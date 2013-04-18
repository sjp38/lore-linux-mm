Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 411936B0002
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 11:10:37 -0400 (EDT)
Date: Thu, 18 Apr 2013 08:09:42 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 04/10] mm: vmscan: Decide whether to compact the pgdat
 based on reclaim progress
Message-ID: <20130418150942.GF2018@cmpxchg.org>
References: <1365710278-6807-1-git-send-email-mgorman@suse.de>
 <1365710278-6807-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365710278-6807-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 11, 2013 at 08:57:52PM +0100, Mel Gorman wrote:
> @@ -2763,7 +2769,21 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  		for (i = 0; i <= end_zone; i++) {
>  			struct zone *zone = pgdat->node_zones + i;
>  
> +			if (!populated_zone(zone))
> +				continue;
> +
>  			lru_pages += zone_reclaimable_pages(zone);
> +
> +			/*
> +			 * If any zone is currently balanced then kswapd will
> +			 * not call compaction as it is expected that the
> +			 * necessary pages are already available.
> +			 */
> +			if (pgdat_needs_compaction &&
> +					zone_watermark_ok(zone, order,
> +						low_wmark_pages(zone),
> +						*classzone_idx, 0))
> +				pgdat_needs_compaction = false;
>  		}
>  
>  		/*
> @@ -2832,7 +2852,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  				 * already being scanned that high
>  				 * watermark would be met at 100% efficiency.
>  				 */
> -				if (kswapd_shrink_zone(zone, &sc, lru_pages))
> +				if (kswapd_shrink_zone(zone, &sc, lru_pages,
> +						       &nr_attempted))
>  					raise_priority = false;
>  			}

There is the odd chance that the watermark is met after reclaim, would
it make sense to defer the pgdat_needs_compaction check?  Not really a
big deal, though, so:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
