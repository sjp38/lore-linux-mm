Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2]) by deliverator.sgi.com (980309.SGI.8.8.8-aspam-6.2/980310.SGI-aspam) via ESMTP id OAA04514
	for <@external-mail-relay.sgi.com:Linux-MM@kvack.org>; Sun, 6 Jun 1999 14:34:17 -0700 (PDT)
	mail_from (kanoj@google.engr.sgi.com)
Received: from google.engr.sgi.com (google.engr.sgi.com [192.48.174.30])
	by cthulhu.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF)
	via ESMTP id OAA66852
	for <@cthulhu.engr.sgi.com:Linux-MM@kvack.org>;
	Sun, 6 Jun 1999 14:34:56 -0700 (PDT)
	mail_from (kanoj@google.engr.sgi.com)
Received: (from kanoj@localhost) by google.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF) id OAA92960 for Linux-MM@kvack.org; Sun, 6 Jun 1999 14:34:46 -0700 (PDT)
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906062134.OAA92960@google.engr.sgi.com>
Subject: [RFC] [RFT] [PATCH] Exec optimization to save readonly pages
Date: Sun, 6 Jun 1999 14:34:45 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

I have been looking at an optimization that can be done in Linux to 
somewhat cut down the program startup times after an exec. I am not
quite sure whether this can be made to work, I would like people's
opinions on this.

The basic idea is that during an exec, we throw away all the pages
of the process, effectively forcing the new image to fault in all 
the pages it needs, including text pages for libc etc. I am trying
to see if it is easily possible during exec to determine which pages
belong to libc, not throw them away, and pass on these pages into 
the new image (pages of ld.so.cache would be another candidate). 
The idea is nothing new, most Unix-like os's have implemented this. 
Due to the way dso loading works in Linux, it is a little harder to 
achieve this, but I think we can make this work. Another problem in
Linux is that there is no preferred load address for a given dso,
so while the shell may load libc text at a certain address, the
"ls" command, spawned from "sh", might load it at a totally different
address, depending on what other dso's it loads and the order of 
loading.

The patch can be downloaded from 

        http://reality.sgi.com/kanoj_engr/kanoj-mm7-2.2.9

A detailed discussion of the patch is at 

	http://reality.sgi.com/kanoj_engr/tsave.html

Some quick results:

These results are from running the exec_test subtest in the AIM7
suite. These consistently show an improvement of 3 - 5%.

Regular 2.2.9 kernel:
Tasks   Jobs/Min        JTI     Real    CPU     Jobs/sec/task
200     4544.8          99      264.0   1015.9  0.3787
300     4413.7          99      407.8   1590.8  0.2452
400     4261.5          99      563.2   2212.5  0.1776
500     4105.0          99      730.8   2882.0  0.1368
600     3951.9          99      911.0   3602.5  0.1098
700     3802.1          99      1104.6  4376.5  0.0905
800     3676.5          99      1305.6  5179.8  0.0766

Patched 2.2.9 kernel:
Tasks   Jobs/Min        JTI     Real    CPU     Jobs/sec/task
200     4836.6          99      248.1   952.2   0.4030
300     4686.4          99      384.1   1496.2  0.2604
400     4512.0          99      531.9   2087.3  0.1880
500     4304.9          99      696.9   2746.9  0.1435
600     4140.5          99      869.5   3436.9  0.1150
700     3987.9          99      1053.2  4171.0  0.0950
800     3841.3          99      1249.6  4956.0  0.0800


Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
