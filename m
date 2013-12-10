Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 350B56B0134
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 19:25:20 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so6117968pde.6
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 16:25:19 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id w3si8748723pbh.89.2013.12.09.16.25.18
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 16:25:18 -0800 (PST)
Date: Mon, 9 Dec 2013 16:25:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 08/23] mm/memblock: Add memblock memory allocation
 apis
Message-Id: <20131209162517.b259540cdd23bfacadc9d171@linux-foundation.org>
In-Reply-To: <1386625856-12942-9-git-send-email-santosh.shilimkar@ti.com>
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
	<1386625856-12942-9-git-send-email-santosh.shilimkar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Grygorii Strashko <grygorii.strashko@ti.com>

On Mon, 9 Dec 2013 16:50:41 -0500 Santosh Shilimkar <santosh.shilimkar@ti.com> wrote:

> Introduce memblock memory allocation APIs which allow to support
> PAE or LPAE extension on 32 bits archs where the physical memory
> start address can be beyond 4GB. In such cases, existing bootmem
> APIs which operate on 32 bit addresses won't work and needs
> memblock layer which operates on 64 bit addresses.
> 
> So we add equivalent APIs so that we can replace usage of bootmem
> with memblock interfaces. Architectures already converted to
> NO_BOOTMEM use these new memblock interfaces. The architectures
> which are still not converted to NO_BOOTMEM continue to function
> as is because we still maintain the fal lback option of bootmem
> back-end supporting these new interfaces. So no functional change
> as such.
> 
> In long run, once all the architectures moves to NO_BOOTMEM, we
> can get rid of bootmem layer completely. This is one step to remove
> the core code dependency with bootmem and also gives path for
> architectures to move away from bootmem.
> 
> The proposed interface will became active if both
> CONFIG_HAVE_MEMBLOCK and CONFIG_NO_BOOTMEM are specified by arch.
> In case !CONFIG_NO_BOOTMEM, the memblock() wrappers will fallback
> to the existing bootmem apis so that arch's not converted to
> NO_BOOTMEM continue to work as is.
> 
> The meaning of MEMBLOCK_ALLOC_ACCESSIBLE and MEMBLOCK_ALLOC_ANYWHERE
> is kept same.
> 
> ...
>
> +static inline void * __init memblock_virt_alloc(
> +					phys_addr_t size,  phys_addr_t align)
> +{
> +	return memblock_virt_alloc_try_nid(size, align, BOOTMEM_LOW_LIMIT,
> +					    BOOTMEM_ALLOC_ACCESSIBLE,
> +					    NUMA_NO_NODE);
> +}

erk.  I prefer

static inline void * __init
memblock_virt_alloc(phys_addr_t size,  phys_addr_t align);

to this.  But not enough to bother changing it ;)

> +/**
> + * memblock_virt_alloc_internal - allocate boot memory block
> + * @size: size of memory block to be allocated in bytes
> + * @align: alignment of the region and block's size
> + * @min_addr: the lower bound of the memory region to allocate (phys address)
> + * @max_addr: the upper bound of the memory region to allocate (phys address)
> + * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
> + *
> + * The @min_addr limit is dropped if it can not be satisfied and the allocation
> + * will fall back to memory below @min_addr. Also, allocation may fall back
> + * to any node in the system if the specified node can not
> + * hold the requested memory.
> + *
> + * The allocation is performed from memory region limited by
> + * memblock.current_limit if @max_addr == %BOOTMEM_ALLOC_ACCESSIBLE.
> + *
> + * The memory block is aligned on SMP_CACHE_BYTES if @align == 0.
> + *
> + * The phys address of allocated boot memory block is converted to virtual and
> + * allocated memory is reset to 0.
> + *
> + * In addition, function sets the min_count to 0 using kmemleak_alloc for
> + * allocated boot memory block, so that it is never reported as leaks.
> + *
> + * RETURNS:
> + * Virtual address of allocated memory block on success, NULL on failure.
> + */
> +static void * __init memblock_virt_alloc_internal(
> +				phys_addr_t size, phys_addr_t align,
> +				phys_addr_t min_addr, phys_addr_t max_addr,
> +				int nid)
> +{
> +	phys_addr_t alloc;
> +	void *ptr;
> +
> +	if (nid == MAX_NUMNODES)
> +		pr_warn("%s: usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE\n",
> +			__func__);

"deprecated".  I'll fix this (three places).

> +	if (WARN_ON_ONCE(slab_is_available()))
> +		return kzalloc_node(size, GFP_NOWAIT, nid);

I don't know why this generates a warning.  And I bet that if it
generates a warning for some other developer, they won't know either. 
Please send a patch to add a suitable code comment here.

> +
> +	/*
> +	 * The min_count is set to 0 so that bootmem allocated blocks
> +	 * are never reported as leaks.
> +	 */
> +	kmemleak_alloc(ptr, size, 0, 0);

This is not a good comment - it explains "what" (which is fairly
obvious) but it doesn't explain "why".  Unfreed bootmem can surely be
considered a leak in some situations so perhaps some people will want
them reported as such.  Please send a patch which updates this comment,
fully explaining the reasoning behind this decision.

> +	return ptr;
> +
> +error:
> +	return NULL;
> +}
> +
> +/**
> + * memblock_virt_alloc_try_nid_nopanic - allocate boot memory block
> + * @size: size of memory block to be allocated in bytes
> + * @align: alignment of the region and block's size
> + * @min_addr: the lower bound of the memory region from where the allocation
> + *	  is preferred (phys address)
> + * @max_addr: the upper bound of the memory region from where the allocation
> + *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
> + *	      allocate only from memory limited by memblock.current_limit value
> + * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
> + *
> + * Public version of _memblock_virt_alloc_try_nid_nopanic() which provides
> + * additional debug information (including caller info), if enabled.
> + *
> + * RETURNS:
> + * Virtual address of allocated memory block on success, NULL on failure.
> + */
> +void * __init memblock_virt_alloc_try_nid_nopanic(
> +				phys_addr_t size, phys_addr_t align,
> +				phys_addr_t min_addr, phys_addr_t max_addr,
> +				int nid)
> +{
> +	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
> +		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
> +		     (u64)max_addr, (void *)_RET_IP_);

Maybe we should teach vsprintf() how to print phys_addr_t's.  Similar
to
http://ozlabs.org/~akpm/mmots/broken-out/vsprintf-add-%25pad-extension-for-dma_addr_t-use.patch

Printing a single level of the call stack is often pretty useless. 
Have you been using memblock_dbg() and have you found this _RET_IP_
information to be sufficient?


> +	return memblock_virt_alloc_internal(size, align, min_addr,
> +					     max_addr, nid);
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
