Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7BF6B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 05:45:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x83so51925344wma.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 02:45:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y82si2064070wmc.122.2016.07.14.02.45.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 02:45:57 -0700 (PDT)
Subject: Re: [PATCH 11/34] mm, vmscan: remove duplicate logic clearing node
 congestion and dirty state
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-12-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <395397c1-9d98-2a9d-0b11-23fdfd15c259@suse.cz>
Date: Thu, 14 Jul 2016 11:45:54 +0200
MIME-Version: 1.0
In-Reply-To: <1467970510-21195-12-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On 07/08/2016 11:34 AM, Mel Gorman wrote:
> Reclaim may stall if there is too much dirty or congested data on a node.
> This was previously based on zone flags and the logic for clearing the
> flags is in two places.  As congestion/dirty tracking is now tracked on a
> per-node basis, we can remove some duplicate logic.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

I don't think it's that big a side-effect to be concerned. I would be 
more worried about frequently dirtying cache lines from other 
zone_balanced callers where, but I guess even the calls from 
wakeup_kswapd() rarely return true for zone_balanced(), otherwise the 
wakeups wouldn't have a reason to happen.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/vmscan.c | 24 ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 01fe4708e404..8b39b903bd14 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3008,7 +3008,17 @@ static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
>  {
>  	unsigned long mark = high_wmark_pages(zone);
>
> -	return zone_watermark_ok_safe(zone, order, mark, classzone_idx);
> +	if (!zone_watermark_ok_safe(zone, order, mark, classzone_idx))
> +		return false;
> +
> +	/*
> +	 * If any eligible zone is balanced then the node is not considered
> +	 * to be congested or dirty
> +	 */
> +	clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
> +	clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
> +
> +	return true;
>  }
>
>  /*
> @@ -3154,13 +3164,6 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  			if (!zone_balanced(zone, order, 0)) {
>  				classzone_idx = i;
>  				break;
> -			} else {
> -				/*
> -				 * If any eligible zone is balanced then the
> -				 * node is not considered congested or dirty.
> -				 */
> -				clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
> -				clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
>  			}
>  		}
>
> @@ -3219,11 +3222,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  			if (!populated_zone(zone))
>  				continue;
>
> -			if (zone_balanced(zone, sc.order, classzone_idx)) {
> -				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
> -				clear_bit(PGDAT_DIRTY, &pgdat->flags);
> +			if (zone_balanced(zone, sc.order, classzone_idx))
>  				goto out;
> -			}
>  		}
>
>  		/*
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
