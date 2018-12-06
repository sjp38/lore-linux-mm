Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E69286B7A65
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 09:10:45 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id b17so388798pfc.11
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 06:10:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p23si346185pgk.312.2018.12.06.06.10.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 06:10:44 -0800 (PST)
Date: Thu, 6 Dec 2018 06:10:22 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 06/34] powerpc/dma: split the two __dma_alloc_coherent
 implementations
Message-ID: <20181206141022.GG29741@infradead.org>
References: <20181114082314.8965-1-hch@lst.de>
 <20181114082314.8965-7-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114082314.8965-7-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

ping?

On Wed, Nov 14, 2018 at 09:22:46AM +0100, Christoph Hellwig wrote:
> The implemementation for the CONFIG_NOT_COHERENT_CACHE case doesn't share
> any code with the one for systems with coherent caches.  Split it off
> and merge it with the helpers in dma-noncoherent.c that have no other
> callers.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>  arch/powerpc/include/asm/dma-mapping.h |  5 -----
>  arch/powerpc/kernel/dma.c              | 14 ++------------
>  arch/powerpc/mm/dma-noncoherent.c      | 15 +++++++--------
>  arch/powerpc/platforms/44x/warp.c      |  2 +-
>  4 files changed, 10 insertions(+), 26 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
> index f2a4a7142b1e..dacd0f93f2b2 100644
> --- a/arch/powerpc/include/asm/dma-mapping.h
> +++ b/arch/powerpc/include/asm/dma-mapping.h
> @@ -39,9 +39,6 @@ extern int dma_nommu_mmap_coherent(struct device *dev,
>   * to ensure it is consistent.
>   */
>  struct device;
> -extern void *__dma_alloc_coherent(struct device *dev, size_t size,
> -				  dma_addr_t *handle, gfp_t gfp);
> -extern void __dma_free_coherent(size_t size, void *vaddr);
>  extern void __dma_sync(void *vaddr, size_t size, int direction);
>  extern void __dma_sync_page(struct page *page, unsigned long offset,
>  				 size_t size, int direction);
> @@ -52,8 +49,6 @@ extern unsigned long __dma_get_coherent_pfn(unsigned long cpu_addr);
>   * Cache coherent cores.
>   */
>  
> -#define __dma_alloc_coherent(dev, gfp, size, handle)	NULL
> -#define __dma_free_coherent(size, addr)		((void)0)
>  #define __dma_sync(addr, size, rw)		((void)0)
>  #define __dma_sync_page(pg, off, sz, rw)	((void)0)
>  
> diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
> index 6551685a4ed0..d6deb458bb91 100644
> --- a/arch/powerpc/kernel/dma.c
> +++ b/arch/powerpc/kernel/dma.c
> @@ -62,18 +62,12 @@ static int dma_nommu_dma_supported(struct device *dev, u64 mask)
>  #endif
>  }
>  
> +#ifndef CONFIG_NOT_COHERENT_CACHE
>  void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
>  				  dma_addr_t *dma_handle, gfp_t flag,
>  				  unsigned long attrs)
>  {
>  	void *ret;
> -#ifdef CONFIG_NOT_COHERENT_CACHE
> -	ret = __dma_alloc_coherent(dev, size, dma_handle, flag);
> -	if (ret == NULL)
> -		return NULL;
> -	*dma_handle += get_dma_offset(dev);
> -	return ret;
> -#else
>  	struct page *page;
>  	int node = dev_to_node(dev);
>  #ifdef CONFIG_FSL_SOC
> @@ -110,19 +104,15 @@ void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
>  	*dma_handle = __pa(ret) + get_dma_offset(dev);
>  
>  	return ret;
> -#endif
>  }
>  
>  void __dma_nommu_free_coherent(struct device *dev, size_t size,
>  				void *vaddr, dma_addr_t dma_handle,
>  				unsigned long attrs)
>  {
> -#ifdef CONFIG_NOT_COHERENT_CACHE
> -	__dma_free_coherent(size, vaddr);
> -#else
>  	free_pages((unsigned long)vaddr, get_order(size));
> -#endif
>  }
> +#endif /* !CONFIG_NOT_COHERENT_CACHE */
>  
>  static void *dma_nommu_alloc_coherent(struct device *dev, size_t size,
>  				       dma_addr_t *dma_handle, gfp_t flag,
> diff --git a/arch/powerpc/mm/dma-noncoherent.c b/arch/powerpc/mm/dma-noncoherent.c
> index b6e7b5952ab5..e955539686a4 100644
> --- a/arch/powerpc/mm/dma-noncoherent.c
> +++ b/arch/powerpc/mm/dma-noncoherent.c
> @@ -29,7 +29,7 @@
>  #include <linux/string.h>
>  #include <linux/types.h>
>  #include <linux/highmem.h>
> -#include <linux/dma-mapping.h>
> +#include <linux/dma-direct.h>
>  #include <linux/export.h>
>  
>  #include <asm/tlbflush.h>
> @@ -151,8 +151,8 @@ static struct ppc_vm_region *ppc_vm_region_find(struct ppc_vm_region *head, unsi
>   * Allocate DMA-coherent memory space and return both the kernel remapped
>   * virtual and bus address for that space.
>   */
> -void *
> -__dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp)
> +void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
> +		dma_addr_t *dma_handle, gfp_t gfp, unsigned long attrs)
>  {
>  	struct page *page;
>  	struct ppc_vm_region *c;
> @@ -223,7 +223,7 @@ __dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *handle, gfp_t
>  		/*
>  		 * Set the "dma handle"
>  		 */
> -		*handle = page_to_phys(page);
> +		*dma_handle = phys_to_dma(dev, page_to_phys(page));
>  
>  		do {
>  			SetPageReserved(page);
> @@ -249,12 +249,12 @@ __dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *handle, gfp_t
>   no_page:
>  	return NULL;
>  }
> -EXPORT_SYMBOL(__dma_alloc_coherent);
>  
>  /*
>   * free a page as defined by the above mapping.
>   */
> -void __dma_free_coherent(size_t size, void *vaddr)
> +void __dma_nommu_free_coherent(struct device *dev, size_t size, void *vaddr,
> +		dma_addr_t dma_handle, unsigned long attrs)
>  {
>  	struct ppc_vm_region *c;
>  	unsigned long flags, addr;
> @@ -309,7 +309,6 @@ void __dma_free_coherent(size_t size, void *vaddr)
>  	       __func__, vaddr);
>  	dump_stack();
>  }
> -EXPORT_SYMBOL(__dma_free_coherent);
>  
>  /*
>   * make an area consistent.
> @@ -401,7 +400,7 @@ EXPORT_SYMBOL(__dma_sync_page);
>  
>  /*
>   * Return the PFN for a given cpu virtual address returned by
> - * __dma_alloc_coherent. This is used by dma_mmap_coherent()
> + * __dma_nommu_alloc_coherent. This is used by dma_mmap_coherent()
>   */
>  unsigned long __dma_get_coherent_pfn(unsigned long cpu_addr)
>  {
> diff --git a/arch/powerpc/platforms/44x/warp.c b/arch/powerpc/platforms/44x/warp.c
> index a886c2c22097..7e4f8ca19ce8 100644
> --- a/arch/powerpc/platforms/44x/warp.c
> +++ b/arch/powerpc/platforms/44x/warp.c
> @@ -47,7 +47,7 @@ static int __init warp_probe(void)
>  	if (!of_machine_is_compatible("pika,warp"))
>  		return 0;
>  
> -	/* For __dma_alloc_coherent */
> +	/* For __dma_nommu_alloc_coherent */
>  	ISA_DMA_THRESHOLD = ~0L;
>  
>  	return 1;
> -- 
> 2.19.1
> 
> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu
---end quoted text---
