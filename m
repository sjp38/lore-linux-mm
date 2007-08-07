From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 07 Aug 2007 17:19:49 +1000
Subject: [RFC/PATCH 5/12] Add mm argument to pte/pmd/pud/pgd_free.
In-Reply-To: <1186471185.826251.312410898174.qpush@grosgo>
Message-Id: <20070807071955.7E419DDE05@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Based on a patch from: Martin Schwidefsky <schwidefsky@de.ibm.com>

pte_alloc_one/pte_alloc_one_kernel get the mm as argument. If the page
table allocation depends on the mm pte/pmd/pud/pgd_free should get
the mm argument as well. That way it will be possible to have per-mm
lists of page table pages. I haven't changed pte_free_kernel at this
stage though.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 arch/arm/kernel/smp.c               |    2 +-
 arch/arm/mm/pgd.c                   |    6 +++---
 arch/frv/mm/pgalloc.c               |    2 +-
 arch/i386/mm/pgtable.c              |    2 +-
 arch/powerpc/mm/pgtable_32.c        |    4 ++--
 arch/ppc/mm/pgtable.c               |    4 ++--
 arch/um/kernel/mem.c                |    2 +-
 arch/um/kernel/skas/mmu.c           |    6 +++---
 include/asm-alpha/pgalloc.h         |    6 +++---
 include/asm-alpha/tlb.h             |    4 ++--
 include/asm-arm/pgalloc.h           |    6 +++---
 include/asm-arm/tlb.h               |    4 ++--
 include/asm-avr32/pgalloc.h         |    4 ++--
 include/asm-cris/pgalloc.h          |    4 ++--
 include/asm-frv/pgalloc.h           |    6 +++---
 include/asm-generic/4level-fixup.h  |    2 +-
 include/asm-generic/pgtable-nopmd.h |    2 +-
 include/asm-generic/pgtable-nopud.h |    2 +-
 include/asm-i386/pgalloc.h          |    6 +++---
 include/asm-ia64/pgalloc.h          |   14 +++++++-------
 include/asm-m32r/pgalloc.h          |    8 ++++----
 include/asm-m68k/motorola_pgalloc.h |    8 ++++----
 include/asm-m68k/sun3_pgalloc.h     |    6 +++---
 include/asm-mips/pgalloc.h          |   10 +++++-----
 include/asm-parisc/pgalloc.h        |    8 ++++----
 include/asm-parisc/tlb.h            |    4 ++--
 include/asm-powerpc/pgalloc-32.h    |    8 ++++----
 include/asm-powerpc/pgalloc-64.h    |    8 ++++----
 include/asm-ppc/pgalloc.h           |    8 ++++----
 include/asm-s390/pgalloc.h          |   10 +++++-----
 include/asm-sh/pgalloc.h            |    6 +++---
 include/asm-sh64/pgalloc.h          |   10 +++++-----
 include/asm-sparc/pgalloc.h         |   12 ++++++------
 include/asm-sparc64/pgalloc.h       |    6 +++---
 include/asm-sparc64/tlb.h           |    4 ++--
 include/asm-um/pgalloc.h            |    6 +++---
 include/asm-x86_64/pgalloc.h        |    8 ++++----
 include/asm-xtensa/pgalloc.h        |    4 ++--
 include/asm-xtensa/tlb.h            |    2 +-
 kernel/fork.c                       |    2 +-
 mm/memory.c                         |    8 ++++----
 41 files changed, 117 insertions(+), 117 deletions(-)

Index: linux-work/arch/powerpc/mm/pgtable_32.c
===================================================================
--- linux-work.orig/arch/powerpc/mm/pgtable_32.c	2007-08-06 13:48:27.000000000 +1000
+++ linux-work/arch/powerpc/mm/pgtable_32.c	2007-08-06 16:15:18.000000000 +1000
@@ -86,7 +86,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	return ret;
 }
 
-void pgd_free(pgd_t *pgd)
+void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_pages((unsigned long)pgd, PGDIR_ORDER);
 }
@@ -131,7 +131,7 @@ void pte_free_kernel(pte_t *pte)
 	free_page((unsigned long)pte);
 }
 
-void pte_free(struct page *ptepage)
+void pte_free(struct mm_struct *mm, struct page *ptepage)
 {
 #ifdef CONFIG_SMP
 	hash_page_sync();
Index: linux-work/arch/ppc/mm/pgtable.c
===================================================================
--- linux-work.orig/arch/ppc/mm/pgtable.c	2007-08-06 13:48:27.000000000 +1000
+++ linux-work/arch/ppc/mm/pgtable.c	2007-08-06 16:15:18.000000000 +1000
@@ -87,7 +87,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	return ret;
 }
 
-void pgd_free(pgd_t *pgd)
+void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_pages((unsigned long)pgd, PGDIR_ORDER);
 }
@@ -132,7 +132,7 @@ void pte_free_kernel(pte_t *pte)
 	free_page((unsigned long)pte);
 }
 
-void pte_free(struct page *ptepage)
+void pte_free(struct mm_struct *mm, struct page *ptepage)
 {
 #ifdef CONFIG_SMP
 	hash_page_sync();
Index: linux-work/include/asm-alpha/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-alpha/pgalloc.h	2007-07-27 13:44:45.000000000 +1000
+++ linux-work/include/asm-alpha/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -31,7 +31,7 @@ pgd_populate(struct mm_struct *mm, pgd_t
 extern pgd_t *pgd_alloc(struct mm_struct *mm);
 
 static inline void
-pgd_free(pgd_t *pgd)
+pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_page((unsigned long)pgd);
 }
@@ -44,7 +44,7 @@ pmd_alloc_one(struct mm_struct *mm, unsi
 }
 
 static inline void
-pmd_free(pmd_t *pmd)
+pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	free_page((unsigned long)pmd);
 }
@@ -67,7 +67,7 @@ pte_alloc_one(struct mm_struct *mm, unsi
 }
 
 static inline void
-pte_free(struct page *page)
+pte_free(struct mm_struct *mm, struct page *page)
 {
 	__free_page(page);
 }
Index: linux-work/include/asm-alpha/tlb.h
===================================================================
--- linux-work.orig/include/asm-alpha/tlb.h	2007-07-27 13:44:45.000000000 +1000
+++ linux-work/include/asm-alpha/tlb.h	2007-08-06 16:26:04.000000000 +1000
@@ -9,7 +9,7 @@
 
 #include <asm-generic/tlb.h>
 
-#define __pte_free_tlb(tlb,pte)			pte_free(pte)
-#define __pmd_free_tlb(tlb,pmd)			pmd_free(pmd)
+#define __pte_free_tlb(tlb,pte)			pte_free((tlb)->mm, pte)
+#define __pmd_free_tlb(tlb,pmd)			pmd_free((tlb)->mm, pmd)
  
 #endif
Index: linux-work/include/asm-arm/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-arm/pgalloc.h	2007-07-27 13:44:45.000000000 +1000
+++ linux-work/include/asm-arm/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -27,14 +27,14 @@
  * Since we have only two-level page tables, these are trivial
  */
 #define pmd_alloc_one(mm,addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(pmd)			do { } while (0)
+#define pmd_free(mm,pmd)		do { } while (0)
 #define pgd_populate(mm,pmd,pte)	BUG()
 
 extern pgd_t *get_pgd_slow(struct mm_struct *mm);
 extern void free_pgd_slow(pgd_t *pgd);
 
 #define pgd_alloc(mm)			get_pgd_slow(mm)
-#define pgd_free(pgd)			free_pgd_slow(pgd)
+#define pgd_free(mm,pgd)		free_pgd_slow(pgd)
 
 /*
  * Allocate one PTE table.
@@ -91,7 +91,7 @@ static inline void pte_free_kernel(pte_t
 	}
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
Index: linux-work/include/asm-arm/tlb.h
===================================================================
--- linux-work.orig/include/asm-arm/tlb.h	2007-07-27 13:44:45.000000000 +1000
+++ linux-work/include/asm-arm/tlb.h	2007-08-06 16:26:04.000000000 +1000
@@ -85,8 +85,8 @@ tlb_end_vma(struct mmu_gather *tlb, stru
 }
 
 #define tlb_remove_page(tlb,page)	free_page_and_swap_cache(page)
-#define pte_free_tlb(tlb,ptep)		pte_free(ptep)
-#define pmd_free_tlb(tlb,pmdp)		pmd_free(pmdp)
+#define pte_free_tlb(tlb,ptep)		pte_free((tlb)->mm, ptep)
+#define pmd_free_tlb(tlb,pmdp)		pmd_free((tlb)->mm, pmdp)
 
 #define tlb_migrate_finish(mm)		do { } while (0)
 
Index: linux-work/include/asm-avr32/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-avr32/pgalloc.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-avr32/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -36,7 +36,7 @@ static __inline__ pgd_t *pgd_alloc(struc
 	return pgd;
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	kfree(pgd);
 }
@@ -84,7 +84,7 @@ static inline void pte_free_kernel(pte_t
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
Index: linux-work/include/asm-cris/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-cris/pgalloc.h	2007-07-27 13:44:45.000000000 +1000
+++ linux-work/include/asm-cris/pgalloc.h	2007-08-06 16:26:04.000000000 +1000
@@ -16,7 +16,7 @@ static inline pgd_t *pgd_alloc (struct m
 	return (pgd_t *)get_zeroed_page(GFP_KERNEL);
 }
 
-static inline void pgd_free (pgd_t *pgd)
+static inline void pgd_free (struct mm_struct *mm, pgd_t *pgd)
 {
 	free_page((unsigned long)pgd);
 }
@@ -39,7 +39,7 @@ static inline void pte_free_kernel(pte_t
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
Index: linux-work/include/asm-frv/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-frv/pgalloc.h	2007-07-27 13:44:45.000000000 +1000
+++ linux-work/include/asm-frv/pgalloc.h	2007-08-06 16:26:04.000000000 +1000
@@ -31,7 +31,7 @@ do {										\
  */
 
 extern pgd_t *pgd_alloc(struct mm_struct *);
-extern void pgd_free(pgd_t *);
+extern void pgd_free(struct mm_struct *mm, pgd_t *);
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
 
@@ -42,7 +42,7 @@ static inline void pte_free_kernel(pte_t
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
@@ -55,7 +55,7 @@ static inline void pte_free(struct page 
  * (In the PAE case we free the pmds as part of the pgd.)
  */
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *) 2); })
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
 
 #endif /* CONFIG_MMU */
Index: linux-work/include/asm-i386/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-i386/pgalloc.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-i386/pgalloc.h	2007-08-06 16:26:05.000000000 +1000
@@ -33,7 +33,7 @@ do {								\
  * Allocate and free page tables.
  */
 extern pgd_t *pgd_alloc(struct mm_struct *);
-extern void pgd_free(pgd_t *pgd);
+extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
 extern struct page *pte_alloc_one(struct mm_struct *, unsigned long);
@@ -43,7 +43,7 @@ static inline void pte_free_kernel(pte_t
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
@@ -60,7 +60,7 @@ do {									\
  * In the PAE case we free the pmds as part of the pgd.
  */
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm,x)			do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
 #define pud_populate(mm, pmd, pte)	BUG()
 #endif
Index: linux-work/include/asm-ia64/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-ia64/pgalloc.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-ia64/pgalloc.h	2007-08-06 16:26:05.000000000 +1000
@@ -27,7 +27,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pgd_free(pgd_t * pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t * pgd)
 {
 	quicklist_free(0, NULL, pgd);
 }
@@ -44,11 +44,11 @@ static inline pud_t *pud_alloc_one(struc
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pud_free(pud_t * pud)
+static inline void pud_free(struct mm_struct *mm, pud_t * pud)
 {
 	quicklist_free(0, NULL, pud);
 }
-#define __pud_free_tlb(tlb, pud)	pud_free(pud)
+#define __pud_free_tlb(tlb, pud)	pud_free((tlb)->mm, pud)
 #endif /* CONFIG_PGTABLE_4 */
 
 static inline void
@@ -62,12 +62,12 @@ static inline pmd_t *pmd_alloc_one(struc
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pmd_free(pmd_t * pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t * pmd)
 {
 	quicklist_free(0, NULL, pmd);
 }
 
-#define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
+#define __pmd_free_tlb(tlb, pmd)	pmd_free((tlb)->mm, pmd)
 
 static inline void
 pmd_populate(struct mm_struct *mm, pmd_t * pmd_entry, struct page *pte)
@@ -94,7 +94,7 @@ static inline pte_t *pte_alloc_one_kerne
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	quicklist_free_page(0, NULL, pte);
 }
@@ -109,6 +109,6 @@ static inline void check_pgt_cache(void)
 	quicklist_trim(0, NULL, 25, 16);
 }
 
-#define __pte_free_tlb(tlb, pte)	pte_free(pte)
+#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, pte)
 
 #endif				/* _ASM_IA64_PGALLOC_H */
Index: linux-work/include/asm-m32r/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-m32r/pgalloc.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-m32r/pgalloc.h	2007-08-06 16:26:05.000000000 +1000
@@ -24,7 +24,7 @@ static __inline__ pgd_t *pgd_alloc(struc
 	return pgd;
 }
 
-static __inline__ void pgd_free(pgd_t *pgd)
+static __inline__ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_page((unsigned long)pgd);
 }
@@ -51,12 +51,12 @@ static __inline__ void pte_free_kernel(p
 	free_page((unsigned long)pte);
 }
 
-static __inline__ void pte_free(struct page *pte)
+static __inline__ void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
 
-#define __pte_free_tlb(tlb, pte)	pte_free((pte))
+#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
@@ -65,7 +65,7 @@ static __inline__ void pte_free(struct p
  */
 
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm,x)			do { } while (0)
 #define __pmd_free_tlb(tlb, x)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 
Index: linux-work/include/asm-m68k/motorola_pgalloc.h
===================================================================
--- linux-work.orig/include/asm-m68k/motorola_pgalloc.h	2007-07-27 13:44:45.000000000 +1000
+++ linux-work/include/asm-m68k/motorola_pgalloc.h	2007-08-06 16:26:04.000000000 +1000
@@ -47,7 +47,7 @@ static inline struct page *pte_alloc_one
 	return page;
 }
 
-static inline void pte_free(struct page *page)
+static inline void pte_free(struct mm_struct *mm, struct page *page)
 {
 	cache_page(kmap(page));
 	kunmap(page);
@@ -67,7 +67,7 @@ static inline pmd_t *pmd_alloc_one(struc
 	return get_pointer_table();
 }
 
-static inline int pmd_free(pmd_t *pmd)
+static inline int pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	return free_pointer_table(pmd);
 }
@@ -78,9 +78,9 @@ static inline int __pmd_free_tlb(struct 
 }
 
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
-	pmd_free((pmd_t *)pgd);
+	pmd_free(mm, (pmd_t *)pgd);
 }
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
Index: linux-work/include/asm-m68k/sun3_pgalloc.h
===================================================================
--- linux-work.orig/include/asm-m68k/sun3_pgalloc.h	2007-07-27 13:44:45.000000000 +1000
+++ linux-work/include/asm-m68k/sun3_pgalloc.h	2007-08-06 16:26:04.000000000 +1000
@@ -26,7 +26,7 @@ static inline void pte_free_kernel(pte_t
         free_page((unsigned long) pte);
 }
 
-static inline void pte_free(struct page *page)
+static inline void pte_free(struct mm_struct *mm, struct page *page)
 {
         __free_page(page);
 }
@@ -72,10 +72,10 @@ static inline void pmd_populate(struct m
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
  * inside the pgd, so has no extra memory associated with it.
  */
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb, x)		do { } while (0)
 
-static inline void pgd_free(pgd_t * pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t * pgd)
 {
         free_page((unsigned long) pgd);
 }
Index: linux-work/include/asm-mips/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-mips/pgalloc.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-mips/pgalloc.h	2007-08-06 16:26:05.000000000 +1000
@@ -58,7 +58,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return ret;
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_pages((unsigned long)pgd, PGD_ORDER);
 }
@@ -90,7 +90,7 @@ static inline void pte_free_kernel(pte_t
 	free_pages((unsigned long)pte, PTE_ORDER);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_pages(pte, PTE_ORDER);
 }
@@ -103,7 +103,7 @@ static inline void pte_free(struct page 
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
  * inside the pgd, so has no extra memory associated with it.
  */
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
 
 #endif
@@ -120,12 +120,12 @@ static inline pmd_t *pmd_alloc_one(struc
 	return pmd;
 }
 
-static inline void pmd_free(pmd_t *pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	free_pages((unsigned long)pmd, PMD_ORDER);
 }
 
-#define __pmd_free_tlb(tlb,x)	pmd_free(x)
+#define __pmd_free_tlb(tlb,x)	pmd_free((tlb)->mm, x)
 
 #endif
 
Index: linux-work/include/asm-parisc/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-parisc/pgalloc.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-parisc/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -43,7 +43,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return actual_pgd;
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 #ifdef CONFIG_64BIT
 	pgd -= PTRS_PER_PGD;
@@ -70,7 +70,7 @@ static inline pmd_t *pmd_alloc_one(struc
 	return pmd;
 }
 
-static inline void pmd_free(pmd_t *pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 #ifdef CONFIG_64BIT
 	if(pmd_flag(*pmd) & PxD_FLAG_ATTACHED)
@@ -91,7 +91,7 @@ static inline void pmd_free(pmd_t *pmd)
  */
 
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm, x)			do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 
 #endif
@@ -135,7 +135,7 @@ static inline void pte_free_kernel(pte_t
 	free_page((unsigned long)pte);
 }
 
-#define pte_free(page)	pte_free_kernel(page_address(page))
+#define pte_free(mm,page)	pte_free_kernel(page_address(page))
 
 #define check_pgt_cache()	do { } while (0)
 
Index: linux-work/include/asm-parisc/tlb.h
===================================================================
--- linux-work.orig/include/asm-parisc/tlb.h	2007-07-27 13:44:45.000000000 +1000
+++ linux-work/include/asm-parisc/tlb.h	2007-08-06 16:26:05.000000000 +1000
@@ -21,7 +21,7 @@ do {	if (!(tlb)->fullmm)	\
 
 #include <asm-generic/tlb.h>
 
-#define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
-#define __pte_free_tlb(tlb, pte)	pte_free(pte)
+#define __pmd_free_tlb(tlb, pmd)	pmd_free((tlb)->mm, pmd)
+#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, pte)
 
 #endif
Index: linux-work/include/asm-powerpc/pgalloc-32.h
===================================================================
--- linux-work.orig/include/asm-powerpc/pgalloc-32.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-powerpc/pgalloc-32.h	2007-08-06 16:26:05.000000000 +1000
@@ -6,14 +6,14 @@
 extern void __bad_pte(pmd_t *pmd);
 
 extern pgd_t *pgd_alloc(struct mm_struct *mm);
-extern void pgd_free(pgd_t *pgd);
+extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
 /*
  * We don't have any real pmd's, and this code never triggers because
  * the pgd will always be present..
  */
 /* #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); }) */
-#define pmd_free(x)                     do { } while (0)
+#define pmd_free(mm, x)                 do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
 /* #define pgd_populate(mm, pmd, pte)      BUG() */
 
@@ -32,9 +32,9 @@ extern void pgd_free(pgd_t *pgd);
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
 extern struct page *pte_alloc_one(struct mm_struct *mm, unsigned long addr);
 extern void pte_free_kernel(pte_t *pte);
-extern void pte_free(struct page *pte);
+extern void pte_free(struct mm_struct *mm, struct page *pte);
 
-#define __pte_free_tlb(tlb, pte)	pte_free((pte))
+#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
 
 #define check_pgt_cache()	do { } while (0)
 
Index: linux-work/include/asm-powerpc/pgalloc-64.h
===================================================================
--- linux-work.orig/include/asm-powerpc/pgalloc-64.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-powerpc/pgalloc-64.h	2007-08-06 16:26:05.000000000 +1000
@@ -25,7 +25,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return kmem_cache_alloc(pgtable_cache[PGD_CACHE_NUM], GFP_KERNEL);
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	kmem_cache_free(pgtable_cache[PGD_CACHE_NUM], pgd);
 }
@@ -40,7 +40,7 @@ static inline pud_t *pud_alloc_one(struc
 				GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline void pud_free(pud_t *pud)
+static inline void pud_free(struct mm_struct *mm, pud_t *pud)
 {
 	kmem_cache_free(pgtable_cache[PUD_CACHE_NUM], pud);
 }
@@ -76,7 +76,7 @@ static inline pmd_t *pmd_alloc_one(struc
 				GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline void pmd_free(pmd_t *pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	kmem_cache_free(pgtable_cache[PMD_CACHE_NUM], pmd);
 }
@@ -99,7 +99,7 @@ static inline void pte_free_kernel(pte_t
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct page *ptepage)
+static inline void pte_free(struct mm_struct *mm, struct page *ptepage)
 {
 	__free_page(ptepage);
 }
Index: linux-work/include/asm-ppc/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-ppc/pgalloc.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-ppc/pgalloc.h	2007-08-06 16:26:05.000000000 +1000
@@ -7,14 +7,14 @@
 extern void __bad_pte(pmd_t *pmd);
 
 extern pgd_t *pgd_alloc(struct mm_struct *mm);
-extern void pgd_free(pgd_t *pgd);
+extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
 /*
  * We don't have any real pmd's, and this code never triggers because
  * the pgd will always be present..
  */
 #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); })
-#define pmd_free(x)                     do { } while (0)
+#define pmd_free(mm,x)                  do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)      BUG()
 
@@ -33,9 +33,9 @@ extern void pgd_free(pgd_t *pgd);
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
 extern struct page *pte_alloc_one(struct mm_struct *mm, unsigned long addr);
 extern void pte_free_kernel(pte_t *pte);
-extern void pte_free(struct page *pte);
+extern void pte_free(struct mm_struct *mm, struct page *pte);
 
-#define __pte_free_tlb(tlb, pte)	pte_free((pte))
+#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
 
 #define check_pgt_cache()	do { } while (0)
 
Index: linux-work/include/asm-s390/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-s390/pgalloc.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-s390/pgalloc.h	2007-08-06 16:26:05.000000000 +1000
@@ -67,7 +67,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return pgd;
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	pgd_t *shadow_pgd = get_shadow_pgd(pgd);
 
@@ -83,7 +83,7 @@ static inline void pgd_free(pgd_t *pgd)
  * code never triggers because the pgd will always be present.
  */
 #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); })
-#define pmd_free(x)                     do { } while (0)
+#define pmd_free(mm, x)                 do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)      BUG()
 #define pgd_populate_kernel(mm, pmd, pte)	BUG()
@@ -111,7 +111,7 @@ static inline pmd_t * pmd_alloc_one(stru
 	return pmd;
 }
 
-static inline void pmd_free (pmd_t *pmd)
+static inline void pmd_free (struct mm_struct *mm, pmd_t *pmd)
 {
 	pmd_t *shadow_pmd = get_shadow_pmd(pmd);
 
@@ -123,7 +123,7 @@ static inline void pmd_free (pmd_t *pmd)
 #define __pmd_free_tlb(tlb,pmd)			\
 	do {					\
 		tlb_flush_mmu(tlb, 0, 0);	\
-		pmd_free(pmd);			\
+		pmd_free((tlb)->mm, pmd);	\
 	 } while (0)
 
 static inline void
@@ -217,7 +217,7 @@ static inline void pte_free_kernel(pte_t
 	free_page((unsigned long) pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	struct page *shadow_page = get_shadow_page(pte);
 
Index: linux-work/include/asm-sh/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-sh/pgalloc.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-sh/pgalloc.h	2007-08-06 16:26:05.000000000 +1000
@@ -36,7 +36,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return quicklist_alloc(QUICK_PGD, GFP_KERNEL | __GFP_REPEAT, pgd_ctor);
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	quicklist_free(QUICK_PGD, NULL, pgd);
 }
@@ -59,7 +59,7 @@ static inline void pte_free_kernel(pte_t
 	quicklist_free(QUICK_PT, NULL, pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	quicklist_free_page(QUICK_PT, NULL, pte);
 }
@@ -71,7 +71,7 @@ static inline void pte_free(struct page 
  * inside the pgd, so has no extra memory associated with it.
  */
 
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm,x)			do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
 
 static inline void check_pgt_cache(void)
Index: linux-work/include/asm-sh64/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-sh64/pgalloc.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-sh64/pgalloc.h	2007-08-06 16:26:05.000000000 +1000
@@ -46,7 +46,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	quicklist_free(0, NULL, pgd);
 }
@@ -63,7 +63,7 @@ static inline void pte_free_kernel(pte_t
 	quicklist_free(0, NULL, pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	quicklist_free_page(0, NULL, pte);
 }
@@ -84,7 +84,7 @@ static inline pte_t *pte_alloc_one_kerne
 #if defined(CONFIG_SH64_PGTABLE_2_LEVEL)
 
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(x)			do { } while (0)
+#define pmd_free(mm, x)			do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 #define __pte_free_tlb(tlb,pte)		tlb_remove_page((tlb),(pte))
 #define __pmd_free_tlb(tlb,pmd)		do { } while (0)
@@ -96,13 +96,13 @@ static inline pmd_t *pmd_alloc_one(struc
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pmd_free(pmd_t *pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	quicklist_free(0, NULL, pmd);
 }
 
 #define pgd_populate(mm, pgd, pmd)	pgd_set(pgd, pmd)
-#define __pmd_free_tlb(tlb,pmd)		pmd_free(pmd)
+#define __pmd_free_tlb(tlb,pmd)		pmd_free((tlb)->mm, pmd)
 
 #else
 #error "No defined page table size"
Index: linux-work/include/asm-sparc/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-sparc/pgalloc.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-sparc/pgalloc.h	2007-08-06 16:26:05.000000000 +1000
@@ -32,8 +32,8 @@ BTFIXUPDEF_CALL(pgd_t *, get_pgd_fast, v
 BTFIXUPDEF_CALL(void, free_pgd_fast, pgd_t *)
 #define free_pgd_fast(pgd)	BTFIXUP_CALL(free_pgd_fast)(pgd)
 
-#define pgd_free(pgd)	free_pgd_fast(pgd)
-#define pgd_alloc(mm)	get_pgd_fast()
+#define pgd_free(mm,pgd)	free_pgd_fast(pgd)
+#define pgd_alloc(mm)		get_pgd_fast()
 
 BTFIXUPDEF_CALL(void, pgd_set, pgd_t *, pmd_t *)
 #define pgd_set(pgdp,pmdp) BTFIXUP_CALL(pgd_set)(pgdp,pmdp)
@@ -45,8 +45,8 @@ BTFIXUPDEF_CALL(pmd_t *, pmd_alloc_one, 
 BTFIXUPDEF_CALL(void, free_pmd_fast, pmd_t *)
 #define free_pmd_fast(pmd)	BTFIXUP_CALL(free_pmd_fast)(pmd)
 
-#define pmd_free(pmd)           free_pmd_fast(pmd)
-#define __pmd_free_tlb(tlb, pmd) pmd_free(pmd)
+#define pmd_free(mm,pmd)	free_pmd_fast(pmd)
+#define __pmd_free_tlb(tlb, pmd) pmd_free((tlb)->mm, pmd)
 
 BTFIXUPDEF_CALL(void, pmd_populate, pmd_t *, struct page *)
 #define pmd_populate(MM, PMD, PTE)        BTFIXUP_CALL(pmd_populate)(PMD, PTE)
@@ -62,7 +62,7 @@ BTFIXUPDEF_CALL(void, free_pte_fast, pte
 #define pte_free_kernel(pte)	BTFIXUP_CALL(free_pte_fast)(pte)
 
 BTFIXUPDEF_CALL(void, pte_free, struct page *)
-#define pte_free(pte)		BTFIXUP_CALL(pte_free)(pte)
-#define __pte_free_tlb(tlb, pte)	pte_free(pte)
+#define pte_free(mm,pte)	BTFIXUP_CALL(pte_free)(pte)
+#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, pte)
 
 #endif /* _SPARC_PGALLOC_H */
Index: linux-work/include/asm-sparc64/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-sparc64/pgalloc.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-sparc64/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -20,7 +20,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	quicklist_free(0, NULL, pgd);
 }
@@ -32,7 +32,7 @@ static inline pmd_t *pmd_alloc_one(struc
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pmd_free(pmd_t *pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	quicklist_free(0, NULL, pmd);
 }
@@ -55,7 +55,7 @@ static inline void pte_free_kernel(pte_t
 	quicklist_free(0, NULL, pte);
 }
 
-static inline void pte_free(struct page *ptepage)
+static inline void pte_free(struct mm_struct *mm, struct page *ptepage)
 {
 	quicklist_free_page(0, NULL, ptepage);
 }
Index: linux-work/include/asm-sparc64/tlb.h
===================================================================
--- linux-work.orig/include/asm-sparc64/tlb.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-sparc64/tlb.h	2007-08-06 16:26:05.000000000 +1000
@@ -49,8 +49,8 @@ extern void smp_flush_tlb_mm(struct mm_s
 #endif
 
 #define __tlb_remove_tlb_entry(mp,ptep,addr) do { } while (0)
-#define __pte_free_tlb(mp,ptepage) pte_free(ptepage)
-#define __pmd_free_tlb(mp,pmdp) pmd_free(pmdp)
+#define __pte_free_tlb(mp,ptepage) pte_free((mp)->mm,ptepage)
+#define __pmd_free_tlb(mp,pmdp) pmd_free((mp)->mm,pmdp)
 
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
Index: linux-work/include/asm-um/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-um/pgalloc.h	2007-07-27 13:44:46.000000000 +1000
+++ linux-work/include/asm-um/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -23,7 +23,7 @@
  * Allocate and free page tables.
  */
 extern pgd_t *pgd_alloc(struct mm_struct *);
-extern void pgd_free(pgd_t *pgd);
+extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
 extern struct page *pte_alloc_one(struct mm_struct *, unsigned long);
@@ -33,7 +33,7 @@ static inline void pte_free_kernel(pte_t
 	free_page((unsigned long) pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	__free_page(pte);
 }
@@ -42,7 +42,7 @@ static inline void pte_free(struct page 
 
 #ifdef CONFIG_3_LEVEL_PGTABLES
 
-extern __inline__ void pmd_free(pmd_t *pmd)
+extern __inline__ void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	free_page((unsigned long)pmd);
 }
Index: linux-work/include/asm-x86_64/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-x86_64/pgalloc.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-x86_64/pgalloc.h	2007-08-06 16:26:05.000000000 +1000
@@ -21,7 +21,7 @@ static inline void pmd_populate(struct m
 	set_pmd(pmd, __pmd(_PAGE_TABLE | (page_to_pfn(pte) << PAGE_SHIFT)));
 }
 
-static inline void pmd_free(pmd_t *pmd)
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	BUG_ON((unsigned long)pmd & (PAGE_SIZE-1));
 	quicklist_free(QUICK_PT, NULL, pmd);
@@ -37,7 +37,7 @@ static inline pud_t *pud_alloc_one(struc
 	return (pud_t *)quicklist_alloc(QUICK_PT, GFP_KERNEL|__GFP_REPEAT, NULL);
 }
 
-static inline void pud_free (pud_t *pud)
+static inline void pud_free (struct mm_struct *mm, pud_t *pud)
 {
 	BUG_ON((unsigned long)pud & (PAGE_SIZE-1));
 	quicklist_free(QUICK_PT, NULL, pud);
@@ -97,7 +97,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return pgd;
 }
 
-static inline void pgd_free(pgd_t *pgd)
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	BUG_ON((unsigned long)pgd & (PAGE_SIZE-1));
 	quicklist_free(QUICK_PGD, pgd_dtor, pgd);
@@ -126,7 +126,7 @@ static inline void pte_free_kernel(pte_t
 	quicklist_free(QUICK_PT, NULL, pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
 	quicklist_free_page(QUICK_PT, NULL, pte);
 }
Index: linux-work/include/asm-xtensa/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-xtensa/pgalloc.h	2007-07-27 13:44:46.000000000 +1000
+++ linux-work/include/asm-xtensa/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -63,7 +63,7 @@
  * inside the pgd, so has no extra memory associated with it.
  */
 
-#define pgd_free(pgd)	free_page((unsigned long)(pgd))
+#define pgd_free(mm,pgd)	free_page((unsigned long)(pgd))
 
 #if (DCACHE_WAY_SIZE > PAGE_SIZE) && XCHAL_DCACHE_IS_WRITEBACK
 
@@ -109,7 +109,7 @@ extern pte_t* pte_alloc_one_kernel(struc
 extern struct page* pte_alloc_one(struct mm_struct* mm, unsigned long addr);
 
 #define pte_free_kernel(pte) free_page((unsigned long)pte)
-#define pte_free(pte) __free_page(pte)
+#define pte_free(mm,pte) __free_page(pte)
 
 #endif /* __KERNEL__ */
 #endif /* _XTENSA_PGALLOC_H */
Index: linux-work/include/asm-xtensa/tlb.h
===================================================================
--- linux-work.orig/include/asm-xtensa/tlb.h	2007-07-27 13:44:46.000000000 +1000
+++ linux-work/include/asm-xtensa/tlb.h	2007-08-06 16:26:05.000000000 +1000
@@ -20,6 +20,6 @@
 #include <asm-generic/tlb.h>
 #include <asm/page.h>
 
-#define __pte_free_tlb(tlb,pte)			pte_free(pte)
+#define __pte_free_tlb(tlb,pte)			pte_free((tlb)->mm, pte)
 
 #endif	/* _XTENSA_TLB_H */
Index: linux-work/mm/memory.c
===================================================================
--- linux-work.orig/mm/memory.c	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/mm/memory.c	2007-08-06 16:26:05.000000000 +1000
@@ -305,7 +305,7 @@ int __pte_alloc(struct mm_struct *mm, pm
 	spin_lock(&mm->page_table_lock);
 	if (pmd_present(*pmd)) {	/* Another has populated it */
 		pte_lock_deinit(new);
-		pte_free(new);
+		pte_free(mm, new);
 	} else {
 		mm->nr_ptes++;
 		inc_zone_page_state(new, NR_PAGETABLE);
@@ -2669,7 +2669,7 @@ int __pud_alloc(struct mm_struct *mm, pg
 
 	spin_lock(&mm->page_table_lock);
 	if (pgd_present(*pgd))		/* Another has populated it */
-		pud_free(new);
+		pud_free(mm, new);
 	else
 		pgd_populate(mm, pgd, new);
 	spin_unlock(&mm->page_table_lock);
@@ -2691,12 +2691,12 @@ int __pmd_alloc(struct mm_struct *mm, pu
 	spin_lock(&mm->page_table_lock);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (pud_present(*pud))		/* Another has populated it */
-		pmd_free(new);
+		pmd_free(mm, new);
 	else
 		pud_populate(mm, pud, new);
 #else
 	if (pgd_present(*pud))		/* Another has populated it */
-		pmd_free(new);
+		pmd_free(mm, new);
 	else
 		pgd_populate(mm, pud, new);
 #endif /* __ARCH_HAS_4LEVEL_HACK */
Index: linux-work/include/asm-generic/4level-fixup.h
===================================================================
--- linux-work.orig/include/asm-generic/4level-fixup.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-generic/4level-fixup.h	2007-08-06 16:26:04.000000000 +1000
@@ -28,7 +28,7 @@
 
 #undef pud_free_tlb
 #define pud_free_tlb(tlb, x)            do { } while (0)
-#define pud_free(x)			do { } while (0)
+#define pud_free(mm,x)			do { } while (0)
 #define __pud_free_tlb(tlb, x)		do { } while (0)
 
 #undef  pud_addr_end
Index: linux-work/include/asm-generic/pgtable-nopmd.h
===================================================================
--- linux-work.orig/include/asm-generic/pgtable-nopmd.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-generic/pgtable-nopmd.h	2007-08-06 16:26:04.000000000 +1000
@@ -54,7 +54,7 @@ static inline pmd_t * pmd_offset(pud_t *
  * inside the pud, so has no extra memory associated with it.
  */
 #define pmd_alloc_one(mm, address)		NULL
-#define pmd_free(x)				do { } while (0)
+#define pmd_free(mm,x)				do { } while (0)
 #define __pmd_free_tlb(tlb, x)			do { } while (0)
 
 #undef  pmd_addr_end
Index: linux-work/include/asm-generic/pgtable-nopud.h
===================================================================
--- linux-work.orig/include/asm-generic/pgtable-nopud.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-generic/pgtable-nopud.h	2007-08-06 16:26:04.000000000 +1000
@@ -51,7 +51,7 @@ static inline pud_t * pud_offset(pgd_t *
  * inside the pgd, so has no extra memory associated with it.
  */
 #define pud_alloc_one(mm, address)		NULL
-#define pud_free(x)				do { } while (0)
+#define pud_free(mm,x)				do { } while (0)
 #define __pud_free_tlb(tlb, x)			do { } while (0)
 
 #undef  pud_addr_end
Index: linux-work/arch/arm/kernel/smp.c
===================================================================
--- linux-work.orig/arch/arm/kernel/smp.c	2007-08-06 13:48:27.000000000 +1000
+++ linux-work/arch/arm/kernel/smp.c	2007-08-06 16:15:18.000000000 +1000
@@ -150,7 +150,7 @@ int __cpuinit __cpu_up(unsigned int cpu)
 	secondary_data.pgdir = 0;
 
 	*pmd_offset(pgd, PHYS_OFFSET) = __pmd(0);
-	pgd_free(pgd);
+	pgd_free(&init_mm, pgd);
 
 	if (ret) {
 		printk(KERN_CRIT "CPU%u: processor failed to boot\n", cpu);
Index: linux-work/arch/arm/mm/pgd.c
===================================================================
--- linux-work.orig/arch/arm/mm/pgd.c	2007-08-06 13:48:27.000000000 +1000
+++ linux-work/arch/arm/mm/pgd.c	2007-08-06 16:15:18.000000000 +1000
@@ -65,7 +65,7 @@ pgd_t *get_pgd_slow(struct mm_struct *mm
 	return new_pgd;
 
 no_pte:
-	pmd_free(new_pmd);
+	pmd_free(mm,new_pmd);
 no_pmd:
 	free_pages((unsigned long)new_pgd, 2);
 no_pgd:
@@ -94,8 +94,8 @@ void free_pgd_slow(pgd_t *pgd)
 	pmd_clear(pmd);
 	dec_zone_page_state(virt_to_page((unsigned long *)pgd), NR_PAGETABLE);
 	pte_lock_deinit(pte);
-	pte_free(pte);
-	pmd_free(pmd);
+	pte_free(NULL, pte); /* our impl. doesn't use the mm arg */
+	pmd_free(NULL, pmd); /* ditto */
 free:
 	free_pages((unsigned long) pgd, 2);
 }
Index: linux-work/arch/frv/mm/pgalloc.c
===================================================================
--- linux-work.orig/arch/frv/mm/pgalloc.c	2007-08-06 13:48:27.000000000 +1000
+++ linux-work/arch/frv/mm/pgalloc.c	2007-08-06 16:15:18.000000000 +1000
@@ -140,7 +140,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	return pgd;
 }
 
-void pgd_free(pgd_t *pgd)
+void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	/* in the non-PAE case, clear_page_tables() clears user pgd entries */
  	quicklist_free(0, pgd_dtor, pgd);
Index: linux-work/arch/i386/mm/pgtable.c
===================================================================
--- linux-work.orig/arch/i386/mm/pgtable.c	2007-08-06 13:48:27.000000000 +1000
+++ linux-work/arch/i386/mm/pgtable.c	2007-08-06 16:15:18.000000000 +1000
@@ -350,7 +350,7 @@ out_oom:
 	return NULL;
 }
 
-void pgd_free(pgd_t *pgd)
+void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	int i;
 
Index: linux-work/arch/um/kernel/mem.c
===================================================================
--- linux-work.orig/arch/um/kernel/mem.c	2007-08-06 13:48:28.000000000 +1000
+++ linux-work/arch/um/kernel/mem.c	2007-08-06 16:15:18.000000000 +1000
@@ -348,7 +348,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	return pgd;
 }
 
-void pgd_free(pgd_t *pgd)
+void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_page((unsigned long) pgd);
 }
Index: linux-work/arch/um/kernel/skas/mmu.c
===================================================================
--- linux-work.orig/arch/um/kernel/skas/mmu.c	2007-08-06 13:48:28.000000000 +1000
+++ linux-work/arch/um/kernel/skas/mmu.c	2007-08-06 16:15:18.000000000 +1000
@@ -64,9 +64,9 @@ static int init_stub_pte(struct mm_struc
 	return(0);
 
  out_pmd:
-	pud_free(pud);
+	pud_free(mm, pud);
  out_pte:
-	pmd_free(pmd);
+	pmd_free(mm, pmd);
  out:
 	return(-ENOMEM);
 }
@@ -152,7 +152,7 @@ void destroy_context_skas(struct mm_stru
 		pte_free_kernel((pte_t *) mmu->last_page_table);
 		dec_zone_page_state(virt_to_page(mmu->last_page_table), NR_PAGETABLE);
 #ifdef CONFIG_3_LEVEL_PGTABLES
-		pmd_free((pmd_t *) mmu->last_pmd);
+		pmd_free(mm, (pmd_t *) mmu->last_pmd);
 #endif
 	}
 }
Index: linux-work/kernel/fork.c
===================================================================
--- linux-work.orig/kernel/fork.c	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/kernel/fork.c	2007-08-06 16:26:17.000000000 +1000
@@ -313,7 +313,7 @@ static inline int mm_alloc_pgd(struct mm
 
 static inline void mm_free_pgd(struct mm_struct * mm)
 {
-	pgd_free(mm->pgd);
+	pgd_free(mm, mm->pgd);
 }
 #else
 #define dup_mmap(mm, oldmm)	(0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
