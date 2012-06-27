Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 9509F6B0082
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:55 -0400 (EDT)
Message-Id: <20120627212831.206575677@chello.nl>
Date: Wed, 27 Jun 2012 23:15:49 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 09/20] mm, arch: Add end argument to p??_free_tlb()
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-p_free_tlb.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

In order to facilitate range tracking we need the end address of the
object we're freeing. The callsites already compute this address so
change things to simply pass it along.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/arm/include/asm/tlb.h         |    6 +++---
 arch/ia64/include/asm/tlb.h        |    6 +++---
 arch/powerpc/mm/hugetlbpage.c      |    4 ++--
 arch/s390/include/asm/tlb.h        |    6 +++---
 arch/sh/include/asm/tlb.h          |    6 +++---
 arch/um/include/asm/tlb.h          |    6 +++---
 include/asm-generic/4level-fixup.h |    2 +-
 include/asm-generic/tlb.h          |    6 +++---
 mm/memory.c                        |   10 +++++-----
 9 files changed, 26 insertions(+), 26 deletions(-)
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -217,9 +217,9 @@ static inline void __pmd_free_tlb(struct
 #endif
 }
 
-#define pte_free_tlb(tlb, ptep, addr)	__pte_free_tlb(tlb, ptep, addr)
-#define pmd_free_tlb(tlb, pmdp, addr)	__pmd_free_tlb(tlb, pmdp, addr)
-#define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
+#define pte_free_tlb(tlb, ptep, addr, end)	__pte_free_tlb(tlb, ptep, addr)
+#define pmd_free_tlb(tlb, pmdp, addr, end)	__pmd_free_tlb(tlb, pmdp, addr)
+#define pud_free_tlb(tlb, pudp, addr, end)	pud_free((tlb)->mm, pudp)
 
 #define tlb_migrate_finish(mm)		do { } while (0)
 
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -262,19 +262,19 @@ do {							\
 	__tlb_remove_tlb_entry(tlb, ptep, addr);	\
 } while (0)
 
-#define pte_free_tlb(tlb, ptep, address)		\
+#define pte_free_tlb(tlb, ptep, address, end)		\
 do {							\
 	tlb->need_flush = 1;				\
 	__pte_free_tlb(tlb, ptep, address);		\
 } while (0)
 
-#define pmd_free_tlb(tlb, ptep, address)		\
+#define pmd_free_tlb(tlb, ptep, address, end)		\
 do {							\
 	tlb->need_flush = 1;				\
 	__pmd_free_tlb(tlb, ptep, address);		\
 } while (0)
 
-#define pud_free_tlb(tlb, pudp, address)		\
+#define pud_free_tlb(tlb, pudp, address, end)		\
 do {							\
 	tlb->need_flush = 1;				\
 	__pud_free_tlb(tlb, pudp, address);		\
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -503,7 +503,7 @@ static void hugetlb_free_pmd_range(struc
 
 	pmd = pmd_offset(pud, start);
 	pud_clear(pud);
-	pmd_free_tlb(tlb, pmd, start);
+	pmd_free_tlb(tlb, pmd, start, end);
 }
 
 static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
@@ -551,7 +551,7 @@ static void hugetlb_free_pud_range(struc
 
 	pud = pud_offset(pgd, start);
 	pgd_clear(pgd);
-	pud_free_tlb(tlb, pud, start);
+	pud_free_tlb(tlb, pud, start, end);
 }
 
 /*
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -103,7 +103,7 @@ static inline void tlb_remove_page(struc
  * page table from the tlb.
  */
 static inline void pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
-				unsigned long address)
+				unsigned long address, unsigned long end)
 {
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	if (!tlb->fullmm)
@@ -120,7 +120,7 @@ static inline void pte_free_tlb(struct m
  * to avoid the double free of the pmd in this case.
  */
 static inline void pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
-				unsigned long address)
+				unsigned long address, unsigned long end)
 {
 #ifdef CONFIG_64BIT
 	if (tlb->mm->context.asce_limit <= (1UL << 31))
@@ -141,7 +141,7 @@ static inline void pmd_free_tlb(struct m
  * to avoid the double free of the pud in this case.
  */
 static inline void pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
-				unsigned long address)
+				unsigned long address, unsigned long end)
 {
 #ifdef CONFIG_64BIT
 	if (tlb->mm->context.asce_limit <= (1UL << 42))
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -99,9 +99,9 @@ static inline void tlb_remove_page(struc
 	__tlb_remove_page(tlb, page);
 }
 
-#define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
-#define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
-#define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
+#define pte_free_tlb(tlb, ptep, addr, end)	pte_free((tlb)->mm, ptep)
+#define pmd_free_tlb(tlb, pmdp, addr, end)	pmd_free((tlb)->mm, pmdp)
+#define pud_free_tlb(tlb, pudp, addr, end)	pud_free((tlb)->mm, pudp)
 
 #define tlb_migrate_finish(mm)		do { } while (0)
 
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -109,11 +109,11 @@ static inline void tlb_remove_page(struc
 		__tlb_remove_tlb_entry(tlb, ptep, address);	\
 	} while (0)
 
-#define pte_free_tlb(tlb, ptep, addr) __pte_free_tlb(tlb, ptep, addr)
+#define pte_free_tlb(tlb, ptep, addr, end) __pte_free_tlb(tlb, ptep, addr)
 
-#define pud_free_tlb(tlb, pudp, addr) __pud_free_tlb(tlb, pudp, addr)
+#define pud_free_tlb(tlb, pudp, addr, end) __pud_free_tlb(tlb, pudp, addr)
 
-#define pmd_free_tlb(tlb, pmdp, addr) __pmd_free_tlb(tlb, pmdp, addr)
+#define pmd_free_tlb(tlb, pmdp, addr, end) __pmd_free_tlb(tlb, pmdp, addr)
 
 #define tlb_migrate_finish(mm) do {} while (0)
 
--- a/include/asm-generic/4level-fixup.h
+++ b/include/asm-generic/4level-fixup.h
@@ -27,7 +27,7 @@
 #define pud_page_vaddr(pud)		pgd_page_vaddr(pud)
 
 #undef pud_free_tlb
-#define pud_free_tlb(tlb, x, addr)	do { } while (0)
+#define pud_free_tlb(tlb, x, addr, end)	do { } while (0)
 #define pud_free(mm, x)			do { } while (0)
 #define __pud_free_tlb(tlb, x, addr)	do { } while (0)
 
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -166,21 +166,21 @@ static inline void tlb_remove_page(struc
 		__tlb_remove_pmd_tlb_entry(tlb, pmdp, address);	\
 	} while (0)
 
-#define pte_free_tlb(tlb, ptep, address)			\
+#define pte_free_tlb(tlb, ptep, address, end)			\
 	do {							\
 		tlb->need_flush = 1;				\
 		__pte_free_tlb(tlb, ptep, address);		\
 	} while (0)
 
 #ifndef __ARCH_HAS_4LEVEL_HACK
-#define pud_free_tlb(tlb, pudp, address)			\
+#define pud_free_tlb(tlb, pudp, address, end)			\
 	do {							\
 		tlb->need_flush = 1;				\
 		__pud_free_tlb(tlb, pudp, address);		\
 	} while (0)
 #endif
 
-#define pmd_free_tlb(tlb, pmdp, address)			\
+#define pmd_free_tlb(tlb, pmdp, address, end)			\
 	do {							\
 		tlb->need_flush = 1;				\
 		__pmd_free_tlb(tlb, pmdp, address);		\
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -421,11 +421,11 @@ void pmd_clear_bad(pmd_t *pmd)
  * has been handled earlier when unmapping all the memory regions.
  */
 static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
-			   unsigned long addr)
+			   unsigned long addr, unsigned long end)
 {
 	pgtable_t token = pmd_pgtable(*pmd);
 	pmd_clear(pmd);
-	pte_free_tlb(tlb, token, addr);
+	pte_free_tlb(tlb, token, addr, end);
 	tlb->mm->nr_ptes--;
 }
 
@@ -443,7 +443,7 @@ static inline void free_pmd_range(struct
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		free_pte_range(tlb, pmd, addr);
+		free_pte_range(tlb, pmd, addr, next);
 	} while (pmd++, addr = next, addr != end);
 
 	start &= PUD_MASK;
@@ -459,7 +459,7 @@ static inline void free_pmd_range(struct
 
 	pmd = pmd_offset(pud, start);
 	pud_clear(pud);
-	pmd_free_tlb(tlb, pmd, start);
+	pmd_free_tlb(tlb, pmd, start, end);
 }
 
 static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
@@ -492,7 +492,7 @@ static inline void free_pud_range(struct
 
 	pud = pud_offset(pgd, start);
 	pgd_clear(pgd);
-	pud_free_tlb(tlb, pud, start);
+	pud_free_tlb(tlb, pud, start, end);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
