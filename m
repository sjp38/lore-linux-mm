From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 27 Feb 2008 16:47:14 -0500
Message-Id: <20080227214714.6858.93635.sendpatchset@localhost>
In-Reply-To: <20080227214708.6858.53458.sendpatchset@localhost>
References: <20080227214708.6858.53458.sendpatchset@localhost>
Subject: [PATCH 1/6] Use zonelists instead of zones when direct reclaiming pages
Sender: owner-linux-mm@kvack.org
From: Mel Gorman <mel@csn.ul.ie>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: mel@csn.ul.ie, ak@suse.de, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 1/6] Use zonelists instead of zones when direct reclaiming pages

V11r3 against 2.6.25-rc2-mm1

The allocator deals with zonelists which indicate the order in which zones
should be targeted for an allocation. Similarly, direct reclaim of pages
iterates over an array of zones. For consistency, this patch converts direct
reclaim to use a zonelist. No functionality is changed by this patch. This
simplifies zonelist iterators in the next patch.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Christoph Lameter <clameter@sgi.com>
Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 fs/buffer.c          |    8 ++++----
 include/linux/swap.h |    2 +-
 mm/page_alloc.c      |    2 +-
 mm/vmscan.c          |   21 ++++++++++++---------
 4 files changed, 18 insertions(+), 15 deletions(-)

Index: linux-2.6.25-rc2-mm1/fs/buffer.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/fs/buffer.c	2008-02-27 16:28:07.000000000 -0500
+++ linux-2.6.25-rc2-mm1/fs/buffer.c	2008-02-27 16:28:09.000000000 -0500
@@ -368,16 +368,16 @@ void invalidate_bdev(struct block_device
  */
 static void free_more_memory(void)
 {
-	struct zone **zones;
+	struct zonelist *zonelist;
 	pg_data_t *pgdat;
 
 	wakeup_pdflush(1024);
 	yield();
 
 	for_each_online_pgdat(pgdat) {
-		zones = pgdat->node_zonelists[gfp_zone(GFP_NOFS)].zones;
-		if (*zones)
-			try_to_free_pages(zones, 0, GFP_NOFS);
+		zonelist = &pgdat->node_zonelists[gfp_zone(GFP_NOFS)];
+		if (zonelist->zones[0])
+			try_to_free_pages(zonelist, 0, GFP_NOFS);
 	}
 }
 
Index: linux-2.6.25-rc2-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.25-rc2-mm1.orig/include/linux/swap.h	2008-02-27 16:28:07.000000000 -0500
+++ linux-2.6.25-rc2-mm1/include/linux/swap.h	2008-02-27 16:28:09.000000000 -0500
@@ -181,7 +181,7 @@ extern int rotate_reclaimable_page(struc
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
-extern unsigned long try_to_free_pages(struct zone **zones, int order,
+extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 							gfp_t gfp_mask);
Index: linux-2.6.25-rc2-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/page_alloc.c	2008-02-27 16:28:07.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/page_alloc.c	2008-02-27 16:28:09.000000000 -0500
@@ -1635,7 +1635,7 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist->zones, order, gfp_mask);
+	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
 
 	p->reclaim_state = NULL;
 	p->flags &= ~PF_MEMALLOC;
Index: linux-2.6.25-rc2-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/vmscan.c	2008-02-27 16:28:07.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/vmscan.c	2008-02-27 16:28:09.000000000 -0500
@@ -1268,10 +1268,11 @@ static unsigned long shrink_zone(int pri
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  */
-static unsigned long shrink_zones(int priority, struct zone **zones,
+static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
 {
 	unsigned long nr_reclaimed = 0;
+	struct zone **zones = zonelist->zones;
 	int i;
 
 
@@ -1323,8 +1324,8 @@ static unsigned long shrink_zones(int pr
  * holds filesystem locks which prevent writeout this might not work, and the
  * allocation attempt will fail.
  */
-static unsigned long do_try_to_free_pages(struct zone **zones, gfp_t gfp_mask,
-					  struct scan_control *sc)
+static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
+					gfp_t gfp_mask, struct scan_control *sc)
 {
 	int priority;
 	int ret = 0;
@@ -1332,6 +1333,7 @@ static unsigned long do_try_to_free_page
 	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
+	struct zone **zones = zonelist->zones;
 	int i;
 
 	if (scan_global_lru(sc))
@@ -1356,7 +1358,7 @@ static unsigned long do_try_to_free_page
 		sc->nr_io_pages = 0;
 		if (!priority)
 			disable_swap_token();
-		nr_reclaimed += shrink_zones(priority, zones, sc);
+		nr_reclaimed += shrink_zones(priority, zonelist, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
@@ -1421,7 +1423,8 @@ out:
 	return ret;
 }
 
-unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
+unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
+								gfp_t gfp_mask)
 {
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
@@ -1434,7 +1437,7 @@ unsigned long try_to_free_pages(struct z
 		.isolate_pages = isolate_pages_global,
 	};
 
-	return do_try_to_free_pages(zones, gfp_mask, &sc);
+	return do_try_to_free_pages(zonelist, gfp_mask, &sc);
 }
 
 #ifdef CONFIG_CGROUP_MEM_CONT
@@ -1452,11 +1455,11 @@ unsigned long try_to_free_mem_cgroup_pag
 		.mem_cgroup = mem_cont,
 		.isolate_pages = mem_cgroup_isolate_pages,
 	};
-	struct zone **zones;
+	struct zonelist *zonelist;
 	int target_zone = gfp_zone(GFP_HIGHUSER_MOVABLE);
 
-	zones = NODE_DATA(numa_node_id())->node_zonelists[target_zone].zones;
-	if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
+	zonelist = &NODE_DATA(numa_node_id())->node_zonelists[target_zone];
+	if (do_try_to_free_pages(zonelist, sc.gfp_mask, &sc))
 		return 1;
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
