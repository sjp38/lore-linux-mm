Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id C72A66B025E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 08:57:55 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id b13so140250115pat.3
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 05:57:55 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z6si46005pas.133.2016.06.23.05.57.54
        for <linux-mm@kvack.org>;
        Thu, 23 Jun 2016 05:57:54 -0700 (PDT)
Date: Thu, 23 Jun 2016 13:57:48 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 1/2] mm: memblock Add some new functions to address the
 mem limit issue
Message-ID: <20160623125748.GF8836@leverpostej>
References: <1466681415-8058-1-git-send-email-dennis.chen@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466681415-8058-1-git-send-email-dennis.chen@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Chen <dennis.chen@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, nd@arm.com, Catalin Marinas <catalin.marinas@arm.com>, Steve Capper <steve.capper@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-efi@vger.kernel.org

On Thu, Jun 23, 2016 at 07:30:14PM +0800, Dennis Chen wrote:
> Two major changes in this patch:
> [1] Add memblock_mem_limit_mark_nomap(phys_addr_t limit) function to
> mark memblock regions above the @limit as NOMAP region, which will
> be used to address the observed 'mem=x' kernel parameter issue.
> 
> [2] Add 'size' and 'flag' debug output in the memblock debugfs.
> The '/sys/kernel/debug/memblock/memory' output looks like before:
>    0: 0x0000008000000000..0x0000008001e7ffff
>    1: 0x0000008001e80000..0x00000083ff184fff
>    2: 0x00000083ff185000..0x00000083ff1c2fff
>    3: 0x00000083ff1c3000..0x00000083ff222fff
>    4: 0x00000083ff223000..0x00000083ffe42fff
>    5: 0x00000083ffe43000..0x00000083ffffffff
> 
> With this patch applied:
>    0: 0x0000008000000000..0x0000008001e7ffff  0x0000000001e80000  0x4
>    1: 0x0000008001e80000..0x00000083ff184fff  0x00000003fd305000  0x0
>    2: 0x00000083ff185000..0x00000083ff1c2fff  0x000000000003e000  0x4
>    3: 0x00000083ff1c3000..0x00000083ff222fff  0x0000000000060000  0x0
>    4: 0x00000083ff223000..0x00000083ffe42fff  0x0000000000c20000  0x4
>    5: 0x00000083ffe43000..0x00000083ffffffff  0x00000000001bd000  0x0

Please explain in the commit message what the problem being solved is,
and how this solves it. e.g.

In some cases, memblock is queried to determine whether a physical
address corresponds to memory present in a system even if unused by the
OS for the linear mapping, highmem, etc. For example, the ACPI core
needs this information to determine which attributes to use when mapping
ACPI regions. Use of incorrect memory types can result in faults, data
corruption, or other issues.

Removing memory with memblock_enforce_memory_limit throws away this
information, and so a kernel booted with mem= may suffer from the issues
described above. To avoid this, we can mark regions as nomap rather than
removing them, which preserves the information we need while preventing
other use of the regions.

This patch adds new insfrastructure to mark all memblock regions in an
address range as nomap, to cater for this. Similarly we add
infrastructure to clear the flag for an address range, which makes
handling some overlap cases simpler.

Other than that, the patch itself looks fine to me.

Thanks,
Mark.

> Signed-off-by: Dennis Chen <dennis.chen@arm.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Steve Capper <steve.capper@arm.com>
> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Cc: Matt Fleming <matt@codeblueprint.co.uk>
> Cc: linux-mm@kvack.org
> Cc: linux-acpi@vger.kernel.org
> Cc: linux-efi@vger.kernel.org
> ---
>  include/linux/memblock.h |  2 ++
>  mm/memblock.c            | 50 ++++++++++++++++++++++++++++++++++++++++--------
>  2 files changed, 44 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 6c14b61..5e069c8 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -92,6 +92,7 @@ int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
>  int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
>  int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
>  int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
> +int memblock_clear_nomap(phys_addr_t base, phys_addr_t size);
>  ulong choose_memblock_flags(void);
>  
>  /* Low level functions */
> @@ -332,6 +333,7 @@ phys_addr_t memblock_mem_size(unsigned long limit_pfn);
>  phys_addr_t memblock_start_of_DRAM(void);
>  phys_addr_t memblock_end_of_DRAM(void);
>  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
> +void memblock_mem_limit_mark_nomap(phys_addr_t limit);
>  bool memblock_is_memory(phys_addr_t addr);
>  int memblock_is_map_memory(phys_addr_t addr);
>  int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index ca09915..60930ac 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -814,6 +814,18 @@ int __init_memblock memblock_mark_nomap(phys_addr_t base, phys_addr_t size)
>  }
>  
>  /**
> + * memblock_clear_nomap - Clear flag MEMBLOCK_NOMAP for a specified region.
> + * @base: the base phys addr of the region
> + * @size: the size of the region
> + *
> + * Return 0 on success, -errno on failure.
> + */
> +int __init_memblock memblock_clear_nomap(phys_addr_t base, phys_addr_t size)
> +{
> +	return memblock_setclr_flag(base, size, 0, MEMBLOCK_NOMAP);
> +}
> +
> +/**
>   * __next_reserved_mem_region - next function for for_each_reserved_region()
>   * @idx: pointer to u64 loop variable
>   * @out_start: ptr to phys_addr_t for start address of the region, can be %NULL
> @@ -1465,14 +1477,11 @@ phys_addr_t __init_memblock memblock_end_of_DRAM(void)
>  	return (memblock.memory.regions[idx].base + memblock.memory.regions[idx].size);
>  }
>  
> -void __init memblock_enforce_memory_limit(phys_addr_t limit)
> +static phys_addr_t __find_max_addr(phys_addr_t limit)
>  {
>  	phys_addr_t max_addr = (phys_addr_t)ULLONG_MAX;
>  	struct memblock_region *r;
>  
> -	if (!limit)
> -		return;
> -
>  	/* find out max address */
>  	for_each_memblock(memory, r) {
>  		if (limit <= r->size) {
> @@ -1482,6 +1491,18 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
>  		limit -= r->size;
>  	}
>  
> +	return max_addr;
> +}
> +
> +void __init memblock_enforce_memory_limit(phys_addr_t limit)
> +{
> +	phys_addr_t max_addr;
> +
> +	if (!limit)
> +		return;
> +
> +	max_addr = __find_max_addr(limit);
> +
>  	/* truncate both memory and reserved regions */
>  	memblock_remove_range(&memblock.memory, max_addr,
>  			      (phys_addr_t)ULLONG_MAX);
> @@ -1489,6 +1510,17 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
>  			      (phys_addr_t)ULLONG_MAX);
>  }
>  
> +void __init memblock_mem_limit_mark_nomap(phys_addr_t limit)
> +{
> +	phys_addr_t max_addr;
> +
> +	if (!limit)
> +		return;
> +
> +	max_addr = __find_max_addr(limit);
> +	memblock_mark_nomap(max_addr, (phys_addr_t)ULLONG_MAX);
> +}
> +
>  static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
>  {
>  	unsigned int left = 0, right = type->cnt;
> @@ -1677,13 +1709,15 @@ static int memblock_debug_show(struct seq_file *m, void *private)
>  		reg = &type->regions[i];
>  		seq_printf(m, "%4d: ", i);
>  		if (sizeof(phys_addr_t) == 4)
> -			seq_printf(m, "0x%08lx..0x%08lx\n",
> +			seq_printf(m, "0x%08lx..0x%08lx  0x%08lx  0x%lx\n",
>  				   (unsigned long)reg->base,
> -				   (unsigned long)(reg->base + reg->size - 1));
> +				   (unsigned long)(reg->base + reg->size - 1),
> +				   (unsigned long)reg->size, reg->flags);
>  		else
> -			seq_printf(m, "0x%016llx..0x%016llx\n",
> +			seq_printf(m, "0x%016llx..0x%016llx  0x%016llx  0x%lx\n",
>  				   (unsigned long long)reg->base,
> -				   (unsigned long long)(reg->base + reg->size - 1));
> +				   (unsigned long long)(reg->base + reg->size - 1),
> +				   (unsigned long long)reg->size, reg->flags);
>  
>  	}
>  	return 0;
> -- 
> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
