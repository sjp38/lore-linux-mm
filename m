Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C8D286B0031
	for <linux-mm@kvack.org>; Sun, 13 Oct 2013 13:56:57 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so6629742pab.29
        for <linux-mm@kvack.org>; Sun, 13 Oct 2013 10:56:57 -0700 (PDT)
Received: by mail-qa0-f53.google.com with SMTP id k15so1702566qaq.12
        for <linux-mm@kvack.org>; Sun, 13 Oct 2013 10:56:54 -0700 (PDT)
Date: Sun, 13 Oct 2013 13:56:48 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 06/23] mm/memblock: Add memblock early memory allocation
 apis
Message-ID: <20131013175648.GC5253@mtj.dyndns.org>
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
 <1381615146-20342-7-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381615146-20342-7-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: yinghai@kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, grygorii.strashko@ti.com, Andrew Morton <akpm@linux-foundation.org>

Hello,

On Sat, Oct 12, 2013 at 05:58:49PM -0400, Santosh Shilimkar wrote:
> Introduce memblock early memory allocation APIs which allow to support
> LPAE extension on 32 bits archs. More over, this is the next step

LPAE isn't something people outside arm circle would understand.
Let's stick to highmem.

> to get rid of NO_BOOTMEM memblock wrapper(nobootmem.c) and directly use
> memblock APIs.
> 
> The proposed interface will became active if both CONFIG_HAVE_MEMBLOCK
> and CONFIG_NO_BOOTMEM are specified by arch. In case !CONFIG_NO_BOOTMEM,
> the memblock() wrappers will fallback to the existing bootmem apis so
> that arch's noy converted to NO_BOOTMEM continue to work as is.
              ^^^
             typo

> +/* FIXME: Move to memblock.h at a point where we remove nobootmem.c */
> +void *memblock_early_alloc_try_nid_nopanic(int nid, phys_addr_t size,
> +		phys_addr_t align, phys_addr_t from, phys_addr_t max_addr);
> +void *memblock_early_alloc_try_nid(int nid, phys_addr_t size,
> +		phys_addr_t align, phys_addr_t from, phys_addr_t max_addr);

Wouldn't it make more sense to put @nid at the end.  @size is the main
parameter here and it gets confusing with _alloc_node() interface as
the positions of paramters change.  Plus, kmalloc_node() puts @node at
the end too.

> +void __memblock_free_early(phys_addr_t base, phys_addr_t size);
> +void __memblock_free_late(phys_addr_t base, phys_addr_t size);

Would it be possible to drop "early"?  It's redundant and makes the
function names unnecessarily long.  When memblock is enabled, these
are basically doing about the same thing as memblock_alloc() and
friends, right?  Wouldn't it make more sense to define these as
memblock_alloc_XXX()?

> +#define memblock_early_alloc(x) \
> +	memblock_early_alloc_try_nid(MAX_NUMNODES, x, SMP_CACHE_BYTES, \
> +			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)
> +#define memblock_early_alloc_align(x, align) \
> +	memblock_early_alloc_try_nid(MAX_NUMNODES, x, align, \
> +			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)
> +#define memblock_early_alloc_nopanic(x) \
> +	memblock_early_alloc_try_nid_nopanic(MAX_NUMNODES, x, SMP_CACHE_BYTES, \
> +			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)
> +#define memblock_early_alloc_pages(x) \
> +	memblock_early_alloc_try_nid(MAX_NUMNODES, x, PAGE_SIZE, \
> +			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)
> +#define memblock_early_alloc_pages_nopanic(x) \
> +	memblock_early_alloc_try_nid_nopanic(MAX_NUMNODES, x, PAGE_SIZE, \
> +			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)

I always felt a bit weird about _pages() interface.  It says pages but
takes bytes in size.  Maybe we're better off just converting the
current _pages users to _alloc_align()?

> +#define memblock_early_alloc_node(nid, x) \
> +	memblock_early_alloc_try_nid(nid, x, SMP_CACHE_BYTES, \
> +			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)
> +#define memblock_early_alloc_node_nopanic(nid, x) \
> +	memblock_early_alloc_try_nid_nopanic(nid, x, SMP_CACHE_BYTES, \
> +			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)

Ditto as above.  Maybe @nid can be moved to the end?

> +static void * __init _memblock_early_alloc_try_nid_nopanic(int nid,
> +				phys_addr_t size, phys_addr_t align,
> +				phys_addr_t from, phys_addr_t max_addr)
> +{
> +	phys_addr_t alloc;
> +	void *ptr;
> +
> +	if (WARN_ON_ONCE(slab_is_available())) {
> +		if (nid == MAX_NUMNODES)

Shouldn't we be using NUMA_NO_NODE?

> +			return kzalloc(size, GFP_NOWAIT);
> +		else
> +			return kzalloc_node(size, GFP_NOWAIT, nid);

And kzalloc_node() understands NUMA_NO_NODE.

> +	}
> +
> +	if (WARN_ON(!align))
> +		align = __alignof__(long long);

Wouldn't SMP_CACHE_BYTES make more sense?  Also, I'm not sure we
actually want WARN on it.  Interpreting 0 as "default align" isn't
that weird.

> +	/* align @size to avoid excessive fragmentation on reserved array */
> +	size = round_up(size, align);
> +
> +again:
> +	alloc = memblock_find_in_range_node(from, max_addr, size, align, nid);
> +	if (alloc)
> +		goto done;
> +
> +	if (nid != MAX_NUMNODES) {
> +		alloc =
> +			memblock_find_in_range_node(from, max_addr, size,
> +						    align, MAX_NUMNODES);
> +		if (alloc)
> +			goto done;
> +	}
> +
> +	if (from) {
> +		from = 0;
> +		goto again;
> +	} else {
> +		goto error;
> +	}
> +
> +done:
> +	memblock_reserve(alloc, size);
> +	ptr = phys_to_virt(alloc);
> +	memset(ptr, 0, size);

What if the address is high?  Don't we need kmapping here?

> +
> +	/*
> +	 * The min_count is set to 0 so that bootmem allocated blocks
> +	 * are never reported as leaks.
> +	 */
> +	kmemleak_alloc(ptr, size, 0, 0);
> +
> +	return ptr;
> +
> +error:
> +	return NULL;
> +}
> +
> +void * __init memblock_early_alloc_try_nid_nopanic(int nid,
> +				phys_addr_t size, phys_addr_t align,
> +				phys_addr_t from, phys_addr_t max_addr)
> +{
> +	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
> +			__func__, (u64)size, (u64)align, nid, (u64)from,
> +			(u64)max_addr, (void *)_RET_IP_);
> +	return _memblock_early_alloc_try_nid_nopanic(nid, size,
> +						align, from, max_addr);

Do we need the extra level of wrapping?  Just implement
alloc_try_nid_nopanic() here and make the panicky version call it?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
