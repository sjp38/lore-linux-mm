From: Paul Davies <pauld@cse.unsw.edu.au>
Date: Wed, 24 Jan 2007 13:38:28 +1100
Message-Id: <20070124023828.11302.51100.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 1/1] Page Table cleanup patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Paul Davies <pauld@cse.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

This patch is a proposed cleanup of the current page table organisation.
Such a cleanup would be a logical first step towards introducing at least
a partial clean page table interface, geared towards providing enhanced 
virtualization oportunities for x86.  It is also a common sense cleanup 
in its own right.

 * Creates mlpt.c to hold the page table implementation currently held 
   in memory.c.
 * Adjust Makefile 
 * Move implementation dependent page table code out of 
   include/linux/mm.h into include/linux/mlpt-mm.h
 * Move implementation dependent page table code out of 
   include/asm-generic/pgtable.h to include/asm-generic/pgtable-mlpt.h

mlpt stands from multi level page table.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/asm-generic/pgtable-mlpt.h |   79 ++++++++++++++++++++
 include/asm-generic/pgtable.h      |   68 -----------------
 include/linux/mlpt-mm.h            |   75 +++++++++++++++++++
 include/linux/mm.h                 |   71 ------------------
 mm/Makefile                        |    2 
 mm/memory.c                        |  121 -------------------------------
 mm/mlpt.c                          |  141 +++++++++++++++++++++++++++++++++++++
 7 files changed, 299 insertions(+), 258 deletions(-)
Index: linux-2.6.20-rc5/mm/Makefile
===================================================================
--- linux-2.6.20-rc5.orig/mm/Makefile	2007-01-24 11:46:30.441362000 +1100
+++ linux-2.6.20-rc5/mm/Makefile	2007-01-24 11:46:32.141362000 +1100
@@ -5,7 +5,7 @@
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o
+			   vmalloc.o mlpt.o
 
 obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
 			   page_alloc.o page-writeback.o pdflush.o \
Index: linux-2.6.20-rc5/mm/memory.c
===================================================================
--- linux-2.6.20-rc5.orig/mm/memory.c	2007-01-24 11:46:30.441362000 +1100
+++ linux-2.6.20-rc5/mm/memory.c	2007-01-24 11:46:32.145362000 +1100
@@ -93,31 +93,6 @@
 }
 __setup("norandmaps", disable_randmaps);
 
-
-/*
- * If a p?d_bad entry is found while walking page tables, report
- * the error, before resetting entry to p?d_none.  Usually (but
- * very seldom) called out from the p?d_none_or_clear_bad macros.
- */
-
-void pgd_clear_bad(pgd_t *pgd)
-{
-	pgd_ERROR(*pgd);
-	pgd_clear(pgd);
-}
-
-void pud_clear_bad(pud_t *pud)
-{
-	pud_ERROR(*pud);
-	pud_clear(pud);
-}
-
-void pmd_clear_bad(pmd_t *pmd)
-{
-	pmd_ERROR(*pmd);
-	pmd_clear(pmd);
-}
-
 /*
  * Note: this doesn't free the actual pages themselves. That
  * has been handled earlier when unmapping all the memory regions.
@@ -300,41 +275,6 @@
 	}
 }
 
-int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
-{
-	struct page *new = pte_alloc_one(mm, address);
-	if (!new)
-		return -ENOMEM;
-
-	pte_lock_init(new);
-	spin_lock(&mm->page_table_lock);
-	if (pmd_present(*pmd)) {	/* Another has populated it */
-		pte_lock_deinit(new);
-		pte_free(new);
-	} else {
-		mm->nr_ptes++;
-		inc_zone_page_state(new, NR_PAGETABLE);
-		pmd_populate(mm, pmd, new);
-	}
-	spin_unlock(&mm->page_table_lock);
-	return 0;
-}
-
-int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
-{
-	pte_t *new = pte_alloc_one_kernel(&init_mm, address);
-	if (!new)
-		return -ENOMEM;
-
-	spin_lock(&init_mm.page_table_lock);
-	if (pmd_present(*pmd))		/* Another has populated it */
-		pte_free_kernel(new);
-	else
-		pmd_populate_kernel(&init_mm, pmd, new);
-	spin_unlock(&init_mm.page_table_lock);
-	return 0;
-}
-
 static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
 {
 	if (file_rss)
@@ -2476,67 +2416,6 @@
 
 EXPORT_SYMBOL_GPL(__handle_mm_fault);
 
-#ifndef __PAGETABLE_PUD_FOLDED
-/*
- * Allocate page upper directory.
- * We've already handled the fast-path in-line.
- */
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
-{
-	pud_t *new = pud_alloc_one(mm, address);
-	if (!new)
-		return -ENOMEM;
-
-	spin_lock(&mm->page_table_lock);
-	if (pgd_present(*pgd))		/* Another has populated it */
-		pud_free(new);
-	else
-		pgd_populate(mm, pgd, new);
-	spin_unlock(&mm->page_table_lock);
-	return 0;
-}
-#else
-/* Workaround for gcc 2.96 */
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
-{
-	return 0;
-}
-#endif /* __PAGETABLE_PUD_FOLDED */
-
-#ifndef __PAGETABLE_PMD_FOLDED
-/*
- * Allocate page middle directory.
- * We've already handled the fast-path in-line.
- */
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
-{
-	pmd_t *new = pmd_alloc_one(mm, address);
-	if (!new)
-		return -ENOMEM;
-
-	spin_lock(&mm->page_table_lock);
-#ifndef __ARCH_HAS_4LEVEL_HACK
-	if (pud_present(*pud))		/* Another has populated it */
-		pmd_free(new);
-	else
-		pud_populate(mm, pud, new);
-#else
-	if (pgd_present(*pud))		/* Another has populated it */
-		pmd_free(new);
-	else
-		pgd_populate(mm, pud, new);
-#endif /* __ARCH_HAS_4LEVEL_HACK */
-	spin_unlock(&mm->page_table_lock);
-	return 0;
-}
-#else
-/* Workaround for gcc 2.96 */
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
-{
-	return 0;
-}
-#endif /* __PAGETABLE_PMD_FOLDED */
-
 int make_pages_present(unsigned long addr, unsigned long end)
 {
 	int ret, len, write;
Index: linux-2.6.20-rc5/include/asm-generic/pgtable.h
===================================================================
--- linux-2.6.20-rc5.orig/include/asm-generic/pgtable.h	2007-01-24 11:46:30.441362000 +1100
+++ linux-2.6.20-rc5/include/asm-generic/pgtable.h	2007-01-24 11:52:28.633362000 +1100
@@ -182,72 +182,8 @@
 #define arch_leave_lazy_mmu_mode()	do {} while (0)
 #endif
 
-/*
- * When walking page tables, get the address of the next boundary,
- * or the end address of the range if that comes earlier.  Although no
- * vma end wraps to 0, rounded up __boundary may wrap to 0 throughout.
- */
-
-#define pgd_addr_end(addr, end)						\
-({	unsigned long __boundary = ((addr) + PGDIR_SIZE) & PGDIR_MASK;	\
-	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
-})
-
-#ifndef pud_addr_end
-#define pud_addr_end(addr, end)						\
-({	unsigned long __boundary = ((addr) + PUD_SIZE) & PUD_MASK;	\
-	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
-})
-#endif
-
-#ifndef pmd_addr_end
-#define pmd_addr_end(addr, end)						\
-({	unsigned long __boundary = ((addr) + PMD_SIZE) & PMD_MASK;	\
-	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
-})
-#endif
-
-/*
- * When walking page tables, we usually want to skip any p?d_none entries;
- * and any p?d_bad entries - reporting the error before resetting to none.
- * Do the tests inline, but report and clear the bad entry in mm/memory.c.
- */
-void pgd_clear_bad(pgd_t *);
-void pud_clear_bad(pud_t *);
-void pmd_clear_bad(pmd_t *);
-
-static inline int pgd_none_or_clear_bad(pgd_t *pgd)
-{
-	if (pgd_none(*pgd))
-		return 1;
-	if (unlikely(pgd_bad(*pgd))) {
-		pgd_clear_bad(pgd);
-		return 1;
-	}
-	return 0;
-}
-
-static inline int pud_none_or_clear_bad(pud_t *pud)
-{
-	if (pud_none(*pud))
-		return 1;
-	if (unlikely(pud_bad(*pud))) {
-		pud_clear_bad(pud);
-		return 1;
-	}
-	return 0;
-}
-
-static inline int pmd_none_or_clear_bad(pmd_t *pmd)
-{
-	if (pmd_none(*pmd))
-		return 1;
-	if (unlikely(pmd_bad(*pmd))) {
-		pmd_clear_bad(pmd);
-		return 1;
-	}
-	return 0;
-}
 #endif /* !__ASSEMBLY__ */
 
+#include <asm-generic/pgtable-mlpt.h>
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
Index: linux-2.6.20-rc5/include/linux/mlpt-mm.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc5/include/linux/mlpt-mm.h	2007-01-24 11:46:32.169362000 +1100
@@ -0,0 +1,75 @@
+#ifndef _LINUX_MLPT_MM_H
+#define _LINUX_MLPT_MM_H
+
+int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
+int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address);
+int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
+
+/*
+ * The following ifdef needed to get the 4level-fixup.h header to work.
+ * Remove it when 4level-fixup.h has been removed.
+ */
+#if defined(CONFIG_MMU) && !defined(__ARCH_HAS_4LEVEL_HACK)
+static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+{
+	return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address))?
+		NULL: pud_offset(pgd, address);
+}
+
+static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+{
+	return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address))?
+		NULL: pmd_offset(pud, address);
+}
+#endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
+
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+/*
+ * We tuck a spinlock to guard each pagetable page into its struct page,
+ * at page->private, with BUILD_BUG_ON to make sure that this will not
+ * overflow into the next struct page (as it might with DEBUG_SPINLOCK).
+ * When freeing, reset page->mapping so free_pages_check won't complain.
+ */
+#define __pte_lockptr(page)	&((page)->ptl)
+#define pte_lock_init(_page)	do {					\
+	spin_lock_init(__pte_lockptr(_page));				\
+} while (0)
+#define pte_lock_deinit(page)	((page)->mapping = NULL)
+#define pte_lockptr(mm, pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
+#else
+/*
+ * We use mm->page_table_lock to guard all pagetable pages of the mm.
+ */
+#define pte_lock_init(page)	do {} while (0)
+#define pte_lock_deinit(page)	do {} while (0)
+#define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
+#endif /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */
+
+#define pte_offset_map_lock(mm, pmd, address, ptlp)	\
+({							\
+	spinlock_t *__ptl = pte_lockptr(mm, pmd);	\
+	pte_t *__pte = pte_offset_map(pmd, address);	\
+	*(ptlp) = __ptl;				\
+	spin_lock(__ptl);				\
+	__pte;						\
+})
+
+#define pte_unmap_unlock(pte, ptl)	do {		\
+	spin_unlock(ptl);				\
+	pte_unmap(pte);					\
+} while (0)
+
+#define pte_alloc_map(mm, pmd, address)			\
+	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
+		NULL: pte_offset_map(pmd, address))
+
+#define pte_alloc_map_lock(mm, pmd, address, ptlp)	\
+	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
+		NULL: pte_offset_map_lock(mm, pmd, address, ptlp))
+
+#define pte_alloc_kernel(pmd, address)			\
+	((unlikely(!pmd_present(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
+		NULL: pte_offset_kernel(pmd, address))
+
+#endif
Index: linux-2.6.20-rc5/include/linux/mm.h
===================================================================
--- linux-2.6.20-rc5.orig/include/linux/mm.h	2007-01-24 11:46:30.441362000 +1100
+++ linux-2.6.20-rc5/include/linux/mm.h	2007-01-24 11:46:32.169362000 +1100
@@ -853,76 +853,7 @@
 
 extern pte_t *FASTCALL(get_locked_pte(struct mm_struct *mm, unsigned long addr, spinlock_t **ptl));
 
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
-int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address);
-int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
-
-/*
- * The following ifdef needed to get the 4level-fixup.h header to work.
- * Remove it when 4level-fixup.h has been removed.
- */
-#if defined(CONFIG_MMU) && !defined(__ARCH_HAS_4LEVEL_HACK)
-static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
-{
-	return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address))?
-		NULL: pud_offset(pgd, address);
-}
-
-static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
-{
-	return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address))?
-		NULL: pmd_offset(pud, address);
-}
-#endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
-
-#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
-/*
- * We tuck a spinlock to guard each pagetable page into its struct page,
- * at page->private, with BUILD_BUG_ON to make sure that this will not
- * overflow into the next struct page (as it might with DEBUG_SPINLOCK).
- * When freeing, reset page->mapping so free_pages_check won't complain.
- */
-#define __pte_lockptr(page)	&((page)->ptl)
-#define pte_lock_init(_page)	do {					\
-	spin_lock_init(__pte_lockptr(_page));				\
-} while (0)
-#define pte_lock_deinit(page)	((page)->mapping = NULL)
-#define pte_lockptr(mm, pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
-#else
-/*
- * We use mm->page_table_lock to guard all pagetable pages of the mm.
- */
-#define pte_lock_init(page)	do {} while (0)
-#define pte_lock_deinit(page)	do {} while (0)
-#define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
-#endif /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */
-
-#define pte_offset_map_lock(mm, pmd, address, ptlp)	\
-({							\
-	spinlock_t *__ptl = pte_lockptr(mm, pmd);	\
-	pte_t *__pte = pte_offset_map(pmd, address);	\
-	*(ptlp) = __ptl;				\
-	spin_lock(__ptl);				\
-	__pte;						\
-})
-
-#define pte_unmap_unlock(pte, ptl)	do {		\
-	spin_unlock(ptl);				\
-	pte_unmap(pte);					\
-} while (0)
-
-#define pte_alloc_map(mm, pmd, address)			\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
-		NULL: pte_offset_map(pmd, address))
-
-#define pte_alloc_map_lock(mm, pmd, address, ptlp)	\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
-		NULL: pte_offset_map_lock(mm, pmd, address, ptlp))
-
-#define pte_alloc_kernel(pmd, address)			\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
-		NULL: pte_offset_kernel(pmd, address))
+#include <linux/mlpt-mm.h>
 
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, pg_data_t *pgdat,
Index: linux-2.6.20-rc5/mm/mlpt.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc5/mm/mlpt.c	2007-01-24 11:46:32.169362000 +1100
@@ -0,0 +1,141 @@
+#include <linux/kernel_stat.h>
+#include <linux/mm.h>
+#include <linux/hugetlb.h>
+#include <linux/mman.h>
+#include <linux/swap.h>
+#include <linux/highmem.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/module.h>
+#include <linux/delayacct.h>
+#include <linux/init.h>
+#include <linux/writeback.h>
+
+#include <asm/pgalloc.h>
+#include <asm/uaccess.h>
+#include <asm/tlb.h>
+#include <asm/tlbflush.h>
+#include <asm/pgtable.h>
+
+#include <linux/swapops.h>
+#include <linux/elf.h>
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
+		inc_zone_page_state(new, NR_PAGETABLE);
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
Index: linux-2.6.20-rc5/include/asm-generic/pgtable-mlpt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc5/include/asm-generic/pgtable-mlpt.h	2007-01-24 11:52:12.141362000 +1100
@@ -0,0 +1,79 @@
+#ifndef _ASM_GENERIC_PGTABLE_MLPT_H
+#define _ASM_GENERIC_PGTABLE_MLPT_H
+
+#ifndef __ASSEMBLY__
+
+#ifndef __HAVE_ARCH_PGD_OFFSET_GATE
+#define pgd_offset_gate(mm, addr)	pgd_offset(mm, addr)
+#endif
+
+/*
+ * When walking page tables, get the address of the next boundary,
+ * or the end address of the range if that comes earlier.  Although no
+ * vma end wraps to 0, rounded up __boundary may wrap to 0 throughout.
+ */
+
+#define pgd_addr_end(addr, end)						\
+({	unsigned long __boundary = ((addr) + PGDIR_SIZE) & PGDIR_MASK;	\
+	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
+})
+
+#ifndef pud_addr_end
+#define pud_addr_end(addr, end)						\
+({	unsigned long __boundary = ((addr) + PUD_SIZE) & PUD_MASK;	\
+	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
+})
+#endif
+
+#ifndef pmd_addr_end
+#define pmd_addr_end(addr, end)						\
+({	unsigned long __boundary = ((addr) + PMD_SIZE) & PMD_MASK;	\
+	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
+})
+#endif
+
+/*
+ * When walking page tables, we usually want to skip any p?d_none entries;
+ * and any p?d_bad entries - reporting the error before resetting to none.
+ * Do the tests inline, but report and clear the bad entry in mm/memory.c.
+ */
+void pgd_clear_bad(pgd_t *);
+void pud_clear_bad(pud_t *);
+void pmd_clear_bad(pmd_t *);
+
+static inline int pgd_none_or_clear_bad(pgd_t *pgd)
+{
+	if (pgd_none(*pgd))
+		return 1;
+	if (unlikely(pgd_bad(*pgd))) {
+		pgd_clear_bad(pgd);
+		return 1;
+	}
+	return 0;
+}
+
+static inline int pud_none_or_clear_bad(pud_t *pud)
+{
+	if (pud_none(*pud))
+		return 1;
+	if (unlikely(pud_bad(*pud))) {
+		pud_clear_bad(pud);
+		return 1;
+	}
+	return 0;
+}
+
+static inline int pmd_none_or_clear_bad(pmd_t *pmd)
+{
+	if (pmd_none(*pmd))
+		return 1;
+	if (unlikely(pmd_bad(*pmd))) {
+		pmd_clear_bad(pmd);
+		return 1;
+	}
+	return 0;
+}
+
+#endif /* !__ASSEMBLY__ */
+
+#endif /* _ASM_GENERIC_PGTABLE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
