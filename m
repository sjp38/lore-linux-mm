Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id DDD7C8E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:42:45 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e63-v6so9798085ite.2
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 11:42:45 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id i184-v6si3519489itb.87.2018.09.13.11.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Sep 2018 11:42:44 -0700 (PDT)
Date: Thu, 13 Sep 2018 20:42:30 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 03/11] x86/mm: Page size aware flush_tlb_mm_range()
Message-ID: <20180913184230.GD24124@hirez.programming.kicks-ass.net>
References: <20180913092110.817204997@infradead.org>
 <20180913092812.012757318@infradead.org>
 <f89e61a3-0eb0-3d00-fbaa-f30c2cf60be3@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f89e61a3-0eb0-3d00-fbaa-f30c2cf60be3@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Thu, Sep 13, 2018 at 10:22:58AM -0700, Dave Hansen wrote:
> > +static inline void tlb_flush(struct mmu_gather *tlb)
> > +{
> > +	unsigned long start = 0UL, end = TLB_FLUSH_ALL;
> > +	unsigned int invl_shift = tlb_get_unmap_shift(tlb);
> 
> I had to go back and look at
> 
> 	https://patchwork.kernel.org/patch/10587207/

I so hate patchwork...

> to figure out what was going on.  I wonder if we could make the code a
> bit more standalone.
> 
> This at least needs a comment about what it's getting from 'tlb'.  Maybe
> just:
> 
> 	/* Find the smallest page size that we unmapped: */
> 
> > --- a/arch/x86/include/asm/tlbflush.h
> > +++ b/arch/x86/include/asm/tlbflush.h
> > @@ -507,23 +507,25 @@ struct flush_tlb_info {
> >  	unsigned long		start;
> >  	unsigned long		end;
> >  	u64			new_tlb_gen;
> > +	unsigned int		invl_shift;
> >  };
> 
> Maybe we really should just call this flush_stride or something.

But its a shift, not a size. stride_shift?

> >  #define local_flush_tlb() __flush_tlb()
> >  
> >  #define flush_tlb_mm(mm)	flush_tlb_mm_range(mm, 0UL, TLB_FLUSH_ALL, 0UL)
> >  
> > -#define flush_tlb_range(vma, start, end)	\
> > -		flush_tlb_mm_range(vma->vm_mm, start, end, vma->vm_flags)
> > +#define flush_tlb_range(vma, start, end)			\
> > +		flush_tlb_mm_range((vma)->vm_mm, start, end,	\
> > +				(vma)->vm_flags & VM_HUGETLB ? PMD_SHIFT : PAGE_SHIFT)
> 
> This is safe.  But, Couldn't this PMD_SHIFT also be PUD_SHIFT for a 1G
> hugetlb page?

It could be, but can we tell at that point?

> >  void native_flush_tlb_others(const struct cpumask *cpumask,
> > --- a/arch/x86/mm/tlb.c
> > +++ b/arch/x86/mm/tlb.c
> > @@ -522,12 +522,12 @@ static void flush_tlb_func_common(const
> >  	    f->new_tlb_gen == mm_tlb_gen) {
> >  		/* Partial flush */
> >  		unsigned long addr;
> > -		unsigned long nr_pages = (f->end - f->start) >> PAGE_SHIFT;
> > +		unsigned long nr_pages = (f->end - f->start) >> f->invl_shift;
> 
> We might want to make this nr_invalidations or nr_flushes now so we
> don't get it confused with PAGE_SIZE stuff.

Sure, can rename.

> Otherwise, this makes me a *tiny* bit nervous.  I think we're good about
> ensuring that we fully flush 4k mappings from the TLB before going up to
> a 2MB mapping because of all the errata we've had there over the years.
> But, had we left 4k mappings around, the old flushing code would have
> cleaned them up for us.

Indeed.

> This certainly tightly ties the invalidations to what was in the page
> tables.  If that diverged from the TLB at some point, there's certainly
> more exposure here.
>
> Looks fun, though. :)

:-)
