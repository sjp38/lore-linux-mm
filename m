Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA536B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 05:02:10 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u108so43400131wrb.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 02:02:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si23722312wro.132.2017.03.13.02.02.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 02:02:09 -0700 (PDT)
Date: Mon, 13 Mar 2017 10:02:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix condition for throttle_direct_reclaim
Message-ID: <20170313090206.GC31518@dhcp22.suse.cz>
References: <20170310194620.5021-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170310194620.5021-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 10-03-17 11:46:20, Shakeel Butt wrote:
> Recently kswapd has been modified to give up after MAX_RECLAIM_RETRIES
> number of unsucessful iterations. Before going to sleep, kswapd thread
> will unconditionally wakeup all threads sleeping on pfmemalloc_wait.
> However the awoken threads will recheck the watermarks and wake the
> kswapd thread and sleep again on pfmemalloc_wait. There is a chance
> of continuous back and forth between kswapd and direct reclaiming
> threads if the kswapd keep failing and thus defeat the purpose of
> adding backoff mechanism to kswapd. So, add kswapd_failures check
> on the throttle_direct_reclaim condition.

I have to say I really do not like this. kswapd_failures shouldn't
really be checked outside of the kswapd context. The
pfmemalloc_watermark_ok/throttle_direct_reclaim is quite complex even
without putting another variable into it. I wish we rather replace this
throttling by something else. Johannes had an idea to throttle by the
number of reclaimers.

Anyway, I am wondering whether we can hit this issue in
practice? Have you seen it happening or is this a result of the code
review? I would assume that that !zone_reclaimable_pages check in
pfmemalloc_watermark_ok should help to some degree.

> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  mm/vmscan.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bae698484e8e..b2d24cc7a161 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2819,6 +2819,12 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
>  	return wmark_ok;
>  }
>  
> +static bool should_throttle_direct_reclaim(pg_data_t *pgdat)
> +{
> +	return (pgdat->kswapd_failures < MAX_RECLAIM_RETRIES &&
> +		!pfmemalloc_watermark_ok(pgdat));
> +}
> +
>  /*
>   * Throttle direct reclaimers if backing storage is backed by the network
>   * and the PFMEMALLOC reserve for the preferred node is getting dangerously
> @@ -2873,7 +2879,7 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
>  
>  		/* Throttle based on the first usable node */
>  		pgdat = zone->zone_pgdat;
> -		if (pfmemalloc_watermark_ok(pgdat))
> +		if (!should_throttle_direct_reclaim(pgdat))
>  			goto out;
>  		break;
>  	}
> @@ -2895,14 +2901,14 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
>  	 */
>  	if (!(gfp_mask & __GFP_FS)) {
>  		wait_event_interruptible_timeout(pgdat->pfmemalloc_wait,
> -			pfmemalloc_watermark_ok(pgdat), HZ);
> +			!should_throttle_direct_reclaim(pgdat), HZ);
>  
>  		goto check_pending;
>  	}
>  
>  	/* Throttle until kswapd wakes the process */
>  	wait_event_killable(zone->zone_pgdat->pfmemalloc_wait,
> -		pfmemalloc_watermark_ok(pgdat));
> +		!should_throttle_direct_reclaim(pgdat));
>  
>  check_pending:
>  	if (fatal_signal_pending(current))
> -- 
> 2.12.0.246.ga2ecc84866-goog
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
