Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id AC0E56B007D
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 20:43:15 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so38831721pab.1
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 17:43:15 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id of16si42273618pdb.108.2015.06.24.17.43.00
        for <linux-mm@kvack.org>;
        Wed, 24 Jun 2015 17:43:01 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 08/10] mm/compaction: remove compaction deferring
Date: Thu, 25 Jun 2015 09:45:19 +0900
Message-Id: <1435193121-25880-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, we have a way to determine compaction depleted state and compaction
activity will be limited according this state and depletion depth so
compaction overhead would be well controlled without compaction deferring.
So, this patch remove compaction deferring completely.

Various functions are renamed and tracepoint outputs are changed due to
this removing.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/compaction.h        | 14 +-------
 include/linux/mmzone.h            |  3 +-
 include/trace/events/compaction.h | 30 +++++++---------
 mm/compaction.c                   | 74 ++++++++++-----------------------------
 mm/page_alloc.c                   |  2 +-
 mm/vmscan.c                       |  4 +--
 6 files changed, 37 insertions(+), 90 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index aa8f61c..8d98f3c 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -45,11 +45,8 @@ extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern unsigned long compaction_suitable(struct zone *zone, int order,
 					int alloc_flags, int classzone_idx);
 
-extern void defer_compaction(struct zone *zone, int order);
-extern bool compaction_deferred(struct zone *zone, int order);
-extern void compaction_defer_reset(struct zone *zone, int order,
+extern void compaction_failed_reset(struct zone *zone, int order,
 				bool alloc_success);
-extern bool compaction_restarting(struct zone *zone, int order);
 
 #else
 static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
@@ -74,15 +71,6 @@ static inline unsigned long compaction_suitable(struct zone *zone, int order,
 	return COMPACT_SKIPPED;
 }
 
-static inline void defer_compaction(struct zone *zone, int order)
-{
-}
-
-static inline bool compaction_deferred(struct zone *zone, int order)
-{
-	return true;
-}
-
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 700e9b5..e13b732 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -514,8 +514,7 @@ struct zone {
 	 * are skipped before trying again. The number attempted since
 	 * last failure is tracked with compact_considered.
 	 */
-	unsigned int		compact_considered;
-	unsigned int		compact_defer_shift;
+	int			compact_failed;
 	int			compact_order_failed;
 	unsigned long		compact_success;
 	unsigned long		compact_depletion_depth;
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 9a6a3fe..323e614 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -239,7 +239,7 @@ DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_suitable,
 );
 
 #ifdef CONFIG_COMPACTION
-DECLARE_EVENT_CLASS(mm_compaction_defer_template,
+DECLARE_EVENT_CLASS(mm_compaction_deplete_template,
 
 	TP_PROTO(struct zone *zone, int order),
 
@@ -249,8 +249,9 @@ DECLARE_EVENT_CLASS(mm_compaction_defer_template,
 		__field(int, nid)
 		__field(char *, name)
 		__field(int, order)
-		__field(unsigned int, considered)
-		__field(unsigned int, defer_shift)
+		__field(unsigned long, success)
+		__field(unsigned long, depletion_depth)
+		__field(int, failed)
 		__field(int, order_failed)
 	),
 
@@ -258,35 +259,30 @@ DECLARE_EVENT_CLASS(mm_compaction_defer_template,
 		__entry->nid = zone_to_nid(zone);
 		__entry->name = (char *)zone->name;
 		__entry->order = order;
-		__entry->considered = zone->compact_considered;
-		__entry->defer_shift = zone->compact_defer_shift;
+		__entry->success = zone->compact_success;
+		__entry->depletion_depth = zone->compact_depletion_depth;
+		__entry->failed = zone->compact_failed;
 		__entry->order_failed = zone->compact_order_failed;
 	),
 
-	TP_printk("node=%d zone=%-8s order=%d order_failed=%d consider=%u limit=%lu",
+	TP_printk("node=%d zone=%-8s order=%d failed=%d order_failed=%d consider=%lu depth=%lu",
 		__entry->nid,
 		__entry->name,
 		__entry->order,
+		__entry->failed,
 		__entry->order_failed,
-		__entry->considered,
-		1UL << __entry->defer_shift)
+		__entry->success,
+		__entry->depletion_depth)
 );
 
-DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_deferred,
+DEFINE_EVENT(mm_compaction_deplete_template, mm_compaction_fail_compaction,
 
 	TP_PROTO(struct zone *zone, int order),
 
 	TP_ARGS(zone, order)
 );
 
-DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_defer_compaction,
-
-	TP_PROTO(struct zone *zone, int order),
-
-	TP_ARGS(zone, order)
-);
-
-DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_defer_reset,
+DEFINE_EVENT(mm_compaction_deplete_template, mm_compaction_failed_reset,
 
 	TP_PROTO(struct zone *zone, int order),
 
diff --git a/mm/compaction.c b/mm/compaction.c
index aff536f..649fca2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -128,7 +128,7 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 #ifdef CONFIG_COMPACTION
 
 /* Do not skip compaction more than 64 times */
-#define COMPACT_MAX_DEFER_SHIFT 6
+#define COMPACT_MAX_FAILED 4
 #define COMPACT_MIN_DEPLETE_THRESHOLD 1UL
 #define COMPACT_MIN_SCAN_LIMIT (pageblock_nr_pages)
 
@@ -190,61 +190,28 @@ static void set_migration_scan_limit(struct compact_control *cc)
 	limit >>= zone->compact_depletion_depth;
 	cc->migration_scan_limit = max(limit, COMPACT_CLUSTER_MAX);
 }
-/*
- * Compaction is deferred when compaction fails to result in a page
- * allocation success. 1 << compact_defer_limit compactions are skipped up
- * to a limit of 1 << COMPACT_MAX_DEFER_SHIFT
- */
-void defer_compaction(struct zone *zone, int order)
-{
-	zone->compact_considered = 0;
-	zone->compact_defer_shift++;
-
-	if (order < zone->compact_order_failed)
-		zone->compact_order_failed = order;
-
-	if (zone->compact_defer_shift > COMPACT_MAX_DEFER_SHIFT)
-		zone->compact_defer_shift = COMPACT_MAX_DEFER_SHIFT;
 
-	trace_mm_compaction_defer_compaction(zone, order);
-}
-
-/* Returns true if compaction should be skipped this time */
-bool compaction_deferred(struct zone *zone, int order)
+void fail_compaction(struct zone *zone, int order)
 {
-	unsigned long defer_limit = 1UL << zone->compact_defer_shift;
-
-	if (order < zone->compact_order_failed)
-		return false;
-
-	/* Avoid possible overflow */
-	if (++zone->compact_considered > defer_limit)
-		zone->compact_considered = defer_limit;
-
-	if (zone->compact_considered >= defer_limit)
-		return false;
-
-	trace_mm_compaction_deferred(zone, order);
+	if (order < zone->compact_order_failed) {
+		zone->compact_failed = 0;
+		zone->compact_order_failed = order;
+	} else
+		zone->compact_failed++;
 
-	return true;
+	trace_mm_compaction_fail_compaction(zone, order);
 }
 
-/*
- * Update defer tracking counters after successful compaction of given order,
- * which means an allocation either succeeded (alloc_success == true) or is
- * expected to succeed.
- */
-void compaction_defer_reset(struct zone *zone, int order,
+void compaction_failed_reset(struct zone *zone, int order,
 		bool alloc_success)
 {
-	if (alloc_success) {
-		zone->compact_considered = 0;
-		zone->compact_defer_shift = 0;
-	}
+	if (alloc_success)
+		zone->compact_failed = 0;
+
 	if (order >= zone->compact_order_failed)
 		zone->compact_order_failed = order + 1;
 
-	trace_mm_compaction_defer_reset(zone, order);
+	trace_mm_compaction_failed_reset(zone, order);
 }
 
 /* Returns true if restarting compaction after many failures */
@@ -256,8 +223,7 @@ static bool compaction_direct_restarting(struct zone *zone, int order)
 	if (order < zone->compact_order_failed)
 		return false;
 
-	return zone->compact_defer_shift == COMPACT_MAX_DEFER_SHIFT &&
-		zone->compact_considered >= 1UL << zone->compact_defer_shift;
+	return zone->compact_failed < COMPACT_MAX_FAILED ? false : true;
 }
 
 /* Returns true if the pageblock should be scanned for pages to isolate. */
@@ -295,6 +261,7 @@ static void __reset_isolation_suitable(struct zone *zone)
 		}
 	}
 	zone->compact_success = 0;
+	zone->compact_failed = 0;
 
 	/* Walk the zone and mark every pageblock as suitable for isolation */
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
@@ -1610,9 +1577,6 @@ unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		int status;
 		int zone_contended;
 
-		if (compaction_deferred(zone, order))
-			continue;
-
 		status = compact_zone_order(zone, order, gfp_mask, mode,
 				&zone_contended, alloc_flags,
 				ac->classzone_idx);
@@ -1632,7 +1596,7 @@ unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			 * will repeat this with true if allocation indeed
 			 * succeeds in this zone.
 			 */
-			compaction_defer_reset(zone, order, false);
+			compaction_failed_reset(zone, order, false);
 			/*
 			 * It is possible that async compaction aborted due to
 			 * need_resched() and the watermarks were ok thanks to
@@ -1653,7 +1617,7 @@ unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			 * so we defer compaction there. If it ends up
 			 * succeeding after all, it will be reset.
 			 */
-			defer_compaction(zone, order);
+			fail_compaction(zone, order);
 		}
 
 		/*
@@ -1715,13 +1679,13 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 		if (cc->order == -1)
 			__reset_isolation_suitable(zone);
 
-		if (cc->order == -1 || !compaction_deferred(zone, cc->order))
+		if (cc->order == -1)
 			compact_zone(zone, cc);
 
 		if (cc->order > 0) {
 			if (zone_watermark_ok(zone, cc->order,
 						low_wmark_pages(zone), 0, 0))
-				compaction_defer_reset(zone, cc->order, false);
+				compaction_failed_reset(zone, cc->order, false);
 		}
 
 		VM_BUG_ON(!list_empty(&cc->freepages));
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index afd5459..f53d764 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2821,7 +2821,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		struct zone *zone = page_zone(page);
 
 		zone->compact_blockskip_flush = false;
-		compaction_defer_reset(zone, order, true);
+		compaction_failed_reset(zone, order, true);
 		count_vm_event(COMPACTSUCCESS);
 		return page;
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 37e90db..a561b5f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2469,10 +2469,10 @@ static inline bool compaction_ready(struct zone *zone, int order)
 	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0, 0);
 
 	/*
-	 * If compaction is deferred, reclaim up to a point where
+	 * If compaction is depleted, reclaim up to a point where
 	 * compaction will have a chance of success when re-enabled
 	 */
-	if (compaction_deferred(zone, order))
+	if (test_bit(ZONE_COMPACTION_DEPLETED, &zone->flags))
 		return watermark_ok;
 
 	/*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
