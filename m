Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 08A516B006E
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 08:24:55 -0400 (EDT)
Received: by wiax7 with SMTP id x7so110829353wia.0
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 05:24:54 -0700 (PDT)
Received: from casper.infradead.org ([2001:770:15f::2])
        by mx.google.com with ESMTPS id ab3si25878527wid.70.2015.04.15.05.24.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Apr 2015 05:24:53 -0700 (PDT)
Date: Wed, 15 Apr 2015 14:24:40 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/4] mm: Gather more PFNs before sending a TLB to flush
 unmapped pages
Message-ID: <20150415122440.GV5029@twins.programming.kicks-ass.net>
References: <1429094576-5877-1-git-send-email-mgorman@suse.de>
 <1429094576-5877-4-git-send-email-mgorman@suse.de>
 <20150415114220.GG17717@twins.programming.kicks-ass.net>
 <20150415121553.GD14842@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150415121553.GD14842@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 15, 2015 at 01:15:53PM +0100, Mel Gorman wrote:
> On Wed, Apr 15, 2015 at 01:42:20PM +0200, Peter Zijlstra wrote:
> > On Wed, Apr 15, 2015 at 11:42:55AM +0100, Mel Gorman wrote:
> > > +/*
> > > + * Use a page to store as many PFNs as possible for batch unmapping. Adjusting
> > > + * this trades memory usage for number of IPIs sent
> > > + */
> > > +#define BATCH_TLBFLUSH_SIZE \
> > > +	((PAGE_SIZE - sizeof(struct cpumask) - sizeof(unsigned long)) / sizeof(unsigned long))
> > >  
> > >  /* Track pages that require TLB flushes */
> > >  struct unmap_batch {
> > > +	/* Update BATCH_TLBFLUSH_SIZE when adjusting this structure */
> > >  	struct cpumask cpumask;
> > >  	unsigned long nr_pages;
> > >  	unsigned long pfns[BATCH_TLBFLUSH_SIZE];
> > 
> > The alternative is something like:
> > 
> > struct unmap_batch {
> > 	struct cpumask cpumask;
> > 	unsigned long nr_pages;
> > 	unsigned long pfnsp[0];
> > };
> > 
> > #define BATCH_TLBFLUSH_SIZE ((PAGE_SIZE - sizeof(struct unmap_batch)) / sizeof(unsigned long))
> > 
> > and unconditionally allocate 1 page. This saves you from having to worry
> > about the layout of struct unmap_batch.
> 
> True but then I need to calculate the size of the real array so it's
> similar in terms of readability. The plus would be that if the structure
> changes then the size calculation is not changed but then the allocation
> site and the size calculation must be kept in sync. I did not see a clear
> win of one approach over the other so flipped a coin.

I'm not seeing your argument, in both your an mine variant the
allocation is hard assumed to be 1 page, right? But even then, what's
more likely to change, extra members in our struct or growing the
allocation to two (or more) pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
