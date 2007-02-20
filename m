Message-ID: <45DB51E3.8090909@redhat.com>
Date: Tue, 20 Feb 2007 14:54:11 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] free swap space when (re)activating page
References: <45D63445.5070005@redhat.com> <Pine.LNX.4.64.0702192048150.9934@schroedinger.engr.sgi.com> <45DAF794.2000209@redhat.com> <Pine.LNX.4.64.0702200833460.13913@schroedinger.engr.sgi.com> <45DB25E1.7030504@redhat.com> <Pine.LNX.4.64.0702201015590.14497@schroedinger.engr.sgi.com> <45DB4C87.6050809@redhat.com>
In-Reply-To: <45DB4C87.6050809@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------040204040601060701030304"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040204040601060701030304
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Rik van Riel wrote:

> ... because I think this is what my patch does :)

Never mind, I see it now.

The attached patch should be correct.

Btw, why do we not call pagevec_strip on the pages on l_active?
I assume we want to reclaim their buffer heads, too...

-- 
All Rights Reversed

--------------040204040601060701030304
Content-Type: text/x-patch;
 name="linux-2.6-swapfree.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6-swapfree.patch"

--- linux-2.6.20.noarch/mm/vmscan.c.swapfree	2007-02-20 06:44:13.000000000 -0500
+++ linux-2.6.20.noarch/mm/vmscan.c	2007-02-20 06:54:10.000000000 -0500
@@ -587,6 +587,9 @@ free_it:
 		continue;
 
 activate_locked:
+		/* Not a candidate for swapping, so reclaim swap space. */
+		if (PageSwapCache(page) && vm_swap_full())
+			remove_exclusive_swap_page(page);
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
@@ -889,6 +892,8 @@ force_reclaim_mapped:
 			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
 			pgmoved = 0;
 			spin_unlock_irq(&zone->lru_lock);
+			if (vm_swap_full())
+				pagevec_swap_free(&pvec);
 			__pagevec_release(&pvec);
 			spin_lock_irq(&zone->lru_lock);
 		}
@@ -899,6 +904,8 @@ force_reclaim_mapped:
 	__count_vm_events(PGDEACTIVATE, pgdeactivate);
 	spin_unlock_irq(&zone->lru_lock);
 
+	if (vm_swap_full())
+		pagevec_swap_free(&pvec);
 	pagevec_release(&pvec);
 }
 
--- linux-2.6.20.noarch/mm/swap.c.swapfree	2007-02-04 13:44:54.000000000 -0500
+++ linux-2.6.20.noarch/mm/swap.c	2007-02-20 06:44:17.000000000 -0500
@@ -420,6 +420,26 @@ void pagevec_strip(struct pagevec *pvec)
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
+			if (printk_ratelimit())
+				printk("kswapd freed a swap space\n");
+		}
+	}
+}
+
 /**
  * pagevec_lookup - gang pagecache lookup
  * @pvec:	Where the resulting pages are placed
--- linux-2.6.20.noarch/include/linux/pagevec.h.swapfree	2007-02-04 13:44:54.000000000 -0500
+++ linux-2.6.20.noarch/include/linux/pagevec.h	2007-02-20 06:44:17.000000000 -0500
@@ -26,6 +26,7 @@ void __pagevec_free(struct pagevec *pvec
 void __pagevec_lru_add(struct pagevec *pvec);
 void __pagevec_lru_add_active(struct pagevec *pvec);
 void pagevec_strip(struct pagevec *pvec);
+void pagevec_swap_free(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,

--------------040204040601060701030304--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
