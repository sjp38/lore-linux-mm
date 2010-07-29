Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F216C6B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:15:08 -0400 (EDT)
Date: Thu, 29 Jul 2010 23:14:26 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
Message-ID: <20100729221426.GA28699@n2100.arm.linux.org.uk>
References: <20100728155617.GA5401@barrios-desktop> <alpine.DEB.2.00.1007281158150.21717@router.home> <20100728225756.GA6108@barrios-desktop> <alpine.DEB.2.00.1007291038100.16510@router.home> <20100729161856.GA16420@barrios-desktop> <alpine.DEB.2.00.1007291132210.17734@router.home> <20100729170313.GB16420@barrios-desktop> <alpine.DEB.2.00.1007291222410.17734@router.home> <20100729183320.GH18923@n2100.arm.linux.org.uk> <1280436919.16922.11246.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1280436919.16922.11246.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 29, 2010 at 01:55:19PM -0700, Dave Hansen wrote:
> Could you give some full examples of how the memory is laid out on these
> systems?  I'm having a bit of a hard time visualizing it.

In the example I quote, there are four banks of memory, which start at
0x10000000, 0x14000000, 0x18000000 and 0x1c000000 physical, which can
be populated or empty, each one in multiples of 512KB up to the maximum
64MB.

There are other systems where memory starts at 0xc0000000 and 0xc8000000
physical, and the memory size is either 32MB or 64MB.

We also have one class of systems where memory starts at 0xc0000000,
0xc1000000, 0xc2000000, etc - but I don't know what the minimum
populated memory size in any one region is.

Things that we've tried over the years:
1. flatmem, remapping memory into one contiguous chunk (which can cause
   problems when parts of the kernel assume that the underlying phys
   space is contiguous.)
2. flatmem with holes and a 1:1 v:p mapping (was told we shouldn't be
   doing this - and it becomes impossible with sparsely populated banks
   of memory split over a large range.)
3. discontigmem (was told this was too heavy, we're not NUMA, we shouldn't
   be using this, and it will be deprecated, use sparsemem instead)
4. sparsemem

What we need is something which allows us to handle memory scattered
in several regions of the physical memory map, each bank being a
variable size.

>From what I've seen through this thread, there is no support for such
a setup.  (People seem to have their opinions on this, and will tell
you what you should be using, only for someone else to tell you that
you shouldn't be using that! - *)  This isn't something new for ARM,
we've had these kinds of issues for the last 10 or more years.

What is new is that we're now seeing systems where the first bank of
memory to be populated is at a higher physical address than the second
bank, and therefore people are setting up v:p mappings which switch the
ordering of these - but this I think is unrelated to the discussion at
hand.

* - this is why I'm exasperated with this latest discussion on it.

While we're here, I'll repeat a point made earlier.

We don't map lowmem in using 4K pages.  That would be utter madness
given the small TLB size ARM processors tend to have.  Instead, we
map lowmem using 1MB section mappings (which occupy one entry in the
L1 page table.)  Modifying these mappings requires all page tables
in the system to be updated - which given that we're SMP etc. now
is not practical.

So the idea that we can remap a section of memory for the mem_map
struct (as suggested several times in this thread) isn't possible
without having it allocated in something like vmalloc space.
Plus, of course, that if you did such a remapping in the lowmem
mapping, the pages which were there become unusable as they lose
their virtual mapping (thereby causing phys_to_virt/virt_to_phys
on their addresses to break.)  Therefore, you only gain even more
problems by this method.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
