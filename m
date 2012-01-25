Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 40F596B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 11:07:56 -0500 (EST)
Date: Wed, 25 Jan 2012 16:07:52 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v2 -mm 1/3] mm: reclaim at order 0 when compaction is
 enabled
Message-ID: <20120125160752.GE3901@csn.ul.ie>
References: <20120124131822.4dc03524@annuminas.surriel.com>
 <20120124132136.3b765f0c@annuminas.surriel.com>
 <20120125150016.GB3901@csn.ul.ie>
 <4F201F60.8080808@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F201F60.8080808@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On Wed, Jan 25, 2012 at 10:27:28AM -0500, Rik van Riel wrote:
> On 01/25/2012 10:00 AM, Mel Gorman wrote:
> >On Tue, Jan 24, 2012 at 01:21:36PM -0500, Rik van Riel wrote:
> >>When built with CONFIG_COMPACTION, kswapd does not try to free
> >>contiguous pages.
> >
> >balance_pgdat() gets its order from wakeup_kswapd(). This does not apply
> >to THP because kswapd does not get woken for THP but it should be woken
> >up for allocations like jumbo frames or order-1.
> 
> In the kernel I run at home, I wake up kswapd for THP
> as well. This is a larger change, which Andrea asked
> me to delay submitting upstream for a bit.
> 

Ok, good call. Waking kswapd up for THP is still premature.

> So far there seem to be no ill effects. I'll continue
> watching for them.
> 
> >As kswapd does no memory compaction itself, this patch still makes
> >sense but I found the changelog misleading.
> 
> Fair enough.  I will adjust the changelog.
> 

Thanks.

> ><SNIP>
> >The second effect of this change is a non-obvious side-effect. kswapd
> >will now isolate fewer pages per cycle because it will isolate
> >SWAP_CLUSTER_MAX pages instead of SWAP_CLUSTER_MAX<<order which it
> >potentially does currently. This is not wrong as such and may be
> >desirable to limit how much reclaim kswapd does but potentially it
> >impacts success rates for compaction. As this does not apply to THP,
> >it will be difficult to detect but bear in mind if we see an increase
> >in high-order allocation failures after this patch is merged. I am
> >not suggesting a change here but it would be nice to note in the
> >changelog if there is a new version of this patch.
> 
> Good point.  I am running with THP waking up kswapd, and
> things seem to behave (and compaction seems to succeed),
> but we might indeed want to change balance_pgdat to free
> more pages for higher order allocations.
> 
> Maybe this is the place to check (in balanced_pgdat) ?
> 
>                 /*
>                  * We do this so kswapd doesn't build up large
> priorities for
>                  * example when it is freeing in parallel with
> allocators. It
>                  * matches the direct reclaim path behaviour in
> terms of impact
>                  * on zone->*_priority.
>                  */
>                 if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
>                         break;
> 

It would be a good place all right. Preferably it would tie into
compaction_ready() to decide whether to continue reclaiming or not.

> >>@@ -2922,8 +2939,6 @@ out:
> >>
> >>  			/* If balanced, clear the congested flag */
> >>  			zone_clear_flag(zone, ZONE_CONGESTED);
> >>-			if (i<= *classzone_idx)
> >>-				balanced += zone->present_pages;
> >>  		}
> >
> >Why is this being deleted? It is still used by pgdat_balanced().
> 
> This is outside of the big while loop and is not used again
> in the function. 

How about here?

               if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
                        break;          /* kswapd: all done */

Either way, it looks like something that should be in its own patch.

> This final for loop does not appear to
> use the variable balanced at all, except for incrementing
> it.
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
