Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2907E6B0392
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:23:58 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id an2so11044534wjc.3
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:23:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g29si2941593wra.149.2017.02.10.09.23.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 09:23:52 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 03/10] mm, page_alloc: split smallest stolen page in fallback
Date: Fri, 10 Feb 2017 18:23:36 +0100
Message-Id: <20170210172343.30283-4-vbabka@suse.cz>
In-Reply-To: <20170210172343.30283-1-vbabka@suse.cz>
References: <20170210172343.30283-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

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
---
 mm/page_alloc.c | 48 ++++++++++++++++++++++++------------------------
 1 file changed, 24 insertions(+), 24 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440e3ae2..314e6b9ddbc4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1960,14 +1960,24 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
  * use it's pages as requested migratetype in the future.
  */
 static void steal_suitable_fallback(struct zone *zone, struct page *page,
-							  int start_type)
+					 int start_type, bool whole_block)
 {
 	unsigned int current_order = page_order(page);
+	struct free_area *area;
 	int pages;
 
 	/* Take ownership for orders >= pageblock_order */
 	if (current_order >= pageblock_order) {
 		change_pageblock_range(page, current_order, start_type);
+		area = &zone->free_area[current_order];
+		list_move(&page->lru, &area->free_list[start_type]);
+		return;
+	}
+
+	/* We are not allowed to try stealing from the whole block */
+	if (!whole_block) {
+		area = &zone->free_area[current_order];
+		list_move(&page->lru, &area->free_list[start_type]);
 		return;
 	}
 
@@ -2111,8 +2121,13 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 	}
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
@@ -2133,32 +2148,16 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 
 		page = list_first_entry(&area->free_list[fallback_mt],
 						struct page, lru);
-		if (can_steal)
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
+		steal_suitable_fallback(zone, page, start_migratetype, can_steal);
 
 		trace_mm_page_alloc_extfrag(page, order, current_order,
 			start_migratetype, fallback_mt);
 
-		return page;
+		return true;
 	}
 
-	return NULL;
+	return false;
 }
 
 /*
@@ -2170,13 +2169,14 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
