Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 54A8B8D0002
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 19:29:12 -0500 (EST)
Subject: Re: [patch]vmscan: make kswapd use a correct order
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20101201155854.GA3372@barrios-desktop>
References: <1291172911.12777.58.camel@sli10-conroe>
	 <20101201132730.ABC2.A69D9226@jp.fujitsu.com>
	 <20101201155854.GA3372@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 02 Dec 2010 08:29:09 +0800
Message-ID: <1291249749.12777.86.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-12-01 at 23:58 +0800, Minchan Kim wrote:
> On Wed, Dec 01, 2010 at 06:44:27PM +0900, KOSAKI Motohiro wrote:
> > > T0: Task1 wakeup_kswapd(order=3)
> > > T1: kswapd enters balance_pgdat
> > > T2: Task2 wakeup_kswapd(order=2), because pages reclaimed by kswapd are used
> > > quickly
> > > T3: kswapd exits balance_pgdat. kswapd will do check. Now new order=2,
> > > pgdat->kswapd_max_order will become 0, but order=3, if sleeping_prematurely,
> > > then order will become pgdat->kswapd_max_order(0), while at this time the
> > > order should 2
> > > This isn't a big deal, but we do have a small window the order is wrong.
> > > 
> > > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index d31d7ce..15cd0d2 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2450,7 +2450,7 @@ static int kswapd(void *p)
> > >  				}
> > >  			}
> > >  
> > > -			order = pgdat->kswapd_max_order;
> > > +			order = max_t(unsigned long, new_order, pgdat->kswapd_max_order);
> > >  		}
> > >  		finish_wait(&pgdat->kswapd_wait, &wait);
> > 
> > Good catch!
> > 
> > But unfortunatelly, the code is not correct. At least, don't fit corrent
> > design.
> > 
> > 1) if "order < new_order" condition is false, we already decided to don't
> >    use new_order. So, we shouldn't use new_order after kswapd_try_to_sleep()
> > 2) if sleeping_prematurely() return false, it probably mean
> >    zone_watermark_ok_safe(zone, order, high_wmark) return false.
> >    therefore, we have to retry reclaim by using old 'order' parameter.
> 
> Good catch, too.
> 
> In Shaohua's scenario, if Task1 gets the order-3 page after kswapd's reclaiming,
> it's no problem.
> But if Task1 doesn't get the order-3 page and others used the order-3 page for Task1,
> Kswapd have to reclaim order-3 for Task1, again.
why? it's just a possibility. Task1 might get its pages too. If Task1
doesn't get its pages, it will wakeup kswapd too with its order.

> In addtion, new order is always less than old order in that context. 
> so big order page reclaim makes much safe for low order pages.
big order page reclaim makes we have more chances to reclaim useful
pages by lumpy, why it's safe?

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
