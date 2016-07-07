Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5BEAB6B0253
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 21:20:58 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u201so6419628oie.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 18:20:58 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id m200si1084723iom.167.2016.07.06.18.20.56
        for <linux-mm@kvack.org>;
        Wed, 06 Jul 2016 18:20:57 -0700 (PDT)
Date: Thu, 7 Jul 2016 10:24:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 20/31] mm, vmscan: only wakeup kswapd once per node for
 the requested classzone
Message-ID: <20160707012423.GC27987@js1304-P5Q-DELUXE>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-21-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467403299-25786-21-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 01, 2016 at 09:01:28PM +0100, Mel Gorman wrote:
> kswapd is woken when zones are below the low watermark but the wakeup
> decision is not taking the classzone into account.  Now that reclaim is
> node-based, it is only required to wake kswapd once per node and only if
> all zones are unbalanced for the requested classzone.
> 
> Note that one node might be checked multiple times if the zonelist is
> ordered by node because there is no cheap way of tracking what nodes have
> already been visited.  For zone-ordering, each node should be checked only
> once.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/page_alloc.c |  8 ++++++--
>  mm/vmscan.c     | 13 +++++++++++--
>  2 files changed, 17 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 441f482bf9a2..2fe2fbb4f2ad 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3410,10 +3410,14 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
>  {
>  	struct zoneref *z;
>  	struct zone *zone;
> +	pg_data_t *last_pgdat = NULL;
>  
>  	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
> -						ac->high_zoneidx, ac->nodemask)
> -		wakeup_kswapd(zone, order, ac_classzone_idx(ac));
> +					ac->high_zoneidx, ac->nodemask) {
> +		if (last_pgdat != zone->zone_pgdat)
> +			wakeup_kswapd(zone, order, ac_classzone_idx(ac));
> +		last_pgdat = zone->zone_pgdat;
> +	}
>  }

In wakeup_kswapd(), there is a check if it is a populated zone or not.
If first zone in node is not a populated zone, wakeup_kswapd() would be
skipped. Though, I'm not sure if zonelist can include a un-populated
zone. Perhaps, moving populated zone check in wakeup_kswapd() to here
would be a safe code.

Thanks.

>  
>  static inline unsigned int
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c1c8b77d8cb4..e02091be0e12 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3420,6 +3420,7 @@ static int kswapd(void *p)
>  void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
>  {
>  	pg_data_t *pgdat;
> +	int z;
>  
>  	if (!populated_zone(zone))
>  		return;
> @@ -3433,8 +3434,16 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
>  	pgdat->kswapd_order = max(pgdat->kswapd_order, order);
>  	if (!waitqueue_active(&pgdat->kswapd_wait))
>  		return;
> -	if (zone_balanced(zone, order, 0))
> -		return;
> +
> +	/* Only wake kswapd if all zones are unbalanced */
> +	for (z = 0; z <= classzone_idx; z++) {
> +		zone = pgdat->node_zones + z;
> +		if (!populated_zone(zone))
> +			continue;
> +
> +		if (zone_balanced(zone, order, classzone_idx))
> +			return;
> +	}
>  
>  	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
>  	wake_up_interruptible(&pgdat->kswapd_wait);
> -- 
> 2.6.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
