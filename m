Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2176B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 06:16:18 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 127so720482670pfg.5
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 03:16:18 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l3si1817301pld.312.2017.01.10.03.16.17
        for <linux-mm@kvack.org>;
        Tue, 10 Jan 2017 03:16:17 -0800 (PST)
Date: Tue, 10 Jan 2017 11:16:18 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v29 1/9] memblock: add memblock_cap_memory_range()
Message-ID: <20170110111617.GB21598@arm.com>
References: <20161228043347.27358-1-takahiro.akashi@linaro.org>
 <20161228043525.27420-1-takahiro.akashi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161228043525.27420-1-takahiro.akashi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: AKASHI Takahiro <takahiro.akashi@linaro.org>
Cc: catalin.marinas@arm.com, akpm@linux-foundation.org, james.morse@arm.com, geoff@infradead.org, bauerman@linux.vnet.ibm.com, dyoung@redhat.com, mark.rutland@arm.com, kexec@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, kuleshovmail@gmail.com, zijun_hu@htc.com, tj@kernel.org, dennis.chen@arm.com

[adding some more folks to cc]

On Wed, Dec 28, 2016 at 01:35:25PM +0900, AKASHI Takahiro wrote:
> Add memblock_cap_memory_range() which will remove all the memblock regions
> except the memory range specified in the arguments. In addition, rework is
> done on memblock_mem_limit_remove_map() to re-implement it using
> memblock_cap_memory_range().
> 
> This function, like memblock_mem_limit_remove_map(), will not remove
> memblocks with MEMMAP_NOMAP attribute as they may be mapped and accessed
> later as "device memory."
> See the commit a571d4eb55d8 ("mm/memblock.c: add new infrastructure to
> address the mem limit issue").
> 
> This function is used, in a succeeding patch in the series of arm64 kdump
> suuport, to limit the range of usable memory, or System RAM, on crash dump
> kernel.
> (Please note that "mem=" parameter is of little use for this purpose.)
> 
> Signed-off-by: AKASHI Takahiro <takahiro.akashi@linaro.org>
> Reviewed-by: Will Deacon <will.deacon@arm.com>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/memblock.h |  1 +
>  mm/memblock.c            | 44 +++++++++++++++++++++++++++++---------------
>  2 files changed, 30 insertions(+), 15 deletions(-)

Whilst this patch looks fine to me, it would be nice if Dennis (author of
memblock_mem_limit_remove_map) or one of the mm chaps could provide an ack
before I merge it via arm64.

Thanks,

Will

> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 5b759c9acf97..fbfcacc50c29 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -333,6 +333,7 @@ phys_addr_t memblock_mem_size(unsigned long limit_pfn);
>  phys_addr_t memblock_start_of_DRAM(void);
>  phys_addr_t memblock_end_of_DRAM(void);
>  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
> +void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
>  void memblock_mem_limit_remove_map(phys_addr_t limit);
>  bool memblock_is_memory(phys_addr_t addr);
>  int memblock_is_map_memory(phys_addr_t addr);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7608bc305936..fea1688fef60 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1514,11 +1514,37 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
>  			      (phys_addr_t)ULLONG_MAX);
>  }
>  
> +void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
> +{
> +	int start_rgn, end_rgn;
> +	int i, ret;
> +
> +	if (!size)
> +		return;
> +
> +	ret = memblock_isolate_range(&memblock.memory, base, size,
> +						&start_rgn, &end_rgn);
> +	if (ret)
> +		return;
> +
> +	/* remove all the MAP regions */
> +	for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
> +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> +			memblock_remove_region(&memblock.memory, i);
> +
> +	for (i = start_rgn - 1; i >= 0; i--)
> +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> +			memblock_remove_region(&memblock.memory, i);
> +
> +	/* truncate the reserved regions */
> +	memblock_remove_range(&memblock.reserved, 0, base);
> +	memblock_remove_range(&memblock.reserved,
> +			base + size, (phys_addr_t)ULLONG_MAX);
> +}
> +
>  void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>  {
> -	struct memblock_type *type = &memblock.memory;
>  	phys_addr_t max_addr;
> -	int i, ret, start_rgn, end_rgn;
>  
>  	if (!limit)
>  		return;
> @@ -1529,19 +1555,7 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>  	if (max_addr == (phys_addr_t)ULLONG_MAX)
>  		return;
>  
> -	ret = memblock_isolate_range(type, max_addr, (phys_addr_t)ULLONG_MAX,
> -				&start_rgn, &end_rgn);
> -	if (ret)
> -		return;
> -
> -	/* remove all the MAP regions above the limit */
> -	for (i = end_rgn - 1; i >= start_rgn; i--) {
> -		if (!memblock_is_nomap(&type->regions[i]))
> -			memblock_remove_region(type, i);
> -	}
> -	/* truncate the reserved regions */
> -	memblock_remove_range(&memblock.reserved, max_addr,
> -			      (phys_addr_t)ULLONG_MAX);
> +	memblock_cap_memory_range(0, max_addr);
>  }
>  
>  static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
> -- 
> 2.11.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
