Date: Mon, 28 Apr 2008 20:19:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] memcg: performance improvement v2 [0/8]
Message-Id: <20080428201900.ae25e086.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Hi, this is a set of patches for improving memcg performance.
This is a kind of status report of my work but I'm glad if someone test and
review this. pefromance results on micro benchmark are below.

This is updated version agasint 2.6.25-mm1. This is still RFC but I'd like
to post some of set after merge-window if no objections.


patch 1-3 are well tested. patch 4-8 are new ones.
==
1/8 ... migration handling update.
2/8 ... remove refcnt
3/8 ... swap cache handling again
4/8 ... mark as read_mostly.
5/8 ... optimization
6/8 ... remove redundant initilization.
7/8 ... remove redundant checks on chage.
8/8 ... remove excessive function.


Following are result of unixbench on x86-64/2core system.

by #./Run execl C shell fstime fsbuffer fsdisk dc

disabled --- disabled by boot ops (but congfigured)
enabled  --- 2.6.25-mm1 with cgroup_enable=memory
(*1)     --- patch 1-3 are applied.
(*2)     --- patch 1-8 are applied. (patch 4-8 are young, I need more checks.)

                                           disabled       enabled      (*1)      (*2)
Execl Throughput                           3111.8 lps      2896.8    3005.6    3003.8
C Compiler Throughput                      1073.3 lpm       982.5     961.6    1034.3
Shell Scripts (1 concurrent)               5741.0 lpm      5417.7    5682.0    5840.6
Shell Scripts (8 concurrent)               1168.3 lpm      1108.7    1132.3    1139.3
Shell Scripts (16 concurrent)               602.3 lpm       570.7     582.3     586.3
File Read 1024 bufsize 2000 maxblocks    1025248.0 KBps 1016883.0 1027897.0 1017299.0
File Write 1024 bufsize 2000 maxblocks   551012.0 KBps   554619.0  554656.0  548747.0
File Copy 1024 bufsize 2000 maxblocks    346886.0 KBps   351423.0  348238.0  344135.0
File Read 256 bufsize 500 maxblocks      323261.0 KBps   324092.0  320753.0  323042.0
File Write 256 bufsize 500 maxblocks     151046.0 KBps   151319.0  152143.0  151431.0
File Copy 256 bufsize 500 maxblocks      100806.0 KBps   101166.0  100270.0  100947.0
File Read 4096 bufsize 8000 maxblocks    2055692.0 KBps 2050954.0 2055142.0 2047008.0
File Write 4096 bufsize 8000 maxblocks   1619457.0 KBps 1627458.0 1621503.0 1615020.0
File Copy 4096 bufsize 8000 maxblocks    865003.0 KBps   862464.0  861305.0  856702.0
Dc: sqrt(2) to 99 decimal places         133621.2 lpm    125084.7  128716.2  128877.8
 
 - Execl/C/Shel/Dc shows overhead, which comes from map/unmap pages.
 - I don't think file-benchmark shows overhead of memory resource controller.
 - I don't have bigger x86-64 system. sorry.

I'm sorry but I'll be completely offline from May/1st to May/6. So, my answer
may be delayed.

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
