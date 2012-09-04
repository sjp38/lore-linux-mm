Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id C9AB56B006E
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 09:26:57 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M9T00IMTUOEUBH0@mailout1.samsung.com> for
 linux-mm@kvack.org; Tue, 04 Sep 2012 22:26:56 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M9T000YZUO4IJ50@mmp2.samsung.com> for linux-mm@kvack.org;
 Tue, 04 Sep 2012 22:26:56 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v3 5/5] cma: fix watermark checking
Date: Tue, 04 Sep 2012 15:26:25 +0200
Message-id: <1346765185-30977-6-git-send-email-b.zolnierkie@samsung.com>
In-reply-to: <1346765185-30977-1-git-send-email-b.zolnierkie@samsung.com>
References: <1346765185-30977-1-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Pass GFP flags to [__]zone_watermark_ok() and use them to account
free CMA pages only when necessary (there is no need to check
watermark against only non-CMA free pages for movable allocations).

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/mmzone.h |  2 +-
 mm/compaction.c        | 11 ++++++-----
 mm/page_alloc.c        | 29 +++++++++++++++++++----------
 mm/vmscan.c            |  4 ++--
 4 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 904889d..308bb91 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -725,7 +725,7 @@ extern struct mutex zonelists_mutex;
 void build_all_zonelists(pg_data_t *pgdat, struct zone *zone);
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
 bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
-		int classzone_idx, int alloc_flags);
+		int classzone_idx, int alloc_flags, gfp_t gfp_flags);
 bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
 		int classzone_idx, int alloc_flags);
 enum memmap_context {
diff --git a/mm/compaction.c b/mm/compaction.c
index 4b902aa..080175a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -684,7 +684,7 @@ static int compact_finished(struct zone *zone,
 	watermark = low_wmark_pages(zone);
 	watermark += (1 << cc->order);
 
-	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
+	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0, 0))
 		return COMPACT_CONTINUE;
 
 	/* Direct compactor: Is a suitable page free? */
@@ -726,7 +726,7 @@ unsigned long compaction_suitable(struct zone *zone, int order)
 	 * allocated and for a short time, the footprint is higher
 	 */
 	watermark = low_wmark_pages(zone) + (2UL << order);
-	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+	if (!zone_watermark_ok(zone, 0, watermark, 0, 0, 0))
 		return COMPACT_SKIPPED;
 
 	/*
@@ -745,7 +745,7 @@ unsigned long compaction_suitable(struct zone *zone, int order)
 		return COMPACT_SKIPPED;
 
 	if (fragindex == -1000 && zone_watermark_ok(zone, order, watermark,
-	    0, 0))
+	    0, 0, 0))
 		return COMPACT_PARTIAL;
 
 	return COMPACT_CONTINUE;
@@ -889,7 +889,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 		rc = max(status, rc);
 
 		/* If a normal allocation would succeed, stop compacting */
-		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
+		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0,
+				      gfp_mask))
 			break;
 	}
 
@@ -920,7 +921,7 @@ static int __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 
 		if (cc->order > 0) {
 			int ok = zone_watermark_ok(zone, cc->order,
-						low_wmark_pages(zone), 0, 0);
+						low_wmark_pages(zone), 0, 0, 0);
 			if (ok && cc->order >= zone->compact_order_failed)
 				zone->compact_order_failed = cc->order + 1;
 			/* Currently async compaction is never deferred. */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2166774..5912a8c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1423,7 +1423,7 @@ int split_free_page(struct page *page, bool check_wmark)
 	if (check_wmark) {
 		/* Obey watermarks as if the page was being allocated */
 		watermark = low_wmark_pages(zone) + (1 << order);
-		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+		if (!zone_watermark_ok(zone, 0, watermark, 0, 0, 0))
 			return 0;
 	}
 
@@ -1628,12 +1628,13 @@ static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
  * of the allocation.
  */
 static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
-		      int classzone_idx, int alloc_flags, long free_pages, long free_cma_pages)
+		      int classzone_idx, int alloc_flags, long free_pages,
+		      long free_cma_pages, gfp_t gfp_flags)
 {
 	/* free_pages my go negative - that's OK */
 	long min = mark;
 	long lowmem_reserve = z->lowmem_reserve[classzone_idx];
-	int o;
+	int mt, o;
 
 	free_pages -= (1 << order) - 1;
 	if (alloc_flags & ALLOC_HIGH)
@@ -1641,8 +1642,14 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
 
-	if (free_pages - free_cma_pages <= min + lowmem_reserve)
-		return false;
+	mt = allocflags_to_migratetype(gfp_flags);
+	if (mt == MIGRATE_MOVABLE) {
+		if (free_pages <= min + lowmem_reserve)
+			return false;
+	} else {
+		if (free_pages - free_cma_pages <= min + lowmem_reserve)
+			return false;
+	}
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
 		free_pages -= z->free_area[o].nr_free << o;
@@ -1671,11 +1678,12 @@ static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
 #endif
 
 bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
-		      int classzone_idx, int alloc_flags)
+		      int classzone_idx, int alloc_flags, gfp_t gfp_flags)
 {
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
 					zone_page_state(z, NR_FREE_PAGES),
-					zone_page_state(z, NR_FREE_CMA_PAGES));
+					zone_page_state(z, NR_FREE_CMA_PAGES),
+					gfp_flags);
 }
 
 bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
@@ -1696,7 +1704,7 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
 	 */
 	free_pages -= nr_zone_isolate_freepages(z);
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
-					free_pages, free_cma_pages);
+					free_pages, free_cma_pages, 0);
 }
 
 #ifdef CONFIG_NUMA
@@ -1906,7 +1914,7 @@ zonelist_scan:
 
 			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 			if (zone_watermark_ok(zone, order, mark,
-				    classzone_idx, alloc_flags))
+				    classzone_idx, alloc_flags, gfp_mask))
 				goto try_this_zone;
 
 			if (NUMA_BUILD && !did_zlc_setup && nr_online_nodes > 1) {
@@ -1942,7 +1950,8 @@ zonelist_scan:
 			default:
 				/* did we reclaim enough */
 				if (!zone_watermark_ok(zone, order, mark,
-						classzone_idx, alloc_flags))
+						classzone_idx, alloc_flags,
+						gfp_mask))
 					goto this_zone_full;
 			}
 		}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8d01243..4a10038b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2777,14 +2777,14 @@ out:
 
 			/* Confirm the zone is balanced for order-0 */
 			if (!zone_watermark_ok(zone, 0,
-					high_wmark_pages(zone), 0, 0)) {
+					high_wmark_pages(zone), 0, 0, 0)) {
 				order = sc.order = 0;
 				goto loop_again;
 			}
 
 			/* Check if the memory needs to be defragmented. */
 			if (zone_watermark_ok(zone, order,
-				    low_wmark_pages(zone), *classzone_idx, 0))
+				    low_wmark_pages(zone), *classzone_idx, 0, 0))
 				zones_need_compaction = 0;
 
 			/* If balanced, clear the congested flag */
-- 
1.7.11.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
