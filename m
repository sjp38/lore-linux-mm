From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:27:35 +1000
Message-Id: <20060713042735.9978.49829.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 6/18] PTI - Abstract default page table
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

1) Abstraction of page table implementation in mm.h to pt-mm.h
 * Removes implementation from mm.h

2) Abstraction of page table implementation from asm-generic/pgtable.h
to asm-generic/pt-pgtable.h

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 asm-generic/pgtable.h    |   73 --------------------------------------------
 asm-generic/pt-pgtable.h |   77 +++++++++++++++++++++++++++++++++++++++++++++++
 linux/mm.h               |   71 -------------------------------------------
 3 files changed, 79 insertions(+), 142 deletions(-)
Index: linux-2.6.17.2/include/linux/mm.h
===================================================================
--- linux-2.6.17.2.orig/include/linux/mm.h	2006-07-07 23:44:23.659612400 +1000
+++ linux-2.6.17.2/include/linux/mm.h	2006-07-08 00:01:41.280244328 +1000
@@ -798,76 +798,7 @@
 
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
+#include <linux/pt-mm.h>
 
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, pg_data_t *pgdat,
Index: linux-2.6.17.2/include/asm-generic/pt-pgtable.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17.2/include/asm-generic/pt-pgtable.h	2006-07-08 00:14:10.398361064 +1000
@@ -0,0 +1,77 @@
+#ifndef _ASM_GENERIC_DEFAULT_PGTABLE_H
+#define _ASM_GENERIC_DEFAULT_PGTABLE_H 1
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
+#ifndef __ASSEMBLY__
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
+#endif /* !__ASSEMBLY__ */
+
+#endif
Index: linux-2.6.17.2/include/asm-generic/pgtable.h
===================================================================
--- linux-2.6.17.2.orig/include/asm-generic/pgtable.h	2006-06-30 10:17:23.000000000 +1000
+++ linux-2.6.17.2/include/asm-generic/pgtable.h	2006-07-08 00:19:21.834250720 +1000
@@ -151,10 +151,6 @@
 #define page_test_and_clear_young(page) (0)
 #endif
 
-#ifndef __HAVE_ARCH_PGD_OFFSET_GATE
-#define pgd_offset_gate(mm, addr)	pgd_offset(mm, addr)
-#endif
-
 #ifndef __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
 #define lazy_mmu_prot_update(pte)	do { } while (0)
 #endif
@@ -163,73 +159,6 @@
 #define move_pte(pte, prot, old_addr, new_addr)	(pte)
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
-#ifndef __ASSEMBLY__
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
-#endif /* !__ASSEMBLY__ */
+#include <asm-generic/pt-pgtable.h>
 
 #endif /* _ASM_GENERIC_PGTABLE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
