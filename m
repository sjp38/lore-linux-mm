Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l5SGfDRX170112
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 16:41:13 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5SGfCHN2023602
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 18:41:12 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5SGfCfQ016583
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 18:41:12 +0200
Message-Id: <20070628164313.165225560@de.ibm.com>
References: <20070628164049.118610355@de.ibm.com>
Date: Thu, 28 Jun 2007 18:40:53 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 4/6] Guest page hinting: writable page table entries.
Content-Disposition: inline; filename=004-hva-prot.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

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

 fs/exec.c                   |    7 +++--
 include/linux/page-flags.h  |    6 ++++
 include/linux/page-states.h |   27 +++++++++++++++++++-
 mm/fremap.c                 |    1 
 mm/memory.c                 |    5 +++
 mm/mprotect.c               |    2 +
 mm/page-states.c            |   58 ++++++++++++++++++++++++++++++++++++++++++--
 mm/page_alloc.c             |    3 +-
 mm/rmap.c                   |    1 
 9 files changed, 104 insertions(+), 6 deletions(-)

diff -urpN linux-2.6/fs/exec.c linux-2.6-patched/fs/exec.c
--- linux-2.6/fs/exec.c	2007-05-25 09:33:26.000000000 +0200
+++ linux-2.6-patched/fs/exec.c	2007-06-28 18:19:47.000000000 +0200
@@ -51,6 +51,7 @@
 #include <linux/cn_proc.h>
 #include <linux/audit.h>
 #include <linux/signalfd.h>
+#include <linux/page-states.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -313,6 +314,7 @@ void install_arg_page(struct vm_area_str
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t * pte;
+	pte_t pte_val;
 	spinlock_t *ptl;
 
 	if (unlikely(anon_vma_prepare(vma)))
@@ -328,8 +330,9 @@ void install_arg_page(struct vm_area_str
 	}
 	inc_mm_counter(mm, anon_rss);
 	lru_cache_add_active(page);
-	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
-					page, vma->vm_page_prot))));
+	pte_val = pte_mkdirty(pte_mkwrite(mk_pte(page, vma->vm_page_prot)));
+	page_check_writable(page, pte_val, 2);
+	set_pte_at(mm, address, pte, pte_val);
 	page_add_new_anon_rmap(page, vma, address);
 	pte_unmap_unlock(pte, ptl);
 
diff -urpN linux-2.6/include/linux/page-flags.h linux-2.6-patched/include/linux/page-flags.h
--- linux-2.6/include/linux/page-flags.h	2007-06-28 18:19:44.000000000 +0200
+++ linux-2.6-patched/include/linux/page-flags.h	2007-06-28 18:19:47.000000000 +0200
@@ -105,6 +105,7 @@
 #endif
 
 #define PG_discarded		20	/* Page discarded by the hypervisor. */
+#define PG_writable		21	/* Page is mapped writable. */
 
 /*
  * Manipulation of page state flags
@@ -283,6 +284,11 @@ static inline void __ClearPageTail(struc
 #define TestSetPageDiscarded(page)	0
 #endif
 
+#define PageWritable(page) test_bit(PG_writable, &(page)->flags)
+#define TestSetPageWritable(page) \
+		test_and_set_bit(PG_writable, &(page)->flags)
+#define ClearPageWritable(page) clear_bit(PG_writable, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 extern void cancel_dirty_page(struct page *page, unsigned int account_size);
diff -urpN linux-2.6/include/linux/page-states.h linux-2.6-patched/include/linux/page-states.h
--- linux-2.6/include/linux/page-states.h	2007-06-28 18:19:44.000000000 +0200
+++ linux-2.6-patched/include/linux/page-states.h	2007-06-28 18:19:47.000000000 +0200
@@ -55,6 +55,9 @@ extern void page_discard(struct page *pa
 extern int  __page_make_stable(struct page *page);
 extern void __page_make_volatile(struct page *page, int offset);
 extern void __pagevec_make_volatile(struct pagevec *pvec);
+extern void __page_check_writable(struct page *page, pte_t pte,
+				  unsigned int offset);
+extern void __page_reset_writable(struct page *page);
 
 /*
  * Extended guest page hinting functions defined by using the
@@ -76,6 +79,12 @@ extern void __pagevec_make_volatile(stru
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
@@ -95,12 +104,26 @@ static inline void pagevec_make_volatile
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
 
@@ -114,6 +137,8 @@ static inline void pagevec_make_volatile
 #define page_make_volatile(_page, offset)	do { } while (0)
 #define pagevec_make_volatile(_pagevec)	do { } while (0)
 #define page_discard(_page)			do { } while (0)
+#define page_check_writable(_page,_pte,_off)	do { } while (0)
+#define page_reset_writable(_page)		do { } while (0)
 
 #endif
 
diff -urpN linux-2.6/mm/fremap.c linux-2.6-patched/mm/fremap.c
--- linux-2.6/mm/fremap.c	2006-12-28 00:23:40.000000000 +0100
+++ linux-2.6-patched/mm/fremap.c	2007-06-28 18:19:47.000000000 +0200
@@ -80,6 +80,7 @@ int install_page(struct mm_struct *mm, s
 
 	flush_icache_page(vma, page);
 	pte_val = mk_pte(page, prot);
+	page_check_writable(page, pte_val, 2);
 	set_pte_at(mm, addr, pte, pte_val);
 	page_add_file_rmap(page);
 	update_mmu_cache(vma, addr, pte_val);
diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2007-06-28 18:19:47.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2007-06-28 18:19:47.000000000 +0200
@@ -1744,6 +1744,7 @@ static int do_wp_page(struct mm_struct *
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = pte_mkyoung(orig_pte);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		page_check_writable(old_page, entry, 1);
 		if (ptep_set_access_flags(vma, address, page_table, entry,1)) {
 			update_mmu_cache(vma, address, entry);
 			lazy_mmu_prot_update(entry);
@@ -1794,6 +1795,7 @@ gotten:
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		page_check_writable(new_page, entry, 2);
 		lazy_mmu_prot_update(entry);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
@@ -2246,6 +2248,7 @@ static int do_swap_page(struct mm_struct
 	}
 
 	flush_icache_page(vma, page);
+	page_check_writable(page, pte, 2);
 	set_pte_at(mm, address, page_table, pte);
 	page_add_anon_rmap(page, vma, address);
 
@@ -2300,6 +2303,7 @@ static int do_anonymous_page(struct mm_s
 
 		entry = mk_pte(page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		page_check_writable(page, entry, 2);
 
 		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 		if (!pte_none(*page_table))
@@ -2453,6 +2457,7 @@ retry:
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		page_check_writable(new_page, entry, 2);
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
diff -urpN linux-2.6/mm/mprotect.c linux-2.6-patched/mm/mprotect.c
--- linux-2.6/mm/mprotect.c	2006-11-08 10:45:56.000000000 +0100
+++ linux-2.6-patched/mm/mprotect.c	2007-06-28 18:19:47.000000000 +0200
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/page-states.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -52,6 +53,7 @@ static void change_pte_range(struct mm_s
 			 */
 			if (dirty_accountable && pte_dirty(ptent))
 				ptent = pte_mkwrite(ptent);
+			page_check_writable(pte_page(ptent), ptent, 1);
 			set_pte_at(mm, addr, pte, ptent);
 			lazy_mmu_prot_update(ptent);
 #ifdef CONFIG_MIGRATION
diff -urpN linux-2.6/mm/page_alloc.c linux-2.6-patched/mm/page_alloc.c
--- linux-2.6/mm/page_alloc.c	2007-06-28 18:19:44.000000000 +0200
+++ linux-2.6-patched/mm/page_alloc.c	2007-06-28 18:19:47.000000000 +0200
@@ -613,7 +613,8 @@ static int prep_new_page(struct page *pa
 
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error |
 			1 << PG_referenced | 1 << PG_arch_1 |
-			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
+			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk |
+			1 << PG_writable);
 	set_page_private(page, 0);
 	set_page_refcounted(page);
 
diff -urpN linux-2.6/mm/page-states.c linux-2.6-patched/mm/page-states.c
--- linux-2.6/mm/page-states.c	2007-06-28 18:19:47.000000000 +0200
+++ linux-2.6-patched/mm/page-states.c	2007-06-28 18:19:47.000000000 +0200
@@ -74,7 +74,7 @@ void __page_make_volatile(struct page *p
 	preempt_disable();
 	if (!page_test_set_state_change(page)) {
 		if (check_bits(page) && check_counts(page, offset))
-			page_set_volatile(page);
+			page_set_volatile(page, PageWritable(page));
 		page_clear_state_change(page);
 	}
 	preempt_enable();
@@ -100,7 +100,7 @@ void __pagevec_make_volatile(struct page
 		page = pvec->pages[i];
 		if (!page_test_set_state_change(page)) {
 			if (check_bits(page) && check_counts(page, 1))
-				page_set_volatile(page);
+				page_set_volatile(page, PageWritable(page));
 			page_clear_state_change(page);
 		}
 	}
@@ -133,6 +133,60 @@ int __page_make_stable(struct page *page
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
diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2007-06-28 18:19:47.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2007-06-28 18:19:47.000000000 +0200
@@ -679,6 +679,7 @@ void page_remove_rmap(struct page *page,
 		}
 		__dec_zone_page_state(page,
 				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
+		page_reset_writable(page);
 	}
 }
 

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
