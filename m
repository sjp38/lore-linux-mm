Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id ABD366B401E
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 07:01:08 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w80-v6so7272023wmw.3
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 04:01:08 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k15-v6si10525807wrm.115.2018.08.27.04.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 Aug 2018 04:01:06 -0700 (PDT)
Date: Mon, 27 Aug 2018 13:00:17 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180827110017.GO24142@hirez.programming.kicks-ass.net>
References: <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
 <20180823133958.GA1496@brain-police>
 <20180824084717.GK24124@hirez.programming.kicks-ass.net>
 <20180824113214.GK24142@hirez.programming.kicks-ass.net>
 <20180824113953.GL24142@hirez.programming.kicks-ass.net>
 <20180827150008.13bce08f@roar.ozlabs.ibm.com>
 <20180827074701.GW24124@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180827074701.GW24124@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, jejb@parisc-linux.org, vgupta@synopsys.com

On Mon, Aug 27, 2018 at 09:47:01AM +0200, Peter Zijlstra wrote:
> And there's only like 4 architectures that still have a custom
> mmu_gather:
> 
>   - sh
>   - arm
>   - ia64
>   - s390
> 
> sh is trivial, arm seems doable, with a bit of luck we can do 'rm -rf
> arch/ia64' leaving us with s390.

The one obvious thing SH and ARM want is a sensible default for
tlb_start_vma(). (also: https://lkml.org/lkml/2004/1/15/6 )

The below make tlb_start_vma() default to flush_cache_range(), which
should be right and sufficient. The only exceptions that I found where
(oddly):

  - m68k-mmu
  - sparc64
  - unicore

Those architectures appear to have a non-NOP flush_cache_range(), but
their current tlb_start_vma() does not call it.

Furthermore, I think tlb_flush() is broken on arc and parisc; in
particular they don't appear to have any TLB invalidate for the
shift_arg_pages() case, where we do not call tlb_*_vma() and fullmm=0.

Possibly shift_arg_pages() should be fixed instead.

Some archs (nds32,sparc32) avoid this by having an unconditional
flush_tlb_mm() in tlb_flush(), which seems somewhat suboptimal if you
have flush_tlb_range().  TLB_FLUSH_VMA() might be an option, however
hideous it is.

---

diff --git a/arch/arc/include/asm/tlb.h b/arch/arc/include/asm/tlb.h
index a9db5f62aaf3..7af2b373ebe7 100644
--- a/arch/arc/include/asm/tlb.h
+++ b/arch/arc/include/asm/tlb.h
@@ -23,15 +23,6 @@ do {						\
  *
  * Note, read http://lkml.org/lkml/2004/1/15/6
  */
-#ifndef CONFIG_ARC_CACHE_VIPT_ALIASING
-#define tlb_start_vma(tlb, vma)
-#else
-#define tlb_start_vma(tlb, vma)						\
-do {									\
-	if (!tlb->fullmm)						\
-		flush_cache_range(vma, vma->vm_start, vma->vm_end);	\
-} while(0)
-#endif
 
 #define tlb_end_vma(tlb, vma)						\
 do {									\
diff --git a/arch/mips/include/asm/tlb.h b/arch/mips/include/asm/tlb.h
index b6823b9e94da..9d04b4649692 100644
--- a/arch/mips/include/asm/tlb.h
+++ b/arch/mips/include/asm/tlb.h
@@ -5,16 +5,6 @@
 #include <asm/cpu-features.h>
 #include <asm/mipsregs.h>
 
-/*
- * MIPS doesn't need any special per-pte or per-vma handling, except
- * we need to flush cache for area to be unmapped.
- */
-#define tlb_start_vma(tlb, vma)					\
-	do {							\
-		if (!tlb->fullmm)				\
-			flush_cache_range(vma, vma->vm_start, vma->vm_end); \
-	}  while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
 /*
diff --git a/arch/nds32/include/asm/tlb.h b/arch/nds32/include/asm/tlb.h
index b35ae5eae3ab..0bf7c9482381 100644
--- a/arch/nds32/include/asm/tlb.h
+++ b/arch/nds32/include/asm/tlb.h
@@ -4,12 +4,6 @@
 #ifndef __ASMNDS32_TLB_H
 #define __ASMNDS32_TLB_H
 
-#define tlb_start_vma(tlb,vma)						\
-	do {								\
-		if (!tlb->fullmm)					\
-			flush_cache_range(vma, vma->vm_start, vma->vm_end); \
-	} while (0)
-
 #define tlb_end_vma(tlb,vma)				\
 	do { 						\
 		if(!tlb->fullmm)			\
diff --git a/arch/nios2/include/asm/tlb.h b/arch/nios2/include/asm/tlb.h
index d3bc648e08b5..9b518c6d0f62 100644
--- a/arch/nios2/include/asm/tlb.h
+++ b/arch/nios2/include/asm/tlb.h
@@ -15,16 +15,6 @@
 
 extern void set_mmu_pid(unsigned long pid);
 
-/*
- * NiosII doesn't need any special per-pte or per-vma handling, except
- * we need to flush cache for the area to be unmapped.
- */
-#define tlb_start_vma(tlb, vma)					\
-	do {							\
-		if (!tlb->fullmm)				\
-			flush_cache_range(vma, vma->vm_start, vma->vm_end); \
-	}  while (0)
-
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
 
diff --git a/arch/parisc/include/asm/tlb.h b/arch/parisc/include/asm/tlb.h
index 0c881e74d8a6..b1984f9cd3af 100644
--- a/arch/parisc/include/asm/tlb.h
+++ b/arch/parisc/include/asm/tlb.h
@@ -7,11 +7,6 @@ do {	if ((tlb)->fullmm)		\
 		flush_tlb_mm((tlb)->mm);\
 } while (0)
 
-#define tlb_start_vma(tlb, vma) \
-do {	if (!(tlb)->fullmm)	\
-		flush_cache_range(vma, vma->vm_start, vma->vm_end); \
-} while (0)
-
 #define tlb_end_vma(tlb, vma)	\
 do {	if (!(tlb)->fullmm)	\
 		flush_tlb_range(vma, vma->vm_start, vma->vm_end); \
diff --git a/arch/sparc/include/asm/tlb_32.h b/arch/sparc/include/asm/tlb_32.h
index 343cea19e573..68d817273de8 100644
--- a/arch/sparc/include/asm/tlb_32.h
+++ b/arch/sparc/include/asm/tlb_32.h
@@ -2,11 +2,6 @@
 #ifndef _SPARC_TLB_H
 #define _SPARC_TLB_H
 
-#define tlb_start_vma(tlb, vma) \
-do {								\
-	flush_cache_range(vma, vma->vm_start, vma->vm_end);	\
-} while (0)
-
 #define tlb_end_vma(tlb, vma) \
 do {								\
 	flush_tlb_range(vma, vma->vm_start, vma->vm_end);	\
diff --git a/arch/xtensa/include/asm/tlb.h b/arch/xtensa/include/asm/tlb.h
index 0d766f9c1083..1a93e350382e 100644
--- a/arch/xtensa/include/asm/tlb.h
+++ b/arch/xtensa/include/asm/tlb.h
@@ -16,19 +16,10 @@
 
 #if (DCACHE_WAY_SIZE <= PAGE_SIZE)
 
-/* Note, read http://lkml.org/lkml/2004/1/15/6 */
-
-# define tlb_start_vma(tlb,vma)			do { } while (0)
 # define tlb_end_vma(tlb,vma)			do { } while (0)
 
 #else
 
-# define tlb_start_vma(tlb, vma)					      \
-	do {								      \
-		if (!tlb->fullmm)					      \
-			flush_cache_range(vma, vma->vm_start, vma->vm_end);   \
-	} while(0)
-
 # define tlb_end_vma(tlb, vma)						      \
 	do {								      \
 		if (!tlb->fullmm)					      \
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index e811ef7b8350..1d037fd5bb7a 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -181,19 +181,21 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
  * the vmas are adjusted to only cover the region to be torn down.
  */
 #ifndef tlb_start_vma
-#define tlb_start_vma(tlb, vma) do { } while (0)
+#define tlb_start_vma(tlb, vma)						\
+do {									\
+	if (!tlb->fullmm)						\
+		flush_cache_range(vma, vma->vm_start, vma->vm_end);	\
+} while (0)
 #endif
 
-#define __tlb_end_vma(tlb, vma)					\
-	do {							\
-		if (!tlb->fullmm && tlb->end) {			\
-			tlb_flush(tlb);				\
-			__tlb_reset_range(tlb);			\
-		}						\
-	} while (0)
-
 #ifndef tlb_end_vma
-#define tlb_end_vma	__tlb_end_vma
+#define tlb_end_vma(tlb, vma)						\
+	do {								\
+		if (!tlb->fullmm && tlb->end) {				\
+			tlb_flush(tlb);					\
+			__tlb_reset_range(tlb);				\
+		}							\
+	} while (0)
 #endif
 
 #ifndef __tlb_remove_tlb_entry
