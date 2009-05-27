Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB776B004F
	for <linux-mm@kvack.org>; Wed, 27 May 2009 05:48:18 -0400 (EDT)
Date: Wed, 27 May 2009 10:48:58 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Use integer fields lookup for gfp_zone and check for
	errors in flags passed to the page allocator
Message-ID: <20090527094857.GA633@csn.ul.ie>
References: <alpine.DEB.1.10.0905221438120.5515@qirst.com> <20090525113004.GD12160@csn.ul.ie> <alpine.DEB.1.10.0905261401100.5632@gentwo.org> <20090526232620.GA6189@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090526232620.GA6189@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, npiggin@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 27, 2009 at 12:26:20AM +0100, Mel Gorman wrote:
> On Tue, May 26, 2009 at 02:04:35PM -0400, Christoph Lameter wrote:
> > On Mon, 25 May 2009, Mel Gorman wrote:
> > 
> > > I expect that the machine would start running into reclaim issues with
> > > enough uptime because it'll not be using Highmem as it should. Similarly,
> > > the GFP_DMA32 may also be a problem as the new implementation is going
> > > ZONE_DMA when ZONE_NORMAL would have been ok in this case.
> > 
> > Right. The fallback for DMA32 is wrong. Should fall back to ZONE_NORMAL.
> > Not to DMA. And the config variable to check for highmem was wrong.
> > 
> 
> That fixed things right up on x86 at least and it looks good. I've queued
> up a few tests with the patch applied on x86, x86-64 and ppc64. Hopefully
> it'll go smoothly.
> 

It didn't go perfectly smoothly but I have some results. First off the new
gfp_zone() is now returning the same results for the old gfp_zone() for the
common flag combinations on ppc64, x86 and x86-64. That is good.

On x86-64 (Phenom II X4)
	netperf is showing +/- 1.8% on UDP and TCP tests, consider level
	sysbench is showing +/- 1% on postgres, mostly level
	kernbench is showing +1.7% on system time
	kernbench is showing 0.25% on elapsed time

On ppc64 (ppc970)
	netperf failed to run overnight, my own fault
	sysbench is showing, +1.95%
	kernbench is showing +0.21% on system time
	kernbench is showing -0.01% on elapsed time

The x86 machine was running other tests and didn't catch up in time.

The performance results are mostly good. kernbench is the most allocator
intensive by far and it showed reasonable gains on the system time for both
machines where you'd expect an allocator improvement to have the most impact.
Other results were either flat or showed small gains.

> For your patch + fix merged
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> 

I'm happier with this now. After the tests and another read through the
patch, nothing else jumps out at me.

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

Good work.

> > 
> > Subject: Fix gfp zone patch
> > 
> > 1. If there is no DMA32 fall back to NORMAL instead of DMA
> > 
> > 2. Use the correct config variable for HIGHMEM
> > 
> > Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> > 
> > 
> > ---
> >  include/linux/gfp.h |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > Index: linux-2.6/include/linux/gfp.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/gfp.h	2009-05-26 12:59:19.000000000 -0500
> > +++ linux-2.6/include/linux/gfp.h	2009-05-26 12:59:31.000000000 -0500
> > @@ -112,7 +112,7 @@ static inline int allocflags_to_migratet
> >  		((gfp_flags & __GFP_RECLAIMABLE) != 0);
> >  }
> > 
> > -#ifdef CONFIG_ZONE_HIGHMEM
> > +#ifdef CONFIG_HIGHMEM
> >  #define OPT_ZONE_HIGHMEM ZONE_HIGHMEM
> >  #else
> >  #define OPT_ZONE_HIGHMEM ZONE_NORMAL
> > @@ -127,7 +127,7 @@ static inline int allocflags_to_migratet
> >  #ifdef CONFIG_ZONE_DMA32
> >  #define OPT_ZONE_DMA32 ZONE_DMA32
> >  #else
> > -#define OPT_ZONE_DMA32 OPT_ZONE_DMA
> > +#define OPT_ZONE_DMA32 ZONE_NORMAL
> >  #endif
> > 
> >  /*
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
