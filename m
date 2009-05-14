Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 499706B018C
	for <linux-mm@kvack.org>; Thu, 14 May 2009 04:39:16 -0400 (EDT)
Date: Thu, 14 May 2009 09:39:47 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Double check memmap is actually valid with a memmap
	has unexpected holes V2
Message-ID: <20090514083947.GB16639@csn.ul.ie>
References: <20090505082944.GA25904@csn.ul.ie> <20090505083614.GA28688@n2100.arm.linux.org.uk> <20090505084928.GC25904@csn.ul.ie> <20090513163448.GA18006@csn.ul.ie> <20090513124805.9c70c43c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090513124805.9c70c43c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux@arm.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hartleys@visionengravers.com, mcrapet@gmail.com, fred99@carolina.rr.com, linux-arm-kernel@lists.arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Wed, May 13, 2009 at 12:48:05PM -0700, Andrew Morton wrote:
> On Wed, 13 May 2009 17:34:48 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > pfn_valid() is meant to be able to tell if a given PFN has valid memmap
> > associated with it or not. In FLATMEM, it is expected that holes always
> > have valid memmap as long as there is valid PFNs either side of the hole.
> > In SPARSEMEM, it is assumed that a valid section has a memmap for the
> > entire section.
> > 
> > However, ARM and maybe other embedded architectures in the future free
> > memmap backing holes to save memory on the assumption the memmap is never
> > used. The page_zone linkages are then broken even though pfn_valid()
> > returns true. A walker of the full memmap must then do this additional
> > check to ensure the memmap they are looking at is sane by making sure the
> > zone and PFN linkages are still valid. This is expensive, but walkers of
> > the full memmap are extremely rare.
> > 
> > This was caught before for FLATMEM and hacked around but it hits again for
> > SPARSEMEM because the page_zone linkages can look ok where the PFN linkages
> > are totally screwed. This looks like a hatchet job but the reality is that
> > any clean solution would end up consumning all the memory saved by punching
> > these unexpected holes in the memmap. For example, we tried marking the
> > memmap within the section invalid but the section size exceeds the size of
> > the hole in most cases so pfn_valid() starts returning false where valid
> > memmap exists. Shrinking the size of the section would increase memory
> > consumption offsetting the gains.
> > 
> > This patch identifies when an architecture is punching unexpected holes
> > in the memmap that the memory model cannot automatically detect and sets
> > ARCH_HAS_HOLES_MEMORYMODEL. At the moment, this is restricted to EP93xx
> > which is the model sub-architecture this has been reported on but may expand
> > later. When set, walkers of the full memmap must call memmap_valid_within()
> > for each PFN and passing in what it expects the page and zone to be for
> > that PFN. If it finds the linkages to be broken, it assumes the memmap is
> > invalid for that PFN.
> 
> It's unclear to me whether this patch is needed in 2.6.30 or even
> 2.6.29 or whatever.
> 

It affected at least 2.6.28.4 so minimally, I'd like to see it in for 2.6.30. I
think it's a -stable candidate but I'd like to hear from the ARM maintainer
on whether he wants to push it or not to that tree.

> It applies OK to 2.6.28, 2.6.29, current mainline and mmotm, so I'll
> just sit tight until I'm told what to do.
> 

Please merge for 2.6.30 at least. Russell, are you ok with that? Are you ok
with this being pushed to -stable?

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
