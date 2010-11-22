Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5061E6B0093
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 10:44:04 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/7] mm: vmscan: Reclaim order-0 and use compaction instead of lumpy reclaim
Date: Mon, 22 Nov 2010 15:43:51 +0000
Message-Id: <1290440635-30071-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1290440635-30071-1-git-send-email-mel@csn.ul.ie>
References: <1290440635-30071-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Lumpy reclaim is disruptive. It reclaims a large number of pages and ignores
the age of the pages it reclaims. This can incur significant stalls and
potentially increase the number of major faults.

Compaction has reached the point where it is considered reasonably stable
(meaning it has passed a lot of testing) and is a potential candidate for
displacing lumpy reclaim. This patch introduces an alternative to lumpy
reclaim whe compaction is available called reclaim/compaction. The basic
operation is very simple - instead of selecting a contiguous range of pages
to reclaim, a number of order-0 pages are reclaimed and then compaction is
later by either kswapd (compact_zone_order()) or direct compaction
(__alloc_pages_direct_compact()).

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/compaction.h |   14 ++++++
 include/linux/kernel.h     |    7 +++
 mm/compaction.c            |   89 +++++++++++++++++++++++--------------
 mm/page_alloc.c            |   13 ++++++
 mm/vmscan.c                |  103 +++++++++++++++++++++++++++++++++++++------
 5 files changed, 177 insertions(+), 49 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 5ac5155..e082cf9 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -22,6 +22,9 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask);
+extern unsigned long compaction_suitable(struct zone *zone, int order);
+extern unsigned long compact_zone_order(struct zone *zone, int order,
+						gfp_t gfp_mask);
 
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_DEFER_SHIFT 6
@@ -59,6 +62,17 @@ static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	return COMPACT_CONTINUE;
 }
 
+static inline unsigned long compaction_suitable(struct zone *zone, int order)
+{
+	return COMPACT_SKIPPED;
+}
+
+extern unsigned long compact_zone_order(struct zone *zone, int order,
+						gfp_t gfp_mask)
+{
+	return 0;
+}
+
 static inline void defer_compaction(struct zone *zone)
 {
 }
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index b6de9a6..7ee8a21 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -584,6 +584,13 @@ struct sysinfo {
 #define NUMA_BUILD 0
 #endif
 
+/* This helps us avoid #ifdef CONFIG_COMPACTION */
+#ifdef CONFIG_COMPACTION
+#define COMPACTION_BUILD 1
+#else
+#define COMPACTION_BUILD 0
+#endif
+
 /* Rebuild everything on CONFIG_FTRACE_MCOUNT_RECORD */
 #ifdef CONFIG_FTRACE_MCOUNT_RECORD
 # define REBUILD_DUE_TO_FTRACE_MCOUNT_RECORD
diff --git a/mm/compaction.c b/mm/compaction.c
index bc8eb8a..384fa71 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -385,10 +385,62 @@ static int compact_finished(struct zone *zone,
 	return COMPACT_CONTINUE;
 }
 
+/*
+ * compaction_suitable: Is this suitable to run compaction on this zone now?
+ * Returns
+ *   COMPACT_SKIPPED  - If there are too few free pages for compaction
+ *   COMPACT_PARTIAL  - If the allocation would succeed without compaction
+ *   COMPACT_CONTINUE - If compaction should run now
+ */
+unsigned long compaction_suitable(struct zone *zone, int order)
+{
+	int fragindex;
+	unsigned long watermark;
+
+	/*
+	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
+	 * This is because during migration, copies of pages need to be
+	 * allocated and for a short time, the footprint is higher
+	 */
+	watermark = low_wmark_pages(zone) + (2UL << order);
+	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+		return COMPACT_SKIPPED;
+
+	/*
+	 * fragmentation index determines if allocation failures are due to
+	 * low memory or external fragmentation
+	 *
+	 * index of -1 implies allocations might succeed dependingon watermarks
+	 * index towards 0 implies failure is due to lack of memory
+	 * index towards 1000 implies failure is due to fragmentation
+	 *
+	 * Only compact if a failure would be due to fragmentation.
+	 */
+	fragindex = fragmentation_index(zone, order);
+	if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
+		return COMPACT_SKIPPED;
+
+	if (fragindex == -1 && zone_watermark_ok(zone, order, watermark, 0, 0))
+		return COMPACT_PARTIAL;
+
+	return COMPACT_CONTINUE;
+}
+
 static int compact_zone(struct zone *zone, struct compact_control *cc)
 {
 	int ret;
 
+	ret = compaction_suitable(zone, cc->order);
+	switch (ret) {
+	case COMPACT_PARTIAL:
+	case COMPACT_SKIPPED:
+		/* Compaction is likely to fail */
+		return ret;
+	case COMPACT_CONTINUE:
+		/* Fall through to compaction */
+		;
+	}
+
 	/* Setup to move all movable pages to the end of the zone */
 	cc->migrate_pfn = zone->zone_start_pfn;
 	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
@@ -430,7 +482,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	return ret;
 }
 
-static unsigned long compact_zone_order(struct zone *zone,
+unsigned long compact_zone_order(struct zone *zone,
 						int order, gfp_t gfp_mask)
 {
 	struct compact_control cc = {
@@ -463,7 +515,6 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
 	int may_perform_io = gfp_mask & __GFP_IO;
-	unsigned long watermark;
 	struct zoneref *z;
 	struct zone *zone;
 	int rc = COMPACT_SKIPPED;
@@ -481,43 +532,13 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	/* Compact each zone in the list */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
 								nodemask) {
-		int fragindex;
 		int status;
 
-		/*
-		 * Watermarks for order-0 must be met for compaction. Note
-		 * the 2UL. This is because during migration, copies of
-		 * pages need to be allocated and for a short time, the
-		 * footprint is higher
-		 */
-		watermark = low_wmark_pages(zone) + (2UL << order);
-		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
-			continue;
-
-		/*
-		 * fragmentation index determines if allocation failures are
-		 * due to low memory or external fragmentation
-		 *
-		 * index of -1 implies allocations might succeed depending
-		 * 	on watermarks
-		 * index towards 0 implies failure is due to lack of memory
-		 * index towards 1000 implies failure is due to fragmentation
-		 *
-		 * Only compact if a failure would be due to fragmentation.
-		 */
-		fragindex = fragmentation_index(zone, order);
-		if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
-			continue;
-
-		if (fragindex == -1 && zone_watermark_ok(zone, order, watermark, 0, 0)) {
-			rc = COMPACT_PARTIAL;
-			break;
-		}
-
 		status = compact_zone_order(zone, order, gfp_mask);
 		rc = max(status, rc);
 
-		if (zone_watermark_ok(zone, order, watermark, 0, 0))
+		/* If a normal allocation would succeed, stop compacting */
+		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
 			break;
 	}
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 07a6544..2c88655 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2097,6 +2097,19 @@ rebalance:
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto rebalance;
+	} else {
+		/*
+		 * High-order allocations do not necessarily loop after
+		 * direct reclaim and reclaim/compaction depends on compaction
+		 * being called after reclaim so call directly if necessary
+		 */
+		page = __alloc_pages_direct_compact(gfp_mask, order,
+					zonelist, high_zoneidx,
+					nodemask,
+					alloc_flags, preferred_zone,
+					migratetype, &did_some_progress);
+		if (page)
+			goto got_pg;
 	}
 
 nopage:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e5eda92..3fb7a76 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -32,6 +32,7 @@
 #include <linux/topology.h>
 #include <linux/cpu.h>
 #include <linux/cpuset.h>
+#include <linux/compaction.h>
 #include <linux/notifier.h>
 #include <linux/rwsem.h>
 #include <linux/delay.h>
@@ -59,12 +60,15 @@
  * LUMPY_MODE_CONTIGRECLAIM: For high-order allocations, take a reference
  *			page from the LRU and reclaim all pages within a
  *			naturally aligned range
+ * LUMPY_MODE_COMPACTION: For high-order allocations, reclaim a number of
+ *			order-0 pages and then compact the zone
  */
 typedef unsigned __bitwise__ lumpy_mode;
 #define LUMPY_MODE_SINGLE		((__force lumpy_mode)0x01u)
 #define LUMPY_MODE_ASYNC		((__force lumpy_mode)0x02u)
 #define LUMPY_MODE_SYNC			((__force lumpy_mode)0x04u)
 #define LUMPY_MODE_CONTIGRECLAIM	((__force lumpy_mode)0x08u)
+#define LUMPY_MODE_COMPACTION		((__force lumpy_mode)0x10u)
 
 struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
@@ -286,18 +290,20 @@ static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
 	lumpy_mode syncmode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
 
 	/*
-	 * Some reclaim have alredy been failed. No worth to try synchronous
-	 * lumpy reclaim.
+	 * Initially assume we are entering either lumpy reclaim or
+	 * reclaim/compaction.Depending on the order, we will either set the
+	 * sync mode or just reclaim order-0 pages later.
 	 */
-	if (sync && sc->lumpy_reclaim_mode & LUMPY_MODE_SINGLE)
-		return;
+	if (COMPACTION_BUILD)
+		sc->lumpy_reclaim_mode = LUMPY_MODE_COMPACTION;
+	else
+		sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;
 
 	/*
-	 * If we need a large contiguous chunk of memory, or have
-	 * trouble getting a small set of contiguous pages, we
-	 * will reclaim both active and inactive pages.
+	 * Avoid using lumpy reclaim or reclaim/compaction if possible by
+	 * restricting when its set to either costly allocations or when
+	 * under memory pressure
 	 */
-	sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;
 	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
 		sc->lumpy_reclaim_mode |= syncmode;
 	else if (sc->order && priority < DEF_PRIORITY - 2)
@@ -1378,8 +1384,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	if (scanning_global_lru(sc)) {
 		nr_taken = isolate_pages_global(nr_to_scan,
 			&page_list, &nr_scanned, sc->order,
-			sc->lumpy_reclaim_mode & LUMPY_MODE_SINGLE ?
-					ISOLATE_INACTIVE : ISOLATE_BOTH,
+			sc->lumpy_reclaim_mode & LUMPY_MODE_CONTIGRECLAIM ?
+					ISOLATE_BOTH : ISOLATE_INACTIVE,
 			zone, 0, file);
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
@@ -1391,8 +1397,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	} else {
 		nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
 			&page_list, &nr_scanned, sc->order,
-			sc->lumpy_reclaim_mode & LUMPY_MODE_SINGLE ?
-					ISOLATE_INACTIVE : ISOLATE_BOTH,
+			sc->lumpy_reclaim_mode & LUMPY_MODE_CONTIGRECLAIM ?
+					ISOLATE_BOTH : ISOLATE_INACTIVE,
 			zone, sc->mem_cgroup,
 			0, file);
 		/*
@@ -1808,6 +1814,57 @@ out:
 }
 
 /*
+ * Reclaim/compaction depends on a number of pages being freed. To avoid
+ * disruption to the system, a small number of order-0 pages continue to be
+ * rotated and reclaimed in the normal fashion. However, by the time we get
+ * back to the allocator and call try_to_compact_zone(), we ensure that
+ * there are enough free pages for it to be likely successful
+ */
+static inline bool should_continue_reclaim(struct zone *zone,
+					unsigned long nr_reclaimed,
+					unsigned long nr_scanned,
+					struct scan_control *sc)
+{
+	unsigned long pages_for_compaction;
+	unsigned long inactive_lru_pages;
+
+	/* If not in reclaim/compaction mode, stop */
+	if (!(sc->lumpy_reclaim_mode & LUMPY_MODE_COMPACTION))
+		return false;
+
+	/*
+	 * If we failed to reclaim and have scanned the full list, stop.
+	 * NOTE: Checking just nr_reclaimed would exit reclaim/compaction far
+	 *       faster but obviously would be less likely to succeed
+	 *       allocation. If this is desirable, use GFP_REPEAT to decide
+	 *       if both reclaimed and scanned should be checked or just
+	 *       reclaimed
+	 */
+	if (!nr_reclaimed && !nr_scanned)
+		return false;
+
+	/*
+	 * If we have not reclaimed enough pages for compaction and the
+	 * inactive lists are large enough, continue reclaiming
+	 */
+	pages_for_compaction = (2UL << sc->order);
+	inactive_lru_pages = zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON) +
+				zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
+	if (sc->nr_reclaimed < pages_for_compaction &&
+			inactive_lru_pages > pages_for_compaction)
+		return true;
+
+	/* If compaction would go ahead or the allocation would succeed, stop */
+	switch (compaction_suitable(zone, sc->order)) {
+	case COMPACT_PARTIAL:
+	case COMPACT_CONTINUE:
+		return false;
+	default:
+		return true;
+	}
+}
+
+/*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static void shrink_zone(int priority, struct zone *zone,
@@ -1816,9 +1873,12 @@ static void shrink_zone(int priority, struct zone *zone,
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
 	enum lru_list l;
-	unsigned long nr_reclaimed = sc->nr_reclaimed;
+	unsigned long nr_reclaimed;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
+	unsigned long nr_scanned = sc->nr_scanned;
 
+restart:
+	nr_reclaimed = 0;
 	get_scan_count(zone, sc, nr, priority);
 
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
@@ -1844,8 +1904,7 @@ static void shrink_zone(int priority, struct zone *zone,
 		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
 			break;
 	}
-
-	sc->nr_reclaimed = nr_reclaimed;
+	sc->nr_reclaimed += nr_reclaimed;
 
 	/*
 	 * Even if we did not try to evict anon pages at all, we want to
@@ -1854,6 +1913,11 @@ static void shrink_zone(int priority, struct zone *zone,
 	if (inactive_anon_is_low(zone, sc))
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
+	/* reclaim/compaction might need reclaim to continue */
+	if (should_continue_reclaim(zone, nr_reclaimed,
+					sc->nr_scanned - nr_scanned, sc))
+		goto restart;
+
 	throttle_vm_writeout(sc->gfp_mask);
 }
 
@@ -2300,6 +2364,15 @@ loop_again:
 			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
 				sc.may_writepage = 1;
 
+			/*
+			 * Compact the zone for higher orders to reduce
+			 * latencies for higher-order allocations that
+			 * would ordinarily call try_to_compact_pages()
+			 */
+			if (sc.order > PAGE_ALLOC_COSTLY_ORDER)
+				compact_zone_order(zone, sc.order,
+						sc.gfp_mask);
+
 			if (!zone_watermark_ok(zone, order,
 					high_wmark_pages(zone), end_zone, 0)) {
 				all_zones_ok = 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
