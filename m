Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53578828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 04:31:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c82so105835038wme.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 01:31:24 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id kr10si2337856wjc.169.2016.07.06.01.31.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Jul 2016 01:31:23 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id B5761210047
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 08:31:22 +0000 (UTC)
Date: Wed, 6 Jul 2016 09:31:21 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 08/31] mm, vmscan: simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160706083121.GL11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-9-git-send-email-mgorman@techsingularity.net>
 <20160705055931.GC28164@bbox>
 <20160705102639.GG11498@techsingularity.net>
 <20160706003054.GC12570@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160706003054.GC12570@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 06, 2016 at 09:30:54AM +0900, Minchan Kim wrote:
> On Tue, Jul 05, 2016 at 11:26:39AM +0100, Mel Gorman wrote:
> 
> <snip>
> 
> > > > @@ -3418,10 +3426,10 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
> > > >  	if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
> > > >  		return;
> > > >  	pgdat = zone->zone_pgdat;
> > > > -	if (pgdat->kswapd_max_order < order) {
> > > > -		pgdat->kswapd_max_order = order;
> > > > -		pgdat->classzone_idx = min(pgdat->classzone_idx, classzone_idx);
> > > > -	}
> > > > +	if (pgdat->kswapd_classzone_idx == -1)
> > > > +		pgdat->kswapd_classzone_idx = classzone_idx;
> > > 
> > > It's tricky. Couldn't we change kswapd_classzone_idx to integer type
> > > and remove if above if condition?
> > > 
> > 
> > It's tricky and not necessarily better overall. It's perfectly possible
> > to be woken up for zone index 0 so it's changing -1 to another magic
> > value.
> 
> I don't get it. What is a problem with this?
> 

It becomes difficult to tell the difference between "no wakeup and init to
zone 0" and "wakeup and reclaim for zone 0". At least that's the problem
I ran into when I tried before settling on -1.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
