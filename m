Date: Thu, 15 May 2008 18:25:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH -mm 0/5] memcg: performance improvement v4
Message-Id: <20080515182516.763967cc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

Hi, this version is against 2.6.26-rc2-mm1...much easier to try ;)
please test.

Major changes from v3.
 - shmem handling is fixed.
 - dropped drop_pages patch (1/6 in v3). It will be rescheduled.
 - applied comments (Thanks!)

brief test result on x86-64 (2core) system is attached below but it seems
better to be tested on bigger system/bigger benchmark.
(But I can't do now, sorry)

Patch Description
 1/5 ... remove refcnt fron page_cgroup patch (shmem handling is fixed)
 2/5 ... swapcache handling patch
 3/5 ... add helper function for shmem's memory reclaim patch
 4/5 ... optimize by likely/unlikely ppatch
 5/5 ... remove redundunt check patch (shmem handling is fixed.)

Unix bench result.

== 2.6.26-rc2-mm1 + memory resource controller
Execl Throughput                           2915.4 lps   (29.6 secs, 3 samples)
C Compiler Throughput                      1019.3 lpm   (60.0 secs, 3 samples)
Shell Scripts (1 concurrent)               5796.0 lpm   (60.0 secs, 3 samples)
Shell Scripts (8 concurrent)               1097.7 lpm   (60.0 secs, 3 samples)
Shell Scripts (16 concurrent)               565.3 lpm   (60.0 secs, 3 samples)
File Read 1024 bufsize 2000 maxblocks    1022128.0 KBps  (30.0 secs, 3 samples)
File Write 1024 bufsize 2000 maxblocks   544057.0 KBps  (30.0 secs, 3 samples)
File Copy 1024 bufsize 2000 maxblocks    346481.0 KBps  (30.0 secs, 3 samples)
File Read 256 bufsize 500 maxblocks      319325.0 KBps  (30.0 secs, 3 samples)
File Write 256 bufsize 500 maxblocks     148788.0 KBps  (30.0 secs, 3 samples)
File Copy 256 bufsize 500 maxblocks       99051.0 KBps  (30.0 secs, 3 samples)
File Read 4096 bufsize 8000 maxblocks    2058917.0 KBps  (30.0 secs, 3 samples)
File Write 4096 bufsize 8000 maxblocks   1606109.0 KBps  (30.0 secs, 3 samples)
File Copy 4096 bufsize 8000 maxblocks    854789.0 KBps  (30.0 secs, 3 samples)
Dc: sqrt(2) to 99 decimal places         126145.2 lpm   (30.0 secs, 3 samples)


                     INDEX VALUES
TEST                                        BASELINE     RESULT      INDEX

Execl Throughput                                43.0     2915.4      678.0
File Copy 1024 bufsize 2000 maxblocks         3960.0   346481.0      875.0
File Copy 256 bufsize 500 maxblocks           1655.0    99051.0      598.5
File Copy 4096 bufsize 8000 maxblocks         5800.0   854789.0     1473.8
Shell Scripts (8 concurrent)                     6.0     1097.7     1829.5
                                                                 =========
     FINAL SCORE                                                     991.3

== 2.6.26-rc2-mm1 + this set ==
Execl Throughput                           3012.9 lps   (29.9 secs, 3 samples)
C Compiler Throughput                       981.0 lpm   (60.0 secs, 3 samples)
Shell Scripts (1 concurrent)               5872.0 lpm   (60.0 secs, 3 samples)
Shell Scripts (8 concurrent)               1120.3 lpm   (60.0 secs, 3 samples)
Shell Scripts (16 concurrent)               578.0 lpm   (60.0 secs, 3 samples)
File Read 1024 bufsize 2000 maxblocks    1003993.0 KBps  (30.0 secs, 3 samples)
File Write 1024 bufsize 2000 maxblocks   550452.0 KBps  (30.0 secs, 3 samples)
File Copy 1024 bufsize 2000 maxblocks    347159.0 KBps  (30.0 secs, 3 samples)
File Read 256 bufsize 500 maxblocks      314644.0 KBps  (30.0 secs, 3 samples)
File Write 256 bufsize 500 maxblocks     151852.0 KBps  (30.0 secs, 3 samples)
File Copy 256 bufsize 500 maxblocks      101000.0 KBps  (30.0 secs, 3 samples)
File Read 4096 bufsize 8000 maxblocks    2033256.0 KBps  (30.0 secs, 3 samples)
File Write 4096 bufsize 8000 maxblocks   1611814.0 KBps  (30.0 secs, 3 samples)
File Copy 4096 bufsize 8000 maxblocks    847979.0 KBps  (30.0 secs, 3 samples)
Dc: sqrt(2) to 99 decimal places         128148.7 lpm   (30.0 secs, 3 samples)


                     INDEX VALUES
TEST                                        BASELINE     RESULT      INDEX

Execl Throughput                                43.0     3012.9      700.7
File Copy 1024 bufsize 2000 maxblocks         3960.0   347159.0      876.7
File Copy 256 bufsize 500 maxblocks           1655.0   101000.0      610.3
File Copy 4096 bufsize 8000 maxblocks         5800.0   847979.0     1462.0
Shell Scripts (8 concurrent)                     6.0     1120.3     1867.2
                                                                 =========
     FINAL SCORE                                                    1004.6


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
