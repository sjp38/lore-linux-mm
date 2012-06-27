Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id A9A296B006E
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:23 -0400 (EDT)
Message-Id: <20120627212832.018140861@chello.nl>
Date: Wed, 27 Jun 2012 23:16:00 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 20/20] mm, xtensa: Convert xtensa to generic tlb
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=xtensa-mmu_range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

Cc: Chris Zankel <chris@zankel.net>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/xtensa/Kconfig           |    1 +
 arch/xtensa/include/asm/tlb.h |   23 -----------------------
 arch/xtensa/mm/tlb.c          |    2 +-
 3 files changed, 2 insertions(+), 24 deletions(-)
--- a/arch/xtensa/Kconfig
+++ b/arch/xtensa/Kconfig
@@ -10,6 +10,7 @@ config XTENSA
 	select HAVE_GENERIC_HARDIRQS
 	select GENERIC_IRQ_SHOW
 	select GENERIC_CPU_DEVICES
+	select HAVE_MMU_GATHER_RANGE
 	help
 	  Xtensa processors are 32-bit RISC machines designed by Tensilica
 	  primarily for embedded systems.  These processors are both
--- a/arch/xtensa/include/asm/tlb.h
+++ b/arch/xtensa/include/asm/tlb.h
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
--- a/arch/xtensa/mm/tlb.c
+++ b/arch/xtensa/mm/tlb.c
@@ -63,7 +63,7 @@ void flush_tlb_all (void)
 void flush_tlb_mm(struct mm_struct *mm)
 {
 	if (mm == current->active_mm) {
-		int flags;
+		unsigned long flags;
 		local_save_flags(flags);
 		__get_new_mmu_context(mm);
 		__load_mmu_context(mm);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
