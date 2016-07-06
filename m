Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D40A828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 21:25:05 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id fq2so460073398obb.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 18:25:05 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z64si852080itd.81.2016.07.05.18.25.04
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 18:25:04 -0700 (PDT)
Date: Wed, 6 Jul 2016 10:25:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 11/31] mm: vmscan: do not reclaim from kswapd if there is
 any eligible zone
Message-ID: <20160706012554.GD12570@bbox>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-12-git-send-email-mgorman@techsingularity.net>
 <20160705061117.GD28164@bbox>
 <20160705103806.GH11498@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160705103806.GH11498@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 05, 2016 at 11:38:06AM +0100, Mel Gorman wrote:
> On Tue, Jul 05, 2016 at 03:11:17PM +0900, Minchan Kim wrote:
> > > -		if (i < 0)
> > > -			goto out;
> > > +		/*
> > > +		 * Only reclaim if there are no eligible zones. Check from
> > > +		 * high to low zone to avoid prematurely clearing pgdat
> > > +		 * congested state.
> > 
> > I cannot understand "prematurely clearing pgdat congested state".
> > Could you add more words to clear it out?
> > 
> 
> It's surprisingly difficult to concisely explain. Is this any better?
> 
>                 /*
>                  * Only reclaim if there are no eligible zones. Check from
>                  * high to low zone as allocations prefer higher zones.
>                  * Scanning from low to high zone would allow congestion to be
>                  * cleared during a very small window when a small low
>                  * zone was balanced even under extreme pressure when the
>                  * overall node may be congested.
>                  */

Surely, it's better. Thanks for the explaining.

I doubt we need such corner case logic at this moment and how it works well
without consistent scan from other callers of zone_balanced where scans
from low to high.

> > > +		 */
> > > +		for (i = classzone_idx; i >= 0; i--) {
> > > +			zone = pgdat->node_zones + i;
> > > +			if (!populated_zone(zone))
> > > +				continue;
> > > +
> > > +			if (zone_balanced(zone, sc.order, classzone_idx))
> > 
> > If buffer_head is over limit, old logic force to reclaim highmem but
> > this zone_balanced logic will prevent it.
> > 
> 
> The old logic was always busted on 64-bit because is_highmem would always
> be 0. The original intent appears to be that buffer_heads_over_limit
> would release the buffers when pages went inactive. There are a number

Yes but the difference is in old, it was handled both direct and background
reclaim once buffers_heads is over the limit but your change slightly
changs it so kswapd couldn't reclaim high zone if any eligible zone
is balanced. I don't know how big difference it can make but we saw
highmem buffer_head problems several times, IIRC. So, I just wanted
to notice it to you. whether it's handled or not, it's up to you.

> of things we treated inconsistently that get fixed up in the series and
> buffer_heads_over_limit is one of them.
> 
> -- 
> Mel Gorman
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
