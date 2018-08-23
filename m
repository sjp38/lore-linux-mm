Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83A5B6B27EC
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 23:45:34 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id r14-v6so1870207pls.23
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 20:45:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z24-v6sor1090889pfe.5.2018.08.22.20.45.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 20:45:33 -0700 (PDT)
Date: Thu, 23 Aug 2018 13:45:25 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
In-Reply-To: <20180822155527.GF24124@hirez.programming.kicks-ass.net>
References: <20180822153012.173508681@infradead.org>
	<20180822154046.823850812@infradead.org>
	<20180822155527.GF24124@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, will.deacon@arm.com, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, 22 Aug 2018 17:55:27 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Wed, Aug 22, 2018 at 05:30:15PM +0200, Peter Zijlstra wrote:
> > ARM
> > which later used this put an explicit TLB invalidate in their
> > __p*_free_tlb() functions, and PowerPC-radix followed that example.  
> 
> > +/*
> > + * If we want tlb_remove_table() to imply TLB invalidates.
> > + */
> > +static inline void tlb_table_invalidate(struct mmu_gather *tlb)
> > +{
> > +#ifdef CONFIG_HAVE_RCU_TABLE_INVALIDATE
> > +	/*
> > +	 * Invalidate page-table caches used by hardware walkers. Then we still
> > +	 * need to RCU-sched wait while freeing the pages because software
> > +	 * walkers can still be in-flight.
> > +	 */
> > +	__tlb_flush_mmu_tlbonly(tlb);
> > +#endif
> > +}  
> 
> 
> Nick, Will is already looking at using this to remove the synchronous
> invalidation from __p*_free_tlb() for ARM, could you have a look to see
> if PowerPC-radix could benefit from that too?

powerpc/radix has no such issue, it already does this tracking.

We were discussing this a couple of months ago, I wasn't aware of ARM's
issue but I suggested x86 could go the same way as powerpc. Would have
been good to get some feedback on some of the proposed approaches there.
Because it's not just pwc tracking but if you do this you don't need
those silly hacks in generic code to expand the TLB address range
either.

So powerpc has no fundamental problem with making this stuff generic.
If you need a fix for x86 and ARM for this merge window though, I would
suggest just copying what powerpc already has. Next time we can
consider consolidating them all into generic code.

Thanks,
Nick


> 
> Basically, using a patch like the below, would give your tlb_flush()
> information on if tables were removed or not.
> 
> ---
> 
> --- a/include/asm-generic/tlb.h
> +++ b/include/asm-generic/tlb.h
> @@ -96,12 +96,22 @@ struct mmu_gather {
>  #endif
>  	unsigned long		start;
>  	unsigned long		end;
> -	/* we are in the middle of an operation to clear
> -	 * a full mm and can make some optimizations */
> -	unsigned int		fullmm : 1,
> -	/* we have performed an operation which
> -	 * requires a complete flush of the tlb */
> -				need_flush_all : 1;
> +	/*
> +	 * we are in the middle of an operation to clear
> +	 * a full mm and can make some optimizations
> +	 */
> +	unsigned int		fullmm : 1;
> +
> +	/*
> +	 * we have performed an operation which
> +	 * requires a complete flush of the tlb
> +	 */
> +	unsigned int		need_flush_all : 1;
> +
> +	/*
> +	 * we have removed page directories
> +	 */
> +	unsigned int		freed_tables : 1;
>  
>  	struct mmu_gather_batch *active;
>  	struct mmu_gather_batch	local;
> @@ -136,6 +146,7 @@ static inline void __tlb_reset_range(str
>  		tlb->start = TASK_SIZE;
>  		tlb->end = 0;
>  	}
> +	tlb->freed_tables = 0;
>  }
>  
>  static inline void tlb_remove_page_size(struct mmu_gather *tlb,
> @@ -269,6 +280,7 @@ static inline void tlb_remove_check_page
>  #define pte_free_tlb(tlb, ptep, address)			\
>  	do {							\
>  		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
> +		tlb->freed_tables = 1;			\
>  		__pte_free_tlb(tlb, ptep, address);		\
>  	} while (0)
>  #endif
> @@ -276,7 +288,8 @@ static inline void tlb_remove_check_page
>  #ifndef pmd_free_tlb
>  #define pmd_free_tlb(tlb, pmdp, address)			\
>  	do {							\
> -		__tlb_adjust_range(tlb, address, PAGE_SIZE);		\
> +		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
> +		tlb->freed_tables = 1;			\
>  		__pmd_free_tlb(tlb, pmdp, address);		\
>  	} while (0)
>  #endif
> @@ -286,6 +299,7 @@ static inline void tlb_remove_check_page
>  #define pud_free_tlb(tlb, pudp, address)			\
>  	do {							\
>  		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
> +		tlb->freed_tables = 1;			\
>  		__pud_free_tlb(tlb, pudp, address);		\
>  	} while (0)
>  #endif
> @@ -295,7 +309,8 @@ static inline void tlb_remove_check_page
>  #ifndef p4d_free_tlb
>  #define p4d_free_tlb(tlb, pudp, address)			\
>  	do {							\
> -		__tlb_adjust_range(tlb, address, PAGE_SIZE);		\
> +		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
> +		tlb->freed_tables = 1;			\
>  		__p4d_free_tlb(tlb, pudp, address);		\
>  	} while (0)
>  #endif
