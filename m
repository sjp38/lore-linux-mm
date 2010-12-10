Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 92B3D6B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 05:37:02 -0500 (EST)
Date: Fri, 10 Dec 2010 10:36:42 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/6] mm: kswapd: Use the order that kswapd was
	reclaiming at for sleeping_prematurely()
Message-ID: <20101210103642.GK20133@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie> <1291893500-12342-4-git-send-email-mel@csn.ul.ie> <AANLkTi=2LYh04DMagfEQ6dtsfrzzLtopPG--BW+SGtpy@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTi=2LYh04DMagfEQ6dtsfrzzLtopPG--BW+SGtpy@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 10, 2010 at 10:16:19AM +0900, Minchan Kim wrote:
> On Thu, Dec 9, 2010 at 8:18 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > Before kswapd goes to sleep, it uses sleeping_prematurely() to check if
> > there was a race pushing a zone below its watermark. If the race
> > happened, it stays awake. However, balance_pgdat() can decide to reclaim
> > at a lower order if it decides that high-order reclaim is not working as
> 
> Could you specify "order-0" explicitly instead of "a lower order"?
> It makes more clear to me.
> 

Done.

> > expected. This information is not passed back to sleeping_prematurely().
> > The impact is that kswapd remains awake reclaiming pages long after it
> > should have gone to sleep. This patch passes the adjusted order to
> > sleeping_prematurely and uses the same logic as balance_pgdat to decide
> > if it's ok to go to sleep.
> >
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> A comment below.
> 
> > ---
> >  mm/vmscan.c |   14 ++++++++++----
> >  1 files changed, 10 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index b4472a1..52e229e 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2132,7 +2132,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced)
> >  }
> >
> >  /* is kswapd sleeping prematurely? */
> > -static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
> > +static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
> >  {
> >        int i;
> >        unsigned long balanced = 0;
> > @@ -2142,7 +2142,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
> >        if (remaining)
> >                return 1;
> >
> > -       /* If after HZ/10, a zone is below the high mark, it's premature */
> > +       /* Check the watermark levels */
> >        for (i = 0; i < pgdat->nr_zones; i++) {
> >                struct zone *zone = pgdat->node_zones + i;
> >
> > @@ -2427,7 +2427,13 @@ out:
> >                }
> >        }
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
> 
> Please change return value description of balance_pgdat.
> "Returns the number of pages which were actually freed"
> 

Oops, done. Thanks

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
