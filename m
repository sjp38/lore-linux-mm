Message-ID: <45D63445.5070005@redhat.com>
Date: Fri, 16 Feb 2007 17:46:29 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: [PATCH] free swap space when (re)activating page
Content-Type: multipart/mixed;
 boundary="------------000701030707080707010708"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000701030707080707010708
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

The attached patch does what I described in the other thread, it
makes the pageout code free swap space when swap is getting full,
by taking away the swap space from pages that get moved onto or
back onto the active list.

In some tests on a system with 2GB RAM and 1GB swap, it kept the
free swap at 500MB for a 2.3GB qsbench, while without the patch
over 950MB of swap was in use all of the time.

This should give kswapd more flexibility in what to swap out.

What do you think?

Signed-off-by: Rik van Riel <riel@redhat.com>

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--------------000701030707080707010708
Content-Type: text/x-patch;
 name="linux-2.6-swapfree.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6-swapfree.patch"

--- linux-2.6.20.x86_64/mm/vmscan.c.swapfull	2007-02-16 06:47:02.000000000 -0500
+++ linux-2.6.20.x86_64/mm/vmscan.c	2007-02-16 07:03:30.000000000 -0500
@@ -587,6 +587,9 @@ free_it:
 		continue;
 
 activate_locked:
+		/* Not a candidate for swapping, so reclaim swap space. */
+		if (PageSwapCache(page) && vm_swap_full())
+			remove_exclusive_swap_page(page);
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
@@ -875,6 +878,11 @@ force_reclaim_mapped:
 		pagevec_strip(&pvec);
 		spin_lock_irq(&zone->lru_lock);
 	}
+	if (vm_swap_full()) {
+		spin_unlock_irq(&zone->lru_lock);
+		pagevec_swap_free(&pvec);
+		spin_lock_irq(&zone->lru_lock);
+	}
 
 	pgmoved = 0;
 	while (!list_empty(&l_active)) {
--- linux-2.6.20.x86_64/mm/swap.c.swapfull	2007-02-16 07:09:38.000000000 -0500
+++ linux-2.6.20.x86_64/mm/swap.c	2007-02-16 07:05:00.000000000 -0500
@@ -420,6 +420,24 @@ void pagevec_strip(struct pagevec *pvec)
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
--- linux-2.6.20.x86_64/include/linux/pagevec.h.swapfull	2007-02-16 07:06:29.000000000 -0500
+++ linux-2.6.20.x86_64/include/linux/pagevec.h	2007-02-16 07:06:41.000000000 -0500
@@ -26,6 +26,7 @@ void __pagevec_free(struct pagevec *pvec
 void __pagevec_lru_add(struct pagevec *pvec);
 void __pagevec_lru_add_active(struct pagevec *pvec);
 void pagevec_strip(struct pagevec *pvec);
+void pagevec_swap_free(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,

--------------000701030707080707010708--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
