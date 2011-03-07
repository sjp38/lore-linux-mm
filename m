Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 289BF8D003C
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:49:21 -0500 (EST)
Message-Id: <20110307172206.624713531@chello.nl>
Date: Mon, 07 Mar 2011 18:13:52 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 02/15] mm, sparc64: Dont use tlb_flush for external tlb flushes
References: <20110307171350.989666626@chello.nl>
Content-Disposition: inline; filename=sparc64-tlb_flush.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

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
 arch/powerpc/mm/tlb_hash64.c         |   10 ----------
 arch/sparc/include/asm/tlb_64.h      |    2 +-
 arch/sparc/include/asm/tlbflush_64.h |   13 +++++++++++++
 3 files changed, 14 insertions(+), 11 deletions(-)

Index: linux-2.6/arch/sparc/include/asm/tlbflush_64.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/tlbflush_64.h
+++ linux-2.6/arch/sparc/include/asm/tlbflush_64.h
@@ -26,6 +26,19 @@ extern void flush_tlb_pending(void);
 #define flush_tlb_page(vma,addr)	flush_tlb_pending()
 #define flush_tlb_mm(mm)		flush_tlb_pending()
 
+#define __HAVE_ARCH_ENTER_LAZY_MMU_MODE
+
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
 
Index: linux-2.6/arch/sparc/include/asm/tlb_64.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/tlb_64.h
+++ linux-2.6/arch/sparc/include/asm/tlb_64.h
@@ -25,7 +25,7 @@ extern void flush_tlb_pending(void);
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
-#define tlb_flush(tlb)	flush_tlb_pending()
+#define tlb_flush(tlb)	do { } while (0)
 
 #include <asm-generic/tlb.h>
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
