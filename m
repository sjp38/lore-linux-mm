Message-Id: <20071218211548.994733453@redhat.com>
References: <20071218211539.250334036@redhat.com>
Date: Tue, 18 Dec 2007 16:15:43 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 04/20] free swap space on swap-in/activation
Content-Disposition: inline; filename=rvr-00-linux-2.6-swapfree.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

+ lts' convert anon_vma list lock to reader/write lock patch
+ Nick Piggin's move and rework isolate_lru_page() patch

Free swap cache entries when swapping in pages if vm_swap_full()
[swap space > 1/2 used?].  Uses new pagevec to reduce pressure
on locks.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

Index: linux-2.6.24-rc3-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc3-mm2.orig/mm/vmscan.c
+++ linux-2.6.24-rc3-mm2/mm/vmscan.c
@@ -632,6 +632,9 @@ free_it:
 		continue;
 
 activate_locked:
+		/* Not a candidate for swapping, so reclaim swap space. */
+		if (PageSwapCache(page) && vm_swap_full())
+			remove_exclusive_swap_page(page);
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
@@ -1213,6 +1216,8 @@ static void shrink_active_list(unsigned 
 			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
 			pgmoved = 0;
 			spin_unlock_irq(&zone->lru_lock);
+			if (vm_swap_full())
+				pagevec_swap_free(&pvec);
 			__pagevec_release(&pvec);
 			spin_lock_irq(&zone->lru_lock);
 		}
@@ -1222,6 +1227,8 @@ static void shrink_active_list(unsigned 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	__count_vm_events(PGDEACTIVATE, pgdeactivate);
 	spin_unlock_irq(&zone->lru_lock);
+	if (vm_swap_full())
+		pagevec_swap_free(&pvec);
 
 	pagevec_release(&pvec);
 }
Index: linux-2.6.24-rc3-mm2/mm/swap.c
===================================================================
--- linux-2.6.24-rc3-mm2.orig/mm/swap.c
+++ linux-2.6.24-rc3-mm2/mm/swap.c
@@ -465,6 +465,24 @@ void pagevec_strip(struct pagevec *pvec)
 	}
 }
 
+/*
+ * Try to free swap space from the pages in a pagevec
+ */
+void pagevec_swap_free(struct pagevec *pvec)
+{
+	int i;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+
+		if (PageSwapCache(page) && !TestSetPageLocked(page)) {
+			if (PageSwapCache(page))
+				remove_exclusive_swap_page(page);
+			unlock_page(page);
+		}
+	}
+}
+
 /**
  * pagevec_lookup - gang pagecache lookup
  * @pvec:	Where the resulting pages are placed
Index: linux-2.6.24-rc3-mm2/include/linux/pagevec.h
===================================================================
--- linux-2.6.24-rc3-mm2.orig/include/linux/pagevec.h
+++ linux-2.6.24-rc3-mm2/include/linux/pagevec.h
@@ -26,6 +26,7 @@ void __pagevec_free(struct pagevec *pvec
 void __pagevec_lru_add(struct pagevec *pvec);
 void __pagevec_lru_add_active(struct pagevec *pvec);
 void pagevec_strip(struct pagevec *pvec);
+void pagevec_swap_free(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
