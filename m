Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B17EA6B003D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 06:05:29 -0400 (EDT)
Date: Tue, 21 Apr 2009 11:05:30 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 10/25] Calculate the alloc_flags for allocation only
	once
Message-ID: <20090421100530.GN12713@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-11-git-send-email-mel@csn.ul.ie> <20090421165022.F13F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090421165022.F13F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 06:03:25PM +0900, KOSAKI Motohiro wrote:
> > Factor out the mapping between GFP and alloc_flags only once. Once factored
> > out, it only needs to be calculated once but some care must be taken.
> > 
> > [neilb@suse.de says]
> > As the test:
> > 
> > -       if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
> > -                       && !in_interrupt()) {
> > -               if (!(gfp_mask & __GFP_NOMEMALLOC)) {
> > 
> > has been replaced with a slightly weaker one:
> > 
> > +       if (alloc_flags & ALLOC_NO_WATERMARKS) {
> > 
> > we need to ensure we don't recurse when PF_MEMALLOC is set.
> 
> It seems good idea.
> 
> > +static inline int
> > +gfp_to_alloc_flags(gfp_t gfp_mask)
> > +{
> > +	struct task_struct *p = current;
> > +	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
> > +	const gfp_t wait = gfp_mask & __GFP_WAIT;
> > +
> > +	/*
> > +	 * The caller may dip into page reserves a bit more if the caller
> > +	 * cannot run direct reclaim, or if the caller has realtime scheduling
> > +	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
> > +	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
> > +	 */
> > +	if (gfp_mask & __GFP_HIGH)
> > +		alloc_flags |= ALLOC_HIGH;
> > +
> > +	if (!wait) {
> > +		alloc_flags |= ALLOC_HARDER;
> > +		/*
> > +		 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
> > +		 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
> > +		 */
> > +		alloc_flags &= ~ALLOC_CPUSET;
> > +	} else if (unlikely(rt_task(p)) && !in_interrupt())
> 
> wait==1 and in_interrupt==1 is never occur.
> I think in_interrupt check can be removed.
> 

Looks like it. I removed it now.

> >  	/* Atomic allocations - we can't balance anything */
> >  	if (!wait)
> >  		goto nopage;
> >  
> > +	/* Avoid recursion of direct reclaim */
> > +	if (p->flags & PF_MEMALLOC)
> > +		goto nopage;
> > +
> 
> Again. old code doesn't only check PF_MEMALLOC, but also check TIF_MEMDIE.
> 

But a direct reclaim will have PF_MEMALLOC set and doesn't care about
the value of TIF_MEMDIE with respect to recursion.

There is still a check made for TIF_MEMDIE for setting ALLOC_NO_WATERMARKS
in gfp_to_alloc_flags() so that flag is still being taken care of.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
