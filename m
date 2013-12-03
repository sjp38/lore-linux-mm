Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 562EE6B0073
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 18:24:50 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id k4so6039703qaq.8
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 15:24:50 -0800 (PST)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id q6si37841737qag.72.2013.12.03.15.24.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 15:24:49 -0800 (PST)
Received: by mail-qa0-f44.google.com with SMTP id i13so6085623qae.17
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 15:24:49 -0800 (PST)
Date: Tue, 3 Dec 2013 18:24:45 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation apis
Message-ID: <20131203232445.GX8277@htj.dyndns.org>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
 <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Grygorii Strashko <grygorii.strashko@ti.com>

Hello,

On Mon, Dec 02, 2013 at 09:27:23PM -0500, Santosh Shilimkar wrote:
> So we add equivalent APIs so that we can replace usage of bootmem
> with memblock interfaces. Architectures already converted to NO_BOOTMEM
> use these new interfaces and other which still uses bootmem, these new
> APIs just fallback to exiting bootmem APIs. So no functional change as
> such.

The last part of the second last sentence doesn't parse too well.  I
think it'd be worthwhile to improve and preferably expand on it as
this is a bit tricky to understand given the twisted state of early
memory allocation.

> In long run, once all the achitectures moves to NO_BOOTMEM, we can get rid of
> bootmem layer completely. This is one step to remove the core code dependency
> with bootmem and also gives path for architectures to move away from bootmem.

Lines too long?

> +/*
> + * FIXME: use NUMA_NO_NODE instead of MAX_NUMNODES when bootmem/nobootmem code
> + * will be removed.
> + * It can't be done now, because when MEMBLOCK or NO_BOOTMEM are not enabled
> + * all calls of the new API will be redirected to bottmem/nobootmem where
> + * MAX_NUMNODES is widely used.

I don't know.  We're introducing a new API which will be used across
the kernel.  I don't think it makes a lot of sense to use the wrong
constant now to convert all the users later.  Wouldn't it be better to
make the new interface take NUMA_NO_NODE and do whatever it needs to
do to interface with bootmem?

> + * Also, memblock core APIs __next_free_mem_range_rev() and
> + * __next_free_mem_range() would need to be updated, and as result we will
> + * need to re-check/update all direct calls of memblock_alloc_xxx()
> + * APIs (including nobootmem).
> + */

Hmmm....

> +/* FIXME: Move to memblock.h at a point where we remove nobootmem.c */
> +void *memblock_virt_alloc_try_nid_nopanic(phys_addr_t size,
> +		phys_addr_t align, phys_addr_t from,
> +		phys_addr_t max_addr, int nid);

Wouldn't @min_addr instead of @from make more sense?  Ditto for other
occurrences.

> +void *memblock_virt_alloc_try_nid(phys_addr_t size, phys_addr_t align,
> +		phys_addr_t from, phys_addr_t max_addr, int nid);
> +void __memblock_free_early(phys_addr_t base, phys_addr_t size);
> +void __memblock_free_late(phys_addr_t base, phys_addr_t size);
> +
> +#define memblock_virt_alloc(x) \
> +	memblock_virt_alloc_try_nid(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT, \
> +				     BOOTMEM_ALLOC_ACCESSIBLE, MAX_NUMNODES)

The underlying function interprets 0 as the default align, so it
probably is a better idea to just use 0 here.

> +#define memblock_virt_alloc_align(x, align) \
> +	memblock_virt_alloc_try_nid(x, align, BOOTMEM_LOW_LIMIT, \
> +				     BOOTMEM_ALLOC_ACCESSIBLE, MAX_NUMNODES)

Also, do we really need this align variant separate when the caller
can simply specify 0 for the default?

> +#define memblock_virt_alloc_nopanic(x) \
> +	memblock_virt_alloc_try_nid_nopanic(x, SMP_CACHE_BYTES, \
> +					     BOOTMEM_LOW_LIMIT, \
> +					     BOOTMEM_ALLOC_ACCESSIBLE, \
> +					     MAX_NUMNODES)
> +#define memblock_virt_alloc_align_nopanic(x, align) \
> +	memblock_virt_alloc_try_nid_nopanic(x, align, \
> +					     BOOTMEM_LOW_LIMIT, \
> +					     BOOTMEM_ALLOC_ACCESSIBLE, \
> +					     MAX_NUMNODES)
> +#define memblock_virt_alloc_node(x, nid) \
> +	memblock_virt_alloc_try_nid(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT, \
> +				     BOOTMEM_ALLOC_ACCESSIBLE, nid)
> +#define memblock_virt_alloc_node_nopanic(x, nid) \
> +	memblock_virt_alloc_try_nid_nopanic(x, SMP_CACHE_BYTES, \
> +					     BOOTMEM_LOW_LIMIT, \
> +					     BOOTMEM_ALLOC_ACCESSIBLE, nid)
> +
> +#define memblock_free_early(x, s)		__memblock_free_early(x, s)
> +#define memblock_free_early_nid(x, s, nid)	__memblock_free_early(x, s)
> +#define memblock_free_late(x, s)		__memblock_free_late(x, s)

Please make the wrappers inline functions.

> +#else
> +
> +#define BOOTMEM_ALLOC_ACCESSIBLE	0
> +
> +
> +/* Fall back to all the existing bootmem APIs */
> +#define memblock_virt_alloc(x) \
> +	__alloc_bootmem(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
> +#define memblock_virt_alloc_align(x, align) \
> +	__alloc_bootmem(x, align, BOOTMEM_LOW_LIMIT)
> +#define memblock_virt_alloc_nopanic(x) \
> +	__alloc_bootmem_nopanic(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
> +#define memblock_virt_alloc_align_nopanic(x, align) \
> +	__alloc_bootmem_nopanic(x, align, BOOTMEM_LOW_LIMIT)
> +#define memblock_virt_alloc_node(x, nid) \
> +	__alloc_bootmem_node(NODE_DATA(nid), x, SMP_CACHE_BYTES, \
> +			BOOTMEM_LOW_LIMIT)
> +#define memblock_virt_alloc_node_nopanic(x, nid) \
> +	__alloc_bootmem_node_nopanic(NODE_DATA(nid), x, SMP_CACHE_BYTES, \
> +			BOOTMEM_LOW_LIMIT)
> +#define memblock_virt_alloc_try_nid(size, align, from, max_addr, nid) \
> +		__alloc_bootmem_node_high(NODE_DATA(nid), size, align, from)
> +#define memblock_virt_alloc_try_nid_nopanic(size, align, from, max_addr, nid) \
> +		___alloc_bootmem_node_nopanic(NODE_DATA(nid), size, align, \
> +			from, max_addr)
> +#define memblock_free_early(x, s)	free_bootmem(x, s)
> +#define memblock_free_early_nid(x, s, nid) \
> +			free_bootmem_node(NODE_DATA(nid), x, s)
> +#define memblock_free_late(x, s)	free_bootmem_late(x, s)
> +
> +#endif /* defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM) */

Ditto.

> diff --git a/mm/memblock.c b/mm/memblock.c
> index 1d15e07..3311fbb 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -21,6 +21,9 @@
>  #include <linux/memblock.h>
>  
>  #include <asm-generic/sections.h>
> +#include <asm/io.h>
> +
> +#include "internal.h"
>  
>  static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
>  static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
> @@ -933,6 +936,198 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
>  	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
>  }
>  
> +/**
> + * _memblock_virt_alloc_try_nid_nopanic - allocate boot memory block

Please don't use both "__" and "_" prefixes.  It gets confusing like
hell.  Just give it an another name.

> + * @size: size of memory block to be allocated in bytes
> + * @align: alignment of the region and block's size
> + * @from: the lower bound of the memory region from where the allocation
> + *	  is preferred (phys address)
> + * @max_addr: the upper bound of the memory region from where the allocation
> + *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
> + *	      allocate only from memory limited by memblock.current_limit value

It probably would be better style to make the above shorter and fit
each on a single line.  If they need further explanation, they can be
done in the body of the comment.

> + * @nid: nid of the free area to find, %MAX_NUMNODES for any node
> + *
> + * The @from limit is dropped if it can not be satisfied and the allocation
> + * will fall back to memory below @from.
> + *
> + * Allocation may fall back to any node in the system if the specified node
> + * can not hold the requested memory.

Maybe combine the above two paragraphs?

> + * The phys address of allocated boot memory block is converted to virtual and
> + * allocated memory is reset to 0.
> + *
> + * In addition, function sets sets the min_count for allocated boot memory block

                            ^^^^^^^^^
No mention of kmemleak at all is a bit confusing.  min_count of what?

> + * to 0 so that it is never reported as leaks.
> + *
> + * RETURNS:
> + * Virtual address of allocated memory block on success, NULL on failure.
> + */
> +static void * __init _memblock_virt_alloc_try_nid_nopanic(
> +				phys_addr_t size, phys_addr_t align,
> +				phys_addr_t from, phys_addr_t max_addr,
> +				int nid)
> +{
> +	phys_addr_t alloc;
> +	void *ptr;
> +
> +	if (WARN_ON_ONCE(slab_is_available())) {
> +		if (nid == MAX_NUMNODES)
> +			return kzalloc(size, GFP_NOWAIT);
> +		else
> +			return kzalloc_node(size, GFP_NOWAIT, nid);
> +	}
> +
> +	if (!align)
> +		align = SMP_CACHE_BYTES;
> +
> +	/* align @size to avoid excessive fragmentation on reserved array */
> +	size = round_up(size, align);
> +
> +again:
> +	alloc = memblock_find_in_range_node(from, max_addr, size, align, nid);

Not your fault but we probably wanna update these functions so that
their param orders are consistent.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
