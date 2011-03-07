Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BC0278D003C
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:49:26 -0500 (EST)
Message-Id: <20110307172206.693792867@chello.nl>
Date: Mon, 07 Mar 2011 18:13:53 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 03/15] mm, arch: Remove tlb_flush()
References: <20110307171350.989666626@chello.nl>
Content-Disposition: inline; filename=generic_tlb_flush.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Since all asm-generic/tlb.h users their tlb_flush() implementation is
now either a nop or flush_tlb_mm(), remove it and make the generic
code use flush_tlb_mm() directly.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/alpha/include/asm/tlb.h      |    2 --
 arch/arm/include/asm/tlb.h        |    2 --
 arch/avr32/include/asm/tlb.h      |    5 -----
 arch/blackfin/include/asm/tlb.h   |    6 ------
 arch/cris/include/asm/tlb.h       |    1 -
 arch/frv/include/asm/tlb.h        |    5 -----
 arch/h8300/include/asm/tlb.h      |   13 -------------
 arch/m32r/include/asm/tlb.h       |    6 ------
 arch/m68k/include/asm/tlb.h       |    6 ------
 arch/microblaze/include/asm/tlb.h |    2 --
 arch/mips/include/asm/tlb.h       |    5 -----
 arch/mn10300/include/asm/tlb.h    |    5 -----
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
 arch/x86/include/asm/tlb.h        |    1 -
 arch/xtensa/include/asm/tlb.h     |    1 -
 include/asm-generic/tlb.h         |    2 +-
 25 files changed, 1 insertion(+), 101 deletions(-)

Index: linux-2.6/arch/alpha/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/alpha/include/asm/tlb.h
+++ linux-2.6/arch/alpha/include/asm/tlb.h
@@ -5,8 +5,6 @@
 #define tlb_end_vma(tlb, vma)			do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, pte, addr)	do { } while (0)
 
-#define tlb_flush(tlb)				flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 #define __pte_free_tlb(tlb, pte, address)		pte_free((tlb)->mm, pte)
Index: linux-2.6/arch/arm/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/arm/include/asm/tlb.h
+++ linux-2.6/arch/arm/include/asm/tlb.h
@@ -23,8 +23,6 @@
 
 #include <linux/pagemap.h>
 
-#define tlb_flush(tlb)	((void) tlb)
-
 #include <asm-generic/tlb.h>
 
 #else /* !CONFIG_MMU */
Index: linux-2.6/arch/avr32/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/avr32/include/asm/tlb.h
+++ linux-2.6/arch/avr32/include/asm/tlb.h
@@ -16,11 +16,6 @@
 
 #define __tlb_remove_tlb_entry(tlb, pte, address) do { } while(0)
 
-/*
- * Flush whole TLB for MM
- */
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 /*
Index: linux-2.6/arch/blackfin/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/blackfin/include/asm/tlb.h
+++ linux-2.6/arch/blackfin/include/asm/tlb.h
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
Index: linux-2.6/arch/cris/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/cris/include/asm/tlb.h
+++ linux-2.6/arch/cris/include/asm/tlb.h
@@ -13,7 +13,6 @@
 #define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
 #include <asm-generic/tlb.h>
 
 #endif
Index: linux-2.6/arch/frv/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/frv/include/asm/tlb.h
+++ linux-2.6/arch/frv/include/asm/tlb.h
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
Index: linux-2.6/arch/h8300/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/h8300/include/asm/tlb.h
+++ linux-2.6/arch/h8300/include/asm/tlb.h
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
Index: linux-2.6/arch/m32r/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/m32r/include/asm/tlb.h
+++ linux-2.6/arch/m32r/include/asm/tlb.h
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
Index: linux-2.6/arch/m68k/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/m68k/include/asm/tlb.h
+++ linux-2.6/arch/m68k/include/asm/tlb.h
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
Index: linux-2.6/arch/microblaze/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/microblaze/include/asm/tlb.h
+++ linux-2.6/arch/microblaze/include/asm/tlb.h
@@ -11,8 +11,6 @@
 #ifndef _ASM_MICROBLAZE_TLB_H
 #define _ASM_MICROBLAZE_TLB_H
 
-#define tlb_flush(tlb)	flush_tlb_mm((tlb)->mm)
-
 #include <linux/pagemap.h>
 #include <asm-generic/tlb.h>
 
Index: linux-2.6/arch/mips/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/mips/include/asm/tlb.h
+++ linux-2.6/arch/mips/include/asm/tlb.h
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
Index: linux-2.6/arch/mn10300/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/mn10300/include/asm/tlb.h
+++ linux-2.6/arch/mn10300/include/asm/tlb.h
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
 
Index: linux-2.6/arch/parisc/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/parisc/include/asm/tlb.h
+++ linux-2.6/arch/parisc/include/asm/tlb.h
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
Index: linux-2.6/arch/powerpc/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/powerpc/include/asm/tlb.h
+++ linux-2.6/arch/powerpc/include/asm/tlb.h
@@ -28,8 +28,6 @@
 #define tlb_start_vma(tlb, vma)	do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 
-extern void tlb_flush(struct mmu_gather *tlb);
-
 /* Get the generic bits... */
 #include <asm-generic/tlb.h>
 
Index: linux-2.6/arch/powerpc/mm/tlb_hash32.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/tlb_hash32.c
+++ linux-2.6/arch/powerpc/mm/tlb_hash32.c
@@ -59,21 +59,6 @@ void flush_tlb_page_nohash(struct vm_are
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
Index: linux-2.6/arch/powerpc/mm/tlb_hash64.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/tlb_hash64.c
+++ linux-2.6/arch/powerpc/mm/tlb_hash64.c
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
Index: linux-2.6/arch/powerpc/mm/tlb_nohash.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/tlb_nohash.c
+++ linux-2.6/arch/powerpc/mm/tlb_nohash.c
@@ -296,11 +296,6 @@ void flush_tlb_range(struct vm_area_stru
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
Index: linux-2.6/arch/score/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/score/include/asm/tlb.h
+++ linux-2.6/arch/score/include/asm/tlb.h
@@ -8,7 +8,6 @@
 #define tlb_start_vma(tlb, vma)		do {} while (0)
 #define tlb_end_vma(tlb, vma)		do {} while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do {} while (0)
-#define tlb_flush(tlb)			flush_tlb_mm((tlb)->mm)
 
 extern void score7_FTLB_refill_Handler(void);
 
Index: linux-2.6/arch/sh/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/sh/include/asm/tlb.h
+++ linux-2.6/arch/sh/include/asm/tlb.h
@@ -125,7 +125,6 @@ static inline void tlb_unwire_entry(void
 #define tlb_start_vma(tlb, vma)				do { } while (0)
 #define tlb_end_vma(tlb, vma)				do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, pte, address)	do { } while (0)
-#define tlb_flush(tlb)					do { } while (0)
 
 #include <asm-generic/tlb.h>
 
Index: linux-2.6/arch/sparc/include/asm/tlb_32.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/tlb_32.h
+++ linux-2.6/arch/sparc/include/asm/tlb_32.h
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
Index: linux-2.6/arch/sparc/include/asm/tlb_64.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/tlb_64.h
+++ linux-2.6/arch/sparc/include/asm/tlb_64.h
@@ -25,7 +25,6 @@ extern void flush_tlb_pending(void);
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
-#define tlb_flush(tlb)	do { } while (0)
 
 #include <asm-generic/tlb.h>
 
Index: linux-2.6/arch/tile/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/tile/include/asm/tlb.h
+++ linux-2.6/arch/tile/include/asm/tlb.h
@@ -18,7 +18,6 @@
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
 
 #include <asm-generic/tlb.h>
 
Index: linux-2.6/arch/x86/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/tlb.h
+++ linux-2.6/arch/x86/include/asm/tlb.h
@@ -4,7 +4,6 @@
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
 
 #include <asm-generic/tlb.h>
 
Index: linux-2.6/arch/xtensa/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/xtensa/include/asm/tlb.h
+++ linux-2.6/arch/xtensa/include/asm/tlb.h
@@ -38,7 +38,6 @@
 #endif
 
 #define __tlb_remove_tlb_entry(tlb,pte,addr)	do { } while (0)
-#define tlb_flush(tlb)				flush_tlb_mm((tlb)->mm)
 
 #include <asm-generic/tlb.h>
 
Index: linux-2.6/include/asm-generic/tlb.h
===================================================================
--- linux-2.6.orig/include/asm-generic/tlb.h
+++ linux-2.6/include/asm-generic/tlb.h
@@ -159,7 +159,7 @@ tlb_flush_mmu(struct mmu_gather *tlb)
 	if (!tlb->need_flush)
 		return;
 	tlb->need_flush = 0;
-	tlb_flush(tlb);
+	flush_tlb_mm(tlb->mm);
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
 #endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
