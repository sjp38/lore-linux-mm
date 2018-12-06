Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9BD6B77D6
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 09:09:57 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id k125so303758pga.5
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 06:09:57 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m188si369741pfb.266.2018.12.06.06.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 06:09:55 -0800 (PST)
Date: Thu, 6 Dec 2018 06:09:48 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/34] powerpc: use mm zones more sensibly
Message-ID: <20181206140948.GB29741@infradead.org>
References: <20181114082314.8965-1-hch@lst.de>
 <20181114082314.8965-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114082314.8965-2-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Ben / Michael,

can we get this one queued up for 4.21 to prepare for the DMA work later
on?

On Wed, Nov 14, 2018 at 09:22:41AM +0100, Christoph Hellwig wrote:
> Powerpc has somewhat odd usage where ZONE_DMA is used for all memory on
> common 64-bit configfs, and ZONE_DMA32 is used for 31-bit schemes.
> 
> Move to a scheme closer to what other architectures use (and I dare to
> say the intent of the system):
> 
>  - ZONE_DMA: optionally for memory < 31-bit (64-bit embedded only)
>  - ZONE_NORMAL: everything addressable by the kernel
>  - ZONE_HIGHMEM: memory > 32-bit for 32-bit kernels
> 
> Also provide information on how ZONE_DMA is used by defining
> ARCH_ZONE_DMA_BITS.
> 
> Contains various fixes from Benjamin Herrenschmidt.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/powerpc/Kconfig                          |  8 +---
>  arch/powerpc/include/asm/page.h               |  2 +
>  arch/powerpc/include/asm/pgtable.h            |  1 -
>  arch/powerpc/kernel/dma-swiotlb.c             |  6 +--
>  arch/powerpc/kernel/dma.c                     |  7 +--
>  arch/powerpc/mm/mem.c                         | 47 +++++++------------
>  arch/powerpc/platforms/85xx/corenet_generic.c | 10 ----
>  arch/powerpc/platforms/85xx/qemu_e500.c       |  9 ----
>  include/linux/mmzone.h                        |  2 +-
>  9 files changed, 25 insertions(+), 67 deletions(-)
> 
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 8be31261aec8..cffff3613bc1 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -374,9 +374,9 @@ config PPC_ADV_DEBUG_DAC_RANGE
>  	depends on PPC_ADV_DEBUG_REGS && 44x
>  	default y
>  
> -config ZONE_DMA32
> +config ZONE_DMA
>  	bool
> -	default y if PPC64
> +	default y if PPC_BOOK3E_64
>  
>  config PGTABLE_LEVELS
>  	int
> @@ -869,10 +869,6 @@ config ISA
>  	  have an IBM RS/6000 or pSeries machine, say Y.  If you have an
>  	  embedded board, consult your board documentation.
>  
> -config ZONE_DMA
> -	bool
> -	default y
> -
>  config GENERIC_ISA_DMA
>  	bool
>  	depends on ISA_DMA_API
> diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
> index f6a1265face2..fc8c9ac0c6be 100644
> --- a/arch/powerpc/include/asm/page.h
> +++ b/arch/powerpc/include/asm/page.h
> @@ -354,4 +354,6 @@ typedef struct page *pgtable_t;
>  #endif /* __ASSEMBLY__ */
>  #include <asm/slice.h>
>  
> +#define ARCH_ZONE_DMA_BITS 31
> +
>  #endif /* _ASM_POWERPC_PAGE_H */
> diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
> index 9679b7519a35..8af32ce93c7f 100644
> --- a/arch/powerpc/include/asm/pgtable.h
> +++ b/arch/powerpc/include/asm/pgtable.h
> @@ -66,7 +66,6 @@ extern unsigned long empty_zero_page[];
>  
>  extern pgd_t swapper_pg_dir[];
>  
> -void limit_zone_pfn(enum zone_type zone, unsigned long max_pfn);
>  int dma_pfn_limit_to_zone(u64 pfn_limit);
>  extern void paging_init(void);
>  
> diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
> index 5fc335f4d9cd..678811abccfc 100644
> --- a/arch/powerpc/kernel/dma-swiotlb.c
> +++ b/arch/powerpc/kernel/dma-swiotlb.c
> @@ -108,12 +108,8 @@ int __init swiotlb_setup_bus_notifier(void)
>  
>  void __init swiotlb_detect_4g(void)
>  {
> -	if ((memblock_end_of_DRAM() - 1) > 0xffffffff) {
> +	if ((memblock_end_of_DRAM() - 1) > 0xffffffff)
>  		ppc_swiotlb_enable = 1;
> -#ifdef CONFIG_ZONE_DMA32
> -		limit_zone_pfn(ZONE_DMA32, (1ULL << 32) >> PAGE_SHIFT);
> -#endif
> -	}
>  }
>  
>  static int __init check_swiotlb_enabled(void)
> diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
> index dbfc7056d7df..6551685a4ed0 100644
> --- a/arch/powerpc/kernel/dma.c
> +++ b/arch/powerpc/kernel/dma.c
> @@ -50,7 +50,7 @@ static int dma_nommu_dma_supported(struct device *dev, u64 mask)
>  		return 1;
>  
>  #ifdef CONFIG_FSL_SOC
> -	/* Freescale gets another chance via ZONE_DMA/ZONE_DMA32, however
> +	/* Freescale gets another chance via ZONE_DMA, however
>  	 * that will have to be refined if/when they support iommus
>  	 */
>  	return 1;
> @@ -94,13 +94,10 @@ void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
>  	}
>  
>  	switch (zone) {
> +#ifdef CONFIG_ZONE_DMA
>  	case ZONE_DMA:
>  		flag |= GFP_DMA;
>  		break;
> -#ifdef CONFIG_ZONE_DMA32
> -	case ZONE_DMA32:
> -		flag |= GFP_DMA32;
> -		break;
>  #endif
>  	};
>  #endif /* CONFIG_FSL_SOC */
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 0a64fffabee1..c0b676c3a5ba 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -246,35 +246,19 @@ static int __init mark_nonram_nosave(void)
>  }
>  #endif
>  
> -static bool zone_limits_final;
> -
>  /*
> - * The memory zones past TOP_ZONE are managed by generic mm code.
> - * These should be set to zero since that's what every other
> - * architecture does.
> + * Zones usage:
> + *
> + * We setup ZONE_DMA to be 31-bits on all platforms and ZONE_NORMAL to be
> + * everything else. GFP_DMA32 page allocations automatically fall back to
> + * ZONE_DMA.
> + *
> + * By using 31-bit unconditionally, we can exploit ARCH_ZONE_DMA_BITS to
> + * inform the generic DMA mapping code.  32-bit only devices (if not handled
> + * by an IOMMU anyway) will take a first dip into ZONE_NORMAL and get
> + * otherwise served by ZONE_DMA.
>   */
> -static unsigned long max_zone_pfns[MAX_NR_ZONES] = {
> -	[0            ... TOP_ZONE        ] = ~0UL,
> -	[TOP_ZONE + 1 ... MAX_NR_ZONES - 1] = 0
> -};
> -
> -/*
> - * Restrict the specified zone and all more restrictive zones
> - * to be below the specified pfn.  May not be called after
> - * paging_init().
> - */
> -void __init limit_zone_pfn(enum zone_type zone, unsigned long pfn_limit)
> -{
> -	int i;
> -
> -	if (WARN_ON(zone_limits_final))
> -		return;
> -
> -	for (i = zone; i >= 0; i--) {
> -		if (max_zone_pfns[i] > pfn_limit)
> -			max_zone_pfns[i] = pfn_limit;
> -	}
> -}
> +static unsigned long max_zone_pfns[MAX_NR_ZONES];
>  
>  /*
>   * Find the least restrictive zone that is entirely below the
> @@ -324,11 +308,14 @@ void __init paging_init(void)
>  	printk(KERN_DEBUG "Memory hole size: %ldMB\n",
>  	       (long int)((top_of_ram - total_ram) >> 20));
>  
> +#ifdef CONFIG_ZONE_DMA
> +	max_zone_pfns[ZONE_DMA]	= min(max_low_pfn, 0x7fffffffUL >> PAGE_SHIFT);
> +#endif
> +	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
>  #ifdef CONFIG_HIGHMEM
> -	limit_zone_pfn(ZONE_NORMAL, lowmem_end_addr >> PAGE_SHIFT);
> +	max_zone_pfns[ZONE_HIGHMEM] = max_pfn;
>  #endif
> -	limit_zone_pfn(TOP_ZONE, top_of_ram >> PAGE_SHIFT);
> -	zone_limits_final = true;
> +
>  	free_area_init_nodes(max_zone_pfns);
>  
>  	mark_nonram_nosave();
> diff --git a/arch/powerpc/platforms/85xx/corenet_generic.c b/arch/powerpc/platforms/85xx/corenet_generic.c
> index ac191a7a1337..b0dac307bebf 100644
> --- a/arch/powerpc/platforms/85xx/corenet_generic.c
> +++ b/arch/powerpc/platforms/85xx/corenet_generic.c
> @@ -68,16 +68,6 @@ void __init corenet_gen_setup_arch(void)
>  
>  	swiotlb_detect_4g();
>  
> -#if defined(CONFIG_FSL_PCI) && defined(CONFIG_ZONE_DMA32)
> -	/*
> -	 * Inbound windows don't cover the full lower 4 GiB
> -	 * due to conflicts with PCICSRBAR and outbound windows,
> -	 * so limit the DMA32 zone to 2 GiB, to allow consistent
> -	 * allocations to succeed.
> -	 */
> -	limit_zone_pfn(ZONE_DMA32, 1UL << (31 - PAGE_SHIFT));
> -#endif
> -
>  	pr_info("%s board\n", ppc_md.name);
>  
>  	mpc85xx_qe_init();
> diff --git a/arch/powerpc/platforms/85xx/qemu_e500.c b/arch/powerpc/platforms/85xx/qemu_e500.c
> index b63a8548366f..27631c607f3d 100644
> --- a/arch/powerpc/platforms/85xx/qemu_e500.c
> +++ b/arch/powerpc/platforms/85xx/qemu_e500.c
> @@ -45,15 +45,6 @@ static void __init qemu_e500_setup_arch(void)
>  
>  	fsl_pci_assign_primary();
>  	swiotlb_detect_4g();
> -#if defined(CONFIG_FSL_PCI) && defined(CONFIG_ZONE_DMA32)
> -	/*
> -	 * Inbound windows don't cover the full lower 4 GiB
> -	 * due to conflicts with PCICSRBAR and outbound windows,
> -	 * so limit the DMA32 zone to 2 GiB, to allow consistent
> -	 * allocations to succeed.
> -	 */
> -	limit_zone_pfn(ZONE_DMA32, 1UL << (31 - PAGE_SHIFT));
> -#endif
>  	mpc85xx_smp_init();
>  }
>  
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 847705a6d0ec..e2d01ccd071d 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -314,7 +314,7 @@ enum zone_type {
>  	 * Architecture		Limit
>  	 * ---------------------------
>  	 * parisc, ia64, sparc	<4G
> -	 * s390			<2G
> +	 * s390, powerpc	<2G
>  	 * arm			Various
>  	 * alpha		Unlimited or 0-16MB.
>  	 *
> -- 
> 2.19.1
> 
> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu
---end quoted text---
