Date: Mon, 30 Jan 2006 12:24:07 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Zone reclaim: Allow modification of zone reclaim behavior
Message-ID: <Pine.LNX.4.62.0601301223350.4821@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In some situations one may want zone_reclaim to behave differently. For
example a process writing large amounts of memory will spew unto other
nodes to cache the writes if many pages in a zone become dirty. This may
impact the performance of processes running on other nodes.

Allowing writes during reclaim puts a stop to that behavior and throttles
the process by restricting the pages to the local zone.

Similarly one may want to contain processes to local memory by enabling
regular swap behavior during zone_reclaim. Off node memory allocation
can then be controlled through memory policies and cpusets.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc1-mm4/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc1-mm4.orig/mm/vmscan.c	2006-01-30 11:31:31.000000000 -0800
+++ linux-2.6.16-rc1-mm4/mm/vmscan.c	2006-01-30 12:19:49.000000000 -0800
@@ -1831,6 +1831,11 @@ module_init(kswapd_init)
  */
 int zone_reclaim_mode __read_mostly;
 
+#define RECLAIM_OFF 0
+#define RECLAIM_ZONE (1<<0)	/* Run shrink_cache on the zone */
+#define RECLAIM_WRITE (1<<1)	/* Writeout pages during reclaim */
+#define RECLAIM_SWAP (1<<2)	/* Swap pages out during reclaim */
+
 /*
  * Mininum time between zone reclaim scans
  */
@@ -1869,8 +1874,8 @@ int zone_reclaim(struct zone *zone, gfp_
 	if (!cpus_empty(mask) && node_id != numa_node_id())
 		return 0;
 
-	sc.may_writepage = 0;
-	sc.may_swap = 0;
+	sc.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE);
+	sc.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP);
 	sc.nr_scanned = 0;
 	sc.nr_reclaimed = 0;
 	sc.priority = ZONE_RECLAIM_PRIORITY + 1;
Index: linux-2.6.16-rc1-mm4/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.16-rc1-mm4.orig/Documentation/sysctl/vm.txt	2006-01-30 12:13:33.000000000 -0800
+++ linux-2.6.16-rc1-mm4/Documentation/sysctl/vm.txt	2006-01-30 12:22:18.000000000 -0800
@@ -127,17 +127,39 @@ the high water marks for each per cpu pa
 
 zone_reclaim_mode:
 
-This is set during bootup to 1 if it is determined that pages from
-remote zones will cause a significant performance reduction. The
+Zone_reclaim_mode allows to set more or less agressive approaches to
+reclaim memory when a zone runs out of memory. If it is set to zero then no
+zone reclaim occurs. Allocations will be satisfied from other zones / nodes
+in the system.
+
+This is value ORed together of
+
+1	= Zone reclaim on
+2	= Zone reclaim writes dirty pages out
+4	= Zone reclaim swaps pages
+
+zone_reclaim_mode is set during bootup to 1 if it is determined that pages
+from remote zones will cause a measurable performance reduction. The
 page allocator will then reclaim easily reusable pages (those page
-cache pages that are currently not used) before going off node.
+cache pages that are currently not used) before allocating off node pages.
 
-The user can override this setting. It may be beneficial to switch
-off zone reclaim if the system is used for a file server and all
-of memory should be used for caching files from disk.
+It may be beneficial to switch off zone reclaim if the system is
+used for a file server and all of memory should be used for caching files
+from disk. In that case the caching effect is more important than
+data locality.
+
+Allowing zone reclaim to write out pages stops processes that are
+writing large amounts of data from dirtying pages on other nodes. Zone
+reclaim will write out dirty pages if a zone fills up and so effectively
+throttle the process. This may decrease the performance of a single process
+since it cannot use all of system memory to buffer the outgoing writes
+anymore but it preserve the memory on other nodes so that the performance
+of other processes running on other nodes will not be affected.
+
+Allowing regular swap effectively restricts allocations to the local
+node unless explicitly overridden by memory policies or cpuset
+configurations.
 
-It may be beneficial to switch this on if one wants to do zone
-reclaim regardless of the numa distances in the system.
 ================================================================
 
 zone_reclaim_interval:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
