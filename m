Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EB5B28D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 10:28:23 -0500 (EST)
Date: Thu, 27 Jan 2011 16:27:55 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110127152755.GB30919@random.random>
References: <1295841406.1949.953.camel@sli10-conroe>
 <20110124150033.GB9506@random.random>
 <20110126141746.GS18984@csn.ul.ie>
 <20110126152302.GT18984@csn.ul.ie>
 <20110126154203.GS926@random.random>
 <20110126163655.GU18984@csn.ul.ie>
 <20110126174236.GV18984@csn.ul.ie>
 <20110127134057.GA32039@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110127134057.GA32039@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 27, 2011 at 01:40:58PM +0000, Mel Gorman wrote:
> On Wed, Jan 26, 2011 at 05:42:37PM +0000, Mel Gorman wrote:
> > On Wed, Jan 26, 2011 at 04:36:55PM +0000, Mel Gorman wrote:
> > > > But the wmarks don't
> > > > seem the real offender, maybe it's something related to the tiny pci32
> > > > zone that materialize on 4g systems that relocate some little memory
> > > > over 4g to make space for the pci32 mmio. I didn't yet finish to debug
> > > > it.
> > > > 
> > > 
> > > This has to be it. What I think is happening is that we're in balance_pgdat(),
> > > the "Normal" zone is never hitting the watermark and we constantly call
> > > "goto loop_again" trying to "rebalance" all zones.
> > > 
> > 
> > Confirmed.
> > <SNIP>
> 
> How about the following? Functionally it would work but I am concerned
> that the logic in balance_pgdat() and kswapd() is getting out of hand
> having being adjusted to work with a number of corner cases already. In
> the next cycle, it could do with a "do-over" attempt to make it easier
> to follow.

That number 8 is the problem, I don't think anybody was ever supposed
to free 8*highwmark pages. kswapd must work in the hysteresis range
low->high area and then sleep wait low to hit again before it gets
wakenup. Not sure how that number 8 ever come up... but to be it looks
like the real offender and I wouldn't work around it.

totally untested... I will test....

====
Subject: vmscan: kswapd must not free more than high_wmark pages

From: Andrea Arcangeli <aarcange@redhat.com>

When the min_free_kbytes is set with `hugeadm
--set-recommended-min_free_kbytes" or with THP enabled (which runs the
equivalent of "hugeadm --set-recommended-min_free_kbytes" to activate
anti-frag at full effectiveness automatically at boot) the high wmark
of some zone is as high as ~88M. 88M free on a 4G system isn't
horrible, but 88M*8 = 704M free on a 4G system is definitely
unbearable. This only tends to be visible on 4G systems with tiny
over-4g zone where kswapd insists to reach the high wmark on the
over-4g zone but doing so it shrunk up to 704M from the normal zone by
mistake.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---


diff --git a/mm/vmscan.c b/mm/vmscan.c
index f5d90de..9e3c78e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2407,7 +2407,7 @@ loop_again:
 			 * zone has way too many pages free already.
 			 */
 			if (!zone_watermark_ok_safe(zone, order,
-					8*high_wmark_pages(zone), end_zone, 0))
+					high_wmark_pages(zone), end_zone, 0))
 				shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
