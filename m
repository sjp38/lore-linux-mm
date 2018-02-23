Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 788186B0007
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 17:28:42 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id m19so4044000pgv.5
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 14:28:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a64sor1066453pfc.55.2018.02.23.14.28.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Feb 2018 14:28:40 -0800 (PST)
Subject: Re: [PATCH 1/7] genalloc: track beginning of allocations
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-2-igor.stoppa@huawei.com>
From: J Freyensee <why2jjj.linux@gmail.com>
Message-ID: <0897d235-db55-3d3c-12be-34a97debb921@gmail.com>
Date: Fri, 23 Feb 2018 14:28:36 -0800
MIME-Version: 1.0
In-Reply-To: <20180223144807.1180-2-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

some code snipping
.
.
.
> +/**
> + * get_bitmap_entry() - extracts the specified entry from the bitmap
> + * @map: pointer to a bitmap
> + * @entry_index: the index of the desired entry in the bitmap
> + *
> + * Return: The requested bitmap.
> + */
> +static inline unsigned long get_bitmap_entry(unsigned long *map,
> +					    int entry_index)
> +{

Apologies if this has been mentioned before, but since this function is 
expecting map to not be NULL, shouldn't something like:

WARN_ON(map == NULL);

be used to check the parameters for bad values?

BTW, excellent commenting :-).
> +	return (map[ENTRIES_DIV_LONGS(entry_index)] >>
> +		ENTRIES_TO_BITS(entry_index % ENTRIES_PER_LONG)) &
> +		ENTRY_MASK;
> +}
> +
> +
> +/**
> + * mem_to_units() - convert references to memory into orders of allocation
> + * @size: amount in bytes
> + * @order: power of 2 represented by each entry in the bitmap
> + *
> + * Return: the number of units representing the size.
> + */
> +static inline unsigned long mem_to_units(unsigned long size,
> +					 unsigned long order)
> +{
> +	return (size + (1UL << order) - 1) >> order;
> +}
> +
> +/**
> + * chunk_size() - dimension of a chunk of memory, in bytes
> + * @chunk: pointer to the struct describing the chunk
> + *
> + * Return: The size of the chunk, in bytes.
> + */
>   static inline size_t chunk_size(const struct gen_pool_chunk *chunk)
>   {
Same problem here, always expecting chunk to not but NULL.

>   	return chunk->end_addr - chunk->start_addr + 1;
>   }
>   
> -static int set_bits_ll(unsigned long *addr, unsigned long mask_to_set)
> +
> +/**
> + * set_bits_ll() - based on value and mask, sets bits at address
> + * @addr: where to write
> + * @mask: filter to apply for the bits to alter
> + * @value: actual configuration of bits to store
> + *
> + * Return:
> + * * 0		- success
> + * * -EBUSY	- otherwise
> + */
> +static int set_bits_ll(unsigned long *addr,
> +		       unsigned long mask, unsigned long value)
>   {
> -	unsigned long val, nval;
> +	unsigned long nval;
> +	unsigned long present;
> +	unsigned long target;
>   
>   	nval = *addr;

Same issue here with addr.
>   	do {
> -		val = nval;
> -		if (val & mask_to_set)
> +		present = nval;
> +		if (present & mask)
>   			return -EBUSY;
> +		target =  present | value;
>   		cpu_relax();
> -	} while ((nval = cmpxchg(addr, val, val | mask_to_set)) != val);
> -
> +	} while ((nval = cmpxchg(addr, present, target)) != target);
>   	return 0;
>   }
>   
> -static int clear_bits_ll(unsigned long *addr, unsigned long mask_to_clear)
> +
> +/**
> + * clear_bits_ll() - based on value and mask, clears bits at address
> + * @addr: where to write
> + * @mask: filter to apply for the bits to alter
> + * @value: actual configuration of bits to clear
> + *
> + * Return:
> + * * 0		- success
> + * * -EBUSY	- otherwise
> + */
> +static int clear_bits_ll(unsigned long *addr,
> +			 unsigned long mask, unsigned long value)

Dido here for addr too.
>   {
> -	unsigned long val, nval;
> +	unsigned long nval;
> +	unsigned long present;
> +	unsigned long target;
>   
>   	nval = *addr;
> +	present = nval;
> +	if (unlikely((present & mask) ^ value))
> +		return -EBUSY;
>   	do {
> -		val = nval;
> -		if ((val & mask_to_clear) != mask_to_clear)
> +		present = nval;
> +		if (unlikely((present & mask) ^ value))
>   			return -EBUSY;
> +		target =  present & ~mask;
>   		cpu_relax();
> -	} while ((nval = cmpxchg(addr, val, val & ~mask_to_clear)) != val);
> -
> +	} while ((nval = cmpxchg(addr, present, target)) != target);
>   	return 0;
>   }
>   
> -/*
> - * bitmap_set_ll - set the specified number of bits at the specified position
> +
> +/**
> + * get_boundary() - verifies address, then measure length.
>    * @map: pointer to a bitmap
> - * @start: a bit position in @map
> - * @nr: number of bits to set
> + * @start_entry: the index of the first entry in the bitmap
> + * @nentries: number of entries to alter
>    *
> - * Set @nr bits start from @start in @map lock-lessly. Several users
> - * can set/clear the same bitmap simultaneously without lock. If two
> - * users set the same bit, one user will return remain bits, otherwise
> - * return 0.
> + * Return:
> + * * length of an allocation	- success
> + * * -EINVAL			- invalid parameters
>    */
> -static int bitmap_set_ll(unsigned long *map, int start, int nr)
> +static int get_boundary(unsigned long *map, int start_entry, int nentries)
Same problem for map.

>   {
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
> +	if (unlikely(get_bitmap_entry(map, start_entry) != ENTRY_HEAD))j
Since get_bitmap_entry() is a new function, I'm not sure why the second 
parameter is defined as an 'int', looks like unsigned int would be 
appropriate.
> +		return -EINVAL;
> +	for (i = start_entry + 1; i < nentries; i++) {
It is being assumed nentries is not negative, which can be possible as 
the function parameter is defined as 'int'.
> +		bitmap_entry = get_bitmap_entry(map, i);
> +		if (bitmap_entry == ENTRY_HEAD ||
> +		    bitmap_entry == ENTRY_UNUSED)
> +			return i;
> +	}
> +	return nentries - start_entry;
>   }
>   
> +
> +#define SET_BITS 1
> +#define CLEAR_BITS 0
> +
>   /*
> - * bitmap_clear_ll - clear the specified number of bits at the specified position
> + * alter_bitmap_ll() - set/clear the entries associated with an allocation
> + * @alteration: indicates if the bits selected should be set or cleared
>    * @map: pointer to a bitmap
> - * @start: a bit position in @map
> - * @nr: number of bits to set
> + * @start: the index of the first entry in the bitmap
> + * @nentries: number of entries to alter
> + *
> + * The modification happens lock-lessly.
> + * Several users can write to the same map simultaneously, without lock.
> + * In case of mid-air conflict, when 2 or more writers try to alter the
> + * same word in the bitmap, only one will succeed and continue, the others
> + * will fail and receive as return value the amount of entries that were
> + * not written. Each failed writer is responsible to revert the changes
> + * it did to the bitmap.
> + * The lockless conflict resolution is implemented through cmpxchg.
> + * Success or failure is purely based on first come first served basis.
> + * The first writer that manages to gain write access to the target word
> + * of the bitmap wins. Whatever can affect the order and priority of execution
> + * of the writers can and will affect the result of the race.
>    *
> - * Clear @nr bits start from @start in @map lock-lessly. Several users
> - * can set/clear the same bitmap simultaneously without lock. If two
> - * users clear the same bit, one user will return remain bits,
> - * otherwise return 0.
> + * Return:
> + * * 0			- success
> + * * remaining entries	- failure
>    */
> -static int bitmap_clear_ll(unsigned long *map, int start, int nr)
> +static int alter_bitmap_ll(bool alteration, unsigned long *map,
> +			   int start_entry, int nentries)
>   {
map could benefit from a WARN_ON(map == NULL).
> -	unsigned long *p = map + BIT_WORD(start);
> -	const int size = start + nr;
> -	int bits_to_clear = BITS_PER_LONG - (start % BITS_PER_LONG);
> -	unsigned long mask_to_clear = BITMAP_FIRST_WORD_MASK(start);
> -
> -	while (nr - bits_to_clear >= 0) {
> -		if (clear_bits_ll(p, mask_to_clear))
> -			return nr;
> -		nr -= bits_to_clear;
> -		bits_to_clear = BITS_PER_LONG;
> -		mask_to_clear = ~0UL;
> -		p++;
> -	}
> -	if (nr) {
> -		mask_to_clear &= BITMAP_LAST_WORD_MASK(size);
> -		if (clear_bits_ll(p, mask_to_clear))
> -			return nr;
> +	unsigned long start_bit;
> +	unsigned long end_bit;
> +	unsigned long mask;
> +	unsigned long value;
> +	int nbits;
> +	int bits_to_write;
> +	int index;
> +	int (*action)(unsigned long *addr,
> +		      unsigned long mask, unsigned long value);
> +
> +	action = (alteration == SET_BITS) ? set_bits_ll : clear_bits_ll;
> +
> +	/*
> +	 * Prepare for writing the initial part of the allocation, from
> +	 * starting entry, to the end of the UL bitmap element which
> +	 * contains it. It might be larger than the actual allocation.
> +	 */
> +	start_bit = ENTRIES_TO_BITS(start_entry);
> +	end_bit = ENTRIES_TO_BITS(start_entry + nentries);
> +	nbits = ENTRIES_TO_BITS(nentries);

these statements won't make any sense if start_entry and nentries are 
negative values, which is possible based on the function definition 
alter_bitmap_ll().A  Am I missing something that it's ok for these 
parameters to be negative?
> +	bits_to_write = BITS_PER_LONG - start_bit % BITS_PER_LONG;
> +	mask = BITMAP_FIRST_WORD_MASK(start_bit);
> +	/* Mark the beginning of the allocation. */
> +	value = MASK | (1UL << (start_bit % BITS_PER_LONG));
> +	index = BITS_DIV_LONGS(start_bit);
> +
> +	/*
> +	 * Writes entries to the bitmap, as long as the reminder is
> +	 * positive or zero.
> +	 * Might be skipped if the entries to write do not reach the end
> +	 * of a bitmap UL unit.
> +	 */
> +	while (nbits >= bits_to_write) {
> +		if (action(map + index, mask, value & mask))
> +			return BITS_DIV_ENTRIES(nbits);
> +		nbits -= bits_to_write;
> +		bits_to_write = BITS_PER_LONG;
> +		mask = ~0UL;
> +		value = MASK;
> +		index++;
>   	}
>   
> +	/* Takes care of the ending part of the entries to mark. */
> +	if (nbits > 0) {
> +		mask ^= BITMAP_FIRST_WORD_MASK((end_bit) % BITS_PER_LONG);
> +		bits_to_write = nbits;
> +		if (action(map + index, mask, value & mask))
> +			return BITS_DIV_ENTRIES(nbits);
> +	}
>   	return 0;
>   }
>   
> +
>   /**
> - * gen_pool_create - create a new special memory pool
> - * @min_alloc_order: log base 2 of number of bytes each bitmap bit represents
> - * @nid: node id of the node the pool structure should be allocated on, or -1
> + * gen_pool_create() - create a new special memory pool
> + * @min_alloc_order: log base 2 of number of bytes each bitmap entry
> + *		     represents
> + * @nid: node id of the node the pool structure should be allocated on,
> + *	 or -1
>    *
> - * Create a new special memory pool that can be used to manage special purpose
> - * memory not managed by the regular kmalloc/kfree interface.
> + * Create a new special memory pool that can be used to manage special
> + * purpose memory not managed by the regular kmalloc/kfree interface.
> + *
> + * Return:
> + * * pointer to the pool	- success
> + * * NULL			- otherwise
>    */
>   struct gen_pool *gen_pool_create(int min_alloc_order, int nid)
>   {
> @@ -167,7 +364,7 @@ struct gen_pool *gen_pool_create(int min_alloc_order, int nid)
>   EXPORT_SYMBOL(gen_pool_create);
>   
>   /**
> - * gen_pool_add_virt - add a new chunk of special memory to the pool
> + * gen_pool_add_virt() - add a new chunk of special memory to the pool
>    * @pool: pool to add new memory chunk to
>    * @virt: virtual starting address of memory chunk to add to pool
>    * @phys: physical starting address of memory chunk to add to pool
> @@ -177,16 +374,20 @@ EXPORT_SYMBOL(gen_pool_create);
>    *
>    * Add a new chunk of special memory to the specified pool.
>    *
> - * Returns 0 on success or a -ve errno on failure.
> + * Return:
> + * * 0		- success
> + * * -ve errno	- failure
>    */
> -int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt, phys_addr_t phys,
> -		 size_t size, int nid)
> +int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt,
> +		      phys_addr_t phys, size_t size, int nid)
>   {
WARN_ON(pool == NULL);
?
>   	struct gen_pool_chunk *chunk;
> -	int nbits = size >> pool->min_alloc_order;
> -	int nbytes = sizeof(struct gen_pool_chunk) +
> -				BITS_TO_LONGS(nbits) * sizeof(long);
> +	int nentries;
> +	int nbytes;
>   
> +	nentries = size >> pool->min_alloc_order;
> +	nbytes = sizeof(struct gen_pool_chunk) +
> +		 ENTRIES_DIV_LONGS(nentries) * sizeof(long);
>   	chunk = kzalloc_node(nbytes, GFP_KERNEL, nid);
>   	if (unlikely(chunk == NULL))
>   		return -ENOMEM;
> @@ -205,11 +406,13 @@ int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt, phys_addr_t phy
>   EXPORT_SYMBOL(gen_pool_add_virt);
>   
>   /**
> - * gen_pool_virt_to_phys - return the physical address of memory
> + * gen_pool_virt_to_phys() - return the physical address of memory
>    * @pool: pool to allocate from
>    * @addr: starting address of memory
>    *
> - * Returns the physical address on success, or -1 on error.
> + * Return:
> + * * the physical address	- success
> + * * \-1			- error
>    */
>   phys_addr_t gen_pool_virt_to_phys(struct gen_pool *pool, unsigned long addr)
>   {
> @@ -230,7 +433,7 @@ phys_addr_t gen_pool_virt_to_phys(struct gen_pool *pool, unsigned long addr)
>   EXPORT_SYMBOL(gen_pool_virt_to_phys);
>   
>   /**
> - * gen_pool_destroy - destroy a special memory pool
> + * gen_pool_destroy() - destroy a special memory pool
>    * @pool: pool to destroy
>    *
>    * Destroy the specified special memory pool. Verifies that there are no
> @@ -248,7 +451,7 @@ void gen_pool_destroy(struct gen_pool *pool)
>   		list_del(&chunk->next_chunk);
>   
>   		end_bit = chunk_size(chunk) >> order;
> -		bit = find_next_bit(chunk->bits, end_bit, 0);
> +		bit = find_next_bit(chunk->entries, end_bit, 0);
>   		BUG_ON(bit < end_bit);
>   
>   		kfree(chunk);
> @@ -259,7 +462,7 @@ void gen_pool_destroy(struct gen_pool *pool)
>   EXPORT_SYMBOL(gen_pool_destroy);
>   
>   /**
> - * gen_pool_alloc - allocate special memory from the pool
> + * gen_pool_alloc() - allocate special memory from the pool
>    * @pool: pool to allocate from
>    * @size: number of bytes to allocate from the pool
>    *
> @@ -267,6 +470,10 @@ EXPORT_SYMBOL(gen_pool_destroy);
>    * Uses the pool allocation function (with first-fit algorithm by default).
>    * Can not be used in NMI handler on architectures without
>    * NMI-safe cmpxchg implementation.
> + *
> + * Return:
> + * * address of the memory allocated	- success
> + * * NULL				- error
>    */
>   unsigned long gen_pool_alloc(struct gen_pool *pool, size_t size)
>   {
> @@ -275,7 +482,7 @@ unsigned long gen_pool_alloc(struct gen_pool *pool, size_t size)
>   EXPORT_SYMBOL(gen_pool_alloc);
>   
>   /**
> - * gen_pool_alloc_algo - allocate special memory from the pool
> + * gen_pool_alloc_algo() - allocate special memory from the pool
>    * @pool: pool to allocate from
>    * @size: number of bytes to allocate from the pool
>    * @algo: algorithm passed from caller
> @@ -285,6 +492,10 @@ EXPORT_SYMBOL(gen_pool_alloc);
>    * Uses the pool allocation function (with first-fit algorithm by default).
>    * Can not be used in NMI handler on architectures without
>    * NMI-safe cmpxchg implementation.
> + *
> + * Return:
> + * * address of the memory allocated	- success
> + * * NULL				- error
>    */
>   unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
>   		genpool_algo_t algo, void *data)
> @@ -292,7 +503,7 @@ unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
>   	struct gen_pool_chunk *chunk;
>   	unsigned long addr = 0;
>   	int order = pool->min_alloc_order;
> -	int nbits, start_bit, end_bit, remain;
> +	int nentries, start_entry, end_entry, remain;
Be nicer to use "unsigned int", but it's not clear from this diff that 
this could work with other existing code.

>   
>   #ifndef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
>   	BUG_ON(in_nmi());
> @@ -301,29 +512,32 @@ unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
>   	if (size == 0)
>   		return 0;
>   
> -	nbits = (size + (1UL << order) - 1) >> order;
> +	nentries = mem_to_units(size, order);
>   	rcu_read_lock();
>   	list_for_each_entry_rcu(chunk, &pool->chunks, next_chunk) {
>   		if (size > atomic_long_read(&chunk->avail))
>   			continue;
>   
> -		start_bit = 0;
> -		end_bit = chunk_size(chunk) >> order;
> +		start_entry = 0;
> +		end_entry = chunk_size(chunk) >> order;
>   retry:
> -		start_bit = algo(chunk->bits, end_bit, start_bit,
> -				 nbits, data, pool);
> -		if (start_bit >= end_bit)
> +		start_entry = algo(chunk->entries, end_entry, start_entry,
> +				  nentries, data, pool);
> +		if (start_entry >= end_entry)
>   			continue;
> -		remain = bitmap_set_ll(chunk->bits, start_bit, nbits);
> +		remain = alter_bitmap_ll(SET_BITS, chunk->entries,
> +					 start_entry, nentries);
>   		if (remain) {
> -			remain = bitmap_clear_ll(chunk->bits, start_bit,
> -						 nbits - remain);
> -			BUG_ON(remain);
> +			remain = alter_bitmap_ll(CLEAR_BITS,
> +						 chunk->entries,
> +						 start_entry,
> +						 nentries - remain);
>   			goto retry;
>   		}
>   
> -		addr = chunk->start_addr + ((unsigned long)start_bit << order);
> -		size = nbits << order;
> +		addr = chunk->start_addr +
> +			((unsigned long)start_entry << order);
> +		size = nentries << order;
>   		atomic_long_sub(size, &chunk->avail);
>   		break;
>   	}
> @@ -333,7 +547,7 @@ unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
>   EXPORT_SYMBOL(gen_pool_alloc_algo);
>   
>   /**
> - * gen_pool_dma_alloc - allocate special memory from the pool for DMA usage
> + * gen_pool_dma_alloc() - allocate special memory from the pool for DMA usage
>    * @pool: pool to allocate from
>    * @size: number of bytes to allocate from the pool
>    * @dma: dma-view physical address return value.  Use NULL if unneeded.
> @@ -342,6 +556,10 @@ EXPORT_SYMBOL(gen_pool_alloc_algo);
>    * Uses the pool allocation function (with first-fit algorithm by default).
>    * Can not be used in NMI handler on architectures without
>    * NMI-safe cmpxchg implementation.
> + *
> + * Return:
> + * * address of the memory allocated	- success
> + * * NULL				- error
>    */
>   void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma)
>   {
> @@ -362,10 +580,10 @@ void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma)
>   EXPORT_SYMBOL(gen_pool_dma_alloc);
>   
>   /**
> - * gen_pool_free - free allocated special memory back to the pool
> + * gen_pool_free() - free allocated special memory back to the pool
>    * @pool: pool to free to
>    * @addr: starting address of memory to free back to pool
> - * @size: size in bytes of memory to free
> + * @size: size in bytes of memory to free or 0, for auto-detection
>    *
>    * Free previously allocated special memory back to the specified
>    * pool.  Can not be used in NMI handler on architectures without
> @@ -375,22 +593,29 @@ void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size)
>   {
>   	struct gen_pool_chunk *chunk;
>   	int order = pool->min_alloc_order;
> -	int start_bit, nbits, remain;
> +	int start_entry, remaining_entries, nentries, remain;
> +	int boundary;
>   
>   #ifndef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
>   	BUG_ON(in_nmi());
>   #endif
>   
> -	nbits = (size + (1UL << order) - 1) >> order;
>   	rcu_read_lock();
>   	list_for_each_entry_rcu(chunk, &pool->chunks, next_chunk) {
>   		if (addr >= chunk->start_addr && addr <= chunk->end_addr) {
>   			BUG_ON(addr + size - 1 > chunk->end_addr);
> -			start_bit = (addr - chunk->start_addr) >> order;
> -			remain = bitmap_clear_ll(chunk->bits, start_bit, nbits);
> +			start_entry = (addr - chunk->start_addr) >> order;
> +			remaining_entries = (chunk->end_addr - addr) >> order;
> +			boundary = get_boundary(chunk->entries, start_entry,
> +						remaining_entries);
> +			BUG_ON(boundary < 0);

Do you really want to use BUG_ON()?A  I've thought twice about using 
BUG_ON() based on Linus's wrath with BUG_ON() code causing an issue with 
the 4.8 release:

https://lkml.org/lkml/2016/10/4/1

Hence why I've been giving WARN_ON() suggestions throughout this review.

Thanks,
Jay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
