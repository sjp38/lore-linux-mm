Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D5B656B0260
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:40:56 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id an2so1433558wjc.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:40:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d11si14918976wra.89.2017.01.18.01.40.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 01:40:55 -0800 (PST)
Date: Wed, 18 Jan 2017 10:40:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 3/4] mm, page_alloc: move cpuset seqcount checking to
 slowpath
Message-ID: <20170118094054.GJ7015@dhcp22.suse.cz>
References: <20170117221610.22505-1-vbabka@suse.cz>
 <20170117221610.22505-4-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117221610.22505-4-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Ganapatrao Kulkarni <gpkulkarni@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 17-01-17 23:16:09, Vlastimil Babka wrote:
> This is a preparation for the following patch to make review simpler. While
> the primary motivation is a bug fix, this could also save some cycles in the
> fast path.

I cannot say I would be happy about this patch :/ The code is still very
confusing and subtle. I really think we should get rid of
synchronization with the concurrent cpuset/mempolicy updates instead.
Have you considered that instead?

> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/page_alloc.c | 46 +++++++++++++++++++++++++---------------------
>  1 file changed, 25 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index dedadb4a779f..bbc3f015f796 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3502,12 +3502,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	struct page *page = NULL;
>  	unsigned int alloc_flags;
>  	unsigned long did_some_progress;
> -	enum compact_priority compact_priority = DEF_COMPACT_PRIORITY;
> +	enum compact_priority compact_priority;
>  	enum compact_result compact_result;
> -	int compaction_retries = 0;
> -	int no_progress_loops = 0;
> +	int compaction_retries;
> +	int no_progress_loops;
>  	unsigned long alloc_start = jiffies;
>  	unsigned int stall_timeout = 10 * HZ;
> +	unsigned int cpuset_mems_cookie;
>  
>  	/*
>  	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -3528,6 +3529,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  				(__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
>  		gfp_mask &= ~__GFP_ATOMIC;
>  
> +retry_cpuset:
> +	compaction_retries = 0;
> +	no_progress_loops = 0;
> +	compact_priority = DEF_COMPACT_PRIORITY;
> +	cpuset_mems_cookie = read_mems_allowed_begin();
> +
>  	/*
>  	 * The fast path uses conservative alloc_flags to succeed only until
>  	 * kswapd needs to be woken up, and to avoid the cost of setting up
> @@ -3699,6 +3706,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	}
>  
>  nopage:
> +	/*
> +	 * When updating a task's mems_allowed, it is possible to race with
> +	 * parallel threads in such a way that an allocation can fail while
> +	 * the mask is being updated. If a page allocation is about to fail,
> +	 * check if the cpuset changed during allocation and if so, retry.
> +	 */
> +	if (read_mems_allowed_retry(cpuset_mems_cookie))
> +		goto retry_cpuset;
> +
>  	warn_alloc(gfp_mask,
>  			"page allocation failure: order:%u", order);
>  got_pg:
> @@ -3713,7 +3729,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  			struct zonelist *zonelist, nodemask_t *nodemask)
>  {
>  	struct page *page;
> -	unsigned int cpuset_mems_cookie;
>  	unsigned int alloc_flags = ALLOC_WMARK_LOW;
>  	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
>  	struct alloc_context ac = {
> @@ -3750,9 +3765,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	if (IS_ENABLED(CONFIG_CMA) && ac.migratetype == MIGRATE_MOVABLE)
>  		alloc_flags |= ALLOC_CMA;
>  
> -retry_cpuset:
> -	cpuset_mems_cookie = read_mems_allowed_begin();
> -
>  	/* Dirty zone balancing only done in the fast path */
>  	ac.spread_dirty_pages = (gfp_mask & __GFP_WRITE);
>  
> @@ -3765,6 +3777,10 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  					ac.high_zoneidx, ac.nodemask);
>  	if (!ac.preferred_zoneref->zone) {
>  		page = NULL;
> +		/*
> +		 * This might be due to race with cpuset_current_mems_allowed
> +		 * update, so make sure we retry with original nodemask.
> +		 */
>  		goto no_zone;
>  	}
>  
> @@ -3787,27 +3803,15 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	 * we could end up iterating over non-eligible zones endlessly.
>  	 */
>  	if (unlikely(ac.nodemask != nodemask)) {
> +no_zone:
>  		ac.nodemask = nodemask;
>  		ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
>  						ac.high_zoneidx, ac.nodemask);
> -		if (!ac.preferred_zoneref->zone)
> -			goto no_zone;
> +		/* If we have NULL preferred zone, slowpath wll handle that */
>  	}
>  
>  	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
>  
> -no_zone:
> -	/*
> -	 * When updating a task's mems_allowed, it is possible to race with
> -	 * parallel threads in such a way that an allocation can fail while
> -	 * the mask is being updated. If a page allocation is about to fail,
> -	 * check if the cpuset changed during allocation and if so, retry.
> -	 */
> -	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie))) {
> -		alloc_mask = gfp_mask;
> -		goto retry_cpuset;
> -	}
> -
>  out:
>  	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) && page &&
>  	    unlikely(memcg_kmem_charge(page, gfp_mask, order) != 0)) {
> -- 
> 2.11.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
