Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 02F666B0073
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 20:43:07 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so41241631pdj.0
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 17:43:06 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id rd8si42279588pab.72.2015.06.24.17.42.55
        for <linux-mm@kvack.org>;
        Wed, 24 Jun 2015 17:42:56 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 07/10] mm/compaction: limit compaction activity in compaction depleted state
Date: Thu, 25 Jun 2015 09:45:18 +0900
Message-Id: <1435193121-25880-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Compaction deferring was introduced to reduce overhead of compaction
when compaction attempt is expected to fail. But, it has a problem.
Whole zone is rescanned after some compaction attempts are deferred and
this rescan overhead is quite big. And, it imposes large latency to one
random requestor while others will get nearly zero latency to fail due
to deferring compaction. This patch try to handle this situation
differently to solve above problems.

At first, we should know when compaction will fail. Previous patch
defines compaction depleted state. In this state, compaction failure
is highly expected so we don't need to take much effort on compaction.
So, this patch forces migration scanner scan restricted number of pages
in this state. With this way, we can evenly distribute compaction overhead
to all compaction requestors. And, there is a way to escape from
compaction depleted state so we don't need to defer specific number of
compaction attempts unconditionally if compaction possibility recovers.

In this patch, migration scanner limit is defined to imitate current
compaction deferring approach. But, we can tune it easily if this
overhead doesn't look appropriate. It would be further work.

There would be a situation that compactino depleted state is maintained
for a long time. In this case, repeated compaction attempts would cause
useless overhead continually. To optimize this case, this patch introduce
compaction depletion depth and make migration scanner limit diminished
according to this depth. It effectively reduce compaction overhead in
this situation.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h |  1 +
 mm/compaction.c        | 61 ++++++++++++++++++++++++++++++++++++++++++++++++--
 mm/internal.h          |  1 +
 3 files changed, 61 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bd9f1a5..700e9b5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -518,6 +518,7 @@ struct zone {
 	unsigned int		compact_defer_shift;
 	int			compact_order_failed;
 	unsigned long		compact_success;
+	unsigned long		compact_depletion_depth;
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
diff --git a/mm/compaction.c b/mm/compaction.c
index 9f259b9..aff536f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -130,6 +130,7 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_DEFER_SHIFT 6
 #define COMPACT_MIN_DEPLETE_THRESHOLD 1UL
+#define COMPACT_MIN_SCAN_LIMIT (pageblock_nr_pages)
 
 static bool compaction_depleted(struct zone *zone)
 {
@@ -147,6 +148,48 @@ static bool compaction_depleted(struct zone *zone)
 	return true;
 }
 
+static void set_migration_scan_limit(struct compact_control *cc)
+{
+	struct zone *zone = cc->zone;
+	int order = cc->order;
+	unsigned long limit;
+
+	cc->migration_scan_limit = LONG_MAX;
+	if (order < 0)
+		return;
+
+	if (!test_bit(ZONE_COMPACTION_DEPLETED, &zone->flags))
+		return;
+
+	if (!zone->compact_depletion_depth)
+		return;
+
+	/* Stop async migration if depleted */
+	if (cc->mode == MIGRATE_ASYNC) {
+		cc->migration_scan_limit = -1;
+		return;
+	}
+
+	/*
+	 * Deferred compaction restart compaction every 64 compaction
+	 * attempts and it rescans whole zone range. If we limit
+	 * migration scanner to scan 1/64 range when depleted, 64
+	 * compaction attempts will rescan whole zone range as same
+	 * as deferred compaction.
+	 */
+	limit = zone->managed_pages >> 6;
+
+	/*
+	 * We don't do async compaction. Instead, give extra credit
+	 * to sync compaction
+	 */
+	limit <<= 1;
+	limit = max(limit, COMPACT_MIN_SCAN_LIMIT);
+
+	/* Degradation scan limit according to depletion depth. */
+	limit >>= zone->compact_depletion_depth;
+	cc->migration_scan_limit = max(limit, COMPACT_CLUSTER_MAX);
+}
 /*
  * Compaction is deferred when compaction fails to result in a page
  * allocation success. 1 << compact_defer_limit compactions are skipped up
@@ -243,8 +286,14 @@ static void __reset_isolation_suitable(struct zone *zone)
 	zone->compact_cached_free_pfn = end_pfn;
 	zone->compact_blockskip_flush = false;
 
-	if (compaction_depleted(zone))
-		set_bit(ZONE_COMPACTION_DEPLETED, &zone->flags);
+	if (compaction_depleted(zone)) {
+		if (test_bit(ZONE_COMPACTION_DEPLETED, &zone->flags))
+			zone->compact_depletion_depth++;
+		else {
+			set_bit(ZONE_COMPACTION_DEPLETED, &zone->flags);
+			zone->compact_depletion_depth = 0;
+		}
+	}
 	zone->compact_success = 0;
 
 	/* Walk the zone and mark every pageblock as suitable for isolation */
@@ -839,6 +888,7 @@ isolate_success:
 	if (locked)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
+	cc->migration_scan_limit -= nr_scanned;
 	if (low_pfn == end_pfn && cc->mode != MIGRATE_ASYNC) {
 		int sync = cc->mode != MIGRATE_ASYNC;
 
@@ -1198,6 +1248,9 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 		return COMPACT_COMPLETE;
 	}
 
+	if (cc->migration_scan_limit < 0)
+		return COMPACT_PARTIAL;
+
 	/*
 	 * order == -1 is expected when compacting via
 	 * /proc/sys/vm/compact_memory
@@ -1373,6 +1426,10 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
 	}
 
+	set_migration_scan_limit(cc);
+	if (cc->migration_scan_limit < 0)
+		return COMPACT_SKIPPED;
+
 	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync);
 
diff --git a/mm/internal.h b/mm/internal.h
index 36b23f1..a427695 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -182,6 +182,7 @@ struct compact_control {
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
+	long migration_scan_limit;	/* Limit migration scanner activity */
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
