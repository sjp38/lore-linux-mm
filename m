Message-Id: <20080212003803.571820013@sgi.com>
References: <20080212003643.536643832@sgi.com>
Date: Mon, 11 Feb 2008 16:36:44 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 1/3] Eliminate the hot/cold distinction in the page allocator
Content-Disposition: inline; filename=hotcold_1
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

2.6.25-rc1 contains only a part of the patches that were done to get
rid of the cold/hot distinction. Performance tests showed that the list
operations added to simulate the hot/cold distinction using a single
list are worse than not having that distinction at all.

See the discussion and the tests that Mel Gorman performed with this patch at

http://marc.info/?t=119507025400001&r=1&w=2

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>

---
 include/linux/gfp.h |    3 +--
 mm/page_alloc.c     |   34 +++++++---------------------------
 mm/swap.c           |    2 +-
 3 files changed, 9 insertions(+), 30 deletions(-)

Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h	2008-02-11 15:53:12.000000000 -0800
+++ linux-2.6/include/linux/gfp.h	2008-02-11 16:18:36.000000000 -0800
@@ -214,8 +214,7 @@ extern unsigned long FASTCALL(get_zeroed
 
 extern void FASTCALL(__free_pages(struct page *page, unsigned int order));
 extern void FASTCALL(free_pages(unsigned long addr, unsigned int order));
-extern void FASTCALL(free_hot_page(struct page *page));
-extern void FASTCALL(free_cold_page(struct page *page));
+extern void FASTCALL(free_a_page(struct page *page));
 
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr),0)
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2008-02-08 13:22:14.000000000 -0800
+++ linux-2.6/mm/page_alloc.c	2008-02-11 16:18:36.000000000 -0800
@@ -975,7 +975,7 @@ void mark_free_pages(struct zone *zone)
 /*
  * Free a 0-order page
  */
-static void free_hot_cold_page(struct page *page, int cold)
+void free_a_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
@@ -995,10 +995,7 @@ static void free_hot_cold_page(struct pa
 	pcp = &zone_pcp(zone, get_cpu())->pcp;
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
-	if (cold)
-		list_add_tail(&page->lru, &pcp->list);
-	else
-		list_add(&page->lru, &pcp->list);
+	list_add(&page->lru, &pcp->list);
 	set_page_private(page, get_pageblock_migratetype(page));
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
@@ -1009,16 +1006,6 @@ static void free_hot_cold_page(struct pa
 	put_cpu();
 }
 
-void free_hot_page(struct page *page)
-{
-	free_hot_cold_page(page, 0);
-}
-	
-void free_cold_page(struct page *page)
-{
-	free_hot_cold_page(page, 1);
-}
-
 /*
  * split_page takes a non-compound higher-order page, and splits it into
  * n (1<<order) sub-pages: page[0..n]
@@ -1047,7 +1034,6 @@ static struct page *buffered_rmqueue(str
 {
 	unsigned long flags;
 	struct page *page;
-	int cold = !!(gfp_flags & __GFP_COLD);
 	int cpu;
 	int migratetype = allocflags_to_migratetype(gfp_flags);
 
@@ -1066,15 +1052,9 @@ again:
 		}
 
 		/* Find a page of the appropriate migrate type */
-		if (cold) {
-			list_for_each_entry_reverse(page, &pcp->list, lru)
-				if (page_private(page) == migratetype)
-					break;
-		} else {
-			list_for_each_entry(page, &pcp->list, lru)
-				if (page_private(page) == migratetype)
-					break;
-		}
+		list_for_each_entry(page, &pcp->list, lru)
+			if (page_private(page) == migratetype)
+				break;
 
 		/* Allocate more to the pcp list if necessary */
 		if (unlikely(&page->lru == &pcp->list)) {
@@ -1677,14 +1657,14 @@ void __pagevec_free(struct pagevec *pvec
 	int i = pagevec_count(pvec);
 
 	while (--i >= 0)
-		free_hot_cold_page(pvec->pages[i], pvec->cold);
+		free_a_page(pvec->pages[i]);
 }
 
 void __free_pages(struct page *page, unsigned int order)
 {
 	if (put_page_testzero(page)) {
 		if (order == 0)
-			free_hot_page(page);
+			free_a_page(page);
 		else
 			__free_pages_ok(page, order);
 	}
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2008-02-07 19:07:05.000000000 -0800
+++ linux-2.6/mm/swap.c	2008-02-11 16:18:36.000000000 -0800
@@ -54,7 +54,7 @@ static void __page_cache_release(struct 
 		del_page_from_lru(zone, page);
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
-	free_hot_page(page);
+	free_a_page(page);
 }
 
 static void put_compound_page(struct page *page)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
