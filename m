Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 60AFA280250
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 04:32:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 123so5705597wmb.7
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 01:32:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rr15si21354154wjb.65.2016.10.07.01.32.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Oct 2016 01:32:21 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 5/4] mm, page_alloc: split smallest stolen page in fallback
Date: Fri,  7 Oct 2016 10:32:13 +0200
Message-Id: <20161007083213.3549-1-vbabka@suse.cz>
In-Reply-To: <20160929210548.26196-1-vbabka@suse.cz>
References: <20160929210548.26196-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

The __rmqueue_fallback() is called when there's no free page of requested
migratetype, and we need to steal from a different one. There are various
heuristics to make this event infrequent and reduce permanent fragmentation.
The main one is to try stealing from a pageblock that has the most free pages,
and possibly steal them all at once and convert the whole pageblock. Precise
searching for such pageblock would be expensive, so instead the heuristics
walks the free lists from MAX_ORDER down to requested order and assumes that
the block with highest-order free page is likely to also have the most free
pages in total.

So the chances are that together with the highest-order page, we steal also
pages of lower orders from the same block. But then we still split the highest
order page. This is wasteful and can contribute to fragmentation instead of
avoiding it.

This patch thus changes __rmqueue_fallback() to only steal the pages(s) and
put them on a freelist of the requested migratetype, and only report whether
it was successful. Then we pick the smallest page with __rmqueue_smallest().
This is all under zone lock, so nobody can steal it from us in the process.
This should reduce fragmentation due to fallbacks. At worst we are only
stealing a single highest-order page and waste some cycles by moving it between
lists and then removing it, but fallback is not exactly hot path so that should
not be a concern. As a side benefit the patch removes some duplicate code by
reusing __rmqueue_smallest().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 50 ++++++++++++++++++++++++++------------------------
 1 file changed, 26 insertions(+), 24 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8a8ef9ebeb4d..2ccd80079d22 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1957,14 +1957,24 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
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
 
@@ -2108,8 +2118,13 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
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
@@ -2130,32 +2145,16 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 
 		page = list_first_entry(&area->free_list[fallback_mt],
 						struct page, lru);
-		if (can_steal)
-			steal_suitable_fallback(zone, page, start_migratetype);
-
-		/* Remove the page from the freelists */
-		area->nr_free--;
-		list_del(&page->lru);
-		rmv_page_order(page);
 
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
@@ -2167,13 +2166,16 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 {
 	struct page *page;
 
+retry:
 	page = __rmqueue_smallest(zone, order, migratetype);
 	if (unlikely(!page)) {
 		if (migratetype == MIGRATE_MOVABLE)
 			page = __rmqueue_cma_fallback(zone, order);
 
-		if (!page && allow_fallback)
-			page = __rmqueue_fallback(zone, order, migratetype);
+		if (!page && allow_fallback) {
+			if (__rmqueue_fallback(zone, order, migratetype))
+				goto retry;
+		}
 	}
 
 	trace_mm_page_alloc_zone_locked(page, order, migratetype);
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
