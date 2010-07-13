Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BD5576B02A5
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 06:00:53 -0400 (EDT)
Date: Tue, 13 Jul 2010 11:00:34 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
Message-ID: <20100713100034.GF29885@csn.ul.ie>
References: <20100712155348.GA2815@barrios-desktop> <20100713093700.GD29885@csn.ul.ie> <20100713094612.GF20590@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100713094612.GF20590@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Minchan Kim <minchan.kim@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 10:46:12AM +0100, Russell King - ARM Linux wrote:
> On Tue, Jul 13, 2010 at 10:37:00AM +0100, Mel Gorman wrote:
> > I prefer Kamezawa's suggestion of mapping on a ZERO_PAGE-like page full
> > of PageReserved struct pages because it would have better performance
> > and be more in line with maintaining the assumptions of the memory
> > model. If we go in this direction, I would strongly prefer it was an
> > ARM-only thing.
> 
> As I've said, this is not possible without doing some serious page
> manipulation.
> 

Yep, x86 used to do something like this for discontig. It wasn't pretty.

> Plus the pages that where there become unusable as they don't correspond
> with a PFN or obey phys_to_virt().  So there's absolutely no point to
> this.
> 
> Now, why do we free the holes in the mem_map - because these holes can
> be extremely large.  Every 512K of hole equates to one page of mem_map
> array.

Sure, the holes might be large but at least they are contiguous. Is
there ever a case where you have

512K_Valid 512K_Hole 512K_Valid 512K_Hole

or is it typically

512K_hole 512K_hole ...... 512K_Valid 512K_Valid etc

If holes are typically contiguos, memmap is not allocated in the first place
and the savings from punching holes in memmap in the latter configuration
are minimal.

I recognise if you have a 2M section with a hole in it, you are
potentially wasting 3 pages on unused memmap. If this is really a problem,
Minchan's modification to sparsemem to increase the size of mem_section on
CONFIG_ARCH_HAS_HOLES_MEMORYMODEL is a messy option. I say messy because
it only works if the hole is on either end of the section and it's adding
quirks to the memory model.

>  Balance that against memory placed at 0xc0000000 physical on
> some platforms, and with PHYSMEM_BITS at 32 and SECTION_SIZE_BITS at
> 19 - well, you do the maths.  The result is certainly not pretty.
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
