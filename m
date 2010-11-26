Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3DF7A8D0001
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 21:40:46 -0500 (EST)
Subject: Re: Free memory never fully used, swapping
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20101126110244.B6DC.A69D9226@jp.fujitsu.com>
References: <20101125161524.GE26037@csn.ul.ie>
	 <1290736844.12777.10.camel@sli10-conroe>
	 <20101126110244.B6DC.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 26 Nov 2010 10:40:43 +0800
Message-ID: <1290739243.12777.17.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Simon Kirby <sim@hostway.ca>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-11-26 at 10:31 +0800, KOSAKI Motohiro wrote:
> > record the order seems not sufficient. in balance_pgdat(), the for look
> > exit only when:
> > priority <0 or sc.nr_reclaimed >= SWAP_CLUSTER_MAX.
> > but we do if (sc.nr_reclaimed < SWAP_CLUSTER_MAX)
> >                         order = sc.order = 0;
> > this means before we set order to 0, we already reclaimed a lot of
> > pages, so I thought we need set order to 0 earlier before there are
> > enough free pages. below is a debug patch.
> > 
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index d31d7ce..ee5d2ed 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2117,6 +2117,26 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
> >  }
> >  #endif
> >  
> > +static int all_zone_enough_free_pages(pg_data_t *pgdat)
> > +{
> > +	int i;
> > +
> > +	for (i = 0; i < pgdat->nr_zones; i++) {
> > +		struct zone *zone = pgdat->node_zones + i;
> > +
> > +		if (!populated_zone(zone))
> > +			continue;
> > +
> > +		if (zone->all_unreclaimable)
> > +			continue;
> > +
> > +		if (!zone_watermark_ok(zone, 0, high_wmark_pages(zone) * 8,
> > +								0, 0))
> > +			return 0;
> > +	}
> > +	return 1;
> > +}
> > +
> >  /* is kswapd sleeping prematurely? */
> >  static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
> >  {
> > @@ -2355,7 +2375,8 @@ out:
> >  		 * back to sleep. High-order users can still perform direct
> >  		 * reclaim if they wish.
> >  		 */
> > -		if (sc.nr_reclaimed < SWAP_CLUSTER_MAX)
> > +		if (sc.nr_reclaimed < SWAP_CLUSTER_MAX ||
> > +		    (order > 0 && all_zone_enough_free_pages(pgdat)))
> >  			order = sc.order = 0;
> 
> Ummm. this doesn't work. this place is processed every 32 pages reclaimed.
> (see below code and comment). Theresore your patch break high order reclaim
> logic.
Yes, this will break high order reclaim, but we need a compromise.
wrongly reclaim pages is more worse. could increase the watermark in
all_zone_enough_free_pages() better?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
