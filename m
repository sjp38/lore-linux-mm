Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 08F248D0039
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 05:16:13 -0500 (EST)
Date: Tue, 18 Jan 2011 10:15:48 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone
	is not allowed
Message-ID: <20110118101547.GF27152@csn.ul.ie>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 17, 2011 at 09:09:07PM -0800, David Rientjes wrote:
> Before 0e093d99763e (writeback: do not sleep on the congestion queue if
> there are no congested BDIs or if significant congestion is not being
> encountered in the current zone), preferred_zone was only used for
> statistics and to determine the zoneidx from which to allocate from given
> the type requested.
> 

It is also used when deciding if compaction should be deferred for a
period of time.

> wait_iff_congested(), though, uses preferred_zone to determine if the
> congestion wait should be deferred because its dirty pages are backed by
> a congested bdi.  This incorrectly defers the timeout and busy loops in
> the page allocator with various cond_resched() calls if preferred_zone is
> not allowed in the current context, usually consuming 100% of a cpu.
> 

The current context being cpuset context or do you have other situations
in mind?

> This patch resets preferred_zone to an allowed zone in the slowpath if
> the allocation context is constrained by current's cpuset. 

Well, preferred_zone has meaning. If it's not possible to allocate from
that zone in the current cpuset context, it's not really preferred. Why
not set it in the fast path so there isn't a useless call to
get_page_from_freelist()?

> It also
> ensures preferred_zone is from the set of allowed nodes when called from
> within direct reclaim; allocations are always constrainted by cpusets
> since the context is always blockable.
> 

preferred_zone should already be obeying nodemask and the set of allowed
nodes. Are you aware of an instance where this is not the case or are
you talking about the nodes allowed by the cpuset?

> Both of these uses of cpuset_current_mems_allowed are protected by
> get_mems_allowed().
> ---
>  mm/page_alloc.c |   12 ++++++++++++
>  mm/vmscan.c     |    3 ++-
>  2 files changed, 14 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2034,6 +2034,18 @@ restart:
>  	 */
>  	alloc_flags = gfp_to_alloc_flags(gfp_mask);
>  
> +	/*
> +	 * If preferred_zone cannot be allocated from in this context, find the
> +	 * first allowable zone instead.
> +	 */
> +	if ((alloc_flags & ALLOC_CPUSET) &&
> +	    !cpuset_zone_allowed_softwall(preferred_zone, gfp_mask)) {
> +		first_zones_zonelist(zonelist, high_zoneidx,
> +				&cpuset_current_mems_allowed, &preferred_zone);
> +		if (unlikely(!preferred_zone))
> +			goto nopage;
> +	}
> +

This looks as if it would work but is there any reason why
cpuset_current_mems_allowed is not used as the nodemask for ALLOC_CPUSET? It's
used by ZLC with CONFIG_NUMA machines for example so it seems a little
inconsistent. If a nodemask was supplied by the caller, it could be AND'd
with cpuset_current_mems_allowed.

>  	/* This is the last chance, in general, before the goto nopage. */
>  	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
>  			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2084,7 +2084,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  			struct zone *preferred_zone;
>  
>  			first_zones_zonelist(zonelist, gfp_zone(sc->gfp_mask),
> -							NULL, &preferred_zone);
> +						&cpuset_current_mems_allowed,
> +						&preferred_zone);
>  			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/10);

This part looks fine and a worthwhile fix all on its own.

>  		}
>  	}
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
