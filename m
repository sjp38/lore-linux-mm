Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D80BB6B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 13:38:17 -0500 (EST)
Message-Id: <20110125174907.220115681@chello.nl>
Date: Tue, 25 Jan 2011 18:31:12 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 01/25] tile: Fix __pte_free_tlb
References: <20110125173111.720927511@chello.nl>
Content-Disposition: inline; filename=tile-fix-pte_free_tlb.patch
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Chris Metcalf <cmetcalf@tilera.com>
List-ID: <linux-mm.kvack.org>

Tile's __pte_free_tlb() implementation makes assumptions about the
generic mmu_gather implementation, cure this ;-)

[ Chris, from a quick look L2_USER_PGTABLE_PAGES is something like:
  1 << (24 - 16 + 3), which looks awefully large for an on-stack
  array. ]

Cc: Chris Metcalf <cmetcalf@tilera.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/tile/mm/pgtable.c |   15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

Index: linux-2.6/arch/tile/mm/pgtable.c
===================================================================
--- linux-2.6.orig/arch/tile/mm/pgtable.c
+++ linux-2.6/arch/tile/mm/pgtable.c
@@ -252,19 +252,8 @@ void __pte_free_tlb(struct mmu_gather *t
 	int i;
 
 	pgtable_page_dtor(pte);
-	tlb->need_flush = 1;
-	if (tlb_fast_mode(tlb)) {
-		struct page *pte_pages[L2_USER_PGTABLE_PAGES];
-		for (i = 0; i < L2_USER_PGTABLE_PAGES; ++i)
-			pte_pages[i] = pte + i;
-		free_pages_and_swap_cache(pte_pages, L2_USER_PGTABLE_PAGES);
-		return;
-	}
-	for (i = 0; i < L2_USER_PGTABLE_PAGES; ++i) {
-		tlb->pages[tlb->nr++] = pte + i;
-		if (tlb->nr >= FREE_PTE_NR)
-			tlb_flush_mmu(tlb, 0, 0);
-	}
+	for (i = 0; i < L2_USER_PGTABLE_PAGES; ++i)
+		tlb_remove_page(tlb, pte + i);
 }
 
 #ifndef __tilegx__


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
