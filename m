Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 519016B252E
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 11:55:39 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j15-v6so1395573pfi.10
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 08:55:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 2-v6si1884074plb.444.2018.08.22.08.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 Aug 2018 08:55:38 -0700 (PDT)
Date: Wed, 22 Aug 2018 17:55:27 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180822155527.GF24124@hirez.programming.kicks-ass.net>
References: <20180822153012.173508681@infradead.org>
 <20180822154046.823850812@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180822154046.823850812@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: luto@kernel.org, x86@kernel.org, bp@alien8.de, will.deacon@arm.com, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nicholas Piggin <npiggin@gmail.com>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, Aug 22, 2018 at 05:30:15PM +0200, Peter Zijlstra wrote:
> ARM
> which later used this put an explicit TLB invalidate in their
> __p*_free_tlb() functions, and PowerPC-radix followed that example.

> +/*
> + * If we want tlb_remove_table() to imply TLB invalidates.
> + */
> +static inline void tlb_table_invalidate(struct mmu_gather *tlb)
> +{
> +#ifdef CONFIG_HAVE_RCU_TABLE_INVALIDATE
> +	/*
> +	 * Invalidate page-table caches used by hardware walkers. Then we still
> +	 * need to RCU-sched wait while freeing the pages because software
> +	 * walkers can still be in-flight.
> +	 */
> +	__tlb_flush_mmu_tlbonly(tlb);
> +#endif
> +}


Nick, Will is already looking at using this to remove the synchronous
invalidation from __p*_free_tlb() for ARM, could you have a look to see
if PowerPC-radix could benefit from that too?

Basically, using a patch like the below, would give your tlb_flush()
information on if tables were removed or not.

---

--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -96,12 +96,22 @@ struct mmu_gather {
 #endif
 	unsigned long		start;
 	unsigned long		end;
-	/* we are in the middle of an operation to clear
-	 * a full mm and can make some optimizations */
-	unsigned int		fullmm : 1,
-	/* we have performed an operation which
-	 * requires a complete flush of the tlb */
-				need_flush_all : 1;
+	/*
+	 * we are in the middle of an operation to clear
+	 * a full mm and can make some optimizations
+	 */
+	unsigned int		fullmm : 1;
+
+	/*
+	 * we have performed an operation which
+	 * requires a complete flush of the tlb
+	 */
+	unsigned int		need_flush_all : 1;
+
+	/*
+	 * we have removed page directories
+	 */
+	unsigned int		freed_tables : 1;
 
 	struct mmu_gather_batch *active;
 	struct mmu_gather_batch	local;
@@ -136,6 +146,7 @@ static inline void __tlb_reset_range(str
 		tlb->start = TASK_SIZE;
 		tlb->end = 0;
 	}
+	tlb->freed_tables = 0;
 }
 
 static inline void tlb_remove_page_size(struct mmu_gather *tlb,
@@ -269,6 +280,7 @@ static inline void tlb_remove_check_page
 #define pte_free_tlb(tlb, ptep, address)			\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
+		tlb->freed_tables = 1;			\
 		__pte_free_tlb(tlb, ptep, address);		\
 	} while (0)
 #endif
@@ -276,7 +288,8 @@ static inline void tlb_remove_check_page
 #ifndef pmd_free_tlb
 #define pmd_free_tlb(tlb, pmdp, address)			\
 	do {							\
-		__tlb_adjust_range(tlb, address, PAGE_SIZE);		\
+		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
+		tlb->freed_tables = 1;			\
 		__pmd_free_tlb(tlb, pmdp, address);		\
 	} while (0)
 #endif
@@ -286,6 +299,7 @@ static inline void tlb_remove_check_page
 #define pud_free_tlb(tlb, pudp, address)			\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
+		tlb->freed_tables = 1;			\
 		__pud_free_tlb(tlb, pudp, address);		\
 	} while (0)
 #endif
@@ -295,7 +309,8 @@ static inline void tlb_remove_check_page
 #ifndef p4d_free_tlb
 #define p4d_free_tlb(tlb, pudp, address)			\
 	do {							\
-		__tlb_adjust_range(tlb, address, PAGE_SIZE);		\
+		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
+		tlb->freed_tables = 1;			\
 		__p4d_free_tlb(tlb, pudp, address);		\
 	} while (0)
 #endif
