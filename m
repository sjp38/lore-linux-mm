Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B5D1D8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:48:50 -0500 (EST)
Message-Id: <20110307172207.513560565@chello.nl>
Date: Mon, 07 Mar 2011 18:14:05 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 15/15] mm, xtensa: Convert xtensa to generic tlb
References: <20110307171350.989666626@chello.nl>
Content-Disposition: inline; filename=xtensa-mmu_range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Chris Zankel <chris@zankel.net>

Cc: Chris Zankel <chris@zankel.net>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/xtensa/Kconfig           |    1 +
 arch/xtensa/include/asm/tlb.h |   23 -----------------------
 2 files changed, 1 insertion(+), 23 deletions(-)

Index: linux-2.6/arch/xtensa/Kconfig
===================================================================
--- linux-2.6.orig/arch/xtensa/Kconfig
+++ linux-2.6/arch/xtensa/Kconfig
@@ -7,6 +7,7 @@ config ZONE_DMA
 config XTENSA
 	def_bool y
 	select HAVE_IDE
+	select HAVE_MMU_GATHER_RANGE
 	help
 	  Xtensa processors are 32-bit RISC machines designed by Tensilica
 	  primarily for embedded systems.  These processors are both
Index: linux-2.6/arch/xtensa/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/xtensa/include/asm/tlb.h
+++ linux-2.6/arch/xtensa/include/asm/tlb.h
@@ -14,29 +14,6 @@
 #include <asm/cache.h>
 #include <asm/page.h>
 
-#if (DCACHE_WAY_SIZE <= PAGE_SIZE)
-
-/* Note, read http://lkml.org/lkml/2004/1/15/6 */
-
-# define tlb_start_vma(tlb,vma)			do { } while (0)
-# define tlb_end_vma(tlb,vma)			do { } while (0)
-
-#else
-
-# define tlb_start_vma(tlb, vma)					      \
-	do {								      \
-		if (!tlb->fullmm)					      \
-			flush_cache_range(vma, vma->vm_start, vma->vm_end);   \
-	} while(0)
-
-# define tlb_end_vma(tlb, vma)						      \
-	do {								      \
-		if (!tlb->fullmm)					      \
-			flush_tlb_range(vma, vma->vm_start, vma->vm_end);     \
-	} while(0)
-
-#endif
-
 #define __tlb_remove_tlb_entry(tlb,pte,addr)	do { } while (0)
 
 #include <asm-generic/tlb.h>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
