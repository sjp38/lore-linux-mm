Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4346B008C
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 05:54:27 -0500 (EST)
Date: Wed, 15 Dec 2010 10:54:06 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/6] mm: kswapd: Keep kswapd awake for high-order
	allocations until a percentage of the node is balanced
Message-ID: <20101215105406.GI13914@csn.ul.ie>
References: <1291995985-5913-1-git-send-email-mel@csn.ul.ie> <1291995985-5913-3-git-send-email-mel@csn.ul.ie> <20101214144341.71b43cb5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101214144341.71b43cb5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 14, 2010 at 02:43:41PM -0800, Andrew Morton wrote:
> On Fri, 10 Dec 2010 15:46:21 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > When reclaiming for high-orders, kswapd is responsible for balancing a
> > node but it should not reclaim excessively. It avoids excessive reclaim by
> > considering if any zone in a node is balanced then the node is balanced.
> 
> Here you're referring to your [patch 1/6] yes?  Not to current upstream.
> 

Yes.

> > In
> > the cases where there are imbalanced zone sizes (e.g. ZONE_DMA with both
> > ZONE_DMA32 and ZONE_NORMAL), kswapd can go to sleep prematurely as just
> > one small zone was balanced.
> 
> Since [1/6]?
> 

Yes.

> > This alters the sleep logic of kswapd slightly. It counts the number of pages
> > that make up the balanced zones. If the total number of balanced pages is
> 
> Define "balanced page"?  Seems to be the sum of the total sizes of all
> zones which have reached their desired free-pages threshold?
> 

Correct.

> But this includes all page orders, whereas here we're targetting a
> particular order.  Although things should work out OK due to the
> scaling/sizing proportionality.
> 

It's the size of the whole zone that is being accounted for and as it's
a watermark check, the order is being taken into account.

> > more than a quarter of the zone, kswapd will go back to sleep. This should
> > keep a node balanced without reclaiming an excessive number of pages.
> 
> ick.
> 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > ---
> >  mm/vmscan.c |   58 +++++++++++++++++++++++++++++++++++++++++++++++++---------
> >  1 files changed, 49 insertions(+), 9 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 625dfba..6723101 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2191,10 +2191,40 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
> >  }
> >  #endif
> >  
> > +/*
> > + * pgdat_balanced is used when checking if a node is balanced for high-order
> > + * allocations.
> 
> Is this the correct use of the term "balanced"?  I think "balanced" is
> something that happens *between* zones: They've all achieved the same
> (perhaps weighted) ratio of free pages.  
> 

What would be a better term?  pgdat_sufficiently_but_not_fully_balanced()? If
it returns true, it can mean the node is either fully "balanced" as you
define it or that enough zones have enough free suitably-ordered pages for
allocations to succeed.

> >  Only zones that meet watermarks and are in a zone allowed
> > + * by the callers classzone_idx are added to balanced_pages. The total of
> 
> caller's
> 

Right.

> > + * balanced pages must be at least 25% of the zones allowed by classzone_idx
> > + * for the node to be considered balanced. Forcing all zones to be balanced
> > + * for high orders can cause excessive reclaim when there are imbalanced zones.
> 
> Excessive reclaim of what?
> 

slab, list rotations and pages within the imbalanced zones that may never
become balanced. Minimally, kswapd just stays awake consuming CPU.

> If one particular zone is having trouble achieving its desired level of
> free pages of a partocular order, are you saying that kswapd sits there
> madly scanning other zones, which have already reached their desired
> level?  If so, that would be bad.
> 

As far as I can gather, yes, this is what is happening. I don't have a local
reproduction case so I'm basing this on a bug report. He has two problems -
kswapd stays awake constantly and way too many pages are free.

> I think you're saying that we just keep on scanning away at this one
> zone.  But what was wrong with doing that?
> 

It wastes CPU.

> > + * The choice of 25% is due to
> > + *   o a 16M DMA zone that is balanced will not balance a zone on any
> > + *     reasonable sized machine
> 
> How does a zone balance another zone?
> 

That should have been "will not balance a node".

> > + *   o On all other machines, the top zone must be at least a reasonable
> > + *     precentage of the middle zones. For example, on 32-bit x86, highmem
> > + *     would need to be at least 256M for it to be balance a whole node.
> > + *     Similarly, on x86-64 the Normal zone would need to be at least 1G
> > + *     to balance a node on its own. These seemed like reasonable ratios.
> > + */
> > +static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
> > +						int classzone_idx)
> > +{
> > +	unsigned long present_pages = 0;
> > +	int i;
> > +
> > +	for (i = 0; i <= classzone_idx; i++)
> > +		present_pages += pgdat->node_zones[i].present_pages;
> > +
> > +	return balanced_pages > (present_pages >> 2);
> > +}
> > +
> >
> > ...
> >
> 

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
