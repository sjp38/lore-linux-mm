Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D08F6B50DD
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 06:24:33 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m4-v6so4829757pgq.19
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 03:24:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x9-v6si5731671plr.160.2018.08.30.03.24.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 Aug 2018 03:24:32 -0700 (PDT)
Date: Thu, 30 Aug 2018 12:23:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180830102354.GY24124@hirez.programming.kicks-ass.net>
References: <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
 <20180823133958.GA1496@brain-police>
 <20180824084717.GK24124@hirez.programming.kicks-ass.net>
 <20180824113214.GK24142@hirez.programming.kicks-ass.net>
 <20180824113953.GL24142@hirez.programming.kicks-ass.net>
 <20180827150008.13bce08f@roar.ozlabs.ibm.com>
 <20180827074701.GW24124@hirez.programming.kicks-ass.net>
 <20180827110017.GO24142@hirez.programming.kicks-ass.net>
 <C2D7FE5348E1B147BCA15975FBA23075012B090CA3@us01wembx1.internal.synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C2D7FE5348E1B147BCA15975FBA23075012B090CA3@us01wembx1.internal.synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Nicholas Piggin <npiggin@gmail.com>, Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, "jejb@parisc-linux.org" <jejb@parisc-linux.org>

On Thu, Aug 30, 2018 at 12:13:50AM +0000, Vineet Gupta wrote:
> On 08/27/2018 04:00 AM, Peter Zijlstra wrote:
> >
> > The one obvious thing SH and ARM want is a sensible default for
> > tlb_start_vma(). (also: https://lkml.org/lkml/2004/1/15/6 )
> >
> > The below make tlb_start_vma() default to flush_cache_range(), which
> > should be right and sufficient. The only exceptions that I found where
> > (oddly):
> >
> >   - m68k-mmu
> >   - sparc64
> >   - unicore
> >
> > Those architectures appear to have a non-NOP flush_cache_range(), but
> > their current tlb_start_vma() does not call it.
> 
> So indeed we follow the DaveM's insight from 2004 about tlb_{start,end}_vma() and
> those are No-ops for ARC for the general case. For the historic VIPT aliasing
> dcache they are what they should be per 2004 link above - I presume that is all
> hunky dory with you ?

Yep, I was just confused about those 3 architectures having
flush_cache_range() but not calling it from tlb_start_vma(). The regular
VIPT aliasing thing is all good. And not having them is also fine.

> > Furthermore, I think tlb_flush() is broken on arc and parisc; in
> > particular they don't appear to have any TLB invalidate for the
> > shift_arg_pages() case, where we do not call tlb_*_vma() and fullmm=0.
> 
> Care to explain this issue a bit more ?
> And that is independent of the current discussion.
> 
> > Possibly shift_arg_pages() should be fixed instead.

So the problem is that shift_arg_pages() does not call tlb_start_vma() /
tlb_end_vma(). It also has fullmm=0. Therefore, on ARC, there will not
be a TLB invalidate at all when freeing the page-tables.

And while looking at this more, move_page_tables() also looks dodgy, I
think it always needs a TLB flush of the entire 'old' range.

> > diff --git a/arch/arc/include/asm/tlb.h b/arch/arc/include/asm/tlb.h
> > index a9db5f62aaf3..7af2b373ebe7 100644
> > --- a/arch/arc/include/asm/tlb.h
> > +++ b/arch/arc/include/asm/tlb.h
> > @@ -23,15 +23,6 @@ do {						\
> >   *
> >   * Note, read http://lkml.org/lkml/2004/1/15/6
> >   */
> > -#ifndef CONFIG_ARC_CACHE_VIPT_ALIASING
> > -#define tlb_start_vma(tlb, vma)
> > -#else
> > -#define tlb_start_vma(tlb, vma)						\
> > -do {									\
> > -	if (!tlb->fullmm)						\
> > -		flush_cache_range(vma, vma->vm_start, vma->vm_end);	\
> > -} while(0)
> > -#endif
> >  
> >  #define tlb_end_vma(tlb, vma)						\
> >  do {									\
> 
> [snip..]
> 
> > 				      \
> > diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
> > index e811ef7b8350..1d037fd5bb7a 100644
> > --- a/include/asm-generic/tlb.h
> > +++ b/include/asm-generic/tlb.h
> > @@ -181,19 +181,21 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
> >   * the vmas are adjusted to only cover the region to be torn down.
> >   */
> >  #ifndef tlb_start_vma
> > -#define tlb_start_vma(tlb, vma) do { } while (0)
> > +#define tlb_start_vma(tlb, vma)						\
> > +do {									\
> > +	if (!tlb->fullmm)						\
> > +		flush_cache_range(vma, vma->vm_start, vma->vm_end);	\
> > +} while (0)
> >  #endif
> 
> So for non aliasing arches to be not affected, this relies on flush_cache_range()
> to be no-op ?

Yes; a cursory inspected shows this to be so. With 'obvious' exception
from the above 3 architectures.

> > -#define __tlb_end_vma(tlb, vma)					\
> > -	do {							\
> > -		if (!tlb->fullmm && tlb->end) {			\
> > -			tlb_flush(tlb);				\
> > -			__tlb_reset_range(tlb);			\
> > -		}						\
> > -	} while (0)
> > -
> >  #ifndef tlb_end_vma
> > -#define tlb_end_vma	__tlb_end_vma
> > +#define tlb_end_vma(tlb, vma)						\
> > +	do {								\
> > +		if (!tlb->fullmm && tlb->end) {				\
> > +			tlb_flush(tlb);					\
> > +			__tlb_reset_range(tlb);				\
> > +		}							\
> > +	} while (0)
> >  #endif
> >  
> >  #ifndef __tlb_remove_tlb_entry
> 
> And this one is for shift_arg_pages() but will also cause extraneous flushes for
> other cases - not happening currently !

No, shift_arg_pages() does not in fact call tlb_end_vma().

The reason for the flush in tlb_end_vma() is (as far as we can remember)
to 'better' deal with large gaps between adjacent VMAs.  Without the
flush here, the range would be extended to cover the (potential) dead
space between the VMAs. Resulting in more expensive range flushes.
