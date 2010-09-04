Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7376B0047
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 23:55:49 -0400 (EDT)
Date: Fri, 3 Sep 2010 20:59:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
 direct reclaim allocation fails
Message-Id: <20100903205945.44e1aa38.akpm@linux-foundation.org>
In-Reply-To: <20100904032311.GA14222@localhost>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie>
	<1283504926-2120-4-git-send-email-mel@csn.ul.ie>
	<20100903160026.564fdcc9.akpm@linux-foundation.org>
	<20100904022545.GD705@dastard>
	<20100904032311.GA14222@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Linux Kernel List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Sat, 4 Sep 2010 11:23:11 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:

> > Still, given the improvements in performance from this patchset,
> > I'd say inclusion is a no-braniner....
> 
> In your case it's not really high memory pressure, but maybe too many
> concurrent direct reclaimers, so that when one reclaimed some free
> pages, others kick in and "steal" the free pages. So we need to kill
> the second cond_resched() call (which effectively gives other tasks a
> good chance to steal this task's vmscan fruits), and only do
> drain_all_pages() when nothing was reclaimed (instead of allocated).

Well...  cond_resched() will only resched when this task has been
marked for preemption.  If that's happening at such a high frequency
then Something Is Up with the scheduler, and the reported context
switch rate will be high.

> Dave, will you give a try of this patch? It's based on Mel's.
> 
> 
> --- linux-next.orig/mm/page_alloc.c	2010-09-04 11:08:03.000000000 +0800
> +++ linux-next/mm/page_alloc.c	2010-09-04 11:16:33.000000000 +0800
> @@ -1850,6 +1850,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
>  
>  	cond_resched();
>  
> +retry:
>  	/* We now go into synchronous reclaim */
>  	cpuset_memory_pressure_bump();
>  	p->flags |= PF_MEMALLOC;
> @@ -1863,26 +1864,23 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
>  	lockdep_clear_current_reclaim_state();
>  	p->flags &= ~PF_MEMALLOC;
>  
> -	cond_resched();
> -
> -	if (unlikely(!(*did_some_progress)))
> +	if (unlikely(!(*did_some_progress))) {
> +		if (!drained) {
> +			drain_all_pages();
> +			drained = true;
> +			goto retry;
> +		}
>  		return NULL;
> +	}
>  
> -retry:
>  	page = get_page_from_freelist(gfp_mask, nodemask, order,
>  					zonelist, high_zoneidx,
>  					alloc_flags, preferred_zone,
>  					migratetype);
>  
> -	/*
> -	 * If an allocation failed after direct reclaim, it could be because
> -	 * pages are pinned on the per-cpu lists. Drain them and try again
> -	 */
> -	if (!page && !drained) {
> -		drain_all_pages();
> -		drained = true;
> +	/* someone steal our vmscan fruits? */
> +	if (!page && *did_some_progress)
>  		goto retry;
> -	}

Perhaps the fruit-stealing event is worth adding to the
userspace-exposed vm stats somewhere.  But not in /proc - somewhere
more temporary, in debugfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
