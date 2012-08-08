Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 9F6366B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 22:06:18 -0400 (EDT)
Date: Wed, 8 Aug 2012 11:07:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/6] mm: kswapd: Continue reclaiming for
 reclaim/compaction if the minimum number of pages have not been reclaimed
Message-ID: <20120808020749.GC4247@bbox>
References: <1344342677-5845-1-git-send-email-mgorman@suse.de>
 <1344342677-5845-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1344342677-5845-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 07, 2012 at 01:31:14PM +0100, Mel Gorman wrote:
> When direct reclaim is running reclaim/compaction, there is a minimum
> number of pages it reclaims. As it must be under the low watermark to be
> in direct reclaim it has also woken kswapd to do some work. This patch
> has kswapd use the same logic as direct reclaim to reclaim a minimum
> number of pages so compaction can run later.

-ENOPARSE by my stupid brain.
Could you elaborate a bit more?

> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/vmscan.c |   19 ++++++++++++++++---
>  1 file changed, 16 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 0cb2593..afdec93 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1701,7 +1701,7 @@ static bool in_reclaim_compaction(struct scan_control *sc)
>   * calls try_to_compact_zone() that it will have enough free pages to succeed.
>   * It will give up earlier than that if there is difficulty reclaiming pages.
>   */
> -static inline bool should_continue_reclaim(struct lruvec *lruvec,
> +static bool should_continue_reclaim(struct lruvec *lruvec,
>  					unsigned long nr_reclaimed,
>  					unsigned long nr_scanned,
>  					struct scan_control *sc)
> @@ -1768,6 +1768,17 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
>  	}
>  }
>  
> +static inline bool should_continue_reclaim_zone(struct zone *zone,
> +					unsigned long nr_reclaimed,
> +					unsigned long nr_scanned,
> +					struct scan_control *sc)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_iter(NULL, NULL, NULL);
> +	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
> +
> +	return should_continue_reclaim(lruvec, nr_reclaimed, nr_scanned, sc);
> +}
> +
>  /*
>   * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
>   */
> @@ -2496,8 +2507,10 @@ loop_again:
>  			 */
>  			testorder = order;
>  			if (COMPACTION_BUILD && order &&
> -					compaction_suitable(zone, order) !=
> -						COMPACT_SKIPPED)
> +					!should_continue_reclaim_zone(zone,
> +						nr_soft_reclaimed,

nr_soft_reclaimed is always zero with !CONFIG_MEMCG.
So should_continue_reclaim_zone would return normally true in case of
non-__GFP_REPEAT allocation. Is it intentional?


> +						sc.nr_scanned - nr_soft_scanned,
> +						&sc))
>  				testorder = 0;
>  
>  			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
> -- 
> 1.7.9.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
