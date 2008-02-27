From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 27 Feb 2008 16:47:28 -0500
Message-Id: <20080227214728.6858.79000.sendpatchset@localhost>
In-Reply-To: <20080227214708.6858.53458.sendpatchset@localhost>
References: <20080227214708.6858.53458.sendpatchset@localhost>
Subject: [PATCH 3/6] Remember what the preferred zone is for zone_statistics
Sender: owner-linux-mm@kvack.org
From: Mel Gorman <mel@csn.ul.ie>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: mel@csn.ul.ie, ak@suse.de, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 3/6] Remember what the preferred zone is for zone_statistics

V11r3 against 2.6.25-rc2-mm1

On NUMA, zone_statistics() is used to record events like numa hit, miss
and foreign. It assumes that the first zone in a zonelist is the preferred
zone. When multiple zonelists are replaced by one that is filtered, this
is no longer the case.

This patch records what the preferred zone is rather than assuming the
first zone in the zonelist is it. This simplifies the reading of later
patches in this set.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/vmstat.h |    2 +-
 mm/page_alloc.c        |    9 +++++----
 mm/vmstat.c            |    6 +++---
 3 files changed, 9 insertions(+), 8 deletions(-)

Index: linux-2.6.25-rc2-mm1/include/linux/vmstat.h
===================================================================
--- linux-2.6.25-rc2-mm1.orig/include/linux/vmstat.h	2008-02-27 16:28:04.000000000 -0500
+++ linux-2.6.25-rc2-mm1/include/linux/vmstat.h	2008-02-27 16:28:14.000000000 -0500
@@ -174,7 +174,7 @@ static inline unsigned long node_page_st
 		zone_page_state(&zones[ZONE_MOVABLE], item);
 }
 
-extern void zone_statistics(struct zonelist *, struct zone *);
+extern void zone_statistics(struct zone *, struct zone *);
 
 #else
 
Index: linux-2.6.25-rc2-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/page_alloc.c	2008-02-27 16:28:11.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/page_alloc.c	2008-02-27 16:28:14.000000000 -0500
@@ -1060,7 +1060,7 @@ void split_page(struct page *page, unsig
  * we cheat by calling it from here, in the order > 0 path.  Saves a branch
  * or two.
  */
-static struct page *buffered_rmqueue(struct zonelist *zonelist,
+static struct page *buffered_rmqueue(struct zone *preferred_zone,
 			struct zone *zone, int order, gfp_t gfp_flags)
 {
 	unsigned long flags;
@@ -1112,7 +1112,7 @@ again:
 	}
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
-	zone_statistics(zonelist, zone);
+	zone_statistics(preferred_zone, zone);
 	local_irq_restore(flags);
 	put_cpu();
 
@@ -1393,7 +1393,7 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	struct zone **z;
 	struct page *page = NULL;
 	int classzone_idx = zone_idx(zonelist->zones[0]);
-	struct zone *zone;
+	struct zone *zone, *preferred_zone;
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
@@ -1405,6 +1405,7 @@ zonelist_scan:
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
 	z = zonelist->zones;
+	preferred_zone = *z;
 
 	do {
 		/*
@@ -1443,7 +1444,7 @@ zonelist_scan:
 			}
 		}
 
-		page = buffered_rmqueue(zonelist, zone, order, gfp_mask);
+		page = buffered_rmqueue(preferred_zone, zone, order, gfp_mask);
 		if (page)
 			break;
 this_zone_full:
Index: linux-2.6.25-rc2-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/vmstat.c	2008-02-27 16:28:04.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/vmstat.c	2008-02-27 16:28:14.000000000 -0500
@@ -365,13 +365,13 @@ void refresh_cpu_vm_stats(int cpu)
  *
  * Must be called with interrupts disabled.
  */
-void zone_statistics(struct zonelist *zonelist, struct zone *z)
+void zone_statistics(struct zone *preferred_zone, struct zone *z)
 {
-	if (z->zone_pgdat == zonelist->zones[0]->zone_pgdat) {
+	if (z->zone_pgdat == preferred_zone->zone_pgdat) {
 		__inc_zone_state(z, NUMA_HIT);
 	} else {
 		__inc_zone_state(z, NUMA_MISS);
-		__inc_zone_state(zonelist->zones[0], NUMA_FOREIGN);
+		__inc_zone_state(preferred_zone, NUMA_FOREIGN);
 	}
 	if (z->node == numa_node_id())
 		__inc_zone_state(z, NUMA_LOCAL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
