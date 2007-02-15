From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070215012459.5343.72021.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 2/7] Add PageMlocked() page state bit and lru infrastructure
Date: Wed, 14 Feb 2007 17:24:59 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Add PageMlocked() infrastructure

This adds a new PG_mlocked to mark pages that were taken off the LRU
because they have a reference from a VM_LOCKED vma.

(Yes, we still have 4 free page flag bits.... BITS_PER_LONG-FLAGS_RESERVED =
32 - 9 = 23 page flags).

Also add pagevec handling for returning mlocked pages to the LRU.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20/include/linux/page-flags.h
===================================================================
--- linux-2.6.20.orig/include/linux/page-flags.h	2007-02-14 15:47:13.000000000 -0800
+++ linux-2.6.20/include/linux/page-flags.h	2007-02-14 16:00:40.000000000 -0800
@@ -91,6 +91,7 @@
 #define PG_nosave_free		18	/* Used for system suspend/resume */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
+#define PG_mlocked		20	/* Page is mlocked */
 
 #if (BITS_PER_LONG > 32)
 /*
@@ -251,6 +252,16 @@
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+/*
+ * PageMlocked set means that the page was taken off the LRU because
+ * a VM_LOCKED vma does exist. PageMlocked must be cleared before a
+ * page is put back onto the LRU. PageMlocked is only modified
+ * under the zone->lru_lock like PageLRU.
+ */
+#define PageMlocked(page)	test_bit(PG_mlocked, &(page)->flags)
+#define SetPageMlocked(page)	set_bit(PG_mlocked, &(page)->flags)
+#define ClearPageMlocked(page)	clear_bit(PG_mlocked, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 extern void cancel_dirty_page(struct page *page, unsigned int account_size);
Index: linux-2.6.20/include/linux/pagevec.h
===================================================================
--- linux-2.6.20.orig/include/linux/pagevec.h	2007-02-14 15:47:13.000000000 -0800
+++ linux-2.6.20/include/linux/pagevec.h	2007-02-14 16:00:40.000000000 -0800
@@ -25,6 +25,7 @@
 void __pagevec_free(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec);
 void __pagevec_lru_add_active(struct pagevec *pvec);
+void __pagevec_lru_add_mlock(struct pagevec *pvec);
 void pagevec_strip(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
Index: linux-2.6.20/include/linux/swap.h
===================================================================
--- linux-2.6.20.orig/include/linux/swap.h	2007-02-14 15:47:13.000000000 -0800
+++ linux-2.6.20/include/linux/swap.h	2007-02-14 16:00:40.000000000 -0800
@@ -182,6 +182,7 @@
 extern void FASTCALL(lru_cache_add_active(struct page *));
 extern void FASTCALL(activate_page(struct page *));
 extern void FASTCALL(mark_page_accessed(struct page *));
+extern void FASTCALL(lru_cache_add_mlock(struct page *));
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
 extern int rotate_reclaimable_page(struct page *page);
Index: linux-2.6.20/mm/swap.c
===================================================================
--- linux-2.6.20.orig/mm/swap.c	2007-02-14 15:47:13.000000000 -0800
+++ linux-2.6.20/mm/swap.c	2007-02-14 17:08:07.000000000 -0800
@@ -176,6 +176,7 @@
  */
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
 static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_mlock_pvecs) = { 0, };
 
 void fastcall lru_cache_add(struct page *page)
 {
@@ -197,6 +198,16 @@
 	put_cpu_var(lru_add_active_pvecs);
 }
 
+void fastcall lru_cache_add_mlock(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_mlock_pvecs);
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		__pagevec_lru_add_mlock(pvec);
+	put_cpu_var(lru_add_mlock_pvecs);
+}
+
 static void __lru_add_drain(int cpu)
 {
 	struct pagevec *pvec = &per_cpu(lru_add_pvecs, cpu);
@@ -207,6 +218,9 @@
 	pvec = &per_cpu(lru_add_active_pvecs, cpu);
 	if (pagevec_count(pvec))
 		__pagevec_lru_add_active(pvec);
+	pvec = &per_cpu(lru_add_mlock_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_mlock(pvec);
 }
 
 void lru_add_drain(void)
@@ -364,6 +378,7 @@
 			spin_lock_irq(&zone->lru_lock);
 		}
 		VM_BUG_ON(PageLRU(page));
+		VM_BUG_ON(PageMlocked(page));
 		SetPageLRU(page);
 		add_page_to_inactive_list(zone, page);
 	}
@@ -394,6 +409,38 @@
 		SetPageLRU(page);
 		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
+		VM_BUG_ON(PageMlocked(page));
+		add_page_to_active_list(zone, page);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
+void __pagevec_lru_add_mlock(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		if (!PageMlocked(page))
+			/* Another process already moved page to LRU */
+			continue;
+		BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		ClearPageMlocked(page);
+		SetPageActive(page);
+		__dec_zone_state(zone, NR_MLOCK);
 		add_page_to_active_list(zone, page);
 	}
 	if (zone)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
