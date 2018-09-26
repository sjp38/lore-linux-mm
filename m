Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id A6FF28E000F
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:55:06 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id r18-v6so39737819ioj.4
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:55:06 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id j16-v6si3076837iok.283.2018.09.26.04.55.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 26 Sep 2018 04:55:05 -0700 (PDT)
Message-ID: <20180926114801.146189550@infradead.org>
Date: Wed, 26 Sep 2018 13:36:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 12/18] arch/tlb: Clean up simple architectures
References: <20180926113623.863696043@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com, Richard Henderson <rth@twiddle.net>, Vineet Gupta <vgupta@synopsys.com>, Mark Salter <msalter@redhat.com>, Richard Kuo <rkuo@codeaurora.org>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Greentime Hu <green.hu@gmail.com>, Ley Foon Tan <lftan@altera.com>, Jonas Bonn <jonas@southpole.se>, Helge Deller <deller@gmx.de>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Max Filippov <jcmvbkbc@gmail.com>

There are generally two cases:

 1) either the platform has an efficient flush_tlb_range() and
    asm-generic/tlb.h doesn't need any overrides at all.

 2) or an architecture lacks an efficient flush_tlb_range() and
    we override tlb_end_vma() and tlb_flush().

Convert all 'simple' architectures to one of these two forms.

alpha:	    has no range invalidate -> 2
arc:	    already used flush_tlb_range() -> 1
c6x:	    has no range invalidate -> 2
h8300:	    has no mmu
hexagon:    has an efficient flush_tlb_range() -> 1
            (flush_tlb_mm() is in fact a full range invalidate,
	     so no need to shoot down everything)
m68k:	    has inefficient flush_tlb_range() -> 2
microblaze: has no flush_tlb_range() -> 2
mips:	    has efficient flush_tlb_range() -> 1
	    (even though it currently seems to use flush_tlb_mm())
nds32:	    already uses flush_tlb_range() -> 1
nios2:	    has inefficient flush_tlb_range() -> 2
	    (no limit on range iteration)
openrisc:   has inefficient flush_tlb_range() -> 2
	    (no limit on range iteration)
parisc:	    already uses flush_tlb_range() -> 1
sparc32:    already uses flush_tlb_range() -> 1
unicore32:  has inefficient flush_tlb_range() -> 2
	    (no limit on range iteration)
xtensa:	    has efficient flush_tlb_range() -> 1

Cc: Richard Henderson <rth@twiddle.net>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: Mark Salter <msalter@redhat.com>
Cc: Richard Kuo <rkuo@codeaurora.org>
Cc: Michal Simek <monstr@monstr.eu>
Cc: Paul Burton <paul.burton@mips.com>
Cc: Greentime Hu <green.hu@gmail.com>
Cc: Ley Foon Tan <lftan@altera.com>
Cc: Jonas Bonn <jonas@southpole.se>
Cc: Helge Deller <deller@gmx.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Guan Xuetao <gxt@pku.edu.cn>
Cc: Max Filippov <jcmvbkbc@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@gmail.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/alpha/include/asm/tlb.h      |    2 --
 arch/arc/include/asm/tlb.h        |   23 -----------------------
 arch/c6x/include/asm/tlb.h        |    1 +
 arch/h8300/include/asm/tlb.h      |    2 --
 arch/hexagon/include/asm/tlb.h    |   12 ------------
 arch/m68k/include/asm/tlb.h       |    1 -
 arch/microblaze/include/asm/tlb.h |    4 +---
 arch/mips/include/asm/tlb.h       |    8 --------
 arch/nds32/include/asm/tlb.h      |   10 ----------
 arch/nios2/include/asm/tlb.h      |    8 +++++---
 arch/openrisc/include/asm/tlb.h   |    6 ++++--
 arch/parisc/include/asm/tlb.h     |   13 -------------
 arch/powerpc/include/asm/tlb.h    |    1 -
 arch/sparc/include/asm/tlb_32.h   |   13 -------------
 arch/unicore32/include/asm/tlb.h  |   10 ++++++----
 arch/xtensa/include/asm/tlb.h     |   17 -----------------
 16 files changed, 17 insertions(+), 114 deletions(-)

--- a/arch/alpha/include/asm/tlb.h
+++ b/arch/alpha/include/asm/tlb.h
@@ -4,8 +4,6 @@
 
 #define tlb_start_vma(tlb, vma)			do { } while (0)
 #define tlb_end_vma(tlb, vma)			do { } while (0)
-#define __tlb_remove_tlb_entry(tlb, pte, addr)	do { } while (0)
-
 #define tlb_flush(tlb)				flush_tlb_mm((tlb)->mm)
 
 #include <asm-generic/tlb.h>
--- a/arch/arc/include/asm/tlb.h
+++ b/arch/arc/include/asm/tlb.h
@@ -9,29 +9,6 @@
 #ifndef _ASM_ARC_TLB_H
 #define _ASM_ARC_TLB_H
 
-#define tlb_flush(tlb)				\
-do {						\
-	if (tlb->fullmm)			\
-		flush_tlb_mm((tlb)->mm);	\
-} while (0)
-
-/*
- * This pair is called at time of munmap/exit to flush cache and TLB entries
- * for mappings being torn down.
- * 1) cache-flush part -implemented via tlb_start_vma( ) for VIPT aliasing D$
- * 2) tlb-flush part - implemted via tlb_end_vma( ) flushes the TLB range
- *
- * Note, read http://lkml.org/lkml/2004/1/15/6
- */
-
-#define tlb_end_vma(tlb, vma)						\
-do {									\
-	if (!tlb->fullmm)						\
-		flush_tlb_range(vma, vma->vm_start, vma->vm_end);	\
-} while (0)
-
-#define __tlb_remove_tlb_entry(tlb, ptep, address)
-
 #include <linux/pagemap.h>
 #include <asm-generic/tlb.h>
 
--- a/arch/c6x/include/asm/tlb.h
+++ b/arch/c6x/include/asm/tlb.h
@@ -2,6 +2,7 @@
 #ifndef _ASM_C6X_TLB_H
 #define _ASM_C6X_TLB_H
 
+#define tlb_end_vma(tlb,vma) do { } while (0)
 #define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
 
 #include <asm-generic/tlb.h>
--- a/arch/h8300/include/asm/tlb.h
+++ b/arch/h8300/include/asm/tlb.h
@@ -2,8 +2,6 @@
 #ifndef __H8300_TLB_H__
 #define __H8300_TLB_H__
 
-#define tlb_flush(tlb)	do { } while (0)
-
 #include <asm-generic/tlb.h>
 
 #endif
--- a/arch/hexagon/include/asm/tlb.h
+++ b/arch/hexagon/include/asm/tlb.h
@@ -22,18 +22,6 @@
 #include <linux/pagemap.h>
 #include <asm/tlbflush.h>
 
-/*
- * We don't need any special per-pte or per-vma handling...
- */
-#define tlb_start_vma(tlb, vma)				do { } while (0)
-#define tlb_end_vma(tlb, vma)				do { } while (0)
-#define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
-
-/*
- * .. because we flush the whole mm when it fills up
- */
-#define tlb_flush(tlb)		flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 #endif
--- a/arch/m68k/include/asm/tlb.h
+++ b/arch/m68k/include/asm/tlb.h
@@ -8,7 +8,6 @@
  */
 #define tlb_start_vma(tlb, vma)	do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
-#define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
 
 /*
  * .. because we flush the whole mm when it
--- a/arch/microblaze/include/asm/tlb.h
+++ b/arch/microblaze/include/asm/tlb.h
@@ -11,14 +11,12 @@
 #ifndef _ASM_MICROBLAZE_TLB_H
 #define _ASM_MICROBLAZE_TLB_H
 
-#define tlb_flush(tlb)	flush_tlb_mm((tlb)->mm)
-
 #include <linux/pagemap.h>
 
 #ifdef CONFIG_MMU
 #define tlb_start_vma(tlb, vma)		do { } while (0)
 #define tlb_end_vma(tlb, vma)		do { } while (0)
-#define __tlb_remove_tlb_entry(tlb, pte, address) do { } while (0)
+#define tlb_flush(tlb)			flush_tlb_mm((tlb)->mm)
 #endif
 
 #include <asm-generic/tlb.h>
--- a/arch/mips/include/asm/tlb.h
+++ b/arch/mips/include/asm/tlb.h
@@ -5,14 +5,6 @@
 #include <asm/cpu-features.h>
 #include <asm/mipsregs.h>
 
-#define tlb_end_vma(tlb, vma) do { } while (0)
-#define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
-
-/*
- * .. because we flush the whole mm when it fills up.
- */
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
-
 #define _UNIQUE_ENTRYHI(base, idx)					\
 		(((base) + ((idx) << (PAGE_SHIFT + 1))) |		\
 		 (cpu_has_tlbinv ? MIPS_ENTRYHI_EHINV : 0))
--- a/arch/nds32/include/asm/tlb.h
+++ b/arch/nds32/include/asm/tlb.h
@@ -4,16 +4,6 @@
 #ifndef __ASMNDS32_TLB_H
 #define __ASMNDS32_TLB_H
 
-#define tlb_end_vma(tlb,vma)				\
-	do { 						\
-		if(!tlb->fullmm)			\
-			flush_tlb_range(vma, vma->vm_start, vma->vm_end); \
-	} while (0)
-
-#define __tlb_remove_tlb_entry(tlb, pte, addr) do { } while (0)
-
-#define tlb_flush(tlb)	flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 #define __pte_free_tlb(tlb, pte, addr)	pte_free((tlb)->mm, pte)
--- a/arch/nios2/include/asm/tlb.h
+++ b/arch/nios2/include/asm/tlb.h
@@ -11,12 +11,14 @@
 #ifndef _ASM_NIOS2_TLB_H
 #define _ASM_NIOS2_TLB_H
 
-#define tlb_flush(tlb)	flush_tlb_mm((tlb)->mm)
-
 extern void set_mmu_pid(unsigned long pid);
 
+/*
+ * NIOS32 does have flush_tlb_range(), but it lacks a limit and fallback to
+ * full mm invalidation. So use flush_tlb_mm() for everything.
+ */
 #define tlb_end_vma(tlb, vma)	do { } while (0)
-#define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
+#define tlb_flush(tlb)	flush_tlb_mm((tlb)->mm)
 
 #include <linux/pagemap.h>
 #include <asm-generic/tlb.h>
--- a/arch/openrisc/include/asm/tlb.h
+++ b/arch/openrisc/include/asm/tlb.h
@@ -22,12 +22,14 @@
 /*
  * or32 doesn't need any special per-pte or
  * per-vma handling..
+ *
+ * OpenRISC doesn't have an efficient flush_tlb_range() so use flush_tlb_mm()
+ * for everything.
  */
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma) do { } while (0)
-#define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
-
 #define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
+
 #include <linux/pagemap.h>
 #include <asm-generic/tlb.h>
 
--- a/arch/parisc/include/asm/tlb.h
+++ b/arch/parisc/include/asm/tlb.h
@@ -2,19 +2,6 @@
 #ifndef _PARISC_TLB_H
 #define _PARISC_TLB_H
 
-#define tlb_flush(tlb)			\
-do {	if ((tlb)->fullmm)		\
-		flush_tlb_mm((tlb)->mm);\
-} while (0)
-
-#define tlb_end_vma(tlb, vma)	\
-do {	if (!(tlb)->fullmm)	\
-		flush_tlb_range(vma, vma->vm_start, vma->vm_end); \
-} while (0)
-
-#define __tlb_remove_tlb_entry(tlb, pte, address) \
-	do { } while (0)
-
 #include <asm-generic/tlb.h>
 
 #define __pmd_free_tlb(tlb, pmd, addr)	pmd_free((tlb)->mm, pmd)
--- a/arch/sparc/include/asm/tlb_32.h
+++ b/arch/sparc/include/asm/tlb_32.h
@@ -2,19 +2,6 @@
 #ifndef _SPARC_TLB_H
 #define _SPARC_TLB_H
 
-#define tlb_end_vma(tlb, vma) \
-do {								\
-	flush_tlb_range(vma, vma->vm_start, vma->vm_end);	\
-} while (0)
-
-#define __tlb_remove_tlb_entry(tlb, pte, address) \
-	do { } while (0)
-
-#define tlb_flush(tlb) \
-do {								\
-	flush_tlb_mm((tlb)->mm);				\
-} while (0)
-
 #include <asm-generic/tlb.h>
 
 #endif /* _SPARC_TLB_H */
--- a/arch/unicore32/include/asm/tlb.h
+++ b/arch/unicore32/include/asm/tlb.h
@@ -12,10 +12,12 @@
 #ifndef __UNICORE_TLB_H__
 #define __UNICORE_TLB_H__
 
-#define tlb_start_vma(tlb, vma)				do { } while (0)
-#define tlb_end_vma(tlb, vma)				do { } while (0)
-#define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
+/*
+ * unicore32 lacks an afficient flush_tlb_range(), use flush_tlb_mm().
+ */
+#define tlb_start_vma(tlb, vma)		do { } while (0)
+#define tlb_end_vma(tlb, vma)		do { } while (0)
+#define tlb_flush(tlb)			flush_tlb_mm((tlb)->mm)
 
 #define __pte_free_tlb(tlb, pte, addr)				\
 	do {							\
--- a/arch/xtensa/include/asm/tlb.h
+++ b/arch/xtensa/include/asm/tlb.h
@@ -14,23 +14,6 @@
 #include <asm/cache.h>
 #include <asm/page.h>
 
-#if (DCACHE_WAY_SIZE <= PAGE_SIZE)
-
-# define tlb_end_vma(tlb,vma)			do { } while (0)
-
-#else
-
-# define tlb_end_vma(tlb, vma)						      \
-	do {								      \
-		if (!tlb->fullmm)					      \
-			flush_tlb_range(vma, vma->vm_start, vma->vm_end);     \
-	} while(0)
-
-#endif
-
-#define __tlb_remove_tlb_entry(tlb,pte,addr)	do { } while (0)
-#define tlb_flush(tlb)				flush_tlb_mm((tlb)->mm)
-
 #include <asm-generic/tlb.h>
 
 #define __pte_free_tlb(tlb, pte, address)	pte_free((tlb)->mm, pte)
