From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:48:40 +1100
Message-Id: <20070113024840.29682.3206.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 5/5] Abstract pgalloc
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH IA64 05
 * Abstract implementation dependent memory allocation stuff from
 pgalloc.h into pgalloc-default.h

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 pgalloc-default.h |   87 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 pgalloc.h         |   87 ++----------------------------------------------------
 2 files changed, 91 insertions(+), 83 deletions(-)
Index: linux-2.6.20-rc1/include/asm-ia64/pgalloc-default.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/include/asm-ia64/pgalloc-default.h	2006-12-23 21:18:48.054043000 +1100
@@ -0,0 +1,87 @@
+#ifndef _ASM_IA64_PGALLOC_DEFAULT_H
+#define _ASM_IA64_PGALLOC_DEFAULT_H
+
+static inline pgd_t *pgd_alloc(struct mm_struct *mm)
+{
+	return pgtable_quicklist_alloc();
+}
+
+static inline void pgd_free(pgd_t * pgd)
+{
+	pgtable_quicklist_free(pgd);
+}
+
+#ifdef CONFIG_PGTABLE_4
+static inline void
+pgd_populate(struct mm_struct *mm, pgd_t * pgd_entry, pud_t * pud)
+{
+	pgd_val(*pgd_entry) = __pa(pud);
+}
+
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return pgtable_quicklist_alloc();
+}
+
+static inline void pud_free(pud_t * pud)
+{
+	pgtable_quicklist_free(pud);
+}
+#define __pud_free_tlb(tlb, pud)	pud_free(pud)
+#endif /* CONFIG_PGTABLE_4 */
+
+static inline void
+pud_populate(struct mm_struct *mm, pud_t * pud_entry, pmd_t * pmd)
+{
+	pud_val(*pud_entry) = __pa(pmd);
+}
+
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return pgtable_quicklist_alloc();
+}
+
+static inline void pmd_free(pmd_t * pmd)
+{
+	pgtable_quicklist_free(pmd);
+}
+
+#define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
+
+static inline void
+pmd_populate(struct mm_struct *mm, pmd_t * pmd_entry, struct page *pte)
+{
+	pmd_val(*pmd_entry) = page_to_phys(pte);
+}
+
+static inline void
+pmd_populate_kernel(struct mm_struct *mm, pmd_t * pmd_entry, pte_t * pte)
+{
+	pmd_val(*pmd_entry) = __pa(pte);
+}
+
+static inline struct page *pte_alloc_one(struct mm_struct *mm,
+					 unsigned long addr)
+{
+	return virt_to_page(pgtable_quicklist_alloc());
+}
+
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long addr)
+{
+	return pgtable_quicklist_alloc();
+}
+
+static inline void pte_free(struct page *pte)
+{
+	pgtable_quicklist_free(page_address(pte));
+}
+
+static inline void pte_free_kernel(pte_t * pte)
+{
+	pgtable_quicklist_free(pte);
+}
+
+#define __pte_free_tlb(tlb, pte)	pte_free(pte)
+
+#endif
Index: linux-2.6.20-rc1/include/asm-ia64/pgalloc.h
===================================================================
--- linux-2.6.20-rc1.orig/include/asm-ia64/pgalloc.h	2006-12-21 11:32:12.430004000 +1100
+++ linux-2.6.20-rc1/include/asm-ia64/pgalloc.h	2006-12-23 21:20:42.258043000 +1100
@@ -75,89 +75,10 @@
 	preempt_enable();
 }
 
-static inline pgd_t *pgd_alloc(struct mm_struct *mm)
-{
-	return pgtable_quicklist_alloc();
-}
-
-static inline void pgd_free(pgd_t * pgd)
-{
-	pgtable_quicklist_free(pgd);
-}
-
-#ifdef CONFIG_PGTABLE_4
-static inline void
-pgd_populate(struct mm_struct *mm, pgd_t * pgd_entry, pud_t * pud)
-{
-	pgd_val(*pgd_entry) = __pa(pud);
-}
-
-static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
-{
-	return pgtable_quicklist_alloc();
-}
-
-static inline void pud_free(pud_t * pud)
-{
-	pgtable_quicklist_free(pud);
-}
-#define __pud_free_tlb(tlb, pud)	pud_free(pud)
-#endif /* CONFIG_PGTABLE_4 */
-
-static inline void
-pud_populate(struct mm_struct *mm, pud_t * pud_entry, pmd_t * pmd)
-{
-	pud_val(*pud_entry) = __pa(pmd);
-}
-
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
-{
-	return pgtable_quicklist_alloc();
-}
-
-static inline void pmd_free(pmd_t * pmd)
-{
-	pgtable_quicklist_free(pmd);
-}
-
-#define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
-
-static inline void
-pmd_populate(struct mm_struct *mm, pmd_t * pmd_entry, struct page *pte)
-{
-	pmd_val(*pmd_entry) = page_to_phys(pte);
-}
-
-static inline void
-pmd_populate_kernel(struct mm_struct *mm, pmd_t * pmd_entry, pte_t * pte)
-{
-	pmd_val(*pmd_entry) = __pa(pte);
-}
-
-static inline struct page *pte_alloc_one(struct mm_struct *mm,
-					 unsigned long addr)
-{
-	return virt_to_page(pgtable_quicklist_alloc());
-}
-
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long addr)
-{
-	return pgtable_quicklist_alloc();
-}
-
-static inline void pte_free(struct page *pte)
-{
-	pgtable_quicklist_free(page_address(pte));
-}
-
-static inline void pte_free_kernel(pte_t * pte)
-{
-	pgtable_quicklist_free(pte);
-}
-
-#define __pte_free_tlb(tlb, pte)	pte_free(pte)
-
 extern void check_pgt_cache(void);
 
+#ifdef CONFIG_PT_DEFAULT
+#include <asm/pgalloc-default.h>
+#endif
+
 #endif				/* _ASM_IA64_PGALLOC_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
