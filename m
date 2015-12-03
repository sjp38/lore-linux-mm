Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D77BA6B025C
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 02:11:57 -0500 (EST)
Received: by pfdd184 with SMTP id d184so5530618pfd.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:57 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id c25si10156424pfj.130.2015.12.02.23.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 23:11:57 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so64995871pab.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:57 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v3 7/7] mm/compaction: replace compaction deferring with compaction limit
Date: Thu,  3 Dec 2015 16:11:21 +0900
Message-Id: <1449126681-19647-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Compaction deferring effectively reduces compaction overhead if
compaction success isn't expected. But, it is implemented that
skipping a number of compaction requests until compaction is re-enabled.
Due to this implementation, unfortunate compaction requestor will get
whole compaction overhead unlike others have zero overhead. And, after
deferring start to work, even if compaction success possibility is
restored, we should skip to compaction in some number of times.

This patch try to solve above problem by using compaction limit.
Instead of imposing compaction overhead to one unfortunate requestor,
compaction limit distributes overhead to all compaction requestors.
All requestors have a chance to migrate some amount of pages and
after limit is exhausted compaction will be stopped. This will fairly
distributes overhead to all compaction requestors. And, because we don't
defer compaction request, someone will succeed to compact as soon as
possible if compaction success possiblility is restored.

Following is whole workflow enabled by this change.

- if sync compaction fails, compact_order_failed is set to current order
- if it fails again, compact_defer_shift is adjusted
- with positive compact_defer_shift, migration_scan_limit is assigned and
compaction limit is activated
- if compaction limit is activated, compaction would be stopped when
migration_scan_limit is exhausted
- when success, compact_defer_shift and compact_order_failed is reset and
compaction limit is deactivated
- compact_defer_shift can be grown up to COMPACT_MAX_DEFER_SHIFT

Most of changes are mechanical ones to remove compact_considered which
is not needed now. Note that, after restart, compact_defer_shift is
subtracted by 1 to avoid invoking __reset_isolation_suitable()
repeatedly.

I tested this patch on my compaction benchmark and found that high-order
allocation latency is evenly distributed and there is no latency spike
in the situation where compaction success isn't possible.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h            |  6 ++---
 include/trace/events/compaction.h |  7 ++----
 mm/compaction.c                   | 47 +++++++++++++--------------------------
 3 files changed, 20 insertions(+), 40 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e23a9e7..ebb6400 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -511,11 +511,9 @@ struct zone {
 
 #ifdef CONFIG_COMPACTION
 	/*
-	 * On compaction failure, 1<<compact_defer_shift compactions
-	 * are skipped before trying again. The number attempted since
-	 * last failure is tracked with compact_considered.
+	 * On compaction failure, compaction will be limited by
+	 * compact_defer_shift.
 	 */
-	unsigned int		compact_considered;
 	unsigned int		compact_defer_shift;
 	int			compact_order_failed;
 #endif
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index c92d1e1..ab7bed1 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -305,7 +305,6 @@ DECLARE_EVENT_CLASS(mm_compaction_defer_template,
 		__field(int, nid)
 		__field(enum zone_type, idx)
 		__field(int, order)
-		__field(unsigned int, considered)
 		__field(unsigned int, defer_shift)
 		__field(int, order_failed)
 	),
@@ -314,18 +313,16 @@ DECLARE_EVENT_CLASS(mm_compaction_defer_template,
 		__entry->nid = zone_to_nid(zone);
 		__entry->idx = zone_idx(zone);
 		__entry->order = order;
-		__entry->considered = zone->compact_considered;
 		__entry->defer_shift = zone->compact_defer_shift;
 		__entry->order_failed = zone->compact_order_failed;
 	),
 
-	TP_printk("node=%d zone=%-8s order=%d order_failed=%d consider=%u limit=%lu",
+	TP_printk("node=%d zone=%-8s order=%d order_failed=%d defer=%u",
 		__entry->nid,
 		__print_symbolic(__entry->idx, ZONE_TYPE),
 		__entry->order,
 		__entry->order_failed,
-		__entry->considered,
-		1UL << __entry->defer_shift)
+		__entry->defer_shift)
 );
 
 DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_deferred,
diff --git a/mm/compaction.c b/mm/compaction.c
index b23f6d9..f3f9dc0 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -129,8 +129,7 @@ static inline bool is_via_compact_memory(int order)
 
 static bool excess_migration_scan_limit(struct compact_control *cc)
 {
-	/* Disable scan limit for now */
-	return false;
+	return cc->migration_scan_limit < 0 ? true : false;
 }
 
 static void set_migration_scan_limit(struct compact_control *cc)
@@ -143,10 +142,7 @@ static void set_migration_scan_limit(struct compact_control *cc)
 	if (is_via_compact_memory(order))
 		return;
 
-	if (order < zone->compact_order_failed)
-		return;
-
-	if (!zone->compact_defer_shift)
+	if (!compaction_deferred(zone, order))
 		return;
 
 	/*
@@ -188,13 +184,10 @@ static void set_migration_scan_limit(struct compact_control *cc)
 static void defer_compaction(struct zone *zone, int order)
 {
 	if (order < zone->compact_order_failed) {
-		zone->compact_considered = 0;
 		zone->compact_defer_shift = 0;
 		zone->compact_order_failed = order;
-	} else {
-		zone->compact_considered = 0;
+	} else
 		zone->compact_defer_shift++;
-	}
 
 	if (zone->compact_defer_shift > COMPACT_MAX_DEFER_SHIFT)
 		zone->compact_defer_shift = COMPACT_MAX_DEFER_SHIFT;
@@ -202,19 +195,13 @@ static void defer_compaction(struct zone *zone, int order)
 	trace_mm_compaction_defer_compaction(zone, order);
 }
 
-/* Returns true if compaction should be skipped this time */
+/* Returns true if compaction is limited */
 bool compaction_deferred(struct zone *zone, int order)
 {
-	unsigned long defer_limit = 1UL << zone->compact_defer_shift;
-
 	if (order < zone->compact_order_failed)
 		return false;
 
-	/* Avoid possible overflow */
-	if (++zone->compact_considered > defer_limit)
-		zone->compact_considered = defer_limit;
-
-	if (zone->compact_considered >= defer_limit)
+	if (!zone->compact_defer_shift)
 		return false;
 
 	trace_mm_compaction_deferred(zone, order);
@@ -226,7 +213,6 @@ bool compaction_deferred(struct zone *zone, int order)
 static void compaction_defer_reset(struct zone *zone, int order)
 {
 	if (order >= zone->compact_order_failed) {
-		zone->compact_considered = 0;
 		zone->compact_defer_shift = 0;
 		zone->compact_order_failed = order + 1;
 	}
@@ -240,8 +226,7 @@ bool compaction_restarting(struct zone *zone, int order)
 	if (order < zone->compact_order_failed)
 		return false;
 
-	return zone->compact_defer_shift == COMPACT_MAX_DEFER_SHIFT &&
-		zone->compact_considered >= 1UL << zone->compact_defer_shift;
+	return zone->compact_defer_shift == COMPACT_MAX_DEFER_SHIFT;
 }
 
 /* Returns true if the pageblock should be scanned for pages to isolate. */
@@ -266,7 +251,7 @@ static void reset_cached_positions(struct zone *zone)
  * should be skipped for page isolation when the migrate and free page scanner
  * meet.
  */
-static void __reset_isolation_suitable(struct zone *zone)
+static void __reset_isolation_suitable(struct zone *zone, bool restart)
 {
 	unsigned long start_pfn = zone->zone_start_pfn;
 	unsigned long end_pfn = zone_end_pfn(zone);
@@ -274,6 +259,11 @@ static void __reset_isolation_suitable(struct zone *zone)
 
 	zone->compact_blockskip_flush = false;
 
+	if (restart) {
+		/* To prevent restart at next compaction attempt */
+		zone->compact_defer_shift = COMPACT_MAX_DEFER_SHIFT - 1;
+	}
+
 	/* Walk the zone and mark every pageblock as suitable for isolation */
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
 		struct page *page;
@@ -304,7 +294,7 @@ void reset_isolation_suitable(pg_data_t *pgdat)
 
 		/* Only flush if a full compaction finished recently */
 		if (zone->compact_blockskip_flush)
-			__reset_isolation_suitable(zone);
+			__reset_isolation_suitable(zone, false);
 	}
 }
 
@@ -1424,7 +1414,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	 * this reset as it'll reset the cached information when going to sleep.
 	 */
 	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
-		__reset_isolation_suitable(zone);
+		__reset_isolation_suitable(zone, true);
 
 	/*
 	 * Setup to move all movable pages to the end of the zone. Used cached
@@ -1615,9 +1605,6 @@ unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		int status;
 		int zone_contended;
 
-		if (compaction_deferred(zone, order))
-			continue;
-
 		status = compact_zone_order(zone, order, gfp_mask, mode,
 				&zone_contended, alloc_flags,
 				ac->classzone_idx);
@@ -1713,11 +1700,9 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 		 * cached scanner positions.
 		 */
 		if (is_via_compact_memory(cc->order))
-			__reset_isolation_suitable(zone);
+			__reset_isolation_suitable(zone, false);
 
-		if (is_via_compact_memory(cc->order) ||
-				!compaction_deferred(zone, cc->order))
-			compact_zone(zone, cc);
+		compact_zone(zone, cc);
 
 		VM_BUG_ON(!list_empty(&cc->freepages));
 		VM_BUG_ON(!list_empty(&cc->migratepages));
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
