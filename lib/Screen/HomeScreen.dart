import '../Model/ChatRoomModel.dart';
import '../Model/FirebaseHelper.dart';
import 'ChatRoomScreen.dart';
import 'LoginScreen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Model/UIHelper.dart';
import '../Model/UserModel.dart';
import 'SearchScreen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomeScreen(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            icon : Icon(Icons.person),
          onPressed: () {
              UIHelper.showAlertDialog(context,"About us", text);
          },
        ),
       backgroundColor: Colors.green,
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // ignore: use_build_context_synchronously
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              },
              
              icon: const Icon(FontAwesomeIcons.signOut))
        ],
        title: const Text("ChitChat"),
        centerTitle: true,
      ),
      body:  Container(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('ChatRoom')
                  .where("participants.${widget.userModel.uid}",
                      isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot chatRoomSnapshot =
                        snapshot.data as QuerySnapshot;
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      itemCount: chatRoomSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                            chatRoomSnapshot.docs[index].data()
                                as Map<String, dynamic>);

                        Map<String, dynamic> participants =
                            chatRoomModel.participants!;
                        List<String> participantsKeys =
                            participants.keys.toList();
                        participantsKeys.remove(widget.userModel.uid);
                        return FutureBuilder(
                          future: FirebaseHelper.getUserModelById(
                              participantsKeys[0]),
                          builder: (context, userData) {
                            if (userData.connectionState ==
                                ConnectionState.done) {
                              if (userData.data != null) {
                                UserModel targetUser =
                                    userData.data as UserModel;
                                return ListTile(
                                  shape: const RoundedRectangleBorder(side : BorderSide(width : 1,color: Colors.green)),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ChatRoomScreen(
                                                    targetUser: targetUser,
                                                    chatRoom: chatRoomModel,
                                                    userModel: widget.userModel,
                                                    firebaseUser:
                                                        widget.firebaseUser)));
                                  },
                                  title: Text(targetUser.fullName.toString(),style : TextStyle(color: Colors.black),),
                                  subtitle: chatRoomModel.lastMessage.toString() !="" ? Text(
                                      chatRoomModel.lastMessage.toString(),style : TextStyle(color: Colors.green) ): Text("Say Hii!",style: TextStyle(color: Colors.blue),),
                                  leading: GestureDetector(
                                    onTap: ()async {
                                       await showDialog(
                                         
                                         context: context, builder: (_)=>Dialog(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                                        targetUser.profilePic.toString()),
            fit: BoxFit.cover
          )
        ),
      ),
    ));
                                    },
                                    child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        targetUser.profilePic.toString()),
                                  ),
                                  )
                                );
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else {
                    return Center(
                      child: Text("No Chats",style: TextStyle(color: Colors.black),),
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchScreen(
                      userModel: widget.userModel,
                      firebaseUser: widget.firebaseUser)));
        },
        child: const Icon(FontAwesomeIcons.rocketchat,color: Colors.white,),
      ),
    );
  }
}
const String text = "This app was created by an engineering student Yogesh Tiwari in his second year of Electrical engineering from NIT jamshedpur.\nThis app provides the instant communication functionality between users.\nThe users have the capability to do one to one communication by means of text And the users can receive messages instantly while online";
