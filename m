Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 87DBA6B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 08:56:26 -0400 (EDT)
Received: by widdi4 with SMTP id di4so153429007wid.0
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 05:56:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bn6si8028842wjb.29.2015.04.15.05.56.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 05:56:25 -0700 (PDT)
Date: Wed, 15 Apr 2015 13:56:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/4] mm: Gather more PFNs before sending a TLB to flush
 unmapped pages
Message-ID: <20150415125620.GE14842@suse.de>
References: <1429094576-5877-1-git-send-email-mgorman@suse.de>
 <1429094576-5877-4-git-send-email-mgorman@suse.de>
 <20150415114220.GG17717@twins.programming.kicks-ass.net>
 <20150415121553.GD14842@suse.de>
 <20150415122440.GV5029@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150415122440.GV5029@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 15, 2015 at 02:24:40PM +0200, Peter Zijlstra wrote:
> On Wed, Apr 15, 2015 at 01:15:53PM +0100, Mel Gorman wrote:
> > On Wed, Apr 15, 2015 at 01:42:20PM +0200, Peter Zijlstra wrote:
> > > On Wed, Apr 15, 2015 at 11:42:55AM +0100, Mel Gorman wrote:
> > > > +/*
> > > > + * Use a page to store as many PFNs as possible for batch unmapping. Adjusting
> > > > + * this trades memory usage for number of IPIs sent
> > > > + */
> > > > +#define BATCH_TLBFLUSH_SIZE \
> > > > +	((PAGE_SIZE - sizeof(struct cpumask) - sizeof(unsigned long)) / sizeof(unsigned long))
> > > >  
> > > >  /* Track pages that require TLB flushes */
> > > >  struct unmap_batch {
> > > > +	/* Update BATCH_TLBFLUSH_SIZE when adjusting this structure */
> > > >  	struct cpumask cpumask;
> > > >  	unsigned long nr_pages;
> > > >  	unsigned long pfns[BATCH_TLBFLUSH_SIZE];
> > > 
> > > The alternative is something like:
> > > 
> > > struct unmap_batch {
> > > 	struct cpumask cpumask;
> > > 	unsigned long nr_pages;
> > > 	unsigned long pfnsp[0];
> > > };
> > > 
> > > #define BATCH_TLBFLUSH_SIZE ((PAGE_SIZE - sizeof(struct unmap_batch)) / sizeof(unsigned long))
> > > 
> > > and unconditionally allocate 1 page. This saves you from having to worry
> > > about the layout of struct unmap_batch.
> > 
> > True but then I need to calculate the size of the real array so it's
> > similar in terms of readability. The plus would be that if the structure
> > changes then the size calculation is not changed but then the allocation
> > site and the size calculation must be kept in sync. I did not see a clear
> > win of one approach over the other so flipped a coin.
> 
> I'm not seeing your argument, in both your an mine variant the
> allocation is hard assumed to be 1 page, right?

No, in mine I can use sizeof to "discover" it even though the answer is
always a page.

> But even then, what's
> more likely to change, extra members in our struct or growing the
> allocation to two (or more) pages?

Either approach requires careful treatment. I can switch to your method
in V2 because to me, they're equivalent in terms of readability and
maintenance.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
