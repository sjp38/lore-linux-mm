Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C1D1E828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 04:42:03 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so106097231wma.3
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 01:42:03 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id o26si2969955wmi.60.2016.07.06.01.42.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 01:42:02 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 0BEC31C24E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 09:42:02 +0100 (IST)
Date: Wed, 6 Jul 2016 09:42:00 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 11/31] mm: vmscan: do not reclaim from kswapd if there is
 any eligible zone
Message-ID: <20160706084200.GM11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-12-git-send-email-mgorman@techsingularity.net>
 <20160705061117.GD28164@bbox>
 <20160705103806.GH11498@techsingularity.net>
 <20160706012554.GD12570@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160706012554.GD12570@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 06, 2016 at 10:25:54AM +0900, Minchan Kim wrote:
> On Tue, Jul 05, 2016 at 11:38:06AM +0100, Mel Gorman wrote:
> > On Tue, Jul 05, 2016 at 03:11:17PM +0900, Minchan Kim wrote:
> > > > -		if (i < 0)
> > > > -			goto out;
> > > > +		/*
> > > > +		 * Only reclaim if there are no eligible zones. Check from
> > > > +		 * high to low zone to avoid prematurely clearing pgdat
> > > > +		 * congested state.
> > > 
> > > I cannot understand "prematurely clearing pgdat congested state".
> > > Could you add more words to clear it out?
> > > 
> > 
> > It's surprisingly difficult to concisely explain. Is this any better?
> > 
> >                 /*
> >                  * Only reclaim if there are no eligible zones. Check from
> >                  * high to low zone as allocations prefer higher zones.
> >                  * Scanning from low to high zone would allow congestion to be
> >                  * cleared during a very small window when a small low
> >                  * zone was balanced even under extreme pressure when the
> >                  * overall node may be congested.
> >                  */
> 
> Surely, it's better. Thanks for the explaining.
> 
> I doubt we need such corner case logic at this moment and how it works well
> without consistent scan from other callers of zone_balanced where scans
> from low to high.
> 

I observed that if scanning from low to high here that under heavy memory
pressure that kswapd would scan much more aggressively but unable to reclaim
pages. Granted, part of the problem at the time was that kswapd was woken
based on the first zone in the zoneref instead of the highest zone allowed
by the allocation request which gets addressed by "mm, page_alloc: wake
kswapd based on the highest eligible zone".

> > > > +		 */
> > > > +		for (i = classzone_idx; i >= 0; i--) {
> > > > +			zone = pgdat->node_zones + i;
> > > > +			if (!populated_zone(zone))
> > > > +				continue;
> > > > +
> > > > +			if (zone_balanced(zone, sc.order, classzone_idx))
> > > 
> > > If buffer_head is over limit, old logic force to reclaim highmem but
> > > this zone_balanced logic will prevent it.
> > > 
> > 
> > The old logic was always busted on 64-bit because is_highmem would always
> > be 0. The original intent appears to be that buffer_heads_over_limit
> > would release the buffers when pages went inactive. There are a number
> 
> Yes but the difference is in old, it was handled both direct and background
> reclaim once buffers_heads is over the limit but your change slightly
> changs it so kswapd couldn't reclaim high zone if any eligible zone
> is balanced. I don't know how big difference it can make but we saw
> highmem buffer_head problems several times, IIRC. So, I just wanted
> to notice it to you. whether it's handled or not, it's up to you.
> 

The last time I remember buffer_heads_over_limit was an NTFS filesystem
using small sub-page block sizes with a large highmem:lowmem ratio. If a
similar situation is encountered then a test patch would be something like;

diff --git a/mm/vmscan.c b/mm/vmscan.c
index dc12af938a8d..a8ebd1871f16 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3151,7 +3151,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 * zone was balanced even under extreme pressure when the
 		 * overall node may be congested.
 		 */
-		for (i = sc.reclaim_idx; i >= 0; i--) {
+		for (i = sc.reclaim_idx; i >= 0 && !buffer_heads_over_limit; i--) {
 			zone = pgdat->node_zones + i;
 			if (!populated_zone(zone))
 				continue;

I'm not going to go with it for now because buffer_heads_over_limit is not
necessarily a problem unless lowmem is factor. We don't want background
reclaim to go ahead unnecessarily just because buffer_heads_over_limit.
It could be distinguished by only forcing reclaim to go ahead on systems
with highmem.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
