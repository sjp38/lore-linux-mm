Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 139446B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 17:45:21 -0400 (EDT)
Date: Tue, 28 Sep 2010 14:45:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: cleanup gfp_zone()
Message-Id: <20100928144518.0eaf1099.akpm@linux-foundation.org>
In-Reply-To: <20100928214141.GG19804@ZenIV.linux.org.uk>
References: <1285676624-1300-1-git-send-email-namhyung@gmail.com>
	<20100928143239.5fe34e1e.akpm@linux-foundation.org>
	<20100928214141.GG19804@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Namhyung Kim <namhyung@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010 22:41:42 +0100
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Tue, Sep 28, 2010 at 02:32:39PM -0700, Andrew Morton wrote:
> > > +#define ZT_SHIFT(gfp) ((__force int) (gfp) * ZONES_SHIFT)
> > >  #define GFP_ZONE_TABLE ( \
> > > -	(ZONE_NORMAL << 0 * ZONES_SHIFT)				\
> > > -	| (OPT_ZONE_DMA << __GFP_DMA * ZONES_SHIFT)			\
> > > -	| (OPT_ZONE_HIGHMEM << __GFP_HIGHMEM * ZONES_SHIFT)		\
> > > -	| (OPT_ZONE_DMA32 << __GFP_DMA32 * ZONES_SHIFT)			\
> > > -	| (ZONE_NORMAL << __GFP_MOVABLE * ZONES_SHIFT)			\
> > > -	| (OPT_ZONE_DMA << (__GFP_MOVABLE | __GFP_DMA) * ZONES_SHIFT)	\
> > > -	| (ZONE_MOVABLE << (__GFP_MOVABLE | __GFP_HIGHMEM) * ZONES_SHIFT)\
> > > -	| (OPT_ZONE_DMA32 << (__GFP_MOVABLE | __GFP_DMA32) * ZONES_SHIFT)\
> > > +	(ZONE_NORMAL        << ZT_SHIFT(0))				\
> > > +	| (OPT_ZONE_DMA     << ZT_SHIFT(__GFP_DMA))			\
> > > +	| (OPT_ZONE_HIGHMEM << ZT_SHIFT(__GFP_HIGHMEM))			\
> > > +	| (OPT_ZONE_DMA32   << ZT_SHIFT(__GFP_DMA32))			\
> > > +	| (ZONE_NORMAL      << ZT_SHIFT(__GFP_MOVABLE))			\
> > > +	| (OPT_ZONE_DMA     << ZT_SHIFT(__GFP_MOVABLE | __GFP_DMA))	\
> > > +	| (ZONE_MOVABLE     << ZT_SHIFT(__GFP_MOVABLE | __GFP_HIGHMEM)) \
> > > +	| (OPT_ZONE_DMA32   << ZT_SHIFT(__GFP_MOVABLE | __GFP_DMA32))	\
> > >  )
> > 
> > hm.  I hope these sparse warnings are sufficiently useful to justify
> > all the gunk we're adding to support them.
> > 
> > Is it actually finding any bugs?
> 
> FWIW, bitwise or done in the right-hand argumet of shift looks ugly as hell;
> what the hell is that code _doing_?

There's a nice fat comment a few lines up...

/*
 * GFP_ZONE_TABLE is a word size bitstring that is used for looking up the
 * zone to use given the lowest 4 bits of gfp_t. Entries are ZONE_SHIFT long
 * and there are 16 of them to cover all possible combinations of
 * __GFP_DMA, __GFP_DMA32, __GFP_MOVABLE and __GFP_HIGHMEM.
 *
 * The zone fallback order is MOVABLE=>HIGHMEM=>NORMAL=>DMA32=>DMA.
 * But GFP_MOVABLE is not only a zone specifier but also an allocation
 * policy. Therefore __GFP_MOVABLE plus another zone selector is valid.
 * Only 1 bit of the lowest 3 bits (DMA,DMA32,HIGHMEM) can be set to "1".
 *
 *       bit       result
 *       =================
 *       0x0    => NORMAL
 *       0x1    => DMA or NORMAL
 *       0x2    => HIGHMEM or NORMAL
 *       0x3    => BAD (DMA+HIGHMEM)
 *       0x4    => DMA32 or DMA or NORMAL
 *       0x5    => BAD (DMA+DMA32)
 *       0x6    => BAD (HIGHMEM+DMA32)
 *       0x7    => BAD (HIGHMEM+DMA32+DMA)
 *       0x8    => NORMAL (MOVABLE+0)
 *       0x9    => DMA or NORMAL (MOVABLE+DMA)
 *       0xa    => MOVABLE (Movable is valid only if HIGHMEM is set too)
 *       0xb    => BAD (MOVABLE+HIGHMEM+DMA)
 *       0xc    => DMA32 (MOVABLE+HIGHMEM+DMA32)
 *       0xd    => BAD (MOVABLE+DMA32+DMA)
 *       0xe    => BAD (MOVABLE+DMA32+HIGHMEM)
 *       0xf    => BAD (MOVABLE+DMA32+HIGHMEM+DMA)
 *
 * ZONES_SHIFT must be <= 2 on 32 bit platforms.
 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
