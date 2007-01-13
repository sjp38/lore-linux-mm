From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:48:03 +1100
Message-Id: <20070113024803.29682.7531.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 27/29] Abstract implementation dependent code for mremap
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 27
 * Moved implementation dependent page table code from mremap.c to
 pt_default.c. move_page_tables has been made part of the page table interface.
   * Added partial page table lookup functions to pt-default-mm.h to
   facilitate the abstraction of the page table dependent code.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/pt-default-mm.h |   49 +++++++++++++++
 mm/mremap.c                   |  133 ------------------------------------------
 mm/pt-default.c               |   90 ++++++++++++++++++++++++++++
 3 files changed, 140 insertions(+), 132 deletions(-)
Index: linux-2.6.20-rc4/mm/mremap.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/mremap.c	2007-01-11 12:40:58.728788000 +1100
+++ linux-2.6.20-rc4/mm/mremap.c	2007-01-11 12:41:42.240788000 +1100
@@ -18,143 +18,12 @@
 #include <linux/highmem.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
+#include <linux/pt.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-static pmd_t *get_old_pmd(struct mm_struct *mm, unsigned long addr)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-
-	pgd = pgd_offset(mm, addr);
-	if (pgd_none_or_clear_bad(pgd))
-		return NULL;
-
-	pud = pud_offset(pgd, addr);
-	if (pud_none_or_clear_bad(pud))
-		return NULL;
-
-	pmd = pmd_offset(pud, addr);
-	if (pmd_none_or_clear_bad(pmd))
-		return NULL;
-
-	return pmd;
-}
-
-static pmd_t *alloc_new_pmd(struct mm_struct *mm, unsigned long addr)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-
-	pgd = pgd_offset(mm, addr);
-	pud = pud_alloc(mm, pgd, addr);
-	if (!pud)
-		return NULL;
-
-	pmd = pmd_alloc(mm, pud, addr);
-	if (!pmd)
-		return NULL;
-
-	if (!pmd_present(*pmd) && __pte_alloc(mm, pmd, addr))
-		return NULL;
-
-	return pmd;
-}
-
-static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
-		unsigned long old_addr, unsigned long old_end,
-		struct vm_area_struct *new_vma, pmd_t *new_pmd,
-		unsigned long new_addr)
-{
-	struct address_space *mapping = NULL;
-	struct mm_struct *mm = vma->vm_mm;
-	pte_t *old_pte, *new_pte, pte;
-	spinlock_t *old_ptl, *new_ptl;
-
-	if (vma->vm_file) {
-		/*
-		 * Subtle point from Rajesh Venkatasubramanian: before
-		 * moving file-based ptes, we must lock vmtruncate out,
-		 * since it might clean the dst vma before the src vma,
-		 * and we propagate stale pages into the dst afterward.
-		 */
-		mapping = vma->vm_file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
-		if (new_vma->vm_truncate_count &&
-		    new_vma->vm_truncate_count != vma->vm_truncate_count)
-			new_vma->vm_truncate_count = 0;
-	}
-
-	/*
-	 * We don't have to worry about the ordering of src and dst
-	 * pte locks because exclusive mmap_sem prevents deadlock.
-	 */
-	old_pte = pte_offset_map_lock(mm, old_pmd, old_addr, &old_ptl);
- 	new_pte = pte_offset_map_nested(new_pmd, new_addr);
-	new_ptl = pte_lockptr(mm, new_pmd);
-	if (new_ptl != old_ptl)
-		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
-	arch_enter_lazy_mmu_mode();
-
-	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
-				   new_pte++, new_addr += PAGE_SIZE) {
-		if (pte_none(*old_pte))
-			continue;
-		pte = ptep_clear_flush(vma, old_addr, old_pte);
-		/* ZERO_PAGE can be dependant on virtual addr */
-		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
-		set_pte_at(mm, new_addr, new_pte, pte);
-	}
-
-	arch_leave_lazy_mmu_mode();
-	if (new_ptl != old_ptl)
-		spin_unlock(new_ptl);
-	pte_unmap_nested(new_pte - 1);
-	pte_unmap_unlock(old_pte - 1, old_ptl);
-	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
-}
-
-#define LATENCY_LIMIT	(64 * PAGE_SIZE)
-
-static unsigned long move_page_tables(struct vm_area_struct *vma,
-		unsigned long old_addr, struct vm_area_struct *new_vma,
-		unsigned long new_addr, unsigned long len)
-{
-	unsigned long extent, next, old_end;
-	pmd_t *old_pmd, *new_pmd;
-
-	old_end = old_addr + len;
-	flush_cache_range(vma, old_addr, old_end);
-
-	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
-		cond_resched();
-		next = (old_addr + PMD_SIZE) & PMD_MASK;
-		if (next - 1 > old_end)
-			next = old_end;
-		extent = next - old_addr;
-		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
-		if (!old_pmd)
-			continue;
-		new_pmd = alloc_new_pmd(vma->vm_mm, new_addr);
-		if (!new_pmd)
-			break;
-		next = (new_addr + PMD_SIZE) & PMD_MASK;
-		if (extent > next - new_addr)
-			extent = next - new_addr;
-		if (extent > LATENCY_LIMIT)
-			extent = LATENCY_LIMIT;
-		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
-				new_vma, new_pmd, new_addr);
-	}
-
-	return len + old_addr - old_end;	/* how much done */
-}
-
 static unsigned long move_vma(struct vm_area_struct *vma,
 		unsigned long old_addr, unsigned long old_len,
 		unsigned long new_len, unsigned long new_addr)
Index: linux-2.6.20-rc4/mm/pt-default.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/pt-default.c	2007-01-11 12:40:58.728788000 +1100
+++ linux-2.6.20-rc4/mm/pt-default.c	2007-01-11 12:41:42.240788000 +1100
@@ -1058,3 +1058,93 @@
 }
 
 #endif
+
+static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
+		unsigned long old_addr, unsigned long old_end,
+		struct vm_area_struct *new_vma, pmd_t *new_pmd,
+		unsigned long new_addr)
+{
+	struct address_space *mapping = NULL;
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t *old_pte, *new_pte, pte;
+	spinlock_t *old_ptl, *new_ptl;
+
+	if (vma->vm_file) {
+		/*
+		 * Subtle point from Rajesh Venkatasubramanian: before
+		 * moving file-based ptes, we must lock vmtruncate out,
+		 * since it might clean the dst vma before the src vma,
+		 * and we propagate stale pages into the dst afterward.
+		 */
+		mapping = vma->vm_file->f_mapping;
+		spin_lock(&mapping->i_mmap_lock);
+		if (new_vma->vm_truncate_count &&
+		    new_vma->vm_truncate_count != vma->vm_truncate_count)
+			new_vma->vm_truncate_count = 0;
+	}
+
+	/*
+	 * We don't have to worry about the ordering of src and dst
+	 * pte locks because exclusive mmap_sem prevents deadlock.
+	 */
+	old_pte = pte_offset_map_lock(mm, old_pmd, old_addr, &old_ptl);
+ 	new_pte = pte_offset_map_nested(new_pmd, new_addr);
+	new_ptl = pte_lockptr(mm, new_pmd);
+	if (new_ptl != old_ptl)
+		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
+	arch_enter_lazy_mmu_mode();
+
+	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
+				   new_pte++, new_addr += PAGE_SIZE) {
+		if (pte_none(*old_pte))
+			continue;
+		pte = ptep_clear_flush(vma, old_addr, old_pte);
+		/* ZERO_PAGE can be dependant on virtual addr */
+		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
+		set_pte_at(mm, new_addr, new_pte, pte);
+	}
+
+	arch_leave_lazy_mmu_mode();
+	if (new_ptl != old_ptl)
+		spin_unlock(new_ptl);
+	pte_unmap_nested(new_pte - 1);
+	pte_unmap_unlock(old_pte - 1, old_ptl);
+	if (mapping)
+		spin_unlock(&mapping->i_mmap_lock);
+}
+
+#define LATENCY_LIMIT	(64 * PAGE_SIZE)
+
+unsigned long move_page_tables(struct vm_area_struct *vma,
+		unsigned long old_addr, struct vm_area_struct *new_vma,
+		unsigned long new_addr, unsigned long len)
+{
+	unsigned long extent, next, old_end;
+	pmd_t *old_pmd, *new_pmd;
+
+	old_end = old_addr + len;
+	flush_cache_range(vma, old_addr, old_end);
+
+	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
+		cond_resched();
+		next = (old_addr + PMD_SIZE) & PMD_MASK;
+		if (next - 1 > old_end)
+			next = old_end;
+		extent = next - old_addr;
+		old_pmd = lookup_pmd(vma->vm_mm, old_addr);
+		if (!old_pmd)
+			continue;
+		new_pmd = build_pmd(vma->vm_mm, new_addr);
+		if (!new_pmd)
+			break;
+		next = (new_addr + PMD_SIZE) & PMD_MASK;
+		if (extent > next - new_addr)
+			extent = next - new_addr;
+		if (extent > LATENCY_LIMIT)
+			extent = LATENCY_LIMIT;
+		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
+				new_vma, new_pmd, new_addr);
+	}
+
+	return len + old_addr - old_end;	/* how much done */
+}
Index: linux-2.6.20-rc4/include/linux/pt-default-mm.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt-default-mm.h	2007-01-11 12:40:58.752788000 +1100
+++ linux-2.6.20-rc4/include/linux/pt-default-mm.h	2007-01-11 12:41:42.268788000 +1100
@@ -72,5 +72,54 @@
 	((unlikely(!pmd_present(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
 		NULL: pte_offset_kernel(pmd, address))
 
+static inline pmd_t *lookup_pmd(struct mm_struct *mm, unsigned long address)
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
 
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
