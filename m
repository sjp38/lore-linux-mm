Received: from programming.kicks-ass.net ([62.194.129.232])
          by amsfep20-int.chello.nl
          (InterMail vM.6.01.04.04 201-2131-118-104-20050224) with SMTP
          id <20050827220304.DTXJ7898.amsfep20-int.chello.nl@programming.kicks-ass.net>
          for <linux-mm@kvack.org>; Sun, 28 Aug 2005 00:03:04 +0200
Message-Id: <20050827220305.671273000@twins>
References: <20050827215756.726585000@twins>
Date: Sat, 27 Aug 2005 23:57:59 +0200
From: a.p.zijlstra@chello.nl
Subject: [RFC][PATCH 3/6] CART Implementation
Content-Disposition: inline; filename=cart-cart.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Index: linux-2.6-cart/include/linux/mm_inline.h
===================================================================
--- linux-2.6-cart.orig/include/linux/mm_inline.h
+++ linux-2.6-cart/include/linux/mm_inline.h
@@ -31,10 +31,28 @@ static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
 	list_del(&page->lru);
-	if (PageActive(page)) {
-		ClearPageActive(page);
+	if (TestClearPageActive(page)) {
 		zone->nr_active--;
 	} else {
 		zone->nr_inactive--;
 	}
+	if (TestClearPageLongTerm(page)) {
+		/* zone->nr_longterm--; */
+	} else {
+		zone->nr_shortterm--;
+	}
+}
+
+static inline void
+add_page_to_active_tail(struct zone *zone, struct page *page)
+{
+	list_add_tail(&page->lru, &zone->active_list);
+	zone->nr_active++;
+}
+
+static inline void
+add_page_to_inactive_tail(struct zone *zone, struct page *page)
+{
+        list_add_tail(&page->lru, &zone->inactive_list);
+        zone->nr_inactive++;
 }
Index: linux-2.6-cart/include/linux/mmzone.h
===================================================================
--- linux-2.6-cart.orig/include/linux/mmzone.h
+++ linux-2.6-cart/include/linux/mmzone.h
@@ -143,13 +143,17 @@ struct zone {
 	ZONE_PADDING(_pad1_)
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;	
-	struct list_head	active_list;
-	struct list_head	inactive_list;
+	spinlock_t		lru_lock;
+	struct list_head	active_list;	/* The T1 list of CART */
+	struct list_head	inactive_list;  /* The T2 list of CART */
 	unsigned long		nr_scan_active;
 	unsigned long		nr_scan_inactive;
 	unsigned long		nr_active;
 	unsigned long		nr_inactive;
+	unsigned long 		nr_evicted_active;
+	unsigned long 		nr_shortterm;	/* number of short term pages */
+	unsigned long		nr_p;		/* p from the CART paper */
+	unsigned long 		nr_q;		/* q from the cart paper */
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	int			all_unreclaimable; /* All pages pinned */
 
Index: linux-2.6-cart/include/linux/page-flags.h
===================================================================
--- linux-2.6-cart.orig/include/linux/page-flags.h
+++ linux-2.6-cart/include/linux/page-flags.h
@@ -76,6 +76,8 @@
 #define PG_nosave_free		18	/* Free, should not be written */
 #define PG_uncached		19	/* Page has been mapped as uncached */
 
+#define PG_longterm		20	/* Filter bit for CART see mm/cart.c */
+
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
  * allowed.
@@ -305,6 +307,12 @@ extern void __mod_page_state(unsigned lo
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#define PageLongTerm(page)	test_bit(PG_longterm, &(page)->flags)
+#define SetPageLongTerm(page)	set_bit(PG_longterm, &(page)->flags)
+#define TestSetPageLongTerm(page) test_and_set_bit(PG_longterm, &(page)->flags)
+#define ClearPageLongTerm(page)	clear_bit(PG_longterm, &(page)->flags)
+#define TestClearPageLongTerm(page) test_and_clear_bit(PG_longterm, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 int test_clear_page_dirty(struct page *page);
Index: linux-2.6-cart/include/linux/swap.h
===================================================================
--- linux-2.6-cart.orig/include/linux/swap.h
+++ linux-2.6-cart/include/linux/swap.h
@@ -7,6 +7,7 @@
 #include <linux/mmzone.h>
 #include <linux/list.h>
 #include <linux/sched.h>
+#include <linux/mm.h>
 
 #include <asm/atomic.h>
 #include <asm/page.h>
@@ -163,6 +164,22 @@ extern unsigned int remember_page(struct
 extern unsigned int recently_evicted(struct address_space *, unsigned long);
 extern void init_nonresident(void);
 
+/* linux/mm/cart.c */
+extern void cart_init(void);
+extern void __cart_insert(struct zone *, struct page *);
+extern struct page *__cart_replace(struct zone *);
+extern void __cart_reinsert(struct zone *, struct page*);
+extern void __cart_remember(struct zone *, struct page*);
+
+static inline void cart_remember(struct page *page)
+{
+	unsigned long flags;
+	struct zone *zone = page_zone(page);
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	__cart_remember(zone, page);
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
+}
+
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalhigh_pages;
Index: linux-2.6-cart/init/main.c
===================================================================
--- linux-2.6-cart.orig/init/main.c
+++ linux-2.6-cart/init/main.c
@@ -497,6 +497,7 @@ asmlinkage void __init start_kernel(void
 	vfs_caches_init_early();
 	init_nonresident();
 	mem_init();
+	cart_init();
 	kmem_cache_init();
 	setup_per_cpu_pageset();
 	numa_policy_init();
Index: linux-2.6-cart/mm/Makefile
===================================================================
--- linux-2.6-cart.orig/mm/Makefile
+++ linux-2.6-cart/mm/Makefile
@@ -13,7 +13,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   prio_tree.o $(mmu-y)
 
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o \
-				nonresident.o
+				nonresident.o cart.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
Index: linux-2.6-cart/mm/cart.c
===================================================================
--- /dev/null
+++ linux-2.6-cart/mm/cart.c
@@ -0,0 +1,243 @@
+/* For further details, please refer to the CART paper here -
+ *   http://www.almaden.ibm.com/cs/people/dmodha/clockfast.pdf
+ *
+ * Modified by Peter Zijlstra to work with the nonresident code I adapted
+ * from Rik van Riel.
+ *
+ * XXX: add page accounting
+ */
+
+#include <linux/swap.h>
+#include <linux/mm.h>
+#include <linux/page-flags.h>
+#include <linux/mm_inline.h>
+#include <linux/rmap.h>
+
+#define cart_cT ((zone)->nr_active + (zone)->nr_inactive)
+#define cart_cB ((zone)->present_pages)
+
+#define size_T1 ((zone)->nr_active)
+#define size_T2 ((zone)->nr_inactive)
+
+#define list_T1 (&(zone)->active_list)
+#define list_T2 (&(zone)->inactive_list)
+
+#define cart_p ((zone)->nr_p)
+#define cart_q ((zone)->nr_q)
+
+#define size_B1 ((zone)->nr_evicted_active)
+#define size_B2 (cart_cB - size_B1)
+
+#define nr_Ns ((zone)->nr_shortterm)
+#define nr_Nl (cart_cT - nr_Ns)
+
+#define T2B(x) (((x) * cart_cB) / (cart_cT + 1))
+#define B2T(x) (((x) * cart_cT) / cart_cB)
+
+/* Called from init/main.c to initialize the cart parameters */
+void cart_init()
+{
+	struct zone *zone;
+	for_each_zone(zone) {
+		zone->nr_evicted_active = 0;
+		/* zone->nr_evicted_inactive = cart_cB; */
+		zone->nr_shortterm = 0;
+		/* zone->nr_longterm = 0; */
+		zone->nr_p = 0;
+		zone->nr_q = 0;
+	}
+}
+
+static inline void cart_q_inc(struct zone *zone)
+{
+	/* if (|T2| + |B2| + |T1| - ns >= c) q = min(q + 1, 2c - |T1|) */
+	if (size_T2 + B2T(size_B2) + size_T1 - nr_Ns >= cart_cT)
+		cart_q = min(cart_q + 1, 2*cart_cB - T2B(size_T1));
+}
+
+static inline void cart_q_dec(struct zone *zone)
+{
+	/* q = max(q - 1, c - |T1|) */
+	unsigned long target = cart_cB - T2B(size_T1);
+	if (cart_q <= target)
+		cart_q = target;
+	else
+		--cart_q;
+}
+
+/*
+ * zone->lru_lock taken
+ */
+void __cart_insert(struct zone *zone, struct page *page)
+{
+	unsigned int rflags;
+	unsigned int on_B1, on_B2;
+
+	rflags = recently_evicted(page_mapping(page), page_index(page));
+	on_B1 = (rflags && !(rflags & NR_list));
+	on_B2 = (rflags && (rflags & NR_list));
+
+	if (on_B1) {
+		/* p = min(p + max(1, ns/|B1|), c) */
+		unsigned long ratio = nr_Ns / (B2T(size_B1) + 1);
+		cart_p += ratio ?: 1UL;
+		if (unlikely(cart_p > cart_cT))
+			cart_p = cart_cT;
+
+		SetPageLongTerm(page);
+		/* ++nr_Nl; */
+	} else if (on_B2) {
+		/* p = max(p - max(1, nl/|B2|), 0) */
+		unsigned long ratio = nr_Nl / (B2T(size_B2) + 1);
+		cart_p -= ratio ?: 1UL;
+		if (unlikely(cart_p > cart_cT)) /* unsigned; wrap around */
+			cart_p = 0UL;
+
+		SetPageLongTerm(page);
+		/* NOTE: this function is the only one that uses recently_evicted()
+		 * and it does not use the NR_filter flag; we could live without,
+		 * for now use as sanity check
+		 */
+		BUG_ON(!(rflags & NR_filter)); /* all pages in B2 are longterm */
+
+		/* ++nr_Nl; */
+		cart_q_inc(zone);
+	} else {
+		ClearPageLongTerm(page);
+		++nr_Ns;
+	}
+
+	ClearPageReferenced(page);
+	SetPageActive(page);
+	add_page_to_active_list(zone, page);
+	BUG_ON(!PageLRU(page));
+}
+
+/* This function selects the candidate and returns the corresponding
+ * struct page * or returns NULL in case no page can be freed.
+ */
+struct page *__cart_replace(struct zone *zone)
+{
+	struct page *page;
+	int referenced;
+
+	while (!list_empty(list_T2)) {
+		page = list_entry(list_T2->next, struct page, lru);
+
+		if (!page_referenced(page, 0, 0))
+			break;
+
+		del_page_from_inactive_list(zone, page);
+		add_page_to_active_tail(zone, page);
+		SetPageActive(page);
+
+		cart_q_inc(zone);
+	}
+
+	while (!list_empty(list_T1)) {
+		page = list_entry(list_T1->next, struct page, lru);
+		referenced = page_referenced(page, 0, 0);
+
+		if (!PageLongTerm(page) && !referenced)
+			break;
+
+		if (referenced) {
+			del_page_from_active_list(zone, page);
+			add_page_to_active_tail(zone, page);
+
+			/* ( |T1| >= min(p + 1, |B1| ) and ( filter = 'S' ) */
+			if (size_T1 >= min(cart_p + 1, B2T(size_B1)) &&
+			    !PageLongTerm(page)) {
+				SetPageLongTerm(page);
+				--nr_Ns;
+				/* ++nr_Nl; */
+			}
+		} else {
+			BUG_ON(!PageLongTerm(page));
+
+			del_page_from_active_list(zone, page);
+			add_page_to_inactive_tail(zone, page);
+			ClearPageActive(page);
+
+			cart_q_dec(zone);
+		}
+	}
+
+	page = NULL;
+	if (size_T1 > max(1UL, cart_p) || list_empty(list_T2)) {
+		if (!list_empty(list_T1)) {
+			page = list_entry(list_T1->next, struct page, lru);
+			del_page_from_active_list(zone, page);
+			BUG_ON(PageLongTerm(page));
+			--nr_Ns;
+		}
+	} else {
+		BUG_ON(list_empty(list_T2));
+		page = list_entry(list_T2->next, struct page, lru);
+		del_page_from_inactive_list(zone, page);
+		/* --nr_Nl; */
+	}
+	if (!page) return NULL;
+
+	return page;
+}
+
+/* re-insert pages that were elected for replacement but somehow didn't make it
+ * treat as referenced to let the relaim path make progress.
+ */
+void __cart_reinsert(struct zone *zone, struct page *page )
+{
+	if (!PageLongTerm(page)) ++nr_Ns;
+
+	if (!PageActive(page)) { /* T2 */
+		SetPageActive(page);
+		add_page_to_active_tail(zone, page);
+
+		cart_q_inc(zone);
+	} else { /* T1 */
+		add_page_to_active_tail(zone, page);
+
+		/* ( |T1| >= min(p + 1, |B1| ) and ( filter = 'S' ) */
+		if (size_T1 >= min(cart_p + 1, B2T(size_B1)) &&
+		    !PageLongTerm(page)) {
+			SetPageLongTerm(page);
+			--nr_Ns;
+			/* ++nr_Nl; */
+		}
+	}
+}
+
+/* puts pages on the non-resident lists on swap-out
+ * XXX: lose the reliance on zone->lru_lock !!!
+ */
+void __cart_remember(struct zone *zone, struct page *page)
+{
+	unsigned int rflags;
+	unsigned int flags = 0;
+
+	if (!PageActive(page)) {
+		flags |= NR_list;
+		/* ++size_B2; */
+	} else
+		++size_B1;
+
+	if (PageLongTerm(page))
+		flags |= NR_filter;
+
+	/* history replacement; always remember, if the page was already remembered
+	 * this will move it to the head. XXX: not so; fix this !!
+	 *
+	 * Assume |B1| + |B2| == c + 1, since |B1_j| + |B2_j| := c_j.
+	 * The list_empty check is done on the Bn_j side.
+	 */
+	/* |B1| <= max(0, q) */
+	if (size_B1 <= cart_q) flags |= NR_evict;
+
+	rflags = remember_page(page_mapping(page), page_index(page), flags);
+
+	if (rflags & NR_list) {
+		/* if (likely(size_B2)) --size_B2; */
+	} else {
+		if (likely(size_B1)) --size_B1;
+	}
+}

--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
