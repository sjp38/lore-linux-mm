Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8850B6B0260
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:59:20 -0500 (EST)
Received: by wmdw130 with SMTP id w130so124647985wmd.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:59:20 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id w191si23866263wme.107.2015.11.16.10.59.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Nov 2015 10:59:19 -0800 (PST)
Date: Mon, 16 Nov 2015 18:58:59 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2 01/12] mm/memblock: add MEMBLOCK_NOMAP attribute to
 memblock memory table
Message-ID: <20151116185859.GF8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
 <1447698757-8762-2-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447698757-8762-2-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, matt.fleming@intel.com, will.deacon@arm.com, grant.likely@linaro.org, catalin.marinas@arm.com, mark.rutland@arm.com, leif.lindholm@linaro.org, roy.franz@linaro.org, msalter@redhat.com, ryan.harkin@linaro.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon, Nov 16, 2015 at 07:32:26PM +0100, Ard Biesheuvel wrote:
> This introduces the MEMBLOCK_NOMAP attribute and the required plumbing
> to make it usable as an indicator that some parts of normal memory
> should not be covered by the kernel direct mapping. It is up to the
> arch to actually honor the attribute when laying out this mapping,
> but the memblock code itself is modified to disregard these regions
> for allocations and other general use.

What does NOMAP mean for the rest of the kernel?  Does this mean the
memory is never handed over to the kernel page allocators for kernel
use - in a similar way to what we do with arm_memblock_steal() ?

> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  include/linux/memblock.h |  8 ++++++
>  mm/memblock.c            | 28 ++++++++++++++++++++
>  2 files changed, 36 insertions(+)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 24daf8fc4d7c..fec66f86eeff 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -25,6 +25,7 @@ enum {
>  	MEMBLOCK_NONE		= 0x0,	/* No special request */
>  	MEMBLOCK_HOTPLUG	= 0x1,	/* hotpluggable region */
>  	MEMBLOCK_MIRROR		= 0x2,	/* mirrored region */
> +	MEMBLOCK_NOMAP		= 0x4,	/* don't add to kernel direct mapping */
>  };
>  
>  struct memblock_region {
> @@ -82,6 +83,7 @@ bool memblock_overlaps_region(struct memblock_type *type,
>  int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
>  int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
>  int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
> +int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
>  ulong choose_memblock_flags(void);
>  
>  /* Low level functions */
> @@ -184,6 +186,11 @@ static inline bool memblock_is_mirror(struct memblock_region *m)
>  	return m->flags & MEMBLOCK_MIRROR;
>  }
>  
> +static inline bool memblock_is_nomap(struct memblock_region *m)
> +{
> +	return m->flags & MEMBLOCK_NOMAP;
> +}
> +
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
>  			    unsigned long  *end_pfn);
> @@ -319,6 +326,7 @@ phys_addr_t memblock_start_of_DRAM(void);
>  phys_addr_t memblock_end_of_DRAM(void);
>  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
>  int memblock_is_memory(phys_addr_t addr);
> +int memblock_is_map_memory(phys_addr_t addr);
>  int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
>  int memblock_is_reserved(phys_addr_t addr);
>  bool memblock_is_region_reserved(phys_addr_t base, phys_addr_t size);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index d300f1329814..07ff069fef25 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -822,6 +822,17 @@ int __init_memblock memblock_mark_mirror(phys_addr_t base, phys_addr_t size)
>  	return memblock_setclr_flag(base, size, 1, MEMBLOCK_MIRROR);
>  }
>  
> +/**
> + * memblock_mark_nomap - Mark a memory region with flag MEMBLOCK_NOMAP.
> + * @base: the base phys addr of the region
> + * @size: the size of the region
> + *
> + * Return 0 on success, -errno on failure.
> + */
> +int __init_memblock memblock_mark_nomap(phys_addr_t base, phys_addr_t size)
> +{
> +	return memblock_setclr_flag(base, size, 1, MEMBLOCK_NOMAP);
> +}
>  
>  /**
>   * __next_reserved_mem_region - next function for for_each_reserved_region()
> @@ -913,6 +924,10 @@ void __init_memblock __next_mem_range(u64 *idx, int nid, ulong flags,
>  		if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(m))
>  			continue;
>  
> +		/* skip nomap memory unless we were asked for it explicitly */
> +		if (!(flags & MEMBLOCK_NOMAP) && memblock_is_nomap(m))
> +			continue;
> +
>  		if (!type_b) {
>  			if (out_start)
>  				*out_start = m_start;
> @@ -1022,6 +1037,10 @@ void __init_memblock __next_mem_range_rev(u64 *idx, int nid, ulong flags,
>  		if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(m))
>  			continue;
>  
> +		/* skip nomap memory unless we were asked for it explicitly */
> +		if (!(flags & MEMBLOCK_NOMAP) && memblock_is_nomap(m))
> +			continue;
> +
>  		if (!type_b) {
>  			if (out_start)
>  				*out_start = m_start;
> @@ -1519,6 +1538,15 @@ int __init_memblock memblock_is_memory(phys_addr_t addr)
>  	return memblock_search(&memblock.memory, addr) != -1;
>  }
>  
> +int __init_memblock memblock_is_map_memory(phys_addr_t addr)
> +{
> +	int i = memblock_search(&memblock.memory, addr);
> +
> +	if (i == -1)
> +		return false;
> +	return !memblock_is_nomap(&memblock.memory.regions[i]);
> +}
> +
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  int __init_memblock memblock_search_pfn_nid(unsigned long pfn,
>  			 unsigned long *start_pfn, unsigned long *end_pfn)
> -- 
> 1.9.1
> 

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
