From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20071109143246.23540.27755.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/6] Use zonelists instead of zones when direct reclaiming pages
Date: Fri,  9 Nov 2007 14:32:46 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Lee.Schermerhorn@hp.com, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, nacc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

The allocator deals with zonelists which indicate the order in which zones
should be targeted for an allocation. Similarly, direct reclaim of pages
iterates over an array of zones. For consistency, this patch converts direct
reclaim to use a zonelist. No functionality is changed by this patch. This
simplifies zonelist iterators in the next patch.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Christoph Lameter <clameter@sgi.com>
---

 include/linux/swap.h |    2 +-
 mm/page_alloc.c      |    2 +-
 mm/vmscan.c          |   21 ++++++++++++---------
 3 files changed, 14 insertions(+), 11 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-b1106/include/linux/swap.h linux-2.6.24-rc1-mm-005_freepages_zonelist/include/linux/swap.h
--- linux-2.6.24-rc1-mm-b1106/include/linux/swap.h	2007-11-08 19:04:09.000000000 +0000
+++ linux-2.6.24-rc1-mm-005_freepages_zonelist/include/linux/swap.h	2007-11-08 19:05:07.000000000 +0000
@@ -181,7 +181,7 @@ extern int rotate_reclaimable_page(struc
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
-extern unsigned long try_to_free_pages(struct zone **zones, int order,
+extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 							gfp_t gfp_mask);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-b1106/mm/page_alloc.c linux-2.6.24-rc1-mm-005_freepages_zonelist/mm/page_alloc.c
--- linux-2.6.24-rc1-mm-b1106/mm/page_alloc.c	2007-11-08 19:04:17.000000000 +0000
+++ linux-2.6.24-rc1-mm-005_freepages_zonelist/mm/page_alloc.c	2007-11-08 19:05:07.000000000 +0000
@@ -1647,7 +1647,7 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist->zones, order, gfp_mask);
+	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
 
 	p->reclaim_state = NULL;
 	p->flags &= ~PF_MEMALLOC;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-b1106/mm/vmscan.c linux-2.6.24-rc1-mm-005_freepages_zonelist/mm/vmscan.c
--- linux-2.6.24-rc1-mm-b1106/mm/vmscan.c	2007-11-08 19:04:17.000000000 +0000
+++ linux-2.6.24-rc1-mm-005_freepages_zonelist/mm/vmscan.c	2007-11-08 19:06:49.000000000 +0000
@@ -1216,10 +1216,11 @@ static unsigned long shrink_zone(int pri
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
 
 	sc->all_unreclaimable = 1;
@@ -1257,8 +1258,8 @@ static unsigned long shrink_zones(int pr
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
@@ -1266,6 +1267,7 @@ static unsigned long do_try_to_free_page
 	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
+	struct zone **zones = zonelist->zones;
 	int i;
 
 	count_vm_event(ALLOCSTALL);
@@ -1285,7 +1287,7 @@ static unsigned long do_try_to_free_page
 		sc->nr_io_pages = 0;
 		if (!priority)
 			disable_swap_token();
-		nr_reclaimed += shrink_zones(priority, zones, sc);
+		nr_reclaimed += shrink_zones(priority, zonelist, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
@@ -1344,7 +1346,8 @@ out:
 	return ret;
 }
 
-unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
+unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
+								gfp_t gfp_mask)
 {
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
@@ -1357,7 +1360,7 @@ unsigned long try_to_free_pages(struct z
 		.isolate_pages = isolate_pages_global,
 	};
 
-	return do_try_to_free_pages(zones, gfp_mask, &sc);
+	return do_try_to_free_pages(zonelist, gfp_mask, &sc);
 }
 
 #ifdef CONFIG_CGROUP_MEM_CONT
@@ -1376,11 +1379,11 @@ unsigned long try_to_free_mem_cgroup_pag
 		.isolate_pages = mem_cgroup_isolate_pages,
 	};
 	int node = numa_node_id();
-	struct zone **zones;
+	struct zonelist *zonelist;
 	int target_zone = gfp_zone(GFP_HIGHUSER_MOVABLE);
 
-	zones = NODE_DATA(node)->node_zonelists[target_zone].zones;
-	if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
+	zonelist = &NODE_DATA(node)->node_zonelists[target_zone];
+	if (do_try_to_free_pages(zonelist, sc.gfp_mask, &sc))
 		return 1;
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
