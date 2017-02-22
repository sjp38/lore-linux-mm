Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 168266B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 06:41:08 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id 134so2668342wmj.6
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 03:41:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n54si1392799wrn.247.2017.02.22.03.41.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 03:41:06 -0800 (PST)
Date: Wed, 22 Feb 2017 12:41:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm/vmscan: fix high cpu usage of kswapd if there
Message-ID: <20170222114105.GI5753@dhcp22.suse.cz>
References: <1487754288-5149-1-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1487754288-5149-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Wed 22-02-17 17:04:48, Jia He wrote:
> When I try to dynamically allocate the hugepages more than system total
> free memory:
> e.g. echo 4000 >/proc/sys/vm/nr_hugepages

I assume that the command has terminated with less huge pages allocated
than requested but

> Node 3, zone      DMA
[...]
>   pages free     2951
>         min      2821
>         low      3526
>         high     4231

it left the zone below high watermark with

>    node_scanned  0
>         spanned  245760
>         present  245760
>         managed  245388
>       nr_free_pages 2951
>       nr_zone_inactive_anon 0
>       nr_zone_active_anon 0
>       nr_zone_inactive_file 0
>       nr_zone_active_file 0

no pages reclaimable, so kswapd will not go to sleep. It would be quite
easy and comfortable to call it a misconfiguration but it seems that
it might be quite easy to hit with NUMA machines which have large
differences in the node sizes. I guess it makes sense to back off
the kswapd rather than burning CPU without any way to make forward
progress.

[...]

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 532a2a7..a05e3ab 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3139,7 +3139,8 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
>  		if (!managed_zone(zone))
>  			continue;
>  
> -		if (!zone_balanced(zone, order, classzone_idx))
> +		if (!zone_balanced(zone, order, classzone_idx)
> +			&& zone_reclaimable_pages(zone))
>  			return false;

OK, this makes some sense, although zone_reclaimable_pages doesn't count
SLAB reclaimable pages. So we might go to sleep with a reclaimable slab
still around. This is not really easy to address because the reclaimable
slab doesn't really imply that those pages will be reclaimed...

>  	}
>  
> @@ -3502,6 +3503,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
>  {
>  	pg_data_t *pgdat;
>  	int z;
> +	int node_has_relaimable_pages = 0;
>  
>  	if (!managed_zone(zone))
>  		return;
> @@ -3522,8 +3524,15 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
>  
>  		if (zone_balanced(zone, order, classzone_idx))
>  			return;
> +
> +		if (!zone_reclaimable_pages(zone))
> +			node_has_relaimable_pages = 1;

What, this doesn't make any sense? Did you mean if (zone_reclaimable_pages)?

>  	}
>  
> +	/* Dont wake kswapd if no reclaimable pages */
> +	if (!node_has_relaimable_pages)
> +		return;
> +
>  	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
>  	wake_up_interruptible(&pgdat->kswapd_wait);
>  }
> -- 
> 1.8.5.6
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
