From: Nick Piggin <nickpiggin@yahoo.com.au>
Message-Id: <20060108052420.2996.95996.sendpatchset@didi.local0.net>
In-Reply-To: <20060108052307.2996.39444.sendpatchset@didi.local0.net>
References: <20060108052307.2996.39444.sendpatchset@didi.local0.net>
Subject: [patch 2/4] mm: PageLRU no testset
Date: Sun, 8 Jan 2006 00:20:41 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

PG_lru is protected by zone->lru_lock. It does not need TestSet/TestClear
operations.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -657,8 +657,8 @@ static void shrink_cache(struct zone *zo
 		 */
 		while (!list_empty(&page_list)) {
 			page = lru_to_page(&page_list);
-			if (TestSetPageLRU(page))
-				BUG();
+			BUG_ON(PageLRU(page));
+			SetPageLRU(page);
 			list_del(&page->lru);
 			if (PageActive(page))
 				add_page_to_active_list(zone, page);
@@ -770,8 +770,8 @@ refill_inactive_zone(struct zone *zone, 
 	while (!list_empty(&l_inactive)) {
 		page = lru_to_page(&l_inactive);
 		prefetchw_prev_lru_page(page, &l_inactive, flags);
-		if (TestSetPageLRU(page))
-			BUG();
+		BUG_ON(PageLRU(page));
+		SetPageLRU(page);
 		if (!TestClearPageActive(page))
 			BUG();
 		list_move(&page->lru, &zone->inactive_list);
@@ -799,8 +799,8 @@ refill_inactive_zone(struct zone *zone, 
 	while (!list_empty(&l_active)) {
 		page = lru_to_page(&l_active);
 		prefetchw_prev_lru_page(page, &l_active, flags);
-		if (TestSetPageLRU(page))
-			BUG();
+		BUG_ON(PageLRU(page));
+		SetPageLRU(page);
 		BUG_ON(!PageActive(page));
 		list_move(&page->lru, &zone->active_list);
 		pgmoved++;
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c
+++ linux-2.6/mm/swap.c
@@ -185,8 +185,8 @@ void fastcall __page_cache_release(struc
 
 		struct zone *zone = page_zone(page);
 		spin_lock_irqsave(&zone->lru_lock, flags);
-		if (!TestClearPageLRU(page))
-			BUG();
+		BUG_ON(!PageLRU(page));
+		ClearPageLRU(page);
 		del_page_from_lru(zone, page);
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
@@ -230,8 +230,8 @@ void release_pages(struct page **pages, 
 				zone = pagezone;
 				spin_lock_irq(&zone->lru_lock);
 			}
-			if (!TestClearPageLRU(page))
-				BUG();
+			BUG_ON(!PageLRU(page));
+			ClearPageLRU(page);
 			del_page_from_lru(zone, page);
 		}
 		BUG_ON(page_count(page));
@@ -311,8 +311,8 @@ void __pagevec_lru_add(struct pagevec *p
 			zone = pagezone;
 			spin_lock_irq(&zone->lru_lock);
 		}
-		if (TestSetPageLRU(page))
-			BUG();
+		BUG_ON(PageLRU(page));
+		SetPageLRU(page);
 		add_page_to_inactive_list(zone, page);
 	}
 	if (zone)
@@ -338,8 +338,8 @@ void __pagevec_lru_add_active(struct pag
 			zone = pagezone;
 			spin_lock_irq(&zone->lru_lock);
 		}
-		if (TestSetPageLRU(page))
-			BUG();
+		BUG_ON(PageLRU(page));
+		SetPageLRU(page);
 		if (TestSetPageActive(page))
 			BUG();
 		add_page_to_active_list(zone, page);
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -244,10 +244,9 @@ extern void __mod_page_state_offset(unsi
 #define __ClearPageDirty(page)	__clear_bit(PG_dirty, &(page)->flags)
 #define TestClearPageDirty(page) test_and_clear_bit(PG_dirty, &(page)->flags)
 
-#define SetPageLRU(page)	set_bit(PG_lru, &(page)->flags)
 #define PageLRU(page)		test_bit(PG_lru, &(page)->flags)
-#define TestSetPageLRU(page)	test_and_set_bit(PG_lru, &(page)->flags)
-#define TestClearPageLRU(page)	test_and_clear_bit(PG_lru, &(page)->flags)
+#define SetPageLRU(page)	set_bit(PG_lru, &(page)->flags)
+#define ClearPageLRU(page)	clear_bit(PG_lru, &(page)->flags)
 
 #define PageActive(page)	test_bit(PG_active, &(page)->flags)
 #define SetPageActive(page)	set_bit(PG_active, &(page)->flags)
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
