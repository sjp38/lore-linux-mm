Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BA90F6B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 21:56:09 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o082u7e0022447
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 8 Jan 2010 11:56:07 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id ACBD645DE53
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 11:56:06 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7788F45DE50
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 11:56:06 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 450EDE08001
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 11:56:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BD8F51DB8047
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 11:56:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Commit f50de2d38 seems to be breaking my oom killer
In-Reply-To: <20100108105841.b9a030c4.minchan.kim@barrios-desktop>
References: <20100107135831.GA29564@csn.ul.ie> <20100108105841.b9a030c4.minchan.kim@barrios-desktop>
Message-Id: <20100108115531.C132.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  8 Jan 2010 11:56:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Will Newton <will.newton@gmail.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Hi, Mel 
> 
> On Thu, 7 Jan 2010 13:58:31 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > vmscan: kswapd should notice that all zones are not ok if they are unreclaimble
> > 
> > In the event all zones are unreclaimble, it is possible for kswapd to
> > never go to sleep because "all zones are ok even though watermarks are
> > not reached". It gets into a situation where cond_reched() is not
> > called.
> > 
> > This patch notes that if all zones are unreclaimable then the zones are
> > not ok and cond_resched() should be called.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > --- 
> >  mm/vmscan.c |    4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 2ad8603..d3c0848 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2022,8 +2022,10 @@ loop_again:
> >  				break;
> >  			}
> >  		}
> > -		if (i < 0)
> > +		if (i < 0) {
> > +			all_zones_ok = 0;
> >  			goto out;
> > +		}
> >  
> >  		for (i = 0; i <= end_zone; i++) {
> >  			struct zone *zone = pgdat->node_zones + i;
> > 
> > --
> 
> Nice catch!
> Don't we care following as although it is rare case?
> 
> ---
>                 for (i = 0; i <= end_zone; i++) {
>                         struct zone *zone = pgdat->node_zones + i; 
>                         int nr_slab;
>                         int nid, zid; 
> 
>                         if (!populated_zone(zone))
>                                 continue;
> 
>                         if (zone_is_all_unreclaimable(zone) &&
>                                         priority != DEF_PRIORITY)
>                                 continue;  <==== here
> 
> ---
> 
> And while I review all_zones_ok'usage in balance_pgdat, 
> I feel it's not consistent and rather confused. 
> How about this?

Can you please read my patch?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
