Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 737048D003C
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 13:05:41 -0500 (EST)
Message-Id: <20110302180258.879537727@chello.nl>
Date: Wed, 02 Mar 2011 18:59:29 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 1/6] mm: Optimize fullmm TLB flushing
References: <20110302175928.022902359@chello.nl>
Content-Disposition: inline; filename=mmu_gather_fullmm.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

This originated from s390 which does something similar and would allow
s390 to use the generic TLB flushing code.

The idea is to flush the mm wide cache and tlb a priory and not bother
with multiple flushes if the batching isn't large enough.

This can be safely done since there cannot be any concurrency on this
mm, its either after the process died (exit) or in the middle of
execve where the thread switched to the new mm.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/asm-generic/tlb.h |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

Index: linux-2.6/include/asm-generic/tlb.h
===================================================================
--- linux-2.6.orig/include/asm-generic/tlb.h
+++ linux-2.6/include/asm-generic/tlb.h
@@ -149,6 +149,11 @@ tlb_gather_mmu(struct mmu_gather *tlb, s
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
 #endif
+
+	if (fullmm) {
+		flush_cache_mm(mm);
+		flush_tlb_mm(mm);
+	}
 }
 
 static inline void
@@ -156,13 +161,15 @@ tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
 
-	if (!tlb->need_flush)
-		return;
-	tlb->need_flush = 0;
-	tlb_flush(tlb);
+	if (!tlb->fullmm && tlb->need_flush) {
+		tlb->need_flush = 0;
+		tlb_flush(tlb);
+	}
+
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
 #endif
+
 	if (tlb_fast_mode(tlb))
 		return;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
