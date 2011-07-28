Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 43F4D6B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 06:56:17 -0400 (EDT)
Date: Thu, 28 Jul 2011 11:56:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/3]vmscan: clear ZONE_CONGESTED for zone with good
 watermark
Message-ID: <20110728105611.GJ3010@suse.de>
References: <1311840781.15392.407.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1311840781.15392.407.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 28, 2011 at 04:13:01PM +0800, Shaohua Li wrote:
> correctly clear ZONE_CONGESTED. If a zone watermark is ok, we
> should clear ZONE_CONGESTED regardless if this is a high order
> allocation, because pages can be reclaimed in other tasks but
> ZONE_CONGESTED is only cleared in kswapd.
> 

What problem does this solve?

As it is, for high order allocations it takes the following steps

If reclaiming at high order {
	for each zone {
		if all_unreclaimable
			skip
		if watermark is not met
			order = 0
			loop again
		
		/* watermark is met */
		clear congested
	}
}

If high orders are failing, kswapd balances for order-0 where there
is already a cleaning of ZONE_CONGESTED if the zone was shrunk and
became balanced. I see the case for hunk 1 of the patch because now
it'll clear ZONE_CONGESTED for zones that are already balanced which
might have a noticable effect on wait_iff_congested. Is this what
you see? Even if it is, it does not explain hunk 2 of the patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
