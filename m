Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CCDDD6B0277
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 05:44:01 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so5522624wmu.1
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 02:44:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si30433055wjr.104.2016.11.23.02.44.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Nov 2016 02:44:00 -0800 (PST)
Subject: Re: [RFC 1/2] mm: consolidate GFP_NOFAIL checks in the allocator
 slowpath
References: <20161123064925.9716-1-mhocko@kernel.org>
 <20161123064925.9716-2-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1716580d-83aa-7a0e-75b6-3377669d5208@suse.cz>
Date: Wed, 23 Nov 2016 11:43:57 +0100
MIME-Version: 1.0
In-Reply-To: <20161123064925.9716-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 11/23/2016 07:49 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> Tetsuo Handa has pointed out that 0a0337e0d1d1 ("mm, oom: rework oom
> detection") has subtly changed semantic for costly high order requests
> with __GFP_NOFAIL and withtout __GFP_REPEAT and those can fail right now.
> My code inspection didn't reveal any such users in the tree but it is
> true that this might lead to unexpected allocation failures and
> subsequent OOPs.
>
> __alloc_pages_slowpath wrt. GFP_NOFAIL is hard to follow currently.
> There are few special cases but we are lacking a catch all place to be
> sure we will not miss any case where the non failing allocation might
> fail. This patch reorganizes the code a bit and puts all those special
> cases under nopage label which is the generic go-to-fail path. Non
> failing allocations are retried or those that cannot retry like
> non-sleeping allocation go to the failure point directly. This should
> make the code flow much easier to follow and make it less error prone
> for future changes.
>
> While we are there we have to move the stall check up to catch
> potentially looping non-failing allocations.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Yeah, that's much better than the current state.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 68 ++++++++++++++++++++++++++++++++++-----------------------
>  1 file changed, 41 insertions(+), 27 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0fbfead6aa7d..76c0b6bb0baf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3627,32 +3627,23 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto got_pg;
>
>  	/* Caller is not willing to reclaim, we can't balance anything */
> -	if (!can_direct_reclaim) {
> -		/*
> -		 * All existing users of the __GFP_NOFAIL are blockable, so warn
> -		 * of any new users that actually allow this type of allocation
> -		 * to fail.
> -		 */
> -		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
> +	if (!can_direct_reclaim)
>  		goto nopage;
> +
> +	/* Make sure we know about allocations which stall for too long */
> +	if (time_after(jiffies, alloc_start + stall_timeout)) {
> +		warn_alloc(gfp_mask,
> +			"page alloction stalls for %ums, order:%u",
> +			jiffies_to_msecs(jiffies-alloc_start), order);
> +		stall_timeout += 10 * HZ;
>  	}
>
>  	/* Avoid recursion of direct reclaim */
> -	if (current->flags & PF_MEMALLOC) {
> -		/*
> -		 * __GFP_NOFAIL request from this context is rather bizarre
> -		 * because we cannot reclaim anything and only can loop waiting
> -		 * for somebody to do a work for us.
> -		 */
> -		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> -			cond_resched();
> -			goto retry;
> -		}
> +	if (current->flags & PF_MEMALLOC)
>  		goto nopage;
> -	}
>
>  	/* Avoid allocations with no watermarks from looping endlessly */
> -	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> +	if (test_thread_flag(TIF_MEMDIE))
>  		goto nopage;
>
>
> @@ -3679,14 +3670,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
>  		goto nopage;
>
> -	/* Make sure we know about allocations which stall for too long */
> -	if (time_after(jiffies, alloc_start + stall_timeout)) {
> -		warn_alloc(gfp_mask,
> -			"page alloction stalls for %ums, order:%u",
> -			jiffies_to_msecs(jiffies-alloc_start), order);
> -		stall_timeout += 10 * HZ;
> -	}
> -
>  	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
>  				 did_some_progress > 0, &no_progress_loops))
>  		goto retry;
> @@ -3715,6 +3698,37 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	}
>
>  nopage:
> +	/*
> +	 * Make sure that __GFP_NOFAIL request doesn't leak out and make sure
> +	 * we always retry
> +	 */
> +	if (gfp_mask & __GFP_NOFAIL) {
> +		/*
> +		 * All existing users of the __GFP_NOFAIL are blockable, so warn
> +		 * of any new users that actually require GFP_NOWAIT
> +		 */
> +		if (WARN_ON_ONCE(!can_direct_reclaim))
> +			goto fail;
> +
> +		/*
> +		 * PF_MEMALLOC request from this context is rather bizarre
> +		 * because we cannot reclaim anything and only can loop waiting
> +		 * for somebody to do a work for us
> +		 */
> +		WARN_ON_ONCE(current->flags & PF_MEMALLOC);
> +
> +		/*
> +		 * non failing costly orders are a hard requirement which we
> +		 * are not prepared for much so let's warn about these users
> +		 * so that we can identify them and convert them to something
> +		 * else.
> +		 */
> +		WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
> +
> +		cond_resched();
> +		goto retry;
> +	}
> +fail:
>  	warn_alloc(gfp_mask,
>  			"page allocation failure: order:%u", order);
>  got_pg:
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
