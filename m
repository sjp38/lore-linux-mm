Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 316E76B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 08:16:10 -0400 (EDT)
Date: Thu, 4 Apr 2013 07:16:08 -0500
From: Cliff Wickman <cpw@sgi.com>
Subject: Re: [PATCH] mm, x86: no zeroing of hugetlbfs pages at boot
Message-ID: <20130404121608.GA14127@sgi.com>
References: <E1UDME8-00041J-B4@eag09.americas.sgi.com> <515CC684.9050004@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515CC684.9050004@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, wli@holomorphy.com

On Thu, Apr 04, 2013 at 08:17:08AM +0800, Simon Jeons wrote:
> On 03/07/2013 05:50 AM, Cliff Wickman wrote:
>> From: Cliff Wickman <cpw@sgi.com>
>>
>> Allocating a large number of 1GB hugetlbfs pages at boot takes a
>> very long time.
>>
>> Large system sites would at times like to allocate a very large amount of
>> memory as 1GB pages.  They would put this on the kernel boot line:
>>     default_hugepagesz=1G hugepagesz=1G hugepages=4096
>> [Dynamic allocation of 1G pages is not an option, as zone pages only go
>>   up to MAX_ORDER, and MAX_ORDER cannot exceed the section size.]
>>
>> Each page is zeroed as it is allocated, and all allocation is done by
>> cpu 0, as this path is early in boot:
>
> How you confirm they are done by cpu 0? just cpu 0 works during boot?

Yes, in kernel_init() you see the call to do_pre_smp_initcalls() just
before the call to smp_init().  It is smp_init() that starts the other
cpus.  They don't come out of reset until then.

>>        start_kernel
>>          kernel_init
>>            do_pre_smp_initcalls
>>              hugetlb_init
>>                hugetlb_init_hstates
>>                  hugetlb_hstate_alloc_pages
>>
>> Zeroing remote (offnode) memory takes ~1GB/sec (and most memory is offnode
>> on large numa systems).
>> This estimate is approximate (it depends on core frequency & number of hops
>> to remote memory) but should be within a factor of 2 on most systems.
>> A benchmark attempting to reserve a TB for 1GB pages would thus require
>> ~1000 seconds of boot time just for this allocating.  32TB would take 8 hours.
>>
>> I propose passing a flag to the early allocator to indicate that no zeroing
>> of a page should be done.  The 'no zeroing' flag would have to be passed
>> down this code path:
>>
>>    hugetlb_hstate_alloc_pages
>>      alloc_bootmem_huge_page
>>        __alloc_bootmem_node_nopanic NO_ZERO  (nobootmem.c)
>>          __alloc_memory_core_early  NO_ZERO
>> 	  if (!(flags & NO_ZERO))
>>              memset(ptr, 0, size);
>>
>> Or this path if CONFIG_NO_BOOTMEM is not set:
>>
>>    hugetlb_hstate_alloc_pages
>>      alloc_bootmem_huge_page
>>        __alloc_bootmem_node_nopanic  NO_ZERO  (bootmem.c)
>>          alloc_bootmem_core          NO_ZERO
>> 	  if (!(flags & NO_ZERO))
>>              memset(region, 0, size);
>>          __alloc_bootmem_nopanic     NO_ZERO
>>            ___alloc_bootmem_nopanic  NO_ZERO
>>              alloc_bootmem_core      NO_ZERO
>> 	      if (!(flags & NO_ZERO))
>>                  memset(region, 0, size);
>>
>> Signed-off-by: Cliff Wickman <cpw@sgi.com>
>>
>> ---
>>   arch/x86/kernel/setup_percpu.c |    4 ++--
>>   include/linux/bootmem.h        |   23 ++++++++++++++++-------
>>   mm/bootmem.c                   |   12 +++++++-----
>>   mm/hugetlb.c                   |    3 ++-
>>   mm/nobootmem.c                 |   41 +++++++++++++++++++++++------------------
>>   mm/page_cgroup.c               |    2 +-
>>   mm/sparse.c                    |    2 +-
>>   7 files changed, 52 insertions(+), 35 deletions(-)
>>
>> Index: linux/include/linux/bootmem.h
>> ===================================================================
>> --- linux.orig/include/linux/bootmem.h
>> +++ linux/include/linux/bootmem.h
>> @@ -8,6 +8,11 @@
>>   #include <asm/dma.h>
>>     /*
>> + * allocation flags
>> + */
>> +#define NO_ZERO		0x00000001
>> +
>> +/*
>>    *  simple boot-time physical memory area allocator.
>>    */
>>   @@ -79,7 +84,8 @@ extern void *__alloc_bootmem(unsigned lo
>>   			     unsigned long goal);
>>   extern void *__alloc_bootmem_nopanic(unsigned long size,
>>   				     unsigned long align,
>> -				     unsigned long goal);
>> +				     unsigned long goal,
>> +				     u32 flags);
>>   extern void *__alloc_bootmem_node(pg_data_t *pgdat,
>>   				  unsigned long size,
>>   				  unsigned long align,
>> @@ -91,12 +97,14 @@ void *__alloc_bootmem_node_high(pg_data_
>>   extern void *__alloc_bootmem_node_nopanic(pg_data_t *pgdat,
>>   				  unsigned long size,
>>   				  unsigned long align,
>> -				  unsigned long goal);
>> +				  unsigned long goal,
>> +				  u32 flags);
>>   void *___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
>>   				  unsigned long size,
>>   				  unsigned long align,
>>   				  unsigned long goal,
>> -				  unsigned long limit);
>> +				  unsigned long limit,
>> +				  u32 flags);
>>   extern void *__alloc_bootmem_low(unsigned long size,
>>   				 unsigned long align,
>>   				 unsigned long goal);
>> @@ -120,19 +128,20 @@ extern void *__alloc_bootmem_low_node(pg
>>   #define alloc_bootmem_align(x, align) \
>>   	__alloc_bootmem(x, align, BOOTMEM_LOW_LIMIT)
>>   #define alloc_bootmem_nopanic(x) \
>> -	__alloc_bootmem_nopanic(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
>> +	__alloc_bootmem_nopanic(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT, 0)
>>   #define alloc_bootmem_pages(x) \
>>   	__alloc_bootmem(x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
>>   #define alloc_bootmem_pages_nopanic(x) \
>> -	__alloc_bootmem_nopanic(x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
>> +	__alloc_bootmem_nopanic(x, PAGE_SIZE, BOOTMEM_LOW_LIMIT, 0)
>>   #define alloc_bootmem_node(pgdat, x) \
>>   	__alloc_bootmem_node(pgdat, x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
>>   #define alloc_bootmem_node_nopanic(pgdat, x) \
>> -	__alloc_bootmem_node_nopanic(pgdat, x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
>> +	__alloc_bootmem_node_nopanic(pgdat, x, SMP_CACHE_BYTES, \
>> +				     BOOTMEM_LOW_LIMIT, 0)
>>   #define alloc_bootmem_pages_node(pgdat, x) \
>>   	__alloc_bootmem_node(pgdat, x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
>>   #define alloc_bootmem_pages_node_nopanic(pgdat, x) \
>> -	__alloc_bootmem_node_nopanic(pgdat, x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
>> +	__alloc_bootmem_node_nopanic(pgdat, x, PAGE_SIZE, BOOTMEM_LOW_LIMIT, 0)
>>     #define alloc_bootmem_low(x) \
>>   	__alloc_bootmem_low(x, SMP_CACHE_BYTES, 0)
>> Index: linux/arch/x86/kernel/setup_percpu.c
>> ===================================================================
>> --- linux.orig/arch/x86/kernel/setup_percpu.c
>> +++ linux/arch/x86/kernel/setup_percpu.c
>> @@ -104,14 +104,14 @@ static void * __init pcpu_alloc_bootmem(
>>   	void *ptr;
>>     	if (!node_online(node) || !NODE_DATA(node)) {
>> -		ptr = __alloc_bootmem_nopanic(size, align, goal);
>> +		ptr = __alloc_bootmem_nopanic(size, align, goal, 0);
>>   		pr_info("cpu %d has no node %d or node-local memory\n",
>>   			cpu, node);
>>   		pr_debug("per cpu data for cpu%d %lu bytes at %016lx\n",
>>   			 cpu, size, __pa(ptr));
>>   	} else {
>>   		ptr = __alloc_bootmem_node_nopanic(NODE_DATA(node),
>> -						   size, align, goal);
>> +						   size, align, goal, 0);
>>   		pr_debug("per cpu data for cpu%d %lu bytes on node%d at %016lx\n",
>>   			 cpu, size, node, __pa(ptr));
>>   	}
>> Index: linux/mm/nobootmem.c
>> ===================================================================
>> --- linux.orig/mm/nobootmem.c
>> +++ linux/mm/nobootmem.c
>> @@ -33,7 +33,7 @@ unsigned long min_low_pfn;
>>   unsigned long max_pfn;
>>     static void * __init __alloc_memory_core_early(int nid, u64 size, 
>> u64 align,
>> -					u64 goal, u64 limit)
>> +					u64 goal, u64 limit, u32 flags)
>>   {
>>   	void *ptr;
>>   	u64 addr;
>> @@ -46,7 +46,8 @@ static void * __init __alloc_memory_core
>>   		return NULL;
>>     	ptr = phys_to_virt(addr);
>> -	memset(ptr, 0, size);
>> +	if (!(flags & NO_ZERO))
>> +		memset(ptr, 0, size);
>>   	memblock_reserve(addr, size);
>>   	/*
>>   	 * The min_count is set to 0 so that bootmem allocated blocks
>> @@ -208,7 +209,8 @@ void __init free_bootmem(unsigned long a
>>   static void * __init ___alloc_bootmem_nopanic(unsigned long size,
>>   					unsigned long align,
>>   					unsigned long goal,
>> -					unsigned long limit)
>> +					unsigned long limit,
>> +					u32 flags)
>>   {
>>   	void *ptr;
>>   @@ -217,7 +219,8 @@ static void * __init ___alloc_bootmem_no
>>     restart:
>>   -	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align, goal, 
>> limit);
>> +	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align, goal,
>> +					limit, 0);
>>     	if (ptr)
>>   		return ptr;
>> @@ -244,17 +247,17 @@ restart:
>>    * Returns NULL on failure.
>>    */
>>   void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
>> -					unsigned long goal)
>> +					unsigned long goal, u32 flags)
>>   {
>>   	unsigned long limit = -1UL;
>>   -	return ___alloc_bootmem_nopanic(size, align, goal, limit);
>> +	return ___alloc_bootmem_nopanic(size, align, goal, limit, flags);
>>   }
>>     static void * __init ___alloc_bootmem(unsigned long size, unsigned 
>> long align,
>> -					unsigned long goal, unsigned long limit)
>> +			unsigned long goal, unsigned long limit, u32 flags)
>>   {
>> -	void *mem = ___alloc_bootmem_nopanic(size, align, goal, limit);
>> +	void *mem = ___alloc_bootmem_nopanic(size, align, goal, limit, flags);
>>     	if (mem)
>>   		return mem;
>> @@ -284,25 +287,26 @@ void * __init __alloc_bootmem(unsigned l
>>   {
>>   	unsigned long limit = -1UL;
>>   -	return ___alloc_bootmem(size, align, goal, limit);
>> +	return ___alloc_bootmem(size, align, goal, limit, 0);
>>   }
>>     void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
>>   						   unsigned long size,
>>   						   unsigned long align,
>>   						   unsigned long goal,
>> -						   unsigned long limit)
>> +						   unsigned long limit,
>> +						   u32 flags)
>>   {
>>   	void *ptr;
>>     again:
>>   	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
>> -					goal, limit);
>> +					goal, limit, flags);
>>   	if (ptr)
>>   		return ptr;
>>     	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
>> -					goal, limit);
>> +					goal, limit, flags);
>>   	if (ptr)
>>   		return ptr;
>>   @@ -315,12 +319,13 @@ again:
>>   }
>>     void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, 
>> unsigned long size,
>> -				   unsigned long align, unsigned long goal)
>> +			unsigned long align, unsigned long goal, u32 flags)
>>   {
>>   	if (WARN_ON_ONCE(slab_is_available()))
>>   		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
>>   -	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0);
>> +	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal,
>> +			0, flags);
>>   }
>>     void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long 
>> size,
>> @@ -329,7 +334,7 @@ void * __init ___alloc_bootmem_node(pg_d
>>   {
>>   	void *ptr;
>>   -	ptr = ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 
>> limit);
>> +	ptr = ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, limit, 0);
>>   	if (ptr)
>>   		return ptr;
>>   @@ -354,7 +359,7 @@ void * __init ___alloc_bootmem_node(pg_d
>>    * The function panics if the request can not be satisfied.
>>    */
>>   void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
>> -				   unsigned long align, unsigned long goal)
>> +			unsigned long align, unsigned long goal)
>>   {
>>   	if (WARN_ON_ONCE(slab_is_available()))
>>   		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
>> @@ -388,7 +393,7 @@ void * __init __alloc_bootmem_node_high(
>>   void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
>>   				  unsigned long goal)
>>   {
>> -	return ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT);
>> +	return ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT, 0);
>>   }
>>     void * __init __alloc_bootmem_low_nopanic(unsigned long size,
>> @@ -396,7 +401,7 @@ void * __init __alloc_bootmem_low_nopani
>>   					  unsigned long goal)
>>   {
>>   	return ___alloc_bootmem_nopanic(size, align, goal,
>> -					ARCH_LOW_ADDRESS_LIMIT);
>> +					ARCH_LOW_ADDRESS_LIMIT, 0);
>>   }
>>     /**
>> Index: linux/mm/sparse.c
>> ===================================================================
>> --- linux.orig/mm/sparse.c
>> +++ linux/mm/sparse.c
>> @@ -281,7 +281,7 @@ sparse_early_usemaps_alloc_pgdat_section
>>   	nid = early_pfn_to_nid(goal >> PAGE_SHIFT);
>>   again:
>>   	p = ___alloc_bootmem_node_nopanic(NODE_DATA(nid), size,
>> -					  SMP_CACHE_BYTES, goal, limit);
>> +					  SMP_CACHE_BYTES, goal, limit, 0);
>>   	if (!p && limit) {
>>   		limit = 0;
>>   		goto again;
>> Index: linux/mm/hugetlb.c
>> ===================================================================
>> --- linux.orig/mm/hugetlb.c
>> +++ linux/mm/hugetlb.c
>> @@ -1188,7 +1188,8 @@ int __weak alloc_bootmem_huge_page(struc
>>   		addr = __alloc_bootmem_node_nopanic(
>>   				NODE_DATA(hstate_next_node_to_alloc(h,
>>   						&node_states[N_MEMORY])),
>> -				huge_page_size(h), huge_page_size(h), 0);
>> +				huge_page_size(h), huge_page_size(h),
>> +				0, NO_ZERO);
>>     		if (addr) {
>>   			/*
>> Index: linux/mm/bootmem.c
>> ===================================================================
>> --- linux.orig/mm/bootmem.c
>> +++ linux/mm/bootmem.c
>> @@ -660,7 +660,7 @@ restart:
>>    * Returns NULL on failure.
>>    */
>>   void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
>> -					unsigned long goal)
>> +					unsigned long goal, u32 flags)
>>   {
>>   	unsigned long limit = 0;
>>   @@ -705,7 +705,8 @@ void * __init __alloc_bootmem(unsigned l
>>     void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
>>   				unsigned long size, unsigned long align,
>> -				unsigned long goal, unsigned long limit)
>> +				unsigned long goal, unsigned long limit,
>> +				u32 flags)
>>   {
>>   	void *ptr;
>>   @@ -734,12 +735,13 @@ again:
>>   }
>>     void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, 
>> unsigned long size,
>> -				   unsigned long align, unsigned long goal)
>> +			unsigned long align, unsigned long goal, u32 flags)
>>   {
>>   	if (WARN_ON_ONCE(slab_is_available()))
>>   		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
>>   -	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0);
>> +	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal,
>> +					     0, flags);
>>   }
>>     void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long 
>> size,
>> @@ -748,7 +750,7 @@ void * __init ___alloc_bootmem_node(pg_d
>>   {
>>   	void *ptr;
>>   -	ptr = ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0);
>> +	ptr = ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0, 0);
>>   	if (ptr)
>>   		return ptr;
>>   Index: linux/mm/page_cgroup.c
>> ===================================================================
>> --- linux.orig/mm/page_cgroup.c
>> +++ linux/mm/page_cgroup.c
>> @@ -55,7 +55,7 @@ static int __init alloc_node_page_cgroup
>>   	table_size = sizeof(struct page_cgroup) * nr_pages;
>>     	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
>> -			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
>> +			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS), 0);
>>   	if (!base)
>>   		return -ENOMEM;
>>   	NODE_DATA(nid)->node_page_cgroup = base;
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Cliff Wickman
SGI
cpw@sgi.com
(651) 683-3824

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
