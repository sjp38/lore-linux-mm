From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:47:04 +1100
Message-Id: <20070113024704.29682.8753.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 16/29] Abstract unmap page range iterator
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 16
 * Remove add_mm_rss from memory.c (now only required in pt-iterator-ops.h)
 * Start shift of default page table unmap page range iterator implementation
 into pt_default.c. Call unmap_page_range_iterator from the interface.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 memory.c |  149 ---------------------------------------------------------------
 1 file changed, 1 insertion(+), 148 deletions(-)
Index: linux-2.6.20-rc4/mm/memory.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/memory.c	2007-01-11 13:37:23.140438000 +1100
+++ linux-2.6.20-rc4/mm/memory.c	2007-01-11 13:37:23.960438000 +1100
@@ -122,14 +122,6 @@
 	}
 }
 
-static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
-{
-	if (file_rss)
-		add_mm_counter(mm, file_rss, file_rss);
-	if (anon_rss)
-		add_mm_counter(mm, anon_rss, anon_rss);
-}
-
 /*
  * This function is called to print an error when a bad pte
  * is found. For example, we might have a PFN-mapped pte in
@@ -223,158 +215,19 @@
 	return copy_dual_iterator(dst_mm, src_mm, addr, end, vma);
 }
 
-static unsigned long zap_pte_range(struct mmu_gather *tlb,
-				struct vm_area_struct *vma, pmd_t *pmd,
-				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
-{
-	struct mm_struct *mm = tlb->mm;
-	pte_t *pte;
-	spinlock_t *ptl;
-	int file_rss = 0;
-	int anon_rss = 0;
-
-	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
-	arch_enter_lazy_mmu_mode();
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
-				    details->check_mapping != page->mapping)
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
-			page_remove_rmap(page, vma);
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
-		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
-	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
-
-	add_mm_rss(mm, file_rss, anon_rss);
-	arch_leave_lazy_mmu_mode();
-	pte_unmap_unlock(pte - 1, ptl);
-
-	return addr;
-}
-
-static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
-				struct vm_area_struct *vma, pud_t *pud,
-				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
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
-				long *zap_work, struct zap_details *details)
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
 
-	return addr;
-}
 
 static unsigned long unmap_page_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma,
 				unsigned long addr, unsigned long end,
 				long *zap_work, struct zap_details *details)
 {
-	pgd_t *pgd;
-	unsigned long next;
-
 	if (details && !details->check_mapping && !details->nonlinear_vma)
 		details = NULL;
 
 	BUG_ON(addr >= end);
 	tlb_start_vma(tlb, vma);
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
+	addr = unmap_page_range_iterator(tlb, vma, addr, end, zap_work, details);
 	tlb_end_vma(tlb, vma);
 
 	return addr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
