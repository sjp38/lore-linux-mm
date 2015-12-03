Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A0E686B025B
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 02:11:54 -0500 (EST)
Received: by pfdd184 with SMTP id d184so5530188pfd.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:54 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id t7si10122795pfi.212.2015.12.02.23.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 23:11:53 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so63043002pac.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:53 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v3 6/7] mm/compaction: introduce migration scan limit
Date: Thu,  3 Dec 2015 16:11:20 +0900
Message-Id: <1449126681-19647-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This is preparation step to replace compaction deferring with compaction
limit. Whole reason why we need to replace it will be mentioned in
the following patch.

In this patch, migration_scan_limit is assigned and accounted, but, not
checked to finish. So, there is no functional change.

Currently, amount of migration_scan_limit is chosen to imitate compaction
deferring logic. We can tune it easily if overhead looks insane, but,
it would be further work.
Also, amount of migration_scan_limit is adapted by compact_defer_shift.
More fails increase compact_defer_shift and this will limit compaction
more.

There are two interesting changes. One is that cached pfn is always
updated while limit is activated. Otherwise, we would scan same range
over and over. Second one is that async compaction is skipped while
limit is activated, for algorithm correctness. Until now, even if
failure case, sync compaction continue to work when both scanner is met
so COMPACT_COMPLETE usually happens in sync compaction. But, limit is
applied, sync compaction is finished if limit is exhausted so
COMPACT_COMPLETE usually happens in async compaction. Because we don't
consider async COMPACT_COMPLETE as actual fail while we reset cached
scanner pfn, defer mechanism doesn't work well. And, async compaction
would not be easy to succeed in this case so skipping async compaction
doesn't result in much difference.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 88 +++++++++++++++++++++++++++++++++++++++++++++++++--------
 mm/internal.h   |  1 +
 2 files changed, 78 insertions(+), 11 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 1a75a6e..b23f6d9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -116,6 +116,67 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 
 #ifdef CONFIG_COMPACTION
 
+/*
+ * order == -1 is expected when compacting via
+ * /proc/sys/vm/compact_memory
+ */
+static inline bool is_via_compact_memory(int order)
+{
+	return order == -1;
+}
+
+#define COMPACT_MIN_SCAN_LIMIT (pageblock_nr_pages)
+
+static bool excess_migration_scan_limit(struct compact_control *cc)
+{
+	/* Disable scan limit for now */
+	return false;
+}
+
+static void set_migration_scan_limit(struct compact_control *cc)
+{
+	struct zone *zone = cc->zone;
+	int order = cc->order;
+	unsigned long limit = zone->managed_pages;
+
+	cc->migration_scan_limit = LONG_MAX;
+	if (is_via_compact_memory(order))
+		return;
+
+	if (order < zone->compact_order_failed)
+		return;
+
+	if (!zone->compact_defer_shift)
+		return;
+
+	/*
+	 * Do not allow async compaction during limit work. In this case,
+	 * async compaction would not be easy to succeed and we need to
+	 * ensure that COMPACT_COMPLETE occurs by sync compaction for
+	 * algorithm correctness and prevention of async compaction will
+	 * lead it.
+	 */
+	if (cc->mode == MIGRATE_ASYNC) {
+		cc->migration_scan_limit = -1;
+		return;
+	}
+
+	/* Migration scanner usually scans less than 1/4 pages */
+	limit >>= 2;
+
+	/*
+	 * Deferred compaction restart compaction every 64 compaction
+	 * attempts and it rescans whole zone range. To imitate it,
+	 * we set limit to 1/64 of scannable range.
+	 */
+	limit >>= 6;
+
+	/* Degradation scan limit according to defer shift */
+	limit >>= zone->compact_defer_shift;
+
+	cc->migration_scan_limit = max(limit, COMPACT_MIN_SCAN_LIMIT);
+}
+
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_DEFER_SHIFT 6
 
@@ -263,10 +324,15 @@ static void update_pageblock_skip(struct compact_control *cc,
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
@@ -822,6 +888,8 @@ isolate_success:
 	if (locked)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
+	cc->migration_scan_limit -= nr_scanned;
+
 	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
 						nr_scanned, nr_isolated);
 
@@ -1186,15 +1254,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
 }
 
-/*
- * order == -1 is expected when compacting via
- * /proc/sys/vm/compact_memory
- */
-static inline bool is_via_compact_memory(int order)
-{
-	return order == -1;
-}
-
 static int __compact_finished(struct zone *zone, struct compact_control *cc,
 			    const int migratetype)
 {
@@ -1224,6 +1283,9 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 	if (is_via_compact_memory(cc->order))
 		return COMPACT_CONTINUE;
 
+	if (excess_migration_scan_limit(cc))
+		return COMPACT_PARTIAL;
+
 	/* Compaction run is not finished if the watermark is not met */
 	watermark = low_wmark_pages(zone);
 
@@ -1382,6 +1444,10 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	}
 	cc->last_migrated_pfn = 0;
 
+	set_migration_scan_limit(cc);
+	if (excess_migration_scan_limit(cc))
+		return COMPACT_SKIPPED;
+
 	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync);
 
diff --git a/mm/internal.h b/mm/internal.h
index dbe0436..bb8225c 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -164,6 +164,7 @@ struct compact_control {
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
+	long migration_scan_limit;      /* Limit migration scanner activity */
 	enum migrate_mode mode;		/* Async or sync migration mode */
 	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
 	int order;			/* order a direct compactor needs */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
