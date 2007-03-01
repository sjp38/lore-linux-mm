From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070301100510.29753.93334.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
References: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 8/12] Move free pages between lists on steal
Date: Thu,  1 Mar 2007 10:05:10 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When a fallback occurs, there will be free pages for one allocation type
stored on the list for another. When a large steal occurs, this patch will
move all the free pages within one list to the other.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 page_alloc.c |   65 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 62 insertions(+), 3 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-007_drainpercpu/mm/page_alloc.c linux-2.6.20-mm2-008_movefree/mm/page_alloc.c
--- linux-2.6.20-mm2-007_drainpercpu/mm/page_alloc.c	2007-02-20 18:35:52.000000000 +0000
+++ linux-2.6.20-mm2-008_movefree/mm/page_alloc.c	2007-02-20 18:38:07.000000000 +0000
@@ -682,6 +682,63 @@ static int fallbacks[MIGRATE_TYPES][MIGR
 	[MIGRATE_MOVABLE]   = { MIGRATE_UNMOVABLE },
 };
 
+/*
+ * Move the free pages in a range to the free lists of the requested type.
+ * Note that start_page and end_pages are not aligned in a MAX_ORDER_NR_PAGES
+ * boundary. If alignment is required, use move_freepages_block()
+ */
+int move_freepages(struct zone *zone,
+			struct page *start_page, struct page *end_page,
+			int migratetype)
+{
+	struct page *page;
+	unsigned long order;
+	int blocks_moved = 0;
+
+	BUG_ON(page_zone(start_page) != page_zone(end_page));
+
+	for (page = start_page; page < end_page;) {
+		if (!PageBuddy(page)) {
+			page++;
+			continue;
+		}
+#ifdef CONFIG_HOLES_IN_ZONE
+		if (!pfn_valid(page_to_pfn(page))) {
+			page++;
+			continue;
+		}
+#endif
+
+		order = page_order(page);
+		list_del(&page->lru);
+		list_add(&page->lru,
+			&zone->free_area[order].free_list[migratetype]);
+		page += 1 << order;
+		blocks_moved++;
+	}
+
+	return blocks_moved;
+}
+
+int move_freepages_block(struct zone *zone, struct page *page, int migratetype)
+{
+	unsigned long start_pfn;
+	struct page *start_page, *end_page;
+
+	start_pfn = page_to_pfn(page);
+	start_pfn = start_pfn & ~(MAX_ORDER_NR_PAGES-1);
+	start_page = pfn_to_page(start_pfn);
+	end_page = start_page + MAX_ORDER_NR_PAGES;
+
+	/* Do not cross zone boundaries */
+	if (page_zone(page) != page_zone(start_page))
+		start_page = page;
+	if (page_zone(page) != page_zone(end_page))
+		return 0;
+
+	return move_freepages(zone, start_page, end_page, migratetype);
+}
+
 /* Remove an element from the buddy allocator from the fallback list */
 static struct page *__rmqueue_fallback(struct zone *zone, int order,
 						int start_migratetype)
@@ -706,11 +763,13 @@ static struct page *__rmqueue_fallback(s
 			area->nr_free--;
 
 			/*
-			 * If breaking a large block of pages, place the buddies
-			 * on the preferred allocation list
+			 * If breaking a large block of pages, move all free
+			 * pages to the preferred allocation list
 			 */
-			if (unlikely(current_order >= MAX_ORDER / 2))
+			if (unlikely(current_order >= MAX_ORDER / 2)) {
 				migratetype = start_migratetype;
+				move_freepages_block(zone, page, migratetype);
+			}
 
 			/* Remove the page from the freelists */
 			list_del(&page->lru);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
