Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3B46B003D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 11:35:11 -0400 (EDT)
Date: Wed, 18 Mar 2009 15:35:08 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 24/27] Convert gfp_zone() to use a table of
	precalculated values
Message-ID: <20090318153508.GA24462@csn.ul.ie>
References: <1237226020-14057-1-git-send-email-mel@csn.ul.ie> <1237226020-14057-25-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161500280.20024@qirst.com> <20090318135222.GA4629@csn.ul.ie> <alpine.DEB.1.10.0903181011210.7901@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903181011210.7901@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 18, 2009 at 10:15:26AM -0400, Christoph Lameter wrote:
> On Wed, 18 Mar 2009, Mel Gorman wrote:
> 
> > On Mon, Mar 16, 2009 at 03:12:50PM -0400, Christoph Lameter wrote:
> > > On Mon, 16 Mar 2009, Mel Gorman wrote:
> > >
> > > > +int gfp_zone_table[GFP_ZONEMASK] __read_mostly;
> > >
> > > The gfp_zone_table is compile time determinable. There is no need to
> > > calculate it.
> > >
> >
> > The cost of calculating it is negligible and the code is then freed later
> > in boot. Does having a const table make any difference?
> 
> Should it not enable the compiler to determine the value at
> compile time and therefore make things like gfp_zone(constant) a
> constant?
> 

Yeah, you're right. I didn't think it would but a test program showed
that code accessing const fields like this are calculated at compile
time.

> > > const int gfp_zone_table[GFP_ZONEMASK] = {
> > > 	ZONE_NORMAL,		/* 00 No flags set */
> > > 	ZONE_DMA,		/* 01 Only GFP_DMA set */
> > > 	ZONE_HIGHMEM,		/* 02 Only GFP_HIGHMEM set */
> > > 	ZONE_DMA,		/* 03 GFP_HIGHMEM and GFP_DMA set */
> > > 	ZONE_DMA32,		/* 04 Only GFP_DMA32 set */
> > > 	ZONE_DMA,		/* 05 GFP_DMA and GFP_DMA32 set */
> > > 	ZONE_DMA32,		/* 06 GFP_DMA32 and GFP_HIGHMEM set */
> > > 	ZONE_DMA,		/* 07 GFP_DMA, GFP_DMA32 and GFP_DMA32 set */
> > > 	ZONE_MOVABLE,		/* 08 Only ZONE_MOVABLE set */
> > > 	ZONE_DMA,		/* 09 MOVABLE + DMA */
> > > 	ZONE_MOVABLE,		/* 0A MOVABLE + HIGHMEM */
> > > 	ZONE_DMA,		/* 0B MOVABLE + DMA + HIGHMEM */
> > > 	ZONE_DMA32,		/* 0C MOVABLE + DMA32 */
> > > 	ZONE_DMA,		/* 0D MOVABLE + DMA + DMA32 */
> > > 	ZONE_DMA32,		/* 0E MOVABLE + DMA32 + HIGHMEM */
> > > 	ZONE_DMA		/* 0F MOVABLE + DMA32 + HIGHMEM + DMA
> > > };
> > >
> > > Hmmmm... Guess one would need to add some #ifdeffery here to setup
> > > ZONE_NORMAL in cases there is no DMA, DMA32 and HIGHMEM.
> > >
> >
> > Indeed, as I said, this is somewhat error prone which is why the patch
> > calculates the table at run-time instead of compile-time trickery.
> 
> One would need to define some macros to make it simpler I guess
> 
> Write something like
> 
> #ifdef CONFIG_ZONE_DMA
> #define TZONE_DMA ZONE_DMA
> #else
> #define TZONE_DMA ZONE_NORMAL
> #endif
> 
> for each configurable item. Then just add the T to the above table.
> 

If you don't mind, I'd like to postpone writing such a patch until a second
or third pass at improving the allocator. I don't think I'll have the time
in the short-term to put together a const-initialised-table patch that will
definitily be correct.

Alternatively, I can drop this patch entirely from the set.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
