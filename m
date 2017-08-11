Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECBFD6B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 05:32:53 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id q50so4243984wrb.14
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 02:32:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f131si475065wmd.265.2017.08.11.02.32.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Aug 2017 02:32:52 -0700 (PDT)
Date: Fri, 11 Aug 2017 11:32:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 04/15] mm: discard memblock data later
Message-ID: <20170811093249.GE30811@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-5-git-send-email-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502138329-123460-5-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, Mel Gorman <mgorman@suse.de>

[CC Mel]

On Mon 07-08-17 16:38:38, Pavel Tatashin wrote:
> There is existing use after free bug when deferred struct pages are
> enabled:
> 
> The memblock_add() allocates memory for the memory array if more than
> 128 entries are needed.  See comment in e820__memblock_setup():
> 
>   * The bootstrap memblock region count maximum is 128 entries
>   * (INIT_MEMBLOCK_REGIONS), but EFI might pass us more E820 entries
>   * than that - so allow memblock resizing.
> 
> This memblock memory is freed here:
>         free_low_memory_core_early()
> 
> We access the freed memblock.memory later in boot when deferred pages are
> initialized in this path:
> 
>         deferred_init_memmap()
>                 for_each_mem_pfn_range()
>                   __next_mem_pfn_range()
>                     type = &memblock.memory;

Yes you seem to be right.
>
> One possible explanation for why this use-after-free hasn't been hit
> before is that the limit of INIT_MEMBLOCK_REGIONS has never been exceeded
> at least on systems where deferred struct pages were enabled.

Yeah this sounds like the case.
 
> Another reason why we want this problem fixed in this patch series is,
> in the next patch, we will need to access memblock.reserved from
> deferred_init_memmap().
> 

I guess this goes all the way down to 
Fixes: 7e18adb4f80b ("mm: meminit: initialise remaining struct pages in parallel with kswapd")
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Bob Picco <bob.picco@oracle.com>

Considering that some HW might behave strangely and this would be rather
hard to debug I would be tempted to mark this for stable. It should also
be merged separately from the rest of the series.

I have just one nit below
Acked-by: Michal Hocko <mhocko@suse.com>

[...]
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 2cb25fe4452c..bf14aea6ab70 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -285,31 +285,27 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
>  }
>  
>  #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK

pull this ifdef inside memblock_discard and you do not have an another
one in page_alloc_init_late

[...]
> +/**
> + * Discard memory and reserved arrays if they were allocated
> + */
> +void __init memblock_discard(void)
>  {

here

> -	if (memblock.memory.regions == memblock_memory_init_regions)
> -		return 0;
> +	phys_addr_t addr, size;
>  
> -	*addr = __pa(memblock.memory.regions);
> +	if (memblock.reserved.regions != memblock_reserved_init_regions) {
> +		addr = __pa(memblock.reserved.regions);
> +		size = PAGE_ALIGN(sizeof(struct memblock_region) *
> +				  memblock.reserved.max);
> +		__memblock_free_late(addr, size);
> +	}
>  
> -	return PAGE_ALIGN(sizeof(struct memblock_region) *
> -			  memblock.memory.max);
> +	if (memblock.memory.regions == memblock_memory_init_regions) {
> +		addr = __pa(memblock.memory.regions);
> +		size = PAGE_ALIGN(sizeof(struct memblock_region) *
> +				  memblock.memory.max);
> +		__memblock_free_late(addr, size);
> +	}
>  }
> -
>  #endif
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index fc32aa81f359..63d16c185736 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1584,6 +1584,10 @@ void __init page_alloc_init_late(void)
>  	/* Reinit limits that are based on free pages after the kernel is up */
>  	files_maxfiles_init();
>  #endif
> +#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> +	/* Discard memblock private memory */
> +	memblock_discard();
> +#endif
>  
>  	for_each_populated_zone(zone)
>  		set_zone_contiguous(zone);
> -- 
> 2.14.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
