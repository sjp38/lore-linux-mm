Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id B3A3D6B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:43:43 -0400 (EDT)
Date: Thu, 14 Jun 2012 10:43:32 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [resend][PATCH] mm, vmscan: fix do_try_to_free_pages() livelock
Message-ID: <20120614084332.GN1761@cmpxchg.org>
References: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@gmail.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jun 14, 2012 at 04:13:12AM -0400, kosaki.motohiro@gmail.com wrote:
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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> @@ -2497,12 +2490,11 @@ loop_again:
>  				shrink_zone(zone, &sc);
>  
>  				reclaim_state->reclaimed_slab = 0;
> -				nr_slab = shrink_slab(&shrink, sc.nr_scanned, lru_pages);
> +				shrink_slab(&shrink, sc.nr_scanned, lru_pages);
>  				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
>  				total_scanned += sc.nr_scanned;
>  
> -				if (nr_slab == 0 && !zone_reclaimable(zone))
> -					zone->all_unreclaimable = 1;
> +

That IS a slight change in behaviour.  But then, if you scanned 6
times the amount of reclaimable pages without freeing a single slab
page, it's probably not worth going on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
