Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 4E2526B0074
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:50 -0400 (EDT)
Message-Id: <20120627212830.911507676@chello.nl>
Date: Wed, 27 Jun 2012 23:15:45 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 05/20] mm, powerpc: Dont use tlb_flush for external tlb flushes
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=powerpc64-tlb_flush.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

Both sparc64 and powerpc64 use tlb_flush() to flush their respective
hash-tables which is entirely different from what
flush_tlb_range()/flush_tlb_mm() would do.

Powerpc64 already uses arch_*_lazy_mmu_mode() to batch and flush these
so any tlb_flush() caller should already find an empty batch. So
remove this functionality from tlb_flush().

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/powerpc/mm/tlb_hash64.c |   10 ----------
 1 file changed, 10 deletions(-)
--- a/arch/powerpc/mm/tlb_hash64.c
+++ b/arch/powerpc/mm/tlb_hash64.c
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
