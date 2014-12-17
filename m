Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 530226B006E
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 10:52:06 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id r20so16209708wiv.6
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 07:52:05 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hs6si7365031wjb.68.2014.12.17.07.52.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 07:52:05 -0800 (PST)
Date: Wed, 17 Dec 2014 16:51:56 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Stalled MM patches for review
Message-ID: <20141217155156.GA24889@dhcp22.suse.cz>
References: <20141215150207.67c9a25583c04202d9f4508e@linux-foundation.org>
 <548F7541.8040407@jp.fujitsu.com>
 <20141216030658.GA18569@phnom.home.cmpxchg.org>
 <alpine.DEB.2.10.1412161650540.19867@chino.kir.corp.google.com>
 <20141217021302.GA14148@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141217021302.GA14148@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue 16-12-14 21:13:02, Johannes Weiner wrote:
[...]
> From 45362d1920340716ef58bf1024d9674b5dfa809e Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Tue, 16 Dec 2014 21:04:24 -0500
> Subject: [patch] mm: page_alloc: embed OOM killing naturally into allocation
>  slowpath fix
> 
> When retrying the allocation after potentially invoking OOM, make sure
> the alloc flags are recalculated, as they have to consider TIF_MEMDIE.
> 
> Restore the original restart label, but rename it to 'retry' to match
> the should_alloc_retry() it depends on.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Missed that too. Well spotted!
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/page_alloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 83ec725aec36..e8f5997c557c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2673,6 +2673,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
>  		goto nopage;
>  
> +retry:
>  	if (!(gfp_mask & __GFP_NO_KSWAPD))
>  		wake_all_kswapds(order, zonelist, high_zoneidx,
>  				preferred_zone, nodemask);
> @@ -2695,7 +2696,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		classzone_idx = zonelist_zone_idx(preferred_zoneref);
>  	}
>  
> -rebalance:
>  	/* This is the last chance, in general, before the goto nopage. */
>  	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
>  			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
> @@ -2823,7 +2823,7 @@ rebalance:
>  		}
>  		/* Wait for some write requests to complete then retry */
>  		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
> -		goto rebalance;
> +		goto retry;
>  	} else {
>  		/*
>  		 * High-order allocations do not necessarily loop after
> -- 
> 2.1.3
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
