From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:28:30 +1000
Message-Id: <20060713042830.9978.36957.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 11/18] PTI - Unmap page range abstraction
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

Abstracts unmap_page_range iterator from memory.c to pt_default.c

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 memory.c     |   96 +++++++----------------------------------------------------
 pt-default.c |   87 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 100 insertions(+), 83 deletions(-)
Index: linux-2.6.17.2/mm/memory.c
===================================================================
--- linux-2.6.17.2.orig/mm/memory.c	2006-07-08 19:43:34.673611200 +1000
+++ linux-2.6.17.2/mm/memory.c	2006-07-08 19:59:51.146361032 +1000
@@ -269,23 +269,14 @@
 	return copy_dual_iterator(dst_mm, src_mm, addr, end, vma);
 }
 
-static unsigned long zap_pte_range(struct mmu_gather *tlb,
-				struct vm_area_struct *vma, pmd_t *pmd,
-				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+void zap_one_pte(pte_t *pte, struct mm_struct *mm, unsigned long addr,
+		struct vm_area_struct *vma, long *zap_work, struct zap_details *details,
+			 struct mmu_gather *tlb, int *anon_rss, int* file_rss)
 {
-	struct mm_struct *mm = tlb->mm;
-	pte_t *pte;
-	spinlock_t *ptl;
-	int file_rss = 0;
-	int anon_rss = 0;
-
-	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
-	do {
 		pte_t ptent = *pte;
 		if (pte_none(ptent)) {
 			(*zap_work)--;
-			continue;
+			return;
 		}
 
 		(*zap_work) -= PAGE_SIZE;
@@ -302,7 +293,7 @@
 				 */
 				if (details->check_mapping &&
 				    details->check_mapping != page->mapping)
-					continue;
+					return;
 				/*
 				 * Each page->index must be checked when
 				 * invalidating or truncating nonlinear.
@@ -310,90 +301,40 @@
 				if (details->nonlinear_vma &&
 				    (page->index < details->first_index ||
 				     page->index > details->last_index))
-					continue;
+					return;
 			}
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 			if (unlikely(!page))
-				continue;
+				return;
 			if (unlikely(details) && details->nonlinear_vma
 			    && linear_page_index(details->nonlinear_vma,
 						addr) != page->index)
 				set_pte_at(mm, addr, pte,
 					   pgoff_to_pte(page->index));
 			if (PageAnon(page))
-				anon_rss--;
+				(*anon_rss)--;
 			else {
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent))
 					mark_page_accessed(page);
-				file_rss--;
+				(*file_rss)--;
 			}
 			page_remove_rmap(page);
 			tlb_remove_page(tlb, page);
-			continue;
+			return;
 		}
 		/*
 		 * If details->check_mapping, we leave swap entries;
 		 * if details->nonlinear_vma, we leave file entries.
 		 */
 		if (unlikely(details))
-			continue;
+			return;
 		if (!pte_file(ptent))
 			free_swap_and_cache(pte_to_swp_entry(ptent));
 		pte_clear_full(mm, addr, pte, tlb->fullmm);
-	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
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
-
-	return addr;
 }
 
 static unsigned long unmap_page_range(struct mmu_gather *tlb,
@@ -401,24 +342,13 @@
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
+
+	addr = unmap_page_range_iterator(tlb, vma, addr, end, zap_work, details);
 	tlb_end_vma(tlb, vma);
 
 	return addr;
Index: linux-2.6.17.2/mm/pt-default.c
===================================================================
--- linux-2.6.17.2.orig/mm/pt-default.c	2006-07-08 19:43:34.672611352 +1000
+++ linux-2.6.17.2/mm/pt-default.c	2006-07-08 19:58:22.610820480 +1000
@@ -399,3 +399,90 @@
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 	return 0;
 }
+
+static unsigned long zap_pte_range(struct mmu_gather *tlb,
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
+	do {
+		zap_one_pte(pte, mm, addr, vma, zap_work, details, tlb, &anon_rss, &file_rss);
+	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
+
+	add_mm_rss(mm, file_rss, anon_rss);
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
