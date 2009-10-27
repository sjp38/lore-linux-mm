Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E98136B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 02:10:54 -0400 (EDT)
Received: by iwn34 with SMTP id 34so6722221iwn.12
        for <linux-mm@kvack.org>; Mon, 26 Oct 2009 23:10:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
References: <hav57c$rso$1@ger.gmane.org>
	 <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com>
	 <hb2cfu$r08$2@ger.gmane.org>
	 <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
	 <4ADE3121.6090407@gmail.com>
	 <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
	 <4AE5CB4E.4090504@gmail.com>
	 <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 27 Oct 2009 15:10:52 +0900
Message-ID: <2f11576a0910262310g7aea23c0n9bfc84c900879d45@mail.gmail.com>
Subject: Re: Memory overcommit
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

2009/10/27 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
> On Mon, 26 Oct 2009 17:16:14 +0100
> Vedran Fura=C4=8D <vedran.furac@gmail.com> wrote:
>> > =C2=A0- Could you show me /var/log/dmesg and /var/log/messages at OOM =
?
>>
>> It was catastrophe. :) X crashed (or killed) with all the programs, but
>> my little program was alive for 20 minutes (see timestamps). And for
>> that time computer was completely unusable. Couldn't even get the
>> console via ssh. Rally embarrassing for a modern OS to get destroyed by
>> a 5 lines of C run as an ordinary user. Luckily screen was still alive,
>> oomk usually kills it also. See for yourself:
>>
>> dmesg: http://pastebin.com/f3f83738a
>> messages: http://pastebin.com/f2091110a
>>
>> (CCing to lklm again... I just want people to see the logs.)
>>
> Thank you for reporting and your patience. It seems something strange
> that your KDE programs are killed. I agree.
>
> I attached a scirpt for checking oom_score of all exisiting process.
> (oom_score is a value used for selecting "bad" processs.")
> please run if you have time.
>
> This is a result of my own desktop(on virtual machine.)
> In this environ (Total memory is 1.6GBytes), mmap(1G) program is running.
>
> %check_badness.pl | sort -n | tail
> --
> 89924 =C2=A0 3938 =C2=A0 =C2=A0mixer_applet2
> 90210 =C2=A0 3942 =C2=A0 =C2=A0tomboy
> 94753 =C2=A0 3936 =C2=A0 =C2=A0clock-applet
> 101994 =C2=A03919 =C2=A0 =C2=A0pulseaudio
> 113525 =C2=A04028 =C2=A0 =C2=A0gnome-terminal
> 127340 =C2=A01 =C2=A0 =C2=A0 =C2=A0 init
> 128177 =C2=A03871 =C2=A0 =C2=A0nautilus
> 151003 =C2=A011515 =C2=A0 bash
> 256944 =C2=A011653 =C2=A0 mmap
> 425561 =C2=A03829 =C2=A0 =C2=A0gnome-session
> --
> Sigh, gnome-session has twice value of mmap(1G).
> Of course, gnome-session only uses 6M bytes of anon.
> I wonder this is because gnome-session has many children..but need to
> dig more. Does anyone has idea ?
> (CCed kosaki)

Following output address the issue.
The fact is, modern desktop application linked pretty many library. it
makes bloat VSS size and increase
OOM score.

Ideally, We shouldn't account evictable file-backed mappings for oom_score.


# cat /proc/`pidof gnome-session`/maps
00400000-00433000 r-xp 00000000 fd:00 100061
  /usr/bin/gnome-session
00632000-00637000 rw-p 00032000 fd:00 100061
  /usr/bin/gnome-session
00949000-00a10000 rw-p 00000000 00:00 0                                  [h=
eap]
34cf600000-34cf61f000 r-xp 00000000 fd:00 1088
  /lib64/ld-2.10.1.so
34cf81e000-34cf81f000 r--p 0001e000 fd:00 1088
  /lib64/ld-2.10.1.so
34cf81f000-34cf820000 rw-p 0001f000 fd:00 1088
  /lib64/ld-2.10.1.so
34cfa00000-34cfb64000 r-xp 00000000 fd:00 1089
  /lib64/libc-2.10.1.so
34cfb64000-34cfd64000 ---p 00164000 fd:00 1089
  /lib64/libc-2.10.1.so
34cfd64000-34cfd68000 r--p 00164000 fd:00 1089
  /lib64/libc-2.10.1.so
34cfd68000-34cfd69000 rw-p 00168000 fd:00 1089
  /lib64/libc-2.10.1.so
34cfd69000-34cfd6e000 rw-p 00000000 00:00 0
34cfe00000-34cfe82000 r-xp 00000000 fd:00 1104
  /lib64/libm-2.10.1.so
34cfe82000-34d0082000 ---p 00082000 fd:00 1104
  /lib64/libm-2.10.1.so
34d0082000-34d0083000 r--p 00082000 fd:00 1104
  /lib64/libm-2.10.1.so
34d0083000-34d0084000 rw-p 00083000 fd:00 1104
  /lib64/libm-2.10.1.so
34d0200000-34d0202000 r-xp 00000000 fd:00 1095
  /lib64/libdl-2.10.1.so
34d0202000-34d0402000 ---p 00002000 fd:00 1095
  /lib64/libdl-2.10.1.so
34d0402000-34d0403000 r--p 00002000 fd:00 1095
  /lib64/libdl-2.10.1.so
34d0403000-34d0404000 rw-p 00003000 fd:00 1095
  /lib64/libdl-2.10.1.so
34d0600000-34d0617000 r-xp 00000000 fd:00 1090
  /lib64/libpthread-2.10.1.so
34d0617000-34d0816000 ---p 00017000 fd:00 1090
  /lib64/libpthread-2.10.1.so
34d0816000-34d0817000 r--p 00016000 fd:00 1090
  /lib64/libpthread-2.10.1.so
34d0817000-34d0818000 rw-p 00017000 fd:00 1090
  /lib64/libpthread-2.10.1.so
34d0818000-34d081c000 rw-p 00000000 00:00 0
34d0a00000-34d0a15000 r-xp 00000000 fd:00 1113
  /lib64/libz.so.1.2.3
34d0a15000-34d0c14000 ---p 00015000 fd:00 1113
  /lib64/libz.so.1.2.3
34d0c14000-34d0c15000 rw-p 00014000 fd:00 1113
  /lib64/libz.so.1.2.3
34d0e00000-34d0e07000 r-xp 00000000 fd:00 1091
  /lib64/librt-2.10.1.so
34d0e07000-34d1006000 ---p 00007000 fd:00 1091
  /lib64/librt-2.10.1.so
34d1006000-34d1007000 r--p 00006000 fd:00 1091
  /lib64/librt-2.10.1.so
34d1007000-34d1008000 rw-p 00007000 fd:00 1091
  /lib64/librt-2.10.1.so
34d1200000-34d121c000 r-xp 00000000 fd:00 1097
  /lib64/libselinux.so.1
34d121c000-34d141b000 ---p 0001c000 fd:00 1097
  /lib64/libselinux.so.1
34d141b000-34d141c000 r--p 0001b000 fd:00 1097
  /lib64/libselinux.so.1
34d141c000-34d141d000 rw-p 0001c000 fd:00 1097
  /lib64/libselinux.so.1
34d141d000-34d141e000 rw-p 00000000 00:00 0
34d1600000-34d16dd000 r-xp 00000000 fd:00 1092
  /lib64/libglib-2.0.so.0.2000.4
34d16dd000-34d18dc000 ---p 000dd000 fd:00 1092
  /lib64/libglib-2.0.so.0.2000.4
34d18dc000-34d18de000 rw-p 000dc000 fd:00 1092
  /lib64/libglib-2.0.so.0.2000.4
34d1a00000-34d1a41000 r-xp 00000000 fd:00 1094
  /lib64/libgobject-2.0.so.0.2000.4
34d1a41000-34d1c41000 ---p 00041000 fd:00 1094
  /lib64/libgobject-2.0.so.0.2000.4
34d1c41000-34d1c43000 rw-p 00041000 fd:00 1094
  /lib64/libgobject-2.0.so.0.2000.4
34d1e00000-34d1e02000 r-xp 00000000 fd:00 1115
  /usr/lib64/libXau.so.6.0.0
34d1e02000-34d2001000 ---p 00002000 fd:00 1115
  /usr/lib64/libXau.so.6.0.0
34d2001000-34d2002000 rw-p 00001000 fd:00 1115
  /usr/lib64/libXau.so.6.0.0
34d2200000-34d2203000 r-xp 00000000 fd:00 1096
  /lib64/libgmodule-2.0.so.0.2000.4
34d2203000-34d2402000 ---p 00003000 fd:00 1096
  /lib64/libgmodule-2.0.so.0.2000.4
34d2402000-34d2403000 rw-p 00002000 fd:00 1096
  /lib64/libgmodule-2.0.so.0.2000.4
34d2600000-34d261a000 r-xp 00000000 fd:00 1116
  /usr/lib64/libxcb.so.1.1.0
34d261a000-34d281a000 ---p 0001a000 fd:00 1116
  /usr/lib64/libxcb.so.1.1.0
34d281a000-34d281b000 rw-p 0001a000 fd:00 1116
  /usr/lib64/libxcb.so.1.1.0
34d2a00000-34d2b34000 r-xp 00000000 fd:00 1117
  /usr/lib64/libX11.so.6.2.0
34d2b34000-34d2d33000 ---p 00134000 fd:00 1117
  /usr/lib64/libX11.so.6.2.0
34d2d33000-34d2d39000 rw-p 00133000 fd:00 1117
  /usr/lib64/libX11.so.6.2.0
34d2e00000-34d2e04000 r-xp 00000000 fd:00 1093
  /lib64/libgthread-2.0.so.0.2000.4
34d2e04000-34d3003000 ---p 00004000 fd:00 1093
  /lib64/libgthread-2.0.so.0.2000.4
34d3003000-34d3004000 rw-p 00003000 fd:00 1093
  /lib64/libgthread-2.0.so.0.2000.4
34d3200000-34d3226000 r-xp 00000000 fd:00 1111
  /lib64/libexpat.so.1.5.2
34d3226000-34d3425000 ---p 00026000 fd:00 1111
  /lib64/libexpat.so.1.5.2
34d3425000-34d3428000 rw-p 00025000 fd:00 1111
  /lib64/libexpat.so.1.5.2
34d3600000-34d3676000 r-xp 00000000 fd:00 1098
  /lib64/libgio-2.0.so.0.2000.4
34d3676000-34d3875000 ---p 00076000 fd:00 1098
  /lib64/libgio-2.0.so.0.2000.4
34d3875000-34d3877000 rw-p 00075000 fd:00 1098
  /lib64/libgio-2.0.so.0.2000.4
34d3877000-34d3878000 rw-p 00000000 00:00 0
34d3a00000-34d3a93000 r-xp 00000000 fd:00 1110
  /usr/lib64/libfreetype.so.6.3.20
34d3a93000-34d3c93000 ---p 00093000 fd:00 1110
  /usr/lib64/libfreetype.so.6.3.20
34d3c93000-34d3c99000 rw-p 00093000 fd:00 1110
  /usr/lib64/libfreetype.so.6.3.20
34d3e00000-34d3e04000 r-xp 00000000 fd:00 1141
  /lib64/libattr.so.1.1.0
34d3e04000-34d4003000 ---p 00004000 fd:00 1141
  /lib64/libattr.so.1.1.0
34d4003000-34d4004000 rw-p 00003000 fd:00 1141
  /lib64/libattr.so.1.1.0
34d4200000-34d4211000 r-xp 00000000 fd:00 1123
  /usr/lib64/libXext.so.6.4.0
34d4211000-34d4411000 ---p 00011000 fd:00 1123
  /usr/lib64/libXext.so.6.4.0
34d4411000-34d4412000 rw-p 00011000 fd:00 1123
  /usr/lib64/libXext.so.6.4.0
34d4600000-34d4604000 r-xp 00000000 fd:00 1142
  /lib64/libcap.so.2.16
34d4604000-34d4803000 ---p 00004000 fd:00 1142
  /lib64/libcap.so.2.16
34d4803000-34d4804000 rw-p 00003000 fd:00 1142
  /lib64/libcap.so.2.16
34d4a00000-34d4a33000 r-xp 00000000 fd:00 1112
  /usr/lib64/libfontconfig.so.1.4.1
34d4a33000-34d4c32000 ---p 00033000 fd:00 1112
  /usr/lib64/libfontconfig.so.1.4.1
34d4c32000-34d4c34000 rw-p 00032000 fd:00 1112
  /usr/lib64/libfontconfig.so.1.4.1
34d4e00000-34d4e25000 r-xp 00000000 fd:00 1114
  /usr/lib64/libpng12.so.0.37.0
34d4e25000-34d5024000 ---p 00025000 fd:00 1114
  /usr/lib64/libpng12.so.0.37.0
34d5024000-34d5025000 rw-p 00024000 fd:00 1114
  /usr/lib64/libpng12.so.0.37.0
34d5200000-34d523c000 r-xp 00000000 fd:00 1143
  /lib64/libdbus-1.so.3.4.0
34d523c000-34d543c000 ---p 0003c000 fd:00 1143
  /lib64/libdbus-1.so.3.4.0
34d543c000-34d543d000 r--p 0003c000 fd:00 1143
  /lib64/libdbus-1.so.3.4.0
34d543d000-34d543e000 rw-p 0003d000 fd:00 1143
  /lib64/libdbus-1.so.3.4.0
34d5600000-34d5609000 r-xp 00000000 fd:00 1118
  /usr/lib64/libXrender.so.1.3.0
34d5609000-34d5808000 ---p 00009000 fd:00 1118
  /usr/lib64/libXrender.so.1.3.0
34d5808000-34d5809000 rw-p 00008000 fd:00 1118
  /usr/lib64/libXrender.so.1.3.0
34d5a00000-34d5a2c000 r-xp 00000000 fd:00 1121
  /usr/lib64/libpangoft2-1.0.so.0.2400.5
34d5a2c000-34d5c2b000 ---p 0002c000 fd:00 1121
  /usr/lib64/libpangoft2-1.0.so.0.2400.5
34d5c2b000-34d5c2d000 rw-p 0002b000 fd:00 1121
  /usr/lib64/libpangoft2-1.0.so.0.2400.5
34d5e00000-34d5e46000 r-xp 00000000 fd:00 1120
  /usr/lib64/libpango-1.0.so.0.2400.5
34d5e46000-34d6046000 ---p 00046000 fd:00 1120
  /usr/lib64/libpango-1.0.so.0.2400.5
34d6046000-34d6049000 rw-p 00046000 fd:00 1120
  /usr/lib64/libpango-1.0.so.0.2400.5
34d6200000-34d6209000 r-xp 00000000 fd:00 1128
  /usr/lib64/libXcursor.so.1.0.2
34d6209000-34d6409000 ---p 00009000 fd:00 1128
  /usr/lib64/libXcursor.so.1.0.2
34d6409000-34d640a000 rw-p 00009000 fd:00 1128
  /usr/lib64/libXcursor.so.1.0.2
34d6600000-34d6674000 r-xp 00000000 fd:00 1119
  /usr/lib64/libcairo.so.2.10800.8
34d6674000-34d6873000 ---p 00074000 fd:00 1119
  /usr/lib64/libcairo.so.2.10800.8
34d6873000-34d6876000 rw-p 00073000 fd:00 1119
  /usr/lib64/libcairo.so.2.10800.8
34d6a00000-34d6a02000 r-xp 00000000 fd:00 1129
  /usr/lib64/libXcomposite.so.1.0.0
34d6a02000-34d6c01000 ---p 00002000 fd:00 1129
  /usr/lib64/libXcomposite.so.1.0.0
34d6c01000-34d6c02000 rw-p 00001000 fd:00 1129
  /usr/lib64/libXcomposite.so.1.0.0
34d6e00000-34d6e99000 r-xp 00000000 fd:00 1132
  /usr/lib64/libgdk-x11-2.0.so.0.1600.5
34d6e99000-34d7099000 ---p 00099000 fd:00 1132
  /usr/lib64/libgdk-x11-2.0.so.0.1600.5
34d7099000-34d709e000 rw-p 00099000 fd:00 1132
  /usr/lib64/libgdk-x11-2.0.so.0.1600.5
34d7200000-34d7243000 r-xp 00000000 fd:00 1109
  /usr/lib64/libpixman-1.so.0.14.0
34d7243000-34d7442000 ---p 00043000 fd:00 1109
  /usr/lib64/libpixman-1.so.0.14.0
34d7442000-34d7445000 rw-p 00042000 fd:00 1109
  /usr/lib64/libpixman-1.so.0.14.0
34d7600000-34d761d000 r-xp 00000000 fd:00 1131
  /usr/lib64/libgdk_pixbuf-2.0.so.0.1600.5
34d761d000-34d781c000 ---p 0001d000 fd:00 1131
  /usr/lib64/libgdk_pixbuf-2.0.so.0.1600.5
34d781c000-34d781d000 rw-p 0001c000 fd:00 1131
  /usr/lib64/libgdk_pixbuf-2.0.so.0.1600.5
34d7a00000-34d7a08000 r-xp 00000000 fd:00 1126
  /usr/lib64/libXrandr.so.2.2.0
34d7a08000-34d7c07000 ---p 00008000 fd:00 1126
  /usr/lib64/libXrandr.so.2.2.0
34d7c07000-34d7c08000 rw-p 00007000 fd:00 1126
  /usr/lib64/libXrandr.so.2.2.0
34d7e00000-34d7e02000 r-xp 00000000 fd:00 1130
  /usr/lib64/libXdamage.so.1.1.0
34d7e02000-34d8001000 ---p 00002000 fd:00 1130
  /usr/lib64/libXdamage.so.1.1.0
34d8001000-34d8002000 rw-p 00001000 fd:00 1130
  /usr/lib64/libXdamage.so.1.1.0
34d8200000-34d8209000 r-xp 00000000 fd:00 1125
  /usr/lib64/libXi.so.6.0.0
34d8209000-34d8409000 ---p 00009000 fd:00 1125
  /usr/lib64/libXi.so.6.0.0
34d8409000-34d840a000 rw-p 00009000 fd:00 1125
  /usr/lib64/libXi.so.6.0.0
34d8600000-34d8602000 r-xp 00000000 fd:00 1124
  /usr/lib64/libXinerama.so.1.0.0
34d8602000-34d8801000 ---p 00002000 fd:00 1124
  /usr/lib64/libXinerama.so.1.0.0
34d8801000-34d8802000 rw-p 00001000 fd:00 1124
  /usr/lib64/libXinerama.so.1.0.0
34d8a00000-34d8a05000 r-xp 00000000 fd:00 1127
  /usr/lib64/libXfixes.so.3.1.0
34d8a05000-34d8c04000 ---p 00005000 fd:00 1127
  /usr/lib64/libXfixes.so.3.1.0
34d8c04000-34d8c05000 rw-p 00004000 fd:00 1127
  /usr/lib64/libXfixes.so.3.1.0
34d8e00000-34d91d6000 r-xp 00000000 fd:00 1134
  /usr/lib64/libgtk-x11-2.0.so.0.1600.5
34d91d6000-34d93d5000 ---p 003d6000 fd:00 1134
  /usr/lib64/libgtk-x11-2.0.so.0.1600.5
34d93d5000-34d93e0000 rw-p 003d5000 fd:00 1134
  /usr/lib64/libgtk-x11-2.0.so.0.1600.5
34d93e0000-34d93e2000 rw-p 00000000 00:00 0
34d9400000-34d941d000 r-xp 00000000 fd:00 1133
  /usr/lib64/libatk-1.0.so.0.2511.1
34d941d000-34d961c000 ---p 0001d000 fd:00 1133
  /usr/lib64/libatk-1.0.so.0.2511.1
34d961c000-34d961f000 rw-p 0001c000 fd:00 1133
  /usr/lib64/libatk-1.0.so.0.2511.1
34d9800000-34d980b000 r-xp 00000000 fd:00 1122
  /usr/lib64/libpangocairo-1.0.so.0.2400.5
34d980b000-34d9a0a000 ---p 0000b000 fd:00 1122
  /usr/lib64/libpangocairo-1.0.so.0.2400.5
34d9a0a000-34d9a0b000 rw-p 0000a000 fd:00 1122
  /usr/lib64/libpangocairo-1.0.so.0.2400.5
34d9c00000-34d9c20000 r-xp 00000000 fd:00 1144
  /usr/lib64/libdbus-glib-1.so.2.1.0
34d9c20000-34d9e1f000 ---p 00020000 fd:00 1144
  /usr/lib64/libdbus-glib-1.so.2.1.0
34d9e1f000-34d9e21000 rw-p 0001f000 fd:00 1144
  /usr/lib64/libdbus-glib-1.so.2.1.0
34da000000-34da003000 r-xp 00000000 fd:00 16360
  /lib64/libuuid.so.1.2
34da003000-34da203000 ---p 00003000 fd:00 16360
  /lib64/libuuid.so.1.2
34da203000-34da204000 rw-p 00003000 fd:00 16360
  /lib64/libuuid.so.1.2
34da800000-34da85d000 r-xp 00000000 fd:00 1145
  /usr/lib64/libORBit-2.so.0.1.0
34da85d000-34daa5c000 ---p 0005d000 fd:00 1145
  /usr/lib64/libORBit-2.so.0.1.0
34daa5c000-34daa6f000 rw-p 0005c000 fd:00 1145
  /usr/lib64/libORBit-2.so.0.1.0
34db000000-34db039000 r-xp 00000000 fd:00 1146
  /usr/lib64/libgconf-2.so.4.1.5
34db039000-34db239000 ---p 00039000 fd:00 1146
  /usr/lib64/libgconf-2.so.4.1.5
34db239000-34db23e000 rw-p 00039000 fd:00 1146
  /usr/lib64/libgconf-2.so.4.1.5
34db400000-34db407000 r-xp 00000000 fd:00 16361
  /usr/lib64/libSM.so.6.0.0
34db407000-34db607000 ---p 00007000 fd:00 16361
  /usr/lib64/libSM.so.6.0.0
34db607000-34db608000 rw-p 00007000 fd:00 16361
  /usr/lib64/libSM.so.6.0.0
34db800000-34db817000 r-xp 00000000 fd:00 16359
  /usr/lib64/libICE.so.6.3.0
34db817000-34dba17000 ---p 00017000 fd:00 16359
  /usr/lib64/libICE.so.6.3.0
34dba17000-34dba18000 rw-p 00017000 fd:00 16359
  /usr/lib64/libICE.so.6.3.0
34dba18000-34dba1c000 rw-p 00000000 00:00 0
34dd000000-34dd019000 r-xp 00000000 fd:00 1139
  /lib64/libgcc_s-4.4.1-20090729.so.1
34dd019000-34dd219000 ---p 00019000 fd:00 1139
  /lib64/libgcc_s-4.4.1-20090729.so.1
34dd219000-34dd21a000 rw-p 00019000 fd:00 1139
  /lib64/libgcc_s-4.4.1-20090729.so.1
34e0000000-34e0005000 r-xp 00000000 fd:00 26294
  /usr/lib64/libXtst.so.6.1.0
34e0005000-34e0205000 ---p 00005000 fd:00 26294
  /usr/lib64/libXtst.so.6.1.0
34e0205000-34e0206000 rw-p 00005000 fd:00 26294
  /usr/lib64/libXtst.so.6.1.0
34e5000000-34e5018000 r-xp 00000000 fd:00 29867
  /usr/lib64/libpolkit.so.2.0.0
34e5018000-34e5218000 ---p 00018000 fd:00 29867
  /usr/lib64/libpolkit.so.2.0.0
34e5218000-34e5219000 rw-p 00018000 fd:00 29867
  /usr/lib64/libpolkit.so.2.0.0
34e5800000-34e5805000 r-xp 00000000 fd:00 29887
  /usr/lib64/libogg.so.0.5.3
34e5805000-34e5a04000 ---p 00005000 fd:00 29887
  /usr/lib64/libogg.so.0.5.3
34e5a04000-34e5a05000 rw-p 00004000 fd:00 29887
  /usr/lib64/libogg.so.0.5.3
34e6400000-34e6408000 r-xp 00000000 fd:00 1177
  /usr/lib64/libltdl.so.7.2.0
34e6408000-34e6608000 ---p 00008000 fd:00 1177
  /usr/lib64/libltdl.so.7.2.0
34e6608000-34e6609000 rw-p 00008000 fd:00 1177
  /usr/lib64/libltdl.so.7.2.0
34e7400000-34e740c000 r-xp 00000000 fd:00 29868
  /usr/lib64/libpolkit-dbus.so.2.0.0
34e740c000-34e760b000 ---p 0000c000 fd:00 29868
  /usr/lib64/libpolkit-dbus.so.2.0.0
34e760b000-34e760c000 rw-p 0000b000 fd:00 29868
  /usr/lib64/libpolkit-dbus.so.2.0.0
34e7800000-34e781f000 r-xp 00000000 fd:00 29888
  /usr/lib64/libvorbis.so.0.4.0
34e781f000-34e7a1e000 ---p 0001f000 fd:00 29888
  /usr/lib64/libvorbis.so.0.4.0
34e7a1e000-34e7a2d000 rw-p 0001e000 fd:00 29888
  /usr/lib64/libvorbis.so.0.4.0
34e7c00000-34e7c0a000 r-xp 00000000 fd:00 29869
  /usr/lib64/libpolkit-grant.so.2.0.0
34e7c0a000-34e7e09000 ---p 0000a000 fd:00 29869
  /usr/lib64/libpolkit-grant.so.2.0.0
34e7e09000-34e7e0a000 rw-p 00009000 fd:00 29869
  /usr/lib64/libpolkit-grant.so.2.0.0
34e8000000-34e8003000 r-xp 00000000 fd:00 29892
  /usr/lib64/libcanberra-gtk.so.0.0.5
34e8003000-34e8203000 ---p 00003000 fd:00 29892
  /usr/lib64/libcanberra-gtk.so.0.0.5
34e8203000-34e8204000 rw-p 00003000 fd:00 29892
  /usr/lib64/libcanberra-gtk.so.0.0.5
34e8800000-34e880f000 r-xp 00000000 fd:00 29891
  /usr/lib64/libcanberra.so.0.1.5
34e880f000-34e8a0e000 ---p 0000f000 fd:00 29891
  /usr/lib64/libcanberra.so.0.1.5
34e8a0e000-34e8a0f000 rw-p 0000e000 fd:00 29891
  /usr/lib64/libcanberra.so.0.1.5
34e9000000-34e9007000 r-xp 00000000 fd:00 29889
  /usr/lib64/libvorbisfile.so.3.2.0
34e9007000-34e9206000 ---p 00007000 fd:00 29889
  /usr/lib64/libvorbisfile.so.3.2.0
34e9206000-34e9207000 rw-p 00006000 fd:00 29889
  /usr/lib64/libvorbisfile.so.3.2.0
34e9400000-34e940d000 r-xp 00000000 fd:00 29890
  /usr/lib64/libtdb.so.1.1.5
34e940d000-34e960c000 ---p 0000d000 fd:00 29890
  /usr/lib64/libtdb.so.1.1.5
34e960c000-34e960d000 rw-p 0000c000 fd:00 29890
  /usr/lib64/libtdb.so.1.1.5
34e9c00000-34e9c0a000 r-xp 00000000 fd:00 29870
  /usr/lib64/libpolkit-gnome.so.0.0.0
34e9c0a000-34e9e0a000 ---p 0000a000 fd:00 29870
  /usr/lib64/libpolkit-gnome.so.0.0.0
34e9e0a000-34e9e0b000 rw-p 0000a000 fd:00 29870
  /usr/lib64/libpolkit-gnome.so.0.0.0
3d14400000-3d14541000 r-xp 00000000 fd:00 114
  /usr/lib64/libxml2.so.2.7.6
3d14541000-3d14740000 ---p 00141000 fd:00 114
  /usr/lib64/libxml2.so.2.7.6
3d14740000-3d1474a000 rw-p 00140000 fd:00 114
  /usr/lib64/libxml2.so.2.7.6
3d1474a000-3d1474b000 rw-p 00000000 00:00 0
3d14c00000-3d14c18000 r-xp 00000000 fd:00 48785
  /usr/lib64/libglade-2.0.so.0.0.7
3d14c18000-3d14e17000 ---p 00018000 fd:00 48785
  /usr/lib64/libglade-2.0.so.0.0.7
3d14e17000-3d14e19000 rw-p 00017000 fd:00 48785
  /usr/lib64/libglade-2.0.so.0.0.7
3d16800000-3d168ed000 r-xp 00000000 fd:00 22864
  /usr/lib64/libstdc++.so.6.0.12
3d168ed000-3d16aec000 ---p 000ed000 fd:00 22864
  /usr/lib64/libstdc++.so.6.0.12
3d16aec000-3d16af3000 r--p 000ec000 fd:00 22864
  /usr/lib64/libstdc++.so.6.0.12
3d16af3000-3d16af5000 rw-p 000f3000 fd:00 22864
  /usr/lib64/libstdc++.so.6.0.12
3d16af5000-3d16b0a000 rw-p 00000000 00:00 0
7f05a3fae000-7f05a3fc1000 r-xp 00000000 fd:00 22909
  /usr/lib64/libelf-0.142.so
7f05a3fc1000-7f05a41c0000 ---p 00013000 fd:00 22909
  /usr/lib64/libelf-0.142.so
7f05a41c0000-7f05a41c1000 r--p 00012000 fd:00 22909
  /usr/lib64/libelf-0.142.so
7f05a41c1000-7f05a41c2000 rw-p 00013000 fd:00 22909
  /usr/lib64/libelf-0.142.so
7f05a41d4000-7f05a41d7000 r-xp 00000000 fd:00 116786
  /usr/lib64/gtk-2.0/modules/libgnomebreakpad.so
7f05a41d7000-7f05a43d6000 ---p 00003000 fd:00 116786
  /usr/lib64/gtk-2.0/modules/libgnomebreakpad.so
7f05a43d6000-7f05a43d7000 rw-p 00002000 fd:00 116786
  /usr/lib64/gtk-2.0/modules/libgnomebreakpad.so
7f05a43d7000-7f05a43db000 r-xp 00000000 fd:00 40602
  /usr/lib64/gtk-2.0/modules/libcanberra-gtk-module.so
7f05a43db000-7f05a45db000 ---p 00004000 fd:00 40602
  /usr/lib64/gtk-2.0/modules/libcanberra-gtk-module.so
7f05a45db000-7f05a45dc000 rw-p 00004000 fd:00 40602
  /usr/lib64/gtk-2.0/modules/libcanberra-gtk-module.so
7f05a45dc000-7f05a45df000 r-xp 00000000 fd:00 82244
  /usr/lib64/gtk-2.0/modules/libpk-gtk-module.so
7f05a45df000-7f05a47de000 ---p 00003000 fd:00 82244
  /usr/lib64/gtk-2.0/modules/libpk-gtk-module.so
7f05a47de000-7f05a47df000 rw-p 00002000 fd:00 82244
  /usr/lib64/gtk-2.0/modules/libpk-gtk-module.so
7f05a47df000-7f05a47fb000 r--p 00000000 fd:00 14540
  /usr/share/locale/ja/LC_MESSAGES/libc.mo
7f05a47fb000-7f05a480d000 r-xp 00000000 fd:00 53032
  /usr/lib64/gtk-2.0/2.10.0/engines/libnodoka.so
7f05a480d000-7f05a4a0d000 ---p 00012000 fd:00 53032
  /usr/lib64/gtk-2.0/2.10.0/engines/libnodoka.so
7f05a4a0d000-7f05a4a0e000 rw-p 00012000 fd:00 53032
  /usr/lib64/gtk-2.0/2.10.0/engines/libnodoka.so
7f05a4a0e000-7f05a4a0f000 ---p 00000000 00:00 0
7f05a4a0f000-7f05a520f000 rw-p 00000000 00:00 0
7f05a520f000-7f05a521b000 r--p 00000000 fd:00 21639
  /usr/share/locale/ja/LC_MESSAGES/glib20.mo
7f05a521b000-7f05a5227000 r-xp 00000000 fd:00 12418
  /lib64/libnss_files-2.10.1.so
7f05a5227000-7f05a5426000 ---p 0000c000 fd:00 12418
  /lib64/libnss_files-2.10.1.so
7f05a5426000-7f05a5427000 r--p 0000b000 fd:00 12418
  /lib64/libnss_files-2.10.1.so
7f05a5427000-7f05a5428000 rw-p 0000c000 fd:00 12418
  /lib64/libnss_files-2.10.1.so
7f05a5428000-7f05a543a000 r--p 00000000 fd:00 25291
  /usr/share/locale/ja/LC_MESSAGES/GConf2.mo
7f05a543a000-7f05a544e000 r--p 00000000 fd:00 40242
  /usr/share/locale/ja/LC_MESSAGES/gtk20.mo
7f05a544e000-7f05aa520000 r--p 00000000 fd:00 14558
  /usr/lib/locale/locale-archive
7f05aa520000-7f05aa538000 rw-p 00000000 00:00 0
7f05aa53f000-7f05aa546000 r--s 00000000 fd:00 12712
  /usr/lib64/gconv/gconv-modules.cache
7f05aa546000-7f05aa54a000 r--p 00000000 fd:00 110980
  /usr/share/locale/ja/LC_MESSAGES/gnome-session-2.0.mo
7f05aa54a000-7f05aa54c000 rw-p 00000000 00:00 0
7fff45b42000-7fff45b57000 rw-p 00000000 00:00 0                          [s=
tack]
7fff45be4000-7fff45be5000 r-xp 00000000 00:00 0                          [v=
dso]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0
  [vsyscall]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
