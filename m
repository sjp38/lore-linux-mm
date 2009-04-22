Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0F06B00AF
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 06:23:20 -0400 (EDT)
Date: Wed, 22 Apr 2009 11:23:33 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 21/25] Use allocation flags as an index to the zone
	watermark
Message-ID: <20090422102333.GA15367@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-22-git-send-email-mel@csn.ul.ie> <20090422092429.6271.A69D9226@jp.fujitsu.com> <20090422102117.GC10380@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090422102117.GC10380@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 22, 2009 at 11:21:17AM +0100, Mel Gorman wrote:
> On Wed, Apr 22, 2009 at 09:26:10AM +0900, KOSAKI Motohiro wrote:
> > > ALLOC_WMARK_MIN, ALLOC_WMARK_LOW and ALLOC_WMARK_HIGH determin whether
> > > pages_min, pages_low or pages_high is used as the zone watermark when
> > > allocating the pages. Two branches in the allocator hotpath determine which
> > > watermark to use. This patch uses the flags as an array index and places
> > > the three watermarks in a union with an array so it can be offset. This
> > > means the flags can be used as an array index and reduces the branches
> > > taken.
> > > 
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> > > ---
> > >  include/linux/mmzone.h |    8 +++++++-
> > >  mm/page_alloc.c        |   18 ++++++++----------
> > >  2 files changed, 15 insertions(+), 11 deletions(-)
> > > 
> > > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > > index f82bdba..c1fa208 100644
> > > --- a/include/linux/mmzone.h
> > > +++ b/include/linux/mmzone.h
> > > @@ -275,7 +275,13 @@ struct zone_reclaim_stat {
> > >  
> > >  struct zone {
> > >  	/* Fields commonly accessed by the page allocator */
> > > -	unsigned long		pages_min, pages_low, pages_high;
> > > +	union {
> > > +		struct {
> > > +			unsigned long	pages_min, pages_low, pages_high;
> > > +		};
> > > +		unsigned long pages_mark[3];
> > > +	};
> > > +
> > 
> > hmmm... I don't like union hack. 
> > Why can't we change all caller to use page_mark?
> > 
> 
> Because pages_min, pages_low and pages_high are such well understood concepts
> and their current use is easy to userstand. It could all be changed to getters
> and setters with a patch to update all call sites or having symbolic names
> for the index and forcing the use of the array but when I started doing that,
> the code looked worse to my eye, not better.  The union is a relatively
> small hack but well contained within the one place that cares.
> 
> > >  	/*
> > >  	 * We don't know if the memory that we're going to allocate will be freeable
> > >  	 * or/and it will be released eventually, so to avoid totally wasting several
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 376d848..e61867e 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1157,10 +1157,13 @@ failed:
> > >  	return NULL;
> > >  }
> > >  
> > > -#define ALLOC_NO_WATERMARKS	0x01 /* don't check watermarks at all */
> > > -#define ALLOC_WMARK_MIN		0x02 /* use pages_min watermark */
> > > -#define ALLOC_WMARK_LOW		0x04 /* use pages_low watermark */
> > > -#define ALLOC_WMARK_HIGH	0x08 /* use pages_high watermark */
> > > +/* The WMARK bits are used as an index zone->pages_mark */
> > > +#define ALLOC_WMARK_MIN		0x00 /* use pages_min watermark */
> > > +#define ALLOC_WMARK_LOW		0x01 /* use pages_low watermark */
> > > +#define ALLOC_WMARK_HIGH	0x02 /* use pages_high watermark */
> > > +#define ALLOC_NO_WATERMARKS	0x08 /* don't check watermarks at all */
> > > +#define ALLOC_WMARK_MASK	0x07 /* Mask to get the watermark bits */
> > 
> > the mask only use two bit. but mask definition is three bit (0x07), why?
> > 
> 
> I was thinking ALLOC_NO_WATERMARKS-1 and that all the lower bits must be
> cleared and left the value of 0x08 to occupy same number of bits even though
> that wasn't necessary. As suggested I'll change this to
> 
> ALLOC_NO_WATERMARKS	0x04
> WMARK_MASK		(1-ALLOC_NO_WATERMARKS)
> 

ALLOC_NO_WATERMARKS-1 obviously is what I meant

> > 
> > > +
> > >  #define ALLOC_HARDER		0x10 /* try to alloc harder */
> > >  #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
> > >  #ifdef CONFIG_CPUSETS
> > > @@ -1463,12 +1466,7 @@ zonelist_scan:
> > >  
> > >  		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
> > >  			unsigned long mark;
> > > -			if (alloc_flags & ALLOC_WMARK_MIN)
> > > -				mark = zone->pages_min;
> > > -			else if (alloc_flags & ALLOC_WMARK_LOW)
> > > -				mark = zone->pages_low;
> > > -			else
> > > -				mark = zone->pages_high;
> > > +			mark = zone->pages_mark[alloc_flags & ALLOC_WMARK_MASK];
> > >  			if (!zone_watermark_ok(zone, order, mark,
> > >  				    classzone_idx, alloc_flags)) {
> > >  				if (!zone_reclaim_mode ||
> > > -- 
> > > 1.5.6.5
> > > 
> > 
> > 
> > 
> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
