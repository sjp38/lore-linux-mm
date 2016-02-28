Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9FDF16B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 11:16:52 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l68so30260926wml.1
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 08:16:52 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ld8si27521595wjc.77.2016.02.28.08.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 08:16:51 -0800 (PST)
Date: Sun, 28 Feb 2016 11:16:44 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/27] mm, vmscan: Make kswapd reclaim in terms of nodes
Message-ID: <20160228161644.GC25622@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-9-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456239890-20737-9-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 03:04:31PM +0000, Mel Gorman wrote:
> @@ -3299,20 +3191,37 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  			break;
>  
>  		/*
> +		 * Stop reclaiming if any eligible zone is balanced and clear
> +		 * node writeback or congested.
> +		 */
> +		for (i = 0; i <= classzone_idx; i++) {
> +			zone = pgdat->node_zones + i;
> +			if (!populated_zone(zone))
> +				continue;
> +
> +			if (zone_balanced(zone, sc.order, 0, classzone_idx)) {
> +				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
> +				clear_bit(PGDAT_DIRTY, &pgdat->flags);
> +				goto out;
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
> -			!pgdat_balanced(pgdat, order, classzone_idx));
> +	} while (sc.priority >= 1);
>  
>  out:
>  	/*
> -	 * Return the highest zone idx we were reclaiming at so
> -	 * prepare_kswapd_sleep() makes the same decisions as here.
> +	 * Return the order we were reclaiming at so prepare_kswapd_sleep()
> +	 * makes a decision on the order we were last reclaiming at. However,
> +	 * if another caller entered the allocator slow path while kswapd
> +	 * was awake, order will remain at the higher level
>  	 */
> -	return end_zone;
> +	return order;

It's sc.order that's updated based on fragmentation, not order.

There is also a now-stale comment above the function saying it returns
the highest reclaimed zone index.

Otherwise, the patch looks good to me.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
