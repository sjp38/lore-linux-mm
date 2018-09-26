Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A01068E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 09:19:04 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id n26-v6so52350586iog.15
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 06:19:04 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id d21-v6si3071994ioe.45.2018.09.26.06.19.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 26 Sep 2018 06:19:03 -0700 (PDT)
Date: Wed, 26 Sep 2018 15:11:41 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 05/18] asm-generic/tlb: Provide generic tlb_flush
Message-ID: <20180926131141.GA12444@hirez.programming.kicks-ass.net>
References: <20180926113623.863696043@infradead.org>
 <20180926114800.770817616@infradead.org>
 <20180926125335.GG2979@brain-police>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180926125335.GG2979@brain-police>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com

On Wed, Sep 26, 2018 at 01:53:35PM +0100, Will Deacon wrote:
> On Wed, Sep 26, 2018 at 01:36:28PM +0200, Peter Zijlstra wrote:
> > +#ifndef tlb_flush
> > +
> > +#if defined(tlb_start_vma) || defined(tlb_end_vma)
> > +#error Default tlb_flush() relies on default tlb_start_vma() and tlb_end_vma()
> > +#endif
> > +
> > +#define tlb_flush tlb_flush
> 
> Do we need this #define?

Probably not, that was just my fingers doing the normal #ifndef #define
pattern. I'll take em out back for a 'hug' :-)

> > +static inline void tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
> > +{
> > +	if (tlb->fullmm)
> > +		return;
> > +
> > +	/*
> > +	 * flush_tlb_range() implementations that look at VM_HUGETLB (tile,
> > +	 * mips-4k) flush only large pages.
> > +	 *
> > +	 * flush_tlb_range() implementations that flush I-TLB also flush D-TLB
> > +	 * (tile, xtensa, arm), so it's ok to just add VM_EXEC to an existing
> > +	 * range.
> > +	 *
> > +	 * We rely on tlb_end_vma() to issue a flush, such that when we reset
> > +	 * these values the batch is empty.
> > +	 */
> > +	tlb->vma_huge = !!(vma->vm_flags & VM_HUGETLB);
> > +	tlb->vma_exec = !!(vma->vm_flags & VM_EXEC);
> 
> Hmm, does this result in code generation for archs that don't care about the
> vm_flags?

Yes. It's not much code, but if you deeply care we could frob things to
get rid of it.
