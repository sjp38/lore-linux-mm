Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67A046B77E7
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 04:56:10 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id t26-v6so5587804pfh.0
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 01:56:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k18-v6si4196487pgl.364.2018.09.06.01.56.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 01:56:09 -0700 (PDT)
Date: Thu, 6 Sep 2018 10:56:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 22/29] mm: nobootmem: remove bootmem allocation APIs
Message-ID: <20180906085607.GG14951@dhcp22.suse.cz>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-23-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536163184-26356-23-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:37, Mike Rapoport wrote:
> The bootmem compatibility APIs are not used and can be removed.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

I am happy to see this finally go
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/bootmem.h |  47 ----------
>  mm/nobootmem.c          | 224 ------------------------------------------------
>  2 files changed, 271 deletions(-)
> 
> diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
> index c97c105..73f1272 100644
> --- a/include/linux/bootmem.h
> +++ b/include/linux/bootmem.h
> @@ -36,33 +36,6 @@ extern void free_bootmem_node(pg_data_t *pgdat,
>  extern void free_bootmem(unsigned long physaddr, unsigned long size);
>  extern void free_bootmem_late(unsigned long physaddr, unsigned long size);
>  
> -extern void *__alloc_bootmem(unsigned long size,
> -			     unsigned long align,
> -			     unsigned long goal);
> -extern void *__alloc_bootmem_nopanic(unsigned long size,
> -				     unsigned long align,
> -				     unsigned long goal) __malloc;
> -extern void *__alloc_bootmem_node(pg_data_t *pgdat,
> -				  unsigned long size,
> -				  unsigned long align,
> -				  unsigned long goal) __malloc;
> -void *__alloc_bootmem_node_high(pg_data_t *pgdat,
> -				  unsigned long size,
> -				  unsigned long align,
> -				  unsigned long goal) __malloc;
> -extern void *__alloc_bootmem_node_nopanic(pg_data_t *pgdat,
> -				  unsigned long size,
> -				  unsigned long align,
> -				  unsigned long goal) __malloc;
> -void *___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
> -				  unsigned long size,
> -				  unsigned long align,
> -				  unsigned long goal,
> -				  unsigned long limit) __malloc;
> -extern void *__alloc_bootmem_low(unsigned long size,
> -				 unsigned long align,
> -				 unsigned long goal) __malloc;
> -
>  /* We are using top down, so it is safe to use 0 here */
>  #define BOOTMEM_LOW_LIMIT 0
>  
> @@ -70,26 +43,6 @@ extern void *__alloc_bootmem_low(unsigned long size,
>  #define ARCH_LOW_ADDRESS_LIMIT  0xffffffffUL
>  #endif
>  
> -#define alloc_bootmem(x) \
> -	__alloc_bootmem(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
> -#define alloc_bootmem_align(x, align) \
> -	__alloc_bootmem(x, align, BOOTMEM_LOW_LIMIT)
> -#define alloc_bootmem_pages(x) \
> -	__alloc_bootmem(x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
> -#define alloc_bootmem_pages_nopanic(x) \
> -	__alloc_bootmem_nopanic(x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
> -#define alloc_bootmem_node(pgdat, x) \
> -	__alloc_bootmem_node(pgdat, x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
> -#define alloc_bootmem_node_nopanic(pgdat, x) \
> -	__alloc_bootmem_node_nopanic(pgdat, x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
> -#define alloc_bootmem_pages_node(pgdat, x) \
> -	__alloc_bootmem_node(pgdat, x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
> -
> -#define alloc_bootmem_low(x) \
> -	__alloc_bootmem_low(x, SMP_CACHE_BYTES, 0)
> -#define alloc_bootmem_low_pages(x) \
> -	__alloc_bootmem_low(x, PAGE_SIZE, 0)
> -
>  /* FIXME: use MEMBLOCK_ALLOC_* variants here */
>  #define BOOTMEM_ALLOC_ACCESSIBLE	0
>  #define BOOTMEM_ALLOC_ANYWHERE		(~(phys_addr_t)0)
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index 44ce7de..bc38e56 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -33,41 +33,6 @@ unsigned long min_low_pfn;
>  unsigned long max_pfn;
>  unsigned long long max_possible_pfn;
>  
> -static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
> -					u64 goal, u64 limit)
> -{
> -	void *ptr;
> -	u64 addr;
> -	enum memblock_flags flags = choose_memblock_flags();
> -
> -	if (limit > memblock.current_limit)
> -		limit = memblock.current_limit;
> -
> -again:
> -	addr = memblock_find_in_range_node(size, align, goal, limit, nid,
> -					   flags);
> -	if (!addr && (flags & MEMBLOCK_MIRROR)) {
> -		flags &= ~MEMBLOCK_MIRROR;
> -		pr_warn("Could not allocate %pap bytes of mirrored memory\n",
> -			&size);
> -		goto again;
> -	}
> -	if (!addr)
> -		return NULL;
> -
> -	if (memblock_reserve(addr, size))
> -		return NULL;
> -
> -	ptr = phys_to_virt(addr);
> -	memset(ptr, 0, size);
> -	/*
> -	 * The min_count is set to 0 so that bootmem allocated blocks
> -	 * are never reported as leaks.
> -	 */
> -	kmemleak_alloc(ptr, size, 0, 0);
> -	return ptr;
> -}
> -
>  /**
>   * free_bootmem_late - free bootmem pages directly to page allocator
>   * @addr: starting address of the range
> @@ -215,192 +180,3 @@ void __init free_bootmem(unsigned long addr, unsigned long size)
>  {
>  	memblock_free(addr, size);
>  }
> -
> -static void * __init ___alloc_bootmem_nopanic(unsigned long size,
> -					unsigned long align,
> -					unsigned long goal,
> -					unsigned long limit)
> -{
> -	void *ptr;
> -
> -	if (WARN_ON_ONCE(slab_is_available()))
> -		return kzalloc(size, GFP_NOWAIT);
> -
> -restart:
> -
> -	ptr = __alloc_memory_core_early(NUMA_NO_NODE, size, align, goal, limit);
> -
> -	if (ptr)
> -		return ptr;
> -
> -	if (goal != 0) {
> -		goal = 0;
> -		goto restart;
> -	}
> -
> -	return NULL;
> -}
> -
> -/**
> - * __alloc_bootmem_nopanic - allocate boot memory without panicking
> - * @size: size of the request in bytes
> - * @align: alignment of the region
> - * @goal: preferred starting address of the region
> - *
> - * The goal is dropped if it can not be satisfied and the allocation will
> - * fall back to memory below @goal.
> - *
> - * Allocation may happen on any node in the system.
> - *
> - * Return: address of the allocated region or %NULL on failure.
> - */
> -void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
> -					unsigned long goal)
> -{
> -	unsigned long limit = -1UL;
> -
> -	return ___alloc_bootmem_nopanic(size, align, goal, limit);
> -}
> -
> -static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
> -					unsigned long goal, unsigned long limit)
> -{
> -	void *mem = ___alloc_bootmem_nopanic(size, align, goal, limit);
> -
> -	if (mem)
> -		return mem;
> -	/*
> -	 * Whoops, we cannot satisfy the allocation request.
> -	 */
> -	pr_alert("bootmem alloc of %lu bytes failed!\n", size);
> -	panic("Out of memory");
> -	return NULL;
> -}
> -
> -/**
> - * __alloc_bootmem - allocate boot memory
> - * @size: size of the request in bytes
> - * @align: alignment of the region
> - * @goal: preferred starting address of the region
> - *
> - * The goal is dropped if it can not be satisfied and the allocation will
> - * fall back to memory below @goal.
> - *
> - * Allocation may happen on any node in the system.
> - *
> - * The function panics if the request can not be satisfied.
> - *
> - * Return: address of the allocated region.
> - */
> -void * __init __alloc_bootmem(unsigned long size, unsigned long align,
> -			      unsigned long goal)
> -{
> -	unsigned long limit = -1UL;
> -
> -	return ___alloc_bootmem(size, align, goal, limit);
> -}
> -
> -void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
> -						   unsigned long size,
> -						   unsigned long align,
> -						   unsigned long goal,
> -						   unsigned long limit)
> -{
> -	void *ptr;
> -
> -again:
> -	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
> -					goal, limit);
> -	if (ptr)
> -		return ptr;
> -
> -	ptr = __alloc_memory_core_early(NUMA_NO_NODE, size, align,
> -					goal, limit);
> -	if (ptr)
> -		return ptr;
> -
> -	if (goal) {
> -		goal = 0;
> -		goto again;
> -	}
> -
> -	return NULL;
> -}
> -
> -void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
> -				   unsigned long align, unsigned long goal)
> -{
> -	if (WARN_ON_ONCE(slab_is_available()))
> -		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
> -
> -	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0);
> -}
> -
> -static void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
> -				    unsigned long align, unsigned long goal,
> -				    unsigned long limit)
> -{
> -	void *ptr;
> -
> -	ptr = ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, limit);
> -	if (ptr)
> -		return ptr;
> -
> -	pr_alert("bootmem alloc of %lu bytes failed!\n", size);
> -	panic("Out of memory");
> -	return NULL;
> -}
> -
> -/**
> - * __alloc_bootmem_node - allocate boot memory from a specific node
> - * @pgdat: node to allocate from
> - * @size: size of the request in bytes
> - * @align: alignment of the region
> - * @goal: preferred starting address of the region
> - *
> - * The goal is dropped if it can not be satisfied and the allocation will
> - * fall back to memory below @goal.
> - *
> - * Allocation may fall back to any node in the system if the specified node
> - * can not hold the requested memory.
> - *
> - * The function panics if the request can not be satisfied.
> - *
> - * Return: address of the allocated region.
> - */
> -void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
> -				   unsigned long align, unsigned long goal)
> -{
> -	if (WARN_ON_ONCE(slab_is_available()))
> -		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
> -
> -	return ___alloc_bootmem_node(pgdat, size, align, goal, 0);
> -}
> -
> -void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
> -				   unsigned long align, unsigned long goal)
> -{
> -	return __alloc_bootmem_node(pgdat, size, align, goal);
> -}
> -
> -
> -/**
> - * __alloc_bootmem_low - allocate low boot memory
> - * @size: size of the request in bytes
> - * @align: alignment of the region
> - * @goal: preferred starting address of the region
> - *
> - * The goal is dropped if it can not be satisfied and the allocation will
> - * fall back to memory below @goal.
> - *
> - * Allocation may happen on any node in the system.
> - *
> - * The function panics if the request can not be satisfied.
> - *
> - * Return: address of the allocated region.
> - */
> -void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
> -				  unsigned long goal)
> -{
> -	return ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT);
> -}
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
