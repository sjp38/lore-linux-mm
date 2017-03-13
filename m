Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA8E06B038C
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 16:04:29 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v190so15548480wme.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 13:04:29 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c13si1957214wrb.34.2017.03.13.13.04.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 13:04:28 -0700 (PDT)
Date: Mon, 13 Mar 2017 15:58:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: fix condition for throttle_direct_reclaim
Message-ID: <20170313195833.GA25454@cmpxchg.org>
References: <20170310194620.5021-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170310194620.5021-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Shakeel,

On Fri, Mar 10, 2017 at 11:46:20AM -0800, Shakeel Butt wrote:
> Recently kswapd has been modified to give up after MAX_RECLAIM_RETRIES
> number of unsucessful iterations. Before going to sleep, kswapd thread
> will unconditionally wakeup all threads sleeping on pfmemalloc_wait.
> However the awoken threads will recheck the watermarks and wake the
> kswapd thread and sleep again on pfmemalloc_wait. There is a chance
> of continuous back and forth between kswapd and direct reclaiming
> threads if the kswapd keep failing and thus defeat the purpose of
> adding backoff mechanism to kswapd. So, add kswapd_failures check
> on the throttle_direct_reclaim condition.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

You're right, the way it works right now is kind of lame. Did you
observe continued kswapd spinning because of the wakeup ping-pong?

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

Instead of a second helper function, could you rename
pfmemalloc_watermark_ok() and add the kswapd_failure check at the very
beginning of that function?

Because that check fits nicely with the comment about kswapd having to
be awake, too. We need kswapd operational when throttling reclaimers.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
