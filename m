Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id EFBDD6B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 09:05:42 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so1501293wiv.2
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 06:05:42 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g9si2536047wie.98.2014.12.05.06.05.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 06:05:41 -0800 (PST)
Date: Fri, 5 Dec 2014 15:05:39 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, oom: remove gfp helper function
Message-ID: <20141205140539.GD2321@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1411261416480.13014@chino.kir.corp.google.com>
 <20141127102547.GA18833@dhcp22.suse.cz>
 <20141201233040.GB29642@phnom.home.cmpxchg.org>
 <20141203155222.GH23236@dhcp22.suse.cz>
 <20141203181509.GA24567@phnom.home.cmpxchg.org>
 <20141204151758.GC25001@dhcp22.suse.cz>
 <20141204201905.GA17790@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141204201905.GA17790@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Qiang Huang <h.huangqiang@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 04-12-14 15:19:05, Johannes Weiner wrote:
[...]
> How about the following?  It changes the code flow to clarify what's
> actually going on there and gets rid of oom_gfp_allowed() altogether,
> instead of awkwardly trying to explain something that has no meaning.

Yes this makes a lot of sense.

> Btw, it looks like there is a bug with oom_killer_disabled, because it
> will return NULL for __GFP_NOFAIL.

Right! __GFP_NOFAIL allocation after oom is disabled cannot be
guaranteed.

> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: page_alloc: embed OOM killing naturally into allocation
>  slowpath
> 
> The OOM killing invocation does a lot of duplicative checks against
> the task's allocation context.  Rework it to take advantage of the
> existing checks in the allocator slowpath.

Nice! Just document the __GFP_NOFAIL fix here as well, please.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

I will rebase my oom vs pm-freezer patch
(http://marc.info/?l=linux-mm&m=141634503316543&w=2) which touches this
area on top of your patch.

Thanks!

> ---
>  include/linux/oom.h |  5 ----
>  mm/page_alloc.c     | 80 +++++++++++++++++++++++------------------------------
>  2 files changed, 35 insertions(+), 50 deletions(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index e8d6e1058723..4971874f54db 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -85,11 +85,6 @@ static inline void oom_killer_enable(void)
>  	oom_killer_disabled = false;
>  }
>  
> -static inline bool oom_gfp_allowed(gfp_t gfp_mask)
> -{
> -	return (gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY);
> -}
> -
>  extern struct task_struct *find_lock_task_mm(struct task_struct *p);
>  
>  /* sysctls */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 616a2c956b4b..2df99ca56e28 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2232,12 +2232,21 @@ static inline struct page *
>  __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	struct zonelist *zonelist, enum zone_type high_zoneidx,
>  	nodemask_t *nodemask, struct zone *preferred_zone,
> -	int classzone_idx, int migratetype)
> +	int classzone_idx, int migratetype, unsigned long *did_some_progress)
>  {
>  	struct page *page;
>  
> -	/* Acquire the per-zone oom lock for each zone */
> +	*did_some_progress = 0;
> +
> +	if (oom_killer_disabled)
> +		return NULL;
> +
> +	/*
> +	 * Acquire the per-zone oom lock for each zone.  If that
> +	 * fails, somebody else is making progress for us.
> +	 */
>  	if (!oom_zonelist_trylock(zonelist, gfp_mask)) {
> +		*did_some_progress = 1;
>  		schedule_timeout_uninterruptible(1);
>  		return NULL;
>  	}
> @@ -2263,12 +2272,18 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  		goto out;
>  
>  	if (!(gfp_mask & __GFP_NOFAIL)) {
> +		/* Coredumps can quickly deplete all memory reserves */
> +		if (current->flags & PF_DUMPCORE)
> +			goto out;
>  		/* The OOM killer will not help higher order allocs */
>  		if (order > PAGE_ALLOC_COSTLY_ORDER)
>  			goto out;
>  		/* The OOM killer does not needlessly kill tasks for lowmem */
>  		if (high_zoneidx < ZONE_NORMAL)
>  			goto out;
> +		/* The OOM killer does not compensate for light reclaim */
> +		if (!(gfp_mask & __GFP_FS))
> +			goto out;
>  		/*
>  		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
>  		 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
> @@ -2281,7 +2296,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	}
>  	/* Exhausted what can be done so it's blamo time */
>  	out_of_memory(zonelist, gfp_mask, order, nodemask, false);
> -
> +	*did_some_progress = 1;
>  out:
>  	oom_zonelist_unlock(zonelist, gfp_mask);
>  	return page;
> @@ -2571,7 +2586,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
>  		goto nopage;
>  
> -restart:
>  	if (!(gfp_mask & __GFP_NO_KSWAPD))
>  		wake_all_kswapds(order, zonelist, high_zoneidx,
>  				preferred_zone, nodemask);
> @@ -2701,51 +2715,27 @@ rebalance:
>  	if (page)
>  		goto got_pg;
>  
> -	/*
> -	 * If we failed to make any progress reclaiming, then we are
> -	 * running out of options and have to consider going OOM
> -	 */
> -	if (!did_some_progress) {
> -		if (oom_gfp_allowed(gfp_mask)) {
> -			if (oom_killer_disabled)
> -				goto nopage;
> -			/* Coredumps can quickly deplete all memory reserves */
> -			if ((current->flags & PF_DUMPCORE) &&
> -			    !(gfp_mask & __GFP_NOFAIL))
> -				goto nopage;
> -			page = __alloc_pages_may_oom(gfp_mask, order,
> -					zonelist, high_zoneidx,
> -					nodemask, preferred_zone,
> -					classzone_idx, migratetype);
> -			if (page)
> -				goto got_pg;
> -
> -			if (!(gfp_mask & __GFP_NOFAIL)) {
> -				/*
> -				 * The oom killer is not called for high-order
> -				 * allocations that may fail, so if no progress
> -				 * is being made, there are no other options and
> -				 * retrying is unlikely to help.
> -				 */
> -				if (order > PAGE_ALLOC_COSTLY_ORDER)
> -					goto nopage;
> -				/*
> -				 * The oom killer is not called for lowmem
> -				 * allocations to prevent needlessly killing
> -				 * innocent tasks.
> -				 */
> -				if (high_zoneidx < ZONE_NORMAL)
> -					goto nopage;
> -			}
> -
> -			goto restart;
> -		}
> -	}
> -
>  	/* Check if we should retry the allocation */
>  	pages_reclaimed += did_some_progress;
>  	if (should_alloc_retry(gfp_mask, order, did_some_progress,
>  						pages_reclaimed)) {
> +		/*
> +		 * If we fail to make progress by freeing individual
> +		 * pages, but the allocation wants us to keep going,
> +		 * start OOM killing tasks.
> +		 */
> +		if (!did_some_progress) {
> +			page = __alloc_pages_may_oom(gfp_mask, order, zonelist,
> +						high_zoneidx, nodemask,
> +						preferred_zone, classzone_idx,
> +						migratetype,&did_some_progress);
> +			if (page)
> +				goto got_pg;
> +			if (!did_some_progress) {
> +				BUG_ON(gfp_mask & __GFP_NOFAIL);
> +				goto nopage;
> +			}
> +		}
>  		/* Wait for some write requests to complete then retry */
>  		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
>  		goto rebalance;
> -- 
> 2.1.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
