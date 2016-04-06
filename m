Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id A02936B0260
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:20:43 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id n3so58318460wmn.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:20:43 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id v125si24355617wme.79.2016.04.06.04.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 04:20:40 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 24D3B1C1198
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 12:20:40 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 05/27] mm, vmscan: Begin reclaiming pages on a per-node basis
Date: Wed,  6 Apr 2016 12:20:04 +0100
Message-Id: <1459941626-3290-6-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
References: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This patch makes reclaim decisions on a per-node basis. A reclaimer knows
what zone is required by the allocation request and skips pages from
higher zones. In many cases this will be ok because it's a GFP_HIGHMEM
request of some description. On 64-bit, ZONE_DMA32 requests will cause
some problems but 32-bit devices on 64-bit platforms are increasingly
rare. Historically it would have been a major problem on 32-bit with big
Highmem:Lowmem ratios but such configurations are also now rare and even
where they exist, they are not encouraged. If it really becomes a problem,
it'll manifest as very low reclaim efficiencies.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 77 ++++++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 48 insertions(+), 29 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 75acb89c9df5..0f8dc3488f9d 100644
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
@@ -1369,6 +1372,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	struct list_head *src = &lruvec->lists[lru];
 	unsigned long nr_taken = 0;
 	unsigned long scan;
+	LIST_HEAD(pages_skipped);
 
 	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
 					!list_empty(src); scan++) {
@@ -1380,6 +1384,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		VM_BUG_ON_PAGE(!PageLRU(page), page);
 
+		if (page_zonenum(page) > sc->reclaim_idx) {
+			list_move(&page->lru, &pages_skipped);
+			continue;
+		}
+
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
 			nr_pages = hpage_nr_pages(page);
@@ -1398,6 +1407,15 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
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
@@ -1560,7 +1578,7 @@ static int current_may_throttle(void)
 }
 
 /*
- * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
+ * shrink_inactive_list() is a helper for shrink_node().  It returns the number
  * of reclaimed pages
  */
 static noinline_for_stack unsigned long
@@ -2394,12 +2412,13 @@ static inline bool should_continue_reclaim(struct zone *zone,
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
@@ -2431,7 +2450,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			shrink_zone_memcg(zone, memcg, sc, &lru_pages);
 			zone_lru_pages += lru_pages;
 
-			if (memcg && is_classzone)
+			if (!global_reclaim(sc) && sc->reclaim_idx == classzone_idx)
 				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
 					    memcg, sc->nr_scanned - scanned,
 					    lru_pages);
@@ -2462,7 +2481,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 		 * Shrink the slab caches in the same proportion that
 		 * the eligible LRU pages were scanned.
 		 */
-		if (global_reclaim(sc) && is_classzone)
+		if (global_reclaim(sc) && sc->reclaim_idx == classzone_idx)
 			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
 				    sc->nr_scanned - nr_scanned,
 				    zone_lru_pages);
@@ -2541,14 +2560,14 @@ static inline bool compaction_ready(struct zone *zone, int order)
  *
  * Returns true if a zone was reclaimable.
  */
-static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
+static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
+		enum zone_type classzone_idx)
 {
 	struct zoneref *z;
 	struct zone *zone;
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
 	gfp_t orig_mask;
-	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
 	bool reclaimable = false;
 
 	/*
@@ -2561,16 +2580,12 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		sc->gfp_mask |= __GFP_HIGHMEM;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-					requested_highidx, sc->nodemask) {
-		enum zone_type classzone_idx;
-
-		if (!populated_zone(zone))
-			continue;
-
-		classzone_idx = requested_highidx;
-		while (!populated_zone(zone->zone_pgdat->node_zones +
-							classzone_idx))
+					classzone_idx, sc->nodemask) {
+		if (!populated_zone(zone)) {
+			sc->reclaim_idx--;
 			classzone_idx--;
+			continue;
+		}
 
 		/*
 		 * Take care memory controller reclaiming has small influence
@@ -2596,7 +2611,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			 */
 			if (IS_ENABLED(CONFIG_COMPACTION) &&
 			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&
-			    zonelist_zone_idx(z) <= requested_highidx &&
+			    zonelist_zone_idx(z) <= classzone_idx &&
 			    compaction_ready(zone, sc->order)) {
 				sc->compaction_ready = true;
 				continue;
@@ -2619,7 +2634,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			/* need some check for avoid more shrink_zone() */
 		}
 
-		if (shrink_zone(zone, sc, zone_idx(zone) == classzone_idx))
+		if (shrink_node(zone->zone_pgdat, sc, classzone_idx))
 			reclaimable = true;
 
 		if (global_reclaim(sc) &&
@@ -2659,6 +2674,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	unsigned long total_scanned = 0;
 	unsigned long writeback_threshold;
 	bool zones_reclaimable;
+	enum zone_type classzone_idx = gfp_zone(sc->gfp_mask);
 retry:
 	delayacct_freepages_start();
 
@@ -2669,7 +2685,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
 				sc->priority);
 		sc->nr_scanned = 0;
-		zones_reclaimable = shrink_zones(zonelist, sc);
+		sc->reclaim_idx = classzone_idx;
+		zones_reclaimable = shrink_zones(zonelist, sc, classzone_idx);
 
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
@@ -3128,7 +3145,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
 						balance_gap, classzone_idx))
 		return true;
 
-	shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
+	shrink_node(zone->zone_pgdat, sc, classzone_idx);
 
 	/* TODO: ANOMALY */
 	clear_bit(PGDAT_WRITEBACK, &pgdat->flags);
@@ -3177,6 +3194,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 	unsigned long nr_soft_scanned;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
+		.reclaim_idx = MAX_NR_ZONES - 1,
 		.order = order,
 		.priority = DEF_PRIORITY,
 		.may_writepage = !laptop_mode,
@@ -3247,15 +3265,14 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
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
+		for (i = end_zone; i >= end_zone; i--) {
 			struct zone *zone = pgdat->node_zones + i;
 
 			if (!populated_zone(zone))
@@ -3266,6 +3283,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 				continue;
 
 			sc.nr_scanned = 0;
+			sc.reclaim_idx = i;
 
 			nr_soft_scanned = 0;
 			/*
@@ -3714,6 +3732,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_UNMAP),
 		.may_swap = 1,
+		.reclaim_idx = zone_idx(zone),
 	};
 
 	cond_resched();
@@ -3733,7 +3752,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
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
