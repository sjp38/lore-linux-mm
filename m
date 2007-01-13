From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:47:15 +1100
Message-Id: <20070113024715.29682.712.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 18/29] Abstract zeromap page range
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 18 
 * Move zeromap_page_range iterator implemtenation from memory.c to pt-default.c
 * Abstract an operator function zeromap_one_pte from this iterator during
 the process and put it into pt-iterator-ops.h

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/pt-iterator-ops.h |   12 ++++++
 include/linux/pt.h              |    1 
 mm/memory.c                     |   78 ----------------------------------------
 mm/pt-default.c                 |   67 ++++++++++++++++++++++++++++++++++
 4 files changed, 81 insertions(+), 77 deletions(-)
Index: linux-2.6.20-rc4/mm/pt-default.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/pt-default.c	2007-01-11 13:37:35.728438000 +1100
+++ linux-2.6.20-rc4/mm/pt-default.c	2007-01-11 13:37:46.828438000 +1100
@@ -494,3 +494,70 @@
 
 	return addr;
 }
+
+static int zeromap_pte_range(struct mm_struct *mm, pmd_t *pmd,
+			unsigned long addr, unsigned long end, pgprot_t prot)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
+	if (!pte)
+		return -ENOMEM;
+	arch_enter_lazy_mmu_mode();
+	do {
+		zeromap_one_pte(mm, pte, addr, prot);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	arch_leave_lazy_mmu_mode();
+	pte_unmap_unlock(pte - 1, ptl);
+	return 0;
+}
+
+static inline int zeromap_pmd_range(struct mm_struct *mm, pud_t *pud,
+			unsigned long addr, unsigned long end, pgprot_t prot)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_alloc(mm, pud, addr);
+	if (!pmd)
+		return -ENOMEM;
+	do {
+		next = pmd_addr_end(addr, end);
+		if (zeromap_pte_range(mm, pmd, addr, next, prot))
+			return -ENOMEM;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int zeromap_pud_range(struct mm_struct *mm, pgd_t *pgd,
+			unsigned long addr, unsigned long end, pgprot_t prot)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_alloc(mm, pgd, addr);
+	if (!pud)
+		return -ENOMEM;
+	do {
+		next = pud_addr_end(addr, end);
+		if (zeromap_pmd_range(mm, pud, addr, next, prot))
+			return -ENOMEM;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+int zeromap_build_iterator(struct mm_struct *mm,
+			unsigned long addr, unsigned long end, pgprot_t prot)
+{
+	unsigned long next;
+	pgd_t *pgd;
+
+	pgd = pgd_offset(mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if(zeromap_pud_range(mm, pgd, addr, next, prot))
+		  	return -ENOMEM;
+	} while (pgd++, addr = next, addr != end);
+	return 0;
+}
Index: linux-2.6.20-rc4/include/linux/pt-iterator-ops.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt-iterator-ops.h	2007-01-11 13:37:35.728438000 +1100
+++ linux-2.6.20-rc4/include/linux/pt-iterator-ops.h	2007-01-11 13:37:46.832438000 +1100
@@ -145,3 +145,15 @@
 		free_swap_and_cache(pte_to_swp_entry(ptent));
 	pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 }
+
+static inline void
+zeromap_one_pte(struct mm_struct *mm, pte_t *pte, unsigned long addr, pgprot_t prot)
+{
+	struct page *page = ZERO_PAGE(addr);
+	pte_t zero_pte = pte_wrprotect(mk_pte(page, prot));
+	page_cache_get(page);
+	page_add_file_rmap(page);
+	inc_mm_counter(mm, file_rss);
+	BUG_ON(!pte_none(*pte));
+	set_pte_at(mm, addr, pte, zero_pte);
+}
Index: linux-2.6.20-rc4/include/linux/pt.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt.h	2007-01-11 13:37:17.200438000 +1100
+++ linux-2.6.20-rc4/include/linux/pt.h	2007-01-11 13:37:46.832438000 +1100
@@ -20,6 +20,7 @@
 void free_pt_range(struct mmu_gather **tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 
+/* Iterators for memory.c */
 int copy_dual_iterator(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		unsigned long addr, unsigned long end, struct vm_area_struct *vma);
 
Index: linux-2.6.20-rc4/mm/memory.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/memory.c	2007-01-11 13:37:23.960438000 +1100
+++ linux-2.6.20-rc4/mm/memory.c	2007-01-11 13:37:46.832438000 +1100
@@ -537,92 +537,16 @@
 }
 EXPORT_SYMBOL(get_user_pages);
 
-static int zeromap_pte_range(struct mm_struct *mm, pmd_t *pmd,
-			unsigned long addr, unsigned long end, pgprot_t prot)
-{
-	pte_t *pte;
-	spinlock_t *ptl;
-	int err = 0;
-
-	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
-	if (!pte)
-		return -EAGAIN;
-	arch_enter_lazy_mmu_mode();
-	do {
-		struct page *page = ZERO_PAGE(addr);
-		pte_t zero_pte = pte_wrprotect(mk_pte(page, prot));
-
-		if (unlikely(!pte_none(*pte))) {
-			err = -EEXIST;
-			pte++;
-			break;
-		}
-		page_cache_get(page);
-		page_add_file_rmap(page);
-		inc_mm_counter(mm, file_rss);
-		set_pte_at(mm, addr, pte, zero_pte);
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	arch_leave_lazy_mmu_mode();
-	pte_unmap_unlock(pte - 1, ptl);
-	return err;
-}
-
-static inline int zeromap_pmd_range(struct mm_struct *mm, pud_t *pud,
-			unsigned long addr, unsigned long end, pgprot_t prot)
-{
-	pmd_t *pmd;
-	unsigned long next;
-	int err;
-
-	pmd = pmd_alloc(mm, pud, addr);
-	if (!pmd)
-		return -EAGAIN;
-	do {
-		next = pmd_addr_end(addr, end);
-		err = zeromap_pte_range(mm, pmd, addr, next, prot);
-		if (err)
-			break;
-	} while (pmd++, addr = next, addr != end);
-	return err;
-}
-
-static inline int zeromap_pud_range(struct mm_struct *mm, pgd_t *pgd,
-			unsigned long addr, unsigned long end, pgprot_t prot)
-{
-	pud_t *pud;
-	unsigned long next;
-	int err;
-
-	pud = pud_alloc(mm, pgd, addr);
-	if (!pud)
-		return -EAGAIN;
-	do {
-		next = pud_addr_end(addr, end);
-		err = zeromap_pmd_range(mm, pud, addr, next, prot);
-		if (err)
-			break;
-	} while (pud++, addr = next, addr != end);
-	return err;
-}
-
 int zeromap_page_range(struct vm_area_struct *vma,
 			unsigned long addr, unsigned long size, pgprot_t prot)
 {
-	pgd_t *pgd;
-	unsigned long next;
 	unsigned long end = addr + size;
 	struct mm_struct *mm = vma->vm_mm;
 	int err;
 
 	BUG_ON(addr >= end);
-	pgd = pgd_offset(mm, addr);
 	flush_cache_range(vma, addr, end);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = zeromap_pud_range(mm, pgd, addr, next, prot);
-		if (err)
-			break;
-	} while (pgd++, addr = next, addr != end);
+	err = zeromap_build_iterator(mm, addr, end, prot);
 	return err;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
