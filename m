Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 821966B0007
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 08:19:18 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id u200so16846318qka.21
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 05:19:18 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w12si14549714qtg.73.2018.03.06.05.19.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 05:19:16 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w26DHde1147089
	for <linux-mm@kvack.org>; Tue, 6 Mar 2018 08:19:15 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ghtf1m48f-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Mar 2018 08:19:15 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 6 Mar 2018 13:19:12 -0000
Date: Tue, 6 Mar 2018 14:19:03 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/7] genalloc: track beginning of allocations
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-2-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180228200620.30026-2-igor.stoppa@huawei.com>
Message-Id: <20180306131856.GD19349@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Feb 28, 2018 at 10:06:14PM +0200, Igor Stoppa wrote:
> The genalloc library is only capable of tracking if a certain unit of
> allocation is in use or not.
> 
> It is not capable of discerning where the memory associated to an
> allocation request begins and where it ends.
> 
> The reason is that units of allocations are tracked by using a bitmap,
> where each bit represents that the unit is either allocated (1) or
> available (0).
> 
> The user of the API must keep track of how much space was requested, if
> it ever needs to be freed.
> 
> This can cause errors being undetected.
> Examples:
> * Only a subset of the memory provided to an allocation request is freed
> * The memory from a subsequent allocation is freed
> * The memory being freed doesn't start at the beginning of an
>   allocation.
> 
> The bitmap is used because it allows to perform lockless read/write
> access, where this is supported by hw through cmpxchg.
> Similarly, it is possible to scan the bitmap for a sufficiently long
> sequence of zeros, to identify zones available for allocation.
> 
> This patch doubles the space reserved in the bitmap for each allocation,
> to track their beginning.
> 
> For details, see the documentation inside lib/genalloc.c
> 
> The primary effect of this patch is that code using the gen_alloc
> library does not need anymore to keep track of the size of the
> allocations it makes.
> 
> Prior to this patch, it was necessary to keep track of the size of the
> allocation, so that it would be possible, later on, to know how much
> space should be freed.
> 
> Now, users of the api can choose to etiher still specify explicitly the
> size, or let the library determine it, by giving a value of 0.
> 
> However, even when the value is specified, the library still uses its on
> understanding of the space associated with a certain allocation, to
> confirm that they are consistent.
> 
> This verification also confirms that the patch works correctly.
> 
> Eventually, the extra parameter (and the corresponding verification)
> could be dropped, in favor of a simplified API.
> 
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>  include/linux/genalloc.h | 354 ++++++++++++++++++++---
>  lib/genalloc.c           | 721 ++++++++++++++++++++++++++++++++++-------------
>  2 files changed, 837 insertions(+), 238 deletions(-)

Thanks for taking time to update the kernel-doc parts!
Some docs related comments below.
 
> diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
> index 872f930f1b06..7b1a1f1d9985 100644
> --- a/include/linux/genalloc.h
> +++ b/include/linux/genalloc.h
> @@ -32,7 +32,7 @@
> 
>  #include <linux/types.h>
>  #include <linux/spinlock_types.h>
> -#include <linux/atomic.h>
> +#include <linux/slab.h>
> 
>  struct device;
>  struct device_node;
> @@ -76,7 +76,7 @@ struct gen_pool_chunk {
>  	phys_addr_t phys_addr;		/* physical starting address of memory chunk */
>  	unsigned long start_addr;	/* start address of memory chunk */
>  	unsigned long end_addr;		/* end address of memory chunk (inclusive) */
> -	unsigned long bits[0];		/* bitmap for allocating memory chunk */
> +	unsigned long entries[0];	/* bitmap for allocating memory chunk */
>  };
> 
>  /*
> @@ -93,10 +93,40 @@ struct genpool_data_fixed {
>  	unsigned long offset;		/* The offset of the specific region */
>  };
> 
> -extern struct gen_pool *gen_pool_create(int, int);
> -extern phys_addr_t gen_pool_virt_to_phys(struct gen_pool *pool, unsigned long);
> -extern int gen_pool_add_virt(struct gen_pool *, unsigned long, phys_addr_t,
> -			     size_t, int);
> +/**
> + * gen_pool_create() - create a new special memory pool
> + * @min_alloc_order: log base 2 of number of bytes each bitmap entry
> + *		     represents
> + * @nid: node id of the node the pool structure should be allocated on,
> + *	 or -1
> + *
> + * Create a new special memory pool that can be used to manage special
> + * purpose memory not managed by the regular kmalloc/kfree interface.
> + *
> + * Return:
> + * * pointer to the pool	- success
> + * * NULL			- otherwise
> + */

If I'm not mistaken, several kernel-doc descriptions are duplicated now.
Can you please keep a single copy? ;-)

> +struct gen_pool *gen_pool_create(int min_alloc_order, int nid);
> +
> +/**
> + * gen_pool_add_virt() - add a new chunk of special memory to the pool
> + * @pool: pool to add new memory chunk to
> + * @virt: virtual starting address of memory chunk to add to pool
> + * @phys: physical starting address of memory chunk to add to pool
> + * @size: size in bytes of the memory chunk to add to pool
> + * @nid: node id of the node the chunk structure and bitmap should be
> + *       allocated on, or -1
> + *
> + * Add a new chunk of special memory to the specified pool.
> + *
> + * Return:
> + * * 0		- success
> + * * -ve errno	- failure
> + */
> +int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt,
> +		      phys_addr_t phys, size_t size, int nid);
> +
>  /**
>   * gen_pool_add - add a new chunk of special memory to the pool
>   * @pool: pool to add new memory chunk to

...

> diff --git a/lib/genalloc.c b/lib/genalloc.c
> index ca06adc4f445..d505b959f888 100644
> --- a/lib/genalloc.c
> +++ b/lib/genalloc.c
> @@ -26,6 +26,74 @@
>   *
>   * This source code is licensed under the GNU General Public License,
>   * Version 2.  See the file COPYING for more details.
> + *
> + *
> + *
> + * Encoding of the bitmap tracking the allocations
> + * -----------------------------------------------
> + *
> + * The bitmap is composed of units of allocations.
> + *
> + * Each unit of allocation is represented using 2 consecutive bits.
> + *
> + * This makes it possible to encode, for each unit of allocation,
> + * information about:
> + *  - allocation status (busy/free)
> + *  - beginning of a sequennce of allocation units (first / successive)
> + *
> + *
> + * Dictionary of allocation units (msb to the left, lsb to the right):
> + *
> + * 11: first allocation unit in the allocation
> + * 10: any subsequent allocation unit (if any) in the allocation
> + * 00: available allocation unit
> + * 01: invalid
> + *
> + * Example, using the same notation as above - MSb.......LSb:
> + *
> + *  ...000010111100000010101011   <-- Read in this direction.
> + *     \__|\__|\|\____|\______|
> + *        |   | |     |       \___ 4 used allocation units
> + *        |   | |     \___________ 3 empty allocation units
> + *        |   | \_________________ 1 used allocation unit
> + *        |   \___________________ 2 used allocation units
> + *        \_______________________ 2 empty allocation units
> + *
> + * The encoding allows for lockless operations, such as:
> + * - search for a sufficiently large range of allocation units
> + * - reservation of a selected range of allocation units
> + * - release of a specific allocation
> + *
> + * The alignment at which to perform the research for sequence of empty

                                           ^ search?

> + * allocation units (marked as zeros in the bitmap) is 2^1.
> + *
> + * This means that an allocation can start only at even places
> + * (bit 0, bit 2, etc.) in the bitmap.
> + *
> + * Therefore, the number of zeroes to look for must be twice the number
> + * of desired allocation units.
> + *
> + * When it's time to free the memory associated to an allocation request,
> + * it's a matter of checking if the corresponding allocation unit is
> + * really the beginning of an allocation (both bits are set to 1).
> + *
> + * Looking for the ending can also be performed locklessly.
> + * It's sufficient to identify the first mapped allocation unit
> + * that is represented either as free (00) or busy (11).
> + * Even if the allocation status should change in the meanwhile, it
> + * doesn't matter, since it can only transition between free (00) and
> + * first-allocated (11).
> + *
> + * The parameter indicating to the *_free() function the size of the
> + * space that should be freed can be either set to 0, for automated
> + * assessment, or it can be specified explicitly.
> + *
> + * In case it is specified explicitly, the value is verified agaisnt what
> + * the library is tracking internally.
> + *
> + * If ever needed, the bitmap could be extended, assigning larger amounts
> + * of bits to each allocation unit (the increase must follow powers of 2),
> + * to track other properties of the allocations.
>   */
> 
>  #include <linux/slab.h>

...

> -/*
> - * bitmap_set_ll - set the specified number of bits at the specified position
> +
> +/**
> + * get_boundary() - verifies address, then measure length.

There's some lack of consistency between the name and implementation and
the description.
It seems that it would be simpler to actually make it get_length() and
return the length of the allocation or nentries if the latter is smaller.
Then in gen_pool_free() there will be no need to recalculate nentries
again.

>   * @map: pointer to a bitmap
> - * @start: a bit position in @map
> - * @nr: number of bits to set
> + * @start_entry: the index of the first entry in the bitmap
> + * @nentries: number of entries to alter

Maybe: "maximal number of entries to check"?

>   *
> - * Set @nr bits start from @start in @map lock-lessly. Several users
> - * can set/clear the same bitmap simultaneously without lock. If two
> - * users set the same bit, one user will return remain bits, otherwise
> - * return 0.
> + * Return:
> + * * length of an allocation	- success
> + * * -EINVAL			- invalid parameters
>   */
> -static int bitmap_set_ll(unsigned long *map, int start, int nr)
> +static int get_boundary(unsigned long *map, unsigned int start_entry,
> +			unsigned int nentries)
>  {
> -	unsigned long *p = map + BIT_WORD(start);
> -	const int size = start + nr;
> -	int bits_to_set = BITS_PER_LONG - (start % BITS_PER_LONG);
> -	unsigned long mask_to_set = BITMAP_FIRST_WORD_MASK(start);
> -
> -	while (nr - bits_to_set >= 0) {
> -		if (set_bits_ll(p, mask_to_set))
> -			return nr;
> -		nr -= bits_to_set;
> -		bits_to_set = BITS_PER_LONG;
> -		mask_to_set = ~0UL;
> -		p++;
> -	}
> -	if (nr) {
> -		mask_to_set &= BITMAP_LAST_WORD_MASK(size);
> -		if (set_bits_ll(p, mask_to_set))
> -			return nr;
> -	}
> +	int i;
> +	unsigned long bitmap_entry;
> 
> -	return 0;
> +
> +	if (unlikely(get_bitmap_entry(map, start_entry) != ENTRY_HEAD))
> +		return -EINVAL;
> +	for (i = start_entry + 1; i < nentries; i++) {
> +		bitmap_entry = get_bitmap_entry(map, i);
> +		if (bitmap_entry == ENTRY_HEAD ||
> +		    bitmap_entry == ENTRY_UNUSED)
> +			return i;
> +	}
> +	return nentries - start_entry;

Shouldn't it be "nentries + start_entry"?

>  }
 
...

> @@ -275,7 +492,7 @@ unsigned long gen_pool_alloc(struct gen_pool *pool, size_t size)
>  EXPORT_SYMBOL(gen_pool_alloc);
> 
>  /**
> - * gen_pool_alloc_algo - allocate special memory from the pool
> + * gen_pool_alloc_algo() - allocate special memory from the pool

+ using specified algorithm

>   * @pool: pool to allocate from
>   * @size: number of bytes to allocate from the pool
>   * @algo: algorithm passed from caller
> @@ -285,14 +502,18 @@ EXPORT_SYMBOL(gen_pool_alloc);
>   * Uses the pool allocation function (with first-fit algorithm by default).

"uses the provided @algo function to find room for the allocation"

>   * Can not be used in NMI handler on architectures without
>   * NMI-safe cmpxchg implementation.
> + *
> + * Return:
> + * * address of the memory allocated	- success
> + * * NULL				- error
>   */
>  unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
>  		genpool_algo_t algo, void *data)
>  {
>  	struct gen_pool_chunk *chunk;
>  	unsigned long addr = 0;
> -	int order = pool->min_alloc_order;
> -	int nbits, start_bit, end_bit, remain;
> +	unsigned int order = pool->min_alloc_order;
> +	unsigned int nentries, start_entry, end_entry, remain;
> 
>  #ifndef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
>  	BUG_ON(in_nmi());
> @@ -301,29 +522,32 @@ unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
>  	if (size == 0)
>  		return 0;
> 
> -	nbits = (size + (1UL << order) - 1) >> order;
> +	nentries = mem_to_units(size, order);
>  	rcu_read_lock();
>  	list_for_each_entry_rcu(chunk, &pool->chunks, next_chunk) {
>  		if (size > atomic_long_read(&chunk->avail))
>  			continue;
> 
> -		start_bit = 0;
> -		end_bit = chunk_size(chunk) >> order;
> +		start_entry = 0;
> +		end_entry = chunk_size(chunk) >> order;
>  retry:
> -		start_bit = algo(chunk->bits, end_bit, start_bit,
> -				 nbits, data, pool);
> -		if (start_bit >= end_bit)
> +		start_entry = algo(chunk->entries, end_entry, start_entry,
> +				  nentries, data, pool);
> +		if (start_entry >= end_entry)
>  			continue;
> -		remain = bitmap_set_ll(chunk->bits, start_bit, nbits);
> +		remain = alter_bitmap_ll(SET_BITS, chunk->entries,
> +					 start_entry, nentries);
>  		if (remain) {
> -			remain = bitmap_clear_ll(chunk->bits, start_bit,
> -						 nbits - remain);
> -			BUG_ON(remain);
> +			remain = alter_bitmap_ll(CLEAR_BITS,
> +						 chunk->entries,
> +						 start_entry,
> +						 nentries - remain);
>  			goto retry;
>  		}
> 
> -		addr = chunk->start_addr + ((unsigned long)start_bit << order);
> -		size = nbits << order;
> +		addr = chunk->start_addr +
> +			((unsigned long)start_entry << order);
> +		size = nentries << order;
>  		atomic_long_sub(size, &chunk->avail);
>  		break;
>  	}

...


> @@ -738,17 +1065,19 @@ EXPORT_SYMBOL(devm_gen_pool_create);
> 
>  #ifdef CONFIG_OF
>  /**
> - * of_gen_pool_get - find a pool by phandle property
> + * of_gen_pool_get() - find a pool by phandle property
>   * @np: device node
>   * @propname: property name containing phandle(s)
>   * @index: index into the phandle array
>   *
> - * Returns the pool that contains the chunk starting at the physical
> - * address of the device tree node pointed at by the phandle property,
> - * or NULL if not found.
> + * Return:
> + * * pool address	- it contains the chunk starting at the physical
> + *			  address of the device tree node pointed at by
> + *			  the phandle property
> + * * NULL		- otherwise
>   */
>  struct gen_pool *of_gen_pool_get(struct device_node *np,
> -	const char *propname, int index)
> +				 const char *propname, int index)
>  {
>  	struct platform_device *pdev;
>  	struct device_node *np_pool, *parent;
> -- 
> 2.14.1
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
