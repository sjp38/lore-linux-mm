Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2E18D003C
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:48:57 -0500 (EST)
Message-Id: <20110307172206.557810970@chello.nl>
Date: Mon, 07 Mar 2011 18:13:51 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 01/15] mm, powerpc: Dont use tlb_flush for external tlb flushes
References: <20110307171350.989666626@chello.nl>
Content-Disposition: inline; filename=powerpc64-tlb_flush.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Both sparc64 and powerpc64 use tlb_flush() to flush their respective
hash-tables which is entirely different from what
flush_tlb_range()/flush_tlb_mm() would do.

Powerpc64 already uses arch_*_lazy_mmu_mode() to batch and flush these
so any tlb_flush() caller should already find an empty batch. So
remove this functionality from tlb_flush().

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/powerpc/mm/tlb_hash64.c         |   10 ----------
 arch/sparc/include/asm/tlb_64.h      |    2 +-
 arch/sparc/include/asm/tlbflush_64.h |   13 +++++++++++++
 3 files changed, 14 insertions(+), 11 deletions(-)

Index: linux-2.6/arch/powerpc/mm/tlb_hash64.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/tlb_hash64.c
+++ linux-2.6/arch/powerpc/mm/tlb_hash64.c
@@ -155,16 +155,6 @@ void __flush_tlb_pending(struct ppc64_tl
 
 void tlb_flush(struct mmu_gather *tlb)
 {
-	struct ppc64_tlb_batch *tlbbatch = &get_cpu_var(ppc64_tlb_batch);
-
-	/* If there's a TLB batch pending, then we must flush it because the
-	 * pages are going to be freed and we really don't want to have a CPU
-	 * access a freed page because it has a stale TLB
-	 */
-	if (tlbbatch->index)
-		__flush_tlb_pending(tlbbatch);
-
-	put_cpu_var(ppc64_tlb_batch);
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
