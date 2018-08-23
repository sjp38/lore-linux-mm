Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 35BA26B2C9C
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 19:31:48 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j17-v6so6230718oii.8
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 16:31:48 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i83-v6si4698846oib.278.2018.08.23.16.31.46
        for <linux-mm@kvack.org>;
        Thu, 23 Aug 2018 16:31:47 -0700 (PDT)
Date: Fri, 24 Aug 2018 00:31:43 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180823233142.GB4487@brain-police>
References: <20180822153012.173508681@infradead.org>
 <20180822154046.823850812@infradead.org>
 <20180822155527.GF24124@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180822155527.GF24124@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nicholas Piggin <npiggin@gmail.com>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, Aug 22, 2018 at 05:55:27PM +0200, Peter Zijlstra wrote:
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
> 
> Basically, using a patch like the below, would give your tlb_flush()
> information on if tables were removed or not.

Just to say that I have something up and running for arm64 based on this.
I'll post it once it's seen a bit more testing (either tomorrow or Monday).

Will
