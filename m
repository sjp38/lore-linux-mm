From: Nick Piggin <nickpiggin@yahoo.com.au>
Message-Id: <20060108052531.2996.20958.sendpatchset@didi.local0.net>
In-Reply-To: <20060108052307.2996.39444.sendpatchset@didi.local0.net>
References: <20060108052307.2996.39444.sendpatchset@didi.local0.net>
Subject: [patch 4/4] mm: less atomic ops
Date: Sun, 8 Jan 2006 00:21:52 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

In the page release paths, we can be sure that nobody will mess with our
page->flags because the refcount has dropped to 0. So no need for atomic
operations here.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -247,10 +247,12 @@ extern void __mod_page_state_offset(unsi
 #define PageLRU(page)		test_bit(PG_lru, &(page)->flags)
 #define SetPageLRU(page)	set_bit(PG_lru, &(page)->flags)
 #define ClearPageLRU(page)	clear_bit(PG_lru, &(page)->flags)
+#define __ClearPageLRU(page)	__clear_bit(PG_lru, &(page)->flags)
 
 #define PageActive(page)	test_bit(PG_active, &(page)->flags)
 #define SetPageActive(page)	set_bit(PG_active, &(page)->flags)
 #define ClearPageActive(page)	clear_bit(PG_active, &(page)->flags)
+#define __ClearPageActive(page)	__clear_bit(PG_active, &(page)->flags)
 
 #define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
 #define SetPageSlab(page)	set_bit(PG_slab, &(page)->flags)
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c
+++ linux-2.6/mm/swap.c
@@ -186,7 +186,7 @@ void fastcall __page_cache_release(struc
 		struct zone *zone = page_zone(page);
 		spin_lock_irqsave(&zone->lru_lock, flags);
 		BUG_ON(!PageLRU(page));
-		ClearPageLRU(page);
+		__ClearPageLRU(page);
 		del_page_from_lru(zone, page);
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
@@ -231,7 +231,7 @@ void release_pages(struct page **pages, 
 				spin_lock_irq(&zone->lru_lock);
 			}
 			BUG_ON(!PageLRU(page));
-			ClearPageLRU(page);
+			__ClearPageLRU(page);
 			del_page_from_lru(zone, page);
 		}
 		BUG_ON(page_count(page));
Index: linux-2.6/include/linux/mm_inline.h
===================================================================
--- linux-2.6.orig/include/linux/mm_inline.h
+++ linux-2.6/include/linux/mm_inline.h
@@ -32,7 +32,7 @@ del_page_from_lru(struct zone *zone, str
 {
 	list_del(&page->lru);
 	if (PageActive(page)) {
-		ClearPageActive(page);
+		__ClearPageActive(page);
 		zone->nr_active--;
 	} else {
 		zone->nr_inactive--;
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
