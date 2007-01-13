From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:45:51 +1100
Message-Id: <20070113024551.29682.77131.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 2/29] Abstract current page table implementation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 02
 * Creates /include/asm-generic/pgtable-default.h to contain the default 
 page table implementation abstracted from include/asm-generic/pgtable.h.
 The abstraction is peformed.
 * Creates include/linux/pt-default-mm.h to contain default page table
 implementation abstracted from include/linux/mm.h.
 * Starts moving default page table implementation from mm.h to pt-default-mm.h
   * moves function prototypes for __pud_alloc, __pmd_alloc etc
   * moves inline implementation of pud_alloc and pmd_alloc
 * NB: All arches are intended to have CONFIG_PT_DEFAULT defined by default
 (which is done in later patches for i386 and IA64 only).

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 asm-generic/pgtable-default.h |   79 ++++++++++++++++++++++++++++++++++++++++++
 asm-generic/pgtable.h         |   68 +-----------------------------------
 linux/mm.h                    |   25 -------------
 linux/pt-default-mm.h         |   27 ++++++++++++++
 4 files changed, 110 insertions(+), 89 deletions(-)
Index: linux-2.6.20-rc4/include/asm-generic/pgtable-default.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc4/include/asm-generic/pgtable-default.h	2007-01-11 13:09:08.147868000 +1100
@@ -0,0 +1,79 @@
+#ifndef _ASM_GENERIC_PGTABLE_DEFAULT_H
+#define _ASM_GENERIC_PGTABLE_DEFAULT_H
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
Index: linux-2.6.20-rc4/include/asm-generic/pgtable.h
===================================================================
--- linux-2.6.20-rc4.orig/include/asm-generic/pgtable.h	2007-01-11 13:09:04.215868000 +1100
+++ linux-2.6.20-rc4/include/asm-generic/pgtable.h	2007-01-11 13:09:08.147868000 +1100
@@ -182,72 +182,10 @@
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
+#endif /* !__ASSEMBLY__ */
 
-#ifndef pmd_addr_end
-#define pmd_addr_end(addr, end)						\
-({	unsigned long __boundary = ((addr) + PMD_SIZE) & PMD_MASK;	\
-	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
-})
+#ifdef CONFIG_PT_DEFAULT
+#include <asm-generic/pgtable-default.h>
 #endif
 
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
-
 #endif /* _ASM_GENERIC_PGTABLE_H */
Index: linux-2.6.20-rc4/include/linux/mm.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/mm.h	2007-01-11 13:09:04.215868000 +1100
+++ linux-2.6.20-rc4/include/linux/mm.h	2007-01-11 13:11:05.387868000 +1100
@@ -729,8 +729,6 @@
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
-void free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
-		unsigned long end, unsigned long floor, unsigned long ceiling);
 void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
@@ -853,28 +851,7 @@
 
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
+#include <linux/pt-default-mm.h>
 
 #if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
 /*
Index: linux-2.6.20-rc4/include/linux/pt-default-mm.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc4/include/linux/pt-default-mm.h	2007-01-11 13:09:08.155868000 +1100
@@ -0,0 +1,27 @@
+#ifndef _LINUX_PT_DEFAULT_MM_H
+#define _LINUX_PT_DEFAULT_MM_H
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
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
