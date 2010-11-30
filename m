Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7DD606B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 05:41:55 -0500 (EST)
Date: Tue, 30 Nov 2010 10:41:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Free memory never fully used, swapping
Message-ID: <20101130104136.GK13268@csn.ul.ie>
References: <20101126195118.B6E7.A69D9226@jp.fujitsu.com> <20101126111122.GK26037@csn.ul.ie> <20101130152002.8307.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101130152002.8307.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Simon Kirby <sim@hostway.ca>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 30, 2010 at 03:31:03PM +0900, KOSAKI Motohiro wrote:
> Hi
> > On Fri, Nov 26, 2010 at 08:03:04PM +0900, KOSAKI Motohiro wrote:
> > > Two points.
> > > 
> > > > @@ -2310,10 +2324,12 @@ loop_again:
> > > >  				 * spectulatively avoid congestion waits
> > > >  				 */
> > > >  				zone_clear_flag(zone, ZONE_CONGESTED);
> > > > +				if (i <= pgdat->high_zoneidx)
> > > > +					any_zone_ok = 1;
> > > >  			}
> > > >  
> > > >  		}
> > > > -		if (all_zones_ok)
> > > > +		if (all_zones_ok || (order && any_zone_ok))
> > > >  			break;		/* kswapd: all done */
> > > >  		/*
> > > >  		 * OK, kswapd is getting into trouble.  Take a nap, then take
> > > > @@ -2336,7 +2352,7 @@ loop_again:
> > > >  			break;
> > > >  	}
> > > >  out:
> > > > -	if (!all_zones_ok) {
> > > > +	if (!(all_zones_ok || (order && any_zone_ok))) {
> > > 
> > > This doesn't work ;)
> > > kswapd have to clear ZONE_CONGESTED flag before enter sleeping.
> > > otherwise nobody can clear it.
> > > 
> > 
> > Does it not do it earlier in balance_pgdat() here
> > 
> >                                 /*
> >                                  * If a zone reaches its high watermark,
> >                                  * consider it to be no longer congested. It's
> >                                  * possible there are dirty pages backed by
> >                                  * congested BDIs but as pressure is
> >                                  * relieved, spectulatively avoid congestion waits
> >                                  */
> >                                 zone_clear_flag(zone, ZONE_CONGESTED);
> >                                 if (i <= pgdat->high_zoneidx)
> >                                         any_zone_ok = 1;
> 
> zone_clear_flag(zone, ZONE_CONGESTED) only clear one zone status. other
> zone remain old status.
> 

Ah now I get you. kswapd does not necessarily balance all zones so it needs
to unconditionally clear them all before it goes to sleep in case. At
some time in the future, the tagging of ZONE_CONGESTED needs more
thinking about.

> > > Say, we have to fill below condition.
> > >  - All zone are successing zone_watermark_ok(order-0)
> > 
> > We should loop around at least once with order == 0 where all_zones_ok
> > is checked.
> 
> But no gurantee. IOW kswapd early stopping increase GFP_ATOMIC allocation
> failure risk, I think.
> 

Force all zones to be balanced for order-0?

> 
> > >  - At least one zone are successing zone_watermark_ok(high-order)
> > 
> > This is preferable but it's possible for kswapd to go to sleep without
> > this condition being satisified.
> 
> Yes.
> 
> > 
> > > 
> > > 
> > > > @@ -2417,6 +2439,7 @@ static int kswapd(void *p)
> > > >  		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> > > >  		new_order = pgdat->kswapd_max_order;
> > > >  		pgdat->kswapd_max_order = 0;
> > > > +		pgdat->high_zoneidx = MAX_ORDER;
> > > 
> > > I don't think MAX_ORDER is correct ;)
> > > 
> > >         high_zoneidx = pgdat->high_zoneidx;
> > >         pgdat->high_zoneidx = pgdat->nr_zones - 1;
> > > 
> > > ?
> > > 
> > 
> > Bah. It should have been MAX_NR_ZONES. This happens to still work because
> > MAX_ORDER will always be higher than MAX_NR_ZONES but it's wrong.
> 
> Well, no. balance_pgdat() shuldn't read pgdat->high_zoneidx. please remember why
> balance balance_pgdat() don't read pgdat->kswapd_max_order directly. wakeup_kswapd()
> change pgdat->kswapd_max_order and pgdat->high_zoneidx without any lock. so, 
> we need to afraid following bad scenario.
> 
> 
> T1: wakeup_kswapd(order=0, HIGHMEM)
> T2: enter balance_kswapd()
> T1: wakeup_kswapd(order=1, DMA32)
> T2: exit balance_kswapd()
>       kswapd() erase pgdat->high_zoneidx and decide to don't sleep (because
>       old-order=0, new-order=1). So now we will start unnecessary HIGHMEM
>       reclaim.
> 

Correct. I'll fix this up.

> > > And, we have another kswapd_max_order reading place. (after kswapd_try_to_sleep)
> > > We need it too.
> > > 
> > 
> > I'm not quite sure what you mean here. kswapd_max_order is read again
> > after kswapd tries to sleep (or wakes for that matter) but it'll be in
> > response to another caller having tried to wake kswapd indicating that
> > those high orders really are needed.
> 
> My expected bad scenario was written above. 
> 
> Thanks.
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
