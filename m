Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id B346582F84
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 09:57:48 -0500 (EST)
Received: by wmvv187 with SMTP id v187so282458957wmv.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 06:57:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h3si4555464wjw.15.2015.11.18.06.57.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 06:57:46 -0800 (PST)
Subject: Re: [PATCH 2/2] mm: do not loop over ALLOC_NO_WATERMARKS without
 triggering reclaim
References: <1447680139-16484-1-git-send-email-mhocko@kernel.org>
 <1447680139-16484-3-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <564C91E9.8000904@suse.cz>
Date: Wed, 18 Nov 2015 15:57:45 +0100
MIME-Version: 1.0
In-Reply-To: <1447680139-16484-3-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 11/16/2015 02:22 PM, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __alloc_pages_slowpath is looping over ALLOC_NO_WATERMARKS requests if
> __GFP_NOFAIL is requested. This is fragile because we are basically
> relying on somebody else to make the reclaim (be it the direct reclaim
> or OOM killer) for us. The caller might be holding resources (e.g.
> locks) which block other other reclaimers from making any progress for
> example. Remove the retry loop and rely on __alloc_pages_slowpath to
> invoke all allowed reclaim steps and retry logic.
> 
> We have to be careful about __GFP_NOFAIL allocations from the
> PF_MEMALLOC context even though this is a very bad idea to begin with
> because no progress can be gurateed at all.  We shouldn't break the
> __GFP_NOFAIL semantic here though. It could be argued that this is
> essentially GFP_NOWAIT context which we do not support but PF_MEMALLOC
> is much harder to check for existing users because they might happen
> deep down the code path performed much later after setting the flag
> so we cannot really rule out there is no kernel path triggering this
> combination.
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/page_alloc.c | 32 ++++++++++++++++++--------------
>  1 file changed, 18 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b153fa3d0b9b..df7746280427 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3046,32 +3046,36 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 * allocations are system rather than user orientated
>  		 */
>  		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
> -		do {
> -			page = get_page_from_freelist(gfp_mask, order,
> -							ALLOC_NO_WATERMARKS, ac);
> -			if (page)
> -				goto got_pg;
> -
> -			if (gfp_mask & __GFP_NOFAIL)
> -				wait_iff_congested(ac->preferred_zone,
> -						   BLK_RW_ASYNC, HZ/50);

I've been thinking if the lack of unconditional wait_iff_congested() can affect
something negatively. I guess not?

> -		} while (gfp_mask & __GFP_NOFAIL);
> +		page = get_page_from_freelist(gfp_mask, order,
> +						ALLOC_NO_WATERMARKS, ac);
> +		if (page)
> +			goto got_pg;
>  	}
>  
>  	/* Caller is not willing to reclaim, we can't balance anything */
>  	if (!can_direct_reclaim) {
>  		/*
> -		 * All existing users of the deprecated __GFP_NOFAIL are
> -		 * blockable, so warn of any new users that actually allow this
> -		 * type of allocation to fail.
> +		 * All existing users of the __GFP_NOFAIL are blockable, so warn
> +		 * of any new users that actually allow this type of allocation
> +		 * to fail.
>  		 */
>  		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
>  		goto nopage;
>  	}
>  
>  	/* Avoid recursion of direct reclaim */
> -	if (current->flags & PF_MEMALLOC)
> +	if (current->flags & PF_MEMALLOC) {
> +		/*
> +		 * __GFP_NOFAIL request from this context is rather bizarre
> +		 * because we cannot reclaim anything and only can loop waiting
> +		 * for somebody to do a work for us.
> +		 */
> +		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> +			cond_resched();
> +			goto retry;
> +		}
>  		goto nopage;
> +	}
>  
>  	/* Avoid allocations with no watermarks from looping endlessly */
>  	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
