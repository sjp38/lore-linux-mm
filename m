Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By note With Smtp ;
	Tue, 30 May 2006 17:30:00 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:29:59 +1000 (EST)
Subject: [Patch 10/17] PTI: Abstract unmap_page_range iterator
Message-ID: <Pine.LNX.4.61.0605301728350.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Added implementation dependent partial lookups to default-pt-mm.h (needed
  for mremap syscall).

  Abstracted the unmap_page_range iterator to default-pt-read-iterators.h

  include/linux/default-pt-mm.h             |   49 +++++++++
  include/linux/default-pt-read-iterators.h |  103 +++++++++++++++++++
  mm/memory.c                               |  155 
------------------------------
  3 files changed, 152 insertions(+), 155 deletions(-)
Index: linux-rc5/include/linux/default-pt-mm.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt-mm.h	2006-05-28 
19:19:46.173079112 +1000
+++ linux-rc5/include/linux/default-pt-mm.h	2006-05-28 
19:19:46.308058592 +1000
@@ -24,6 +24,55 @@
  }
  #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */

+static inline pmd_t *lookup_pmd(struct mm_struct *mm, unsigned long 
address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	if (mm!=&init_mm) { /* Look up user page table */
+		pgd = pgd_offset(mm, address);
+		if (pgd_none_or_clear_bad(pgd))
+			return NULL;
+	} else {            /* Look up kernel page table */
+		pgd = pgd_offset_k(address);
+		if (pgd_none_or_clear_bad(pgd))
+			return NULL;
+	}
+
+	pud = pud_offset(pgd, address);
+	if (pud_none_or_clear_bad(pud)) {
+		return NULL;
+	}
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none_or_clear_bad(pmd)) {
+		return NULL;
+	}
+
+	return pmd;
+}
+
+static inline pmd_t *build_pmd(struct mm_struct *mm, unsigned long addr)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_offset(mm, addr);
+	pud = pud_alloc(mm, pgd, addr);
+	if (!pud)
+		return NULL;
+
+	pmd = pmd_alloc(mm, pud, addr);
+	if (!pmd)
+		return NULL;
+
+	if (!pmd_present(*pmd) && __pte_alloc(mm, pmd, addr))
+		return NULL;
+
+	return pmd;
+}

  #if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
  /*
Index: linux-rc5/include/linux/default-pt-read-iterators.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-rc5/include/linux/default-pt-read-iterators.h	2006-05-28 
19:19:51.817221072 +1000
@@ -0,0 +1,103 @@
+#ifndef _LINUX_DEFAULT_PT_READ_ITERATORS_H
+#define _LINUX_DEFAULT_PT_READ_ITERATORS_H 1
+
+/******************************************************************************/
+/*                              READ ITERATORS 
*/
+/******************************************************************************/
+
+/*
+ * unmap_page_range read iterator. Called in memory.c
+ */
+
+typedef void (*zap_pte_callback_t) (pte_t *, struct mm_struct *, unsigned 
long,
+			struct vm_area_struct *, long *, struct 
zap_details *,
+			struct mmu_gather *, int *, int *);
+
+static inline unsigned long zap_pte_range(struct mmu_gather *tlb,
+			struct vm_area_struct *vma, pmd_t *pmd, unsigned 
long addr,
+			unsigned long end, long *zap_work, struct 
zap_details *details,
+			zap_pte_callback_t func)
+{
+	struct mm_struct *mm = tlb->mm;
+	pte_t *pte;
+	spinlock_t *ptl;
+	int file_rss = 0;
+	int anon_rss = 0;
+
+	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	do {
+		func(pte, mm, addr, vma, zap_work, details, tlb, 
&anon_rss, &file_rss);
+	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 
0));
+
+	add_mm_rss(mm, file_rss, anon_rss);
+	pte_unmap_unlock(pte - 1, ptl);
+
+	return addr;
+}
+
+static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
+		struct vm_area_struct *vma, pud_t *pud, unsigned long 
addr,
+		unsigned long end, long *zap_work, struct zap_details 
*details,
+		zap_pte_callback_t func)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd)) {
+			(*zap_work)--;
+			continue;
+		}
+		next = zap_pte_range(tlb, vma, pmd, addr, next,
+						zap_work, details, func);
+	} while (pmd++, addr = next, (addr != end && *zap_work > 0));
+
+	return addr;
+}
+
+static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
+		struct vm_area_struct *vma, pgd_t *pgd, unsigned long 
addr,
+		unsigned long end, long *zap_work, struct zap_details 
*details,
+		zap_pte_callback_t func)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud)) {
+			(*zap_work)--;
+			continue;
+		}
+		next = zap_pmd_range(tlb, vma, pud, addr, next,
+						zap_work, details, func);
+	} while (pud++, addr = next, (addr != end && *zap_work > 0));
+
+	return addr;
+}
+
+static inline unsigned long unmap_page_range_iterator(struct mmu_gather 
*tlb,
+		struct vm_area_struct *vma, unsigned long addr, unsigned 
long end,
+		long *zap_work, struct zap_details *details, 
zap_pte_callback_t func)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	pgd = pgd_offset(vma->vm_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd)) {
+			(*zap_work)--;
+			continue;
+		}
+		next = zap_pud_range(tlb, vma, pgd, addr, next, zap_work,
+							 details, func);
+	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
+
+	return addr;
+}
+
+#endif
Index: linux-rc5/mm/memory.c
===================================================================
--- linux-rc5.orig/mm/memory.c	2006-05-28 19:19:46.292061024 +1000
+++ linux-rc5/mm/memory.c	2006-05-28 19:19:51.817221072 +1000
@@ -273,161 +273,6 @@
  	return 0;
  }

-static unsigned long zap_pte_range(struct mmu_gather *tlb,
-				struct vm_area_struct *vma, pmd_t *pmd,
-				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details 
*details)
-{
-	struct mm_struct *mm = tlb->mm;
-	pte_t *pte;
-	spinlock_t *ptl;
-	int file_rss = 0;
-	int anon_rss = 0;
-
-	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
-	do {
-		pte_t ptent = *pte;
-		if (pte_none(ptent)) {
-			(*zap_work)--;
-			continue;
-		}
-
-		(*zap_work) -= PAGE_SIZE;
-
-		if (pte_present(ptent)) {
-			struct page *page;
-
-			page = vm_normal_page(vma, addr, ptent);
-			if (unlikely(details) && page) {
-				/*
-				 * unmap_shared_mapping_pages() wants to
-				 * invalidate cache without truncating:
-				 * unmap shared but keep private pages.
-				 */
-				if (details->check_mapping &&
-				    details->check_mapping != 
page->mapping)
-					continue;
-				/*
-				 * Each page->index must be checked when
-				 * invalidating or truncating nonlinear.
-				 */
-				if (details->nonlinear_vma &&
-				    (page->index < details->first_index ||
-				     page->index > details->last_index))
-					continue;
-			}
-			ptent = ptep_get_and_clear_full(mm, addr, pte,
-							tlb->fullmm);
-			tlb_remove_tlb_entry(tlb, pte, addr);
-			if (unlikely(!page))
-				continue;
-			if (unlikely(details) && details->nonlinear_vma
-			    && linear_page_index(details->nonlinear_vma,
-						addr) != page->index)
-				set_pte_at(mm, addr, pte,
-					   pgoff_to_pte(page->index));
-			if (PageAnon(page))
-				anon_rss--;
-			else {
-				if (pte_dirty(ptent))
-					set_page_dirty(page);
-				if (pte_young(ptent))
-					mark_page_accessed(page);
-				file_rss--;
-			}
-			page_remove_rmap(page);
-			tlb_remove_page(tlb, page);
-			continue;
-		}
-		/*
-		 * If details->check_mapping, we leave swap entries;
-		 * if details->nonlinear_vma, we leave file entries.
-		 */
-		if (unlikely(details))
-			continue;
-		if (!pte_file(ptent))
-			free_swap_and_cache(pte_to_swp_entry(ptent));
-		pte_clear_full(mm, addr, pte, tlb->fullmm);
-	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 
0));
-
-	add_mm_rss(mm, file_rss, anon_rss);
-	pte_unmap_unlock(pte - 1, ptl);
-
-	return addr;
-}
-
-static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
-				struct vm_area_struct *vma, pud_t *pud,
-				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details 
*details)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd)) {
-			(*zap_work)--;
-			continue;
-		}
-		next = zap_pte_range(tlb, vma, pmd, addr, next,
-						zap_work, details);
-	} while (pmd++, addr = next, (addr != end && *zap_work > 0));
-
-	return addr;
-}
-
-static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
-				struct vm_area_struct *vma, pgd_t *pgd,
-				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details 
*details)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud)) {
-			(*zap_work)--;
-			continue;
-		}
-		next = zap_pmd_range(tlb, vma, pud, addr, next,
-						zap_work, details);
-	} while (pud++, addr = next, (addr != end && *zap_work > 0));
-
-	return addr;
-}
-
-static unsigned long unmap_page_range(struct mmu_gather *tlb,
-				struct vm_area_struct *vma,
-				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details 
*details)
-{
-	pgd_t *pgd;
-	unsigned long next;
-
-	if (details && !details->check_mapping && !details->nonlinear_vma)
-		details = NULL;
-
-	BUG_ON(addr >= end);
-	tlb_start_vma(tlb, vma);
-	pgd = pgd_offset(vma->vm_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd)) {
-			(*zap_work)--;
-			continue;
-		}
-		next = zap_pud_range(tlb, vma, pgd, addr, next,
-						zap_work, details);
-	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
-	tlb_end_vma(tlb, vma);
-
-	return addr;
-}
-
  #ifdef CONFIG_PREEMPT
  # define ZAP_BLOCK_SIZE	(8 * PAGE_SIZE)
  #else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
