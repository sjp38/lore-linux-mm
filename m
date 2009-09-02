Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8ECE86B004F
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 19:17:01 -0400 (EDT)
Received: by bwz24 with SMTP id 24so1133914bwz.38
        for <linux-mm@kvack.org>; Wed, 02 Sep 2009 16:17:05 -0700 (PDT)
Date: Thu, 3 Sep 2009 08:15:48 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RESEND][PATCH mmotm] Fix NUMA accounting in numastat.txt
Message-Id: <20090903081548.482b8771.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


In Documentation/numastat.txt, it confused me.
For example, there are nodes [0,1] in system.

barrios:~$ cat /proc/zoneinfo | egrep 'numa|zone'
Node 0, zone	DMA
	numa_hit	33226
	numa_miss	1739
	numa_foreign	27978
	..
	..
Node 1, zone	DMA
	numa_hit	307
	numa_miss	46900
	numa_foreign	0

1) In node 0,  NUMA_MISS means it wanted to allocate page
in node 1 but ended up with page in node 0

2) In node 0, NUMA_FOREIGN means it wanted to allocate page
in node 0 but ended up with page from Node 1.

But now, numastat explains it oppositely about (MISS, FOREIGN).
Let's fix up with viewpoint of zone. 

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: Christoph Lameter <cl@linux-foundation.org>
---
 Documentation/numastat.txt |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/numastat.txt b/Documentation/numastat.txt
index 80133ac..9fcc9a6 100644
--- a/Documentation/numastat.txt
+++ b/Documentation/numastat.txt
@@ -7,10 +7,10 @@ All units are pages. Hugepages have separate counters.

 numa_hit			A process wanted to allocate memory from this node,
 					and succeeded.
-numa_miss			A process wanted to allocate memory from this node,
-					but ended up with memory from another.
-numa_foreign		A process wanted to allocate on another node,
-				    but ended up with memory from this one.
+numa_miss			A process wanted to allocate memory from another node,
+					but ended up with memory from this node.
+numa_foreign		A process wanted to allocate on this node,
+				    but ended up with memory from another one.
 local_node			A process ran on this node and got memory from it.
 other_node			A process ran on this node and got memory from another node.
 interleave_hit 		Interleaving wanted to allocate from this node
--
1.5.4.3



-- 
Kind regards,
Minchan Kim


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
