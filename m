Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3EB8A8D0001
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 21:05:45 -0500 (EST)
Subject: Re: Free memory never fully used, swapping
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20101126012527.GI26037@csn.ul.ie>
References: <20101115195246.GB17387@hostway.ca>
	 <20101122154419.ee0e09d2.akpm@linux-foundation.org>
	 <1290501331.2390.7023.camel@nimitz> <20101124084652.GC25170@hostway.ca>
	 <1290647274.12777.3.camel@sli10-conroe> <20101125090328.GB14180@hostway.ca>
	 <20101125161238.GD26037@csn.ul.ie> <1290733556.12777.5.camel@sli10-conroe>
	 <20101126012527.GI26037@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 26 Nov 2010 10:05:40 +0800
Message-ID: <1290737140.12777.13.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-11-26 at 09:25 +0800, Mel Gorman wrote:
> On Fri, Nov 26, 2010 at 09:05:56AM +0800, Shaohua Li wrote:
> > > @@ -2168,6 +2180,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
> > >  static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
> > >  {
> > >         int all_zones_ok;
> > > +       int any_zone_ok;
> > >         int priority;
> > >         int i;
> > >         unsigned long total_scanned;
> > > @@ -2201,6 +2214,7 @@ loop_again:
> > >                         disable_swap_token();
> > > 
> > >                 all_zones_ok = 1;
> > > +               any_zone_ok = 0;
> > > 
> > >                 /*
> > >                  * Scan in the highmem->dma direction for the highest
> > > @@ -2310,10 +2324,12 @@ loop_again:
> > >                                  * spectulatively avoid congestion waits
> > >                                  */
> > >                                 zone_clear_flag(zone, ZONE_CONGESTED);
> > > +                               if (i <= pgdat->high_zoneidx)
> > > +                                       any_zone_ok = 1;
> > >                         }
> > > 
> > >                 }
> > > -               if (all_zones_ok)
> > > +               if (all_zones_ok || (order && any_zone_ok))
> > >                         break;          /* kswapd: all done */
> > >                 /*
> > >                  * OK, kswapd is getting into trouble.  Take a nap, then take
> > > @@ -2336,7 +2352,7 @@ loop_again:
> > >                         break;
> > >         }
> > >  out:
> > > -       if (!all_zones_ok) {
> > > +       if (!(all_zones_ok || (order && any_zone_ok))) {
> > >                 cond_resched();
> > > 
> > >                 try_to_freeze();
> > > @@ -2361,7 +2377,13 @@ out:
> > >                 goto loop_again;
> > >         }
> > > 
> > > -       return sc.nr_reclaimed;
> > > +       /*
> > > +        * Return the order we were reclaiming at so sleeping_prematurely()
> > > +        * makes a decision on the order we were last reclaiming at. However,
> > > +        * if another caller entered the allocator slow path while kswapd
> > > +        * was awake, order will remain at the higher level
> > > +        */
> > > +       return order;
> > >  }
> > This seems always fail. because you have the protect in the kswapd side,
> > but no in the page allocation side. so every time a high order
> > allocation occurs, the protect breaks and kswapd keeps running.
> > 
> 
> I don't understand your question. sc.nr_reclaimed was being unused. The
> point of returning order was to tell kswapd that "the order you were
> reclaiming at may or may not be still valid, make your decisions on the
> order I am currently reclaiming at". The key here is if that multiple
> allocation requests come in for higher orders, kswapd will get reworken
> multiple times. Unless it gets rewoken multiple times, kswapd is willing
> to go back to sleep to avoid reclaiming an excessive number of pages.
yes, I thought is rewoken multiple times, in the workload Simon reported
Node 0, zone    DMA32  20741  29383   6022    134    272   123 4 0 0 0 0
Node 0, zone   Normal    453      1      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  20476  29370   6024    117     48   116 4 0 0 0 0
Node 0, zone   Normal    453      1      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  20343  29369   6020    110     23    10 2 0 0 0 0
Node 0, zone   Normal    453      1      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  21592  30477   4856     22     10     4 2 0 0 0 0
order >=3 pages are reduced a lot in a second

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
