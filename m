Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By tone With Smtp ;
	Tue, 30 May 2006 17:31:43 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:31:43 +1000 (EST)
Subject: [Patch 11/17] PTI: Abstract vunmap read iterator
Message-ID: <Pine.LNX.4.61.0605301730010.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Abstract the vunmap read iterator from vmalloc.c to
  default-pt-read-iterators.h

  Put unmap_page_range in the read iterators file.

  include/linux/default-pt-read-iterators.h |   62 ++++++++++++++++++++++
  include/linux/default-pt.h                |    2
  mm/memory.c                               |   84 
++++++++++++++++++++++++++++++
  mm/vmalloc.c                              |   55 ++-----------------
  4 files changed, 155 insertions(+), 48 deletions(-)
Index: linux-rc5/include/linux/default-pt.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt.h	2006-05-28 
19:21:07.728000400 +1000
+++ linux-rc5/include/linux/default-pt.h	2006-05-28 
19:21:12.138737536 +1000
@@ -1,6 +1,7 @@
  #ifndef _LINUX_DEFAULT_PT_H
  #define _LINUX_DEFAULT_PT_H

+#include <asm/tlb.h>
  #include <asm/pgalloc.h>
  #include <asm/pgtable.h>

@@ -171,6 +172,7 @@

  #include <linux/pt-common.h>
  #include <linux/default-pt-dual-iterators.h>
+#include <linux/default-pt-read-iterators.h>

  #endif

Index: linux-rc5/mm/memory.c
===================================================================
--- linux-rc5.orig/mm/memory.c	2006-05-28 19:21:07.747016512 +1000
+++ linux-rc5/mm/memory.c	2006-05-28 19:21:10.177075456 +1000
@@ -273,6 +273,90 @@
  	return 0;
  }

+static void zap_pte(pte_t *pte, struct mm_struct *mm, unsigned long addr,
+		struct vm_area_struct *vma, long *zap_work, struct 
zap_details *details,
+		struct mmu_gather *tlb, int *anon_rss, int* file_rss)
+{
+	pte_t ptent = *pte;
+	if (pte_none(ptent)) {
+		(*zap_work)--;
+		return;
+	}
+
+	(*zap_work) -= PAGE_SIZE;
+
+	if (pte_present(ptent)) {
+		struct page *page;
+
+		page = vm_normal_page(vma, addr, ptent);
+		if (unlikely(details) && page) {
+			/*
+			 * unmap_shared_mapping_pages() wants to
+			 * invalidate cache without truncating:
+			 * unmap shared but keep private pages.
+			 */
+			if (details->check_mapping &&
+				details->check_mapping != page->mapping)
+				return;
+			/*
+			 * Each page->index must be checked when
+			 * invalidating or truncating nonlinear.
+			 */
+			if (details->nonlinear_vma &&
+				(page->index < details->first_index ||
+				 page->index > details->last_index))
+				return;
+		}
+		ptent = ptep_get_and_clear_full(mm, addr, pte,
+ 
tlb->fullmm);
+		tlb_remove_tlb_entry(tlb, pte, addr);
+		if (unlikely(!page))
+			return;
+		if (unlikely(details) && details->nonlinear_vma
+			&& linear_page_index(details->nonlinear_vma,
+					addr) != page->index)
+			set_pte_at(mm, addr, pte,
+					pgoff_to_pte(page->index));
+		if (PageAnon(page))
+			anon_rss--;
+		else {
+			if (pte_dirty(ptent))
+				set_page_dirty(page);
+			if (pte_young(ptent))
+				mark_page_accessed(page);
+			file_rss--;
+		}
+		page_remove_rmap(page);
+		tlb_remove_page(tlb, page);
+		return;
+	}
+	/*
+	 * If details->check_mapping, we leave swap entries;
+	 * if details->nonlinear_vma, we leave file entries.
+	 */
+	if (unlikely(details))
+		return;
+	if (!pte_file(ptent))
+		free_swap_and_cache(pte_to_swp_entry(ptent));
+	pte_clear_full(mm, addr, pte, tlb->fullmm);
+}
+
+static unsigned long unmap_page_range(struct mmu_gather *tlb,
+		struct vm_area_struct *vma, unsigned long addr, unsigned 
long end,
+		long *zap_work, struct zap_details *details)
+{
+	if (details && !details->check_mapping && !details->nonlinear_vma)
+		details = NULL;
+
+	BUG_ON(addr >= end);
+	tlb_start_vma(tlb, vma);
+	addr = unmap_page_range_iterator(tlb, vma, addr, end, zap_work,
+ 
details, zap_pte);
+	tlb_end_vma(tlb, vma);
+
+	return addr;
+}
+
  #ifdef CONFIG_PREEMPT
  # define ZAP_BLOCK_SIZE	(8 * PAGE_SIZE)
  #else
Index: linux-rc5/include/linux/default-pt-read-iterators.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt-read-iterators.h	2006-05-28 
19:21:07.745014816 +1000
+++ linux-rc5/include/linux/default-pt-read-iterators.h	2006-05-28 
19:21:12.660179344 +1000
@@ -100,4 +100,66 @@
  	return addr;
  }

+/*
+ * vunmap_read_iterator: Called in vmalloc.c
+ */
+
+typedef void (*vunmap_callback_t)(pte_t *, unsigned long);
+
+static void vunmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned 
long end,
+						vunmap_callback_t func )
+{
+	pte_t *pte;
+
+	pte = pte_offset_kernel(pmd, addr);
+	do {
+		func(pte, addr);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+}
+
+static inline void vunmap_pmd_range(pud_t *pud, unsigned long addr,
+						unsigned long end, 
vunmap_callback_t func)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+			vunmap_pte_range(pmd, addr, next, func);
+	} while (pmd++, addr = next, addr != end);
+}
+
+static inline void vunmap_pud_range(pgd_t *pgd, unsigned long addr,
+						unsigned long end, 
vunmap_callback_t func)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		vunmap_pmd_range(pud, addr, next, func);
+	} while (pud++, addr = next, addr != end);
+}
+
+static inline void vunmap_read_iterator(unsigned long addr,
+						unsigned long end, 
vunmap_callback_t func)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	pgd = pgd_offset_k(addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+			vunmap_pud_range(pgd, addr, next, func);
+	} while (pgd++, addr = next, addr != end);
+}
+
  #endif
Index: linux-rc5/mm/vmalloc.c
===================================================================
--- linux-rc5.orig/mm/vmalloc.c	2006-05-28 19:19:51.817221072 +1000
+++ linux-rc5/mm/vmalloc.c	2006-05-28 19:21:10.880671600 +1000
@@ -16,6 +16,8 @@
  #include <linux/interrupt.h>

  #include <linux/vmalloc.h>
+#include <linux/rmap.h>
+#include <linux/default-pt.h>

  #include <asm/uaccess.h>
  #include <asm/tlbflush.h>
@@ -24,63 +26,20 @@
  DEFINE_RWLOCK(vmlist_lock);
  struct vm_struct *vmlist;

-static void vunmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned 
long end)
+static void vunmap_pte(pte_t *pte, unsigned long address)
  {
-	pte_t *pte;
-
-	pte = pte_offset_kernel(pmd, addr);
-	do {
-		pte_t ptent = ptep_get_and_clear(&init_mm, addr, pte);
-		WARN_ON(!pte_none(ptent) && !pte_present(ptent));
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-}
-
-static inline void vunmap_pmd_range(pud_t *pud, unsigned long addr,
-						unsigned long end)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		vunmap_pte_range(pmd, addr, next);
-	} while (pmd++, addr = next, addr != end);
-}
-
-static inline void vunmap_pud_range(pgd_t *pgd, unsigned long addr,
-						unsigned long end)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		vunmap_pmd_range(pud, addr, next);
-	} while (pud++, addr = next, addr != end);
+	pte_t ptent = ptep_get_and_clear(&init_mm, address, pte);
+	WARN_ON(!pte_none(ptent) && !pte_present(ptent));
  }

  void unmap_vm_area(struct vm_struct *area)
  {
-	pgd_t *pgd;
-	unsigned long next;
  	unsigned long addr = (unsigned long) area->addr;
  	unsigned long end = addr + area->size;

  	BUG_ON(addr >= end);
-	pgd = pgd_offset_k(addr);
-	flush_cache_vunmap(addr, end);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		vunmap_pud_range(pgd, addr, next);
-	} while (pgd++, addr = next, addr != end);
+	flush_cache_vunmap(addr, end);
+	vunmap_read_iterator(addr, end, vunmap_pte);
  	flush_tlb_kernel_range((unsigned long) area->addr, end);
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
