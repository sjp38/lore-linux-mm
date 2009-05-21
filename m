Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 261CE6B005A
	for <linux-mm@kvack.org>; Wed, 20 May 2009 22:46:22 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4L2l3iq001243
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 21 May 2009 11:47:03 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B10945DD7B
	for <linux-mm@kvack.org>; Thu, 21 May 2009 11:47:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 41A2545DD78
	for <linux-mm@kvack.org>; Thu, 21 May 2009 11:47:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CF1C1DB803C
	for <linux-mm@kvack.org>; Thu, 21 May 2009 11:47:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B651D1DB803B
	for <linux-mm@kvack.org>; Thu, 21 May 2009 11:47:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH v3] zone_reclaim is always 0 by default
Message-Id: <20090521114408.63D0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 21 May 2009 11:47:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Robin Holt <holt@sgi.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Subject: [PATCH v3] zone_reclaim is always 0 by default

Current linux policy is, zone_reclaim_mode is enabled by default if the machine
has large remote node distance. it's because we could assume that large distance
mean large server until recently.

Unfortunately, recent modern x86 CPU (e.g. Core i7, Opeteron) have P2P transport
memory controller. IOW it's seen as NUMA from software view.
Some Core i7 machine has large remote node distance.

Yanmin reported zone_reclaim_mode=1 cause large apache regression.

    One Nehalem machine has 12GB memory,
    but there is always 2GB free although applications accesses lots of files.
    Eventually we located the root cause as zone_reclaim_mode=1.

Actually, zone_reclaim_mode=1 mean "I dislike remote node allocation rather than
disk access", it makes performance improvement to HPC workload.
but it makes performance degression desktop, file server and web server.

In general, workload depended configration shouldn't put into default settings.
Plus, desktop and file/web server eco-system is much larger than hpc's.

Thus, zone_reclaim == 0 is better by default.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Robin Holt <holt@sgi.com>
Tested-by: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Acked-by: Wu Fengguang <fengguang.wu@intel.com> 
---
 arch/ia64/include/asm/topology.h |    5 -----
 include/linux/topology.h         |    9 +--------
 mm/page_alloc.c                  |    7 -------
 3 files changed, 1 insertion(+), 20 deletions(-)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2494,13 +2494,6 @@ static void build_zonelists(pg_data_t *p
 		int distance = node_distance(local_node, node);
 
 		/*
-		 * If another node is sufficiently far away then it is better
-		 * to reclaim pages in a zone before going off node.
-		 */
-		if (distance > RECLAIM_DISTANCE)
-			zone_reclaim_mode = 1;
-
-		/*
 		 * We don't want to pressure a particular node.
 		 * So adding penalty to the first node in same
 		 * distance group to make it round-robin.
Index: b/arch/ia64/include/asm/topology.h
===================================================================
--- a/arch/ia64/include/asm/topology.h
+++ b/arch/ia64/include/asm/topology.h
@@ -21,11 +21,6 @@
 #define PENALTY_FOR_NODE_WITH_CPUS 255
 
 /*
- * Distance above which we begin to use zone reclaim
- */
-#define RECLAIM_DISTANCE 15
-
-/*
  * Returns the number of the node containing CPU 'cpu'
  */
 #define cpu_to_node(cpu) (int)(cpu_to_node_map[cpu])
Index: b/include/linux/topology.h
===================================================================
--- a/include/linux/topology.h
+++ b/include/linux/topology.h
@@ -53,14 +53,7 @@ int arch_update_cpu_topology(void);
 #ifndef node_distance
 #define node_distance(from,to)	((from) == (to) ? LOCAL_DISTANCE : REMOTE_DISTANCE)
 #endif
-#ifndef RECLAIM_DISTANCE
-/*
- * If the distance between nodes in a system is larger than RECLAIM_DISTANCE
- * (in whatever arch specific measurement units returned by node_distance())
- * then switch on zone reclaim on boot.
- */
-#define RECLAIM_DISTANCE 20
-#endif
+
 #ifndef PENALTY_FOR_NODE_WITH_CPUS
 #define PENALTY_FOR_NODE_WITH_CPUS	(1)
 #endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
