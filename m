Date: Thu, 10 Jan 2008 20:13:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Eliminate the hot/cold distinction in the page allocator
Message-ID: <Pine.LNX.4.64.0801102011340.23992@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This is on top of the patch that adds cold pages to the end of the pcp
list. It drops all the distinctions between hot and cold pages which
improves performance. See the discussion and the tests that Mel Gorman
performed with this patch at

http://marc.info/?t=119507025400001&r=1&w=2

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>

---
 include/linux/gfp.h |    3 +--
 mm/page_alloc.c     |   34 +++++++---------------------------
 mm/swap.c           |    2 +-
 3 files changed, 9 insertions(+), 30 deletions(-)

Index: linux-2.6.24-rc6-mm1/include/linux/gfp.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/gfp.h	2008-01-10 20:03:24.965516788 -0800
+++ linux-2.6.24-rc6-mm1/include/linux/gfp.h	2008-01-10 20:08:12.117206294 -0800
@@ -220,8 +220,7 @@ extern unsigned long FASTCALL(get_zeroed
 
 extern void FASTCALL(__free_pages(struct page *page, unsigned int order));
 extern void FASTCALL(free_pages(unsigned long addr, unsigned int order));
-extern void FASTCALL(free_hot_page(struct page *page));
-extern void FASTCALL(free_cold_page(struct page *page));
+extern void FASTCALL(free_a_page(struct page *page));
 
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr),0)
Index: linux-2.6.24-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/page_alloc.c	2008-01-10 20:03:24.977516887 -0800
+++ linux-2.6.24-rc6-mm1/mm/page_alloc.c	2008-01-10 20:03:28.169508169 -0800
@@ -993,7 +993,7 @@ void mark_free_pages(struct zone *zone)
 /*
  * Free a 0-order page
  */
-static void free_hot_cold_page(struct page *page, int cold)
+void free_a_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
@@ -1013,10 +1013,7 @@ static void free_hot_cold_page(struct pa
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
@@ -1027,16 +1024,6 @@ static void free_hot_cold_page(struct pa
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
@@ -1065,7 +1052,6 @@ static struct page *buffered_rmqueue(str
 {
 	unsigned long flags;
 	struct page *page;
-	int cold = !!(gfp_flags & __GFP_COLD);
 	int cpu;
 	int migratetype = allocflags_to_migratetype(gfp_flags);
 
@@ -1084,15 +1070,9 @@ again:
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
@@ -1755,14 +1735,14 @@ void __pagevec_free(struct pagevec *pvec
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
Index: linux-2.6.24-rc6-mm1/mm/swap.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/swap.c	2008-01-10 20:07:59.497196870 -0800
+++ linux-2.6.24-rc6-mm1/mm/swap.c	2008-01-10 20:08:12.117206294 -0800
@@ -54,7 +54,7 @@ static void __page_cache_release(struct 
 		del_page_from_lru(zone, page);
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
-	free_hot_page(page);
+	free_a_page(page);
 }
 
 static void put_compound_page(struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
