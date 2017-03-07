Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B05E36B0391
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 08:16:30 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u9so1223114wme.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:16:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v110si25435761wrb.289.2017.03.07.05.16.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 05:16:23 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 3/8] mm, page_alloc: split smallest stolen page in fallback
Date: Tue,  7 Mar 2017 14:15:40 +0100
Message-Id: <20170307131545.28577-4-vbabka@suse.cz>
In-Reply-To: <20170307131545.28577-1-vbabka@suse.cz>
References: <20170307131545.28577-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

The __rmqueue_fallback() function is called when there's no free page of
requested migratetype, and we need to steal from a different one. There are
various heuristics to make this event infrequent and reduce permanent
fragmentation. The main one is to try stealing from a pageblock that has the
most free pages, and possibly steal them all at once and convert the whole
pageblock. Precise searching for such pageblock would be expensive, so instead
the heuristics walks the free lists from MAX_ORDER down to requested order and
assumes that the block with highest-order free page is likely to also have the
most free pages in total.

Chances are that together with the highest-order page, we steal also pages of
lower orders from the same block. But then we still split the highest order
page. This is wasteful and can contribute to fragmentation instead of avoiding
it.

This patch thus changes __rmqueue_fallback() to just steal the page(s) and put
them on the freelist of the requested migratetype, and only report whether it
was successful. Then we pick (and eventually split) the smallest page with
__rmqueue_smallest().  This all happens under zone lock, so nobody can steal it
from us in the process. This should reduce fragmentation due to fallbacks. At
worst we are only stealing a single highest-order page and waste some cycles by
moving it between lists and then removing it, but fallback is not exactly hot
path so that should not be a concern. As a side benefit the patch removes some
duplicate code by reusing __rmqueue_smallest().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c | 59 +++++++++++++++++++++++++++++++++------------------------
 1 file changed, 34 insertions(+), 25 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5238b87aec91..eda7fedf6378 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1952,23 +1952,41 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
  * use it's pages as requested migratetype in the future.
  */
 static void steal_suitable_fallback(struct zone *zone, struct page *page,
-							  int start_type)
+					int start_type, bool whole_block)
 {
 	unsigned int current_order = page_order(page);
+	struct free_area *area;
 	int pages;
 
+	/*
+	 * This can happen due to races and we want to prevent broken
+	 * highatomic accounting.
+	 */
+	if (is_migrate_highatomic_page(page))
+		goto single_page;
+
 	/* Take ownership for orders >= pageblock_order */
 	if (current_order >= pageblock_order) {
 		change_pageblock_range(page, current_order, start_type);
-		return;
+		goto single_page;
 	}
 
+	/* We are not allowed to try stealing from the whole block */
+	if (!whole_block)
+		goto single_page;
+
 	pages = move_freepages_block(zone, page, start_type);
 
 	/* Claim the whole block if over half of it is free */
 	if (pages >= (1 << (pageblock_order-1)) ||
 			page_group_by_mobility_disabled)
 		set_pageblock_migratetype(page, start_type);
+
+	return;
+
+single_page:
+	area = &zone->free_area[current_order];
+	list_move(&page->lru, &area->free_list[start_type]);
 }
 
 /*
@@ -2127,8 +2145,13 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 	return false;
 }
 
-/* Remove an element from the buddy allocator from the fallback list */
-static inline struct page *
+/*
+ * Try finding a free buddy page on the fallback list and put it on the free
+ * list of requested migratetype, possibly along with other pages from the same
+ * block, depending on fragmentation avoidance heuristics. Returns true if
+ * fallback was found so that __rmqueue_smallest() can grab it.
+ */
+static inline bool
 __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 {
 	struct free_area *area;
@@ -2149,32 +2172,17 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 
 		page = list_first_entry(&area->free_list[fallback_mt],
 						struct page, lru);
-		if (can_steal && !is_migrate_highatomic_page(page))
-			steal_suitable_fallback(zone, page, start_migratetype);
 
-		/* Remove the page from the freelists */
-		area->nr_free--;
-		list_del(&page->lru);
-		rmv_page_order(page);
-
-		expand(zone, page, order, current_order, area,
-					start_migratetype);
-		/*
-		 * The pcppage_migratetype may differ from pageblock's
-		 * migratetype depending on the decisions in
-		 * find_suitable_fallback(). This is OK as long as it does not
-		 * differ for MIGRATE_CMA pageblocks. Those can be used as
-		 * fallback only via special __rmqueue_cma_fallback() function
-		 */
-		set_pcppage_migratetype(page, start_migratetype);
+		steal_suitable_fallback(zone, page, start_migratetype,
+								can_steal);
 
 		trace_mm_page_alloc_extfrag(page, order, current_order,
 			start_migratetype, fallback_mt);
 
-		return page;
+		return true;
 	}
 
-	return NULL;
+	return false;
 }
 
 /*
@@ -2186,13 +2194,14 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 {
 	struct page *page;
 
+retry:
 	page = __rmqueue_smallest(zone, order, migratetype);
 	if (unlikely(!page)) {
 		if (migratetype == MIGRATE_MOVABLE)
 			page = __rmqueue_cma_fallback(zone, order);
 
-		if (!page)
-			page = __rmqueue_fallback(zone, order, migratetype);
+		if (!page && __rmqueue_fallback(zone, order, migratetype))
+			goto retry;
 	}
 
 	trace_mm_page_alloc_zone_locked(page, order, migratetype);
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
