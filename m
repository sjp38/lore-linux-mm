Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 78EDD6B007D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 23:59:58 -0500 (EST)
Received: by ywh5 with SMTP id 5so38857761ywh.11
        for <linux-mm@kvack.org>; Thu, 07 Jan 2010 20:59:55 -0800 (PST)
Date: Fri, 8 Jan 2010 13:53:05 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: Commit f50de2d38 seems to be breaking my oom killer
Message-Id: <20100108135305.e053e9fe.minchan.kim@barrios-desktop>
In-Reply-To: <20100108130742.C138.A69D9226@jp.fujitsu.com>
References: <20100108105841.b9a030c4.minchan.kim@barrios-desktop>
	<20100108115531.C132.A69D9226@jp.fujitsu.com>
	<20100108130742.C138.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Will Newton <will.newton@gmail.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri,  8 Jan 2010 13:08:46 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

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
> Cc: Mel Gorman <mel@csn.ul.ie>
> Reported-by: Will Newton <will.newton@gmail.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Looks good than mine. Thnaks, Kosaki. 
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
