Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8C66B0260
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:36:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n127so8245582wme.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:36:14 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id ie10si3972773wjb.98.2016.07.08.02.36.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 02:36:13 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 9367A1C2231
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 10:36:12 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 05/34] mm, vmscan: begin reclaiming pages on a per-node basis
Date: Fri,  8 Jul 2016 10:34:41 +0100
Message-Id: <1467970510-21195-6-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This patch makes reclaim decisions on a per-node basis.  A reclaimer knows
what zone is required by the allocation request and skips pages from
higher zones.  In many cases this will be ok because it's a GFP_HIGHMEM
request of some description.  On 64-bit, ZONE_DMA32 requests will cause
some problems but 32-bit devices on 64-bit platforms are increasingly
rare.  Historically it would have been a major problem on 32-bit with big
Highmem:Lowmem ratios but such configurations are also now rare and even
where they exist, they are not encouraged.  If it really becomes a
problem, it'll manifest as very low reclaim efficiencies.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---
 mm/vmscan.c | 79 ++++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 55 insertions(+), 24 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 86a523a761c9..766b36bec829 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -84,6 +84,9 @@ struct scan_control {
 	/* Scan (total_size >> priority) pages at once */
 	int priority;
 
+	/* The highest zone to isolate pages for reclaim from */
+	enum zone_type reclaim_idx;
+
 	unsigned int may_writepage:1;
 
 	/* Can mapped pages be reclaimed? */
@@ -1392,6 +1395,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long nr_taken = 0;
 	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
 	unsigned long scan, nr_pages;
+	LIST_HEAD(pages_skipped);
 
 	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
 					!list_empty(src); scan++) {
@@ -1402,6 +1406,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		VM_BUG_ON_PAGE(!PageLRU(page), page);
 
+		if (page_zonenum(page) > sc->reclaim_idx) {
+			list_move(&page->lru, &pages_skipped);
+			continue;
+		}
+
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
 			nr_pages = hpage_nr_pages(page);
@@ -1420,6 +1429,15 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		}
 	}
 
+	/*
+	 * Splice any skipped pages to the start of the LRU list. Note that
+	 * this disrupts the LRU order when reclaiming for lower zones but
+	 * we cannot splice to the tail. If we did then the SWAP_CLUSTER_MAX
+	 * scanning would soon rescan the same pages to skip and put the
+	 * system at risk of premature OOM.
+	 */
+	if (!list_empty(&pages_skipped))
+		list_splice(&pages_skipped, src);
 	*nr_scanned = scan;
 	trace_mm_vmscan_lru_isolate(sc->order, nr_to_scan, scan,
 				    nr_taken, mode, is_file_lru(lru));
@@ -1589,7 +1607,7 @@ static int current_may_throttle(void)
 }
 
 /*
- * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
+ * shrink_inactive_list() is a helper for shrink_node().  It returns the number
  * of reclaimed pages
  */
 static noinline_for_stack unsigned long
@@ -2401,12 +2419,13 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	}
 }
 
-static bool shrink_zone(struct zone *zone, struct scan_control *sc,
-			bool is_classzone)
+static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
+			enum zone_type classzone_idx)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
 	bool reclaimable = false;
+	struct zone *zone = &pgdat->node_zones[classzone_idx];
 
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -2438,7 +2457,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			shrink_zone_memcg(zone, memcg, sc, &lru_pages);
 			zone_lru_pages += lru_pages;
 
-			if (memcg && is_classzone)
+			if (!global_reclaim(sc))
 				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
 					    memcg, sc->nr_scanned - scanned,
 					    lru_pages);
@@ -2469,7 +2488,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 		 * Shrink the slab caches in the same proportion that
 		 * the eligible LRU pages were scanned.
 		 */
-		if (global_reclaim(sc) && is_classzone)
+		if (global_reclaim(sc))
 			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
 				    sc->nr_scanned - nr_scanned,
 				    zone_lru_pages);
@@ -2553,7 +2572,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
 	gfp_t orig_mask;
-	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
+	enum zone_type classzone_idx;
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2561,17 +2580,23 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	 * highmem pages could be pinning lowmem pages storing buffer_heads
 	 */
 	orig_mask = sc->gfp_mask;
-	if (buffer_heads_over_limit)
+	if (buffer_heads_over_limit) {
 		sc->gfp_mask |= __GFP_HIGHMEM;
+		sc->reclaim_idx = classzone_idx = gfp_zone(sc->gfp_mask);
+	}
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-					gfp_zone(sc->gfp_mask), sc->nodemask) {
-		enum zone_type classzone_idx;
-
+					sc->reclaim_idx, sc->nodemask) {
 		if (!populated_zone(zone))
 			continue;
 
-		classzone_idx = requested_highidx;
+		/*
+		 * Note that reclaim_idx does not change as it is the highest
+		 * zone reclaimed from which for empty zones is a no-op but
+		 * classzone_idx is used by shrink_node to test if the slabs
+		 * should be shrunk on a given node.
+		 */
+		classzone_idx = sc->reclaim_idx;
 		while (!populated_zone(zone->zone_pgdat->node_zones +
 							classzone_idx))
 			classzone_idx--;
@@ -2600,8 +2625,8 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			 */
 			if (IS_ENABLED(CONFIG_COMPACTION) &&
 			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&
-			    zonelist_zone_idx(z) <= requested_highidx &&
-			    compaction_ready(zone, sc->order, requested_highidx)) {
+			    zonelist_zone_idx(z) <= classzone_idx &&
+			    compaction_ready(zone, sc->order, classzone_idx)) {
 				sc->compaction_ready = true;
 				continue;
 			}
@@ -2621,7 +2646,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			/* need some check for avoid more shrink_zone() */
 		}
 
-		shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
+		shrink_node(zone->zone_pgdat, sc, classzone_idx);
 	}
 
 	/*
@@ -2847,6 +2872,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	struct scan_control sc = {
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
+		.reclaim_idx = gfp_zone(gfp_mask),
 		.order = order,
 		.nodemask = nodemask,
 		.priority = DEF_PRIORITY,
@@ -2886,6 +2912,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 		.target_mem_cgroup = memcg,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
+		.reclaim_idx = MAX_NR_ZONES - 1,
 		.may_swap = !noswap,
 	};
 	unsigned long lru_pages;
@@ -2924,6 +2951,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
+		.reclaim_idx = MAX_NR_ZONES - 1,
 		.target_mem_cgroup = memcg,
 		.priority = DEF_PRIORITY,
 		.may_writepage = !laptop_mode,
@@ -3118,7 +3146,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
 						balance_gap, classzone_idx))
 		return true;
 
-	shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
+	shrink_node(zone->zone_pgdat, sc, classzone_idx);
 
 	/* TODO: ANOMALY */
 	clear_bit(PGDAT_WRITEBACK, &pgdat->flags);
@@ -3167,6 +3195,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 	unsigned long nr_soft_scanned;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
+		.reclaim_idx = MAX_NR_ZONES - 1,
 		.order = order,
 		.priority = DEF_PRIORITY,
 		.may_writepage = !laptop_mode,
@@ -3237,15 +3266,14 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			sc.may_writepage = 1;
 
 		/*
-		 * Now scan the zone in the dma->highmem direction, stopping
-		 * at the last zone which needs scanning.
-		 *
-		 * We do this because the page allocator works in the opposite
-		 * direction.  This prevents the page allocator from allocating
-		 * pages behind kswapd's direction of progress, which would
-		 * cause too much scanning of the lower zones.
+		 * Continue scanning in the highmem->dma direction stopping at
+		 * the last zone which needs scanning. This may reclaim lowmem
+		 * pages that are not necessary for zone balancing but it
+		 * preserves LRU ordering. It is assumed that the bulk of
+		 * allocation requests can use arbitrary zones with the
+		 * possible exception of big highmem:lowmem configurations.
 		 */
-		for (i = 0; i <= end_zone; i++) {
+		for (i = end_zone; i >= 0; i--) {
 			struct zone *zone = pgdat->node_zones + i;
 
 			if (!populated_zone(zone))
@@ -3256,6 +3284,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 				continue;
 
 			sc.nr_scanned = 0;
+			sc.reclaim_idx = i;
 
 			nr_soft_scanned = 0;
 			/*
@@ -3513,6 +3542,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 	struct scan_control sc = {
 		.nr_to_reclaim = nr_to_reclaim,
 		.gfp_mask = GFP_HIGHUSER_MOVABLE,
+		.reclaim_idx = MAX_NR_ZONES - 1,
 		.priority = DEF_PRIORITY,
 		.may_writepage = 1,
 		.may_unmap = 1,
@@ -3704,6 +3734,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_UNMAP),
 		.may_swap = 1,
+		.reclaim_idx = zone_idx(zone),
 	};
 
 	cond_resched();
@@ -3723,7 +3754,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * priorities until we have enough memory freed.
 		 */
 		do {
-			shrink_zone(zone, &sc, true);
+			shrink_node(zone->zone_pgdat, &sc, zone_idx(zone));
 		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 	}
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
