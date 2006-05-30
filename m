Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By tone With Smtp ;
	Tue, 30 May 2006 17:06:28 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:06:27 +1000 (EST)
Subject: [Patch 1/17] PTI: Introduce simple interface
Message-ID: <Pine.LNX.4.61.0605301701521.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

PATCH 1
  This patch introduces the page table interface with the exception of
  the iterators (the iterators are introduced individually later on).

  default-pt.h contains the interface and much of its implementation.  This
  includes the ability to create, destroy, build and lookup a page table.

  default-pt.c is to contain the rest of the implementation of the default
  page table.  Some implementation is moved from memory.c to here in this 
patch.

  include/linux/default-pt.h |  177 
+++++++++++++++++++++++++++++++++++++++++++++
  mm/default-pt.c            |  140 +++++++++++++++++++++++++++++++++++
  2 files changed, 317 insertions(+)
Index: linux-rc5/include/linux/default-pt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-rc5/include/linux/default-pt.h	2006-05-28 
00:59:58.031357384 +1000
@@ -0,0 +1,177 @@
+#ifndef _LINUX_DEFAULT_PT_H
+#define _LINUX_DEFAULT_PT_H
+
+#include <asm/pgalloc.h>
+#include <asm/pgtable.h>
+
+/*
+ * This is the structure representing the path of the pte in
+ * the page table.  For efficiency reasons we store the partial
+ * path only
+ */
+typedef struct pt_struct { pmd_t *pmd; } pt_path_t;
+
+static inline int create_user_page_table(struct mm_struct *mm)
+{
+	mm->pgd = pgd_alloc(NULL);
+
+	if (unlikely(!mm->pgd))
+		return 0;
+	return 1;
+}
+
+static inline void destroy_user_page_table(struct mm_struct *mm)
+{
+	pgd_free(mm->pgd);
+}
+
+static inline pte_t *lookup_page_table(struct mm_struct *mm,
+			unsigned long address, pt_path_t *pt_path)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	if (mm!=&init_mm) { /* Look up user page table */
+		pgd = pgd_offset(mm, address);
+		if (pgd_none_or_clear_bad(pgd))
+			return NULL;
+	} else { /* Look up kernel page table */
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
+	if(!pt_path)
+		pt_path->pmd = pmd;
+
+	return pte_offset_map(pmd, address);
+}
+
+static inline pte_t *lookup_gate_area(struct mm_struct *mm,
+			unsigned long pg)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	if (pg > TASK_SIZE)
+		pgd = pgd_offset_k(pg);
+	else
+		pgd = pgd_offset_gate(mm, pg);
+	BUG_ON(pgd_none(*pgd));
+	pud = pud_offset(pgd, pg);
+	BUG_ON(pud_none(*pud));
+	pmd = pmd_offset(pud, pg);
+	if (pmd_none(*pmd))
+		return NULL;
+	pte = pte_offset_map(pmd, pg);
+	return pte;
+}
+
+/*
+ * This function builds the page table atomically and saves
+ * the partial path for a fast lookup later on.
+ */
+static inline pte_t *build_page_table(struct mm_struct *mm,
+		unsigned long address, pt_path_t *pt_path)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_offset(mm, address);
+	pud = pud_alloc(mm, pgd, address);
+	if (!pud)
+		return NULL;
+	pmd = pmd_alloc(mm, pud, address);
+	if (!pmd)
+		return NULL;
+
+	pt_path->pmd = pmd;
+	return pte_alloc_map(mm, pmd, address);
+}
+
+/*
+ * Locks the ptes notionally pointed to by the page table path.
+ */
+#define lock_pte(mm, pt_path) \
+	({ spin_lock(pte_lockptr(mm, pt_path.pmd));})
+
+/*
+ * Unlocks the ptes notionally pointed to by the
+ * page table path.
+ */
+#define unlock_pte(mm, pt_path) \
+	({ spin_unlock(pte_lockptr(mm, pt_path.pmd)); })
+
+/*
+ * Looks up a page table from a saved path.  It also
+ * locks the page table.
+ */
+#define lookup_page_table_fast(mm, pt_path, address)	\
+({							\
+	spinlock_t *__ptl = pte_lockptr(mm, pt_path.pmd);	\
+	pte_t *__pte = pte_offset_map(pt_path.pmd, address);	\
+	spin_lock(__ptl);				\
+	__pte;						\
+})
+
+/*
+ * Check that the original pte hasn't change.
+ */
+#define atomic_pte_same(mm, pte, orig_pte, pt_path) \
+({ \
+	spinlock_t *ptl = pte_lockptr(mm, pt_path.pmd); \
+	int __same; \
+	spin_lock(ptl); \
+	__same = pte_same(*pte, orig_pte); \
+	spin_unlock(ptl); \
+	__same; \
+})
+
+void free_page_table_range(struct mmu_gather **tlb, unsigned long addr,
+		unsigned long end, unsigned long floor, unsigned long 
ceiling);
+
+
+
+
+
+
+static inline void coallesce_vmas(struct vm_area_struct **vma_p,
+		struct vm_area_struct **next_p)
+{
+	struct vm_area_struct *vma, *next;
+
+	vma = *vma_p;
+	next = *next_p;
+
+	/*
+	 * Optimization: gather nearby vmas into one call down
+	 */
+	while (next && next->vm_start <= vma->vm_end + PMD_SIZE) {
+		vma = next;
+		next = vma->vm_next;
+		anon_vma_unlink(vma);
+		unlink_file_vma(vma);
+	}
+
+	*vma_p = vma;
+	*next_p = next;
+}
+
+
+#endif
+
+
Index: linux-rc5/mm/default-pt.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-rc5/mm/default-pt.c	2006-05-28 00:59:12.228320504 +1000
@@ -0,0 +1,140 @@
+#include <linux/kernel_stat.h>
+#include <linux/mm.h>
+#include <linux/hugetlb.h>
+#include <linux/mman.h>
+#include <linux/swap.h>
+#include <linux/highmem.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/module.h>
+#include <linux/init.h>
+
+#include <asm/pgalloc.h>
+#include <asm/uaccess.h>
+#include <asm/tlb.h>
+#include <asm/tlbflush.h>
+#include <asm/pgtable.h>
+
+#include <linux/swapops.h>
+#include <linux/elf.h>
+#include <linux/default-pt.h>
+
+/*
+ * If a p?d_bad entry is found while walking page tables, report
+ * the error, before resetting entry to p?d_none.  Usually (but
+ * very seldom) called out from the p?d_none_or_clear_bad macros.
+ */
+
+void pgd_clear_bad(pgd_t *pgd)
+{
+	pgd_ERROR(*pgd);
+	pgd_clear(pgd);
+}
+
+void pud_clear_bad(pud_t *pud)
+{
+	pud_ERROR(*pud);
+	pud_clear(pud);
+}
+
+void pmd_clear_bad(pmd_t *pmd)
+{
+	pmd_ERROR(*pmd);
+	pmd_clear(pmd);
+}
+
+int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
+{
+	struct page *new = pte_alloc_one(mm, address);
+	if (!new)
+		return -ENOMEM;
+
+	pte_lock_init(new);
+	spin_lock(&mm->page_table_lock);
+	if (pmd_present(*pmd)) {	/* Another has populated it */
+		pte_lock_deinit(new);
+		pte_free(new);
+	} else {
+		mm->nr_ptes++;
+		inc_page_state(nr_page_table_pages);
+		pmd_populate(mm, pmd, new);
+	}
+	spin_unlock(&mm->page_table_lock);
+	return 0;
+}
+
+int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
+{
+	pte_t *new = pte_alloc_one_kernel(&init_mm, address);
+	if (!new)
+		return -ENOMEM;
+
+	spin_lock(&init_mm.page_table_lock);
+	if (pmd_present(*pmd))		/* Another has populated it */
+		pte_free_kernel(new);
+	else
+		pmd_populate_kernel(&init_mm, pmd, new);
+	spin_unlock(&init_mm.page_table_lock);
+	return 0;
+}
+
+#ifndef __PAGETABLE_PUD_FOLDED
+/*
+ * Allocate page upper directory.
+ * We've already handled the fast-path in-line.
+ */
+int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+{
+	pud_t *new = pud_alloc_one(mm, address);
+	if (!new)
+		return -ENOMEM;
+
+	spin_lock(&mm->page_table_lock);
+	if (pgd_present(*pgd))		/* Another has populated it */
+		pud_free(new);
+	else
+		pgd_populate(mm, pgd, new);
+	spin_unlock(&mm->page_table_lock);
+	return 0;
+}
+#else
+/* Workaround for gcc 2.96 */
+int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+{
+	return 0;
+}
+#endif /* __PAGETABLE_PUD_FOLDED */
+
+#ifndef __PAGETABLE_PMD_FOLDED
+/*
+ * Allocate page middle directory.
+ * We've already handled the fast-path in-line.
+ */
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+{
+	pmd_t *new = pmd_alloc_one(mm, address);
+	if (!new)
+		return -ENOMEM;
+
+	spin_lock(&mm->page_table_lock);
+#ifndef __ARCH_HAS_4LEVEL_HACK
+	if (pud_present(*pud))		/* Another has populated it */
+		pmd_free(new);
+	else
+		pud_populate(mm, pud, new);
+#else
+	if (pgd_present(*pud))		/* Another has populated it */
+		pmd_free(new);
+	else
+		pgd_populate(mm, pud, new);
+#endif /* __ARCH_HAS_4LEVEL_HACK */
+	spin_unlock(&mm->page_table_lock);
+	return 0;
+}
+#else
+/* Workaround for gcc 2.96 */
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+{
+	return 0;
+}
+#endif /* __PAGETABLE_PMD_FOLDED */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
