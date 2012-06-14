Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id BC7EE6B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 11:25:40 -0400 (EDT)
Date: Thu, 14 Jun 2012 17:25:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [resend][PATCH] mm, vmscan: fix do_try_to_free_pages() livelock
Message-ID: <20120614152537.GR27397@tiehlicka.suse.cz>
References: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu 14-06-12 04:13:12, kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Currently, do_try_to_free_pages() can enter livelock. Because of,
> now vmscan has two conflicted policies.
> 
> 1) kswapd sleep when it couldn't reclaim any page when reaching
>    priority 0. This is because to avoid kswapd() infinite
>    loop. That said, kswapd assume direct reclaim makes enough
>    free pages to use either regular page reclaim or oom-killer.
>    This logic makes kswapd -> direct-reclaim dependency.
> 2) direct reclaim continue to reclaim without oom-killer until
>    kswapd turn on zone->all_unreclaimble. This is because
>    to avoid too early oom-kill.
>    This logic makes direct-reclaim -> kswapd dependency.
> 
> In worst case, direct-reclaim may continue to page reclaim forever
> when kswapd sleeps forever.
> 
> We can't turn on zone->all_unreclaimable from direct reclaim path
> because direct reclaim path don't take any lock and this way is racy.
> 
> Thus this patch removes zone->all_unreclaimable field completely and
> recalculates zone reclaimable state every time.
> 
> Note: we can't take the idea that direct-reclaim see zone->pages_scanned
> directly and kswapd continue to use zone->all_unreclaimable. Because, it
> is racy. commit 929bea7c71 (vmscan: all_unreclaimable() use
> zone->all_unreclaimable as a name) describes the detail.
> 
> Reported-by: Aaditya Kumar <aaditya.kumar.30@gmail.com>
> Reported-by: Ying Han <yinghan@google.com>
> Cc: Nick Piggin <npiggin@gmail.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Looks good, just one comment bellow:

Reviewed-by: Michal Hocko <mhocko@suse.cz>

[...]
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eeb3bc9..033671c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
[...]
> @@ -1936,8 +1936,8 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  		if (global_reclaim(sc)) {
>  			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>  				continue;
> -			if (zone->all_unreclaimable &&
> -					sc->priority != DEF_PRIORITY)
> +			if (!zone_reclaimable(zone) &&
> +			    sc->priority != DEF_PRIORITY)

Not exactly a hot path but still would be nice to test the priority
first as the test is cheaper (maybe compiler is clever enough to reorder
this, as both expressions are independent and without any side-effects
but...).

[...]
> @@ -2393,8 +2388,7 @@ loop_again:
>  			if (!populated_zone(zone))
>  				continue;
>  
> -			if (zone->all_unreclaimable &&
> -			    sc.priority != DEF_PRIORITY)
> +			if (!zone_reclaimable(zone) && sc.priority != DEF_PRIORITY)
>  				continue;

Same here

>  
>  			/*
> @@ -2443,14 +2437,13 @@ loop_again:
>  		 */
>  		for (i = 0; i <= end_zone; i++) {
>  			struct zone *zone = pgdat->node_zones + i;
> -			int nr_slab, testorder;
> +			int testorder;
>  			unsigned long balance_gap;
>  
>  			if (!populated_zone(zone))
>  				continue;
>  
> -			if (zone->all_unreclaimable &&
> -			    sc.priority != DEF_PRIORITY)
> +			if (!zone_reclaimable(zone) && sc.priority != DEF_PRIORITY)
>  				continue;

Same here

[...]
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
