From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 13:26:53 +1000 (EST)
Subject: [PATCH 5/15] PTI: Finish moving mlpt behind interface
In-Reply-To: <Pine.LNX.4.61.0505211313160.17972@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211325210.18258@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211305230.12627@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211313160.17972@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 5 of 15.

This patch completes moving general mlpt code behind the
page table interface.

 	*It abstracts mlpt dependent code from the general
 	 pgtable.h and the general tlb.h to ptable-mlpt.h
 	 and tlb-mlpt.h respectively.
 	*The prototypes from clearing bad pgds etc are moved in this
 	 process.

  include/asm-generic/pgtable-mlpt.h |   74 
+++++++++++++++++++++++++++++++++++++
  include/asm-generic/pgtable.h      |   71 
+----------------------------------
  include/asm-generic/tlb-mlpt.h     |   20 ++++++++++
  include/asm-generic/tlb.h          |   20 +---------
  4 files changed, 98 insertions(+), 87 deletions(-)

Index: linux-2.6.12-rc4/include/asm-generic/pgtable.h
===================================================================
--- linux-2.6.12-rc4.orig/include/asm-generic/pgtable.h	2005-05-17 
21:45:09.000000000 +1000
+++ linux-2.6.12-rc4/include/asm-generic/pgtable.h	2005-05-18 
00:41:18.000000000 +1000
@@ -131,81 +131,14 @@
  #define page_test_and_clear_young(page) (0)
  #endif

-#ifndef __HAVE_ARCH_PGD_OFFSET_GATE
-#define pgd_offset_gate(mm, addr)	pgd_offset(mm, addr)
-#endif
-
  #ifndef __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
  #define lazy_mmu_prot_update(pte)	do { } while (0)
  #endif

-/*
- * When walking page tables, get the address of the next boundary,
- * or the end address of the range if that comes earlier.  Although no
- * vma end wraps to 0, rounded up __boundary may wrap to 0 throughout.
- */
-
-#define pgd_addr_end(addr, end) 
\
-({	unsigned long __boundary = ((addr) + PGDIR_SIZE) & PGDIR_MASK;	\
-	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
-})
-
-#ifndef pud_addr_end
-#define pud_addr_end(addr, end) 
\
-({	unsigned long __boundary = ((addr) + PUD_SIZE) & PUD_MASK;	\
-	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
-})
-#endif

-#ifndef pmd_addr_end
-#define pmd_addr_end(addr, end) 
\
-({	unsigned long __boundary = ((addr) + PMD_SIZE) & PMD_MASK;	\
-	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
-})
+#ifdef CONFIG_MLPT
+#include <asm-generic/pgtable-mlpt.h>
  #endif

-#ifndef __ASSEMBLY__
-/*
- * When walking page tables, we usually want to skip any p?d_none 
entries;
- * and any p?d_bad entries - reporting the error before resetting to 
none.
- * Do the tests inline, but report and clear the bad entry in 
mm/memory.c.
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

  #endif /* _ASM_GENERIC_PGTABLE_H */
Index: linux-2.6.12-rc4/include/asm-generic/pgtable-mlpt.h
===================================================================
--- linux-2.6.12-rc4.orig/include/asm-generic/pgtable-mlpt.h	2005-05-18 
00:30:14.000000000 +1000
+++ linux-2.6.12-rc4/include/asm-generic/pgtable-mlpt.h	2005-05-18 
00:41:05.000000000 +1000
@@ -1,4 +1,78 @@
  #ifndef _ASM_GENERIC_PGTABLE_MLPT_H
  #define _ASM_GENERIC_PGTABLE_MLPT_H 1

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
+#define pgd_addr_end(addr, end) 
\
+({	unsigned long __boundary = ((addr) + PGDIR_SIZE) & PGDIR_MASK;	\
+	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
+})
+
+#ifndef pud_addr_end
+#define pud_addr_end(addr, end) 
\
+({	unsigned long __boundary = ((addr) + PUD_SIZE) & PUD_MASK;	\
+	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
+})
+#endif
+
+#ifndef pmd_addr_end
+#define pmd_addr_end(addr, end) 
\
+({	unsigned long __boundary = ((addr) + PMD_SIZE) & PMD_MASK;	\
+	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
+})
+#endif
+
+#ifndef __ASSEMBLY__
+/*
+ * When walking page tables, we usually want to skip any p?d_none 
entries;
+ * and any p?d_bad entries - reporting the error before resetting to 
none.
+ * Do the tests inline, but report and clear the bad entry in 
mm/memory.c.
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
+
  #endif
Index: linux-2.6.12-rc4/include/asm-generic/tlb.h
===================================================================
--- linux-2.6.12-rc4.orig/include/asm-generic/tlb.h	2005-05-07 
15:20:31.000000000 +1000
+++ linux-2.6.12-rc4/include/asm-generic/tlb.h	2005-05-18 
00:54:19.000000000 +1000
@@ -135,26 +135,10 @@
  		__tlb_remove_tlb_entry(tlb, ptep, address);	\
  	} while (0)

-#define pte_free_tlb(tlb, ptep)					\
-	do {							\
-		tlb->need_flush = 1;				\
-		__pte_free_tlb(tlb, ptep);			\
-	} while (0)
-
-#ifndef __ARCH_HAS_4LEVEL_HACK
-#define pud_free_tlb(tlb, pudp)					\
-	do {							\
-		tlb->need_flush = 1;				\
-		__pud_free_tlb(tlb, pudp);			\
-	} while (0)
+#ifdef CONFIG_MLPT
+#include <asm-generic/tlb-mlpt.h>
  #endif

-#define pmd_free_tlb(tlb, pmdp)					\
-	do {							\
-		tlb->need_flush = 1;				\
-		__pmd_free_tlb(tlb, pmdp);			\
-	} while (0)
-
  #define tlb_migrate_finish(mm) do {} while (0)

  #endif /* _ASM_GENERIC__TLB_H */
Index: linux-2.6.12-rc4/include/asm-generic/tlb-mlpt.h
===================================================================
--- linux-2.6.12-rc4.orig/include/asm-generic/tlb-mlpt.h	2005-05-18 
00:30:14.000000000 +1000
+++ linux-2.6.12-rc4/include/asm-generic/tlb-mlpt.h	2005-05-18 
00:54:03.000000000 +1000
@@ -1,4 +1,24 @@
  #ifndef _ASM_GENERIC_TLB_MLPT_H
  #define _ASM_GENERIC_TLB_MLPT_H 1

+#define pte_free_tlb(tlb, ptep)					\
+	do {							\
+		tlb->need_flush = 1;				\
+		__pte_free_tlb(tlb, ptep);			\
+	} while (0)
+
+#ifndef __ARCH_HAS_4LEVEL_HACK
+#define pud_free_tlb(tlb, pudp)					\
+	do {							\
+		tlb->need_flush = 1;				\
+		__pud_free_tlb(tlb, pudp);			\
+	} while (0)
+#endif
+
+#define pmd_free_tlb(tlb, pmdp)					\
+	do {							\
+		tlb->need_flush = 1;				\
+		__pmd_free_tlb(tlb, pmdp);			\
+	} while (0)
+
  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
