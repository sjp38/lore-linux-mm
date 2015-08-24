Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id B96326B0255
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 04:54:22 -0400 (EDT)
Received: by wijp15 with SMTP id p15so70526419wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 01:54:22 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id y6si6752292wix.78.2015.08.24.01.54.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 01:54:21 -0700 (PDT)
Received: by wijp15 with SMTP id p15so70525793wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 01:54:20 -0700 (PDT)
Date: Mon, 24 Aug 2015 10:54:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [REPOST] [PATCH 2/2] mm: Fix potentially scheduling in
 GFP_ATOMIC allocations.
Message-ID: <20150824085419.GD17078@dhcp22.suse.cz>
References: <201508231623.DED13020.tFOHFVFQOSOLMJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201508231623.DED13020.tFOHFVFQOSOLMJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Sun 23-08-15 16:23:37, Tetsuo Handa wrote:
> >From 08a638e04351386ab03cd1223988ac7940d4d3aa Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 1 Aug 2015 22:46:12 +0900
> Subject: [PATCH 2/2] mm: Fix potentially scheduling in GFP_ATOMIC
>  allocations.
> 
> Currently, if somebody does GFP_ATOMIC | __GFP_NOFAIL allocation,

This combination of flags is broken by definition and I fail to see it
being used anywhere in the kernel.

> wait_iff_congested() might be called via __alloc_pages_high_priority()
> before reaching
> 
>   if (!wait) {
>     WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
>     goto nopage;
>   }

> 
> because gfp_to_alloc_flags() includes ALLOC_NO_WATERMARKS if TIF_MEMDIE
> was set.
> 
> We need to check for __GFP_WAIT flag at __alloc_pages_high_priority()
> in order to make sure that we won't schedule.

I do not think this is an improvement. It is true we are already failing
__GFP_NOFAIL & ~__GFP_WAIT but I believe it doesn't make much sense
to replace one buggy behavior (sleeping in atomic context) by another
(failing __GFP_NOFAIL). It is the caller which should be fixed here. We
should get "scheduling while atomic:" and the trace with the current
code so we are not loosing any debugging options.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/page_alloc.c | 13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 37a0390..f9f09fa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2917,16 +2917,15 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
>  {
>  	struct page *page;
>  
> -	do {
> +	for (;;) {
>  		page = get_page_from_freelist(gfp_mask, order,
>  						ALLOC_NO_WATERMARKS, ac);
>  
> -		if (!page && gfp_mask & __GFP_NOFAIL)
> -			wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC,
> -									HZ/50);
> -	} while (!page && (gfp_mask & __GFP_NOFAIL));
> -
> -	return page;
> +		if (page || (gfp_mask & (__GFP_NOFAIL | __GFP_WAIT)) !=
> +		    (__GFP_NOFAIL | __GFP_WAIT))
> +			return page;
> +		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
> +	}
>  }
>  
>  static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
