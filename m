From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 07 Aug 2007 17:19:49 +1000
Subject: [RFC/PATCH 6/12] Add "address" argument to pte/pmd/pud_free_tlb()
In-Reply-To: <1186471185.826251.312410898174.qpush@grosgo>
Message-Id: <20070807071956.7B5B0DDE09@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Architectures like ia64 who use a virtual page table can benefit
from knowing the virtual address range affected by a page table
being removed. We already pass that information to the alloc
functions, let's pass it to the free ones. I've only changed
the tlb_* versions for simplicity.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 arch/powerpc/mm/hugetlbpage.c       |    4 ++--
 include/asm-alpha/tlb.h             |    4 ++--
 include/asm-arm/tlb.h               |    4 ++--
 include/asm-cris/pgalloc.h          |    2 +-
 include/asm-frv/pgalloc.h           |    4 ++--
 include/asm-generic/4level-fixup.h  |    4 ++--
 include/asm-generic/pgtable-nopmd.h |    2 +-
 include/asm-generic/pgtable-nopud.h |    2 +-
 include/asm-generic/tlb.h           |   12 ++++++------
 include/asm-i386/pgalloc.h          |    4 ++--
 include/asm-ia64/pgalloc.h          |    6 +++---
 include/asm-ia64/tlb.h              |   12 ++++++------
 include/asm-m32r/pgalloc.h          |    4 ++--
 include/asm-m68k/motorola_pgalloc.h |    6 ++++--
 include/asm-m68k/sun3_pgalloc.h     |    4 ++--
 include/asm-mips/pgalloc.h          |    6 +++---
 include/asm-parisc/tlb.h            |    4 ++--
 include/asm-powerpc/pgalloc-32.h    |    4 ++--
 include/asm-powerpc/pgalloc-64.h    |    6 +++---
 include/asm-ppc/pgalloc.h           |    4 ++--
 include/asm-s390/pgalloc.h          |    6 +++---
 include/asm-sh/pgalloc.h            |    4 ++--
 include/asm-sh64/pgalloc.h          |    7 +++----
 include/asm-sparc/pgalloc.h         |    4 ++--
 include/asm-sparc64/tlb.h           |    6 +++---
 include/asm-x86_64/pgalloc.h        |    6 +++---
 include/asm-xtensa/tlb.h            |    2 +-
 mm/memory.c                         |   11 ++++++-----
 28 files changed, 73 insertions(+), 71 deletions(-)

Index: linux-work/include/asm-m68k/sun3_pgalloc.h
===================================================================
--- linux-work.orig/include/asm-m68k/sun3_pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-m68k/sun3_pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -31,7 +31,7 @@ static inline void pte_free(struct mm_st
         __free_page(page);
 }
 
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte,address) tlb_remove_page((tlb),(pte))
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
@@ -73,7 +73,7 @@ static inline void pmd_populate(struct m
  * inside the pgd, so has no extra memory associated with it.
  */
 #define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb, x)		do { } while (0)
+#define __pmd_free_tlb(tlb, x, a)	do { } while (0)
 
 static inline void pgd_free(struct mm_struct *mm, pgd_t * pgd)
 {
Index: linux-work/include/asm-generic/tlb.h
===================================================================
--- linux-work.orig/include/asm-generic/tlb.h	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/include/asm-generic/tlb.h	2007-08-06 16:15:18.000000000 +1000
@@ -123,24 +123,24 @@ static inline void tlb_remove_page(struc
 		__tlb_remove_tlb_entry(tlb, ptep, address);	\
 	} while (0)
 
-#define pte_free_tlb(tlb, ptep)					\
+#define pte_free_tlb(tlb, ptep, address)			\
 	do {							\
 		tlb->need_flush = 1;				\
-		__pte_free_tlb(tlb, ptep);			\
+		__pte_free_tlb(tlb, ptep, address);		\
 	} while (0)
 
 #ifndef __ARCH_HAS_4LEVEL_HACK
-#define pud_free_tlb(tlb, pudp)					\
+#define pud_free_tlb(tlb, pudp, address)			\
 	do {							\
 		tlb->need_flush = 1;				\
-		__pud_free_tlb(tlb, pudp);			\
+		__pud_free_tlb(tlb, pudp, address);		\
 	} while (0)
 #endif
 
-#define pmd_free_tlb(tlb, pmdp)					\
+#define pmd_free_tlb(tlb, pmdp, address)			\
 	do {							\
 		tlb->need_flush = 1;				\
-		__pmd_free_tlb(tlb, pmdp);			\
+		__pmd_free_tlb(tlb, pmdp, address);		\
 	} while (0)
 
 #define tlb_migrate_finish(mm) do {} while (0)
Index: linux-work/include/asm-alpha/tlb.h
===================================================================
--- linux-work.orig/include/asm-alpha/tlb.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-alpha/tlb.h	2007-08-06 16:15:18.000000000 +1000
@@ -9,7 +9,7 @@
 
 #include <asm-generic/tlb.h>
 
-#define __pte_free_tlb(tlb,pte)			pte_free((tlb)->mm, pte)
-#define __pmd_free_tlb(tlb,pmd)			pmd_free((tlb)->mm, pmd)
+#define __pte_free_tlb(tlb,pte,address)		pte_free((tlb)->mm, pte)
+#define __pmd_free_tlb(tlb,pmd,address)		pmd_free((tlb)->mm, pmd)
  
 #endif
Index: linux-work/include/asm-arm/tlb.h
===================================================================
--- linux-work.orig/include/asm-arm/tlb.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-arm/tlb.h	2007-08-06 16:15:18.000000000 +1000
@@ -85,8 +85,8 @@ tlb_end_vma(struct mmu_gather *tlb, stru
 }
 
 #define tlb_remove_page(tlb,page)	free_page_and_swap_cache(page)
-#define pte_free_tlb(tlb,ptep)		pte_free((tlb)->mm, ptep)
-#define pmd_free_tlb(tlb,pmdp)		pmd_free((tlb)->mm, pmdp)
+#define pte_free_tlb(tlb,ptep,address)	pte_free((tlb)->mm, ptep)
+#define pmd_free_tlb(tlb,pmdp,address)	pmd_free((tlb)->mm, pmdp)
 
 #define tlb_migrate_finish(mm)		do { } while (0)
 
Index: linux-work/include/asm-cris/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-cris/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-cris/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -45,7 +45,7 @@ static inline void pte_free(struct mm_st
 }
 
 
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte,address) tlb_remove_page((tlb),(pte))
 
 #define check_pgt_cache()          do { } while (0)
 
Index: linux-work/include/asm-frv/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-frv/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-frv/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -47,7 +47,7 @@ static inline void pte_free(struct mm_st
 	__free_page(pte);
 }
 
-#define __pte_free_tlb(tlb,pte)		tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte,address)		tlb_remove_page((tlb),(pte))
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
@@ -56,7 +56,7 @@ static inline void pte_free(struct mm_st
  */
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *) 2); })
 #define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
+#define __pmd_free_tlb(tlb,x,a)		do { } while (0)
 
 #endif /* CONFIG_MMU */
 
Index: linux-work/include/asm-i386/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-i386/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-i386/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -49,7 +49,7 @@ static inline void pte_free(struct mm_st
 }
 
 
-#define __pte_free_tlb(tlb,pte) 					\
+#define __pte_free_tlb(tlb,pte,address) 					\
 do {									\
 	paravirt_release_pt(page_to_pfn(pte));				\
 	tlb_remove_page((tlb),(pte));					\
@@ -61,7 +61,7 @@ do {									\
  */
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm,x)			do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
+#define __pmd_free_tlb(tlb,x,a)		do { } while (0)
 #define pud_populate(mm, pmd, pte)	BUG()
 #endif
 
Index: linux-work/include/asm-ia64/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-ia64/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-ia64/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -48,7 +48,7 @@ static inline void pud_free(struct mm_st
 {
 	quicklist_free(0, NULL, pud);
 }
-#define __pud_free_tlb(tlb, pud)	pud_free((tlb)->mm, pud)
+#define __pud_free_tlb(tlb, pud, address)	pud_free((tlb)->mm, pud)
 #endif /* CONFIG_PGTABLE_4 */
 
 static inline void
@@ -67,7 +67,7 @@ static inline void pmd_free(struct mm_st
 	quicklist_free(0, NULL, pmd);
 }
 
-#define __pmd_free_tlb(tlb, pmd)	pmd_free((tlb)->mm, pmd)
+#define __pmd_free_tlb(tlb, pmd, address)	pmd_free((tlb)->mm, pmd)
 
 static inline void
 pmd_populate(struct mm_struct *mm, pmd_t * pmd_entry, struct page *pte)
@@ -109,6 +109,6 @@ static inline void check_pgt_cache(void)
 	quicklist_trim(0, NULL, 25, 16);
 }
 
-#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, pte)
+#define __pte_free_tlb(tlb, pte, address)	pte_free((tlb)->mm, pte)
 
 #endif				/* _ASM_IA64_PGALLOC_H */
Index: linux-work/include/asm-m32r/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-m32r/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-m32r/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -56,7 +56,7 @@ static __inline__ void pte_free(struct m
 	__free_page(pte);
 }
 
-#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
+#define __pte_free_tlb(tlb, pte, address)	pte_free((tlb)->mm, (pte))
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
@@ -66,7 +66,7 @@ static __inline__ void pte_free(struct m
 
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm,x)			do { } while (0)
-#define __pmd_free_tlb(tlb, x)		do { } while (0)
+#define __pmd_free_tlb(tlb, x, a)	do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 
 #define check_pgt_cache()	do { } while (0)
Index: linux-work/include/asm-m68k/motorola_pgalloc.h
===================================================================
--- linux-work.orig/include/asm-m68k/motorola_pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-m68k/motorola_pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -54,7 +54,8 @@ static inline void pte_free(struct mm_st
 	__free_page(page);
 }
 
-static inline void __pte_free_tlb(struct mmu_gather *tlb, struct page *page)
+static inline void __pte_free_tlb(struct mmu_gather *tlb, struct page *page,
+				  unsigned long address)
 {
 	cache_page(kmap(page));
 	kunmap(page);
@@ -72,7 +73,8 @@ static inline int pmd_free(struct mm_str
 	return free_pointer_table(pmd);
 }
 
-static inline int __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
+static inline int __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
+				 unsigned long address)
 {
 	return free_pointer_table(pmd);
 }
Index: linux-work/include/asm-mips/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-mips/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-mips/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -95,7 +95,7 @@ static inline void pte_free(struct mm_st
 	__free_pages(pte, PTE_ORDER);
 }
 
-#define __pte_free_tlb(tlb,pte)		tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte,address)	tlb_remove_page((tlb),(pte))
 
 #ifdef CONFIG_32BIT
 
@@ -104,7 +104,7 @@ static inline void pte_free(struct mm_st
  * inside the pgd, so has no extra memory associated with it.
  */
 #define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
+#define __pmd_free_tlb(tlb,x,a)		do { } while (0)
 
 #endif
 
@@ -125,7 +125,7 @@ static inline void pmd_free(struct mm_st
 	free_pages((unsigned long)pmd, PMD_ORDER);
 }
 
-#define __pmd_free_tlb(tlb,x)	pmd_free((tlb)->mm, x)
+#define __pmd_free_tlb(tlb,x,a)	pmd_free((tlb)->mm, x)
 
 #endif
 
Index: linux-work/include/asm-parisc/tlb.h
===================================================================
--- linux-work.orig/include/asm-parisc/tlb.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-parisc/tlb.h	2007-08-06 16:15:18.000000000 +1000
@@ -21,7 +21,7 @@ do {	if (!(tlb)->fullmm)	\
 
 #include <asm-generic/tlb.h>
 
-#define __pmd_free_tlb(tlb, pmd)	pmd_free((tlb)->mm, pmd)
-#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, pte)
+#define __pmd_free_tlb(tlb, pmd, address)	pmd_free((tlb)->mm, pmd)
+#define __pte_free_tlb(tlb, pte, address)	pte_free((tlb)->mm, pte)
 
 #endif
Index: linux-work/include/asm-powerpc/pgalloc-32.h
===================================================================
--- linux-work.orig/include/asm-powerpc/pgalloc-32.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-powerpc/pgalloc-32.h	2007-08-06 16:15:18.000000000 +1000
@@ -14,7 +14,7 @@ extern void pgd_free(struct mm_struct *m
  */
 /* #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); }) */
 #define pmd_free(mm, x)                 do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
+#define __pmd_free_tlb(tlb,x,a)		do { } while (0)
 /* #define pgd_populate(mm, pmd, pte)      BUG() */
 
 #ifndef CONFIG_BOOKE
@@ -34,7 +34,7 @@ extern struct page *pte_alloc_one(struct
 extern void pte_free_kernel(pte_t *pte);
 extern void pte_free(struct mm_struct *mm, struct page *pte);
 
-#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
+#define __pte_free_tlb(tlb, pte, address)	pte_free((tlb)->mm, (pte))
 
 #define check_pgt_cache()	do { } while (0)
 
Index: linux-work/include/asm-powerpc/pgalloc-64.h
===================================================================
--- linux-work.orig/include/asm-powerpc/pgalloc-64.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-powerpc/pgalloc-64.h	2007-08-06 16:15:18.000000000 +1000
@@ -131,14 +131,14 @@ static inline void pgtable_free(pgtable_
 
 extern void pgtable_free_tlb(struct mmu_gather *tlb, pgtable_free_t pgf);
 
-#define __pte_free_tlb(tlb, ptepage)	\
+#define __pte_free_tlb(tlb, ptepage, address)	\
 	pgtable_free_tlb(tlb, pgtable_free_cache(page_address(ptepage), \
 		PTE_NONCACHE_NUM, PTE_TABLE_SIZE-1))
-#define __pmd_free_tlb(tlb, pmd) 	\
+#define __pmd_free_tlb(tlb, pmd, address) 	\
 	pgtable_free_tlb(tlb, pgtable_free_cache(pmd, \
 		PMD_CACHE_NUM, PMD_TABLE_SIZE-1))
 #ifndef CONFIG_PPC_64K_PAGES
-#define __pud_free_tlb(tlb, pud)	\
+#define __pud_free_tlb(tlb, pud, address)	\
 	pgtable_free_tlb(tlb, pgtable_free_cache(pud, \
 		PUD_CACHE_NUM, PUD_TABLE_SIZE-1))
 #endif /* CONFIG_PPC_64K_PAGES */
Index: linux-work/include/asm-ppc/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-ppc/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-ppc/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -15,7 +15,7 @@ extern void pgd_free(struct mm_struct *m
  */
 #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm,x)                  do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
+#define __pmd_free_tlb(tlb,x,a)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)      BUG()
 
 #ifndef CONFIG_BOOKE
@@ -35,7 +35,7 @@ extern struct page *pte_alloc_one(struct
 extern void pte_free_kernel(pte_t *pte);
 extern void pte_free(struct mm_struct *mm, struct page *pte);
 
-#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
+#define __pte_free_tlb(tlb, pte, addr)	pte_free((tlb)->mm, (pte))
 
 #define check_pgt_cache()	do { } while (0)
 
Index: linux-work/include/asm-s390/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-s390/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-s390/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -84,7 +84,7 @@ static inline void pgd_free(struct mm_st
  */
 #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, x)                 do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
+#define __pmd_free_tlb(tlb,x,a)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)      BUG()
 #define pgd_populate_kernel(mm, pmd, pte)	BUG()
 #else /* __s390x__ */
@@ -120,7 +120,7 @@ static inline void pmd_free (struct mm_s
 	free_pages((unsigned long) pmd, PMD_ALLOC_ORDER);
 }
 
-#define __pmd_free_tlb(tlb,pmd)			\
+#define __pmd_free_tlb(tlb,pmd,address)		\
 	do {					\
 		tlb_flush_mmu(tlb, 0, 0);	\
 		pmd_free((tlb)->mm, pmd);	\
@@ -226,7 +226,7 @@ static inline void pte_free(struct mm_st
 	__free_page(pte);
 }
 
-#define __pte_free_tlb(tlb, pte)					\
+#define __pte_free_tlb(tlb, pte, address)				\
 ({									\
 	struct mmu_gather *__tlb = (tlb);				\
 	struct page *__pte = (pte);					\
Index: linux-work/include/asm-sh/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-sh/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-sh/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -64,7 +64,7 @@ static inline void pte_free(struct mm_st
 	quicklist_free_page(QUICK_PT, NULL, pte);
 }
 
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte,address) tlb_remove_page((tlb),(pte))
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
@@ -72,7 +72,7 @@ static inline void pte_free(struct mm_st
  */
 
 #define pmd_free(mm,x)			do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
+#define __pmd_free_tlb(tlb,x,a)		do { } while (0)
 
 static inline void check_pgt_cache(void)
 {
Index: linux-work/include/asm-sh64/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-sh64/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-sh64/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -74,7 +74,7 @@ static inline pte_t *pte_alloc_one_kerne
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte,address) tlb_remove_page((tlb),(pte))
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
@@ -86,8 +86,7 @@ static inline pte_t *pte_alloc_one_kerne
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, x)			do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
-#define __pte_free_tlb(tlb,pte)		tlb_remove_page((tlb),(pte))
-#define __pmd_free_tlb(tlb,pmd)		do { } while (0)
+#define __pmd_free_tlb(tlb,pmd,addr)	do { } while (0)
 
 #elif defined(CONFIG_SH64_PGTABLE_3_LEVEL)
 
@@ -102,7 +101,7 @@ static inline void pmd_free(struct mm_st
 }
 
 #define pgd_populate(mm, pgd, pmd)	pgd_set(pgd, pmd)
-#define __pmd_free_tlb(tlb,pmd)		pmd_free((tlb)->mm, pmd)
+#define __pmd_free_tlb(tlb,pmd,addr)	pmd_free((tlb)->mm, pmd)
 
 #else
 #error "No defined page table size"
Index: linux-work/include/asm-sparc/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-sparc/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-sparc/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -46,7 +46,7 @@ BTFIXUPDEF_CALL(void, free_pmd_fast, pmd
 #define free_pmd_fast(pmd)	BTFIXUP_CALL(free_pmd_fast)(pmd)
 
 #define pmd_free(mm,pmd)	free_pmd_fast(pmd)
-#define __pmd_free_tlb(tlb, pmd) pmd_free((tlb)->mm, pmd)
+#define __pmd_free_tlb(tlb, pmd, address) pmd_free((tlb)->mm, pmd)
 
 BTFIXUPDEF_CALL(void, pmd_populate, pmd_t *, struct page *)
 #define pmd_populate(MM, PMD, PTE)        BTFIXUP_CALL(pmd_populate)(PMD, PTE)
@@ -63,6 +63,6 @@ BTFIXUPDEF_CALL(void, free_pte_fast, pte
 
 BTFIXUPDEF_CALL(void, pte_free, struct page *)
 #define pte_free(mm,pte)	BTFIXUP_CALL(pte_free)(pte)
-#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, pte)
+#define __pte_free_tlb(tlb, pte, address)	pte_free((tlb)->mm, pte)
 
 #endif /* _SPARC_PGALLOC_H */
Index: linux-work/include/asm-sparc64/tlb.h
===================================================================
--- linux-work.orig/include/asm-sparc64/tlb.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-sparc64/tlb.h	2007-08-06 16:15:18.000000000 +1000
@@ -48,9 +48,9 @@ extern void smp_flush_tlb_mm(struct mm_s
 #define do_flush_tlb_mm(mm) __flush_tlb_mm(CTX_HWBITS(mm->context), SECONDARY_CONTEXT)
 #endif
 
-#define __tlb_remove_tlb_entry(mp,ptep,addr) do { } while (0)
-#define __pte_free_tlb(mp,ptepage) pte_free((mp)->mm,ptepage)
-#define __pmd_free_tlb(mp,pmdp) pmd_free((mp)->mm,pmdp)
+#define __tlb_remove_tlb_entry(mp,ptep,addr)	do { } while (0)
+#define __pte_free_tlb(mp,ptepage,address)	pte_free((mp)->mm,ptepage)
+#define __pmd_free_tlb(mp,pmdp,address)		pmd_free((mp)->mm,pmdp)
 
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
Index: linux-work/include/asm-x86_64/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-x86_64/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-x86_64/pgalloc.h	2007-08-06 16:15:18.000000000 +1000
@@ -131,10 +131,10 @@ static inline void pte_free(struct mm_st
 	quicklist_free_page(QUICK_PT, NULL, pte);
 }
 
-#define __pte_free_tlb(tlb,pte) quicklist_free_page(QUICK_PT, NULL,(pte))
+#define __pte_free_tlb(tlb,pte,addr)  quicklist_free_page(QUICK_PT, NULL,(pte))
 
-#define __pmd_free_tlb(tlb,x)   quicklist_free(QUICK_PT, NULL, (x))
-#define __pud_free_tlb(tlb,x)   quicklist_free(QUICK_PT, NULL, (x))
+#define __pmd_free_tlb(tlb,x,addr)    quicklist_free(QUICK_PT, NULL, (x))
+#define __pud_free_tlb(tlb,x,addr)    quicklist_free(QUICK_PT, NULL, (x))
 
 static inline void check_pgt_cache(void)
 {
Index: linux-work/include/asm-xtensa/tlb.h
===================================================================
--- linux-work.orig/include/asm-xtensa/tlb.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-xtensa/tlb.h	2007-08-06 16:15:18.000000000 +1000
@@ -20,6 +20,6 @@
 #include <asm-generic/tlb.h>
 #include <asm/page.h>
 
-#define __pte_free_tlb(tlb,pte)			pte_free((tlb)->mm, pte)
+#define __pte_free_tlb(tlb,pte,address)		pte_free((tlb)->mm, pte)
 
 #endif	/* _XTENSA_TLB_H */
Index: linux-work/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-work.orig/arch/powerpc/mm/hugetlbpage.c	2007-08-06 13:48:27.000000000 +1000
+++ linux-work/arch/powerpc/mm/hugetlbpage.c	2007-08-06 16:15:18.000000000 +1000
@@ -192,7 +192,7 @@ static void hugetlb_free_pmd_range(struc
 
 	pmd = pmd_offset(pud, start);
 	pud_clear(pud);
-	pmd_free_tlb(tlb, pmd);
+	pmd_free_tlb(tlb, pmd, addr);
 }
 #endif
 
@@ -232,7 +232,7 @@ static void hugetlb_free_pud_range(struc
 
 	pud = pud_offset(pgd, start);
 	pgd_clear(pgd);
-	pud_free_tlb(tlb, pud);
+	pud_free_tlb(tlb, pud, addr);
 }
 
 /*
Index: linux-work/mm/memory.c
===================================================================
--- linux-work.orig/mm/memory.c	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/mm/memory.c	2007-08-06 16:15:18.000000000 +1000
@@ -120,12 +120,13 @@ void pmd_clear_bad(pmd_t *pmd)
  * Note: this doesn't free the actual pages themselves. That
  * has been handled earlier when unmapping all the memory regions.
  */
-static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd)
+static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
+			   unsigned long addr)
 {
 	struct page *page = pmd_page(*pmd);
 	pmd_clear(pmd);
 	pte_lock_deinit(page);
-	pte_free_tlb(tlb, page);
+	pte_free_tlb(tlb, page, addr);
 	dec_zone_page_state(page, NR_PAGETABLE);
 	tlb->mm->nr_ptes--;
 }
@@ -144,7 +145,7 @@ static inline void free_pmd_range(struct
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		free_pte_range(tlb, pmd);
+		free_pte_range(tlb, pmd, addr);
 	} while (pmd++, addr = next, addr != end);
 
 	start &= PUD_MASK;
@@ -160,7 +161,7 @@ static inline void free_pmd_range(struct
 
 	pmd = pmd_offset(pud, start);
 	pud_clear(pud);
-	pmd_free_tlb(tlb, pmd);
+	pmd_free_tlb(tlb, pmd, addr);
 }
 
 static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
@@ -193,7 +194,7 @@ static inline void free_pud_range(struct
 
 	pud = pud_offset(pgd, start);
 	pgd_clear(pgd);
-	pud_free_tlb(tlb, pud);
+	pud_free_tlb(tlb, pud, addr);
 }
 
 /*
Index: linux-work/include/asm-ia64/tlb.h
===================================================================
--- linux-work.orig/include/asm-ia64/tlb.h	2007-07-27 13:44:45.000000000 +1000
+++ linux-work/include/asm-ia64/tlb.h	2007-08-06 16:24:42.000000000 +1000
@@ -210,22 +210,22 @@ do {							\
 	__tlb_remove_tlb_entry(tlb, ptep, addr);	\
 } while (0)
 
-#define pte_free_tlb(tlb, ptep)				\
+#define pte_free_tlb(tlb, ptep, addr)			\
 do {							\
 	tlb->need_flush = 1;				\
-	__pte_free_tlb(tlb, ptep);			\
+	__pte_free_tlb(tlb, ptep, addr);		\
 } while (0)
 
-#define pmd_free_tlb(tlb, ptep)				\
+#define pmd_free_tlb(tlb, ptep, addr)			\
 do {							\
 	tlb->need_flush = 1;				\
-	__pmd_free_tlb(tlb, ptep);			\
+	__pmd_free_tlb(tlb, ptep, addr);		\
 } while (0)
 
-#define pud_free_tlb(tlb, pudp)				\
+#define pud_free_tlb(tlb, pudp, addr)			\
 do {							\
 	tlb->need_flush = 1;				\
-	__pud_free_tlb(tlb, pudp);			\
+	__pud_free_tlb(tlb, pudp, addr);		\
 } while (0)
 
 #endif /* _ASM_IA64_TLB_H */
Index: linux-work/include/asm-generic/4level-fixup.h
===================================================================
--- linux-work.orig/include/asm-generic/4level-fixup.h	2007-08-06 16:25:33.000000000 +1000
+++ linux-work/include/asm-generic/4level-fixup.h	2007-08-06 16:25:49.000000000 +1000
@@ -27,9 +27,9 @@
 #define pud_page_vaddr(pud)		pgd_page_vaddr(pud)
 
 #undef pud_free_tlb
-#define pud_free_tlb(tlb, x)            do { } while (0)
+#define pud_free_tlb(tlb, x, a)         do { } while (0)
 #define pud_free(mm,x)			do { } while (0)
-#define __pud_free_tlb(tlb, x)		do { } while (0)
+#define __pud_free_tlb(tlb, x, a)	do { } while (0)
 
 #undef  pud_addr_end
 #define pud_addr_end(addr, end)		(end)
Index: linux-work/include/asm-generic/pgtable-nopmd.h
===================================================================
--- linux-work.orig/include/asm-generic/pgtable-nopmd.h	2007-08-06 16:24:54.000000000 +1000
+++ linux-work/include/asm-generic/pgtable-nopmd.h	2007-08-06 16:25:06.000000000 +1000
@@ -55,7 +55,7 @@ static inline pmd_t * pmd_offset(pud_t *
  */
 #define pmd_alloc_one(mm, address)		NULL
 #define pmd_free(mm,x)				do { } while (0)
-#define __pmd_free_tlb(tlb, x)			do { } while (0)
+#define __pmd_free_tlb(tlb, x, a)		do { } while (0)
 
 #undef  pmd_addr_end
 #define pmd_addr_end(addr, end)			(end)
Index: linux-work/include/asm-generic/pgtable-nopud.h
===================================================================
--- linux-work.orig/include/asm-generic/pgtable-nopud.h	2007-08-06 16:25:21.000000000 +1000
+++ linux-work/include/asm-generic/pgtable-nopud.h	2007-08-06 16:25:25.000000000 +1000
@@ -52,7 +52,7 @@ static inline pud_t * pud_offset(pgd_t *
  */
 #define pud_alloc_one(mm, address)		NULL
 #define pud_free(mm,x)				do { } while (0)
-#define __pud_free_tlb(tlb, x)			do { } while (0)
+#define __pud_free_tlb(tlb, x, a)		do { } while (0)
 
 #undef  pud_addr_end
 #define pud_addr_end(addr, end)			(end)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
