Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 5DAAA6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:14 -0400 (EDT)
Message-Id: <20120627212831.137126018@chello.nl>
Date: Wed, 27 Jun 2012 23:15:48 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 08/20] mm: Optimize fullmm TLB flushing
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=mmu_gather_fullmm.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

This originated from s390 which does something similar and would allow
s390 to use the generic TLB flushing code.

The idea is to flush the mm wide cache and tlb a priory and not bother
with multiple flushes if the batching isn't large enough.

This can be safely done since there cannot be any concurrency on this
mm, its either after the process died (exit) or in the middle of
execve where the thread switched to the new mm.

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/memory.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -215,16 +215,22 @@ void tlb_gather_mmu(struct mmu_gather *t
 	tlb->active     = &tlb->local;
 
 	tlb_table_init(tlb);
+
+	if (fullmm) {
+		flush_cache_mm(mm);
+		flush_tlb_mm(mm);
+	}
 }
 
 void tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
 
-	if (!tlb->need_flush)
-		return;
-	tlb->need_flush = 0;
-	flush_tlb_mm(tlb->mm);
+	if (!tlb->fullmm && tlb->need_flush) {
+		tlb->need_flush = 0;
+		flush_tlb_mm(tlb->mm);
+	}
+
 	tlb_table_flush(tlb);
 
 	if (tlb_fast_mode(tlb))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
