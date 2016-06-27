Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 72E656B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 10:28:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so403290986pfa.1
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 07:28:27 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 81si26953175pfw.133.2016.06.27.07.28.26
        for <linux-mm@kvack.org>;
        Mon, 27 Jun 2016 07:28:26 -0700 (PDT)
Date: Mon, 27 Jun 2016 15:28:19 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v3 1/2] mm: memblock Add some new functions to address
 the mem limit issue
Message-ID: <20160627142818.GI1113@leverpostej>
References: <1466994431-6214-1-git-send-email-dennis.chen@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466994431-6214-1-git-send-email-dennis.chen@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Chen <dennis.chen@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, nd@arm.com, Catalin Marinas <catalin.marinas@arm.com>, Steve Capper <steve.capper@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-efi@vger.kernel.org

On Mon, Jun 27, 2016 at 10:27:10AM +0800, Dennis Chen wrote:
> In some cases, memblock is queried to determine whether a physical
> address corresponds to memory present in a system even if unused by
> the OS for the linear mapping, highmem, etc. For example, the ACPI
> core needs this information to determine which attributes to use when
> mapping ACPI regions. Use of incorrect memory types can result in
> faults, data corruption, or other issues.
> 
> Removing memory with memblock_enforce_memory_limit throws away this
> information, and so a kernel booted with 'mem=' may suffers from the
> issues described above. To avoid this, we need to keep those NOMAP
> regions instead of removing all above limit, which preserves the
> information we need while preventing other use of the regions.
> 
> This patch adds new insfrastructure to retain all NOMAP memblock regions
> while removing others, to cater for this.
> 
> At last, we add 'size' and 'flag' debug output in the memblock debugfs
> for ease of the memblock debug.
> The '/sys/kernel/debug/memblock/memory' output looks like before:
>    0: 0x0000008000000000..0x0000008001e7ffff
>    1: 0x0000008001e80000..0x00000083ff184fff
>    2: 0x00000083ff185000..0x00000083ff1c2fff
>    3: 0x00000083ff1c3000..0x00000083ff222fff
>    4: 0x00000083ff223000..0x00000083ffe42fff
>    5: 0x00000083ffe43000..0x00000083ffffffff
> 
> After applied:
>    0: 0x0000008000000000..0x0000008001e7ffff  0x0000000001e80000  0x4
>    1: 0x0000008001e80000..0x00000083ff184fff  0x00000003fd305000  0x0
>    2: 0x00000083ff185000..0x00000083ff1c2fff  0x000000000003e000  0x4
>    3: 0x00000083ff1c3000..0x00000083ff222fff  0x0000000000060000  0x0
>    4: 0x00000083ff223000..0x00000083ffe42fff  0x0000000000c20000  0x4
>    5: 0x00000083ffe43000..0x00000083ffffffff  0x00000000001bd000  0x0

The debugfs changes should be a separate patch. Even if they're useful
for debugging this patch, they're logically independent.

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
>  include/linux/memblock.h |  1 +
>  mm/memblock.c            | 55 +++++++++++++++++++++++++++++++++++++++++-------
>  2 files changed, 48 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 6c14b61..2925da2 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -332,6 +332,7 @@ phys_addr_t memblock_mem_size(unsigned long limit_pfn);
>  phys_addr_t memblock_start_of_DRAM(void);
>  phys_addr_t memblock_end_of_DRAM(void);
>  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
> +void memblock_mem_limit_remove_map(phys_addr_t limit);
>  bool memblock_is_memory(phys_addr_t addr);
>  int memblock_is_map_memory(phys_addr_t addr);
>  int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index ca09915..8099f1a 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1465,14 +1465,11 @@ phys_addr_t __init_memblock memblock_end_of_DRAM(void)
>  	return (memblock.memory.regions[idx].base + memblock.memory.regions[idx].size);
>  }
>  
> -void __init memblock_enforce_memory_limit(phys_addr_t limit)
> +static phys_addr_t __init_memblock __find_max_addr(phys_addr_t limit)
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
> @@ -1482,6 +1479,20 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
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
> +	if (max_addr == (phys_addr_t)ULLONG_MAX)
> +		return;

We didn't previously return early, so do we actually need this check?

> +
>  	/* truncate both memory and reserved regions */
>  	memblock_remove_range(&memblock.memory, max_addr,
>  			      (phys_addr_t)ULLONG_MAX);
> @@ -1489,6 +1500,32 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
>  			      (phys_addr_t)ULLONG_MAX);
>  }
>  
> +void __init memblock_mem_limit_remove_map(phys_addr_t limit)
> +{
> +	struct memblock_type *type = &memblock.memory;
> +	phys_addr_t max_addr;
> +	int i, ret, start_rgn, end_rgn;
> +
> +	if (!limit)
> +		return;
> +
> +	max_addr = __find_max_addr(limit);
> +	if (max_addr == (phys_addr_t)ULLONG_MAX)
> +		return;

Likewise?

> +
> +	ret = memblock_isolate_range(type, max_addr, (phys_addr_t)ULLONG_MAX,
> +					&start_rgn, &end_rgn);
> +	if (ret) {
> +		WARN_ONCE(1, "Mem limit failed, will not be applied!\n");
> +		return;
> +	}

We don't have a similar warning in memblock_enforce_memory_limit, where
memblock_remove_range() might return an error code from an internal call
to memblock_isolate_range.

The two should be consistent, either both with a message or both
without.

> +
> +	for (i = end_rgn - 1; i >= start_rgn; i--) {
> +		if (!memblock_is_nomap(&type->regions[i]))
> +			memblock_remove_region(type, i);
> +	}
> +}

This will preserve nomap regions, but it does mean that we may preserve
less memory that the user asked for, since __find_max_addr counted nomap
(and reserved) regions. Given we've always counted the latter, maybe
that's ok.

We should clarify what __find_max_addr is intended to determine, with a
comment, so as to avoid future ambiguity there.

> +
>  static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
>  {
>  	unsigned int left = 0, right = type->cnt;
> @@ -1677,13 +1714,15 @@ static int memblock_debug_show(struct seq_file *m, void *private)
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

As mentioned above, this should be a separate patch. I have no strong
feelings either way about the logic itself.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
