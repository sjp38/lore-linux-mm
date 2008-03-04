Message-Id: <20080304225226.998477390@redhat.com>
References: <20080304225157.573336066@redhat.com>
Date: Tue, 04 Mar 2008 17:52:01 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 04/20] free swap space on swap-in/activation
Content-Disposition: inline; filename=rvr-00-linux-2.6-swapfree.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Free swap cache entries when swapping in pages if vm_swap_full()
[swap space > 1/2 used].  Uses new pagevec to reduce pressure
on locks.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

Index: linux-2.6.25-rc3-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/vmscan.c	2008-03-04 15:25:52.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/vmscan.c	2008-03-04 15:29:50.000000000 -0500
@@ -632,6 +632,9 @@ free_it:
 		continue;
 
 activate_locked:
+		/* Not a candidate for swapping, so reclaim swap space. */
+		if (PageSwapCache(page) && vm_swap_full())
+			remove_exclusive_swap_page(page);
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
@@ -1216,6 +1219,8 @@ static void shrink_active_list(unsigned 
 			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
 			pgmoved = 0;
 			spin_unlock_irq(&zone->lru_lock);
+			if (vm_swap_full())
+				pagevec_swap_free(&pvec);
 			__pagevec_release(&pvec);
 			spin_lock_irq(&zone->lru_lock);
 		}
@@ -1225,6 +1230,8 @@ static void shrink_active_list(unsigned 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	__count_vm_events(PGDEACTIVATE, pgdeactivate);
 	spin_unlock_irq(&zone->lru_lock);
+	if (vm_swap_full())
+		pagevec_swap_free(&pvec);
 
 	pagevec_release(&pvec);
 }
Index: linux-2.6.25-rc3-mm1/mm/swap.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/swap.c	2008-03-04 15:28:39.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/swap.c	2008-03-04 15:29:50.000000000 -0500
@@ -457,6 +457,24 @@ void pagevec_strip(struct pagevec *pvec)
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
Index: linux-2.6.25-rc3-mm1/include/linux/pagevec.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/include/linux/pagevec.h	2008-03-04 15:26:18.000000000 -0500
+++ linux-2.6.25-rc3-mm1/include/linux/pagevec.h	2008-03-04 15:29:50.000000000 -0500
@@ -25,6 +25,7 @@ void __pagevec_release_nonlru(struct pag
 void __pagevec_free(struct pagevec *pvec);
 void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
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
