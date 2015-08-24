Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B289182F5F
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 22:20:10 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so6515040pac.1
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:10 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id b5si24897887pbu.237.2015.08.23.19.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 19:20:09 -0700 (PDT)
Received: by padfo6 with SMTP id fo6so5196449pad.3
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:09 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 4/9] mm/compaction: remove compaction deferring
Date: Mon, 24 Aug 2015 11:19:28 +0900
Message-Id: <1440382773-16070-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, we have a way to determine compaction depleted state and compaction
activity will be limited according this state and depletion depth so
compaction overhead would be well controlled without compaction deferring.
So, this patch remove compaction deferring completely and enable
compaction activity limit.

Various functions are renamed and tracepoint outputs are changed due to
this removing.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/compaction.h        | 14 +------
 include/linux/mmzone.h            |  3 +-
 include/trace/events/compaction.h | 30 ++++++-------
 mm/compaction.c                   | 88 ++++++++++++++-------------------------
 mm/page_alloc.c                   |  2 +-
 mm/vmscan.c                       |  4 +-
 6 files changed, 49 insertions(+), 92 deletions(-)

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
index c6b8277..1817564 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -128,7 +128,7 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 #ifdef CONFIG_COMPACTION
 
 /* Do not skip compaction more than 64 times */
-#define COMPACT_MAX_DEFER_SHIFT 6
+#define COMPACT_MAX_FAILED 4
 #define COMPACT_MIN_DEPLETE_THRESHOLD 1UL
 #define COMPACT_MIN_SCAN_LIMIT (pageblock_nr_pages)
 
@@ -184,61 +184,28 @@ static void set_migration_scan_limit(struct compact_control *cc)
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
-
-	trace_mm_compaction_defer_compaction(zone, order);
-}
 
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
@@ -247,8 +214,7 @@ bool compaction_restarting(struct zone *zone, int order)
 	if (order < zone->compact_order_failed)
 		return false;
 
-	return zone->compact_defer_shift == COMPACT_MAX_DEFER_SHIFT &&
-		zone->compact_considered >= 1UL << zone->compact_defer_shift;
+	return zone->compact_failed < COMPACT_MAX_FAILED ? false : true;
 }
 
 /* Returns true if the pageblock should be scanned for pages to isolate. */
@@ -286,6 +252,7 @@ static void __reset_isolation_suitable(struct zone *zone)
 		}
 	}
 	zone->compact_success = 0;
+	zone->compact_failed = 0;
 
 	/* Walk the zone and mark every pageblock as suitable for isolation */
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
@@ -335,10 +302,15 @@ static void update_pageblock_skip(struct compact_control *cc,
 	if (!page)
 		return;
 
-	if (nr_isolated)
+	/*
+	 * Always update cached_pfn if compaction has scan_limit,
+	 * otherwise we would scan same range over and over.
+	 */
+	if (cc->migration_scan_limit == LONG_MAX && nr_isolated)
 		return;
 
-	set_pageblock_skip(page);
+	if (!nr_isolated)
+		set_pageblock_skip(page);
 
 	/* Update where async and sync compaction should restart */
 	if (migrate_scanner) {
@@ -1231,6 +1203,9 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 		return COMPACT_COMPLETE;
 	}
 
+	if (cc->migration_scan_limit < 0)
+		return COMPACT_PARTIAL;
+
 	/*
 	 * order == -1 is expected when compacting via
 	 * /proc/sys/vm/compact_memory
@@ -1407,6 +1382,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	}
 
 	set_migration_scan_limit(cc);
+	if (cc->migration_scan_limit < 0)
+		return COMPACT_SKIPPED;
 
 	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync);
@@ -1588,9 +1565,6 @@ unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		int status;
 		int zone_contended;
 
-		if (compaction_deferred(zone, order))
-			continue;
-
 		status = compact_zone_order(zone, order, gfp_mask, mode,
 				&zone_contended, alloc_flags,
 				ac->classzone_idx);
@@ -1610,7 +1584,7 @@ unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			 * will repeat this with true if allocation indeed
 			 * succeeds in this zone.
 			 */
-			compaction_defer_reset(zone, order, false);
+			compaction_failed_reset(zone, order, false);
 			/*
 			 * It is possible that async compaction aborted due to
 			 * need_resched() and the watermarks were ok thanks to
@@ -1631,7 +1605,7 @@ unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			 * so we defer compaction there. If it ends up
 			 * succeeding after all, it will be reset.
 			 */
-			defer_compaction(zone, order);
+			fail_compaction(zone, order);
 		}
 
 		/*
@@ -1693,13 +1667,13 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
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
index 0e9cc98..c67f853 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2827,7 +2827,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
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
