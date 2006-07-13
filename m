From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:27:00 +1000
Message-Id: <20060713042700.9978.85075.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 3/18] PTI - Abstract default page table
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

This patch does the following:
1) Starts abstraction of page table implementation from memory.c to 
   pt-default.c 
   * Add mm/pt-default.c to contain majority of page table implementation
   for the Linux default page table.
   * Add pt-default.c to mm/Makefile
   * Move page table allocation functions from memory.c to pt-default.c
2) Carried over from previous patch
   * pgtable.h & mmu_context.h references to pgd are removed for i386.
   * init_task.h reference to pgd removed.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 arch/i386/mm/fault.c           |    2 
 include/asm-i386/mmu_context.h |    5 -
 include/asm-i386/pgtable.h     |    2 
 mm/Makefile                    |    2 
 mm/memory.c                    |   87 ---------------------------------
 mm/pt-default.c                |  105 +++++++++++++++++++++++++++++++++++++++++
 6 files changed, 110 insertions(+), 93 deletions(-)
Index: linux-2.6.17.2/mm/Makefile
===================================================================
--- linux-2.6.17.2.orig/mm/Makefile	2006-07-07 21:31:11.155866904 +1000
+++ linux-2.6.17.2/mm/Makefile	2006-07-07 21:31:13.847457720 +1000
@@ -5,7 +5,7 @@
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o
+			   vmalloc.o pt-default.o
 
 obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
 			   page_alloc.o page-writeback.o pdflush.o \
Index: linux-2.6.17.2/mm/pt-default.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17.2/mm/pt-default.c	2006-07-07 22:06:38.839684032 +1000
@@ -0,0 +1,105 @@
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
+#include <linux/pt.h>
+
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
Index: linux-2.6.17.2/arch/i386/mm/fault.c
===================================================================
--- linux-2.6.17.2.orig/arch/i386/mm/fault.c	2006-07-07 21:31:11.168864928 +1000
+++ linux-2.6.17.2/arch/i386/mm/fault.c	2006-07-07 21:31:13.848457568 +1000
@@ -222,7 +222,7 @@
 	pmd_t *pmd, *pmd_k;
 
 	pgd += index;
-	pgd_k = init_mm.pgd + index;
+	pgd_k = init_mm.pt.pgd + index;
 
 	if (!pgd_present(*pgd_k))
 		return NULL;
Index: linux-2.6.17.2/include/asm-i386/mmu_context.h
===================================================================
--- linux-2.6.17.2.orig/include/asm-i386/mmu_context.h	2006-07-07 21:31:11.168864928 +1000
+++ linux-2.6.17.2/include/asm-i386/mmu_context.h	2006-07-07 21:31:13.849457416 +1000
@@ -39,8 +39,7 @@
 		cpu_set(cpu, next->cpu_vm_mask);
 
 		/* Re-load page tables */
-		load_cr3(next->pgd);
-
+		load_cr3(get_root_pt(next));
 		/*
 		 * load the LDT, if the LDT is different:
 		 */
@@ -56,7 +55,7 @@
 			/* We were in lazy tlb mode and leave_mm disabled 
 			 * tlb flush IPI delivery. We must reload %cr3.
 			 */
-			load_cr3(next->pgd);
+			load_cr3(get_root_pt(next));
 			load_LDT_nolock(&next->context, cpu);
 		}
 	}
Index: linux-2.6.17.2/include/asm-i386/pgtable.h
===================================================================
--- linux-2.6.17.2.orig/include/asm-i386/pgtable.h	2006-07-07 21:31:11.167865080 +1000
+++ linux-2.6.17.2/include/asm-i386/pgtable.h	2006-07-07 21:31:13.850457264 +1000
@@ -339,7 +339,7 @@
  * pgd_offset() returns a (pgd_t *)
  * pgd_index() is used get the offset into the pgd page's array of pgd_t's;
  */
-#define pgd_offset(mm, address) ((mm)->pgd+pgd_index(address))
+#define pgd_offset(mm, address) ((mm)->pt.pgd+pgd_index(address))
 
 /*
  * a shortcut which implies the use of the kernel's pgd, instead
Index: linux-2.6.17.2/mm/memory.c
===================================================================
--- linux-2.6.17.2.orig/mm/memory.c	2006-07-07 21:31:13.820461824 +1000
+++ linux-2.6.17.2/mm/memory.c	2006-07-07 22:06:48.655191848 +1000
@@ -91,31 +91,6 @@
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
@@ -298,41 +273,6 @@
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
-		inc_page_state(nr_page_table_pages);
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
 /*
  * This function is called to print an error when a bad pte
  * is found. For example, we might have a PFN-mapped pte in
@@ -2276,33 +2216,6 @@
 
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
 #ifndef __PAGETABLE_PMD_FOLDED
 /*
  * Allocate page middle directory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
