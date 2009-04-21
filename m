Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 32C396B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 06:36:40 -0400 (EDT)
Date: Tue, 21 Apr 2009 11:37:10 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 10/25] Calculate the alloc_flags for allocation only
	once
Message-ID: <20090421103709.GR12713@csn.ul.ie>
References: <20090421165022.F13F.A69D9226@jp.fujitsu.com> <20090421100530.GN12713@csn.ul.ie> <20090421190921.F15F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090421190921.F15F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 07:12:57PM +0900, KOSAKI Motohiro wrote:
> > > > +	/* Avoid recursion of direct reclaim */
> > > > +	if (p->flags & PF_MEMALLOC)
> > > > +		goto nopage;
> > > > +
> > > 
> > > Again. old code doesn't only check PF_MEMALLOC, but also check TIF_MEMDIE.
> > > 
> > 
> > But a direct reclaim will have PF_MEMALLOC set and doesn't care about
> > the value of TIF_MEMDIE with respect to recursion.
> > 
> > There is still a check made for TIF_MEMDIE for setting ALLOC_NO_WATERMARKS
> > in gfp_to_alloc_flags() so that flag is still being taken care of.
> 
> Do you mean this is intentional change?
> I only said there is changelog-less behavior change.
> 

Yes, it's intentional.

> old code is here.
> PF_MEMALLOC and TIF_MEMDIE makes goto nopage. it avoid reclaim.

PF_MEMALLOC avoiding reclaim makes sense but TIF_MEMDIE should be
allowed to reclaim. I called it out a bit better in the changelog now.

> -------------------------------------------------------------------------
> rebalance:
>         if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
>                         && !in_interrupt()) {
>                 if (!(gfp_mask & __GFP_NOMEMALLOC)) {
> nofail_alloc:
>                         /* go through the zonelist yet again, ignoring mins */
>                         page = get_page_from_freelist(gfp_mask, nodemask, order,
>                                 zonelist, high_zoneidx, ALLOC_NO_WATERMARKS);
>                         if (page)
>                                 goto got_pg;
>                         if (gfp_mask & __GFP_NOFAIL) {
>                                 congestion_wait(WRITE, HZ/50);
>                                 goto nofail_alloc;
>                         }
>                 }
>                 goto nopage;
>         }
> -------------------------------------------------------------------------
> 
> 
> but I don't oppose this change if it is your intentional.
> 

The changelog now reads
=====

Factor out the mapping between GFP and alloc_flags only once. Once factored
out, it only needs to be calculated once but some care must be taken.

[neilb@suse.de says]
As the test:

-       if (((p->flags & PF_MEMALLOC) ||
        unlikely(test_thread_flag(TIF_MEMDIE)))
-                       && !in_interrupt()) {
-               if (!(gfp_mask & __GFP_NOMEMALLOC)) {

has been replaced with a slightly weaker one:

+       if (alloc_flags & ALLOC_NO_WATERMARKS) {

Without care, this would allow recursion into the allocator via direct
reclaim. This patch ensures we do not recurse when PF_MEMALLOC is set
but TF_MEMDIE callers are now allowed to directly reclaim where they
would have been prevented in the past.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
