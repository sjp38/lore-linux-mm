Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id D4D156B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 08:41:44 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id ga2so11910487lbc.0
        for <linux-mm@kvack.org>; Thu, 12 May 2016 05:41:44 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id m71si16592530wmb.117.2016.05.12.05.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 05:41:43 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id r12so15968228wme.0
        for <linux-mm@kvack.org>; Thu, 12 May 2016 05:41:42 -0700 (PDT)
Date: Thu, 12 May 2016 14:41:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 02/13] mm, page_alloc: set alloc_flags only once in slowpath
Message-ID: <20160512124141.GH4200@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-3-git-send-email-vbabka@suse.cz>
 <201605102028.AAC26596.SMHOQOtLOFFFVJ@I-love.SAKURA.ne.jp>
 <5731D453.8050104@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5731D453.8050104@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, rientjes@google.com, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Tue 10-05-16 14:30:11, Vlastimil Babka wrote:
[...]
> >From 68f09f1d4381c7451238b4575557580380d8bf30 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Fri, 29 Apr 2016 11:51:17 +0200
> Subject: [RFC 02/13] mm, page_alloc: set alloc_flags only once in slowpath
> 
> In __alloc_pages_slowpath(), alloc_flags doesn't change after it's initialized,
> so move the initialization above the retry: label. Also make the comment above
> the initialization more descriptive.
> 
> The only exception in the alloc_flags being constant is ALLOC_NO_WATERMARKS,
> which may change due to TIF_MEMDIE being set on the allocating thread. We can
> fix this, and make the code simpler and a bit more effective at the same time,
> by moving the part that determines ALLOC_NO_WATERMARKS from
> gfp_to_alloc_flags() to gfp_pfmemalloc_allowed(). This means we don't have to
> mask out ALLOC_NO_WATERMARKS in several places in __alloc_pages_slowpath()
> anymore.  The only test for the flag can instead call gfp_pfmemalloc_allowed().

I like this _very_ much! gfp_to_alloc_flags was really ugly doing two
separate things and it is nice to split them up and give the whole thing
more sense. gfp_pfmemalloc_allowed() is the bright example of it.

> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
 
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 49 ++++++++++++++++++++++++-------------------------
>  1 file changed, 24 insertions(+), 25 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a50184ec6ca0..1b58facf4b5e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3216,8 +3216,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  	 */
>  	count_vm_event(COMPACTSTALL);
>  
> -	page = get_page_from_freelist(gfp_mask, order,
> -					alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
> +	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
>  
>  	if (page) {
>  		struct zone *zone = page_zone(page);
> @@ -3366,8 +3365,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
>  		return NULL;
>  
>  retry:
> -	page = get_page_from_freelist(gfp_mask, order,
> -					alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
> +	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
>  
>  	/*
>  	 * If an allocation failed after direct reclaim, it could be because
> @@ -3425,16 +3423,6 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  	} else if (unlikely(rt_task(current)) && !in_interrupt())
>  		alloc_flags |= ALLOC_HARDER;
>  
> -	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
> -		if (gfp_mask & __GFP_MEMALLOC)
> -			alloc_flags |= ALLOC_NO_WATERMARKS;
> -		else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
> -			alloc_flags |= ALLOC_NO_WATERMARKS;
> -		else if (!in_interrupt() &&
> -				((current->flags & PF_MEMALLOC) ||
> -				 unlikely(test_thread_flag(TIF_MEMDIE))))
> -			alloc_flags |= ALLOC_NO_WATERMARKS;
> -	}
>  #ifdef CONFIG_CMA
>  	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
>  		alloc_flags |= ALLOC_CMA;
> @@ -3444,7 +3432,19 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  
>  bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  {
> -	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS);
> +	if (unlikely(gfp_mask & __GFP_NOMEMALLOC))
> +		return false;
> +
> +	if (gfp_mask & __GFP_MEMALLOC)
> +		return true;
> +	if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
> +		return true;
> +	if (!in_interrupt() &&
> +			((current->flags & PF_MEMALLOC) ||
> +			 unlikely(test_thread_flag(TIF_MEMDIE))))
> +		return true;
> +
> +	return false;
>  }
>  
>  static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
> @@ -3579,25 +3579,24 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  				(__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
>  		gfp_mask &= ~__GFP_ATOMIC;
>  
> -retry:
> -	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
> -		wake_all_kswapds(order, ac);
> -
>  	/*
> -	 * OK, we're below the kswapd watermark and have kicked background
> -	 * reclaim. Now things get more complex, so set up alloc_flags according
> -	 * to how we want to proceed.
> +	 * The fast path uses conservative alloc_flags to succeed only until
> +	 * kswapd needs to be woken up, and to avoid the cost of setting up
> +	 * alloc_flags precisely. So we do that now.
>  	 */
>  	alloc_flags = gfp_to_alloc_flags(gfp_mask);
>  
> +retry:
> +	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
> +		wake_all_kswapds(order, ac);
> +
>  	/* This is the last chance, in general, before the goto nopage. */
> -	page = get_page_from_freelist(gfp_mask, order,
> -				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
> +	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
>  	if (page)
>  		goto got_pg;
>  
>  	/* Allocate without watermarks if the context allows */
> -	if (alloc_flags & ALLOC_NO_WATERMARKS) {
> +	if (gfp_pfmemalloc_allowed(gfp_mask)) {
>  		/*
>  		 * Ignore mempolicies if ALLOC_NO_WATERMARKS on the grounds
>  		 * the allocation is high priority and these type of
> -- 
> 2.8.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
