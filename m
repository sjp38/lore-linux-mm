Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id D57EC6B0031
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 14:14:42 -0400 (EDT)
Date: Thu, 8 Aug 2013 14:14:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [resend] [PATCH V2] mm: vmscan: fix do_try_to_free_pages()
 livelock
Message-ID: <20130808181426.GI715@cmpxchg.org>
References: <89813612683626448B837EE5A0B6A7CB3B630BE80B@SC-VEXCH4.marvell.com>
 <20130805074146.GD10146@dhcp22.suse.cz>
 <89813612683626448B837EE5A0B6A7CB3B630BED6B@SC-VEXCH4.marvell.com>
 <20130806103543.GA31138@dhcp22.suse.cz>
 <89813612683626448B837EE5A0B6A7CB3B63175BCA@SC-VEXCH4.marvell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B63175BCA@SC-VEXCH4.marvell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Bob Liu <lliubbo@gmail.com>, Neil Zhang <zhangwm@marvell.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, "yinghan@google.com" <yinghan@google.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "riel@redhat.com" <riel@redhat.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Aug 06, 2013 at 06:42:06PM -0700, Lisa Du wrote:
> Hi, Michal and all
>    I'm so sorry, now I updated the review list.
>    Thank you all for the review and comments!
> 
> In this version:
> Remove change ID according to Minchan's comment;
> Reorder the check in shrink_zones according Johannes's comment.
> Also cc to more people.
> 
> >From ff345123117394c6b9b838bf54eb935bfa879f32 Mon Sep 17 00:00:00 2001
> From: Lisa Du <cldu@marvell.com>
> Date: Mon, 5 Aug 2013 09:26:57 +0800
> Subject: [PATCH] mm: vmscan: fix do_try_to_free_pages() livelock
> 
> This patch is based on KOSAKI's work and I add a little more
> description, please refer https://lkml.org/lkml/2012/6/14/74.
> 
> Currently, I found system can enter a state that there are lots
> of free pages in a zone but only order-0 and order-1 pages which
> means the zone is heavily fragmented, then high order allocation
> could make direct reclaim path's long stall(ex, 60 seconds)
> especially in no swap and no compaciton enviroment. This problem
> happened on v3.4, but it seems issue still lives in current tree,
> the reason is do_try_to_free_pages enter live lock:
> 
> kswapd will go to sleep if the zones have been fully scanned
> and are still not balanced. As kswapd thinks there's little point
> trying all over again to avoid infinite loop. Instead it changes
> order from high-order to 0-order because kswapd think order-0 is the
> most important. Look at 73ce02e9 in detail. If watermarks are ok,
> kswapd will go back to sleep and may leave zone->all_unreclaimable = 0.
> It assume high-order users can still perform direct reclaim if they wish.
> 
> Direct reclaim continue to reclaim for a high order which is not a
> COSTLY_ORDER without oom-killer until kswapd turn on zone->all_unreclaimble.
> This is because to avoid too early oom-kill. So it means direct_reclaim
> depends on kswapd to break this loop.
> 
> In worst case, direct-reclaim may continue to page reclaim forever
> when kswapd sleeps forever until someone like watchdog detect and finally
> kill the process. As described in:
> http://thread.gmane.org/gmane.linux.kernel.mm/103737
> 
> We can't turn on zone->all_unreclaimable from direct reclaim path
> because direct reclaim path don't take any lock and this way is racy.
> Thus this patch removes zone->all_unreclaimable field completely and
> recalculates zone reclaimable state every time.
> 
> Note: we can't take the idea that direct-reclaim see zone->pages_scanned
> directly and kswapd continue to use zone->all_unreclaimable. Because, it
> is racy. commit 929bea7c71 (vmscan: all_unreclaimable() use
> zone->all_unreclaimable as a name) describes the detail.
> 
> Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>
> Cc: Ying Han <yinghan@google.com>
> Cc: Nick Piggin <npiggin@gmail.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Bob Liu <lliubbo@gmail.com>
> Cc: Neil Zhang <zhangwm@marvell.com>
> Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

I sent an Acked-by, please keep these tags verbatim.

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Lisa Du <cldu@marvell.com>

> @@ -2244,8 +2244,8 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  		if (global_reclaim(sc)) {
>  			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>  				continue;
> -			if (zone->all_unreclaimable &&
> -					sc->priority != DEF_PRIORITY)
> +			if (sc->priority != DEF_PRIORITY &&
> +			    !zone_reclaimable(zone))
>  				continue;	/* Let kswapd poll it */
>  			if (IS_ENABLED(CONFIG_COMPACTION)) {
>  				/*

Yes, this is better, thanks.

> @@ -2901,7 +2892,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  			if (!populated_zone(zone))
>  				continue;
>  
> -			if (zone->all_unreclaimable &&
> +			if (!zone_reclaimable(zone) &&
>  			    sc.priority != DEF_PRIORITY)
>  				continue;
>  

> @@ -2980,7 +2971,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  			if (!populated_zone(zone))
>  				continue;
>  
> -			if (zone->all_unreclaimable &&
> +			if (!zone_reclaimable(zone) &&
>  			    sc.priority != DEF_PRIORITY)
>  				continue;
>  

What about those?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
