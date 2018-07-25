Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7536B02B8
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 10:06:56 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r20-v6so4246174pgv.20
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:06:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h6-v6sor3627918pgb.415.2018.07.25.07.06.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 07:06:55 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH 1/4] mm: move tlb_table_flush to tlb_flush_mmu_free
Date: Thu, 26 Jul 2018 00:06:38 +1000
Message-Id: <20180725140641.30372-2-npiggin@gmail.com>
In-Reply-To: <20180725140641.30372-1-npiggin@gmail.com>
References: <20180725140641.30372-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org

There is no need to call this from tlb_flush_mmu_tlbonly, it
logically belongs with tlb_flush_mmu_free. This allows some
code consolidation with a subsequent fix.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 mm/memory.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 7206a634270b..bc053d5e9d41 100644
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
