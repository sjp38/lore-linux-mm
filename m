Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 03DF86B0071
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:56:47 -0400 (EDT)
Received: by wgme6 with SMTP id e6so104058161wgm.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:56:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fa2si1346495wib.27.2015.06.08.06.56.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:45 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/25] mm, vmscan: Begin reclaiming pages on a per-node basis
Date: Mon,  8 Jun 2015 14:56:10 +0100
Message-Id: <1433771791-30567-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch makes reclaim decisions on a per-node basis. A reclaimer knows
what zone is required by the allocation request and skips unrelated pages. In
many cases this will be ok because it's a GFP_HIGHMEM request of some
description. On 64-bit, ZONE_DMA32 requests will cause some problems but
32-bit devices on 64-bit platforms are getting more rare. Historically it
would have been a major problem on 32-bit with big Highmem:Lowmem ratios
but that is also becoming very rare. If it really becomes a problem,
it'll manifest as very low reclaim efficiencies.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 75 ++++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 45 insertions(+), 30 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a11d7d6d2070..acdded211bd8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -83,6 +83,9 @@ struct scan_control {
 	/* Scan (total_size >> priority) pages at once */
 	int priority;
 
+	/* The highest zone to isolate pages for reclaim from */
+	enum zone_type reclaim_idx;
+
 	unsigned int may_writepage:1;
 
 	/* Can mapped pages be reclaimed? */
@@ -1319,6 +1322,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	struct list_head *src = &lruvec->lists[lru];
 	unsigned long nr_taken = 0;
 	unsigned long scan;
+	LIST_HEAD(pages_skipped);
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
@@ -1329,6 +1333,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		VM_BUG_ON_PAGE(!PageLRU(page), page);
 
+		if (page_zone_id(page) > sc->reclaim_idx)
+			list_move(&page->lru, &pages_skipped);
+
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
 			nr_pages = hpage_nr_pages(page);
@@ -1347,6 +1354,15 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
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
@@ -1508,7 +1524,7 @@ static int current_may_throttle(void)
 }
 
 /*
- * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
+ * shrink_inactive_list() is a helper for shrink_node().  It returns the number
  * of reclaimed pages
  */
 static noinline_for_stack unsigned long
@@ -2319,12 +2335,14 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	}
 }
 
-static bool shrink_zone(struct zone *zone, struct scan_control *sc,
-			bool is_classzone)
+static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
+			enum zone_type reclaim_idx,
+			enum zone_type classzone_idx)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
 	bool reclaimable = false;
+	struct zone *zone = &pgdat->node_zones[classzone_idx];
 
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -2355,10 +2373,11 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			swappiness = mem_cgroup_swappiness(memcg);
 			scanned = sc->nr_scanned;
 
+			sc->reclaim_idx = reclaim_idx;
 			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
 			zone_lru_pages += lru_pages;
 
-			if (memcg && is_classzone)
+			if (!global_reclaim(sc) && reclaim_idx == classzone_idx)
 				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
 					    memcg, sc->nr_scanned - scanned,
 					    lru_pages);
@@ -2384,7 +2403,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 		 * Shrink the slab caches in the same proportion that
 		 * the eligible LRU pages were scanned.
 		 */
-		if (global_reclaim(sc) && is_classzone)
+		if (global_reclaim(sc) && reclaim_idx == classzone_idx)
 			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
 				    sc->nr_scanned - nr_scanned,
 				    zone_lru_pages);
@@ -2462,14 +2481,14 @@ static inline bool compaction_ready(struct zone *zone, int order)
  *
  * Returns true if a zone was reclaimable.
  */
-static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
+static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
+		enum zone_type reclaim_idx, enum zone_type classzone_idx)
 {
 	struct zoneref *z;
 	struct zone *zone;
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
 	gfp_t orig_mask;
-	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
 	bool reclaimable = false;
 
 	/*
@@ -2482,16 +2501,12 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
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
+			reclaim_idx--;
 			classzone_idx--;
+			continue;
+		}
 
 		/*
 		 * Take care memory controller reclaiming has small influence
@@ -2517,7 +2532,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			 */
 			if (IS_ENABLED(CONFIG_COMPACTION) &&
 			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&
-			    zonelist_zone_idx(z) <= requested_highidx &&
+			    zonelist_zone_idx(z) <= classzone_idx &&
 			    compaction_ready(zone, sc->order)) {
 				sc->compaction_ready = true;
 				continue;
@@ -2537,10 +2552,10 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			sc->nr_scanned += nr_soft_scanned;
 			if (nr_soft_reclaimed)
 				reclaimable = true;
-			/* need some check for avoid more shrink_zone() */
+			/* need some check for avoid more shrink_node() */
 		}
 
-		if (shrink_zone(zone, sc, zone_idx(zone) == classzone_idx))
+		if (shrink_node(zone->zone_pgdat, sc, reclaim_idx, classzone_idx))
 			reclaimable = true;
 
 		if (global_reclaim(sc) &&
@@ -2580,6 +2595,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	unsigned long total_scanned = 0;
 	unsigned long writeback_threshold;
 	bool zones_reclaimable;
+	enum zone_type classzone_idx = gfp_zone(sc->gfp_mask);
 retry:
 	delayacct_freepages_start();
 
@@ -2590,7 +2606,7 @@ retry:
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
 				sc->priority);
 		sc->nr_scanned = 0;
-		zones_reclaimable = shrink_zones(zonelist, sc);
+		zones_reclaimable = shrink_zones(zonelist, sc, classzone_idx, classzone_idx);
 
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
@@ -3058,7 +3074,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
 						balance_gap, classzone_idx))
 		return true;
 
-	shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
+	shrink_node(zone->zone_pgdat, sc, zone_idx(zone), classzone_idx);
 
 	/* Account for the number of pages attempted to reclaim */
 	*nr_attempted += sc->nr_to_reclaim;
@@ -3201,15 +3217,14 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
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
@@ -3707,7 +3722,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * priorities until we have enough memory freed.
 		 */
 		do {
-			shrink_zone(zone, &sc, true);
+			shrink_node(zone->zone_pgdat, &sc, zone_idx(zone), zone_idx(zone));
 		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 	}
 
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
