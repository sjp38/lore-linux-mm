Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A04B86B0260
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 07:19:24 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u144so6215070wmu.1
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 04:19:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id de9si30862993wjc.91.2016.11.23.04.19.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Nov 2016 04:19:23 -0800 (PST)
Subject: Re: [RFC 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
References: <20161123064925.9716-1-mhocko@kernel.org>
 <20161123064925.9716-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <87b89181-a141-611d-c772-c5e483aa4f49@suse.cz>
Date: Wed, 23 Nov 2016 13:19:20 +0100
MIME-Version: 1.0
In-Reply-To: <20161123064925.9716-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 11/23/2016 07:49 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> __alloc_pages_may_oom makes sure to skip the OOM killer depending on
> the allocation request. This includes lowmem requests, costly high
> order requests and others. For a long time __GFP_NOFAIL acted as an
> override for all those rules. This is not documented and it can be quite
> surprising as well. E.g. GFP_NOFS requests are not invoking the OOM
> killer but GFP_NOFS|__GFP_NOFAIL does so if we try to convert some of
> the existing open coded loops around allocator to nofail request (and we
> have done that in the past) then such a change would have a non trivial
> side effect which is not obvious. Note that the primary motivation for
> skipping the OOM killer is to prevent from pre-mature invocation.
>
> The exception has been added by 82553a937f12 ("oom: invoke oom killer
> for __GFP_NOFAIL"). The changelog points out that the oom killer has to
> be invoked otherwise the request would be looping for ever. But this
> argument is rather weak because the OOM killer doesn't really guarantee
> any forward progress for those exceptional cases - e.g. it will hardly
> help to form costly order - I believe we certainly do not want to kill
> all processes and eventually panic the system just because there is a
> nasty driver asking for order-9 page with GFP_NOFAIL not realizing all
> the consequences - it is much better this request would loop for ever
> than the massive system disruption, lowmem is also highly unlikely to be
> freed during OOM killer and GFP_NOFS request could trigger while there
> is still a lot of memory pinned by filesystems.
>
> This patch simply removes the __GFP_NOFAIL special case in order to have
> a more clear semantic without surprising side effects. Instead we do
> allow nofail requests to access memory reserves to move forward in both
> cases when the OOM killer is invoked and when it should be supressed.
> __alloc_pages_nowmark helper has been introduced for that purpose.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

This makes some sense to me, but there might be unpleasant consequences, 
e.g. due to allowing costly allocations without reserves. I guess only 
testing will show...

Also some comments below.

> ---
>  mm/oom_kill.c   |  2 +-
>  mm/page_alloc.c | 95 +++++++++++++++++++++++++++++++++++----------------------
>  2 files changed, 59 insertions(+), 38 deletions(-)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ec9f11d4f094..12a6fce85f61 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1013,7 +1013,7 @@ bool out_of_memory(struct oom_control *oc)
>  	 * make sure exclude 0 mask - all other users should have at least
>  	 * ___GFP_DIRECT_RECLAIM to get here.
>  	 */
> -	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
> +	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
>  		return true;
>
>  	/*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 76c0b6bb0baf..7102641147c4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3044,6 +3044,25 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
>  }
>
>  static inline struct page *
> +__alloc_pages_nowmark(gfp_t gfp_mask, unsigned int order,
> +						const struct alloc_context *ac)
> +{
> +	struct page *page;
> +
> +	page = get_page_from_freelist(gfp_mask, order,
> +			ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
> +	/*
> +	 * fallback to ignore cpuset restriction if our nodes
> +	 * are depleted
> +	 */
> +	if (!page)
> +		page = get_page_from_freelist(gfp_mask, order,
> +				ALLOC_NO_WATERMARKS, ac);

Is this enough? Look at what __alloc_pages_slowpath() does since 
e46e7b77c909 ("mm, page_alloc: recalculate the preferred zoneref if the 
context can ignore memory policies").

...

> -	}
>  	/* Exhausted what can be done so it's blamo time */
> -	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> +	if (out_of_memory(&oc)) {

This removes the warning, but also the check for __GFP_NOFAIL itself. 
Was it what you wanted?

>  		*did_some_progress = 1;
>
> -		if (gfp_mask & __GFP_NOFAIL) {
> -			page = get_page_from_freelist(gfp_mask, order,
> -					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
> -			/*
> -			 * fallback to ignore cpuset restriction if our nodes
> -			 * are depleted
> -			 */
> -			if (!page)
> -				page = get_page_from_freelist(gfp_mask, order,
> -					ALLOC_NO_WATERMARKS, ac);
> -		}
> +		/*
> +		 * Help non-failing allocations by giving them access to memory
> +		 * reserves
> +		 */
> +		if (gfp_mask & __GFP_NOFAIL)
> +			page = __alloc_pages_nowmark(gfp_mask, order, ac);
>  	}
>  out:
>  	mutex_unlock(&oom_lock);
> @@ -3725,6 +3738,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 */
>  		WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
>
> +		/*
> +		 * Help non-failing allocations by giving them access to memory
> +		 * reserves
> +		 */
> +		page = __alloc_pages_nowmark(gfp_mask, order, ac);
> +		if (page)
> +			goto got_pg;
> +
>  		cond_resched();
>  		goto retry;
>  	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
