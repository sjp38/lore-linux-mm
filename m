Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 44C0E6B007B
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:48 -0400 (EDT)
Message-Id: <20120627212831.062889833@chello.nl>
Date: Wed, 27 Jun 2012 23:15:47 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 07/20] mm, arch: Remove tlb_flush()
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=generic_tlb_flush.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

Since all asm-generic/tlb.h users their tlb_flush() implementation is
now either a nop or flush_tlb_mm(), remove it and make the generic
code use flush_tlb_mm() directly.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/alpha/include/asm/tlb.h      |    2 --
 arch/arm/include/asm/tlb.h        |    2 --
 arch/avr32/include/asm/tlb.h      |    5 -----
 arch/blackfin/include/asm/tlb.h   |    6 ------
 arch/c6x/include/asm/tlb.h        |    2 --
 arch/cris/include/asm/tlb.h       |    1 -
 arch/frv/include/asm/tlb.h        |    5 -----
 arch/h8300/include/asm/tlb.h      |   13 -------------
 arch/hexagon/include/asm/tlb.h    |    5 -----
 arch/m32r/include/asm/tlb.h       |    6 ------
 arch/m68k/include/asm/tlb.h       |    6 ------
 arch/microblaze/include/asm/tlb.h |    2 --
 arch/mips/include/asm/tlb.h       |    5 -----
 arch/mn10300/include/asm/tlb.h    |    5 -----
 arch/openrisc/include/asm/tlb.h   |    1 -
 arch/parisc/include/asm/tlb.h     |    5 -----
 arch/powerpc/include/asm/tlb.h    |    2 --
 arch/powerpc/mm/tlb_hash32.c      |   15 ---------------
 arch/powerpc/mm/tlb_hash64.c      |    4 ----
 arch/powerpc/mm/tlb_nohash.c      |    5 -----
 arch/score/include/asm/tlb.h      |    1 -
 arch/sh/include/asm/tlb.h         |    1 -
 arch/sparc/include/asm/tlb_32.h   |    5 -----
 arch/sparc/include/asm/tlb_64.h   |    1 -
 arch/tile/include/asm/tlb.h       |    1 -
 arch/unicore32/include/asm/tlb.h  |    1 -
 arch/x86/include/asm/tlb.h        |    1 -
 arch/xtensa/include/asm/tlb.h     |    1 -
 mm/memory.c                       |    2 +-
 29 files changed, 1 insertion(+), 110 deletions(-)
--- a/arch/alpha/include/asm/tlb.h
+++ b/arch/alpha/include/asm/tlb.h
@@ -5,8 +5,6 @@
 #define tlb_end_vma(tlb, vma)			do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, pte, addr)	do { } while (0)
 
-#define tlb_flush(tlb)				flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 #define __pte_free_tlb(tlb, pte, address)		pte_free((tlb)->mm, pte)
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -23,8 +23,6 @@
 
 #include <linux/pagemap.h>
 
-#define tlb_flush(tlb)	((void) tlb)
-
 #include <asm-generic/tlb.h>
 
 #else /* !CONFIG_MMU */
--- a/arch/avr32/include/asm/tlb.h
+++ b/arch/avr32/include/asm/tlb.h
@@ -16,11 +16,6 @@
 
 #define __tlb_remove_tlb_entry(tlb, pte, address) do { } while(0)
 
-/*
- * Flush whole TLB for MM
- */
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 /*
--- a/arch/blackfin/include/asm/tlb.h
+++ b/arch/blackfin/include/asm/tlb.h
@@ -11,12 +11,6 @@
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
 
-/*
- * .. because we flush the whole mm when it
- * fills up.
- */
-#define tlb_flush(tlb)		flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 #endif				/* _BLACKFIN_TLB_H */
--- a/arch/c6x/include/asm/tlb.h
+++ b/arch/c6x/include/asm/tlb.h
@@ -1,8 +1,6 @@
 #ifndef _ASM_C6X_TLB_H
 #define _ASM_C6X_TLB_H
 
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 #endif /* _ASM_C6X_TLB_H */
--- a/arch/cris/include/asm/tlb.h
+++ b/arch/cris/include/asm/tlb.h
@@ -13,7 +13,6 @@
 #define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
 #include <asm-generic/tlb.h>
 
 #endif
--- a/arch/frv/include/asm/tlb.h
+++ b/arch/frv/include/asm/tlb.h
@@ -16,11 +16,6 @@ extern void check_pgt_cache(void);
 #define tlb_end_vma(tlb, vma)				do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
 
-/*
- * .. because we flush the whole mm when it fills up
- */
-#define tlb_flush(tlb)		flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 #endif /* _ASM_TLB_H */
--- a/arch/h8300/include/asm/tlb.h
+++ b/arch/h8300/include/asm/tlb.h
@@ -5,19 +5,6 @@
 #ifndef __H8300_TLB_H__
 #define __H8300_TLB_H__
 
-#define tlb_flush(tlb)	do { } while(0)
-
-/* 
-  include/asm-h8300/tlb.h 
-*/
-
-#ifndef __H8300_TLB_H__
-#define __H8300_TLB_H__
-
-#define tlb_flush(tlb)	do { } while(0)
-
 #include <asm-generic/tlb.h>
 
 #endif
-
-#endif
--- a/arch/hexagon/include/asm/tlb.h
+++ b/arch/hexagon/include/asm/tlb.h
@@ -29,11 +29,6 @@
 #define tlb_end_vma(tlb, vma)				do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
 
-/*
- * .. because we flush the whole mm when it fills up
- */
-#define tlb_flush(tlb)		flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 #endif
--- a/arch/m32r/include/asm/tlb.h
+++ b/arch/m32r/include/asm/tlb.h
@@ -9,12 +9,6 @@
 #define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, pte, address) do { } while (0)
 
-/*
- * .. because we flush the whole mm when it
- * fills up.
- */
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 #endif /* _M32R_TLB_H */
--- a/arch/m68k/include/asm/tlb.h
+++ b/arch/m68k/include/asm/tlb.h
@@ -9,12 +9,6 @@
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
 
-/*
- * .. because we flush the whole mm when it
- * fills up.
- */
-#define tlb_flush(tlb)		flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 #endif /* _M68K_TLB_H */
--- a/arch/microblaze/include/asm/tlb.h
+++ b/arch/microblaze/include/asm/tlb.h
@@ -11,8 +11,6 @@
 #ifndef _ASM_MICROBLAZE_TLB_H
 #define _ASM_MICROBLAZE_TLB_H
 
-#define tlb_flush(tlb)	flush_tlb_mm((tlb)->mm)
-
 #include <linux/pagemap.h>
 #include <asm-generic/tlb.h>
 
--- a/arch/mips/include/asm/tlb.h
+++ b/arch/mips/include/asm/tlb.h
@@ -13,11 +13,6 @@
 #define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
-/*
- * .. because we flush the whole mm when it fills up.
- */
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 #endif /* __ASM_TLB_H */
--- a/arch/mn10300/include/asm/tlb.h
+++ b/arch/mn10300/include/asm/tlb.h
@@ -23,11 +23,6 @@ extern void check_pgt_cache(void);
 #define tlb_end_vma(tlb, vma)				do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
 
-/*
- * .. because we flush the whole mm when it fills up
- */
-#define tlb_flush(tlb)	flush_tlb_mm((tlb)->mm)
-
 /* for now, just use the generic stuff */
 #include <asm-generic/tlb.h>
 
--- a/arch/openrisc/include/asm/tlb.h
+++ b/arch/openrisc/include/asm/tlb.h
@@ -27,7 +27,6 @@
 #define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
 #include <linux/pagemap.h>
 #include <asm-generic/tlb.h>
 
--- a/arch/parisc/include/asm/tlb.h
+++ b/arch/parisc/include/asm/tlb.h
@@ -1,11 +1,6 @@
 #ifndef _PARISC_TLB_H
 #define _PARISC_TLB_H
 
-#define tlb_flush(tlb)			\
-do {	if ((tlb)->fullmm)		\
-		flush_tlb_mm((tlb)->mm);\
-} while (0)
-
 #define tlb_start_vma(tlb, vma) \
 do {	if (!(tlb)->fullmm)	\
 		flush_cache_range(vma, vma->vm_start, vma->vm_end); \
--- a/arch/powerpc/include/asm/tlb.h
+++ b/arch/powerpc/include/asm/tlb.h
@@ -28,8 +28,6 @@
 #define tlb_start_vma(tlb, vma)	do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 
-extern void tlb_flush(struct mmu_gather *tlb);
-
 /* Get the generic bits... */
 #include <asm-generic/tlb.h>
 
--- a/arch/powerpc/mm/tlb_hash32.c
+++ b/arch/powerpc/mm/tlb_hash32.c
@@ -60,21 +60,6 @@ void flush_tlb_page_nohash(struct vm_are
 }
 
 /*
- * Called at the end of a mmu_gather operation to make sure the
- * TLB flush is completely done.
- */
-void tlb_flush(struct mmu_gather *tlb)
-{
-	if (Hash == 0) {
-		/*
-		 * 603 needs to flush the whole TLB here since
-		 * it doesn't use a hash table.
-		 */
-		_tlbia();
-	}
-}
-
-/*
  * TLB flushing:
  *
  *  - flush_tlb_mm(mm) flushes the specified mm context TLB's
--- a/arch/powerpc/mm/tlb_hash64.c
+++ b/arch/powerpc/mm/tlb_hash64.c
@@ -153,10 +153,6 @@ void __flush_tlb_pending(struct ppc64_tl
 	batch->index = 0;
 }
 
-void tlb_flush(struct mmu_gather *tlb)
-{
-}
-
 /**
  * __flush_hash_table_range - Flush all HPTEs for a given address range
  *                            from the hash table (and the TLB). But keeps
--- a/arch/powerpc/mm/tlb_nohash.c
+++ b/arch/powerpc/mm/tlb_nohash.c
@@ -357,11 +357,6 @@ void flush_tlb_range(struct vm_area_stru
 }
 EXPORT_SYMBOL(flush_tlb_range);
 
-void tlb_flush(struct mmu_gather *tlb)
-{
-	flush_tlb_mm(tlb->mm);
-}
-
 /*
  * Below are functions specific to the 64-bit variant of Book3E though that
  * may change in the future
--- a/arch/score/include/asm/tlb.h
+++ b/arch/score/include/asm/tlb.h
@@ -8,7 +8,6 @@
 #define tlb_start_vma(tlb, vma)		do {} while (0)
 #define tlb_end_vma(tlb, vma)		do {} while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do {} while (0)
-#define tlb_flush(tlb)			flush_tlb_mm((tlb)->mm)
 
 extern void score7_FTLB_refill_Handler(void);
 
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -126,7 +126,6 @@ static inline void tlb_unwire_entry(void
 #define tlb_start_vma(tlb, vma)				do { } while (0)
 #define tlb_end_vma(tlb, vma)				do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, pte, address)	do { } while (0)
-#define tlb_flush(tlb)					do { } while (0)
 
 #include <asm-generic/tlb.h>
 
--- a/arch/sparc/include/asm/tlb_32.h
+++ b/arch/sparc/include/asm/tlb_32.h
@@ -14,11 +14,6 @@ do {								\
 #define __tlb_remove_tlb_entry(tlb, pte, address) \
 	do { } while (0)
 
-#define tlb_flush(tlb) \
-do {								\
-	flush_tlb_mm((tlb)->mm);				\
-} while (0)
-
 #include <asm-generic/tlb.h>
 
 #endif /* _SPARC_TLB_H */
--- a/arch/sparc/include/asm/tlb_64.h
+++ b/arch/sparc/include/asm/tlb_64.h
@@ -25,7 +25,6 @@ extern void flush_tlb_pending(void);
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
-#define tlb_flush(tlb)	do { } while (0)
 
 #include <asm-generic/tlb.h>
 
--- a/arch/tile/include/asm/tlb.h
+++ b/arch/tile/include/asm/tlb.h
@@ -18,7 +18,6 @@
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
 
 #include <asm-generic/tlb.h>
 
--- a/arch/unicore32/include/asm/tlb.h
+++ b/arch/unicore32/include/asm/tlb.h
@@ -15,7 +15,6 @@
 #define tlb_start_vma(tlb, vma)				do { } while (0)
 #define tlb_end_vma(tlb, vma)				do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
 
 #define __pte_free_tlb(tlb, pte, addr)				\
 	do {							\
--- a/arch/x86/include/asm/tlb.h
+++ b/arch/x86/include/asm/tlb.h
@@ -5,7 +5,6 @@
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
 
 #include <asm-generic/tlb.h>
 
--- a/arch/xtensa/include/asm/tlb.h
+++ b/arch/xtensa/include/asm/tlb.h
@@ -38,7 +38,6 @@
 #endif
 
 #define __tlb_remove_tlb_entry(tlb,pte,addr)	do { } while (0)
-#define tlb_flush(tlb)				flush_tlb_mm((tlb)->mm)
 
 #include <asm-generic/tlb.h>
 
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -226,7 +226,7 @@ void tlb_flush_mmu(struct mmu_gather *tl
 	if (!tlb->need_flush)
 		return;
 	tlb->need_flush = 0;
-	tlb_flush(tlb);
+	flush_tlb_mm(tlb->mm);
 	tlb_table_flush(tlb);
 
 	if (tlb_fast_mode(tlb))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
