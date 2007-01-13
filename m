From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:47:10 +1100
Message-Id: <20070113024710.29682.21692.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 17/29] Finish abstracting unmap page range
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 17
 * A function called zap_one_pte has been abstracted from the
 unmap_page_range iterator and put into pt-iterator-ops.h
 * Put implementation of unmap_page_range iterator for default page
 table into pt-default.c

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/pt-iterator-ops.h |   68 ++++++++++++++++++++++++++++++
 mm/pt-default.c                 |   89 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 157 insertions(+)
Index: linux-2.6.20-rc4/include/linux/pt-iterator-ops.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt-iterator-ops.h	2007-01-11 13:37:23.136438000 +1100
+++ linux-2.6.20-rc4/include/linux/pt-iterator-ops.h	2007-01-11 13:37:35.728438000 +1100
@@ -77,3 +77,71 @@
 out_set_pte:
 	set_pte_at(dst_mm, addr, dst_pte, pte);
 }
+
+static inline void zap_one_pte(pte_t *pte, struct mm_struct *mm, unsigned long addr,
+		struct vm_area_struct *vma, long *zap_work, struct zap_details *details,
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
+			    details->check_mapping != page->mapping)
+				return;
+			/*
+			 * Each page->index must be checked when
+			 * invalidating or truncating nonlinear.
+			 */
+			if (details->nonlinear_vma &&
+			    (page->index < details->first_index ||
+			     page->index > details->last_index))
+				return;
+		}
+		ptent = ptep_get_and_clear_full(mm, addr, pte,
+						tlb->fullmm);
+		tlb_remove_tlb_entry(tlb, pte, addr);
+		if (unlikely(!page))
+			return;
+		if (unlikely(details) && details->nonlinear_vma
+		    && linear_page_index(details->nonlinear_vma,
+					addr) != page->index)
+			set_pte_at(mm, addr, pte,
+				   pgoff_to_pte(page->index));
+		if (PageAnon(page))
+			(*anon_rss)--;
+		else {
+			if (pte_dirty(ptent))
+				set_page_dirty(page);
+			if (pte_young(ptent))
+				mark_page_accessed(page);
+			(*file_rss)--;
+		}
+		page_remove_rmap(page,vma);
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
+	pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
+}
Index: linux-2.6.20-rc4/mm/pt-default.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/pt-default.c	2007-01-11 13:37:23.140438000 +1100
+++ linux-2.6.20-rc4/mm/pt-default.c	2007-01-11 13:37:35.728438000 +1100
@@ -405,3 +405,92 @@
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 	return 0;
 }
+
+static inline unsigned long zap_pte_range(struct mmu_gather *tlb,
+				struct vm_area_struct *vma, pmd_t *pmd,
+				unsigned long addr, unsigned long end,
+				long *zap_work, struct zap_details *details)
+{
+	struct mm_struct *mm = tlb->mm;
+	pte_t *pte;
+	spinlock_t *ptl;
+	int file_rss = 0;
+	int anon_rss = 0;
+
+	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	arch_enter_lazy_mmu_mode();
+	do {
+		zap_one_pte(pte, mm, addr, vma, zap_work, details, tlb, &anon_rss, &file_rss);
+	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
+
+	add_mm_rss(mm, file_rss, anon_rss);
+	arch_leave_lazy_mmu_mode();
+	pte_unmap_unlock(pte - 1, ptl);
+
+	return addr;
+}
+
+static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
+				struct vm_area_struct *vma, pud_t *pud,
+				unsigned long addr, unsigned long end,
+				long *zap_work, struct zap_details *details)
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
+						zap_work, details);
+	} while (pmd++, addr = next, (addr != end && *zap_work > 0));
+
+	return addr;
+}
+
+static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
+				struct vm_area_struct *vma, pgd_t *pgd,
+				unsigned long addr, unsigned long end,
+				long *zap_work, struct zap_details *details)
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
+						zap_work, details);
+	} while (pud++, addr = next, (addr != end && *zap_work > 0));
+
+	return addr;
+}
+
+unsigned long unmap_page_range_iterator(struct mmu_gather *tlb,
+		struct vm_area_struct *vma, unsigned long addr, unsigned long end,
+		long *zap_work, struct zap_details *details)
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
+							 details);
+	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
+
+	return addr;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
