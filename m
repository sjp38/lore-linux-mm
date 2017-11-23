Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1106B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 07:25:42 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id s18so18852305pge.19
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 04:25:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o8si15588828pgp.359.2017.11.23.04.25.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 04:25:37 -0800 (PST)
Date: Thu, 23 Nov 2017 13:25:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Add slowpath enter/exit trace events
Message-ID: <20171123122530.ktsxgeakebfp3yep@dhcp22.suse.cz>
References: <20171123104336.25855-1-peter.enderborg@sony.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171123104336.25855-1-peter.enderborg@sony.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter.enderborg@sony.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, "David S . Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Pavel Tatashin <pasha.tatashin@oracle.com>

On Thu 23-11-17 11:43:36, peter.enderborg@sony.com wrote:
> From: Peter Enderborg <peter.enderborg@sony.com>
> 
> The warning of slow allocation has been removed, this is
> a other way to fetch that information. But you need
> to enable the trace. The exit function also returns
> information about the number of retries, how long
> it was stalled and failure reason if that happened.

I think this is just too excessive. We already have a tracepoint for the
allocation exit. All we need is an entry to have a base to compare with.
Another usecase would be to measure allocation latency. Information you
are adding can be (partially) covered by existing tracepoints.

> Signed-off-by: Peter Enderborg <peter.enderborg@sony.com>
> ---
>  include/trace/events/kmem.h | 68 +++++++++++++++++++++++++++++++++++++++++++++
>  mm/page_alloc.c             | 62 +++++++++++++++++++++++++++++++----------
>  2 files changed, 116 insertions(+), 14 deletions(-)
> 
> diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
> index eb57e30..bb882ca 100644
> --- a/include/trace/events/kmem.h
> +++ b/include/trace/events/kmem.h
> @@ -315,6 +315,74 @@ TRACE_EVENT(mm_page_alloc_extfrag,
>  		__entry->change_ownership)
>  );
>  
> +TRACE_EVENT(mm_page_alloc_slowpath_enter,
> +
> +	TP_PROTO(int alloc_order,
> +		nodemask_t *nodemask,
> +		gfp_t gfp_flags),
> +
> +	TP_ARGS(alloc_order, nodemask, gfp_flags),
> +
> +	TP_STRUCT__entry(
> +		__field(int, alloc_order)
> +		__field(nodemask_t *, nodemask)
> +		__field(gfp_t, gfp_flags)
> +	 ),
> +
> +	 TP_fast_assign(
> +		__entry->alloc_order		= alloc_order;
> +		__entry->nodemask		= nodemask;
> +		__entry->gfp_flags		= gfp_flags;
> +	 ),
> +
> +	 TP_printk("alloc_order=%d nodemask=%*pbl gfp_flags=%s",
> +		__entry->alloc_order,
> +		nodemask_pr_args(__entry->nodemask),
> +		show_gfp_flags(__entry->gfp_flags))
> +);
> +
> +TRACE_EVENT(mm_page_alloc_slowpath_exit,
> +
> +	TP_PROTO(struct page *page,
> +		int alloc_order,
> +		nodemask_t *nodemask,
> +		u64 alloc_start,
> +		gfp_t gfp_flags,
> +		int retrys,
> +		int exit),
> +
> +	TP_ARGS(page, alloc_order, nodemask, alloc_start, gfp_flags,
> +		retrys, exit),
> +
> +	TP_STRUCT__entry(__field(struct page *, page)
> +		__field(int, alloc_order)
> +		__field(nodemask_t *, nodemask)
> +		__field(u64, msdelay)
> +		__field(gfp_t, gfp_flags)
> +		__field(int, retrys)
> +		__field(int, exit)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->page	     = page;
> +		__entry->alloc_order = alloc_order;
> +		__entry->nodemask    = nodemask;
> +		__entry->msdelay     = jiffies_to_msecs(jiffies-alloc_start);
> +		__entry->gfp_flags   = gfp_flags;
> +		__entry->retrys	     = retrys;
> +		__entry->exit	     = exit;
> +	),
> +
> +	TP_printk("page=%p alloc_order=%d nodemask=%*pbl msdelay=%llu gfp_flags=%s retrys=%d exit=%d",
> +		__entry->page,
> +		__entry->alloc_order,
> +		nodemask_pr_args(__entry->nodemask),
> +		__entry->msdelay,
> +		show_gfp_flags(__entry->gfp_flags),
> +		__entry->retrys,
> +		__entry->exit)
> +);
> +
>  #endif /* _TRACE_KMEM_H */
>  
>  /* This part must be outside protection */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 48b5b01..bae9cb9 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -104,6 +104,17 @@ DEFINE_PER_CPU(struct work_struct, pcpu_drain);
>  volatile unsigned long latent_entropy __latent_entropy;
>  EXPORT_SYMBOL(latent_entropy);
>  #endif
> +enum slowpath_exit {
> +	SLOWPATH_NOZONE = -16,
> +	SLOWPATH_COMPACT_DEFERRED,
> +	SLOWPATH_CAN_NOT_DIRECT_RECLAIM,
> +	SLOWPATH_RECURSION,
> +	SLOWPATH_NO_RETRY,
> +	SLOWPATH_COSTLY_ORDER,
> +	SLOWPATH_OOM_VICTIM,
> +	SLOWPATH_NO_DIRECT_RECLAIM,
> +	SLOWPATH_ORDER
> +};
>  
>  /*
>   * Array of node states.
> @@ -3908,8 +3919,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	enum compact_result compact_result;
>  	int compaction_retries;
>  	int no_progress_loops;
> +	unsigned long alloc_start = jiffies;
>  	unsigned int cpuset_mems_cookie;
>  	int reserve_flags;
> +	enum slowpath_exit slowpath_exit;
> +	int retry_count = 0;
> +
> +	trace_mm_page_alloc_slowpath_enter(order,
> +		ac->nodemask,
> +		gfp_mask);
>  
>  	/*
>  	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -3919,7 +3937,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 */
>  	if (order >= MAX_ORDER) {
>  		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
> -		return NULL;
> +		slowpath_exit = SLOWPATH_ORDER;
> +		goto fail;
>  	}
>  
>  	/*
> @@ -3951,8 +3970,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 */
>  	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
>  					ac->high_zoneidx, ac->nodemask);
> -	if (!ac->preferred_zoneref->zone)
> +	if (!ac->preferred_zoneref->zone) {
> +		slowpath_exit = SLOWPATH_NOZONE;
>  		goto nopage;
> +	}
>  
>  	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
>  		wake_all_kswapds(order, ac);
> @@ -3998,8 +4019,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  			 * system, so we fail the allocation instead of entering
>  			 * direct reclaim.
>  			 */
> -			if (compact_result == COMPACT_DEFERRED)
> +			if (compact_result == COMPACT_DEFERRED) {
> +				slowpath_exit = SLOWPATH_COMPACT_DEFERRED;
>  				goto nopage;
> +			}
>  
>  			/*
>  			 * Looks like reclaim/compaction is worth trying, but
> @@ -4011,6 +4034,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	}
>  
>  retry:
> +	retry_count++;
>  	/* Ensure kswapd doesn't accidentally go to sleep as long as we loop */
>  	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
>  		wake_all_kswapds(order, ac);
> @@ -4036,13 +4060,16 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto got_pg;
>  
>  	/* Caller is not willing to reclaim, we can't balance anything */
> -	if (!can_direct_reclaim)
> +	if (!can_direct_reclaim) {
> +		slowpath_exit = SLOWPATH_CAN_NOT_DIRECT_RECLAIM;
>  		goto nopage;
> +	}
>  
>  	/* Avoid recursion of direct reclaim */
> -	if (current->flags & PF_MEMALLOC)
> +	if (current->flags & PF_MEMALLOC) {
> +		slowpath_exit = SLOWPATH_RECURSION;
>  		goto nopage;
> -
> +	}
>  	/* Try direct reclaim and then allocating */
>  	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
>  							&did_some_progress);
> @@ -4056,16 +4083,18 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto got_pg;
>  
>  	/* Do not loop if specifically requested */
> -	if (gfp_mask & __GFP_NORETRY)
> +	if (gfp_mask & __GFP_NORETRY) {
> +		slowpath_exit = SLOWPATH_NO_RETRY;
>  		goto nopage;
> -
> +	}
>  	/*
>  	 * Do not retry costly high order allocations unless they are
>  	 * __GFP_RETRY_MAYFAIL
>  	 */
> -	if (costly_order && !(gfp_mask & __GFP_RETRY_MAYFAIL))
> +	if (costly_order && !(gfp_mask & __GFP_RETRY_MAYFAIL)) {
> +		slowpath_exit = SLOWPATH_COSTLY_ORDER;
>  		goto nopage;
> -
> +	}
>  	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
>  				 did_some_progress > 0, &no_progress_loops))
>  		goto retry;
> @@ -4095,9 +4124,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	/* Avoid allocations with no watermarks from looping endlessly */
>  	if (tsk_is_oom_victim(current) &&
>  	    (alloc_flags == ALLOC_OOM ||
> -	     (gfp_mask & __GFP_NOMEMALLOC)))
> +	     (gfp_mask & __GFP_NOMEMALLOC))) {
> +		slowpath_exit = SLOWPATH_OOM_VICTIM;
>  		goto nopage;
> -
> +	}
>  	/* Retry as long as the OOM killer is making progress */
>  	if (did_some_progress) {
>  		no_progress_loops = 0;
> @@ -4118,9 +4148,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 * All existing users of the __GFP_NOFAIL are blockable, so warn
>  		 * of any new users that actually require GFP_NOWAIT
>  		 */
> -		if (WARN_ON_ONCE(!can_direct_reclaim))
> +		if (WARN_ON_ONCE(!can_direct_reclaim)) {
> +			slowpath_exit = SLOWPATH_NO_DIRECT_RECLAIM;
>  			goto fail;
> -
> +		}
>  		/*
>  		 * PF_MEMALLOC request from this context is rather bizarre
>  		 * because we cannot reclaim anything and only can loop waiting
> @@ -4153,6 +4184,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	warn_alloc(gfp_mask, ac->nodemask,
>  			"page allocation failure: order:%u", order);
>  got_pg:
> +	trace_mm_page_alloc_slowpath_exit(page, order, ac->nodemask,
> +		alloc_start, gfp_mask, retry_count, slowpath_exit);
> +
>  	return page;
>  }
>  
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
