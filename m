Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 89C746B0062
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:14 -0400 (EDT)
Message-Id: <20120627212830.984924257@chello.nl>
Date: Wed, 27 Jun 2012 23:15:46 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 06/20] mm, sparc64: Dont use tlb_flush for external tlb flushes
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=sparc64-tlb_flush.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

Both sparc64 and powerpc64 use tlb_flush() to flush their respective
hash-tables which is entirely different from what
flush_tlb_range()/flush_tlb_mm() would do.

Powerpc64 already uses arch_*_lazy_mmu_mode() to batch and flush these
so any tlb_flush() caller should already find an empty batch, make
sparc64 do the same.

This ensures all platforms now have a tlb_flush() implementation that
is either flush_tlb_mm() or flush_tlb_range().

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/sparc/Makefile                  |    1 +
 arch/sparc/include/asm/tlb_64.h      |    2 +-
 arch/sparc/include/asm/tlbflush_64.h |   11 +++++++++++
 3 files changed, 13 insertions(+), 1 deletion(-)
--- a/arch/sparc/Makefile
+++ b/arch/sparc/Makefile
@@ -37,6 +37,7 @@ LDFLAGS       := -m elf64_sparc
 export BITS   := 64
 UTS_MACHINE   := sparc64
 
+KBUILD_CPPFLAGS += -D__HAVE_ARCH_ENTER_LAZY_MMU_MODE
 KBUILD_CFLAGS += -m64 -pipe -mno-fpu -mcpu=ultrasparc -mcmodel=medlow
 KBUILD_CFLAGS += -ffixed-g4 -ffixed-g5 -fcall-used-g7 -Wno-sign-compare
 KBUILD_CFLAGS += -Wa,--undeclared-regs
--- a/arch/sparc/include/asm/tlb_64.h
+++ b/arch/sparc/include/asm/tlb_64.h
@@ -25,7 +25,7 @@ extern void flush_tlb_pending(void);
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
-#define tlb_flush(tlb)	flush_tlb_pending()
+#define tlb_flush(tlb)	do { } while (0)
 
 #include <asm-generic/tlb.h>
 
--- a/arch/sparc/include/asm/tlbflush_64.h
+++ b/arch/sparc/include/asm/tlbflush_64.h
@@ -26,6 +26,17 @@ extern void flush_tlb_pending(void);
 #define flush_tlb_page(vma,addr)	flush_tlb_pending()
 #define flush_tlb_mm(mm)		flush_tlb_pending()
 
+static inline void arch_enter_lazy_mmu_mode(void)
+{
+}
+
+static inline void arch_leave_lazy_mmu_mode(void)
+{
+	flush_tlb_pending();
+}
+
+#define arch_flush_lazy_mmu_mode()      do {} while (0)
+
 /* Local cpu only.  */
 extern void __flush_tlb_all(void);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
