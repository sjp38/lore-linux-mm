Date: Mon, 5 Feb 2007 12:52:45 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070205205245.4500.64711.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070205205235.4500.54958.sendpatchset@schroedinger.engr.sgi.com>
References: <20070205205235.4500.54958.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 2/7] Add PageMlocked() page state bit and lru infrastructure
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Add PageMlocked() infrastructure

This adds a new PG_mlocked to mark pages that were taken off the LRU
because they have a reference from a VM_LOCKED vma.

Also add pagevec handling for returning mlocked pages to the LRU.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: current/include/linux/page-flags.h
===================================================================
--- current.orig/include/linux/page-flags.h	2007-02-05 11:30:47.000000000 -0800
+++ current/include/linux/page-flags.h	2007-02-05 11:33:00.000000000 -0800
@@ -93,6 +93,7 @@
 
 #define PG_readahead		20	/* Reminder to do read-ahead */
 
+#define PG_mlocked		21	/* Page is mlocked */
 
 #if (BITS_PER_LONG > 32)
 /*
@@ -235,6 +236,16 @@ static inline void SetPageUptodate(struc
 #define SetPageReadahead(page)	set_bit(PG_readahead, &(page)->flags)
 #define ClearPageReadahead(page) clear_bit(PG_readahead, &(page)->flags)
 
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
Index: current/include/linux/pagevec.h
===================================================================
--- current.orig/include/linux/pagevec.h	2007-02-05 11:30:47.000000000 -0800
+++ current/include/linux/pagevec.h	2007-02-05 11:33:00.000000000 -0800
@@ -25,6 +25,7 @@ void __pagevec_release_nonlru(struct pag
 void __pagevec_free(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec);
 void __pagevec_lru_add_active(struct pagevec *pvec);
+void __pagevec_lru_add_mlock(struct pagevec *pvec);
 void pagevec_strip(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
Index: current/include/linux/swap.h
===================================================================
--- current.orig/include/linux/swap.h	2007-02-05 11:30:47.000000000 -0800
+++ current/include/linux/swap.h	2007-02-05 11:33:00.000000000 -0800
@@ -181,6 +181,7 @@ extern unsigned int nr_free_pagecache_pa
 extern void FASTCALL(lru_cache_add(struct page *));
 extern void FASTCALL(lru_cache_add_active(struct page *));
 extern void FASTCALL(lru_cache_add_tail(struct page *));
+extern void FASTCALL(lru_cache_add_mlock(struct page *));
 extern void FASTCALL(activate_page(struct page *));
 extern void FASTCALL(mark_page_accessed(struct page *));
 extern void lru_add_drain(void);
Index: current/mm/swap.c
===================================================================
--- current.orig/mm/swap.c	2007-02-05 11:30:47.000000000 -0800
+++ current/mm/swap.c	2007-02-05 11:33:00.000000000 -0800
@@ -178,6 +178,7 @@ EXPORT_SYMBOL(mark_page_accessed);
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
 static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
 static DEFINE_PER_CPU(struct pagevec, lru_add_tail_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_mlock_pvecs) = { 0, };
 
 void fastcall lru_cache_add(struct page *page)
 {
@@ -199,6 +200,16 @@ void fastcall lru_cache_add_active(struc
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
 static void __pagevec_lru_add_tail(struct pagevec *pvec)
 {
 	int i;
@@ -237,6 +248,9 @@ static void __lru_add_drain(int cpu)
 	pvec = &per_cpu(lru_add_tail_pvecs, cpu);
 	if (pagevec_count(pvec))
 		__pagevec_lru_add_tail(pvec);
+	pvec = &per_cpu(lru_add_mlock_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_mlock(pvec);
 }
 
 void lru_add_drain(void)
@@ -394,6 +408,7 @@ void __pagevec_lru_add(struct pagevec *p
 			spin_lock_irq(&zone->lru_lock);
 		}
 		VM_BUG_ON(PageLRU(page));
+		VM_BUG_ON(PageMlocked(page));
 		SetPageLRU(page);
 		add_page_to_inactive_list(zone, page);
 	}
@@ -423,6 +438,7 @@ void __pagevec_lru_add_active(struct pag
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		VM_BUG_ON(PageActive(page));
+		VM_BUG_ON(PageMlocked(page));
 		SetPageActive(page);
 		add_page_to_active_list(zone, page);
 	}
@@ -432,6 +448,36 @@ void __pagevec_lru_add_active(struct pag
 	pagevec_reinit(pvec);
 }
 
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
+		BUG_ON(PageLRU(page));
+		if (!PageMlocked(page))
+			continue;
+		ClearPageMlocked(page);
+		smp_wmb();
+		__dec_zone_state(zone, NR_MLOCK);
+		SetPageLRU(page);
+		add_page_to_active_list(zone, page);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
 /*
  * Function used uniquely to put pages back to the lru at the end of the
  * inactive list to preserve the lru order. Currently only used by swap

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
