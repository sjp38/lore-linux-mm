Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2]) by pneumatic-tube.sgi.com (980327.SGI.8.8.8-aspam/980310.SGI-aspam) via ESMTP id OAA04037
	for <@external-mail-relay.sgi.com:linux-mm@kvack.org>; Mon, 18 Sep 2000 14:47:21 -0700 (PDT)
	mail_from (ananth@sgi.com)
Received: from madurai.engr.sgi.com (madurai.engr.sgi.com [163.154.5.75])
	by cthulhu.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF)
	via ESMTP id OAA87949
	for <@cthulhu.engr.sgi.com:linux-mm@kvack.org>;
	Mon, 18 Sep 2000 14:40:35 -0700 (PDT)
	mail_from (ananth@sgi.com)
Received: from sgi.com (mango.engr.sgi.com [163.154.5.76]) by madurai.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF) via ESMTP id OAA60875 for <linux-mm@kvack.org>; Mon, 18 Sep 2000 14:36:44 -0700 (PDT)
Message-ID: <39C68C65.B91C9447@sgi.com>
Date: Mon, 18 Sep 2000 14:43:01 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Encouraging results from Multiqueue VM Patch
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Here are the results with the latest Multiqueue VM patch (2.4.0-t8-vmpatch4),
labelled TEST8-MQ.  Two earlier versions of the patch 2.4.0-t8p1-vmpatch2,
labelled TEST8-1MQ and 2.4.0-t7p4-vmpatch2b labelled TEST7-5MQ are also
included  ...

Observations
------------

Block I/O performance has definitely improved in the MQ patches.
For writes Test8-MQ does as good as vanilla test5. From an
earlier post note that vanilla test8 is slower thatn test5, so
test8 MQ is better than vanilla test8. Block writes with lmdd
are uniformly faster than any vanilla test version.

Block reads are a little slower in Test8-MQ, but still not bad.

Dbench which is more than just streaming I/O needs some more work,
but compared to previous MQ patches Test8-MQ is better ...

All numbers on a 2P 64MB X86 box using a dedicated scsi disk for the tests
containing an EXT2 filesystem. All tests were run 3 times, in some cases
individual results from 3 runs are reported; in others a range is given.

------
Bonnie
------
              -------Sequential Output-------- ---Sequential Input-- --Random--
              -Per Char-  --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
Machine    MB K/sec %CPU  K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU

TEST8-MQ  256  3624 100.0 11044 16.1  6080 13.3  3292 98.2 15683 19.4 184.4  3.0
TEST8-MQ  256  3638 100.0 11060 15.9  6179 13.0  3294 98.2 15945 17.6 177.9  2.7
TEST8-MQ  256  3639 99.7  11055 15.9  6177 13.3  3300 98.3 16231 18.3 178.5  2.6

TEST8-1MQ 256  3586 98.9   2727  4.9  6094 12.3  3273 97.9 15005 16.3 173.7  2.2
TEST8-1MQ 256  3605 99.4   2503  4.5  6084 12.7  3234 96.3 14219 17.1 172.4  2.8
TEST8-1MQ 256  3599 99.0   2621  4.7  6071 12.6  3282 97.7 14737 15.8 171.5  3.3

TEST7-5MQ 256  3507 97.1   9021 14.3  3715  6.6  2985 88.6 16494 17.7 170.8  2.4
TEST7-5MQ 256  3572 98.9   9153 14.1  3757  7.1  2984 88.1 15749 17.7 170.0  2.5
TEST7-5MQ 256  3566 98.3   9086 13.7  3776  6.8  2975 88.5 16469 16.7 171.4  2.8

TEST5     256  3618 99.2  11135 16.0  5981 10.8  3005 88.8 18268 17.8 185.4  2.9
TEST5     256  3652 100.0 11066 15.6  6014 10.6  2999 89.1 18276 17.4 185.5  2.8
TEST5     256  3647 99.8  11055 15.8  5924 10.3  3003 88.8 18270 18.5 183.5  3.1
 
-----------------------------------
lmdd (across blocksizes 1K to 1024K)
------------------------------------
                 Write            Read
                ---------       --------
TEST8-MQ         ~12 MB/sec      16.8 - 17.7 MB/sec
                                 18.5 MB/sec [ 1K blocksize ]
TEST8-1MQ       2.5 - 3.5 MB/s   14.5 - 17.7 MB/sec
                                [ MB/sec increases with blocksize ]
TEST7-5+MQ      9.4-10.4 MB/s   15.5-17 MB/sec
TEST5           11.5  MB/s       ~19   MB/s
 
-------------------
DBENCH (48 clients)
-------------------
TEST8-MQ    4.5, 4.7, 5.1 MB/sec
TEST8-1MQ   3.6, 3.8, 4.2 MB/sec
TEST7-5+MQ  2.7, 2.7, 1.9 MB/sec
TEST5       11.5 - 12.4   MB/sec

-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
