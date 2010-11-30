Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3E0876B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 01:31:09 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAU6V6aI005745
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Nov 2010 15:31:06 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 864D545DE5B
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:31:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5706745DE58
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:31:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 04C511DB805E
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:31:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 533771DB803C
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:31:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101126111122.GK26037@csn.ul.ie>
References: <20101126195118.B6E7.A69D9226@jp.fujitsu.com> <20101126111122.GK26037@csn.ul.ie>
Message-Id: <20101130152002.8307.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Nov 2010 15:31:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Simon Kirby <sim@hostway.ca>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi
> On Fri, Nov 26, 2010 at 08:03:04PM +0900, KOSAKI Motohiro wrote:
> > Two points.
> > 
> > > @@ -2310,10 +2324,12 @@ loop_again:
> > >  				 * spectulatively avoid congestion waits
> > >  				 */
> > >  				zone_clear_flag(zone, ZONE_CONGESTED);
> > > +				if (i <= pgdat->high_zoneidx)
> > > +					any_zone_ok = 1;
> > >  			}
> > >  
> > >  		}
> > > -		if (all_zones_ok)
> > > +		if (all_zones_ok || (order && any_zone_ok))
> > >  			break;		/* kswapd: all done */
> > >  		/*
> > >  		 * OK, kswapd is getting into trouble.  Take a nap, then take
> > > @@ -2336,7 +2352,7 @@ loop_again:
> > >  			break;
> > >  	}
> > >  out:
> > > -	if (!all_zones_ok) {
> > > +	if (!(all_zones_ok || (order && any_zone_ok))) {
> > 
> > This doesn't work ;)
> > kswapd have to clear ZONE_CONGESTED flag before enter sleeping.
> > otherwise nobody can clear it.
> > 
> 
> Does it not do it earlier in balance_pgdat() here
> 
>                                 /*
>                                  * If a zone reaches its high watermark,
>                                  * consider it to be no longer congested. It's
>                                  * possible there are dirty pages backed by
>                                  * congested BDIs but as pressure is
>                                  * relieved, spectulatively avoid congestion waits
>                                  */
>                                 zone_clear_flag(zone, ZONE_CONGESTED);
>                                 if (i <= pgdat->high_zoneidx)
>                                         any_zone_ok = 1;

zone_clear_flag(zone, ZONE_CONGESTED) only clear one zone status. other
zone remain old status.



> > Say, we have to fill below condition.
> >  - All zone are successing zone_watermark_ok(order-0)
> 
> We should loop around at least once with order == 0 where all_zones_ok
> is checked.

But no gurantee. IOW kswapd early stopping increase GFP_ATOMIC allocation
failure risk, I think.


> >  - At least one zone are successing zone_watermark_ok(high-order)
> 
> This is preferable but it's possible for kswapd to go to sleep without
> this condition being satisified.

Yes.

> 
> > 
> > 
> > > @@ -2417,6 +2439,7 @@ static int kswapd(void *p)
> > >  		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> > >  		new_order = pgdat->kswapd_max_order;
> > >  		pgdat->kswapd_max_order = 0;
> > > +		pgdat->high_zoneidx = MAX_ORDER;
> > 
> > I don't think MAX_ORDER is correct ;)
> > 
> >         high_zoneidx = pgdat->high_zoneidx;
> >         pgdat->high_zoneidx = pgdat->nr_zones - 1;
> > 
> > ?
> > 
> 
> Bah. It should have been MAX_NR_ZONES. This happens to still work because
> MAX_ORDER will always be higher than MAX_NR_ZONES but it's wrong.

Well, no. balance_pgdat() shuldn't read pgdat->high_zoneidx. please remember why
balance balance_pgdat() don't read pgdat->kswapd_max_order directly. wakeup_kswapd()
change pgdat->kswapd_max_order and pgdat->high_zoneidx without any lock. so, 
we need to afraid following bad scenario.


T1: wakeup_kswapd(order=0, HIGHMEM)
T2: enter balance_kswapd()
T1: wakeup_kswapd(order=1, DMA32)
T2: exit balance_kswapd()
      kswapd() erase pgdat->high_zoneidx and decide to don't sleep (because
      old-order=0, new-order=1). So now we will start unnecessary HIGHMEM
      reclaim.



> 
> > And, we have another kswapd_max_order reading place. (after kswapd_try_to_sleep)
> > We need it too.
> > 
> 
> I'm not quite sure what you mean here. kswapd_max_order is read again
> after kswapd tries to sleep (or wakes for that matter) but it'll be in
> response to another caller having tried to wake kswapd indicating that
> those high orders really are needed.

My expected bad scenario was written above. 

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
