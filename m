Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 31E966B006C
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 20:07:20 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id hl2so8693089igb.2
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 17:07:20 -0800 (PST)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com. [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id z5si2473854igl.33.2014.12.16.17.07.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Dec 2014 17:07:19 -0800 (PST)
Received: by mail-ie0-f176.google.com with SMTP id tr6so13554366ieb.7
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 17:07:18 -0800 (PST)
Date: Tue, 16 Dec 2014 17:07:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Stalled MM patches for review
In-Reply-To: <20141216030658.GA18569@phnom.home.cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1412161650540.19867@chino.kir.corp.google.com>
References: <20141215150207.67c9a25583c04202d9f4508e@linux-foundation.org> <548F7541.8040407@jp.fujitsu.com> <20141216030658.GA18569@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, 15 Dec 2014, Johannes Weiner wrote:

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

Hmm, my patch which removed this already seems to have been yanked from 
-mm because this is seen as an alternative.  Not sure why it couldn't have 
been rebased on top of it.

>  extern struct task_struct *find_lock_task_mm(struct task_struct *p);
>  
>  /* sysctls */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 616a2c956b4b..88b64c09a8c0 100644
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

I initially didn't care much for using did_some_progress as a boolean 
value for __alloc_pages_may_oom() to determine whether the oom killer 
(either already running or having been called) should lead to future 
memory freeing, but its use for reclaim is similar with the exception that 
we don't need to actually know how much memory was freed since this check 
is now already under should_alloc_retry().  Pretty creative.

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

Aside, outside the scope of this particular patch: I think this should 
probably be schedule_timeout_killable(1) instead in the case where current 
has already been killed as a result of the pending oom kill.  It's 
probably not a huge deal since we'll drop the oom zonelist locks almost 
immediately after that and we just have to wait to be scheduled again, but 
it is probably more correct to do schedule_timeout_killable(1).

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
> @@ -2701,51 +2715,25 @@ rebalance:
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

Missing a space.

> +			if (page)
> +				goto got_pg;
> +			if (!did_some_progress)
> +				goto nopage;
> +		}
>  		/* Wait for some write requests to complete then retry */
>  		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
>  		goto rebalance;

This is broken because it does not recall gfp_to_alloc_flags().  If 
current is the oom kill victim, then ALLOC_NO_WATERMARKS never gets set 
properly and the slowpath will end up looping forever.  The "restart" 
label which was removed in this patch needs to be reintroduced, and it can 
probably be moved to directly before gfp_to_alloc_flags().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
