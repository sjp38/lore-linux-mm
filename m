Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F1CEF6B251A
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 11:46:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j15-v6so1375542pfi.10
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 08:46:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w7-v6si1842346plq.198.2018.08.22.08.46.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 Aug 2018 08:46:00 -0700 (PDT)
Message-ID: <20180822154046.823850812@infradead.org>
Date: Wed, 22 Aug 2018 17:30:15 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for RCU_TABLE_FREE
References: <20180822153012.173508681@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: peterz@infradead.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, will.deacon@arm.com, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nicholas Piggin <npiggin@gmail.com>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

Jann reported that x86 was missing required TLB invalidates when he
hit the !*batch slow path in tlb_remove_table().

This is indeed the case; RCU_TABLE_FREE does not provide TLB (cache)
invalidates, the PowerPC-hash where this code originated and the
Sparc-hash where this was subsequently used did not need that. ARM
which later used this put an explicit TLB invalidate in their
__p*_free_tlb() functions, and PowerPC-radix followed that example.

But when we hooked up x86 we failed to consider this. Fix this by
(optionally) hooking tlb_remove_table() into the TLB invalidate code.

NOTE: s390 was also needing something like this and might now
      be able to use the generic code again.

Cc: stable@kernel.org
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Fixes: 9e52fc2b50de ("x86/mm: Enable RCU based page table freeing (CONFIG_HAVE_RCU_TABLE_FREE=y)")
Reported-by: Jann Horn <jannh@google.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/Kconfig     |    3 +++
 arch/x86/Kconfig |    1 +
 mm/memory.c      |   27 +++++++++++++++++++++++++--
 3 files changed, 29 insertions(+), 2 deletions(-)

--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -362,6 +362,9 @@ config HAVE_ARCH_JUMP_LABEL
 config HAVE_RCU_TABLE_FREE
 	bool
 
+config HAVE_RCU_TABLE_INVALIDATE
+	bool
+
 config ARCH_HAVE_NMI_SAFE_CMPXCHG
 	bool
 
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -180,6 +180,7 @@ config X86
 	select HAVE_PERF_REGS
 	select HAVE_PERF_USER_STACK_DUMP
 	select HAVE_RCU_TABLE_FREE
+	select HAVE_RCU_TABLE_INVALIDATE	if HAVE_RCU_TABLE_FREE
 	select HAVE_REGS_AND_STACK_ACCESS_API
 	select HAVE_RELIABLE_STACKTRACE		if X86_64 && (UNWINDER_FRAME_POINTER || UNWINDER_ORC) && STACK_VALIDATION
 	select HAVE_STACKPROTECTOR		if CC_HAS_SANE_STACKPROTECTOR
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -238,17 +238,22 @@ void arch_tlb_gather_mmu(struct mmu_gath
 	__tlb_reset_range(tlb);
 }
 
-static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
+static void __tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	if (!tlb->end)
 		return;
 
 	tlb_flush(tlb);
 	mmu_notifier_invalidate_range(tlb->mm, tlb->start, tlb->end);
+	__tlb_reset_range(tlb);
+}
+
+static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
+{
+	__tlb_flush_mmu_tlbonly(tlb);
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
 #endif
-	__tlb_reset_range(tlb);
 }
 
 static void tlb_flush_mmu_free(struct mmu_gather *tlb)
@@ -330,6 +335,21 @@ bool __tlb_remove_page_size(struct mmu_g
  * See the comment near struct mmu_table_batch.
  */
 
+/*
+ * If we want tlb_remove_table() to imply TLB invalidates.
+ */
+static inline void tlb_table_invalidate(struct mmu_gather *tlb)
+{
+#ifdef CONFIG_HAVE_RCU_TABLE_INVALIDATE
+	/*
+	 * Invalidate page-table caches used by hardware walkers. Then we still
+	 * need to RCU-sched wait while freeing the pages because software
+	 * walkers can still be in-flight.
+	 */
+	__tlb_flush_mmu_tlbonly(tlb);
+#endif
+}
+
 static void tlb_remove_table_smp_sync(void *arg)
 {
 	/* Simply deliver the interrupt */
@@ -366,6 +386,7 @@ void tlb_table_flush(struct mmu_gather *
 	struct mmu_table_batch **batch = &tlb->batch;
 
 	if (*batch) {
+		tlb_table_invalidate(tlb);
 		call_rcu_sched(&(*batch)->rcu, tlb_remove_table_rcu);
 		*batch = NULL;
 	}
@@ -378,11 +399,13 @@ void tlb_remove_table(struct mmu_gather
 	if (*batch == NULL) {
 		*batch = (struct mmu_table_batch *)__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
 		if (*batch == NULL) {
+			tlb_table_invalidate(tlb);
 			tlb_remove_table_one(table);
 			return;
 		}
 		(*batch)->nr = 0;
 	}
+
 	(*batch)->tables[(*batch)->nr++] = table;
 	if ((*batch)->nr == MAX_TABLE_BATCH)
 		tlb_table_flush(tlb);
