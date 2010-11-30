Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 41D346B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 06:19:32 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAUBJTpF014755
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Nov 2010 20:19:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AE6F45DE56
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 20:19:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4484445DE53
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 20:19:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3880D1DB8048
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 20:19:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0557B1DB8047
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 20:19:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101130104136.GK13268@csn.ul.ie>
References: <20101130152002.8307.A69D9226@jp.fujitsu.com> <20101130104136.GK13268@csn.ul.ie>
Message-Id: <20101130201821.8319.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Nov 2010 20:19:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Simon Kirby <sim@hostway.ca>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi

> > > > >  out:
> > > > > -	if (!all_zones_ok) {
> > > > > +	if (!(all_zones_ok || (order && any_zone_ok))) {
> > > > 
> > > > This doesn't work ;)
> > > > kswapd have to clear ZONE_CONGESTED flag before enter sleeping.
> > > > otherwise nobody can clear it.
> > > > 
> > > 
> > > Does it not do it earlier in balance_pgdat() here
> > > 
> > >                                 /*
> > >                                  * If a zone reaches its high watermark,
> > >                                  * consider it to be no longer congested. It's
> > >                                  * possible there are dirty pages backed by
> > >                                  * congested BDIs but as pressure is
> > >                                  * relieved, spectulatively avoid congestion waits
> > >                                  */
> > >                                 zone_clear_flag(zone, ZONE_CONGESTED);
> > >                                 if (i <= pgdat->high_zoneidx)
> > >                                         any_zone_ok = 1;
> > 
> > zone_clear_flag(zone, ZONE_CONGESTED) only clear one zone status. other
> > zone remain old status.
> > 
> 
> Ah now I get you. kswapd does not necessarily balance all zones so it needs
> to unconditionally clear them all before it goes to sleep in case. At
> some time in the future, the tagging of ZONE_CONGESTED needs more
> thinking about.
>

This is a option.


> > > > Say, we have to fill below condition.
> > > >  - All zone are successing zone_watermark_ok(order-0)
> > > 
> > > We should loop around at least once with order == 0 where all_zones_ok
> > > is checked.
> > 
> > But no gurantee. IOW kswapd early stopping increase GFP_ATOMIC allocation
> > failure risk, I think.
> > 
> 
> Force all zones to be balanced for order-0?

Yes.

I think following change does.

	if (i <= pgdat->high_zoneidx)
- 		 any_zone_ok = 1;
+		order = sc.order = 0;


This is more conservative.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
