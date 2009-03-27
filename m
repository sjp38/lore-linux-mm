Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 250846B0047
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 10:55:07 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2RFAfJ7316764
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 15:10:41 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2RFADBx2834634
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:18 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2RFACHe015268
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:12 +0100
Message-Id: <20090327151012.398894143@de.ibm.com>
References: <20090327150905.819861420@de.ibm.com>
Date: Fri, 27 Mar 2009 16:09:09 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 4/6] Guest page hinting: writable page table entries.
Content-Disposition: inline; filename=004-hva-prot.diff
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org
Cc: frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com, riel@redhat.com, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj

The volatile state for page cache and swap cache pages requires that
the host system needs to be able to determine if a volatile page is
dirty before removing it. This excludes almost all platforms from using
the scheme. What is needed is a way to distinguish between pages that
are purely read-only and pages that might get written to. This allows
platforms with per-pte dirty bits to use the scheme and platforms with
per-page dirty bits a small optimization.

Whenever a writable pte is created a check is added that allows to
move the page into the correct state. This needs to be done before
the writable pte is established. To avoid unnecessary state transitions
and the need for a counter, a new page flag PG_writable is added. Only
the creation of the first writable pte will do a page state change.
Even if all the writable ptes pointing to a page are removed again,
the page stays in the safe state until all read-only users of the page
have unmapped it as well. Only then is the PG_writable bit reset.

The state a page needs to have if a writable pte is present depends
on the platform. A platform with per-pte dirty bits wants to move the
page into stable state, a platform with per-page dirty bits like s390
can decide to move the page into a special state that requires the host
system to check the dirty bit before discarding a page.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/linux/page-flags.h  |    8 ++++++
 include/linux/page-states.h |   27 +++++++++++++++++++-
 mm/memory.c                 |    5 +++
 mm/mprotect.c               |    2 +
 mm/page-states.c            |   58 ++++++++++++++++++++++++++++++++++++++++++--
 mm/rmap.c                   |    1 
 6 files changed, 98 insertions(+), 3 deletions(-)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -103,6 +103,7 @@ enum pageflags {
 #endif
 #ifdef CONFIG_PAGE_STATES
 	PG_discarded,		/* Page discarded by the hypervisor. */
+	PG_writable,		/* Page is mapped writable. */
 #endif
 	__NR_PAGEFLAGS,
 
@@ -186,10 +187,17 @@ static inline int TestClearPage##uname(s
 #define ClearPageDiscarded(page) clear_bit(PG_discarded, &(page)->flags)
 #define TestSetPageDiscarded(page) \
 		test_and_set_bit(PG_discarded, &(page)->flags)
+#define PageWritable(page)	test_bit(PG_writable, &(page)->flags)
+#define ClearPageWritable(page) clear_bit(PG_writable, &(page)->flags)
+#define TestSetPageWritable(page) \
+		test_and_set_bit(PG_writable, &(page)->flags)
 #else
 #define PageDiscarded(page)		0
 #define ClearPageDiscarded(page)	do { } while (0)
 #define TestSetPageDiscarded(page)	0
+#define PageWritable(page)		0
+#define ClearPageWritable(page)		do { } while (0)
+#define TestSetPageWritable(page)	0
 #endif
 
 struct page;	/* forward declaration */
Index: linux-2.6/include/linux/page-states.h
===================================================================
--- linux-2.6.orig/include/linux/page-states.h
+++ linux-2.6/include/linux/page-states.h
@@ -57,6 +57,9 @@ extern void page_discard(struct page *pa
 extern int  __page_make_stable(struct page *page);
 extern void __page_make_volatile(struct page *page, int offset);
 extern void __pagevec_make_volatile(struct pagevec *pvec);
+extern void __page_check_writable(struct page *page, pte_t pte,
+				  unsigned int offset);
+extern void __page_reset_writable(struct page *page);
 
 /*
  * Extended guest page hinting functions defined by using the
@@ -78,6 +81,12 @@ extern void __pagevec_make_volatile(stru
  *     from the LRU list and the radix tree of its mapping.
  *     page_discard uses page_unmap_all to remove all page table
  *     entries for a page.
+ * - page_check_writable:
+ *     Checks if the page states needs to be adapted because a new
+ *     writable page table entry refering to the page is established.
+ * - page_reset_writable:
+ *     Resets the page state after the last writable page table entry
+ *     refering to the page has been removed.
  */
 
 static inline int page_make_stable(struct page *page)
@@ -97,12 +106,26 @@ static inline void pagevec_make_volatile
 		__pagevec_make_volatile(pvec);
 }
 
+static inline void page_check_writable(struct page *page, pte_t pte,
+				       unsigned int offset)
+{
+	if (page_host_discards() && pte_write(pte) &&
+	    !test_bit(PG_writable, &page->flags))
+		__page_check_writable(page, pte, offset);
+}
+
+static inline void page_reset_writable(struct page *page)
+{
+	if (page_host_discards() && test_bit(PG_writable, &page->flags))
+		__page_reset_writable(page);
+}
+
 #else
 
 #define page_host_discards()			(0)
 #define page_set_unused(_page,_order)		do { } while (0)
 #define page_set_stable(_page,_order)		do { } while (0)
-#define page_set_volatile(_page)		do { } while (0)
+#define page_set_volatile(_page,_writable)	do { } while (0)
 #define page_set_stable_if_present(_page)	(1)
 #define page_discarded(_page)			(0)
 #define page_volatile(_page)			(0)
@@ -117,6 +140,8 @@ static inline void pagevec_make_volatile
 #define page_make_volatile(_page, offset)	do { } while (0)
 #define pagevec_make_volatile(_pagevec)	do { } while (0)
 #define page_discard(_page)			do { } while (0)
+#define page_check_writable(_page,_pte,_off)	do { } while (0)
+#define page_reset_writable(_page)		do { } while (0)
 
 #endif
 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -2029,6 +2029,7 @@ reuse:
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = pte_mkyoung(orig_pte);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		page_check_writable(old_page, entry, 1);
 		if (ptep_set_access_flags(vma, address, page_table, entry,1))
 			update_mmu_cache(vma, address, entry);
 		ret |= VM_FAULT_WRITE;
@@ -2084,6 +2085,7 @@ gotten:
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		page_check_writable(new_page, entry, 2);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
@@ -2540,6 +2542,7 @@ static int do_swap_page(struct mm_struct
 		write_access = 0;
 	}
 	flush_icache_page(vma, page);
+	page_check_writable(page, pte, 2);
 	set_pte_at(mm, address, page_table, pte);
 	page_add_anon_rmap(page, vma, address);
 	/* It's better to call commit-charge after rmap is established */
@@ -2599,6 +2602,7 @@ static int do_anonymous_page(struct mm_s
 
 	entry = mk_pte(page, vma->vm_page_prot);
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	page_check_writable(page, entry, 2);
 
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (!pte_none(*page_table))
@@ -2754,6 +2758,7 @@ retry:
 		entry = mk_pte(page, vma->vm_page_prot);
 		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		page_check_writable(page, entry, 2);
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
 			page_add_new_anon_rmap(page, vma, address);
Index: linux-2.6/mm/mprotect.c
===================================================================
--- linux-2.6.orig/mm/mprotect.c
+++ linux-2.6/mm/mprotect.c
@@ -23,6 +23,7 @@
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
 #include <linux/migrate.h>
+#include <linux/page-states.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -58,6 +59,7 @@ static void change_pte_range(struct mm_s
 			 */
 			if (dirty_accountable && pte_dirty(ptent))
 				ptent = pte_mkwrite(ptent);
+			page_check_writable(pte_page(ptent), ptent, 1);
 
 			ptep_modify_prot_commit(mm, addr, pte, ptent);
 		} else if (PAGE_MIGRATION && !pte_file(oldpte)) {
Index: linux-2.6/mm/page-states.c
===================================================================
--- linux-2.6.orig/mm/page-states.c
+++ linux-2.6/mm/page-states.c
@@ -83,7 +83,7 @@ void __page_make_volatile(struct page *p
 	preempt_disable();
 	if (!page_test_set_state_change(page)) {
 		if (check_bits(page) && check_counts(page, offset))
-			page_set_volatile(page);
+			page_set_volatile(page, PageWritable(page));
 		page_clear_state_change(page);
 	}
 	preempt_enable();
@@ -109,7 +109,7 @@ void __pagevec_make_volatile(struct page
 		page = pvec->pages[i];
 		if (!page_test_set_state_change(page)) {
 			if (check_bits(page) && check_counts(page, 1))
-				page_set_volatile(page);
+				page_set_volatile(page, PageWritable(page));
 			page_clear_state_change(page);
 		}
 	}
@@ -142,6 +142,60 @@ int __page_make_stable(struct page *page
 EXPORT_SYMBOL(__page_make_stable);
 
 /**
+ * __page_check_writable() - check page state for new writable pte
+ *
+ * @page: the page the new writable pte refers to
+ * @pte: the new writable pte
+ */
+void __page_check_writable(struct page *page, pte_t pte, unsigned int offset)
+{
+	int count_ok = 0;
+
+	preempt_disable();
+	while (page_test_set_state_change(page))
+		cpu_relax();
+
+	if (!TestSetPageWritable(page)) {
+		count_ok = check_counts(page, offset);
+		if (check_bits(page) && count_ok)
+			page_set_volatile(page, 1);
+		else
+			/*
+			 * If two processes create a write mapping at the
+			 * same time check_counts will return false or if
+			 * the page is currently isolated from the LRU
+			 * check_bits will return false but the page might
+			 * be in volatile state.
+			 * We have to take care about the dirty bit so the
+			 * only option left is to make the page stable but
+			 * we can try to make it volatile a bit later.
+			 */
+			page_set_stable_if_present(page);
+	}
+	page_clear_state_change(page);
+	if (!count_ok)
+		page_make_volatile(page, 1);
+	preempt_enable();
+}
+EXPORT_SYMBOL(__page_check_writable);
+
+/**
+ * __page_reset_writable() - clear the PageWritable bit
+ *
+ * @page: the page
+ */
+void __page_reset_writable(struct page *page)
+{
+	preempt_disable();
+	if (!page_test_set_state_change(page)) {
+		ClearPageWritable(page);
+		page_clear_state_change(page);
+	}
+	preempt_enable();
+}
+EXPORT_SYMBOL(__page_reset_writable);
+
+/**
  * __page_discard() - remove a discarded page from the cache
  *
  * @page: the page
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -752,6 +752,7 @@ void page_remove_rmap(struct page *page)
 			mem_cgroup_uncharge_page(page);
 		__dec_zone_page_state(page,
 			PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
+		page_reset_writable(page);
 		/*
 		 * It would be tidy to reset the PageAnon mapping here,
 		 * but that might overwrite a racing page_add_anon_rmap

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
