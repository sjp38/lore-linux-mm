Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C70345F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:02:50 -0400 (EDT)
Subject: Adding "addr" argument to __{pte,pmd,pud}_free_tlb()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Tue, 02 Jun 2009 15:02:44 +1000
Message-Id: <1243918964.5308.31.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi !

For some new powerpc variant support where I'm doing tricks with
the mapping of PTE pages I need to know the virtual address
represented by the base of a PTE page.

I could use the old technique of sticking stuff in the struct page of
the PTE page but that sucks since all callsites have it already close
by.

So before I do a giant patch adding the argument to all archs, here's a
quick check to see there's no objection. The basic patch for the core
code and powerpc arch only is below. If nobody goes onto a tantrum over
the next few weeks, then I'll produce a new variant that fixes all
archs.

Note: In theory I only need it for __pte_free_tlb() but it's readily
available at the callsite for the others and so it's basically free
so it's better to have the API be consistent for all 3 call types.

Cheers,
Ben.

Index: linux-work/arch/powerpc/include/asm/pgalloc-32.h
===================================================================
--- linux-work.orig/arch/powerpc/include/asm/pgalloc-32.h	2009-04-01 16:32:01.000000000 +1100
+++ linux-work/arch/powerpc/include/asm/pgalloc-32.h	2009-04-01 16:32:03.000000000 +1100
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
--- linux-work.orig/arch/powerpc/include/asm/pgalloc-64.h	2009-04-01 16:32:12.000000000 +1100
+++ linux-work/arch/powerpc/include/asm/pgalloc-64.h	2009-04-01 16:32:21.000000000 +1100
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
--- linux-work.orig/arch/powerpc/include/asm/pgalloc.h	2009-04-01 16:31:33.000000000 +1100
+++ linux-work/arch/powerpc/include/asm/pgalloc.h	2009-04-01 16:31:43.000000000 +1100
@@ -38,14 +38,14 @@ static inline pgtable_free_t pgtable_fre
 extern void pgtable_free_tlb(struct mmu_gather *tlb, pgtable_free_t pgf);
 
 #ifdef CONFIG_SMP
-#define __pte_free_tlb(tlb,ptepage)	\
+#define __pte_free_tlb(tlb,ptepage,address)		\
 do { \
 	pgtable_page_dtor(ptepage); \
 	pgtable_free_tlb(tlb, pgtable_free_cache(page_address(ptepage), \
 		PTE_NONCACHE_NUM, PTE_TABLE_SIZE-1)); \
 } while (0)
 #else
-#define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
+#define __pte_free_tlb(tlb, pte, address)	pte_free((tlb)->mm, (pte))
 #endif
 
 
Index: linux-work/include/asm-generic/pgtable-nopmd.h
===================================================================
--- linux-work.orig/include/asm-generic/pgtable-nopmd.h	2009-04-01 16:32:57.000000000 +1100
+++ linux-work/include/asm-generic/pgtable-nopmd.h	2009-04-01 16:33:03.000000000 +1100
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
--- linux-work.orig/include/asm-generic/pgtable-nopud.h	2009-04-01 16:32:40.000000000 +1100
+++ linux-work/include/asm-generic/pgtable-nopud.h	2009-04-01 16:32:44.000000000 +1100
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
--- linux-work.orig/include/asm-generic/tlb.h	2009-04-01 16:28:50.000000000 +1100
+++ linux-work/include/asm-generic/tlb.h	2009-04-01 16:29:20.000000000 +1100
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
--- linux-work.orig/mm/memory.c	2009-04-01 16:30:05.000000000 +1100
+++ linux-work/mm/memory.c	2009-04-01 16:30:48.000000000 +1100
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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
