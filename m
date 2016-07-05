Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8E86B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 06:38:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so85037061wma.3
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 03:38:10 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id 185si562699wmc.80.2016.07.05.03.38.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 03:38:09 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id A2FED1C1EC8
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 11:38:08 +0100 (IST)
Date: Tue, 5 Jul 2016 11:38:06 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 11/31] mm: vmscan: do not reclaim from kswapd if there is
 any eligible zone
Message-ID: <20160705103806.GH11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-12-git-send-email-mgorman@techsingularity.net>
 <20160705061117.GD28164@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160705061117.GD28164@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 05, 2016 at 03:11:17PM +0900, Minchan Kim wrote:
> > -		if (i < 0)
> > -			goto out;
> > +		/*
> > +		 * Only reclaim if there are no eligible zones. Check from
> > +		 * high to low zone to avoid prematurely clearing pgdat
> > +		 * congested state.
> 
> I cannot understand "prematurely clearing pgdat congested state".
> Could you add more words to clear it out?
> 

It's surprisingly difficult to concisely explain. Is this any better?

                /*
                 * Only reclaim if there are no eligible zones. Check from
                 * high to low zone as allocations prefer higher zones.
                 * Scanning from low to high zone would allow congestion to be
                 * cleared during a very small window when a small low
                 * zone was balanced even under extreme pressure when the
                 * overall node may be congested.
                 */
> > +		 */
> > +		for (i = classzone_idx; i >= 0; i--) {
> > +			zone = pgdat->node_zones + i;
> > +			if (!populated_zone(zone))
> > +				continue;
> > +
> > +			if (zone_balanced(zone, sc.order, classzone_idx))
> 
> If buffer_head is over limit, old logic force to reclaim highmem but
> this zone_balanced logic will prevent it.
> 

The old logic was always busted on 64-bit because is_highmem would always
be 0. The original intent appears to be that buffer_heads_over_limit
would release the buffers when pages went inactive. There are a number
of things we treated inconsistently that get fixed up in the series and
buffer_heads_over_limit is one of them.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
