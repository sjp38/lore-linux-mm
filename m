Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA0776B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 01:50:41 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j134so4126344oib.1
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 22:50:41 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g185si2133883ioe.130.2016.07.06.22.50.40
        for <linux-mm@kvack.org>;
        Wed, 06 Jul 2016 22:50:40 -0700 (PDT)
Date: Thu, 7 Jul 2016 14:51:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 08/31] mm, vmscan: simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160707055121.GA18072@bbox>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-9-git-send-email-mgorman@techsingularity.net>
 <20160705055931.GC28164@bbox>
 <20160705102639.GG11498@techsingularity.net>
 <20160706003054.GC12570@bbox>
 <20160706083121.GL11498@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <20160706083121.GL11498@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 06, 2016 at 09:31:21AM +0100, Mel Gorman wrote:
> On Wed, Jul 06, 2016 at 09:30:54AM +0900, Minchan Kim wrote:
> > On Tue, Jul 05, 2016 at 11:26:39AM +0100, Mel Gorman wrote:
> > 
> > <snip>
> > 
> > > > > @@ -3418,10 +3426,10 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
> > > > >  	if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
> > > > >  		return;
> > > > >  	pgdat = zone->zone_pgdat;
> > > > > -	if (pgdat->kswapd_max_order < order) {
> > > > > -		pgdat->kswapd_max_order = order;
> > > > > -		pgdat->classzone_idx = min(pgdat->classzone_idx, classzone_idx);
> > > > > -	}
> > > > > +	if (pgdat->kswapd_classzone_idx == -1)
> > > > > +		pgdat->kswapd_classzone_idx = classzone_idx;
> > > > 
> > > > It's tricky. Couldn't we change kswapd_classzone_idx to integer type
> > > > and remove if above if condition?
> > > > 
> > > 
> > > It's tricky and not necessarily better overall. It's perfectly possible
> > > to be woken up for zone index 0 so it's changing -1 to another magic
> > > value.
> > 
> > I don't get it. What is a problem with this?
> > 
> 
> It becomes difficult to tell the difference between "no wakeup and init to
> zone 0" and "wakeup and reclaim for zone 0". At least that's the problem
> I ran into when I tried before settling on -1.

Sorry for bothering you several times. I cannot parse what you mean.
I didn't mean -1 is problem here but why do we need below two lines
I removed?

IOW, what's the problem if we apply below patch?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c538a8c..6eb23f5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3413,9 +3413,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
        if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
                return;
        pgdat = zone->zone_pgdat;
-       if (pgdat->kswapd_classzone_idx == -1)
-               pgdat->kswapd_classzone_idx = classzone_idx;
-       pgdat->kswapd_classzone_idx = max(pgdat->kswapd_classzone_idx, classzone_idx);
+       pgdat->kswapd_classzone_idx = max_t(int, pgdat->kswapd_classzone_idx, classzone_idx);
        pgdat->kswapd_order = max(pgdat->kswapd_order, order);
        if (!waitqueue_active(&pgdat->kswapd_wait))
                return;  

> 
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
