Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CC00A6B00D7
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 13:17:18 -0500 (EST)
Date: Mon, 23 Feb 2009 18:17:13 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: gfp_to_alloc_flags()
Message-ID: <20090223181713.GS6740@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235390103.4645.80.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1235390103.4645.80.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 23, 2009 at 12:55:03PM +0100, Peter Zijlstra wrote:
> I've always found the below a clean-up, respun it on top of your changes.
> Test box still boots ;-)
> 
> ---
> Subject: mm: gfp_to_alloc_flags()
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Mon Feb 23 12:46:36 CET 2009
> 
> Clean up the code by factoring out the gfp to alloc_flags mapping.
> 
> [neilb@suse.de says]
> As the test:
> 
> -       if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
> -                       && !in_interrupt()) {
> -               if (!(gfp_mask & __GFP_NOMEMALLOC)) {
> 

At what point was this code deleted?

If it still exists, then I like the idea of this patch anyway. It takes
more code out of the loop. We end up checking if __GFP_WAIT is set twice,
but no major harm in that.

> has been replaced with a slightly weaker one:
> 
> +       if (alloc_flags & ALLOC_NO_WATERMARKS) {
> 
> we need to ensure we don't recurse when PF_MEMALLOC is set
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  mm/page_alloc.c |   90 ++++++++++++++++++++++++++++++++------------------------
>  1 file changed, 52 insertions(+), 38 deletions(-)
> 
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -1658,16 +1658,6 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
>  	return page;
>  }
>  
> -static inline int is_allocation_high_priority(struct task_struct *p,
> -							gfp_t gfp_mask)
> -{
> -	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
> -			&& !in_interrupt())
> -		if (!(gfp_mask & __GFP_NOMEMALLOC))
> -			return 1;
> -	return 0;
> -}
> -
>  /*
>   * This is called in the allocator slow-path if the allocation request is of
>   * sufficient urgency to ignore watermarks and take other desperate measures
> @@ -1702,6 +1692,44 @@ void wake_all_kswapd(unsigned int order,
>  		wakeup_kswapd(zone, order);
>  }
>  
> +/*
> + * get the deepest reaching allocation flags for the given gfp_mask
> + */
> +static int gfp_to_alloc_flags(gfp_t gfp_mask)
> +{
> +	struct task_struct *p = current;
> +	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
> +	const gfp_t wait = gfp_mask & __GFP_WAIT;
> +
> +	/*
> +	 * The caller may dip into page reserves a bit more if the caller
> +	 * cannot run direct reclaim, or if the caller has realtime scheduling
> +	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
> +	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
> +	 */
> +	if (gfp_mask & __GFP_HIGH)
> +		alloc_flags |= ALLOC_HIGH;
> +
> +	if (!wait) {
> +		alloc_flags |= ALLOC_HARDER;
> +		/*
> +		 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
> +		 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
> +		 */
> +		alloc_flags &= ~ALLOC_CPUSET;
> +	} else if (unlikely(rt_task(p)) && !in_interrupt())
> +		alloc_flags |= ALLOC_HARDER;
> +
> +	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
> +		if (!in_interrupt() &&
> +		    ((p->flags & PF_MEMALLOC) ||
> +		     unlikely(test_thread_flag(TIF_MEMDIE))))
> +			alloc_flags |= ALLOC_NO_WATERMARKS;
> +	}
> +
> +	return alloc_flags;
> +}
> +
>  static struct page * noinline
>  __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	struct zonelist *zonelist, enum zone_type high_zoneidx,
> @@ -1732,48 +1760,34 @@ __alloc_pages_slowpath(gfp_t gfp_mask, u
>  	 * OK, we're below the kswapd watermark and have kicked background
>  	 * reclaim. Now things get more complex, so set up alloc_flags according
>  	 * to how we want to proceed.
> -	 *
> -	 * The caller may dip into page reserves a bit more if the caller
> -	 * cannot run direct reclaim, or if the caller has realtime scheduling
> -	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
> -	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
>  	 */
> -	alloc_flags = ALLOC_WMARK_MIN;
> -	if ((unlikely(rt_task(p)) && !in_interrupt()) || !wait)
> -		alloc_flags |= ALLOC_HARDER;
> -	if (gfp_mask & __GFP_HIGH)
> -		alloc_flags |= ALLOC_HIGH;
> -	if (wait)
> -		alloc_flags |= ALLOC_CPUSET;
> +	alloc_flags = gfp_to_alloc_flags(gfp_mask);
>  
>  restart:
> -	/*
> -	 * Go through the zonelist again. Let __GFP_HIGH and allocations
> -	 * coming from realtime tasks go deeper into reserves.
> -	 *
> -	 * This is the last chance, in general, before the goto nopage.
> -	 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
> -	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
> -	 */
> +	/* This is the last chance, in general, before the goto nopage. */
>  	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
> -						high_zoneidx, alloc_flags,
> -						preferred_zone,
> -						migratetype);
> +			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
> +			preferred_zone, migratetype);
>  	if (page)
>  		goto got_pg;
>  
>  	/* Allocate without watermarks if the context allows */
> -	if (is_allocation_high_priority(p, gfp_mask))
> +	if (alloc_flags & ALLOC_NO_WATERMARKS) {
>  		page = __alloc_pages_high_priority(gfp_mask, order,
> -			zonelist, high_zoneidx, nodemask, preferred_zone,
> -			migratetype);
> -	if (page)
> -		goto got_pg;
> +				zonelist, high_zoneidx, nodemask,
> +				preferred_zone, migratetype);
> +		if (page)
> +			goto got_pg;
> +	}
>  
>  	/* Atomic allocations - we can't balance anything */
>  	if (!wait)
>  		goto nopage;
>  
> +	/* Avoid recursion of direct reclaim */
> +	if (p->flags & PF_MEMALLOC)
> +		goto nopage;
> +
>  	/* Try direct reclaim and then allocating */
>  	page = __alloc_pages_direct_reclaim(gfp_mask, order,
>  					zonelist, high_zoneidx,
> 

Looks good eyeballing it here at least. I'll slot it in and see what the
end result looks like but I think it'll be good.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
