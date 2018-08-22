Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7ACA46B2521
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 11:46:58 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m129-v6so2086860wma.8
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 08:46:58 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 64-v6si1699618wrf.122.2018.08.22.08.46.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 Aug 2018 08:46:57 -0700 (PDT)
Message-ID: <20180822154046.772017055@infradead.org>
Date: Wed, 22 Aug 2018 17:30:14 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 2/4] mm/tlb: Remove tlb_remove_table() non-concurrent condition
References: <20180822153012.173508681@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: peterz@infradead.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, will.deacon@arm.com, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nicholas Piggin <npiggin@gmail.com>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

Will noted that only checking mm_users is incorrect; we should also
check mm_count in order to cover CPUs that have a lazy reference to
this mm (and could do speculative TLB operations).

If removing this turns out to be a performance issue, we can
re-instate a more complete check, but in tlb_table_flush() eliding the
call_rcu_sched().

Cc: stable@kernel.org
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Fixes: 267239116987 ("mm, powerpc: move the RCU page-table freeing into generic code")
Reported-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 mm/memory.c |    9 ---------
 1 file changed, 9 deletions(-)

--- a/mm/memory.c
+++ b/mm/memory.c
@@ -375,15 +375,6 @@ void tlb_remove_table(struct mmu_gather
 {
 	struct mmu_table_batch **batch = &tlb->batch;
 
-	/*
-	 * When there's less then two users of this mm there cannot be a
-	 * concurrent page-table walk.
-	 */
-	if (atomic_read(&tlb->mm->mm_users) < 2) {
-		__tlb_remove_table(table);
-		return;
-	}
-
 	if (*batch == NULL) {
 		*batch = (struct mmu_table_batch *)__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
 		if (*batch == NULL) {
