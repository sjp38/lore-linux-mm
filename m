Date: Fri, 26 Jan 2007 14:29:44 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/8] Create ZONE_MOVABLE to partition memory between
 movable and non-movable pages
In-Reply-To: <20070126030753.03529e7a.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0701261334240.19245@skynet.skynet.ie>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
 <20070126030753.03529e7a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007, Andrew Morton wrote:

> On Thu, 25 Jan 2007 23:44:58 +0000 (GMT)
> Mel Gorman <mel@csn.ul.ie> wrote:
>
>> The following 8 patches against 2.6.20-rc4-mm1 create a zone called
>> ZONE_MOVABLE
>
> Argh.  These surely get all tangled up with the
> make-zones-optional-by-adding-zillions-of-ifdef patches:
>

There may be some entertainment there all right. I didn't see any obvious 
way of avoiding collisions with those patches but for what it's worth, 
ZONE_MOVABLE could also be made optional.

In this patchset, I made no assumptions about the number of zones other 
than the value of MAX_NR_ZONES. There should be no critical collisions but 
I'll look through this patch list and see what I can spot.

> deal-with-cases-of-zone_dma-meaning-the-first-zone.patch

This patch looks ok and looks like it stands on it's own.

> introduce-config_zone_dma.patch

ok, no collisions here but obviously this patch does not stand on it's 
own.

> optional-zone_dma-in-the-vm.patch

There are collisions here with the __ZONE_COUNT stuff but it's not 
difficult to work around.

> optional-zone_dma-in-the-vm-no-gfp_dma-check-in-the-slab-if-no-config_zone_dma-is-set.patch
> optional-zone_dma-in-the-vm-no-gfp_dma-check-in-the-slab-if-no-config_zone_dma-is-set-reduce-config_zone_dma-ifdefs.patch

There is no cross-over here with the ZONE_MOVABLE patches. They are 
messing around with slab

> optional-zone_dma-for-ia64.patch

No collision here

> remove-zone_dma-remains-from-parisc.patch
> remove-zone_dma-remains-from-sh-sh64.patch

No collisions here either. I see that there were discussions about Power 
potentially doing something similar.

> set-config_zone_dma-for-arches-with-generic_isa_dma.patch

No collisions

> zoneid-fix-up-calculations-for-zoneid_pgshift.patch
>

Fun, but no collisions.

To my suprise, I only spotted one major conflict point with 
optional-zone_dma-in-the-vm.patch and that should be easy enough to 
resolve. What I could do is break up one of my patches into 
most-of-the-patch and the-part-that-may-conflict-with-optional-dma-zone . 
The smaller part would then change depending on whether the optional DMA 
zone work is present. Would that be any help?

> My objections to those patches:
>
> - They add zillions of ifdefs
>
> - They make the VM's behaviour diverge between different platforms and
>  between differen configs on the same platforms, and hence degrade
>  maintainability and increase complexity.
>

I haven't thought about it much so I probably am missing something. The 
major difference I see is when only one zone is present. In that case, a 
number of loops presumably get optimised away and the behavior is very 
different (presumably better although you point out no figures exist to 
prove it). Where there are two or more zones, the code paths should be 
similar whether there are 2, 3 or 4 zones present.

As the common platforms will always have more than one zone, it'll be 
heavily tested and I'm guessing that distros are always going to have to 
ship kernels with ZONE_DMA for the devices that require it. The only 
platform I see that may have problems at the moment is IA64 which looks 
like the only platform that can have one and only one zone. I am guessing 
that Christoph will catch problems here fairly quickly although a 
non-optional ZONE_MOVABLE would throw a spanner into the works somewhat.

> - We kicked around some quite different ways of implementing the same
>  things, but nothing came of it.  iirc, one was to remove the hard-coded
>  zones altogether and rework all the MM to operate in terms of
>
> 	for (idx = 0; idx < NUMBER_OF_ZONES; idx++)
> 		...
>

hmm. Assuming the aim is to have a situation where all zone-related loops 
are optimised away at compile-time, it's hard to see an alternative that 
works. Any dynamic way of creating zone at boot time will not have the 
compile-time optimizations and any API that is page-range aware will 
eventually hit the problems zones were made to solve (i.e. unmovable pages 
locked in the lower address ranges).

> - I haven't seen any hard numbers to justify the change.
>
> So I want to drop them all.
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
