Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A4EB36B004F
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 05:49:50 -0400 (EDT)
Date: Wed, 29 Jul 2009 10:49:52 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] page-allocator: Change migratetype for all pageblocks
	within a high-order page during __rmqueue_fallback
Message-ID: <20090729094951.GA15102@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: apw@shadowen.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When there are no pages of a target migratetype free, the page allocator
selects a high-order block of another migratetype to allocate from. When
the order of the page taken is greater than pageblock_order, all pageblocks
within that high-order page should change migratetype so that pages are
later freed to the correct free-lists.

The current behaviour is that pageblocks change migratetype if the order
being split matches the pageblock_order.  When pageblock_order < MAX_ORDER-1,
ownership is not changing correct and pages are being later freed to the
incorrect list and this impacts fragmentation avoidance.

This patch changes all pageblocks within the high-order page being split to
the correct migratetype. Without the patch, allocation success rates for
hugepages under stress were about 59% of physical memory on x86-64. With
the patch applied, this goes up to 65%.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 mm/page_alloc.c |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index caa9268..c158466 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -783,6 +783,17 @@ static int move_freepages_block(struct zone *zone, struct page *page,
 	return move_freepages(zone, start_page, end_page, migratetype);
 }
 
+static void change_pageblock_range(struct page *pageblock_page,
+					int start_order, int migratetype)
+{
+	int nr_pageblocks = 1 << (MAX_ORDER - 1 - start_order);
+
+	while (nr_pageblocks--) {
+		set_pageblock_migratetype(pageblock_page, migratetype);
+		pageblock_page += pageblock_nr_pages;
+	}
+}
+
 /* Remove an element from the buddy allocator from the fallback list */
 static inline struct page *
 __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
@@ -834,8 +845,9 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			list_del(&page->lru);
 			rmv_page_order(page);
 
-			if (current_order == pageblock_order)
-				set_pageblock_migratetype(page,
+			/* Take ownership for orders >= pageblock_order */
+			if (current_order >= pageblock_order)
+				change_pageblock_range(page, current_order,
 							start_migratetype);
 
 			expand(zone, page, order, current_order, area, migratetype);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
