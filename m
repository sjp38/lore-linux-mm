Message-ID: <39B41F53.50DD6A9@sgi.com>
Date: Mon, 04 Sep 2000 15:16:51 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Multiqueue VM Patch performance (2.4.0-t8p1-vmpatch2)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Here are the results with the latest Multiqueue VM patch (2.4.0-t8p1-vmpatch2),
labelled TEST8-1MQ.  Except for an improvement in dbench, TEST8-1MQ does
poorly in block I/O operations. Write performance has definitely gone down.
An earlier version of the patch (2.4.0-t7p4-vmpatch2b), labelled
TEST7-5MQ below does better. Both MQ patches do worse than test5 or test8-1.

All numbers on a 2P 64MB X86 box using a dedicated scsi disk for the tests
containing an EXT2 filesystem. All tests were run 3 times, in some cases
individual results from 3 runs are reported; in others a range is given.

------
Bonnie
------
              -------Sequential Output-------- ---Sequential Input-- --Random--
              -Per Char-  --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
Machine    MB K/sec %CPU  K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU

TEST8-1MQ 256  3586 98.9   2727  4.9  6094 12.3  3273 97.9 15005 16.3 173.7  2.2
TEST8-1MQ 256  3605 99.4   2503  4.5  6084 12.7  3234 96.3 14219 17.1 172.4  2.8
TEST8-1MQ 256  3599 99.0   2621  4.7  6071 12.6  3282 97.7 14737 15.8 171.5  3.3

TEST8-1   256  3647 99.9  10169 14.5  5835 11.3  3321 98.3 17887 19.0 190.1  2.8
TEST8-1   256  3647 100.7 10206 14.2  5819 10.9  3323 99.3 17894 19.6 187.8  2.6
TEST8-1   256  3647 100.2 10090 14.3  5785 11.4  3322 99.3 17707 19.5 187.0  3.6

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
TEST8-1MQ       2.5 - 3.5 MB/s   14.5 - 17.7 MB/sec
                                [ MB/sec increases with blocksize ]
TEST8-1         10.8  MB/s       ~19   MB/sec [ blocksizes 1K -> 128 K ]
                                 ~17.6 MB/sec [ blocksizes 256K -> 1024K ]
TEST7-5+MQ      9.4-10.4 MB/s   15.5-17 MB/sec
TEST5           11.5  MB/s       ~19   MB/s
 
-------------------
DBENCH (48 clients)
-------------------
TEST8-1MQ   3.6, 3.8, 4.2 MB/sec
TEST8-1     8.6, 7.8, 9.0 MB/sec
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
