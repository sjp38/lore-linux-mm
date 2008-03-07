From: Andi Kleen <andi@firstfloor.org>
Message-Id: <200803071007.493903088@firstfloor.org>
Subject: [PATCH] [0/13] General DMA zone rework
Date: Fri,  7 Mar 2008 10:07:10 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Background:

The 16MB Linux ZONE_DMA has some long standing problems on
x86. Traditionally it was designed only for ISA dma which is limited to
24bit (16MB). This means it has a fixed 16MB size.

On 32bit i386 with its limited virtual memory space the next zone is
lowmem with ~900MB (on default split) which works for a lot of devices,
but not all.  But on x86-64 the next zone is only 4GB (DMA32) which is too
big for quite a lot more devices (typically 30,31 or 28bit limitations).

While the DMA zone is in a true VM zone and could be in theory used for
any user allocations in practice the VM has a concept called lower zone
protection to avoid low memory deadlocks that keeps ZONE_DMA nearly
always free unless the caller specifies GFP_DMA directly. This means
in practice it does not participate in the rest of the automatic VM
balancing and its memory is essentially reserved.

Then there is another pool used on x86-64: the swiotlb pool. It is 64MB
by default and used to bounce buffer in the pci DMA API in the low level
drivers for any devices that have 32bit limitations (very common)

Swiotlb and the DMA zone already interact. For consistent mappings swiotlb
will already allocate from both the DMA zone and from the swiotlb pool as
needed. On the other hand swiotlb is a truly separate pool not directly
visible to the normal zone balancing (although it happens to be in the
DMA32 zone). In practice ZONE_DMA behaves very similar in that respect.

Driver interfaces:

When drivers need DMA able memory they typically use the pci_*/dma_*
interfaces which allow specifying device masks.   There are two interfaces
here:

dma_alloc_coherent/pci_alloc_consistent to get a block of coherent
memory honouring a device DMA mask and mapped into an IOMMU as needed.
And pci_map_*/dma_map_* to remap an arbitary block to the DMA mask of
the device and into the IOMMU.

Both ways have their own disadvantages: coherent mappings can have some
bad performance penalties and high setup costs on some platforms which
are not full IO coherent, so they are not encouraged for high volume
driver data.  And pci/dma_map_* will always bounce buffer on the common
x86 swiotlb case so it might be quite expensive. Also on a lot of IOMMU
implementations (in particularly x86 swiotlb/pci-gart) pci/dma_map_*
does not support remapping to any DMA masks smaller than 32bit so it
cannot actually be used for ISA or any other device with <32bit DMA mask.

Then there is the old style way of directly telling the allocators
what memory you need by using GFP_DMA or GFP_DMA32 and then later using
bounce less pci/dma_map_*. That also has its own set of problems: first
GFP_DMA varies between architectures. On x86 it is always 16MB, on IA64
4GB, on some other architectures it doesn't exist at all or has other
sizes. GFP_DMA32 often doesn't exist at all (although it can be often
replaced with GFP_KERNEL on 32bit platforms).  This means any caller
needs to have knowledge about its platform which is often non portable.

Then the other problem is that it these are only single bits into small
fixed zones. So for example if a user has a 30bit DMA zone limit on 64bit
they have no other choice than to use GFP_DMA and when they need more than
16MB of memory they lose.  On the other hand on a lot of other boxes which
don't have any devices with <4GB dma masks ZONE_DMA is just wasted memory.

Then GFP_DMA is also not a very clean interface. It is usually
not documented what device mask is really needed. Also some driver
authors misunderstand it as meaning "required for any DMA" which is
not correct. And often it actually requires dma masks larger than 24bit
(16MB) so the fixed 24bit on x86 is limiting.

The pci_alloc_consistent implementation on x86 also has more problems:
usually it cannot use an IOMMU to remap the dma memory so they actually
have to allocate memory with physical addresses according to the dma mask
of the passed device. All they can do for this is to map it to GFP_DMA
(16MB small), GFP_DMA32 (big, but sometimes too big) or by getting
it from the swiotlb pool. It also attempts to get fitting memory from
the main allocator. That works mostly, but has bad corner cases and is
quite inelegant.

In practice this leads to various unfortunate situations: either the 64bit
system has upto 100MB of reserved memory wasted (ZONE_DMA + swiotlb),
but does not have any devices that require bouncing to 16MB or 4GB.

Or the system has devices that need bouncing to <4GB, but the pools in
their default size are too small and can overflow. There are various
hac^wworkarounds in drivers for this problem, but it still causes
problems for users.  The ZONE_DMA can also not be enlarged because a 
lot of drivers "know" that it is only 16MB and expect 16MB memory from it.

On 32bit x86 the problem is a little less severe because of the 900MB
ZONE_NORMAL which fits most devices, but there are still some problems
with more obscure devices with sufficiently small DMA masks. And ISA
devices still fit in badly.

Requirements for a solution:

There is clearly a need for a new better low memory bounce pool on x86.
It must be larger than 16MB and actually be variable sized. Also the
driver interfaces are inadequate. All DMA memory allocation should
specify what mask they actually need. That allows to extend the pool
and use a single pool for multiple masks.

The new pool must be isolated from the rest of the VM. Otherwise it
cannot be safely used in any device driver paths who cannot necessarily
safely allocate memory (e.g. the block write out path is not allowed to
do this to avoid deadlocks while swapping) The current effective pools
(ZONE_DMA, swiotlb) are already isolated in practice so this won't make
much difference.

Proposed solution:

I chose to implement a new "maskable memory" allocator to solve these
problems. The existing page buddy allocator is not really suited for
this because the data structures don't allow cheap allocation by physical 
address boundary. 

The allocator has a separate pool of memory that it grabs at boot
using the bootmem allocator. The memory is part of the lowest zone,
but practically invisible to the normal page allocator or VM.

The allocator is very simple: it works with pages and uses a bitmap to 
find memory. It also uses a simple rotating cursor through the bitmap.
It is very similar to the allocators used by the various IOMMU 
implementations.  While this is not a true O(1) allocator, in practice
it tends to find free pages very quickly and it is quite flexible.
Also it makes it very simple to allocate below arbitary address boundaries.
It has one advantage over buddy in that it doesn't require all
blocks to be size of power of two. It only rounds to pages. So especially 
larger blocks tend to have less overhead.

The allocator knows how to fall back to the other zones if 
the mask is sufficiently big enough, so it can be used for 
arbitrary masks.

I chose to only implement a page mask allocator only, not "kmalloc_mask",
because the various drivers I looked at actually tended to allocate 
quite large objects towards a page. Also if a sub page allocator 
is really needed there are several existing ones that could be 
relatively easily adopted (mm/dmapool.c or the lib/bitmap.c allocator)
on top of an page allocator.

The maskable allocator's pool is variable sized and the user can set 
it to any size needed (upto 2GB currently). The default sizing 
heuristics are for now the same as in the old code: by default
all free memory below 16MB is put into the pool (in practice that
is only ~8MB or so usable because the kernel is loaded there too) 
and swiotlb is needed another 64MB of low memory are reserved too.
The user can override this using the command line.
Any other subsystems can also increase the memory reservation
(but this currently has to happen early while bootmem is still active)

In the future I hope to make this more flexible. In particular
the low memory could not be fully reserved, but only put into
the "moveable" zone and then later as devices are discovered
and e.g. block devices are set up this pre reservation could
be actually reserved. This would then actually allow to use
a lot of the ~100MB that currently go to waste on x86-64.  But
so far that is not implemented yet.

swiotlb doesn't maintain an own pool anymore, but just allocates
using the mask allocator.  THis is safe because the maskable
pool is isolated from the rest of the VM and not prone
to OOM deadlocks. This is admittedly more a heuristic, than 
a strict 100% guarantee, but it is not worse than the old swiotlb.
Also all users of the maskable allocators currently are benign
and won't overflow it in dynamic situations I believe. 

The internal implementations

ZONE_DMA is disabled for x86 with the maskable allocator enabled.

The maskable allocator requires some simple modifications in
the architecture start up code. These are currently only 
done for x86. All other architectures keep the same GFP_DMA
semantics as they had before. Adapting other architectures
wouldn't be very difficult.

The longer term goal is to convert all GFP_DMA allocations
to always specify the correct mask and then eventually remove
GFP_DMA.

Especially I hope kmalloc/kmem_cache_alloc GFP_DMA can be
removed soon. I have some patches to eliminate those users.
Then slab wouldn't need to maintain DMA caches anymore.

This patch kit only contains the core changes for the actual
allocator, swiotlb conversion and pci_alloc_consistent/dma_alloc_coherent()
Between swiotlb and the later changes this already means that
a lot of drivers use it.

The existing GFP_DMA users transparently fall back to
a maskable allocation with 16MB.

I have various other driver conversions in the pipeline, but 
I will post these sepately to not distract too much from
the review of the main code.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
