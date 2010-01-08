Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B4F9B6B0093
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 04:25:16 -0500 (EST)
Date: Fri, 8 Jan 2010 09:25:03 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Commit f50de2d38 seems to be breaking my oom killer
Message-ID: <20100108092503.GA3985@csn.ul.ie>
References: <20100108105841.b9a030c4.minchan.kim@barrios-desktop> <20100108115531.C132.A69D9226@jp.fujitsu.com> <20100108130742.C138.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100108130742.C138.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Will Newton <will.newton@gmail.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 08, 2010 at 01:08:46PM +0900, KOSAKI Motohiro wrote:
> > > Hi, Mel 
> > > 
> > > On Thu, 7 Jan 2010 13:58:31 +0000
> > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > 
> > > > vmscan: kswapd should notice that all zones are not ok if they are unreclaimble
> > > > 
> > > > In the event all zones are unreclaimble, it is possible for kswapd to
> > > > never go to sleep because "all zones are ok even though watermarks are
> > > > not reached". It gets into a situation where cond_reched() is not
> > > > called.
> > > > 
> > > > This patch notes that if all zones are unreclaimable then the zones are
> > > > not ok and cond_resched() should be called.
> > > > 
> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > > --- 
> > > >  mm/vmscan.c |    4 +++-
> > > >  1 file changed, 3 insertions(+), 1 deletion(-)
> > > > 
> > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > index 2ad8603..d3c0848 100644
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -2022,8 +2022,10 @@ loop_again:
> > > >  				break;
> > > >  			}
> > > >  		}
> > > > -		if (i < 0)
> > > > +		if (i < 0) {
> > > > +			all_zones_ok = 0;
> > > >  			goto out;
> > > > +		}
> > > >  
> > > >  		for (i = 0; i <= end_zone; i++) {
> > > >  			struct zone *zone = pgdat->node_zones + i;
> > > > 
> > > > --
> > > 
> > > Nice catch!
> > > Don't we care following as although it is rare case?
> > > 
> > > ---
> > >                 for (i = 0; i <= end_zone; i++) {
> > >                         struct zone *zone = pgdat->node_zones + i; 
> > >                         int nr_slab;
> > >                         int nid, zid; 
> > > 
> > >                         if (!populated_zone(zone))
> > >                                 continue;
> > > 
> > >                         if (zone_is_all_unreclaimable(zone) &&
> > >                                         priority != DEF_PRIORITY)
> > >                                 continue;  <==== here
> > > 
> > > ---
> > > 
> > > And while I review all_zones_ok'usage in balance_pgdat, 
> > > I feel it's not consistent and rather confused. 
> > > How about this?
> > 
> > Can you please read my patch?
> 
> Grr. I'm sorry. such thread don't CCed LKML.
> cut-n-past here.
> 
> 
> ----------------------------------------
> Umm..
> This code looks a bit risky. Please imazine asymmetric numa. If the system has
> very small node, its nude have unreclaimable state at almost time.
> 
> Thus, if all zones in the node are unreclaimable, It should be slept. To retry balance_pgdat()
> is meaningless. this is original intention, I think.
> 
> So why can't we write following?
> 
> From c00d7bb29552d3aa4d934b5007f3d52ade5f2dfd Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Fri, 8 Jan 2010 08:36:05 +0900
> Subject: [PATCH] vmscan: kswapd don't retry balance_pgdat() if all zones are unreclaimable
> 
> Commit f50de2d3 (vmscan: have kswapd sleep for a short interval and
> double check it should be asleep) can cause kswapd to enter an infinite
> loop if running on a single-CPU system. If all zones are unreclaimble,
> sleeping_prematurely return 1 and kswapd will call balance_pgdat()
> again. but it's totally meaningless, balance_pgdat() doesn't anything
> against unreclaimable zone!
> 

Sure, that would be a safer check in the face of very small NUMA nodes.
It could do with a comment explaining why unreclaimable zones are being skipped
but it's no biggie.  Will, can you confirm this patch also fixes your problem.

Kosaki, if Will reports success, can you then report that patch please
for upstreaming?  After today, I'm offline for a week so it'd be at
least 10 days before I'd do it. Thanks

> Cc: Mel Gorman <mel@csn.ul.ie>
> Reported-by: Will Newton <will.newton@gmail.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/vmscan.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2bbee91..56327d5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1922,6 +1922,9 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
>  		if (!populated_zone(zone))
>  			continue;
>  
> +		if (zone_is_all_unreclaimable(zone))
> +			continue;
> +
>  		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
>  								0, 0))
>  			return 1;
> -- 
> 1.6.5.2
> 
> 
> 
> 
> 
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
