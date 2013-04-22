Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 820CF6B0032
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 04:31:52 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 1/3] mm, page_alloc: clean-up __rmqueue_fallback()
Date: Mon, 22 Apr 2013 17:33:08 +0900
Message-Id: <1366619590-31526-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is just one code flow if two for-loops find proper area. So we don't
need to keep this logic in for-loops. Clean-up code to nderstand easily
what it does. It is for following patch.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8fcced7..a822389 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1013,10 +1013,10 @@ static void change_pageblock_range(struct page *pageblock_page,
 static inline struct page *
 __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 {
-	struct free_area * area;
+	struct free_area *area = NULL;
 	int current_order;
 	struct page *page;
-	int migratetype, i;
+	int migratetype = 0, i;
 
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1; current_order >= order;
@@ -1029,64 +1029,59 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 				break;
 
 			area = &(zone->free_area[current_order]);
-			if (list_empty(&area->free_list[migratetype]))
-				continue;
+			if (!list_empty(&area->free_list[migratetype]))
+				goto found;
+		}
+	}
 
-			page = list_entry(area->free_list[migratetype].next,
-					struct page, lru);
-			area->nr_free--;
+	return NULL;
 
-			/*
-			 * If breaking a large block of pages, move all free
-			 * pages to the preferred allocation list. If falling
-			 * back for a reclaimable kernel allocation, be more
-			 * aggressive about taking ownership of free pages
-			 *
-			 * On the other hand, never change migration
-			 * type of MIGRATE_CMA pageblocks nor move CMA
-			 * pages on different free lists. We don't
-			 * want unmovable pages to be allocated from
-			 * MIGRATE_CMA areas.
-			 */
-			if (!is_migrate_cma(migratetype) &&
-			    (unlikely(current_order >= pageblock_order / 2) ||
-			     start_migratetype == MIGRATE_RECLAIMABLE ||
-			     page_group_by_mobility_disabled)) {
-				int pages;
-				pages = move_freepages_block(zone, page,
-								start_migratetype);
-
-				/* Claim the whole block if over half of it is free */
-				if (pages >= (1 << (pageblock_order-1)) ||
-						page_group_by_mobility_disabled)
-					set_pageblock_migratetype(page,
-								start_migratetype);
-
-				migratetype = start_migratetype;
-			}
+found:
+	page = list_entry(area->free_list[migratetype].next, struct page, lru);
+	area->nr_free--;
 
-			/* Remove the page from the freelists */
-			list_del(&page->lru);
-			rmv_page_order(page);
+	/*
+	 * If breaking a large block of pages, move all free pages to the
+	 * preferred allocation list. If falling back for a reclaimable
+	 * kernel allocation, be more aggressive about taking ownership
+	 * of free pages
+	 *
+	 * On the other hand, never change migration type of MIGRATE_CMA
+	 * pageblocks nor move CMA pages on different free lists. We don't
+	 * want unmovable pages to be allocated from MIGRATE_CMA areas.
+	 */
+	if (!is_migrate_cma(migratetype) &&
+			(unlikely(current_order >= pageblock_order / 2) ||
+			 start_migratetype == MIGRATE_RECLAIMABLE ||
+			 page_group_by_mobility_disabled)) {
+		int pages;
+		pages = move_freepages_block(zone, page, start_migratetype);
+
+		/* Claim the whole block if over half of it is free */
+		if (pages >= (1 << (pageblock_order-1)) ||
+				page_group_by_mobility_disabled)
+			set_pageblock_migratetype(page, start_migratetype);
+
+		migratetype = start_migratetype;
+	}
 
-			/* Take ownership for orders >= pageblock_order */
-			if (current_order >= pageblock_order &&
-			    !is_migrate_cma(migratetype))
-				change_pageblock_range(page, current_order,
-							start_migratetype);
+	/* Remove the page from the freelists */
+	list_del(&page->lru);
+	rmv_page_order(page);
 
-			expand(zone, page, order, current_order, area,
-			       is_migrate_cma(migratetype)
-			     ? migratetype : start_migratetype);
+	/* Take ownership for orders >= pageblock_order */
+	if (current_order >= pageblock_order &&
+			!is_migrate_cma(migratetype))
+		change_pageblock_range(page, current_order, start_migratetype);
 
-			trace_mm_page_alloc_extfrag(page, order, current_order,
-				start_migratetype, migratetype);
+	expand(zone, page, order, current_order, area,
+			is_migrate_cma(migratetype)
+			? migratetype : start_migratetype);
 
-			return page;
-		}
-	}
+	trace_mm_page_alloc_extfrag(page, order, current_order,
+			start_migratetype, migratetype);
 
-	return NULL;
+	return page;
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
