From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:45:45 +1100
Message-Id: <20070113024545.29682.95671.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 1/29] Abstract current page table implementation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 01
 * Creates the mm/pt-default.c to hold the implementation of 
 the default page table.
 * Adjusts mm/Makefile to compile default page table.
 * Starts moving default page table implementation from memory.c to
 pt-default.c.
   * moves across pgd/pud/pmd_clear_bad
   * moves accross pt alloc fns: __pte_alloc, __pte_alloc_kernel
   __pud_alloc and __pmd_alloc

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 Makefile     |    2 
 memory.c     |  121 --------------------------------------------------
 pt-default.c |  141 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 142 insertions(+), 122 deletions(-)
Index: linux-2.6.20-rc1/mm/Makefile
===================================================================
--- linux-2.6.20-rc1.orig/mm/Makefile	2006-12-21 11:41:06.410940000 +1100
+++ linux-2.6.20-rc1/mm/Makefile	2006-12-21 13:33:22.215470000 +1100
@@ -5,7 +5,7 @@
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o
+			   vmalloc.o pt-default.o
 
 obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
 			   page_alloc.o page-writeback.o pdflush.o \
Index: linux-2.6.20-rc1/mm/memory.c
===================================================================
--- linux-2.6.20-rc1.orig/mm/memory.c	2006-12-21 11:41:06.410940000 +1100
+++ linux-2.6.20-rc1/mm/memory.c	2006-12-21 13:47:45.554231000 +1100
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
Index: linux-2.6.20-rc1/mm/pt-default.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/mm/pt-default.c	2006-12-21 13:46:59.270231000 +1100
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
