Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E63A56B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 06:29:42 -0400 (EDT)
Date: Wed, 28 Oct 2009 10:29:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when
	high-order watermarks are being hit
Message-ID: <20091028102936.GS8900@csn.ul.ie>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <1256650833-15516-4-git-send-email-mel@csn.ul.ie> <20091027131905.410ec04a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091027131905.410ec04a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 27, 2009 at 01:19:05PM -0700, Andrew Morton wrote:
> On Tue, 27 Oct 2009 13:40:33 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > When a high-order allocation fails, kswapd is kicked so that it reclaims
> > at a higher-order to avoid direct reclaimers stall and to help GFP_ATOMIC
> > allocations. Something has changed in recent kernels that affect the timing
> > where high-order GFP_ATOMIC allocations are now failing with more frequency,
> > particularly under pressure. This patch forces kswapd to notice sooner that
> > high-order allocations are occuring.
> > 
> 
> "something has changed"?  Shouldn't we find out what that is?
> 

We've been trying but the answer right now is "lots". There were some
changes in the allocator itself which were unintentional and fixed in
patches 1 and 2 of this series. The two other major changes are

iwlagn is now making high order GFP_ATOMIC allocations which didn't
help. This is being addressed separetly and I believe the relevant
patches are now in mainline.

The other major change appears to be in page writeback. Reverting
commits 373c0a7e + 8aa7e847 significantly helps one bug reporter but
it's still unknown as to why that is.

The latter is still being investigated but as the patches in this series
are known to help some bug reporters with their GFP_ATOMIC failures and
it is being reported against latest mainline and -stable, I felt it was
best to help some of the bug reporters now to reduce duplicate reports.

> > ---
> >  mm/vmscan.c |    9 +++++++++
> >  1 files changed, 9 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 64e4388..7eceb02 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2016,6 +2016,15 @@ loop_again:
> >  					priority != DEF_PRIORITY)
> >  				continue;
> >  
> > +			/*
> > +			 * Exit the function now and have kswapd start over
> > +			 * if it is known that higher orders are required
> > +			 */
> > +			if (pgdat->kswapd_max_order > order) {
> > +				all_zones_ok = 1;
> > +				goto out;
> > +			}
> > +
> >  			if (!zone_watermark_ok(zone, order,
> >  					high_wmark_pages(zone), end_zone, 0))
> >  				all_zones_ok = 0;
> 
> So this handles the case where some concurrent thread or interrupt
> increases pgdat->kswapd_max_order while kswapd was running
> balance_pgdat(), yes?
> 

Right.

> Does that actually happen much?  Enough for this patch to make any
> useful difference?
> 

Apparently, yes. Wireless drivers in particularly seem to be very
high-order GFP_ATOMIC happy.

> If one where to whack a printk in that `if' block, how often would it
> trigger, and under what circumstances?

I don't know the frequency. The circumstances are "under load" when
there are drivers depending on high-order allocations but the
reproduction cases are unreliable.

Do you want me to slap together a patch that adds a vmstat counter for
this? I can then ask future bug reporters to examine that counter and see
if it really is a major factor for a lot of people or not.

> If the -stable maintainers were to ask me "why did you send this" then
> right now my answer would have to be "I have no idea".  Help.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
