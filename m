Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 22D2D6B3F84
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 08:38:10 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b7so9188941eda.10
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 05:38:10 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t22si331717edr.225.2018.11.26.05.38.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 05:38:08 -0800 (PST)
Subject: Re: [PATCH 3/5] mm: Use alloc_flags to record if kswapd can wake
References: <20181123114528.28802-1-mgorman@techsingularity.net>
 <20181123114528.28802-4-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <39711f99-1a2a-67d3-5cb0-a63ac739a917@suse.cz>
Date: Mon, 26 Nov 2018 14:38:07 +0100
MIME-Version: 1.0
In-Reply-To: <20181123114528.28802-4-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 11/23/18 12:45 PM, Mel Gorman wrote:
> This is a preparation patch that copies the GFP flag __GFP_KSWAPD_RECLAIM
> into alloc_flags. This is a preparation patch only that avoids having to
> pass gfp_mask through a long callchain in a future patch.
> 
> Note that the setting in the fast path happens in alloc_flags_nofragment()
> and it may be claimed that this has nothing to do with ALLOC_NO_FRAGMENT.
> That's true in this patch but is not true later so it's done now for
> easier review to show where the flag needs to be recorded.
> 
> No functional change.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Small bug below:

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3278,10 +3278,15 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
>   * fragmentation between the Normal and DMA32 zones.
>   */
>  static inline unsigned int
> -alloc_flags_nofragment(struct zone *zone)
> +alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
>  {
> +	unsigned int alloc_flags = 0;
> +
> +	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
> +		alloc_flags |= ALLOC_KSWAPD;
> +
>  	if (zone_idx(zone) != ZONE_NORMAL)
> -		return 0;
> +		goto out;
>  
>  	/*
>  	 * If ZONE_DMA32 exists, assume it is the one after ZONE_NORMAL and
> @@ -3290,13 +3295,14 @@ alloc_flags_nofragment(struct zone *zone)
>  	 */
>  	BUILD_BUG_ON(ZONE_NORMAL - ZONE_DMA32 != 1);
>  	if (nr_online_nodes > 1 && !populated_zone(--zone))
> -		return 0;
> +		goto out;
>  
> -	return ALLOC_NOFRAGMENT;
> +out:
> +	return alloc_flags;
>  }
>  #else
>  static inline unsigned int
> -alloc_flags_nofragment(struct zone *zone)
> +alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
>  {
>  	return 0;

The !CONFIG_ZONE_DMA32 version should still set ALLOC_KSWAPD, right?

>  }
> @@ -3939,6 +3945,9 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  	} else if (unlikely(rt_task(current)) && !in_interrupt())
>  		alloc_flags |= ALLOC_HARDER;
>  
> +	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
> +		alloc_flags |= ALLOC_KSWAPD;
> +
>  #ifdef CONFIG_CMA
>  	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
>  		alloc_flags |= ALLOC_CMA;
