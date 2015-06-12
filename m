Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF176B0032
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 03:05:11 -0400 (EDT)
Received: by padev16 with SMTP id ev16so17576124pad.0
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 00:05:10 -0700 (PDT)
Received: from out4133-130.mail.aliyun.com (out4133-130.mail.aliyun.com. [42.120.133.130])
        by mx.google.com with ESMTP id mx8si4069838pdb.255.2015.06.12.00.05.08
        for <linux-mm@kvack.org>;
        Fri, 12 Jun 2015 00:05:09 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [PATCH 07/25] mm, vmscan: Make kswapd think of reclaim in terms of nodes
Date: Fri, 12 Jun 2015 15:05:00 +0800
Message-ID: <00ea01d0a4de$19f165d0$4dd43170$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

> -	/* Reclaim above the high watermark. */
> -	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
> +	/* Aim to reclaim above all the zone high watermarks */
> +	for (z = 0; z <= end_zone; z++) {
> +		zone = pgdat->node_zones + end_zone;
s/end_zone/z/ ?
> +		nr_to_reclaim += high_wmark_pages(zone);
> 
[...]
> @@ -3280,13 +3177,26 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  			compact_pgdat(pgdat, order);
> 
>  		/*
> +		 * Stop reclaiming if any eligible zone is balanced and clear
> +		 * node writeback or congested.
> +		 */
> +		for (i = 0; i <= *classzone_idx; i++) {
> +			zone = pgdat->node_zones + i;
> +
> +			if (zone_balanced(zone, sc.order, 0, *classzone_idx)) {
> +				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
> +				clear_bit(PGDAT_DIRTY, &pgdat->flags);
> +				break;
s/break/goto out/ ?
> +			}
> +		}
> +
> +		/*
>  		 * Raise priority if scanning rate is too low or there was no
>  		 * progress in reclaiming pages
>  		 */
>  		if (raise_priority || !sc.nr_reclaimed)
>  			sc.priority--;
> -	} while (sc.priority >= 1 &&
> -		 !pgdat_balanced(pgdat, order, *classzone_idx));
> +	} while (sc.priority >= 1);
> 
>  out:
>  	/*
> --
> 2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
