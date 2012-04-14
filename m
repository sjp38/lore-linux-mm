Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 622A96B0044
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 06:14:23 -0400 (EDT)
Date: Sat, 14 Apr 2012 11:13:58 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Missing initialization of pages removed with memblock_remove
Message-ID: <20120414101358.GR24211@n2100.arm.linux.org.uk>
References: <4F7CF0EF.2090302@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F7CF0EF.2090302@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-arm-msm@vger.kernel.org, linux-mm@kvack.org, ohaugan@codeaurora.org, vgandhi@codeaurora.org

On Wed, Apr 04, 2012 at 06:10:07PM -0700, Laura Abbott wrote:
> We seem to have hit an odd edge case related to the use of  
> memblock_remove. We carve out memory for certain use cases using  
> memblock_remove, which gives a layout such as:
>
> <4>[    0.000000] Zone PFN ranges:
> <4>[    0.000000]   Normal   0x00080200 -> 0x000a1200
> <4>[    0.000000]   HighMem  0x000a1200 -> 0x000c0000
> <4>[    0.000000] Movable zone start PFN for each node
> <4>[    0.000000] early_node_map[3] active PFN ranges
> <4>[    0.000000]     0: 0x00080200 -> 0x00088f00
> <4>[    0.000000]     0: 0x00090000 -> 0x000ac680
> <4>[    0.000000]     0: 0x000b7a02 -> 0x000c0000
>
> Since pfn_valid uses memblock_is_memory, pfn_valid will return false on  
> all memory removed with memblock_remove.

Correct.  memblock_remove() removes the range from the 'memory' array.
memblock_is_memory() searches the 'memory' array to discover whether
the address is within a region described by that array.  So, having called
memblock_remove() on a region, memblock_is_memory() will then return false
for that region.

This provably works, because all those platforms using arm_memblock_steal()
and then subsequently using ioremap() on the same physical address range
relies upon this behaviour - and this is the desired behaviour.

> As a result, none of the page structures for the memblock_remove regions
> will have been initialized since memmap_init_zone calls pfn_valid before
> trying to initialize the memmap. Normally this isn't an issue but a recent
> test case ends up hitting a BUG_ON in move_freepages_block identical to
> the case in  
> http://lists.infradead.org/pipermail/linux-arm-kernel/2011-August/059934.html
> (BUG_ON(page_zone(start_page) != page_zone(end_page)))

Yes, welcome to the sad fact that sparsemem can't handle... sparse memory.
sparsemem apparantly was designed to handle fully populated memory sections,
but we've had some forward progress to get it sorted.  So if your memory
size is a multiple of 1MB, and you have memory in the upper half of the 4GB
space, you'll need an insane number of sections to cover this if you follow
this - you will need 4GB / 1MB = 4096 sections.

> What's happening is the calculation of start_page in  
> move_freepages_block returns a page within a range removed by  
> memblock_remove which means the page structure is uninitialized. (e.g.  
> 0xb7a02 -> 0xb7800)
>
> I've read through that thread and several others which have discouraged  
> use of CONFIG_HOLES_IN_ZONE due to the runtime overhead. The best  
> alternative solution I've come up with is to align the memory removed  
> via memblock_remove to MAX_ORDER_NR_PAGES but this will have a very high  
> memory overhead for certain use cases.
>
> A more fundamental question I have is should the page structures be  
> initialized for the regions removed with memblock_remove? Internally,  
> we've been divided on this issue and reading the source code hasn't  
> given any indication of if this is expected behavior or not.

One of the problems with that is you may have a GB or so between memblock
memory regions, and you certainly do not want to try and populate all
those page structs.

> Any suggestions on what's the cleanest solution?

I think CONFIG_HOLES_IN_ZONE=y is the best solution short of writing a
memory support subsystem which _can_ cope with all the various broken
ideas of system memory layout on ARM.

This would be a lot less of a problem had ARM Ltd mandated as part of
the architecture that memory was to be contiguous (and preferably
starting at physical address zero in normal system operation) but alas
every silicon vendor is free to create whatever abortion they like
here - we've even had cases where people want the order of physical
memory reversed because the first populated memory region is at a
higher address, which we've had to say a definite no to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
