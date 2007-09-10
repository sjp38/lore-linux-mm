From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070910112352.3097.43645.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
References: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 11/13] Bias the placement of kernel pages at lower pfns
Date: Mon, 10 Sep 2007 12:23:52 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Subject: Bias the placement of kernel pages at lower pfns
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch chooses blocks with lower PFNs when placing kernel allocations.
This is particularly important during fallback in low memory situations to
stop unmovable pages being placed throughout the entire address space.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-010-bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks/mm/page_alloc.c linux-2.6.23-rc5-011-bias-the-placement-of-kernel-pages-at-lower-pfns/mm/page_alloc.c
--- linux-2.6.23-rc5-010-bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks/mm/page_alloc.c	2007-09-02 16:22:04.000000000 +0100
+++ linux-2.6.23-rc5-011-bias-the-placement-of-kernel-pages-at-lower-pfns/mm/page_alloc.c	2007-09-02 16:22:27.000000000 +0100
@@ -768,6 +768,23 @@ int move_freepages_block(struct zone *zo
 	return move_freepages(zone, start_page, end_page, migratetype);
 }
 
+/* Return the page with the lowest PFN in the list */
+static struct page *min_page(struct list_head *list)
+{
+	unsigned long min_pfn = -1UL;
+	struct page *min_page = NULL, *page;;
+
+	list_for_each_entry(page, list, lru) {
+		unsigned long pfn = page_to_pfn(page);
+		if (pfn < min_pfn) {
+			min_pfn = pfn;
+			min_page = page;
+		}
+	}
+
+	return min_page;
+}
+
 /* Remove an element from the buddy allocator from the fallback list */
 static struct page *__rmqueue_fallback(struct zone *zone, int order,
 						int start_migratetype)
@@ -791,8 +808,11 @@ static struct page *__rmqueue_fallback(s
 			if (list_empty(&area->free_list[migratetype]))
 				continue;
 
+			/* Bias kernel allocations towards low pfns */
 			page = list_entry(area->free_list[migratetype].next,
 					struct page, lru);
+			if (unlikely(start_migratetype != MIGRATE_MOVABLE))
+				page = min_page(&area->free_list[migratetype]);
 			area->nr_free--;
 
 			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
