Message-ID: <492FCFF6.1050808@redhat.com>
Date: Fri, 28 Nov 2008 06:03:18 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: bail out of page reclaim after swap_cluster_max
 pages
References: <20081124145057.4211bd46@bree.surriel.com> <20081125203333.26F0.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081128140405.3D0B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081128140405.3D0B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi
> 
> I mesured some data in this week and I got some interesting data.

> Rik patch improve about 30% and my patch improve 20% more.
> totally, We got about 50% improvement.

Very interesting indeed!   I did not know there was this easy
a reproducer of the problem that my patch is trying to solve.

> 	rc6+stream	rvr		+kosaki
> 	----------------------------------------
> avg	274.8004	194.6495	132.7923
> std	184.4902365	111.5699478	75.88299814
> min	37.523		57.084		52.233
> max	588.74		382.376		319.115

Impressive.

> So, rik patch and my patch improve perfectly different reclaim aspect.
> In general, kernel reclaim processing has several key goals.
> 
>  (1) if system has droppable cache, system shouldn't happen oom kill.
>  (2) if system has avaiable swap space, system shouldn't happen 
>      oom kill as poosible as.
>  (3) if system has enough free memory, system shouldn't reclaim any page
>      at all.
>  (4) if memory pressure is lite, system shouldn't cause heavy reclaim 
>      latency to application.
> 
> rik patch improve (3), my (this mail) modification improve (4).

Actually, to achieve (3) we would want to skip zones with way
more than enough free memory in shrink_zones().  Kswapd already
skips zones like this in shrink_pgdat(), so we definately want
this change:

@@ -1519,6 +1519,9 @@ static void shrink_zones(int priority, s
                         if (zone_is_all_unreclaimable(zone) &&
                                                 priority != DEF_PRIORITY)
                                 continue;       /* Let kswapd poll it */
+                       if (zone_watermark_ok(zone, order, 
4*zone->pages_high,
+                                               end_zone, 0))
+                               continue;       /* Lots free already */
                         sc->all_unreclaimable = 0;
                 } else {
                         /*

I'm sending a patch with this right now :)

> Actually, kswapd background reclaim and direct reclaim have perfectly
> different purpose and goal.
> 
> background reclaim
>   - kswapd don't need latency overhead reducing.
>     it isn't observe from end user.
>   - kswapd shoudn't only increase free pages, but also should 
>     zone balancing.
> 
> foreground reclaim
>   - it used application task context.
>   - as possible as, it shouldn't increase latency overhead.
>   - this reclaiming purpose is to make the memory for _own_ taks.
>     for other tasks memory don't need to concern.
>     kswap does it.

I am not entirely convinced that breaking out of the loop early
in a zone is not harmful for direct reclaimers.  Maybe it works
fine, maybe it won't.

Or maybe direct reclaimers should start scanning the largest zone
first, so your change can be done with the lowest risk possible?

Having said that, the 20% additional performance achieved with
your changes is impressive.

> o remove priority==DEF_PRIORITY condision

This one could definately be worth considering.

However, looking at the changeset that was backed out in the
early 2.6 series suggests that it may not be the best idea.

> o shrink_zones() also should have bailing out feature.

This one is similar.  What are the downsides of skipping a
zone entirely, when that zone has pages that should be freed?

If it can lead to the VM reclaiming new pages from one zone,
while leaving old pages from another zone in memory, we can
greatly reduce the caching efficiency of the page cache.

> ---
>  mm/vmscan.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1469,7 +1469,7 @@ static void shrink_zone(int priority, st
>  		 * freeing target can get unreasonably large.
>  		 */
>  		if (sc->nr_reclaimed > sc->swap_cluster_max &&
> -		    priority < DEF_PRIORITY && !current_is_kswapd())
> +		    !current_is_kswapd())
>  			break;
>  	}
>  
> @@ -1534,6 +1534,8 @@ static void shrink_zones(int priority, s
>  		}
>  
>  		shrink_zone(priority, zone, sc);
> +		if (sc->nr_reclaimed > sc->swap_cluster_max)
> +			break;
>  	}
>  }

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
