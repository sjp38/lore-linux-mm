Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 81E7C6B00BE
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:07:24 -0500 (EST)
Date: Tue, 24 Feb 2009 17:07:21 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/19] Convert gfp_zone() to use a table of
	precalculated values
Message-ID: <20090224170721.GB5333@csn.ul.ie>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie> <1235477835-14500-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0902241112310.22519@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0902241112310.22519@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 24, 2009 at 11:43:29AM -0500, Christoph Lameter wrote:
> On Tue, 24 Feb 2009, Mel Gorman wrote:
> 
> >  static inline enum zone_type gfp_zone(gfp_t flags)
> >  {
> > -#ifdef CONFIG_ZONE_DMA
> > -	if (flags & __GFP_DMA)
> > -		return ZONE_DMA;
> > -#endif
> > -#ifdef CONFIG_ZONE_DMA32
> > -	if (flags & __GFP_DMA32)
> > -		return ZONE_DMA32;
> > -#endif
> > -	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
> > -			(__GFP_HIGHMEM | __GFP_MOVABLE))
> > -		return ZONE_MOVABLE;
> > -#ifdef CONFIG_HIGHMEM
> > -	if (flags & __GFP_HIGHMEM)
> > -		return ZONE_HIGHMEM;
> > -#endif
> > -	return ZONE_NORMAL;
> > +	return gfp_zone_table[flags & GFP_ZONEMASK];
> >  }
> 
> Aassume
> 
> GFP_DMA		= 0x01
> GFP_DMA32	= 0x02
> GFP_MOVABLE	= 0x04
> GFP_HIGHMEM	= 0x08
> 
> ZONE_NORMAL	= 0
> ZONE_DMA	= 1
> ZONE_DMA32	= 2
> ZONE_MOVABLE	= 3
> ZONE_HIGHMEM	= 4
> 
> then we could implement gfp_zone simply as:
> 
> static inline enum zone_type gfp_zone(gfp_t flags)
> {
> 	return ffs(flags & 0xf);
> }
> 

A few points immediately spring to mind

o What's the cost of ffs?
o The altering of zone order is not without consequence. The zonelist
  walkers for example make the assumion that the higher the zone index,
  then the "higher" it is. i.e. NORMAL is a bigger index than DMA, HIGHMEM
  is bigger index than NORMAL etc.
o I think movable ends up the wrong "side" of highmem in terms of zone
  order with that scheme and you'd need to redo how the movable zone is
  created.

There are probably other consequences too that I haven't thought of yet.
Summary - this would not be a trivial way fixing anything.

> However, this would return ZONE_MOVABLE if only GFP_MOVABLE would be
> set but not GFP_HIGHMEM.
> 
> If we could make sure that GFP_MOVABLE always includes GFP_HIGHMEM then
> this would not be a problem.
> 

But it wouldn't be right either. It's ok to specify __GFP_MOVABLE without
specifying __GFP_HIGHMEM. Quick grep shows it's not amazingly common but
it's allowed.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
