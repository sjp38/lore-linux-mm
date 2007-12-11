From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20071211202257.1961.66587.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20071211202157.1961.27940.sendpatchset@skynet.skynet.ie>
References: <20071211202157.1961.27940.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/6] Remember what the preferred zone is for zone_statistics
Date: Tue, 11 Dec 2007 20:22:57 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Lee.Schermerhorn@hp.com, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On NUMA, zone_statistics() is used to record events like numa hit, miss
and foreign. It assumes that the first zone in a zonelist is the preferred
zone. When multiple zonelists are replaced by one that is filtered, this
is no longer the case.

This patch records what the preferred zone is rather than assuming the
first zone in the zonelist is it. This simplifies the reading of later
patches in this set.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 include/linux/vmstat.h |    2 +-
 mm/page_alloc.c        |    9 +++++----
 mm/vmstat.c            |    6 +++---
 3 files changed, 9 insertions(+), 8 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc4-mm1-007_node_zonelist/include/linux/vmstat.h linux-2.6.24-rc4-mm1-008_preferred/include/linux/vmstat.h
--- linux-2.6.24-rc4-mm1-007_node_zonelist/include/linux/vmstat.h	2007-12-04 04:26:10.000000000 +0000
+++ linux-2.6.24-rc4-mm1-008_preferred/include/linux/vmstat.h	2007-12-07 13:51:10.000000000 +0000
@@ -174,7 +174,7 @@ static inline unsigned long node_page_st
 		zone_page_state(&zones[ZONE_MOVABLE], item);
 }
 
-extern void zone_statistics(struct zonelist *, struct zone *);
+extern void zone_statistics(struct zone *, struct zone *);
 
 #else
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc4-mm1-007_node_zonelist/mm/page_alloc.c linux-2.6.24-rc4-mm1-008_preferred/mm/page_alloc.c
--- linux-2.6.24-rc4-mm1-007_node_zonelist/mm/page_alloc.c	2007-12-07 13:51:01.000000000 +0000
+++ linux-2.6.24-rc4-mm1-008_preferred/mm/page_alloc.c	2007-12-07 13:51:10.000000000 +0000
@@ -1049,7 +1049,7 @@ void split_page(struct page *page, unsig
  * we cheat by calling it from here, in the order > 0 path.  Saves a branch
  * or two.
  */
-static struct page *buffered_rmqueue(struct zonelist *zonelist,
+static struct page *buffered_rmqueue(struct zone *preferred_zone,
 			struct zone *zone, int order, gfp_t gfp_flags)
 {
 	unsigned long flags;
@@ -1101,7 +1101,7 @@ again:
 	}
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
-	zone_statistics(zonelist, zone);
+	zone_statistics(preferred_zone, zone);
 	local_irq_restore(flags);
 	put_cpu();
 
@@ -1382,7 +1382,7 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	struct zone **z;
 	struct page *page = NULL;
 	int classzone_idx = zone_idx(zonelist->zones[0]);
-	struct zone *zone;
+	struct zone *zone, *preferred_zone;
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
@@ -1394,6 +1394,7 @@ zonelist_scan:
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
 	z = zonelist->zones;
+	preferred_zone = *z;
 
 	do {
 		/*
@@ -1432,7 +1433,7 @@ zonelist_scan:
 			}
 		}
 
-		page = buffered_rmqueue(zonelist, zone, order, gfp_mask);
+		page = buffered_rmqueue(preferred_zone, zone, order, gfp_mask);
 		if (page)
 			break;
 this_zone_full:
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc4-mm1-007_node_zonelist/mm/vmstat.c linux-2.6.24-rc4-mm1-008_preferred/mm/vmstat.c
--- linux-2.6.24-rc4-mm1-007_node_zonelist/mm/vmstat.c	2007-12-07 12:14:07.000000000 +0000
+++ linux-2.6.24-rc4-mm1-008_preferred/mm/vmstat.c	2007-12-07 13:51:10.000000000 +0000
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
