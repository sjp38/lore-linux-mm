Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6276B6B005A
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 03:12:36 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 15 Jul 2009 17:49:47 +1000
Subject: [RFC/PATCH] mm: Pass virtual address to [__]p{te,ud,md}_free_tlb()
Message-Id: <20090715074952.A36C7DDDB2@ozlabs.org>
Sender: owner-linux-mm@kvack.org
To: Linux Memory Management <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Cc: Hugh Dickins <hugh@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Upcoming paches to support the new 64-bit "BookE" powerpc architecture
will need to have the virtual address corresponding to PTE page when
freeing it, due to the way the HW table walker works.

Basically, the TLB can be loaded with "large" pages that cover the whole
virtual space (well, sort-of, half of it actually) represented by a PTE
page, and which contain an "indirect" bit indicating that this TLB entry
RPN points to an array of PTEs from which the TLB can then create direct
entries. Thus, in order to invalidate those when PTE pages are deleted,
we need the virtual address to pass to tlbilx or tlbivax instructions.

The old trick of sticking it somewhere in the PTE page struct page sucks
too much, the address is almost readily available in all call sites and
almost everybody implemets these as macros, so we may as well add the
argument everywhere. I added it to the pmd and pud variants for consistency.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

I would like to merge the new support that depends on this in 2.6.32,
so unless there's major objections, I'd like this to go in early during
the merge window. We can sort out separately how to carry the patch
around in -next until then since the powerpc tree will have a dependency
on it.

I haven't had a chance to test or even build on most architectures, the
patch is reasonably trivial but I may have screwed up regardless, I
appologize in advance, let me know if something is wrong.

 arch/alpha/include/asm/tlb.h             |    4 ++--
 arch/arm/include/asm/tlb.h               |    4 ++--
 arch/avr32/include/asm/pgalloc.h         |    2 +-
 arch/cris/include/asm/pgalloc.h          |    2 +-
 arch/frv/include/asm/pgalloc.h           |    4 ++--
 arch/frv/include/asm/pgtable.h           |    2 +-
 arch/ia64/include/asm/pgalloc.h          |    6 +++---
 arch/ia64/include/asm/tlb.h              |   12 ++++++------
 arch/m32r/include/asm/pgalloc.h          |    4 ++--
 arch/m68k/include/asm/motorola_pgalloc.h |    6 ++++--
 arch/m68k/include/asm/sun3_pgalloc.h     |    4 ++--
 arch/microblaze/include/asm/pgalloc.h    |    4 ++--
 arch/mips/include/asm/pgalloc.h          |    6 +++---
 arch/mn10300/include/asm/pgalloc.h       |    2 +-
 arch/parisc/include/asm/tlb.h            |    4 ++--
 arch/powerpc/include/asm/pgalloc-32.h    |    2 +-
 arch/powerpc/include/asm/pgalloc-64.h    |    4 ++--
 arch/powerpc/include/asm/pgalloc.h       |    6 +++---
 arch/powerpc/mm/hugetlbpage.c            |    4 ++--
 arch/s390/include/asm/tlb.h              |    9 ++++++---
 arch/sh/include/asm/pgalloc.h            |    4 ++--
 arch/sh/include/asm/tlb.h                |    6 +++---
 arch/sparc/include/asm/pgalloc_32.h      |    8 ++++----
 arch/sparc/include/asm/tlb_64.h          |    6 +++---
 arch/um/include/asm/pgalloc.h            |    4 ++--
 arch/um/include/asm/tlb.h                |    6 +++---
 arch/x86/include/asm/pgalloc.h           |   25 ++++++++++++++++++++++---
 arch/x86/mm/pgtable.c                    |    6 +++---
 arch/xtensa/include/asm/tlb.h            |    2 +-
 include/asm-generic/4level-fixup.h       |    4 ++--
 include/asm-generic/pgtable-nopmd.h      |    2 +-
 include/asm-generic/pgtable-nopud.h      |    2 +-
 include/asm-generic/tlb.h                |   12 ++++++------
 mm/memory.c                              |   11 ++++++-----
 34 files changed, 107 insertions(+), 82 deletions(-)

--- linux-work.orig/arch/powerpc/include/asm/pgalloc-32.h	2009-02-05 16:22:24.000000000 +1100
+++ linux-work/arch/powerpc/include/asm/pgalloc-32.h	2009-07-15 17:42:43.000000000 +1000
@@ -16,7 +16,7 @@ extern void pgd_free(struct mm_struct *m
  */
 /* #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); }) */
 #define pmd_free(mm, x) 		do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
+#define __pmd_free_tlb(tlb,x,a)		do { } while (0)
 /* #define pgd_populate(mm, pmd, pte)      BUG() */
 
 #ifndef CONFIG_BOOKE
Index: linux-work/arch/powerpc/include/asm/pgalloc-64.h
===================================================================
--- linux-work.orig/arch/powerpc/include/asm/pgalloc-64.h	2009-02-05 16:22:24.000000000 +1100
+++ linux-work/arch/powerpc/include/asm/pgalloc-64.h	2009-07-15 17:42:43.000000000 +1000
@@ -118,11 +118,11 @@ static inline void pgtable_free(pgtable_
 		kmem_cache_free(pgtable_cache[cachenum], p);
 }
 
-#define __pmd_free_tlb(tlb, pmd) 	\
+#define __pmd_free_tlb(tlb, pmd,addr)		      \
 	pgtable_free_tlb(tlb, pgtable_free_cache(pmd, \
 		PMD_CACHE_NUM, PMD_TABLE_SIZE-1))
 #ifndef CONFIG_PPC_64K_PAGES
-#define __pud_free_tlb(tlb, pud)	\
+#define __pud_free_tlb(tlb, pud, addr)		      \
 	pgtable_free_tlb(tlb, pgtable_free_cache(pud, \
 		PUD_CACHE_NUM, PUD_TABLE_SIZE-1))
 #endif /* CONFIG_PPC_64K_PAGES */
Index: linux-work/arch/powerpc/include/asm/pgalloc.h
===================================================================
--- linux-work.orig/arch/powerpc/include/asm/pgalloc.h	2009-02-05 16:22:24.000000000 +1100
+++ linux-work/arch/powerpc/include/asm/pgalloc.h	2009-07-15 17:42:43.000000000 +1000
@@ -38,14 +38,14 @@ static inline pgtable_free_t pgtable_fre
 extern void pgtable_free_tlb(struct mmu_gather *tlb, pgtable_free_t pgf);
 
 #ifdef CONFIG_SMP
-#define __pte_free_tlb(tlb,ptepage)	\
+#define __pte_free_tlb(tlb,ptepage,address)		\
 do { \
 	pgtable_page_dtor(ptepage); \
 	pgtable_free_tlb(tlb, pgtable_free_cache(page_address(ptepage), \
-		PTE_NONCACHE_NUM, PTE_TABLE_SIZE-1)); \
+					PTE_NONCACHE_NUM, PTE_TABLE_SIZE-1)); \
 } while (0)
 #else
-#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
+#define __pte_free_tlb(tlb, pte, address)	pte_free((tlb)->mm, (pte))
 #endif
 
 
Index: linux-work/include/asm-generic/pgtable-nopmd.h
===================================================================
--- linux-work.orig/include/asm-generic/pgtable-nopmd.h	2009-02-05 16:23:01.000000000 +1100
+++ linux-work/include/asm-generic/pgtable-nopmd.h	2009-07-15 17:42:43.000000000 +1000
@@ -59,7 +59,7 @@ static inline pmd_t * pmd_offset(pud_t *
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 }
-#define __pmd_free_tlb(tlb, x)			do { } while (0)
+#define __pmd_free_tlb(tlb, x, a)		do { } while (0)
 
 #undef  pmd_addr_end
 #define pmd_addr_end(addr, end)			(end)
Index: linux-work/include/asm-generic/pgtable-nopud.h
===================================================================
--- linux-work.orig/include/asm-generic/pgtable-nopud.h	2009-02-05 16:23:01.000000000 +1100
+++ linux-work/include/asm-generic/pgtable-nopud.h	2009-07-15 17:42:43.000000000 +1000
@@ -52,7 +52,7 @@ static inline pud_t * pud_offset(pgd_t *
  */
 #define pud_alloc_one(mm, address)		NULL
 #define pud_free(mm, x)				do { } while (0)
-#define __pud_free_tlb(tlb, x)			do { } while (0)
+#define __pud_free_tlb(tlb, x, a)		do { } while (0)
 
 #undef  pud_addr_end
 #define pud_addr_end(addr, end)			(end)
Index: linux-work/include/asm-generic/tlb.h
===================================================================
--- linux-work.orig/include/asm-generic/tlb.h	2009-02-05 16:23:01.000000000 +1100
+++ linux-work/include/asm-generic/tlb.h	2009-07-15 17:42:43.000000000 +1000
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
Index: linux-work/mm/memory.c
===================================================================
--- linux-work.orig/mm/memory.c	2009-07-08 15:53:55.000000000 +1000
+++ linux-work/mm/memory.c	2009-07-15 17:42:43.000000000 +1000
@@ -135,11 +135,12 @@ void pmd_clear_bad(pmd_t *pmd)
  * Note: this doesn't free the actual pages themselves. That
  * has been handled earlier when unmapping all the memory regions.
  */
-static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd)
+static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
+			   unsigned long addr)
 {
 	pgtable_t token = pmd_pgtable(*pmd);
 	pmd_clear(pmd);
-	pte_free_tlb(tlb, token);
+	pte_free_tlb(tlb, token, addr);
 	tlb->mm->nr_ptes--;
 }
 
@@ -157,7 +158,7 @@ static inline void free_pmd_range(struct
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		free_pte_range(tlb, pmd);
+		free_pte_range(tlb, pmd, addr);
 	} while (pmd++, addr = next, addr != end);
 
 	start &= PUD_MASK;
@@ -173,7 +174,7 @@ static inline void free_pmd_range(struct
 
 	pmd = pmd_offset(pud, start);
 	pud_clear(pud);
-	pmd_free_tlb(tlb, pmd);
+	pmd_free_tlb(tlb, pmd, start);
 }
 
 static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
@@ -206,7 +207,7 @@ static inline void free_pud_range(struct
 
 	pud = pud_offset(pgd, start);
 	pgd_clear(pgd);
-	pud_free_tlb(tlb, pud);
+	pud_free_tlb(tlb, pud, start);
 }
 
 /*
Index: linux-work/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-work.orig/arch/powerpc/mm/hugetlbpage.c	2009-02-05 16:22:25.000000000 +1100
+++ linux-work/arch/powerpc/mm/hugetlbpage.c	2009-07-15 17:42:43.000000000 +1000
@@ -305,7 +305,7 @@ static void hugetlb_free_pmd_range(struc
 
 	pmd = pmd_offset(pud, start);
 	pud_clear(pud);
-	pmd_free_tlb(tlb, pmd);
+	pmd_free_tlb(tlb, pmd, start);
 }
 
 static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
@@ -348,7 +348,7 @@ static void hugetlb_free_pud_range(struc
 
 	pud = pud_offset(pgd, start);
 	pgd_clear(pgd);
-	pud_free_tlb(tlb, pud);
+	pud_free_tlb(tlb, pud, start);
 }
 
 /*
Index: linux-work/arch/alpha/include/asm/tlb.h
===================================================================
--- linux-work.orig/arch/alpha/include/asm/tlb.h	2009-02-05 16:22:17.000000000 +1100
+++ linux-work/arch/alpha/include/asm/tlb.h	2009-07-15 17:42:43.000000000 +1000
@@ -9,7 +9,7 @@
 
 #include <asm-generic/tlb.h>
 
-#define __pte_free_tlb(tlb, pte)			pte_free((tlb)->mm, pte)
-#define __pmd_free_tlb(tlb, pmd)			pmd_free((tlb)->mm, pmd)
+#define __pte_free_tlb(tlb, pte, address)		pte_free((tlb)->mm, pte)
+#define __pmd_free_tlb(tlb, pmd, address)		pmd_free((tlb)->mm, pmd)
  
 #endif
Index: linux-work/arch/avr32/include/asm/pgalloc.h
===================================================================
--- linux-work.orig/arch/avr32/include/asm/pgalloc.h	2009-02-05 16:22:19.000000000 +1100
+++ linux-work/arch/avr32/include/asm/pgalloc.h	2009-07-15 17:42:43.000000000 +1000
@@ -83,7 +83,7 @@ static inline void pte_free(struct mm_st
 	quicklist_free_page(QUICK_PT, NULL, pte);
 }
 
-#define __pte_free_tlb(tlb,pte)				\
+#define __pte_free_tlb(tlb,pte,addr)			\
 do {							\
 	pgtable_page_dtor(pte);				\
 	tlb_remove_page((tlb), pte);			\
Index: linux-work/arch/cris/include/asm/pgalloc.h
===================================================================
--- linux-work.orig/arch/cris/include/asm/pgalloc.h	2009-02-05 16:22:19.000000000 +1100
+++ linux-work/arch/cris/include/asm/pgalloc.h	2009-07-15 17:42:43.000000000 +1000
@@ -47,7 +47,7 @@ static inline void pte_free(struct mm_st
 	__free_page(pte);
 }
 
-#define __pte_free_tlb(tlb,pte)				\
+#define __pte_free_tlb(tlb,pte,address)			\
 do {							\
 	pgtable_page_dtor(pte);				\
 	tlb_remove_page((tlb), pte);			\
Index: linux-work/arch/frv/include/asm/pgalloc.h
===================================================================
--- linux-work.orig/arch/frv/include/asm/pgalloc.h	2009-04-30 14:19:03.000000000 +1000
+++ linux-work/arch/frv/include/asm/pgalloc.h	2009-07-15 17:42:43.000000000 +1000
@@ -49,7 +49,7 @@ static inline void pte_free(struct mm_st
 	__free_page(pte);
 }
 
-#define __pte_free_tlb(tlb,pte)				\
+#define __pte_free_tlb(tlb,pte,address)			\
 do {							\
 	pgtable_page_dtor(pte);				\
 	tlb_remove_page((tlb),(pte));			\
@@ -62,7 +62,7 @@ do {							\
  */
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *) 2); })
 #define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
+#define __pmd_free_tlb(tlb,x,a)		do { } while (0)
 
 #endif /* CONFIG_MMU */
 
Index: linux-work/arch/ia64/include/asm/pgalloc.h
===================================================================
--- linux-work.orig/arch/ia64/include/asm/pgalloc.h	2009-02-05 16:22:19.000000000 +1100
+++ linux-work/arch/ia64/include/asm/pgalloc.h	2009-07-15 17:42:43.000000000 +1000
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
 pmd_populate(struct mm_struct *mm, pmd_t * pmd_entry, pgtable_t pte)
@@ -117,6 +117,6 @@ static inline void check_pgt_cache(void)
 	quicklist_trim(0, NULL, 25, 16);
 }
 
-#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, pte)
+#define __pte_free_tlb(tlb, pte, address)	pte_free((tlb)->mm, pte)
 
 #endif				/* _ASM_IA64_PGALLOC_H */
Index: linux-work/arch/ia64/include/asm/tlb.h
===================================================================
--- linux-work.orig/arch/ia64/include/asm/tlb.h	2009-02-05 16:22:19.000000000 +1100
+++ linux-work/arch/ia64/include/asm/tlb.h	2009-07-15 17:42:43.000000000 +1000
@@ -236,22 +236,22 @@ do {							\
 	__tlb_remove_tlb_entry(tlb, ptep, addr);	\
 } while (0)
 
-#define pte_free_tlb(tlb, ptep)				\
+#define pte_free_tlb(tlb, ptep, address)		\
 do {							\
 	tlb->need_flush = 1;				\
-	__pte_free_tlb(tlb, ptep);			\
+	__pte_free_tlb(tlb, ptep, address);		\
 } while (0)
 
-#define pmd_free_tlb(tlb, ptep)				\
+#define pmd_free_tlb(tlb, ptep, address)		\
 do {							\
 	tlb->need_flush = 1;				\
-	__pmd_free_tlb(tlb, ptep);			\
+	__pmd_free_tlb(tlb, ptep, address);		\
 } while (0)
 
-#define pud_free_tlb(tlb, pudp)				\
+#define pud_free_tlb(tlb, pudp, address)		\
 do {							\
 	tlb->need_flush = 1;				\
-	__pud_free_tlb(tlb, pudp);			\
+	__pud_free_tlb(tlb, pudp, address);		\
 } while (0)
 
 #endif /* _ASM_IA64_TLB_H */
Index: linux-work/arch/m32r/include/asm/pgalloc.h
===================================================================
--- linux-work.orig/arch/m32r/include/asm/pgalloc.h	2009-04-30 14:19:03.000000000 +1000
+++ linux-work/arch/m32r/include/asm/pgalloc.h	2009-07-15 17:42:43.000000000 +1000
@@ -58,7 +58,7 @@ static inline void pte_free(struct mm_st
 	__free_page(pte);
 }
 
-#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
+#define __pte_free_tlb(tlb, pte, addr)	pte_free((tlb)->mm, (pte))
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
@@ -68,7 +68,7 @@ static inline void pte_free(struct mm_st
 
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb, x)		do { } while (0)
+#define __pmd_free_tlb(tlb, x, addr)	do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 
 #define check_pgt_cache()	do { } while (0)
Index: linux-work/arch/m68k/include/asm/motorola_pgalloc.h
===================================================================
--- linux-work.orig/arch/m68k/include/asm/motorola_pgalloc.h	2009-02-05 16:22:20.000000000 +1100
+++ linux-work/arch/m68k/include/asm/motorola_pgalloc.h	2009-07-15 17:42:43.000000000 +1000
@@ -54,7 +54,8 @@ static inline void pte_free(struct mm_st
 	__free_page(page);
 }
 
-static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t page)
+static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t page,
+				  unsigned long address)
 {
 	pgtable_page_dtor(page);
 	cache_page(kmap(page));
@@ -73,7 +74,8 @@ static inline int pmd_free(struct mm_str
 	return free_pointer_table(pmd);
 }
 
-static inline int __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
+static inline int __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
+				 unsigned long address)
 {
 	return free_pointer_table(pmd);
 }
Index: linux-work/arch/m68k/include/asm/sun3_pgalloc.h
===================================================================
--- linux-work.orig/arch/m68k/include/asm/sun3_pgalloc.h	2009-02-05 16:22:20.000000000 +1100
+++ linux-work/arch/m68k/include/asm/sun3_pgalloc.h	2009-07-15 17:42:43.000000000 +1000
@@ -32,7 +32,7 @@ static inline void pte_free(struct mm_st
         __free_page(page);
 }
 
-#define __pte_free_tlb(tlb,pte)				\
+#define __pte_free_tlb(tlb,pte,addr)			\
 do {							\
 	pgtable_page_dtor(pte);				\
 	tlb_remove_page((tlb), pte);			\
@@ -80,7 +80,7 @@ static inline void pmd_populate(struct m
  * inside the pgd, so has no extra memory associated with it.
  */
 #define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb, x)		do { } while (0)
+#define __pmd_free_tlb(tlb, x, addr)	do { } while (0)
 
 static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
Index: linux-work/arch/microblaze/include/asm/pgalloc.h
===================================================================
--- linux-work.orig/arch/microblaze/include/asm/pgalloc.h	2009-07-08 15:53:49.000000000 +1000
+++ linux-work/arch/microblaze/include/asm/pgalloc.h	2009-07-15 17:42:43.000000000 +1000
@@ -180,7 +180,7 @@ extern inline void pte_free(struct mm_st
 	__free_page(ptepage);
 }
 
-#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
+#define __pte_free_tlb(tlb, pte, addr)	pte_free((tlb)->mm, (pte))
 
 #define pmd_populate(mm, pmd, pte)	(pmd_val(*(pmd)) = page_address(pte))
 
@@ -193,7 +193,7 @@ extern inline void pte_free(struct mm_st
  */
 #define pmd_alloc_one(mm, address)	({ BUG(); ((pmd_t *)2); })
 /*#define pmd_free(mm, x)			do { } while (0)*/
-#define __pmd_free_tlb(tlb, x)		do { } while (0)
+#define __pmd_free_tlb(tlb, x, addr)	do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 
 extern int do_check_pgt_cache(int, int);
Index: linux-work/arch/mips/include/asm/pgalloc.h
===================================================================
--- linux-work.orig/arch/mips/include/asm/pgalloc.h	2009-02-05 16:22:21.000000000 +1100
+++ linux-work/arch/mips/include/asm/pgalloc.h	2009-07-15 17:42:43.000000000 +1000
@@ -98,7 +98,7 @@ static inline void pte_free(struct mm_st
 	__free_pages(pte, PTE_ORDER);
 }
 
-#define __pte_free_tlb(tlb,pte)				\
+#define __pte_free_tlb(tlb,pte,address)			\
 do {							\
 	pgtable_page_dtor(pte);				\
 	tlb_remove_page((tlb), pte);			\
@@ -111,7 +111,7 @@ do {							\
  * inside the pgd, so has no extra memory associated with it.
  */
 #define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb, x)		do { } while (0)
+#define __pmd_free_tlb(tlb, x, addr)	do { } while (0)
 
 #endif
 
@@ -132,7 +132,7 @@ static inline void pmd_free(struct mm_st
 	free_pages((unsigned long)pmd, PMD_ORDER);
 }
 
-#define __pmd_free_tlb(tlb, x)	pmd_free((tlb)->mm, x)
+#define __pmd_free_tlb(tlb, x, addr)	pmd_free((tlb)->mm, x)
 
 #endif
 
Index: linux-work/arch/mn10300/include/asm/pgalloc.h
===================================================================
--- linux-work.orig/arch/mn10300/include/asm/pgalloc.h	2009-04-30 14:19:03.000000000 +1000
+++ linux-work/arch/mn10300/include/asm/pgalloc.h	2009-07-15 17:42:43.000000000 +1000
@@ -51,6 +51,6 @@ static inline void pte_free(struct mm_st
 }
 
 
-#define __pte_free_tlb(tlb, pte) tlb_remove_page((tlb), (pte))
+#define __pte_free_tlb(tlb, pte, addr) tlb_remove_page((tlb), (pte))
 
 #endif /* _ASM_PGALLOC_H */
Index: linux-work/arch/parisc/include/asm/tlb.h
===================================================================
--- linux-work.orig/arch/parisc/include/asm/tlb.h	2009-02-05 16:22:21.000000000 +1100
+++ linux-work/arch/parisc/include/asm/tlb.h	2009-07-15 17:42:43.000000000 +1000
@@ -21,7 +21,7 @@ do {	if (!(tlb)->fullmm)	\
 
 #include <asm-generic/tlb.h>
 
-#define __pmd_free_tlb(tlb, pmd)	pmd_free((tlb)->mm, pmd)
-#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, pte)
+#define __pmd_free_tlb(tlb, pmd, addr)	pmd_free((tlb)->mm, pmd)
+#define __pte_free_tlb(tlb, pte, addr)	pte_free((tlb)->mm, pte)
 
 #endif
Index: linux-work/arch/s390/include/asm/tlb.h
===================================================================
--- linux-work.orig/arch/s390/include/asm/tlb.h	2009-02-05 16:22:25.000000000 +1100
+++ linux-work/arch/s390/include/asm/tlb.h	2009-07-15 17:42:43.000000000 +1000
@@ -96,7 +96,8 @@ static inline void tlb_remove_page(struc
  * pte_free_tlb frees a pte table and clears the CRSTE for the
  * page table from the tlb.
  */
-static inline void pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte)
+static inline void pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
+				unsigned long address)
 {
 	if (!tlb->fullmm) {
 		tlb->array[tlb->nr_ptes++] = pte;
@@ -113,7 +114,8 @@ static inline void pte_free_tlb(struct m
  * as the pgd. pmd_free_tlb checks the asce_limit against 2GB
  * to avoid the double free of the pmd in this case.
  */
-static inline void pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
+static inline void pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
+				unsigned long address)
 {
 #ifdef __s390x__
 	if (tlb->mm->context.asce_limit <= (1UL << 31))
@@ -134,7 +136,8 @@ static inline void pmd_free_tlb(struct m
  * as the pgd. pud_free_tlb checks the asce_limit against 4TB
  * to avoid the double free of the pud in this case.
  */
-static inline void pud_free_tlb(struct mmu_gather *tlb, pud_t *pud)
+static inline void pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
+				unsigned long address)
 {
 #ifdef __s390x__
 	if (tlb->mm->context.asce_limit <= (1UL << 42))
Index: linux-work/arch/sh/include/asm/pgalloc.h
===================================================================
--- linux-work.orig/arch/sh/include/asm/pgalloc.h	2009-02-05 16:22:26.000000000 +1100
+++ linux-work/arch/sh/include/asm/pgalloc.h	2009-07-15 17:42:43.000000000 +1000
@@ -73,7 +73,7 @@ static inline void pte_free(struct mm_st
 	quicklist_free_page(QUICK_PT, NULL, pte);
 }
 
-#define __pte_free_tlb(tlb,pte)				\
+#define __pte_free_tlb(tlb,pte,addr)			\
 do {							\
 	pgtable_page_dtor(pte);				\
 	tlb_remove_page((tlb), (pte));			\
@@ -85,7 +85,7 @@ do {							\
  */
 
 #define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
+#define __pmd_free_tlb(tlb,x,addr)	do { } while (0)
 
 static inline void check_pgt_cache(void)
 {
Index: linux-work/arch/sh/include/asm/tlb.h
===================================================================
--- linux-work.orig/arch/sh/include/asm/tlb.h	2009-03-31 13:22:05.000000000 +1100
+++ linux-work/arch/sh/include/asm/tlb.h	2009-07-15 17:42:43.000000000 +1000
@@ -91,9 +91,9 @@ tlb_end_vma(struct mmu_gather *tlb, stru
 }
 
 #define tlb_remove_page(tlb,page)	free_page_and_swap_cache(page)
-#define pte_free_tlb(tlb, ptep)		pte_free((tlb)->mm, ptep)
-#define pmd_free_tlb(tlb, pmdp)		pmd_free((tlb)->mm, pmdp)
-#define pud_free_tlb(tlb, pudp)		pud_free((tlb)->mm, pudp)
+#define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
+#define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
+#define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
 
 #define tlb_migrate_finish(mm)		do { } while (0)
 
Index: linux-work/arch/sparc/include/asm/pgalloc_32.h
===================================================================
--- linux-work.orig/arch/sparc/include/asm/pgalloc_32.h	2009-02-05 16:22:26.000000000 +1100
+++ linux-work/arch/sparc/include/asm/pgalloc_32.h	2009-07-15 17:42:43.000000000 +1000
@@ -44,8 +44,8 @@ BTFIXUPDEF_CALL(pmd_t *, pmd_alloc_one, 
 BTFIXUPDEF_CALL(void, free_pmd_fast, pmd_t *)
 #define free_pmd_fast(pmd)	BTFIXUP_CALL(free_pmd_fast)(pmd)
 
-#define pmd_free(mm, pmd)	free_pmd_fast(pmd)
-#define __pmd_free_tlb(tlb, pmd) pmd_free((tlb)->mm, pmd)
+#define pmd_free(mm, pmd)		free_pmd_fast(pmd)
+#define __pmd_free_tlb(tlb, pmd, addr)	pmd_free((tlb)->mm, pmd)
 
 BTFIXUPDEF_CALL(void, pmd_populate, pmd_t *, struct page *)
 #define pmd_populate(MM, PMD, PTE)        BTFIXUP_CALL(pmd_populate)(PMD, PTE)
@@ -62,7 +62,7 @@ BTFIXUPDEF_CALL(void, free_pte_fast, pte
 #define pte_free_kernel(mm, pte)	BTFIXUP_CALL(free_pte_fast)(pte)
 
 BTFIXUPDEF_CALL(void, pte_free, pgtable_t )
-#define pte_free(mm, pte)	BTFIXUP_CALL(pte_free)(pte)
-#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, pte)
+#define pte_free(mm, pte)		BTFIXUP_CALL(pte_free)(pte)
+#define __pte_free_tlb(tlb, pte, addr)	pte_free((tlb)->mm, pte)
 
 #endif /* _SPARC_PGALLOC_H */
Index: linux-work/arch/sparc/include/asm/tlb_64.h
===================================================================
--- linux-work.orig/arch/sparc/include/asm/tlb_64.h	2009-03-31 13:22:05.000000000 +1100
+++ linux-work/arch/sparc/include/asm/tlb_64.h	2009-07-15 17:42:43.000000000 +1000
@@ -100,9 +100,9 @@ static inline void tlb_remove_page(struc
 }
 
 #define tlb_remove_tlb_entry(mp,ptep,addr) do { } while (0)
-#define pte_free_tlb(mp, ptepage) pte_free((mp)->mm, ptepage)
-#define pmd_free_tlb(mp, pmdp) pmd_free((mp)->mm, pmdp)
-#define pud_free_tlb(tlb,pudp) __pud_free_tlb(tlb,pudp)
+#define pte_free_tlb(mp, ptepage, addr) pte_free((mp)->mm, ptepage)
+#define pmd_free_tlb(mp, pmdp, addr) pmd_free((mp)->mm, pmdp)
+#define pud_free_tlb(tlb,pudp, addr) __pud_free_tlb(tlb,pudp,addr)
 
 #define tlb_migrate_finish(mm)	do { } while (0)
 #define tlb_start_vma(tlb, vma) do { } while (0)
Index: linux-work/arch/um/include/asm/pgalloc.h
===================================================================
--- linux-work.orig/arch/um/include/asm/pgalloc.h	2009-04-30 14:19:04.000000000 +1000
+++ linux-work/arch/um/include/asm/pgalloc.h	2009-07-15 17:42:43.000000000 +1000
@@ -40,7 +40,7 @@ static inline void pte_free(struct mm_st
 	__free_page(pte);
 }
 
-#define __pte_free_tlb(tlb,pte)				\
+#define __pte_free_tlb(tlb,pte, address)		\
 do {							\
 	pgtable_page_dtor(pte);				\
 	tlb_remove_page((tlb),(pte));			\
@@ -53,7 +53,7 @@ static inline void pmd_free(struct mm_st
 	free_page((unsigned long)pmd);
 }
 
-#define __pmd_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
+#define __pmd_free_tlb(tlb,x, address)   tlb_remove_page((tlb),virt_to_page(x))
 #endif
 
 #define check_pgt_cache()	do { } while (0)
Index: linux-work/arch/um/include/asm/tlb.h
===================================================================
--- linux-work.orig/arch/um/include/asm/tlb.h	2009-02-05 16:22:28.000000000 +1100
+++ linux-work/arch/um/include/asm/tlb.h	2009-07-15 17:42:43.000000000 +1000
@@ -116,11 +116,11 @@ static inline void tlb_remove_page(struc
 		__tlb_remove_tlb_entry(tlb, ptep, address);	\
 	} while (0)
 
-#define pte_free_tlb(tlb, ptep) __pte_free_tlb(tlb, ptep)
+#define pte_free_tlb(tlb, ptep, addr) __pte_free_tlb(tlb, ptep, addr)
 
-#define pud_free_tlb(tlb, pudp) __pud_free_tlb(tlb, pudp)
+#define pud_free_tlb(tlb, pudp, addr) __pud_free_tlb(tlb, pudp, addr)
 
-#define pmd_free_tlb(tlb, pmdp) __pmd_free_tlb(tlb, pmdp)
+#define pmd_free_tlb(tlb, pmdp, addr) __pmd_free_tlb(tlb, pmdp, addr)
 
 #define tlb_migrate_finish(mm) do {} while (0)
 
Index: linux-work/arch/x86/include/asm/pgalloc.h
===================================================================
--- linux-work.orig/arch/x86/include/asm/pgalloc.h	2009-02-05 16:22:28.000000000 +1100
+++ linux-work/arch/x86/include/asm/pgalloc.h	2009-07-15 17:42:43.000000000 +1000
@@ -46,7 +46,13 @@ static inline void pte_free(struct mm_st
 	__free_page(pte);
 }
 
-extern void __pte_free_tlb(struct mmu_gather *tlb, struct page *pte);
+extern void ___pte_free_tlb(struct mmu_gather *tlb, struct page *pte);
+
+static inline void __pte_free_tlb(struct mmu_gather *tlb, struct page *pte,
+				  unsigned long address)
+{
+	___pte_free_tlb(tlb, pte);
+}
 
 static inline void pmd_populate_kernel(struct mm_struct *mm,
 				       pmd_t *pmd, pte_t *pte)
@@ -78,7 +84,13 @@ static inline void pmd_free(struct mm_st
 	free_page((unsigned long)pmd);
 }
 
-extern void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd);
+extern void ___pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd);
+
+static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
+				  unsigned long adddress)
+{
+	___pmd_free_tlb(tlb, pmd);
+}
 
 #ifdef CONFIG_X86_PAE
 extern void pud_populate(struct mm_struct *mm, pud_t *pudp, pmd_t *pmd);
@@ -108,7 +120,14 @@ static inline void pud_free(struct mm_st
 	free_page((unsigned long)pud);
 }
 
-extern void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud);
+extern void ___pud_free_tlb(struct mmu_gather *tlb, pud_t *pud);
+
+static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
+				  unsigned long address)
+{
+	___pud_free_tlb(tlb, pud);
+}
+
 #endif	/* PAGETABLE_LEVELS > 3 */
 #endif	/* PAGETABLE_LEVELS > 2 */
 
Index: linux-work/arch/x86/mm/pgtable.c
===================================================================
--- linux-work.orig/arch/x86/mm/pgtable.c	2009-07-08 15:53:51.000000000 +1000
+++ linux-work/arch/x86/mm/pgtable.c	2009-07-15 17:42:43.000000000 +1000
@@ -25,7 +25,7 @@ pgtable_t pte_alloc_one(struct mm_struct
 	return pte;
 }
 
-void __pte_free_tlb(struct mmu_gather *tlb, struct page *pte)
+void ___pte_free_tlb(struct mmu_gather *tlb, struct page *pte)
 {
 	pgtable_page_dtor(pte);
 	paravirt_release_pte(page_to_pfn(pte));
@@ -33,14 +33,14 @@ void __pte_free_tlb(struct mmu_gather *t
 }
 
 #if PAGETABLE_LEVELS > 2
-void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
+void ___pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
 {
 	paravirt_release_pmd(__pa(pmd) >> PAGE_SHIFT);
 	tlb_remove_page(tlb, virt_to_page(pmd));
 }
 
 #if PAGETABLE_LEVELS > 3
-void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud)
+void ___pud_free_tlb(struct mmu_gather *tlb, pud_t *pud)
 {
 	paravirt_release_pud(__pa(pud) >> PAGE_SHIFT);
 	tlb_remove_page(tlb, virt_to_page(pud));
Index: linux-work/arch/xtensa/include/asm/tlb.h
===================================================================
--- linux-work.orig/arch/xtensa/include/asm/tlb.h	2009-02-05 16:22:29.000000000 +1100
+++ linux-work/arch/xtensa/include/asm/tlb.h	2009-07-15 17:42:43.000000000 +1000
@@ -42,6 +42,6 @@
 
 #include <asm-generic/tlb.h>
 
-#define __pte_free_tlb(tlb, pte)		pte_free((tlb)->mm, pte)
+#define __pte_free_tlb(tlb, pte, address)	pte_free((tlb)->mm, pte)
 
 #endif	/* _XTENSA_TLB_H */
Index: linux-work/arch/arm/include/asm/tlb.h
===================================================================
--- linux-work.orig/arch/arm/include/asm/tlb.h	2009-07-15 17:45:18.000000000 +1000
+++ linux-work/arch/arm/include/asm/tlb.h	2009-07-15 17:45:28.000000000 +1000
@@ -102,8 +102,8 @@ tlb_end_vma(struct mmu_gather *tlb, stru
 }
 
 #define tlb_remove_page(tlb,page)	free_page_and_swap_cache(page)
-#define pte_free_tlb(tlb, ptep)		pte_free((tlb)->mm, ptep)
-#define pmd_free_tlb(tlb, pmdp)		pmd_free((tlb)->mm, pmdp)
+#define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
+#define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
 
 #define tlb_migrate_finish(mm)		do { } while (0)
 
Index: linux-work/arch/frv/include/asm/pgtable.h
===================================================================
--- linux-work.orig/arch/frv/include/asm/pgtable.h	2009-07-15 17:45:52.000000000 +1000
+++ linux-work/arch/frv/include/asm/pgtable.h	2009-07-15 17:45:59.000000000 +1000
@@ -225,7 +225,7 @@ static inline pud_t *pud_offset(pgd_t *p
  */
 #define pud_alloc_one(mm, address)		NULL
 #define pud_free(mm, x)				do { } while (0)
-#define __pud_free_tlb(tlb, x)			do { } while (0)
+#define __pud_free_tlb(tlb, x, address)		do { } while (0)
 
 /*
  * The "pud_xxx()" functions here are trivial for a folded two-level
Index: linux-work/include/asm-generic/4level-fixup.h
===================================================================
--- linux-work.orig/include/asm-generic/4level-fixup.h	2009-07-15 17:44:05.000000000 +1000
+++ linux-work/include/asm-generic/4level-fixup.h	2009-07-15 17:44:25.000000000 +1000
@@ -27,9 +27,9 @@
 #define pud_page_vaddr(pud)		pgd_page_vaddr(pud)
 
 #undef pud_free_tlb
-#define pud_free_tlb(tlb, x)            do { } while (0)
+#define pud_free_tlb(tlb, x, addr)	do { } while (0)
 #define pud_free(mm, x)			do { } while (0)
-#define __pud_free_tlb(tlb, x)		do { } while (0)
+#define __pud_free_tlb(tlb, x, addr)	do { } while (0)
 
 #undef  pud_addr_end
 #define pud_addr_end(addr, end)		(end)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
