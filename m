Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7A6618D0001
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 20:25:45 -0500 (EST)
Date: Fri, 26 Nov 2010 01:25:27 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Free memory never fully used, swapping
Message-ID: <20101126012527.GI26037@csn.ul.ie>
References: <20101115195246.GB17387@hostway.ca> <20101122154419.ee0e09d2.akpm@linux-foundation.org> <1290501331.2390.7023.camel@nimitz> <20101124084652.GC25170@hostway.ca> <1290647274.12777.3.camel@sli10-conroe> <20101125090328.GB14180@hostway.ca> <20101125161238.GD26037@csn.ul.ie> <1290733556.12777.5.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1290733556.12777.5.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 26, 2010 at 09:05:56AM +0800, Shaohua Li wrote:
> > @@ -2168,6 +2180,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
> >  static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
> >  {
> >         int all_zones_ok;
> > +       int any_zone_ok;
> >         int priority;
> >         int i;
> >         unsigned long total_scanned;
> > @@ -2201,6 +2214,7 @@ loop_again:
> >                         disable_swap_token();
> > 
> >                 all_zones_ok = 1;
> > +               any_zone_ok = 0;
> > 
> >                 /*
> >                  * Scan in the highmem->dma direction for the highest
> > @@ -2310,10 +2324,12 @@ loop_again:
> >                                  * spectulatively avoid congestion waits
> >                                  */
> >                                 zone_clear_flag(zone, ZONE_CONGESTED);
> > +                               if (i <= pgdat->high_zoneidx)
> > +                                       any_zone_ok = 1;
> >                         }
> > 
> >                 }
> > -               if (all_zones_ok)
> > +               if (all_zones_ok || (order && any_zone_ok))
> >                         break;          /* kswapd: all done */
> >                 /*
> >                  * OK, kswapd is getting into trouble.  Take a nap, then take
> > @@ -2336,7 +2352,7 @@ loop_again:
> >                         break;
> >         }
> >  out:
> > -       if (!all_zones_ok) {
> > +       if (!(all_zones_ok || (order && any_zone_ok))) {
> >                 cond_resched();
> > 
> >                 try_to_freeze();
> > @@ -2361,7 +2377,13 @@ out:
> >                 goto loop_again;
> >         }
> > 
> > -       return sc.nr_reclaimed;
> > +       /*
> > +        * Return the order we were reclaiming at so sleeping_prematurely()
> > +        * makes a decision on the order we were last reclaiming at. However,
> > +        * if another caller entered the allocator slow path while kswapd
> > +        * was awake, order will remain at the higher level
> > +        */
> > +       return order;
> >  }
> This seems always fail. because you have the protect in the kswapd side,
> but no in the page allocation side. so every time a high order
> allocation occurs, the protect breaks and kswapd keeps running.
> 

I don't understand your question. sc.nr_reclaimed was being unused. The
point of returning order was to tell kswapd that "the order you were
reclaiming at may or may not be still valid, make your decisions on the
order I am currently reclaiming at". The key here is if that multiple
allocation requests come in for higher orders, kswapd will get reworken
multiple times. Unless it gets rewoken multiple times, kswapd is willing
to go back to sleep to avoid reclaiming an excessive number of pages.

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
