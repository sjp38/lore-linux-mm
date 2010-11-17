Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 918186B0112
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 11:25:28 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/8] mm: vmscan: Reclaim order-0 and use compaction instead of lumpy reclaim
Date: Wed, 17 Nov 2010 16:22:44 +0000
Message-Id: <1290010969-26721-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Lumpy reclaim is disruptive. It reclaims a large number of pages and ignores
the age of the pages it reclaims. This can incur significant stalls and
potentially increase the number of major faults.

Compaction has reached the point where it is considered reasonably stable
(meaning it has passed a lot of testing) and is a potential candidate for
displacing lumpy reclaim. This patch uses memory compaction where available
and lumpy reclaim otherwise. The basic operation is very simple - instead
of selecting a contiguous range of pages to reclaim, a number of order-0
pages are reclaimed and then compaction is called for the zone.  If the
watermarks are not met, another reclaim+compaction cycle occurs.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/compaction.h |    9 ++++-
 include/linux/kernel.h     |    7 +++
 mm/compaction.c            |   96 +++++++++++++++++++++++++++++---------------
 mm/vmscan.c                |   40 +++++++++++++-----
 4 files changed, 106 insertions(+), 46 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 5ac5155..9ebbc12 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -22,7 +22,8 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask);
-
+extern unsigned long reclaimcompact_zone_order(struct zone *zone,
+			int order, gfp_t gfp_mask);
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_DEFER_SHIFT 6
 
@@ -59,6 +60,12 @@ static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	return COMPACT_CONTINUE;
 }
 
+static inline unsigned long reclaimcompact_zone_order(struct zone *zone,
+			int order, gfp_t gfp_mask)
+{
+	return 0;
+}
+
 static inline void defer_compaction(struct zone *zone)
 {
 }
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 450092c..c00c5d1 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -826,6 +826,13 @@ struct sysinfo {
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
index bc8eb8a..3c37c52 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -385,10 +385,55 @@ static int compact_finished(struct zone *zone,
 	return COMPACT_CONTINUE;
 }
 
+static unsigned long compaction_suitable(struct zone *zone, int order)
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
@@ -446,6 +491,22 @@ static unsigned long compact_zone_order(struct zone *zone,
 	return compact_zone(zone, &cc);
 }
 
+unsigned long reclaimcompact_zone_order(struct zone *zone,
+						int order, gfp_t gfp_mask)
+{
+	struct compact_control cc = {
+		.nr_freepages = 0,
+		.nr_migratepages = 0,
+		.order = order,
+		.migratetype = allocflags_to_migratetype(gfp_mask),
+		.zone = zone,
+	};
+	INIT_LIST_HEAD(&cc.freepages);
+	INIT_LIST_HEAD(&cc.migratepages);
+
+	return compact_zone(zone, &cc);
+}
+
 int sysctl_extfrag_threshold = 500;
 
 /**
@@ -463,7 +524,6 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
 	int may_perform_io = gfp_mask & __GFP_IO;
-	unsigned long watermark;
 	struct zoneref *z;
 	struct zone *zone;
 	int rc = COMPACT_SKIPPED;
@@ -481,43 +541,13 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
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
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 37d4f0e..ca108ce 100644
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
@@ -283,25 +287,27 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
 				   bool sync)
 {
-	lumpy_mode mode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
+	lumpy_mode syncmode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
 
 	/*
-	 * Some reclaim have alredy been failed. No worth to try synchronous
-	 * lumpy reclaim.
+	 * Initially assume we are entering either lumpy reclaim or lumpy
+	 * compaction. Depending on the order, we will either set the sync
+	 * mode or just reclaim order-0 pages later.
 	 */
-	if (sync && sc->lumpy_reclaim_mode & LUMPY_MODE_SINGLE)
-		return;
+	if (COMPACTION_BUILD)
+		sc->lumpy_reclaim_mode = LUMPY_MODE_COMPACTION;
+	else
+		sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;
 
 	/*
 	 * If we need a large contiguous chunk of memory, or have
 	 * trouble getting a small set of contiguous pages, we
 	 * will reclaim both active and inactive pages.
 	 */
-	sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;
 	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
-		sc->lumpy_reclaim_mode |= mode;
+		sc->lumpy_reclaim_mode |= syncmode;
 	else if (sc->order && priority < DEF_PRIORITY - 2)
-		sc->lumpy_reclaim_mode |= mode;
+		sc->lumpy_reclaim_mode |= syncmode;
 	else
 		sc->lumpy_reclaim_mode = LUMPY_MODE_SINGLE | LUMPY_MODE_ASYNC;
 }
@@ -1375,11 +1381,18 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 
+	/*
+	 * If we are lumpy compacting, we bump nr_to_scan to at least
+	 * the size of the page we are trying to allocate
+	 */
+	if (sc->lumpy_reclaim_mode & LUMPY_MODE_COMPACTION)
+		nr_to_scan = max(nr_to_scan, (1UL << sc->order));
+
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
@@ -1391,8 +1404,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
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
@@ -1425,6 +1438,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
 
+	if (sc->lumpy_reclaim_mode & LUMPY_MODE_COMPACTION)
+		reclaimcompact_zone_order(zone, sc->order, sc->gfp_mask);
+
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
 		zone_idx(zone),
 		nr_scanned, nr_reclaimed,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
