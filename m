Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CE5026B0203
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 16:35:17 -0400 (EDT)
Date: Wed, 25 Aug 2010 16:32:37 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH/RFCv4 2/6] mm: cma: Contiguous Memory Allocator added
Message-ID: <20100825203237.GA5318@phenom.dumpdata.com>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
 <0b02e05fc21e70a3af39e65e628d117cd89d70a1.1282286941.git.m.nazarewicz@samsung.com>
 <343f4b0edf9b5eef598831700cb459cd428d3f2e.1282286941.git.m.nazarewicz@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <343f4b0edf9b5eef598831700cb459cd428d3f2e.1282286941.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 11:50:42AM +0200, Michal Nazarewicz wrote:
> The Contiguous Memory Allocator framework is a set of APIs for
> allocating physically contiguous chunks of memory.
> 
> Various chips require contiguous blocks of memory to operate.  Those
> chips include devices such as cameras, hardware video decoders and
> encoders, etc.

I am not that familiar with how StrongARM works, and I took a bit look
at the arch/arm/mach-s* and then some of the
drivers/video/media/video/cx88 to get an idea how the hardware video
decoders would work this.

What I got from this patch review is that you are writting an IOMMU
that is on steroids. It essentially knows that this device and that
device can both share the same region, and it has fancy plugin system
to deal with fragmentation and offers an simple API for other to
write their own "allocators".

Even better, during init, the sub-platform can use 
cma_early_regions_reserve(<func>) to register their own function
for reserving large regions of memory. Which from my experience (with
Xen) means that there is a mechanism in place to have it setup 
contingous regions using sub-platform code.

This is how I think it works, but I am not sure if I got it right. From
looking at 'cma_alloc' and 'cma_alloc_from_region' - both return
an dma_addr_t, which is what is usually feed in the DMA API. And looking
at the cx88 driver I see it using that API..

I do understand that under ARM platform you might not have a need for
DMA at all, and you use the 'dma_addr_t' just as handles, but for
other platforms this would be used.

So here is the bit where I am confused. Why not have this
as Software IOMMU that would utilize the IOMMU API? There would be some
technical questions to be answered (such as, what to do when you have 
another IOMMU and can you stack them on top of each other).

A light review below:
..
> +*** Allocator operations
> +
> +    Creating an allocator for CMA needs four functions to be
> +    implemented.
> +
> +
> +    The first two are used to initialise an allocator far given driver
                                                         ^^- for

> +    and clean up afterwards:
> +
> +        int  cma_foo_init(struct cma_region *reg);
> +        void cma_foo_cleanup(struct cma_region *reg);
> +
> +    The first is called when allocater is attached to region.  The
> +    cma_region structure has saved starting address of the region as

Who saved the starting address? Is that the job of the cma_foo_init?

> +    well as its size.  Any data that allocate associated with the
> +    region can be saved in private_data field.

..
> +    The name ("foo") will be available to use with command line
> +    argument.

No command line arguments.
> +
> +*** Integration with platform
> +
> +    There is one function that needs to be called form platform
> +    initialisation code.  That is the cma_early_regions_reserve()
> +    function:
> +
> +        void cma_early_regions_reserve(int (*reserve)(struct cma_region *reg));
> +
> +    It traverses list of all of the regions given on command line and

Ditto.

> +    reserves memory for them.  The only argument is a callback
> +    function used to reserve the region.  Passing NULL as the argument
> +    makes the function use cma_early_region_reserve() function which
> +    uses bootmem and memblock for allocating.
> +
> +    Alternatively, platform code could traverse the cma_early_regions
> +    list by itself but this should not be necessary.
> +
..
> +/**
> + * cma_alloc - allocates contiguous chunk of memory.
> + * @dev:	The device to perform allocation for.
> + * @type:	A type of memory to allocate.  Platform may define
> + *		several different types of memory and device drivers
> + *		can then request chunks of different types.  Usually it's
> + *		safe to pass NULL here which is the same as passing
> + *		"common".
> + * @size:	Size of the memory to allocate in bytes.
> + * @alignment:	Desired alignment in bytes.  Must be a power of two or
> + *		zero.  If alignment is less then a page size it will be
> + *		set to page size. If unsure, pass zero here.
> + *
> + * On error returns a negative error cast to dma_addr_t.  Use
> + * IS_ERR_VALUE() to check if returned value is indeed an error.
> + * Otherwise physical address of the chunk is returned.

Should be 'bus address'. On some platforms the physical != PCI address.
..

> +/****************************** Lower lever API *****************************/
> +
> +/**
> + * cma_alloc_from - allocates contiguous chunk of memory from named regions.
> + * @regions:	Comma separated list of region names.  Terminated by NUL

I think you mean 'NULL'

> + *		byte or a semicolon.

Uh, really? Why? Why not just simplify your life and make it \0?
..
> +/****************************** Allocators API ******************************/
> +
> +/**
> + * struct cma_chunk - an allocated contiguous chunk of memory.
> + * @start:	Physical address in bytes.
> + * @size:	Size in bytes.
> + * @free_space:	Free space in region in bytes.  Read only.
> + * @reg:	Region this chunk belongs to.
> + * @by_start:	A node in an red-black tree with all chunks sorted by
> + *		start address.
> + *
> + * The cma_allocator::alloc() operation need to set only the @start
                       ^^- C++, eh?
.. snip..
> + * struct cma_allocator - a CMA allocator.
> + * @name:	Allocator's unique name
> + * @init:	Initialises an allocator on given region.
> + * @cleanup:	Cleans up after init.  May assume that there are no chunks
> + *		allocated in given region.
> + * @alloc:	Allocates a chunk of memory of given size in bytes and
> + *		with given alignment.  Alignment is a power of
> + *		two (thus non-zero) and callback does not need to check it.
> + *		May also assume that it is the only call that uses given
> + *		region (ie. access to the region is synchronised with
> + *		a mutex).  This has to allocate the chunk object (it may be
> + *		contained in a bigger structure with allocator-specific data.
> + *		Required.
> + * @free:	Frees allocated chunk.  May also assume that it is the only
> + *		call that uses given region.  This has to free() the chunk
> + *		object as well.  Required.
> + * @list:	Entry in list of allocators.  Private.
> + */
> + /* * @users:	How many regions use this allocator.  Private. */

That looks to be gone..
> +struct cma_allocator {
> +	const char *name;
> +
> +	int (*init)(struct cma_region *reg);
> +	void (*cleanup)(struct cma_region *reg);
> +	struct cma_chunk *(*alloc)(struct cma_region *reg, size_t size,
> +				   dma_addr_t alignment);
> +	void (*free)(struct cma_chunk *chunk);
> +
> +	/* unsigned users; */

and sure enough it is gone. No need for that comment then.

> +	struct list_head list;
> +};
> +
> +
> +/**
> + * cma_allocator_register() - Registers an allocator.
> + * @alloc:	Allocator to register.
> + *
> + * Adds allocator to the list of allocators managed by CMA.
> + *
> + * All of the fields of cma_allocator structure must be set except for
> + * optional name and users and list which will be overriden.
                    ^^^^^^^^^ - It is gone, isn't?
..
> +/**
> + * cma_early_region_register() - registers an early region.
> + * @reg:	Region to add.
> + *
> + * Region's start, size and alignment must be set.
> + *
> + * If name is set the region will be accessible using normal mechanism
> + * like mapping or cma_alloc_from() function otherwise it will be
> + * a private region accessible only using the cma_alloc_from_region().
> + *


> + * If alloc is set function will try to initialise given allocator
> + * when the early region is "converted" to normal region and
> + * registered during CMA initialisation.  If this failes, the space

I am having a hard time understanding that statement. Can you simplify
it a bit?


..
> +int __init cma_early_region_reserve(struct cma_region *reg)


> +{
> +	int tried = 0;
> +
> +	if (!reg->size || (reg->alignment & (reg->alignment - 1)) ||
> +	    reg->reserved)
> +		return -EINVAL;
> +
> +#ifndef CONFIG_NO_BOOTMEM
> +
> +	tried = 1;
> +
> +	{
> +		void *ptr = __alloc_bootmem_nopanic(reg->size, reg->alignment,
> +						    reg->start);
> +		if (ptr) {
> +			reg->start = virt_to_phys(ptr);
> +			reg->reserved = 1;
> +			return 0;
> +		}
> +	}
> +
> +#endif
> +
> +#ifdef CONFIG_HAVE_MEMBLOCK
> +
> +	tried = 1;
> +
> +	if (reg->start) {
> +		if (memblock_is_region_reserved(reg->start, reg->size) < 0 &&
> +		    memblock_reserve(reg->start, reg->size) >= 0) {
> +			reg->reserved = 1;
> +			return 0;
> +		}
> +	} else {
> +		/*
> +		 * Use __memblock_alloc_base() since
> +		 * memblock_alloc_base() panic()s.
> +		 */
> +		u64 ret = __memblock_alloc_base(reg->size, reg->alignment, 0);
> +		if (ret &&
> +		    ret < ~(dma_addr_t)0 &&
> +		    ret + reg->size < ~(dma_addr_t)0 &&
> +		    ret + reg->size > ret) {
> +			reg->start = ret;
> +			reg->reserved = 1;
> +			return 0;
> +		}
> +
> +		if (ret)
> +			memblock_free(ret, reg->size);
> +	}
> +
> +#endif
Those two #ifdefs are pretty ugly. What if you defined in a header
something along this:

#ifdef CONFIG_HAVE_MEMBLOCK
int __init default_early_region_reserve(struct cma_region *reg) {
   .. do it using memblock
}
#endif
#ifdef CONFIG_NO_BOOTMEM
int __init default_early_region_reserve(struct cma_region *reg) {
   .. do it using bootmem
}
#endif

...
> +
> +	return tried ? -ENOMEM : -EOPNOTSUPP;
> +}
> +
> +void __init cma_early_regions_reserve(int (*reserve)(struct cma_region *reg))
> +{
> +	struct cma_region *reg;
> +
> +	pr_debug("init: reserving early regions\n");
> +
> +	if (!reserve)
> +		reserve = cma_early_region_reserve;

and then in here you would have
		reserve = default_early_region_reserve;

and you would cut the API by one function, the
cma_early_regions_reserve(struct cma_region *reg)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
