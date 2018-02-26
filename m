Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 908226B0003
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 12:33:05 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id t12-v6so4918527plo.9
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 09:33:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k3-v6sor252517pld.63.2018.02.26.09.33.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 09:33:03 -0800 (PST)
Subject: Re: [PATCH 1/7] genalloc: track beginning of allocations
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-2-igor.stoppa@huawei.com>
 <0897d235-db55-3d3c-12be-34a97debb921@gmail.com>
 <4f77b269-c2eb-a8d2-1326-900d00229268@huawei.com>
From: J Freyensee <why2jjj.linux@gmail.com>
Message-ID: <14be8222-766f-50e6-83ec-bcbefa04ba44@gmail.com>
Date: Mon, 26 Feb 2018 09:32:56 -0800
MIME-Version: 1.0
In-Reply-To: <4f77b269-c2eb-a8d2-1326-900d00229268@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

My replies also inlined.

On 2/26/18 4:09 AM, Igor Stoppa wrote:
> Hello,
> and thanks for the reviews, my replies inlined below.
>
> On 24/02/18 00:28, J Freyensee wrote:
>> some code snipping
>> .
>> .
>> .
>>> +/**
>>> + * get_bitmap_entry() - extracts the specified entry from the bitmap
>>> + * @map: pointer to a bitmap
>>> + * @entry_index: the index of the desired entry in the bitmap
>>> + *
>>> + * Return: The requested bitmap.
>>> + */
>>> +static inline unsigned long get_bitmap_entry(unsigned long *map,
>>> +					    int entry_index)
>>> +{
>> Apologies if this has been mentioned before, but since this function is
>> expecting map to not be NULL, shouldn't something like:
>>
>> WARN_ON(map == NULL);
>>
>> be used to check the parameters for bad values?
> TBH I do not know.
> Actually I'd rather ask back: when is it preferred to do (and not do)
> parameter sanitation?
>
> I was thinking that doing it at API level is the right balance.
> This function, for example, is not part of the API, it's used only
> internally in this file.


I agree.A  But some of the code looks API'like to me, partly because of 
all the function header documentation, which thank you for that, but I 
wasn't sure where you drew your "API line" where the checks would be.

>
> Is it assuming too much that the function will be used correctly, inside
> the module it belongs to?
>
> And even at API level, I'd tend to say that if there are chances that
> the data received is corrupted, then it should be sanitized, but otherwise,
> why adding overhead?

It's good secure coding practice to check your parameters, you are 
adding code to a security module after all ;-).

If it's brand-new code entering the kernel, it's better to err on the 
side of having the extra checks and have a maintainer tell you to remove 
it than the other way around- especially since this code is part of the 
LSM solution.A  What's worse- a tad bit of overhead catching a 
corner-case scenario that can be more easily fixed or something not 
caught that makes the kernel unstable?

>
> Unless you expect some form of memory corruption. Is that what you have
> in mind?
>
> [...]
>
>>>    static inline size_t chunk_size(const struct gen_pool_chunk *chunk)
>>>    {
>> Same problem here, always expecting chunk to not but NULL.
> What would be the case that makes it not NULL?
> There are already tests in place when the memory is allocated.
>
> If I really have to pick a place where to do the test, it's at API
> level,

I agree, and if that is the case, I'm fine.

> where the user of the API might fail to notice that the creation
> of a pool failed and try to get memory from a non-existing pool.
> That is the only scenario I can think of, where bogus data would be
> received.
>
>>>    	return chunk->end_addr - chunk->start_addr + 1;
>>>    }
>>>    
>>> -static int set_bits_ll(unsigned long *addr, unsigned long mask_to_set)
>>> +
>>> +/**
>>> + * set_bits_ll() - based on value and mask, sets bits at address
>>> + * @addr: where to write
>>> + * @mask: filter to apply for the bits to alter
>>> + * @value: actual configuration of bits to store
>>> + *
>>> + * Return:
>>> + * * 0		- success
>>> + * * -EBUSY	- otherwise
>>> + */
>>> +static int set_bits_ll(unsigned long *addr,
>>> +		       unsigned long mask, unsigned long value)
>>>    {
>>> -	unsigned long val, nval;
>>> +	unsigned long nval;
>>> +	unsigned long present;
>>> +	unsigned long target;
>>>    
>>>    	nval = *addr;
>> Same issue here with addr.
> Again, I am more leaning toward believing that the user of the API might
> forget to check for errors,

Same in agreement, so if that is the case, I'm ok.A  It was a little hard 
to tell what is exactly your API is.A  I'm used to reviewing kernel code 
where important API-like functions were heavily documented, and inner 
routines were not...so seeing the function documentation (which is a 
good thing :-)) made me think this was some sort of new API code I was 
looking at.

> and pass a NULL pointer as pool, than to
> believe something like this would happen.
>
> This is an address obtained from data managed automatically by the library.
>
> Can you please explain why you think it would be NULL?

Why would it be NULL?A  I don't know, I'm not intimately familiar with 
the code; but I default to implementing code defensively.A  But I'll turn 
the question around on you- why would it NOT be NULL?A  Are you sure this 
will never be NULL?A  Are you going to trust the library that it always 
provides a good address?A  You should add to your function header 
documentation why addr will NOT be NULL.


> I'll skip further similar comment.
>
> [...]
>
>>> +	/*
>>> +	 * Prepare for writing the initial part of the allocation, from
>>> +	 * starting entry, to the end of the UL bitmap element which
>>> +	 * contains it. It might be larger than the actual allocation.
>>> +	 */
>>> +	start_bit = ENTRIES_TO_BITS(start_entry);
>>> +	end_bit = ENTRIES_TO_BITS(start_entry + nentries);
>>> +	nbits = ENTRIES_TO_BITS(nentries);
>> these statements won't make any sense if start_entry and nentries are
>> negative values, which is possible based on the function definition
>> alter_bitmap_ll().A  Am I missing something that it's ok for these
>> parameters to be negative?
> This patch is extending the handling of the bitmap, it's not trying to
> rewrite genalloc, thus it tries to not alter parts which are unrelated.
> Like the type of parameters passed.
>
> What you are suggesting is a further cleanup of genalloc.
> I'm not against it, but it's unrelated to this patchset.

OK, very reasonable.A  Then I would think this would be a case to add a 
check for negative values in the function parameters start_entry and 
nentries as it's possible (though maybe not realistic) to have negative 
values supplied, especially if there is currently no active maintainer 
for genalloc().A  Since you are fitting new code to genalloc's behavior 
and this is a security module, I'll err on the side of checking the 
parameters for bad values, or document in your function header comments 
why it is expected for these parameters to never have negative values.
>
> Incidentally, nobody really seems to be maintaining genalloc, so I'm
> hesitant in adding more changes, when there isn't a dedicated maintainer
> to say Yes/No.

Very understandable.A  I think this is another reason it's good to have 
more checks around your new function parameters- be good to be sure your 
code behaves to the expectations of genalloc().

>
>>> +	bits_to_write = BITS_PER_LONG - start_bit % BITS_PER_LONG;
>>> +	mask = BITMAP_FIRST_WORD_MASK(start_bit);
>>> +	/* Mark the beginning of the allocation. */
>>> +	value = MASK | (1UL << (start_bit % BITS_PER_LONG));
>>> +	index = BITS_DIV_LONGS(start_bit);
>>> +
>>> +	/*
>>> +	 * Writes entries to the bitmap, as long as the reminder is
>>> +	 * positive or zero.
>>> +	 * Might be skipped if the entries to write do not reach the end
>>> +	 * of a bitmap UL unit.
>>> +	 */
>>> +	while (nbits >= bits_to_write) {
>>> +		if (action(map + index, mask, value & mask))
>>> +			return BITS_DIV_ENTRIES(nbits);
>>> +		nbits -= bits_to_write;
>>> +		bits_to_write = BITS_PER_LONG;
>>> +		mask = ~0UL;
>>> +		value = MASK;
>>> +		index++;
>>>    	}
>>>    
>>> +	/* Takes care of the ending part of the entries to mark. */
>>> +	if (nbits > 0) {
>>> +		mask ^= BITMAP_FIRST_WORD_MASK((end_bit) % BITS_PER_LONG);
>>> +		bits_to_write = nbits;
>>> +		if (action(map + index, mask, value & mask))
>>> +			return BITS_DIV_ENTRIES(nbits);
>>> +	}
>>>    	return 0;
>>>    }
>>>    
>>> +
>>>    /**
>>> - * gen_pool_create - create a new special memory pool
>>> - * @min_alloc_order: log base 2 of number of bytes each bitmap bit represents
>>> - * @nid: node id of the node the pool structure should be allocated on, or -1
>>> + * gen_pool_create() - create a new special memory pool
>>> + * @min_alloc_order: log base 2 of number of bytes each bitmap entry
>>> + *		     represents
>>> + * @nid: node id of the node the pool structure should be allocated on,
>>> + *	 or -1
>>>     *
>>> - * Create a new special memory pool that can be used to manage special purpose
>>> - * memory not managed by the regular kmalloc/kfree interface.
>>> + * Create a new special memory pool that can be used to manage special
>>> + * purpose memory not managed by the regular kmalloc/kfree interface.
>>> + *
>>> + * Return:
>>> + * * pointer to the pool	- success
>>> + * * NULL			- otherwise
>>>     */
>>>    struct gen_pool *gen_pool_create(int min_alloc_order, int nid)
>>>    {
>>> @@ -167,7 +364,7 @@ struct gen_pool *gen_pool_create(int min_alloc_order, int nid)
>>>    EXPORT_SYMBOL(gen_pool_create);
>>>    
>>>    /**
>>> - * gen_pool_add_virt - add a new chunk of special memory to the pool
>>> + * gen_pool_add_virt() - add a new chunk of special memory to the pool
>>>     * @pool: pool to add new memory chunk to
>>>     * @virt: virtual starting address of memory chunk to add to pool
>>>     * @phys: physical starting address of memory chunk to add to pool
>>> @@ -177,16 +374,20 @@ EXPORT_SYMBOL(gen_pool_create);
>>>     *
>>>     * Add a new chunk of special memory to the specified pool.
>>>     *
>>> - * Returns 0 on success or a -ve errno on failure.
>>> + * Return:
>>> + * * 0		- success
>>> + * * -ve errno	- failure
>>>     */
>>> -int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt, phys_addr_t phys,
>>> -		 size_t size, int nid)
>>> +int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt,
>>> +		      phys_addr_t phys, size_t size, int nid)
>>>    {
>> WARN_ON(pool == NULL);
>> ?
>>>    	struct gen_pool_chunk *chunk;
>>> -	int nbits = size >> pool->min_alloc_order;
>>> -	int nbytes = sizeof(struct gen_pool_chunk) +
>>> -				BITS_TO_LONGS(nbits) * sizeof(long);
>>> +	int nentries;
>>> +	int nbytes;
>>>    
>>> +	nentries = size >> pool->min_alloc_order;
>>> +	nbytes = sizeof(struct gen_pool_chunk) +
>>> +		 ENTRIES_DIV_LONGS(nentries) * sizeof(long);
>>>    	chunk = kzalloc_node(nbytes, GFP_KERNEL, nid);
>>>    	if (unlikely(chunk == NULL))
>>>    		return -ENOMEM;
>>> @@ -205,11 +406,13 @@ int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt, phys_addr_t phy
>>>    EXPORT_SYMBOL(gen_pool_add_virt);
>>>    
>>>    /**
>>> - * gen_pool_virt_to_phys - return the physical address of memory
>>> + * gen_pool_virt_to_phys() - return the physical address of memory
>>>     * @pool: pool to allocate from
>>>     * @addr: starting address of memory
>>>     *
>>> - * Returns the physical address on success, or -1 on error.
>>> + * Return:
>>> + * * the physical address	- success
>>> + * * \-1			- error
>>>     */
>>>    phys_addr_t gen_pool_virt_to_phys(struct gen_pool *pool, unsigned long addr)
>>>    {
>>> @@ -230,7 +433,7 @@ phys_addr_t gen_pool_virt_to_phys(struct gen_pool *pool, unsigned long addr)
>>>    EXPORT_SYMBOL(gen_pool_virt_to_phys);
>>>    
>>>    /**
>>> - * gen_pool_destroy - destroy a special memory pool
>>> + * gen_pool_destroy() - destroy a special memory pool
>>>     * @pool: pool to destroy
>>>     *
>>>     * Destroy the specified special memory pool. Verifies that there are no
>>> @@ -248,7 +451,7 @@ void gen_pool_destroy(struct gen_pool *pool)
>>>    		list_del(&chunk->next_chunk);
>>>    
>>>    		end_bit = chunk_size(chunk) >> order;
>>> -		bit = find_next_bit(chunk->bits, end_bit, 0);
>>> +		bit = find_next_bit(chunk->entries, end_bit, 0);
>>>    		BUG_ON(bit < end_bit);
>>>    
>>>    		kfree(chunk);
>>> @@ -259,7 +462,7 @@ void gen_pool_destroy(struct gen_pool *pool)
>>>    EXPORT_SYMBOL(gen_pool_destroy);
>>>    
>>>    /**
>>> - * gen_pool_alloc - allocate special memory from the pool
>>> + * gen_pool_alloc() - allocate special memory from the pool
>>>     * @pool: pool to allocate from
>>>     * @size: number of bytes to allocate from the pool
>>>     *
>>> @@ -267,6 +470,10 @@ EXPORT_SYMBOL(gen_pool_destroy);
>>>     * Uses the pool allocation function (with first-fit algorithm by default).
>>>     * Can not be used in NMI handler on architectures without
>>>     * NMI-safe cmpxchg implementation.
>>> + *
>>> + * Return:
>>> + * * address of the memory allocated	- success
>>> + * * NULL				- error
>>>     */
>>>    unsigned long gen_pool_alloc(struct gen_pool *pool, size_t size)
>>>    {
>>> @@ -275,7 +482,7 @@ unsigned long gen_pool_alloc(struct gen_pool *pool, size_t size)
>>>    EXPORT_SYMBOL(gen_pool_alloc);
>>>    
>>>    /**
>>> - * gen_pool_alloc_algo - allocate special memory from the pool
>>> + * gen_pool_alloc_algo() - allocate special memory from the pool
>>>     * @pool: pool to allocate from
>>>     * @size: number of bytes to allocate from the pool
>>>     * @algo: algorithm passed from caller
>>> @@ -285,6 +492,10 @@ EXPORT_SYMBOL(gen_pool_alloc);
>>>     * Uses the pool allocation function (with first-fit algorithm by default).
>>>     * Can not be used in NMI handler on architectures without
>>>     * NMI-safe cmpxchg implementation.
>>> + *
>>> + * Return:
>>> + * * address of the memory allocated	- success
>>> + * * NULL				- error
>>>     */
>>>    unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
>>>    		genpool_algo_t algo, void *data)
>>> @@ -292,7 +503,7 @@ unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
>>>    	struct gen_pool_chunk *chunk;
>>>    	unsigned long addr = 0;
>>>    	int order = pool->min_alloc_order;
>>> -	int nbits, start_bit, end_bit, remain;
>>> +	int nentries, start_entry, end_entry, remain;
>> Be nicer to use "unsigned int", but it's not clear from this diff that
>> this could work with other existing code.
>>
>>>    
>>>    #ifndef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
>>>    	BUG_ON(in_nmi());
>>> @@ -301,29 +512,32 @@ unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
>>>    	if (size == 0)
>>>    		return 0;
>>>    
>>> -	nbits = (size + (1UL << order) - 1) >> order;
>>> +	nentries = mem_to_units(size, order);
>>>    	rcu_read_lock();
>>>    	list_for_each_entry_rcu(chunk, &pool->chunks, next_chunk) {
>>>    		if (size > atomic_long_read(&chunk->avail))
>>>    			continue;
>>>    
>>> -		start_bit = 0;
>>> -		end_bit = chunk_size(chunk) >> order;
>>> +		start_entry = 0;
>>> +		end_entry = chunk_size(chunk) >> order;
>>>    retry:
>>> -		start_bit = algo(chunk->bits, end_bit, start_bit,
>>> -				 nbits, data, pool);
>>> -		if (start_bit >= end_bit)
>>> +		start_entry = algo(chunk->entries, end_entry, start_entry,
>>> +				  nentries, data, pool);
>>> +		if (start_entry >= end_entry)
>>>    			continue;
>>> -		remain = bitmap_set_ll(chunk->bits, start_bit, nbits);
>>> +		remain = alter_bitmap_ll(SET_BITS, chunk->entries,
>>> +					 start_entry, nentries);
>>>    		if (remain) {
>>> -			remain = bitmap_clear_ll(chunk->bits, start_bit,
>>> -						 nbits - remain);
>>> -			BUG_ON(remain);
>>> +			remain = alter_bitmap_ll(CLEAR_BITS,
>>> +						 chunk->entries,
>>> +						 start_entry,
>>> +						 nentries - remain);
>>>    			goto retry;
>>>    		}
>>>    
>>> -		addr = chunk->start_addr + ((unsigned long)start_bit << order);
>>> -		size = nbits << order;
>>> +		addr = chunk->start_addr +
>>> +			((unsigned long)start_entry << order);
>>> +		size = nentries << order;
>>>    		atomic_long_sub(size, &chunk->avail);
>>>    		break;
>>>    	}
>>> @@ -333,7 +547,7 @@ unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
>>>    EXPORT_SYMBOL(gen_pool_alloc_algo);
>>>    
>>>    /**
>>> - * gen_pool_dma_alloc - allocate special memory from the pool for DMA usage
>>> + * gen_pool_dma_alloc() - allocate special memory from the pool for DMA usage
>>>     * @pool: pool to allocate from
>>>     * @size: number of bytes to allocate from the pool
>>>     * @dma: dma-view physical address return value.  Use NULL if unneeded.
>>> @@ -342,6 +556,10 @@ EXPORT_SYMBOL(gen_pool_alloc_algo);
>>>     * Uses the pool allocation function (with first-fit algorithm by default).
>>>     * Can not be used in NMI handler on architectures without
>>>     * NMI-safe cmpxchg implementation.
>>> + *
>>> + * Return:
>>> + * * address of the memory allocated	- success
>>> + * * NULL				- error
>>>     */
>>>    void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma)
>>>    {
>>> @@ -362,10 +580,10 @@ void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma)
>>>    EXPORT_SYMBOL(gen_pool_dma_alloc);
>>>    
>>>    /**
>>> - * gen_pool_free - free allocated special memory back to the pool
>>> + * gen_pool_free() - free allocated special memory back to the pool
>>>     * @pool: pool to free to
>>>     * @addr: starting address of memory to free back to pool
>>> - * @size: size in bytes of memory to free
>>> + * @size: size in bytes of memory to free or 0, for auto-detection
>>>     *
>>>     * Free previously allocated special memory back to the specified
>>>     * pool.  Can not be used in NMI handler on architectures without
>>> @@ -375,22 +593,29 @@ void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size)
>>>    {
>>>    	struct gen_pool_chunk *chunk;
>>>    	int order = pool->min_alloc_order;
>>> -	int start_bit, nbits, remain;
>>> +	int start_entry, remaining_entries, nentries, remain;
>>> +	int boundary;
>>>    
>>>    #ifndef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
>>>    	BUG_ON(in_nmi());
>>>    #endif
>>>    
>>> -	nbits = (size + (1UL << order) - 1) >> order;
>>>    	rcu_read_lock();
>>>    	list_for_each_entry_rcu(chunk, &pool->chunks, next_chunk) {
>>>    		if (addr >= chunk->start_addr && addr <= chunk->end_addr) {
>>>    			BUG_ON(addr + size - 1 > chunk->end_addr);
>>> -			start_bit = (addr - chunk->start_addr) >> order;
>>> -			remain = bitmap_clear_ll(chunk->bits, start_bit, nbits);
>>> +			start_entry = (addr - chunk->start_addr) >> order;
>>> +			remaining_entries = (chunk->end_addr - addr) >> order;
>>> +			boundary = get_boundary(chunk->entries, start_entry,
>>> +						remaining_entries);
>>> +			BUG_ON(boundary < 0);
>> Do you really want to use BUG_ON()?A  I've thought twice about using
>> BUG_ON() based on Linus's wrath with BUG_ON() code causing an issue with
>> the 4.8 release:
>>
>> https://lkml.org/lkml/2016/10/4/1
>>
>> Hence why I've been giving WARN_ON() suggestions throughout this review.
> Oh, I thought I had added explanations here too, but I did it only for
> pmalloc :-(
>
> Thanks for spotting this.
>
> To answer the question, do I really want to do it?
> Maybe not here, I wrote this before introducing the self test.
> But in the self test probably yes. The self test is optional and the
> idea is to prevent cases where there could be corruption of permanent
> storage.

Yah, it would be much better to have this in self-tests.


>
> I have read Linus' comments, but what is still not clear to me is:
> is there _any_ case where BUG_ON() is acceptable?

Probably not :-P.

Thanks,
Jay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
