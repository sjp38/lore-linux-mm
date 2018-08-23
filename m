Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8E46B2924
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 04:47:29 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id bg5-v6so2230177plb.20
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 01:47:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v2-v6sor1111968pgt.196.2018.08.23.01.47.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 01:47:28 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH 1/2] mm: move tlb_table_flush to tlb_flush_mmu_free
Date: Thu, 23 Aug 2018 18:47:08 +1000
Message-Id: <20180823084709.19717-2-npiggin@gmail.com>
In-Reply-To: <20180823084709.19717-1-npiggin@gmail.com>
References: <20180823084709.19717-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, will.deacon@arm.com, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org

There is no need to call this from tlb_flush_mmu_tlbonly, it
logically belongs with tlb_flush_mmu_free. This allows some
code consolidation with a subsequent fix.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 mm/memory.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 19f47d7b9b86..7c58310734eb 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -245,9 +245,6 @@ static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 
 	tlb_flush(tlb);
 	mmu_notifier_invalidate_range(tlb->mm, tlb->start, tlb->end);
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb_table_flush(tlb);
-#endif
 	__tlb_reset_range(tlb);
 }
 
@@ -255,6 +252,9 @@ static void tlb_flush_mmu_free(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
 
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	tlb_table_flush(tlb);
+#endif
 	for (batch = &tlb->local; batch && batch->nr; batch = batch->next) {
 		free_pages_and_swap_cache(batch->pages, batch->nr);
 		batch->nr = 0;
-- 
2.17.0
