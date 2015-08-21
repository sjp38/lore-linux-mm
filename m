Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 584616B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 23:50:56 -0400 (EDT)
Received: by paom9 with SMTP id m9so9013340pao.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 20:50:56 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id po4si10751280pdb.142.2015.08.20.20.50.54
        for <linux-mm@kvack.org>;
        Thu, 20 Aug 2015 20:50:55 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] mm/compaction: correct to flush migrated pages if pageblock skip happens
Date: Fri, 21 Aug 2015 12:56:59 +0900
Message-Id: <1440129419-30023-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We cache isolate_start_pfn before entering isolate_migratepages().
If pageblock is skipped in isolate_migratepages() due to whatever reason,
cc->migrate_pfn could be far from isolate_start_pfn hence flushing pages
that were freed happens. For example, following scenario can be possible.

- assume order-9 compaction, pageblock order is 9
- start_isolate_pfn is 0x200
- isolate_migratepages()
  - skip a number of pageblocks
  - start to isolate from pfn 0x600
  - cc->migrate_pfn = 0x620
  - return
- last_migrated_pfn is set to 0x200
- check flushing condition
  - current_block_start is set to 0x600
  - last_migrated_pfn < current_block_start then do useless flush

This wrong flush would not help the performance and success rate so
this patch try to fix it. One simple way to know exact position
where we start to isolate migratable pages is that we cache it
in isolate_migratepages() before entering actual isolation. This patch
implements it and fix the problem.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 30 +++++++++++++++---------------
 mm/internal.h   |  1 +
 2 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 86f04e5..4cae0f6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1112,6 +1112,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
 	unsigned long low_pfn, end_pfn;
+	unsigned long isolate_start_pfn;
 	struct page *page;
 	const isolate_mode_t isolate_mode =
 		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE : 0) |
@@ -1160,6 +1161,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 
 		/* Perform the isolation */
+		isolate_start_pfn = low_pfn;
 		low_pfn = isolate_migratepages_block(cc, low_pfn, end_pfn,
 								isolate_mode);
 
@@ -1169,6 +1171,15 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		}
 
 		/*
+		 * Record where we could have freed pages by migration and not
+		 * yet flushed them to buddy allocator.
+		 * - this is the lowest page that could have been isolated and
+		 * then freed by migration.
+		 */
+		if (cc->nr_migratepages && !cc->last_migrated_pfn)
+			cc->last_migrated_pfn = isolate_start_pfn;
+
+		/*
 		 * Either we isolated something and proceed with migration. Or
 		 * we failed and compact_zone should decide if we should
 		 * continue or not.
@@ -1339,7 +1350,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	unsigned long end_pfn = zone_end_pfn(zone);
 	const int migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	const bool sync = cc->mode != MIGRATE_ASYNC;
-	unsigned long last_migrated_pfn = 0;
 
 	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
 							cc->classzone_idx);
@@ -1377,6 +1387,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
 		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
 	}
+	cc->last_migrated_pfn = 0;
 
 	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync);
@@ -1386,7 +1397,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	while ((ret = compact_finished(zone, cc, migratetype)) ==
 						COMPACT_CONTINUE) {
 		int err;
-		unsigned long isolate_start_pfn = cc->migrate_pfn;
 
 		switch (isolate_migratepages(zone, cc)) {
 		case ISOLATE_ABORT:
@@ -1426,16 +1436,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 			}
 		}
 
-		/*
-		 * Record where we could have freed pages by migration and not
-		 * yet flushed them to buddy allocator. We use the pfn that
-		 * isolate_migratepages() started from in this loop iteration
-		 * - this is the lowest page that could have been isolated and
-		 * then freed by migration.
-		 */
-		if (!last_migrated_pfn)
-			last_migrated_pfn = isolate_start_pfn;
-
 check_drain:
 		/*
 		 * Has the migration scanner moved away from the previous
@@ -1444,18 +1444,18 @@ check_drain:
 		 * compact_finished() can detect immediately if allocation
 		 * would succeed.
 		 */
-		if (cc->order > 0 && last_migrated_pfn) {
+		if (cc->order > 0 && cc->last_migrated_pfn) {
 			int cpu;
 			unsigned long current_block_start =
 				cc->migrate_pfn & ~((1UL << cc->order) - 1);
 
-			if (last_migrated_pfn < current_block_start) {
+			if (cc->last_migrated_pfn < current_block_start) {
 				cpu = get_cpu();
 				lru_add_drain_cpu(cpu);
 				drain_local_pages(zone);
 				put_cpu();
 				/* No more flushing until we migrate again */
-				last_migrated_pfn = 0;
+				cc->last_migrated_pfn = 0;
 			}
 		}
 
diff --git a/mm/internal.h b/mm/internal.h
index 1195dd2..bc0fa9a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -182,6 +182,7 @@ struct compact_control {
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
+	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
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
