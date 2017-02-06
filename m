Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD3BF6B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 03:30:35 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id c7so16794446wjb.7
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 00:30:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j17si31308wrb.166.2017.02.06.00.30.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 00:30:31 -0800 (PST)
Date: Mon, 6 Feb 2017 09:30:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmscan: Skip slab scan when LRU size is zero
Message-ID: <20170206083028.GB3085@dhcp22.suse.cz>
References: <1837390276.846271.1486216381871.ref@mail.yahoo.com>
 <1837390276.846271.1486216381871@mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1837390276.846271.1486216381871@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shantanu Goel <sgoel01@yahoo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

[CC few people]

On Sat 04-02-17 13:53:01, Shantanu Goel wrote:
> Hi,
> 
> I am running 4.9.7 and noticed the slab was being scanned very
> aggressively (200K objects scanned for 1K LRU pages).  Turning on
> tracing in do_shrink_slab() revealed it was sometimes being called
> with a LRU size of zero causing the LRU scan ratio to be very large.
> The attached patch skips shrinking the slab when the LRU size is zero.
> After applying the patch the slab size I no longer see the extremely
> large object scan values.
> 
> 
> Trace output when LRU size is 0:
> 
> 
> kswapd0-93    [005] .... 49736.760169: mm_shrink_slab_start: scan_shadow_nodes+0x0/0x50 ffffffff94e6e460: nid: 0 objects to shrink 59291940 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 0 cache items 20 delta 1280 total_scan 40
> kswapd0-93    [005] .... 49736.760207: mm_shrink_slab_start: super_cache_scan+0x0/0x1a0 ffff9d79ce488cc0: nid: 0 objects to shrink 22740669 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 0 cache items 1 delta 64 total_scan 2
> kswapd0-93    [005] .... 49736.760216: mm_shrink_slab_start: super_cache_scan+0x0/0x1a0 ffff9d79db59ecc0: nid: 0 objects to shrink 79098834 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 0 cache items 642 delta 41088 total_scan 1284
> kswapd0-93    [005] .... 49736.760769: mm_shrink_slab_start: super_cache_scan+0x0/0x1a0 ffff9d79ce488cc0: nid: 0 objects to shrink 22740729 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 0 cache items 1 delta 64 total_scan 2
> kswapd0-93    [005] .... 49736.766125: mm_shrink_slab_start: scan_shadow_nodes+0x0/0x50 ffffffff94e6e460: nid: 0 objects to shrink 59293180 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 0 cache items 32 delta 2048 total_scan 64

OK, so the shrinker->nr_deferred has grown quite large. This would
suggest that the scan_shadow_nodes shrinker couldn't have made progress
in the past AFAIU. I do not think your fix is correct, though. We might
have slab pages to reclaim even when there are only few or no pages on
the particular memcg LRU list.

Could you be more specific about your workload and configuration please?

> From 97817fc71e1fd0e8fe3f385b00dd16ed64f655ab Mon Sep 17 00:00:00 2001
> From: Shantanu Goel <sgoel01@yahoo.com>
> Date: Fri, 3 Feb 2017 15:05:57 -0500
> Subject: [PATCH] vmscan: do not shrink slab if LRU size is 0
> 
> Some memcg's may not have any LRU pages in them so
> shrink_slab incorrectly ends up free'ing a huge portion
> of the slab.
> 
> Signed-off-by: Shantanu Goel <sgoel01@yahoo.com>
> ---
>  mm/vmscan.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4205b3e..7682469 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -445,6 +445,9 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
>  		return 0;
>  
> +	if (nr_eligible == 0)
> +		return 0;
> +
>  	if (nr_scanned == 0)
>  		nr_scanned = SWAP_CLUSTER_MAX;
>  
> -- 
> 2.7.4
> 


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
