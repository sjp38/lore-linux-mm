Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3OCaBW2129920
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 12:36:11 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3OCbGGv087498
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:37:16 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3OCaBmB008062
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:36:11 +0200
Date: Mon, 24 Apr 2006 14:36:15 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 7/8] Page host virtual assist: discarded page list.
Message-ID: <20060424123615.GH15817@skybase>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@osdl.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

[patch 7/8] Page host virtual assist: discarded page list.

The discarded page list is used to postpone the freeing of discarded
pages. A check is added to __remove_from_page_cache and
__delete_from_swap_cache that sets the PG_discarded bit if the page
has been removed by the host. free_hot_cold_page tests for the bit
and puts the page to a per-cpu discarded page list if it is set.
try_to_free_pages does an smp_call_function to collect all the
partial discarded page lists and frees them.

There are two reasons why this is desirable. First, discarded page are
really cold. Before the guest can reaccess the page frame the host
needs to provide a fresh page. It is faster to use only non-discarded
pages which do not require a host action as long as the working set
of the guest allows it.

The second reason has to do with the peculiars of the s390 architecture.
The discard fault exception delivers the absolute address of the page
that caused the fault to the guest instead of the virtual address. With
the virtual address we could have used the page table entry of the
current process to safely get a reference to the discarded page. We can
get the struct page pointer from the absolute page address but its
rather hard to get to a proper page reference. The page that caused the
fault could already have been freed and reused for a different purpose.
None of the fields in the struct page would be reliable to use. The
smp_call_function makes sure that the discard fault handler is called
only for discarded pages that have not been freed yet. A call to
get_page_unless_zero can then be used to get a proper page reference.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/linux/page_hva.h |    4 +++
 mm/filemap.c             |    4 +++
 mm/page_alloc.c          |   57 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/swap_state.c          |    4 +++
 mm/vmscan.c              |    1 
 5 files changed, 70 insertions(+)

diff -urpN linux-2.6/include/linux/page_hva.h linux-2.6-patched/include/linux/page_hva.h
--- linux-2.6/include/linux/page_hva.h	2006-04-24 12:51:30.000000000 +0200
+++ linux-2.6-patched/include/linux/page_hva.h	2006-04-24 12:51:31.000000000 +0200
@@ -18,6 +18,7 @@
 
 extern void page_hva_unmap_all(struct page *page);
 extern void page_hva_discard_page(struct page *page);
+extern unsigned long page_hva_shrink_discards(void);
 
 extern int  __page_hva_make_stable(struct page *page);
 extern void __page_hva_make_volatile(struct page *page, unsigned int offset);
@@ -64,6 +65,8 @@ static inline void page_hva_reset_write(
 #define page_hva_set_volatile(_page,_writable)	do { } while (0)
 #define page_hva_cond_set_stable(_page)		(1)
 
+#define page_hva_discarded(_page)		(0)
+
 #define page_hva_make_stable(_page)		(1)
 #define page_hva_make_volatile(_page,_offset)	do { } while (0)
 
@@ -71,6 +74,7 @@ static inline void page_hva_reset_write(
 #define page_hva_reset_write(_page)		do { } while (0)
 
 #define page_hva_discard_page(_page)		do { } while (0)
+#define page_hva_shrink_discards()		(0)
 
 #endif
 
diff -urpN linux-2.6/mm/filemap.c linux-2.6-patched/mm/filemap.c
--- linux-2.6/mm/filemap.c	2006-04-24 12:51:31.000000000 +0200
+++ linux-2.6-patched/mm/filemap.c	2006-04-24 12:51:31.000000000 +0200
@@ -117,6 +117,10 @@ void __remove_from_page_cache(struct pag
 {
 	struct address_space *mapping = page->mapping;
 
+	/* Set the PageDiscarded bit if the page has been discarded. */
+	if (page_hva_enabled() &&
+	    unlikely(!PageDiscarded(page) && page_hva_discarded(page)))
+		SetPageDiscarded(page);
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	mapping->nrpages--;
diff -urpN linux-2.6/mm/page_alloc.c linux-2.6-patched/mm/page_alloc.c
--- linux-2.6/mm/page_alloc.c	2006-04-24 12:51:30.000000000 +0200
+++ linux-2.6-patched/mm/page_alloc.c	2006-04-24 12:51:31.000000000 +0200
@@ -744,6 +744,42 @@ static void zone_statistics(struct zonel
 #endif
 }
 
+#if defined(CONFIG_PAGE_HVA)
+DEFINE_PER_CPU(struct list_head, page_hva_discard_list);
+
+static void __page_hva_shrink_discards(void *info)
+{
+	static DEFINE_SPINLOCK(splice_lock);
+	struct list_head *discard_list = info;
+	struct list_head *cpu_list = &__get_cpu_var(page_hva_discard_list);
+
+	if (list_empty(cpu_list))
+		return;
+	spin_lock(&splice_lock);
+	list_splice_init(cpu_list, discard_list);
+	spin_unlock(&splice_lock);
+}
+
+unsigned long page_hva_shrink_discards(void)
+{
+	struct list_head pages_to_free = LIST_HEAD_INIT(pages_to_free);
+	struct page *page, *next;
+	unsigned long freed = 0;
+
+	if (!page_hva_enabled())
+		return 0;
+
+	smp_call_function(__page_hva_shrink_discards, &pages_to_free, 0, 1);
+
+	list_for_each_entry_safe(page, next, &pages_to_free, lru) {
+		ClearPageDiscarded(page);
+		free_cold_page(page);
+		freed++;
+	}
+	return freed;
+}
+#endif
+
 /*
  * Free a 0-order page
  */
@@ -753,6 +789,16 @@ static void fastcall free_hot_cold_page(
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
 
+#if defined(CONFIG_PAGE_HVA)
+	if (page_hva_enabled() && unlikely(PageDiscarded(page))) {
+		local_irq_disable();
+		list_add_tail(&page->lru,
+			      &__get_cpu_var(page_hva_discard_list));
+		local_irq_enable();
+		return;
+	}
+#endif
+
 	arch_free_page(page, 0);
 
 	if (PageAnon(page))
@@ -2623,6 +2669,11 @@ static int page_alloc_cpu_notify(struct 
 			src[i] = 0;
 		}
 
+#if defined(CONFIG_PAGE_HVA)
+		list_splice_init(&per_cpu(page_hva_discard_list, cpu),
+				 &__get_cpu_var(page_hva_discard_list));
+#endif
+
 		local_irq_enable();
 	}
 	return NOTIFY_OK;
@@ -2631,6 +2682,12 @@ static int page_alloc_cpu_notify(struct 
 
 void __init page_alloc_init(void)
 {
+#if defined(CONFIG_PAGE_HVA)
+	int i;
+
+	for_each_possible_cpu(i)
+		INIT_LIST_HEAD(&per_cpu(page_hva_discard_list, i));
+#endif
 	hotcpu_notifier(page_alloc_cpu_notify, 0);
 }
 
diff -urpN linux-2.6/mm/swap_state.c linux-2.6-patched/mm/swap_state.c
--- linux-2.6/mm/swap_state.c	2006-04-24 12:51:31.000000000 +0200
+++ linux-2.6-patched/mm/swap_state.c	2006-04-24 12:51:31.000000000 +0200
@@ -131,6 +131,10 @@ void __delete_from_swap_cache(struct pag
 	BUG_ON(PageWriteback(page));
 	BUG_ON(PagePrivate(page));
 
+	/* Set the PageDiscarded bit if the page has been discarded. */
+	if (page_hva_enabled() &&
+	    unlikely(!PageDiscarded(page) && page_hva_discarded(page)))
+		SetPageDiscarded(page);
 	radix_tree_delete(&swapper_space.page_tree, page_private(page));
 	set_page_private(page, 0);
 	ClearPageSwapCache(page);
diff -urpN linux-2.6/mm/vmscan.c linux-2.6-patched/mm/vmscan.c
--- linux-2.6/mm/vmscan.c	2006-04-24 12:51:27.000000000 +0200
+++ linux-2.6-patched/mm/vmscan.c	2006-04-24 12:51:31.000000000 +0200
@@ -993,6 +993,7 @@ unsigned long try_to_free_pages(struct z
 		sc.nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
+		nr_reclaimed += page_hva_shrink_discards();
 		nr_reclaimed += shrink_zones(priority, zones, &sc);
 		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages);
 		if (reclaim_state) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
