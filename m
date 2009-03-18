Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6826B0047
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 14:17:21 -0400 (EDT)
Date: Wed, 18 Mar 2009 18:17:17 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 24/27] Convert gfp_zone() to use a table of
	precalculated values
Message-ID: <20090318181717.GC24462@csn.ul.ie>
References: <1237226020-14057-1-git-send-email-mel@csn.ul.ie> <1237226020-14057-25-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161500280.20024@qirst.com> <20090318135222.GA4629@csn.ul.ie> <alpine.DEB.1.10.0903181011210.7901@qirst.com> <20090318153508.GA24462@csn.ul.ie> <alpine.DEB.1.10.0903181300540.15570@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903181300540.15570@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 18, 2009 at 01:21:30PM -0400, Christoph Lameter wrote:
> 
> 
> > time.
> >
> > > > > const int gfp_zone_table[GFP_ZONEMASK] = {
> > > > > 	ZONE_NORMAL,		/* 00 No flags set */
> > > > > 	ZONE_DMA,		/* 01 Only GFP_DMA set */
> > > > > 	ZONE_HIGHMEM,		/* 02 Only GFP_HIGHMEM set */
> > > > > 	ZONE_DMA,		/* 03 GFP_HIGHMEM and GFP_DMA set */
> > > > > 	ZONE_DMA32,		/* 04 Only GFP_DMA32 set */
> > > > > 	ZONE_DMA,		/* 05 GFP_DMA and GFP_DMA32 set */
> > > > > 	ZONE_DMA32,		/* 06 GFP_DMA32 and GFP_HIGHMEM set */
> > > > > 	ZONE_DMA,		/* 07 GFP_DMA, GFP_DMA32 and GFP_DMA32 set */
> > > > > 	ZONE_MOVABLE,		/* 08 Only ZONE_MOVABLE set */
> > > > > 	ZONE_DMA,		/* 09 MOVABLE + DMA */
> > > > > 	ZONE_MOVABLE,		/* 0A MOVABLE + HIGHMEM */
> > > > > 	ZONE_DMA,		/* 0B MOVABLE + DMA + HIGHMEM */
> > > > > 	ZONE_DMA32,		/* 0C MOVABLE + DMA32 */
> > > > > 	ZONE_DMA,		/* 0D MOVABLE + DMA + DMA32 */
> > > > > 	ZONE_DMA32,		/* 0E MOVABLE + DMA32 + HIGHMEM */
> > > > > 	ZONE_DMA		/* 0F MOVABLE + DMA32 + HIGHMEM + DMA
> > > > > };
> > > > >
> > > > > Hmmmm... Guess one would need to add some #ifdeffery here to setup
> > > > > ZONE_NORMAL in cases there is no DMA, DMA32 and HIGHMEM.
> > > > >
> > > >
> > > > Indeed, as I said, this is somewhat error prone which is why the patch
> > > > calculates the table at run-time instead of compile-time trickery.
> > >
> > > One would need to define some macros to make it simpler I guess
> > >
> > > Write something like
> > >
> > > #ifdef CONFIG_ZONE_DMA
> > > #define TZONE_DMA ZONE_DMA
> > > #else
> > > #define TZONE_DMA ZONE_NORMAL
> > > #endif
> > >
> > > for each configurable item. Then just add the T to the above table.
> > >
> >
> > If you don't mind, I'd like to postpone writing such a patch until a second
> > or third pass at improving the allocator. I don't think I'll have the time
> > in the short-term to put together a const-initialised-table patch that will
> > definitily be correct.
> >
> > Alternatively, I can drop this patch entirely from the set.
> >
> >
> 
> Let me give it a shot:
> 
> Note that there is a slight buggyness in the current implementation of
> gfp_zone. If you set both GFP_DMA32 and GFP_HIGHMEM and the arch does not
> support GFP_DMA32 then gfp_zone returns GFP_HIGHMEM which may result in
> memory being allocated that cannot be used for I/O.
> 
> This version here returns GFP_NORMAL which is more correct.
> 
> 
> #ifdef CONFIG_ZONE_HIGHMEM
> #define OPT_ZONE_HIGHMEM ZONE_HIGHMEM
> #else
> #define OPT_ZONE_HIGHMEM ZONE_NORMAL
> #endif
> 
> #ifdef CONFIG_ZONE_DMA
> #define OPT_ZONE_DMA ZONE_DMA
> #else
> #define OPT_ZONE_DMA ZONE_NORMAL
> #endif
> 
> #ifdef CONFIG_ZONE_DMA32
> #define OPT_ZONE_DMA32 ZONE_DMA32
> #else
> #define OPT_ZONE_DMA32 OPT_ZONE_DMA
> #endif
> 
> 
> const int gfp_zone_table[GFP_ZONEMASK] = {
> 	ZONE_NORMAL,            /* 00 No flags set */
> 	OPT_ZONE_DMA,           /* 01 GFP_DMA */
> 	OPT_ZONE_HIGHMEM,       /* 02 GFP_HIGHMEM */
>         OPT_ZONE_DMA,           /* 03 GFP_HIGHMEM GFP_DMA */
>         OPT_ZONE_DMA32,         /* 04 GFP_DMA32 */
>         OPT_ZONE_DMA,           /* 05 GFP_DMA32 GFP_DMA */
>         OPT_ZONE_DMA32,         /* 06 GFP_DMA32 GFP_HIGHMEM */
>         OPT_ZONE_DMA,           /* 07 GFP_DMA32 GFP_HIGHMEM GFP_DMA */
>         ZONE_NORMAL,            /* 08 ZONE_MOVABLE */
>         OPT_ZONE_DMA,           /* 09 MOVABLE + DMA */
>         ZONE_MOVABLE,           /* 0A MOVABLE + HIGHMEM */
>         OPT_ZONE_DMA,           /* 0B MOVABLE + HIGHMEM + DMA */
>         OPT_ZONE_DMA32,         /* 0C MOVABLE + DMA32 */
>         OPT_ZONE_DMA,           /* 0D MOVABLE + DMA32 + DMA */
>         OPT_ZONE_DMA32,         /* 0E MOVABLE + DMA32 + HIGHMEM */
>         OPT_ZONE_DMA            /* 0F MOVABLE + DMA32 + HIGHMEM + DMA */
> };
> 

Thanks.At a quick glance, it looks ok but I haven't tested it. As the intention
was to get one pass of patches that are not controversial and are "obvious",
I have dropped my version of the gfp_zone patch and the subsequent flag
cleanup and will revisit it after the first lot of patches has been dealt
with. I'm testing again with the remaining patches.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
