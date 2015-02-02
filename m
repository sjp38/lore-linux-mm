Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 626156B0070
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 02:20:55 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so78993497pad.1
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 23:20:55 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id uv4si22538583pbc.110.2015.02.01.23.20.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 23:20:54 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so78810993pab.3
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 23:20:54 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [RFC PATCH v3 3/3] mm/compaction: enhance compaction finish condition
Date: Mon,  2 Feb 2015 16:15:48 +0900
Message-Id: <1422861348-5117-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1422861348-5117-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1422861348-5117-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Compaction has anti fragmentation algorithm. It is that freepage
should be more than pageblock order to finish the compaction if we don't
find any freepage in requested migratetype buddy list. This is for
mitigating fragmentation, but, there is a lack of migratetype
consideration and it is too excessive compared to page allocator's anti
fragmentation algorithm.

Not considering migratetype would cause premature finish of compaction.
For example, if allocation request is for unmovable migratetype,
freepage with CMA migratetype doesn't help that allocation and
compaction should not be stopped. But, current logic regards this
situation as compaction is no longer needed, so finish the compaction.

Secondly, condition is too excessive compared to page allocator's logic.
We can steal freepage from other migratetype and change pageblock
migratetype on more relaxed conditions in page allocator. This is designed
to prevent fragmentation and we can use it here. Imposing hard constraint
only to the compaction doesn't help much in this case since page allocator
would cause fragmentation again.

To solve these problems, this patch borrows anti fragmentation logic from
page allocator. It will reduce premature compaction finish in some cases
and reduce excessive compaction work.

stress-highalloc test in mmtests with non movable order 7 allocation shows
considerable increase of compaction success rate.

Compaction success rate (Compaction success * 100 / Compaction stalls, %)
31.82 : 42.20

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 14 ++++++++++++--
 mm/internal.h   |  2 ++
 mm/page_alloc.c | 12 ++++++++----
 3 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 782772d..d40c426 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1170,13 +1170,23 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 	/* Direct compactor: Is a suitable page free? */
 	for (order = cc->order; order < MAX_ORDER; order++) {
 		struct free_area *area = &zone->free_area[order];
+		bool can_steal;
 
 		/* Job done if page is free of the right migratetype */
 		if (!list_empty(&area->free_list[migratetype]))
 			return COMPACT_PARTIAL;
 
-		/* Job done if allocation would set block type */
-		if (order >= pageblock_order && area->nr_free)
+		/* MIGRATE_MOVABLE can fallback on MIGRATE_CMA */
+		if (migratetype == MIGRATE_MOVABLE &&
+			!list_empty(&area->free_list[MIGRATE_CMA]))
+			return COMPACT_PARTIAL;
+
+		/*
+		 * Job done if allocation would steal freepages from
+		 * other migratetype buddy lists.
+		 */
+		if (find_suitable_fallback(area, order, migratetype,
+						true, &can_steal) != -1)
 			return COMPACT_PARTIAL;
 	}
 
diff --git a/mm/internal.h b/mm/internal.h
index c4d6c9b..9640650 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -200,6 +200,8 @@ isolate_freepages_range(struct compact_control *cc,
 unsigned long
 isolate_migratepages_range(struct compact_control *cc,
 			   unsigned long low_pfn, unsigned long end_pfn);
+int find_suitable_fallback(struct free_area *area, unsigned int order,
+			int migratetype, bool only_stealable, bool *can_steal);
 
 #endif
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6cb18f8..0a150f1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1177,8 +1177,8 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 		set_pageblock_migratetype(page, start_type);
 }
 
-static int find_suitable_fallback(struct free_area *area, unsigned int order,
-					int migratetype, bool *can_steal)
+int find_suitable_fallback(struct free_area *area, unsigned int order,
+			int migratetype, bool only_stealable, bool *can_steal)
 {
 	int i;
 	int fallback_mt;
@@ -1198,7 +1198,11 @@ static int find_suitable_fallback(struct free_area *area, unsigned int order,
 		if (can_steal_fallback(order, migratetype))
 			*can_steal = true;
 
-		return i;
+		if (!only_stealable)
+			return i;
+
+		if (*can_steal)
+			return i;
 	}
 
 	return -1;
@@ -1220,7 +1224,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 				--current_order) {
 		area = &(zone->free_area[current_order]);
 		fallback_mt = find_suitable_fallback(area, current_order,
-				start_migratetype, &can_steal);
+				start_migratetype, false, &can_steal);
 		if (fallback_mt == -1)
 			continue;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
