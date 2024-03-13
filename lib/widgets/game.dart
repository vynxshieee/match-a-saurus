// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/card_item.dart';
import 'package:memory_game/widgets/card_widget.dart';
import 'package:memory_game/widgets/home_page.dart';
import 'package:memory_game/widgets/leaderboard.dart';

class Game extends StatefulWidget {
  const Game({super.key});
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> { 
  late List<CardItem> _cards;
  late List<CardItem> _validPairs;
  late CardItem? _tappedCard;
  late int _counter;
  late Timer _timer;
  late int _rows;
  late int _cols;
  int _score = 0;
  late int _multiplier; 
  bool _enableTaps = true;

  late double deviceWidth;
  late double deviceHeight;
  
  @override
  void initState(){
    super.initState();
    String? difficulty = Database.optionsBox?.get("difficulty");
    switch(difficulty){
      case "Easy": 
        setState(() {
          _multiplier = 1;
          _rows = 3;
          _cols = 4;
        }); 
        break;
      case "Medium":
         setState(() {
          _multiplier = 2;
          _rows = 4;
          _cols = 5;
        }); 
        break;
      case "Hard":
       setState(() {
          _multiplier = 3;
          _rows = 6;
          _cols = 6;
        }); 
        break;
      default:
        throw Exception("Must not be reached");
    }
    _cards = _getRandomCards(_rows*_cols);
    _tappedCard = null;
    _validPairs = [];
    _startTimer(60);
  }

  List<CardItem> _shuffleCards(List<CardItem> cards) {
    Random rng = Random();
    for(int i = cards.length-1; i >= 1; --i){
      int newIdx = rng.nextInt(i);
      CardItem temp = cards[i];
      cards[i] = cards[newIdx];
      cards[newIdx] = temp;
    }
    return cards;
  }
  List<CardItem> _getRandomCards(int max) {
    return _shuffleCards(CardItem.getCards(_rows*_cols));
  }

  @override 
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  void _startTimer(int time){
    _counter = time;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(_counter > 0){
        setState(() {
         --_counter;
        });
      } else {
        timer.cancel();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Leaderboard(score: _score)));
      }
    });
  }

  void _handleTap(CardItem card){
    if(_counter == 0){
      return;
    }
    card.isTapped = true;
    setState(() => _tappedCard ??= card);
    if(_tappedCard == card){
      return;
    }
    if(_tappedCard?.val == card.val){
      setState(() {
        _score += _counter;
        _score *= _multiplier;
        _validPairs.add(_tappedCard!);
        _validPairs.add(card);
        _tappedCard = null;
      });
    }
    else{
      setState(() => _enableTaps = false);
      Timer(const Duration(milliseconds: 500), () {
          _tappedCard?.isTapped = false;
          card.isTapped = false;
          _tappedCard = null;
          setState(() => _enableTaps = true);
        });
    }
    if(_validPairs.length == _cards.length){
      _timer.cancel();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Leaderboard(score: _score)));
    }
  }

  String _secondsToMinutes(int s){
    int minutes = (s / 60).truncate();
    int seconds = (s % 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

AlertDialog _buildPopupDialog(BuildContext context) {
  double dialogWidth = MediaQuery.of(context).size.width - 20;
  return AlertDialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(0),
    content: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: deviceWidth,
          width: deviceWidth,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/game-paused-bg.png"),
              fit: BoxFit.contain
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide (
                      width: 5.0,
                      color:Color.fromRGBO(36, 107, 34, 1)
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    )
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                  }, 
                  child: const Text(
                    "back to main menu",
                    style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'MadimiOne',
                        color: Color.fromRGBO(36, 107, 34, 1),
                        shadows: [
                          Shadow( 
                            offset: Offset(3.0, 3.0), 
                            blurRadius: 2.0,
                            color: Color.fromRGBO(255, 220, 80, 1),
                          ),
                        ],
                      ),
                    ),
                ),
              ),
              SizedBox(height: 20,),
              SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide (
                      width: 5.0,
                      color:Color.fromRGBO(36, 107, 34, 1)
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    )
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => const Game())
                    );
                  }, 
                  child: const Text(
                    "restart game",
                    style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'MadimiOne',
                        color: Color.fromRGBO(36, 107, 34, 1),
                        shadows: [
                          Shadow( 
                            offset: Offset(3.0, 3.0), 
                            blurRadius: 2.0,
                            color: Color.fromRGBO(255, 220, 80, 1), 
                          ),
                        ],
                      ),
                    ),
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
       ),
      
       Positioned(
        bottom: 12,
        left: (deviceWidth - (dialogWidth / 3)) / 2,
        child: SizedBox(
          height: 70,
          width: 70,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.transparent
              ),
              onPressed: () {
                _startTimer(_counter);
                Navigator.of(context).pop();
              }, 
              child: const Text(
                "",
                textAlign: TextAlign.center, 
                style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'MadimiOne',
                    color: Color.fromRGBO(36, 107, 34, 1),
                    shadows: [
                      Shadow( // Adjust offsets and blurRadius for stroke thickness
                        offset: Offset(3.0, 3.0),
                        color: Color.fromRGBO(255, 220, 80, 1), // Set your stroke color
                      ),
                    ],
                  ),
                ),
            ),
          ),
       ),
       
      ],
    )
  );
}

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: (_counter != 0) ? Text("Time: ${_secondsToMinutes(_counter)} Score: $_score") : const Text("Time's up!")),
        backgroundColor: _counter != 0 ? Colors.blue : Colors.red,
        actions: [IconButton(icon: const Icon(Icons.pause), onPressed: () { 
              _timer.cancel();
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext dialogContext) {
                      return _buildPopupDialog(dialogContext);
                    }
              );
            }) 
          ],
        ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        childAspectRatio: _rows == 6 ? 0.63 : 0.8,
        crossAxisCount: _rows,
        mainAxisSpacing: _rows == 6 ? 35.0 : 20.0,
        crossAxisSpacing: _rows == 6? 10.0 : 20.0,
        children: _cards.map((card) => CardWidget(
          card: card,
          onTap: _enableTaps ? _handleTap : null,
          )).toList()
        ),
    );
  }

}