Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 420106B00B5
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 04:19:22 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id z11so10982932lbi.6
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 01:19:21 -0800 (PST)
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id e9si22640018wiv.77.2015.01.06.01.19.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 01:19:21 -0800 (PST)
Received: by mail-wg0-f49.google.com with SMTP id n12so29023594wgh.36
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 01:19:20 -0800 (PST)
Date: Tue, 6 Jan 2015 09:19:18 +0000
From: Matt Fleming <matt@console-pimps.org>
Subject: Re: [PATCH 4/8] memblock: introduce memblock_add_phys() and
 memblock_is_physmem()
Message-ID: <20150106091918.GI3163@console-pimps.org>
References: <1419275322-29811-1-git-send-email-ard.biesheuvel@linaro.org>
 <1419275322-29811-5-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1419275322-29811-5-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, roy.franz@linaro.org, mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com, matt.fleming@intel.com, bp@alien8.de, dyoung@redhat.com, msalter@redhat.com, grant.likely@linaro.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(Moar reviewers)

On Mon, 22 Dec, at 07:08:38PM, Ard Biesheuvel wrote:
> This introduces the following functions:
> - memblock_add_phys(), that registers regions in the 'physmem' memblock map if
>   CONFIG_HAVE_MEMBLOCK_PHYS_MAP is set; otherwise, it is a nop
> - memblock_is_physmem(), returns whether a physical address is classified as
>   physical memory.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  include/linux/memblock.h | 10 ++++++++++
>  mm/memblock.c            | 15 +++++++++++++++
>  2 files changed, 25 insertions(+)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index e8cc45307f8f..d32fe838c6ca 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -365,6 +365,16 @@ static inline unsigned long memblock_region_reserved_end_pfn(const struct memblo
>  #define __initdata_memblock
>  #endif
>  
> +#ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
> +int memblock_add_phys(phys_addr_t base, phys_addr_t size);
> +int memblock_is_physmem(phys_addr_t addr);
> +#else
> +static inline int memblock_add_phys(phys_addr_t base, phys_addr_t size)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_HAVE_MEMBLOCK_PHYS_MAP */
> +
>  #else
>  static inline phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align)
>  {
> diff --git a/mm/memblock.c b/mm/memblock.c
> index c27353beb260..107aa5ee2d7b 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -586,6 +586,14 @@ int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
>  				   MAX_NUMNODES, 0);
>  }
>  
> +#ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
> +int __init_memblock memblock_add_phys(phys_addr_t base, phys_addr_t size)
> +{
> +	return memblock_add_range(&memblock.physmem, base, size,
> +				  MAX_NUMNODES, 0);
> +}
> +#endif
> +
>  /**
>   * memblock_isolate_range - isolate given range into disjoint memblocks
>   * @type: memblock type to isolate range for
> @@ -1398,6 +1406,13 @@ int __init_memblock memblock_is_memory(phys_addr_t addr)
>  	return memblock_search(&memblock.memory, addr) != -1;
>  }
>  
> +#ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
> +int __init_memblock memblock_is_physmem(phys_addr_t addr)
> +{
> +	return memblock_search(&memblock.physmem, addr) != -1;
> +}
> +#endif
> +
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  int __init_memblock memblock_search_pfn_nid(unsigned long pfn,
>  			 unsigned long *start_pfn, unsigned long *end_pfn)
> -- 
> 1.8.3.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-efi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Matt Fleming, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
