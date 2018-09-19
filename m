Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id A14AC8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 08:23:12 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id e38-v6so4762782otj.15
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 05:23:12 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k70-v6si7504705otk.129.2018.09.19.05.23.10
        for <linux-mm@kvack.org>;
        Wed, 19 Sep 2018 05:23:11 -0700 (PDT)
Date: Wed, 19 Sep 2018 13:23:29 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC][PATCH 01/11] asm-generic/tlb: Provide a comment
Message-ID: <20180919122328.GB22723@arm.com>
References: <20180913092110.817204997@infradead.org>
 <20180913092811.894806629@infradead.org>
 <20180914164857.GG6236@arm.com>
 <20180919115158.GD24124@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180919115158.GD24124@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Wed, Sep 19, 2018 at 01:51:58PM +0200, Peter Zijlstra wrote:
> On Fri, Sep 14, 2018 at 05:48:57PM +0100, Will Deacon wrote:
> 
> > > + *  - mmu_gather::fullmm
> > > + *
> > > + *    A flag set by tlb_gather_mmu() to indicate we're going to free
> > > + *    the entire mm; this allows a number of optimizations.
> > > + *
> > > + *    XXX list optimizations
> > 
> > On arm64, we can elide the invalidation altogether because we won't
> > re-allocate the ASID. We also have an invalidate-by-ASID (mm) instruction,
> > which we could use if we needed to.
> 
> Right, but I was also struggling to put into words the normal fullmm
> case.
> 
> I now ended up with:
> 
> --- a/include/asm-generic/tlb.h
> +++ b/include/asm-generic/tlb.h
> @@ -82,7 +82,11 @@
>   *    A flag set by tlb_gather_mmu() to indicate we're going to free
>   *    the entire mm; this allows a number of optimizations.
>   *
> - *    XXX list optimizations
> + *    - We can ignore tlb_{start,end}_vma(); because we don't
> + *      care about ranges. Everything will be shot down.
> + *
> + *    - (RISC) architectures that use ASIDs can cycle to a new ASID
> + *      and delay the invalidation until ASID space runs out.
>   *
>   *  - mmu_gather::need_flush_all
>   *
> 
> Does that about cover things; or do we need more?

I think that's fine as a starting point. People can always add more.

> > > + *
> > > + *  - mmu_gather::need_flush_all
> > > + *
> > > + *    A flag that can be set by the arch code if it wants to force
> > > + *    flush the entire TLB irrespective of the range. For instance
> > > + *    x86-PAE needs this when changing top-level entries.
> > > + *
> > > + * And requires the architecture to provide and implement tlb_flush().
> > > + *
> > > + * tlb_flush() may, in addition to the above mentioned mmu_gather fields, make
> > > + * use of:
> > > + *
> > > + *  - mmu_gather::start / mmu_gather::end
> > > + *
> > > + *    which (when !need_flush_all; fullmm will have start = end = ~0UL) provides
> > > + *    the range that needs to be flushed to cover the pages to be freed.
> > 
> > I don't understand the mention of need_flush_all here -- I didn't think it
> > was used by the core code at all.
> 
> The core does indeed not use that flag; but if the architecture set
> that, the range is still ignored.
> 
> Can you suggest clearer wording?

The range is only ignored if the default tlb_flush() implementation is used
though, right? Since this text is about the fields that tlb_flush() can use,
I think we can just delete the part in brackets.

Will
