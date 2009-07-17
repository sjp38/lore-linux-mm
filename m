Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 60DDE6B004F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 05:21:54 -0400 (EDT)
Date: Fri, 17 Jul 2009 10:21:57 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] page-allocator: Ensure that processes that have been
	OOM killed exit the page allocator (resend)
Message-ID: <20090717092157.GA9835@csn.ul.ie>
References: <20090715104944.GC9267@csn.ul.ie> <alpine.DEB.2.00.0907151326350.22582@chino.kir.corp.google.com> <20090716110328.GB22499@csn.ul.ie> <alpine.DEB.2.00.0907161202500.27201@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0907161202500.27201@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 16, 2009 at 12:14:13PM -0700, David Rientjes wrote:
> On Thu, 16 Jul 2009, Mel Gorman wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 4b8552e..b381a6b 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1830,8 +1830,6 @@ rebalance:
> >  			if (order > PAGE_ALLOC_COSTLY_ORDER &&
> >  						!(gfp_mask & __GFP_NOFAIL))
> >  				goto nopage;
> > -
> > -			goto restart;
> >  		}
> >  	}
> >  
> > 
> 
> This isn't right (and not only because it'll add a compiler warning 
> because `restart' is now unused).
> 
> This would immediately fail any allocation that triggered the oom killer 
> and ended up being selected that isn't __GFP_NOFAIL, even if it would have 
> succeeded without even killing any task simply because it allocates 
> without watermarks.
> 
> It will also, coupled with your earlier patch, inappropriately warn about 
> an infinite loop with __GFP_NOFAIL even though it hasn't even attempted to 
> loop once since that decision is now handled by should_alloc_retry().
> 
> The liklihood of such an infinite loop, considering only one thread per 
> system (or cpuset) can be TIF_MEMDIE at a time, is very low.  I've never 
> seen memory reserves completely depleted such that the next high-priority 
> allocation wouldn't succeed so that current could handle its pending 
> SIGKILL.
> 
> You get the same behavior with my patch, but are allowed to try the high 
> priority allocation again for the attempt that triggered the oom killer 
> (and not only subsequent ones).

Ok, lets go with this patch then. Thanks

> ---
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1789,6 +1789,10 @@ rebalance:
>  	if (p->flags & PF_MEMALLOC)
>  		goto nopage;
>  
> +	/* Avoid allocations with no watermarks from looping endlessly */
> +	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> +		goto nopage;
> +
>  	/* Try direct reclaim and then allocating */
>  	page = __alloc_pages_direct_reclaim(gfp_mask, order,
>  					zonelist, high_zoneidx,
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
