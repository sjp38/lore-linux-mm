Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1437F6B0071
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 02:12:46 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id w10so1521509pde.39
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 23:12:45 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id v7si58736107pdj.60.2014.12.07.23.12.40
        for <linux-mm@kvack.org>;
        Sun, 07 Dec 2014 23:12:41 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 3/4] mm/compaction: enhance compaction finish condition
Date: Mon,  8 Dec 2014 16:16:19 +0900
Message-Id: <1418022980-4584-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Compaction has anti fragmentation algorithm. It is that freepage
should be more than pageblock order to finish the compaction if we don't
find any freepage in requested migratetype buddy list. This is for
mitigating fragmentation, but, it is a lack of migratetype consideration
and too excessive.

At first, it doesn't consider migratetype so there would be false positive
on compaction finish decision. For example, if allocation request is
for unmovable migratetype, freepage in CMA migratetype doesn't help that
allocation, so compaction should not be stopped. But, current logic
considers it as compaction is no longer needed and stop the compaction.

Secondly, it is too excessive. We can steal freepage from other migratetype
and change pageblock migratetype on more relaxed conditions. In page
allocator, there is another conditions that can succeed to steal without
introducing fragmentation.

To solve these problems, this patch borrows anti fragmentation logic from
page allocator. It will reduce premature compaction finish in some cases
and reduce excessive compaction work.

stress-highalloc test in mmtests with non movable order 7 allocation shows
in allocation success rate on phase 1 and compaction success rate.

Allocation success rate on phase 1 (%)
57.00 : 63.67

Compaction success rate (Compaction success * 100 / Compaction stalls, %)
28.94 : 35.13

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h |    3 +++
 mm/compaction.c        |   31 +++++++++++++++++++++++++++++--
 mm/internal.h          |    1 +
 mm/page_alloc.c        |    5 ++---
 4 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2f0856d..87f5bb5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -63,6 +63,9 @@ enum {
 	MIGRATE_TYPES
 };
 
+#define FALLBACK_MIGRATETYPES (4)
+extern int fallbacks[MIGRATE_TYPES][FALLBACK_MIGRATETYPES];
+
 #ifdef CONFIG_CMA
 #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
 #else
diff --git a/mm/compaction.c b/mm/compaction.c
index 1a5f465..2fd5f79 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1054,6 +1054,30 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
 }
 
+static bool can_steal_fallbacks(struct free_area *area,
+			unsigned int order, int migratetype)
+{
+	int i;
+	int fallback_mt;
+
+	if (area->nr_free == 0)
+		return false;
+
+	for (i = 0; i < FALLBACK_MIGRATETYPES; i++) {
+		fallback_mt = fallbacks[migratetype][i];
+		if (fallback_mt == MIGRATE_RESERVE)
+			break;
+
+		if (list_empty(&area->free_list[fallback_mt]))
+			continue;
+
+		if (can_steal_freepages(order, migratetype, fallback_mt))
+			return true;
+	}
+
+	return false;
+}
+
 static int __compact_finished(struct zone *zone, struct compact_control *cc,
 			    const int migratetype)
 {
@@ -1104,8 +1128,11 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 		if (!list_empty(&area->free_list[migratetype]))
 			return COMPACT_PARTIAL;
 
-		/* Job done if allocation would set block type */
-		if (order >= pageblock_order && area->nr_free)
+		/*
+		 * Job done if allocation would steal freepages from
+		 * other migratetype buddy lists.
+		 */
+		if (can_steal_fallbacks(area, order, migratetype))
 			return COMPACT_PARTIAL;
 	}
 
diff --git a/mm/internal.h b/mm/internal.h
index efad241..7028d83 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -179,6 +179,7 @@ unsigned long
 isolate_migratepages_range(struct compact_control *cc,
 			   unsigned long low_pfn, unsigned long end_pfn);
 
+bool can_steal_freepages(unsigned int order, int start_mt, int fallback_mt);
 #endif
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7b4c9aa..dcb8523 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1031,7 +1031,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
  * This array describes the order lists are fallen back to when
  * the free lists for the desirable migrate type are depleted
  */
-static int fallbacks[MIGRATE_TYPES][4] = {
+int fallbacks[MIGRATE_TYPES][FALLBACK_MIGRATETYPES] = {
 	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,     MIGRATE_RESERVE },
 	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,     MIGRATE_RESERVE },
 #ifdef CONFIG_CMA
@@ -1161,8 +1161,7 @@ static void try_to_steal_freepages(struct zone *zone, struct page *page,
 	}
 }
 
-static bool can_steal_freepages(unsigned int order,
-			int start_mt, int fallback_mt)
+bool can_steal_freepages(unsigned int order, int start_mt, int fallback_mt)
 {
 	/*
 	 * When borrowing from MIGRATE_CMA, we need to release the excess
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
