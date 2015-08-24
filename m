Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 580E982F5F
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 22:20:05 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so48183958pdr.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:05 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id ks7si25002962pab.99.2015.08.23.19.20.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 19:20:04 -0700 (PDT)
Received: by pacgr6 with SMTP id gr6so6513067pac.1
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:04 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 3/9] mm/compaction: limit compaction activity in compaction depleted state
Date: Mon, 24 Aug 2015 11:19:27 +0900
Message-Id: <1440382773-16070-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
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

There would be a situation that compaction depleted state is maintained
for a long time. In this case, repeated compaction attempts would cause
useless overhead continually. To optimize this case, this patch uses
compaction depletion depth and make migration scanner limit diminished
according to this depth. It effectively reduce compaction overhead in
this situation.

Should note that this patch just introduces scan_limit infrastructure
and doesn't check scan_limit to finish the compaction. It will
be implemented in next patch with removing compaction deferring.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 41 +++++++++++++++++++++++++++++++++++++++++
 mm/internal.h   |  1 +
 2 files changed, 42 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index de96e9d..c6b8277 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -130,6 +130,7 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_DEFER_SHIFT 6
 #define COMPACT_MIN_DEPLETE_THRESHOLD 1UL
+#define COMPACT_MIN_SCAN_LIMIT (pageblock_nr_pages)
 
 static bool compaction_depleted(struct zone *zone)
 {
@@ -147,6 +148,42 @@ static bool compaction_depleted(struct zone *zone)
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
+	/*
+	 * Experimental observation shows that migration scanner
+	 * normally scans 1/4 pages
+	 */
+	limit = zone->managed_pages >> 2;
+
+	/*
+	 * Deferred compaction restart compaction every 64 compaction
+	 * attempts and it rescans whole zone range. If we limit
+	 * migration scanner to scan 1/64 range when depleted, 64
+	 * compaction attempts will rescan whole zone range as same
+	 * as deferred compaction.
+	 */
+	limit >>= 6;
+	limit = max(limit, COMPACT_MIN_SCAN_LIMIT);
+
+	/* Degradation scan limit according to depletion depth. */
+	limit >>= zone->compact_depletion_depth;
+	cc->migration_scan_limit = max(limit, COMPACT_CLUSTER_MAX);
+}
 /*
  * Compaction is deferred when compaction fails to result in a page
  * allocation success. 1 << compact_defer_limit compactions are skipped up
@@ -839,6 +876,8 @@ isolate_success:
 		update_pageblock_skip(cc, valid_page, nr_isolated,
 					end_pfn, true);
 
+	cc->migration_scan_limit -= nr_scanned;
+
 	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
 						nr_scanned, nr_isolated);
 
@@ -1367,6 +1406,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
 	}
 
+	set_migration_scan_limit(cc);
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
