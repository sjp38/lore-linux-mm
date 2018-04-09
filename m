Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A48066B0006
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 03:15:18 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id z2-v6so6490508plk.3
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 00:15:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l11si2716603pfi.200.2018.04.09.00.15.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 00:15:17 -0700 (PDT)
Date: Mon, 9 Apr 2018 09:15:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memblock: introduce PHYS_ADDR_MAX
Message-ID: <20180409071514.GC21835@dhcp22.suse.cz>
References: <20180406213809.566-1-stefan@agner.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180406213809.566-1-stefan@agner.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Agner <stefan@agner.ch>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, torvalds@linux-foundation.org, pasha.tatashin@oracle.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 06-04-18 23:38:09, Stefan Agner wrote:
> So far code was using ULLONG_MAX and type casting to obtain a
> phys_addr_t with all bits set. The typecast is necessary to
> silence compiler warnings on 32-bit platforms.
> 
> Use the simpler but still type safe approach "~(phys_addr_t)0"
> to create a preprocessor define for all bits set.
> 
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Stefan Agner <stefan@agner.ch>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> Hi,
> 
> There are about a dozen other instances of (phys_addr_t)ULLONG_MAX
> accross the tree. Should I address them too?

Yes, please. Maybe wait until the merge window sattles (rc1).

> --
> Stefan
> 
>  include/linux/kernel.h |  1 +
>  mm/memblock.c          | 22 +++++++++++-----------
>  2 files changed, 12 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index 3fd291503576..1ba9e2d71bc9 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -29,6 +29,7 @@
>  #define LLONG_MIN	(-LLONG_MAX - 1)
>  #define ULLONG_MAX	(~0ULL)
>  #define SIZE_MAX	(~(size_t)0)
> +#define PHYS_ADDR_MAX	(~(phys_addr_t)0)
>  
>  #define U8_MAX		((u8)~0U)
>  #define S8_MAX		((s8)(U8_MAX>>1))
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 696829a198ba..957587178b36 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -67,7 +67,7 @@ ulong __init_memblock choose_memblock_flags(void)
>  /* adjust *@size so that (@base + *@size) doesn't overflow, return new size */
>  static inline phys_addr_t memblock_cap_size(phys_addr_t base, phys_addr_t *size)
>  {
> -	return *size = min(*size, (phys_addr_t)ULLONG_MAX - base);
> +	return *size = min(*size, PHYS_ADDR_MAX - base);
>  }
>  
>  /*
> @@ -924,7 +924,7 @@ void __init_memblock __next_mem_range(u64 *idx, int nid, ulong flags,
>  			r = &type_b->regions[idx_b];
>  			r_start = idx_b ? r[-1].base + r[-1].size : 0;
>  			r_end = idx_b < type_b->cnt ?
> -				r->base : (phys_addr_t)ULLONG_MAX;
> +				r->base : PHYS_ADDR_MAX;
>  
>  			/*
>  			 * if idx_b advanced past idx_a,
> @@ -1040,7 +1040,7 @@ void __init_memblock __next_mem_range_rev(u64 *idx, int nid, ulong flags,
>  			r = &type_b->regions[idx_b];
>  			r_start = idx_b ? r[-1].base + r[-1].size : 0;
>  			r_end = idx_b < type_b->cnt ?
> -				r->base : (phys_addr_t)ULLONG_MAX;
> +				r->base : PHYS_ADDR_MAX;
>  			/*
>  			 * if idx_b advanced past idx_a,
>  			 * break out to advance idx_a
> @@ -1543,13 +1543,13 @@ phys_addr_t __init_memblock memblock_end_of_DRAM(void)
>  
>  static phys_addr_t __init_memblock __find_max_addr(phys_addr_t limit)
>  {
> -	phys_addr_t max_addr = (phys_addr_t)ULLONG_MAX;
> +	phys_addr_t max_addr = PHYS_ADDR_MAX;
>  	struct memblock_region *r;
>  
>  	/*
>  	 * translate the memory @limit size into the max address within one of
>  	 * the memory memblock regions, if the @limit exceeds the total size
> -	 * of those regions, max_addr will keep original value ULLONG_MAX
> +	 * of those regions, max_addr will keep original value PHYS_ADDR_MAX
>  	 */
>  	for_each_memblock(memory, r) {
>  		if (limit <= r->size) {
> @@ -1564,7 +1564,7 @@ static phys_addr_t __init_memblock __find_max_addr(phys_addr_t limit)
>  
>  void __init memblock_enforce_memory_limit(phys_addr_t limit)
>  {
> -	phys_addr_t max_addr = (phys_addr_t)ULLONG_MAX;
> +	phys_addr_t max_addr = PHYS_ADDR_MAX;
>  
>  	if (!limit)
>  		return;
> @@ -1572,14 +1572,14 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
>  	max_addr = __find_max_addr(limit);
>  
>  	/* @limit exceeds the total size of the memory, do nothing */
> -	if (max_addr == (phys_addr_t)ULLONG_MAX)
> +	if (max_addr == PHYS_ADDR_MAX)
>  		return;
>  
>  	/* truncate both memory and reserved regions */
>  	memblock_remove_range(&memblock.memory, max_addr,
> -			      (phys_addr_t)ULLONG_MAX);
> +			      PHYS_ADDR_MAX);
>  	memblock_remove_range(&memblock.reserved, max_addr,
> -			      (phys_addr_t)ULLONG_MAX);
> +			      PHYS_ADDR_MAX);
>  }
>  
>  void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
> @@ -1607,7 +1607,7 @@ void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
>  	/* truncate the reserved regions */
>  	memblock_remove_range(&memblock.reserved, 0, base);
>  	memblock_remove_range(&memblock.reserved,
> -			base + size, (phys_addr_t)ULLONG_MAX);
> +			base + size, PHYS_ADDR_MAX);
>  }
>  
>  void __init memblock_mem_limit_remove_map(phys_addr_t limit)
> @@ -1620,7 +1620,7 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>  	max_addr = __find_max_addr(limit);
>  
>  	/* @limit exceeds the total size of the memory, do nothing */
> -	if (max_addr == (phys_addr_t)ULLONG_MAX)
> +	if (max_addr == PHYS_ADDR_MAX)
>  		return;
>  
>  	memblock_cap_memory_range(0, max_addr);
> -- 
> 2.17.0
> 

-- 
Michal Hocko
SUSE Labs
