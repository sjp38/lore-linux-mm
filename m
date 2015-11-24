Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6B26B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 23:23:34 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so8245700pab.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 20:23:34 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id qh12si23995743pab.145.2015.11.23.20.23.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 20:23:33 -0800 (PST)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: + arc-convert-to-dma_map_ops.patch added to -mm tree
Date: Tue, 24 Nov 2015 04:21:28 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075F44D2EEF@IN01WEMBXA.internal.synopsys.com>
References: <564b9e3a.DaXj5xWV8Mzu1fPX%akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_002_C2D7FE5348E1B147BCA15975FBA23075F44D2EEFIN01WEMBXAinter_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@lst.de" <hch@lst.de>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, arcml <linux-snps-arc@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, Anton Kolesov <Anton.Kolesov@synopsys.com>

--_002_C2D7FE5348E1B147BCA15975FBA23075F44D2EEFIN01WEMBXAinter_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Wednesday 18 November 2015 03:08 AM, akpm@linux-foundation.org wrote:=0A=
> The patch titled=0A=
>      Subject: arc: convert to dma_map_ops=0A=
> has been added to the -mm tree.  Its filename is=0A=
>      arc-convert-to-dma_map_ops.patch=0A=
>=0A=
> This patch should soon appear at=0A=
>     http://ozlabs.org/~akpm/mmots/broken-out/arc-convert-to-dma_map_ops.p=
atch=0A=
> and later at=0A=
>     http://ozlabs.org/~akpm/mmotm/broken-out/arc-convert-to-dma_map_ops.p=
atch=0A=
>=0A=
> Before you just go and hit "reply", please:=0A=
>    a) Consider who else should be cc'ed=0A=
>    b) Prefer to cc a suitable mailing list as well=0A=
>    c) Ideally: find the original patch on the mailing list and do a=0A=
>       reply-to-all to that, adding suitable additional cc's=0A=
>=0A=
> *** Remember to use Documentation/SubmitChecklist when testing your code =
***=0A=
>=0A=
> The -mm tree is included into linux-next and is updated=0A=
> there every 3-4 working days=0A=
>=0A=
> ------------------------------------------------------=0A=
> From: Christoph Hellwig <hch@lst.de>=0A=
> Subject: arc: convert to dma_map_ops=0A=
>=0A=
> Signed-off-by: Christoph Hellwig <hch@lst.de>=0A=
> Cc: Vineet Gupta <vgupta@synopsys.com>=0A=
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>=0A=
> ---=0A=
>=0A=
>  arch/arc/Kconfig                   |    1 =0A=
>  arch/arc/include/asm/dma-mapping.h |  187 ---------------------------=0A=
>  arch/arc/mm/dma.c                  |  151 +++++++++++++++------=0A=
>  3 files changed, 109 insertions(+), 230 deletions(-)=0A=
>=0A=
> diff -puN arch/arc/Kconfig~arc-convert-to-dma_map_ops arch/arc/Kconfig=0A=
> --- a/arch/arc/Kconfig~arc-convert-to-dma_map_ops=0A=
> +++ a/arch/arc/Kconfig=0A=
> @@ -38,6 +38,7 @@ config ARC=0A=
>  	select OF_EARLY_FLATTREE=0A=
>  	select PERF_USE_VMALLOC=0A=
>  	select HAVE_DEBUG_STACKOVERFLOW=0A=
> +	select HAVE_DMA_ATTRS=0A=
>  =0A=
>  config TRACE_IRQFLAGS_SUPPORT=0A=
>  	def_bool y=0A=
> diff -puN arch/arc/include/asm/dma-mapping.h~arc-convert-to-dma_map_ops a=
rch/arc/include/asm/dma-mapping.h=0A=
> --- a/arch/arc/include/asm/dma-mapping.h~arc-convert-to-dma_map_ops=0A=
> +++ a/arch/arc/include/asm/dma-mapping.h=0A=
> @@ -11,192 +11,13 @@=0A=
>  #ifndef ASM_ARC_DMA_MAPPING_H=0A=
>  #define ASM_ARC_DMA_MAPPING_H=0A=
>  =0A=
> -#include <asm-generic/dma-coherent.h>=0A=
> -#include <asm/cacheflush.h>=0A=
> +extern struct dma_map_ops arc_dma_ops;=0A=
>  =0A=
> -void *dma_alloc_noncoherent(struct device *dev, size_t size,=0A=
> -			    dma_addr_t *dma_handle, gfp_t gfp);=0A=
> -=0A=
> -void dma_free_noncoherent(struct device *dev, size_t size, void *vaddr,=
=0A=
> -			  dma_addr_t dma_handle);=0A=
> -=0A=
> -void *dma_alloc_coherent(struct device *dev, size_t size,=0A=
> -			 dma_addr_t *dma_handle, gfp_t gfp);=0A=
> -=0A=
> -void dma_free_coherent(struct device *dev, size_t size, void *kvaddr,=0A=
> -		       dma_addr_t dma_handle);=0A=
> -=0A=
> -/* drivers/base/dma-mapping.c */=0A=
> -extern int dma_common_mmap(struct device *dev, struct vm_area_struct *vm=
a,=0A=
> -			   void *cpu_addr, dma_addr_t dma_addr, size_t size);=0A=
> -extern int dma_common_get_sgtable(struct device *dev, struct sg_table *s=
gt,=0A=
> -				  void *cpu_addr, dma_addr_t dma_addr,=0A=
> -				  size_t size);=0A=
> -=0A=
> -#define dma_mmap_coherent(d, v, c, h, s) dma_common_mmap(d, v, c, h, s)=
=0A=
> -#define dma_get_sgtable(d, t, v, h, s) dma_common_get_sgtable(d, t, v, h=
, s)=0A=
> -=0A=
> -/*=0A=
> - * streaming DMA Mapping API...=0A=
> - * CPU accesses page via normal paddr, thus needs to explicitly made=0A=
> - * consistent before each use=0A=
> - */=0A=
> -=0A=
> -static inline void __inline_dma_cache_sync(unsigned long paddr, size_t s=
ize,=0A=
> -					   enum dma_data_direction dir)=0A=
> -{=0A=
> -	switch (dir) {=0A=
> -	case DMA_FROM_DEVICE:=0A=
> -		dma_cache_inv(paddr, size);=0A=
> -		break;=0A=
> -	case DMA_TO_DEVICE:=0A=
> -		dma_cache_wback(paddr, size);=0A=
> -		break;=0A=
> -	case DMA_BIDIRECTIONAL:=0A=
> -		dma_cache_wback_inv(paddr, size);=0A=
> -		break;=0A=
> -	default:=0A=
> -		pr_err("Invalid DMA dir [%d] for OP @ %lx\n", dir, paddr);=0A=
> -	}=0A=
> -}=0A=
> -=0A=
> -void __arc_dma_cache_sync(unsigned long paddr, size_t size,=0A=
> -			  enum dma_data_direction dir);=0A=
> -=0A=
> -#define _dma_cache_sync(addr, sz, dir)			\=0A=
> -do {							\=0A=
> -	if (__builtin_constant_p(dir))			\=0A=
> -		__inline_dma_cache_sync(addr, sz, dir);	\=0A=
> -	else						\=0A=
> -		__arc_dma_cache_sync(addr, sz, dir);	\=0A=
> -}							\=0A=
> -while (0);=0A=
> -=0A=
> -static inline dma_addr_t=0A=
> -dma_map_single(struct device *dev, void *cpu_addr, size_t size,=0A=
> -	       enum dma_data_direction dir)=0A=
> -{=0A=
> -	_dma_cache_sync((unsigned long)cpu_addr, size, dir);=0A=
> -	return (dma_addr_t)cpu_addr;=0A=
> -}=0A=
> -=0A=
> -static inline void=0A=
> -dma_unmap_single(struct device *dev, dma_addr_t dma_addr,=0A=
> -		 size_t size, enum dma_data_direction dir)=0A=
> -{=0A=
> -}=0A=
> -=0A=
> -static inline dma_addr_t=0A=
> -dma_map_page(struct device *dev, struct page *page,=0A=
> -	     unsigned long offset, size_t size,=0A=
> -	     enum dma_data_direction dir)=0A=
> -{=0A=
> -	unsigned long paddr =3D page_to_phys(page) + offset;=0A=
> -	return dma_map_single(dev, (void *)paddr, size, dir);=0A=
> -}=0A=
> -=0A=
> -static inline void=0A=
> -dma_unmap_page(struct device *dev, dma_addr_t dma_handle,=0A=
> -	       size_t size, enum dma_data_direction dir)=0A=
> -{=0A=
> -}=0A=
> -=0A=
> -static inline int=0A=
> -dma_map_sg(struct device *dev, struct scatterlist *sg,=0A=
> -	   int nents, enum dma_data_direction dir)=0A=
> -{=0A=
> -	struct scatterlist *s;=0A=
> -	int i;=0A=
> -=0A=
> -	for_each_sg(sg, s, nents, i)=0A=
> -		s->dma_address =3D dma_map_page(dev, sg_page(s), s->offset,=0A=
> -					       s->length, dir);=0A=
> -=0A=
> -	return nents;=0A=
> -}=0A=
> -=0A=
> -static inline void=0A=
> -dma_unmap_sg(struct device *dev, struct scatterlist *sg,=0A=
> -	     int nents, enum dma_data_direction dir)=0A=
> -{=0A=
> -	struct scatterlist *s;=0A=
> -	int i;=0A=
> -=0A=
> -	for_each_sg(sg, s, nents, i)=0A=
> -		dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);=0A=
> -}=0A=
> -=0A=
> -static inline void=0A=
> -dma_sync_single_for_cpu(struct device *dev, dma_addr_t dma_handle,=0A=
> -			size_t size, enum dma_data_direction dir)=0A=
> -{=0A=
> -	_dma_cache_sync(dma_handle, size, DMA_FROM_DEVICE);=0A=
> -}=0A=
> -=0A=
> -static inline void=0A=
> -dma_sync_single_for_device(struct device *dev, dma_addr_t dma_handle,=0A=
> -			   size_t size, enum dma_data_direction dir)=0A=
> -{=0A=
> -	_dma_cache_sync(dma_handle, size, DMA_TO_DEVICE);=0A=
> -}=0A=
> -=0A=
> -static inline void=0A=
> -dma_sync_single_range_for_cpu(struct device *dev, dma_addr_t dma_handle,=
=0A=
> -			      unsigned long offset, size_t size,=0A=
> -			      enum dma_data_direction direction)=0A=
> -{=0A=
> -	_dma_cache_sync(dma_handle + offset, size, DMA_FROM_DEVICE);=0A=
> -}=0A=
> -=0A=
> -static inline void=0A=
> -dma_sync_single_range_for_device(struct device *dev, dma_addr_t dma_hand=
le,=0A=
> -				 unsigned long offset, size_t size,=0A=
> -				 enum dma_data_direction direction)=0A=
> -{=0A=
> -	_dma_cache_sync(dma_handle + offset, size, DMA_TO_DEVICE);=0A=
> -}=0A=
> -=0A=
> -static inline void=0A=
> -dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sglist, int =
nelems,=0A=
> -		    enum dma_data_direction dir)=0A=
> +static inline struct dma_map_ops *get_dma_ops(struct device *dev)=0A=
>  {=0A=
> -	int i;=0A=
> -	struct scatterlist *sg;=0A=
> -=0A=
> -	for_each_sg(sglist, sg, nelems, i)=0A=
> -		_dma_cache_sync((unsigned int)sg_virt(sg), sg->length, dir);=0A=
> -}=0A=
> -=0A=
> -static inline void=0A=
> -dma_sync_sg_for_device(struct device *dev, struct scatterlist *sglist,=
=0A=
> -		       int nelems, enum dma_data_direction dir)=0A=
> -{=0A=
> -	int i;=0A=
> -	struct scatterlist *sg;=0A=
> -=0A=
> -	for_each_sg(sglist, sg, nelems, i)=0A=
> -		_dma_cache_sync((unsigned int)sg_virt(sg), sg->length, dir);=0A=
> -}=0A=
> -=0A=
> -static inline int dma_supported(struct device *dev, u64 dma_mask)=0A=
> -{=0A=
> -	/* Support 32 bit DMA mask exclusively */=0A=
> -	return dma_mask =3D=3D DMA_BIT_MASK(32);=0A=
> +	return &arc_dma_ops;=0A=
>  }=0A=
>  =0A=
> -static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_a=
ddr)=0A=
> -{=0A=
> -	return 0;=0A=
> -}=0A=
> -=0A=
> -static inline int dma_set_mask(struct device *dev, u64 dma_mask)=0A=
> -{=0A=
> -	if (!dev->dma_mask || !dma_supported(dev, dma_mask))=0A=
> -		return -EIO;=0A=
> -=0A=
> -	*dev->dma_mask =3D dma_mask;=0A=
> -=0A=
> -	return 0;=0A=
> -}=0A=
> +#include <asm-generic/dma-mapping-common.h>=0A=
>  =0A=
>  #endif=0A=
> diff -puN arch/arc/mm/dma.c~arc-convert-to-dma_map_ops arch/arc/mm/dma.c=
=0A=
> --- a/arch/arc/mm/dma.c~arc-convert-to-dma_map_ops=0A=
> +++ a/arch/arc/mm/dma.c=0A=
> @@ -17,18 +17,14 @@=0A=
>   */=0A=
>  =0A=
>  #include <linux/dma-mapping.h>=0A=
> -#include <linux/dma-debug.h>=0A=
> -#include <linux/export.h>=0A=
>  #include <asm/cache.h>=0A=
>  #include <asm/cacheflush.h>=0A=
>  =0A=
> -/*=0A=
> - * Helpers for Coherent DMA API.=0A=
> - */=0A=
> -void *dma_alloc_noncoherent(struct device *dev, size_t size,=0A=
> -			    dma_addr_t *dma_handle, gfp_t gfp)=0A=
> +=0A=
> +static void *arc_dma_alloc(struct device *dev, size_t size,=0A=
> +		dma_addr_t *dma_handle, gfp_t gfp, struct dma_attrs *attrs)=0A=
>  {=0A=
> -	void *paddr;=0A=
> +	void *paddr, *kvaddr;=0A=
>  =0A=
>  	/* This is linear addr (0x8000_0000 based) */=0A=
>  	paddr =3D alloc_pages_exact(size, gfp);=0A=
> @@ -38,22 +34,6 @@ void *dma_alloc_noncoherent(struct devic=0A=
>  	/* This is bus address, platform dependent */=0A=
>  	*dma_handle =3D (dma_addr_t)paddr;=0A=
>  =0A=
> -	return paddr;=0A=
> -}=0A=
> -EXPORT_SYMBOL(dma_alloc_noncoherent);=0A=
> -=0A=
> -void dma_free_noncoherent(struct device *dev, size_t size, void *vaddr,=
=0A=
> -			  dma_addr_t dma_handle)=0A=
> -{=0A=
> -	free_pages_exact((void *)dma_handle, size);=0A=
> -}=0A=
> -EXPORT_SYMBOL(dma_free_noncoherent);=0A=
> -=0A=
> -void *dma_alloc_coherent(struct device *dev, size_t size,=0A=
> -			 dma_addr_t *dma_handle, gfp_t gfp)=0A=
> -{=0A=
> -	void *paddr, *kvaddr;=0A=
> -=0A=
>  	/*=0A=
>  	 * IOC relies on all data (even coherent DMA data) being in cache=0A=
>  	 * Thus allocate normal cached memory=0A=
> @@ -65,22 +45,15 @@ void *dma_alloc_coherent(struct device *=0A=
>  	 *   -For coherent data, Read/Write to buffers terminate early in cache=
=0A=
>  	 *   (vs. always going to memory - thus are faster)=0A=
>  	 */=0A=
> -	if (is_isa_arcv2() && ioc_exists)=0A=
> -		return dma_alloc_noncoherent(dev, size, dma_handle, gfp);=0A=
> -=0A=
> -	/* This is linear addr (0x8000_0000 based) */=0A=
> -	paddr =3D alloc_pages_exact(size, gfp);=0A=
> -	if (!paddr)=0A=
> -		return NULL;=0A=
> +	if ((is_isa_arcv2() && ioc_exists) ||=0A=
> +	    dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs)=0A=
> +		return paddr;=0A=
>  =0A=
>  	/* This is kernel Virtual address (0x7000_0000 based) */=0A=
>  	kvaddr =3D ioremap_nocache((unsigned long)paddr, size);=0A=
>  	if (kvaddr =3D=3D NULL)=0A=
>  		return NULL;=0A=
>  =0A=
> -	/* This is bus address, platform dependent */=0A=
> -	*dma_handle =3D (dma_addr_t)paddr;=0A=
> -=0A=
>  	/*=0A=
>  	 * Evict any existing L1 and/or L2 lines for the backing page=0A=
>  	 * in case it was used earlier as a normal "cached" page.=0A=
> @@ -95,26 +68,110 @@ void *dma_alloc_coherent(struct device *=0A=
>  =0A=
>  	return kvaddr;=0A=
>  }=0A=
> -EXPORT_SYMBOL(dma_alloc_coherent);=0A=
>  =0A=
> -void dma_free_coherent(struct device *dev, size_t size, void *kvaddr,=0A=
> -		       dma_addr_t dma_handle)=0A=
> +static void arc_dma_free(struct device *dev, size_t size, void *vaddr,=
=0A=
> +		dma_addr_t dma_handle, struct dma_attrs *attrs)=0A=
>  {=0A=
> -	if (is_isa_arcv2() && ioc_exists)=0A=
> -		return dma_free_noncoherent(dev, size, kvaddr, dma_handle);=0A=
> -=0A=
> -	iounmap((void __force __iomem *)kvaddr);=0A=
> +	if (!(is_isa_arcv2() && ioc_exists) ||=0A=
> +	    dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs))=0A=
> +		iounmap((void __force __iomem *)kvaddr);=0A=
>  =0A=
>  	free_pages_exact((void *)dma_handle, size);=0A=
>  }=0A=
> -EXPORT_SYMBOL(dma_free_coherent);=0A=
>  =0A=
>  /*=0A=
> - * Helper for streaming DMA...=0A=
> + * streaming DMA Mapping API...=0A=
> + * CPU accesses page via normal paddr, thus needs to explicitly made=0A=
> + * consistent before each use=0A=
>   */=0A=
> -void __arc_dma_cache_sync(unsigned long paddr, size_t size,=0A=
> -			  enum dma_data_direction dir)=0A=
> +static void _dma_cache_sync(unsigned long paddr, size_t size,=0A=
> +		enum dma_data_direction dir)=0A=
> +{=0A=
> +	switch (dir) {=0A=
> +	case DMA_FROM_DEVICE:=0A=
> +		dma_cache_inv(paddr, size);=0A=
> +		break;=0A=
> +	case DMA_TO_DEVICE:=0A=
> +		dma_cache_wback(paddr, size);=0A=
> +		break;=0A=
> +	case DMA_BIDIRECTIONAL:=0A=
> +		dma_cache_wback_inv(paddr, size);=0A=
> +		break;=0A=
> +	default:=0A=
> +		pr_err("Invalid DMA dir [%d] for OP @ %lx\n", dir, paddr);=0A=
> +	}=0A=
> +}=0A=
> +=0A=
> +static dma_addr_t arc_dma_map_page(struct device *dev, struct page *page=
,=0A=
> +		unsigned long offset, size_t size, enum dma_data_direction dir,=0A=
> +		struct dma_attrs *attrs)=0A=
> +{=0A=
> +	unsigned long paddr =3D page_to_phys(page) + offset;=0A=
> +	return dma_map_single(dev, (void *)paddr, size, dir);=0A=
> +}=0A=
> +=0A=
> +static int arc_dma_map_sg(struct device *dev, struct scatterlist *sg,=0A=
> +	   int nents, enum dma_data_direction dir, struct dma_attrs *attrs)=0A=
> +{=0A=
> +	struct scatterlist *s;=0A=
> +	int i;=0A=
> +=0A=
> +	for_each_sg(sg, s, nents, i)=0A=
> +		s->dma_address =3D dma_map_page(dev, sg_page(s), s->offset,=0A=
> +					       s->length, dir);=0A=
> +=0A=
> +	return nents;=0A=
> +}=0A=
> +=0A=
> +static void arc_dma_sync_single_for_cpu(struct device *dev,=0A=
> +		dma_addr_t dma_handle, size_t size, enum dma_data_direction dir)=0A=
> +{=0A=
> +	_dma_cache_sync(dma_handle, size, DMA_FROM_DEVICE);=0A=
> +}=0A=
> +=0A=
> +static void arc_dma_sync_single_for_device(struct device *dev,=0A=
> +		dma_addr_t dma_handle, size_t size, enum dma_data_direction dir)=0A=
>  {=0A=
> -	__inline_dma_cache_sync(paddr, size, dir);=0A=
> +	_dma_cache_sync(dma_handle, size, DMA_TO_DEVICE);=0A=
>  }=0A=
> -EXPORT_SYMBOL(__arc_dma_cache_sync);=0A=
> +=0A=
> +static void arm_dma_sync_sg_for_cpu(struct device *dev,=0A=
> +		struct scatterlist *sglist, int nelems,=0A=
> +		enum dma_data_direction dir)=0A=
> +{=0A=
> +	int i;=0A=
> +	struct scatterlist *sg;=0A=
> +=0A=
> +	for_each_sg(sglist, sg, nelems, i)=0A=
> +		_dma_cache_sync((unsigned int)sg_virt(sg), sg->length, dir);=0A=
> +}=0A=
> +=0A=
> +static void arc_dma_sync_sg_for_device(struct device *dev,=0A=
> +		struct scatterlist *sglist, int nelems,=0A=
> +		enum dma_data_direction dir)=0A=
> +{=0A=
> +	int i;=0A=
> +	struct scatterlist *sg;=0A=
> +=0A=
> +	for_each_sg(sglist, sg, nelems, i)=0A=
> +		_dma_cache_sync((unsigned int)sg_virt(sg), sg->length, dir);=0A=
> +}=0A=
> +=0A=
> +static int arc_dma_supported(struct device *dev, u64 dma_mask)=0A=
> +{=0A=
> +	/* Support 32 bit DMA mask exclusively */=0A=
> +	return dma_mask =3D=3D DMA_BIT_MASK(32);=0A=
> +}=0A=
> +=0A=
> +struct dma_map_ops arc_dma_ops =3D {=0A=
> +	.alloc			=3D arc_dma_alloc,=0A=
> +	.free			=3D arc_dma_free,=0A=
> +	.map_page		=3D arc_dma_map_page,=0A=
> +	.map_sg			=3D arc_dma_map_sg,=0A=
> +	.sync_single_for_device	=3D arc_dma_sync_single_for_device,=0A=
> +	.sync_single_for_cpu	=3D arc_dma_sync_single_for_cpu,=0A=
> +	.sync_sg_for_cpu	=3D arc_dma_sync_sg_for_cpu,=0A=
> +	.sync_sg_for_dev	=3D arc_dma_sync_sg_for_device,=0A=
> +	.dma_supported		=3D arc_dma_supported,=0A=
> +};=0A=
> +EXPORT_SYMBOL(arc_dma_ops);=0A=
> _=0A=
>=0A=
> Patches currently in -mm which might be from hch@lst.de are=0A=
>=0A=
> dma-mapping-make-the-generic-coherent-dma-mmap-implementation-optional.pa=
tch=0A=
> arc-convert-to-dma_map_ops.patch=0A=
> avr32-convert-to-dma_map_ops.patch=0A=
> blackfin-convert-to-dma_map_ops.patch=0A=
> c6x-convert-to-dma_map_ops.patch=0A=
> cris-convert-to-dma_map_ops.patch=0A=
> nios2-convert-to-dma_map_ops.patch=0A=
> frv-convert-to-dma_map_ops.patch=0A=
> parisc-convert-to-dma_map_ops.patch=0A=
> mn10300-convert-to-dma_map_ops.patch=0A=
> m68k-convert-to-dma_map_ops.patch=0A=
> metag-convert-to-dma_map_ops.patch=0A=
> sparc-use-generic-dma_set_mask.patch=0A=
> tile-uninline-dma_set_mask.patch=0A=
> dma-mapping-always-provide-the-dma_map_ops-based-implementation.patch=0A=
> dma-mapping-remove-asm-generic-dma-coherenth.patch=0A=
=0A=
Hi Christoph,=0A=
=0A=
This patch in linux-next breaks ARC build.=0A=
=0A=
Below is fixup patch which u can probably fold into your tree=0A=
------------>=0A=
>From d924a26542660cd1ac68f8f86f8b646835ef5179 Mon Sep 17 00:00:00 2001=0A=
From: Vineet Gupta <vgupta@synopsys.com>=0A=
Date: Tue, 24 Nov 2015 09:46:05 +0530=0A=
Subject: [PATCH] arc: fix wreakage of conversion to dma_map_ops=0A=
=0A=
Obviously the initial patch was not build tested.=0A=
=0A=
Reported-by: Anton Kolesov <akolesov@synopsys.com>=0A=
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>=0A=
---=0A=
 arch/arc/mm/dma.c | 8 ++++----=0A=
 1 file changed, 4 insertions(+), 4 deletions(-)=0A=
=0A=
diff --git a/arch/arc/mm/dma.c b/arch/arc/mm/dma.c=0A=
index da289cb30ca5..695029f41a48 100644=0A=
--- a/arch/arc/mm/dma.c=0A=
+++ b/arch/arc/mm/dma.c=0A=
@@ -46,7 +46,7 @@ static void *arc_dma_alloc(struct device *dev, size_t siz=
e,=0A=
      *   (vs. always going to memory - thus are faster)=0A=
      */=0A=
     if ((is_isa_arcv2() && ioc_exists) ||=0A=
-        dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs)=0A=
+        dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs))=0A=
         return paddr;=0A=
 =0A=
     /* This is kernel Virtual address (0x7000_0000 based) */=0A=
@@ -74,7 +74,7 @@ static void arc_dma_free(struct device *dev, size_t size,=
 void=0A=
*vaddr,=0A=
 {=0A=
     if (!(is_isa_arcv2() && ioc_exists) ||=0A=
         dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs))=0A=
-        iounmap((void __force __iomem *)kvaddr);=0A=
+        iounmap((void __force __iomem *)vaddr);=0A=
 =0A=
     free_pages_exact((void *)dma_handle, size);=0A=
 }=0A=
@@ -135,7 +135,7 @@ static void arc_dma_sync_single_for_device(struct devic=
e *dev,=0A=
     _dma_cache_sync(dma_handle, size, DMA_TO_DEVICE);=0A=
 }=0A=
 =0A=
-static void arm_dma_sync_sg_for_cpu(struct device *dev,=0A=
+static void arc_dma_sync_sg_for_cpu(struct device *dev,=0A=
         struct scatterlist *sglist, int nelems,=0A=
         enum dma_data_direction dir)=0A=
 {=0A=
@@ -171,7 +171,7 @@ struct dma_map_ops arc_dma_ops =3D {=0A=
     .sync_single_for_device    =3D arc_dma_sync_single_for_device,=0A=
     .sync_single_for_cpu    =3D arc_dma_sync_single_for_cpu,=0A=
     .sync_sg_for_cpu    =3D arc_dma_sync_sg_for_cpu,=0A=
-    .sync_sg_for_dev    =3D arc_dma_sync_sg_for_device,=0A=
+    .sync_sg_for_device    =3D arc_dma_sync_sg_for_device,=0A=
     .dma_supported        =3D arc_dma_supported,=0A=
 };=0A=
 EXPORT_SYMBOL(arc_dma_ops);=0A=
-- =0A=
1.9.1=0A=
=0A=
=0A=

--_002_C2D7FE5348E1B147BCA15975FBA23075F44D2EEFIN01WEMBXAinter_
Content-Type: text/x-patch;
	name="0001-arc-fix-wreakage-of-conversion-to-dma_map_ops.patch"
Content-Description: 0001-arc-fix-wreakage-of-conversion-to-dma_map_ops.patch
Content-Disposition: attachment;
	filename="0001-arc-fix-wreakage-of-conversion-to-dma_map_ops.patch";
	size=2005; creation-date="Tue, 24 Nov 2015 04:21:27 GMT";
	modification-date="Tue, 24 Nov 2015 04:21:27 GMT"
Content-Transfer-Encoding: base64

RnJvbSBkOTI0YTI2NTQyNjYwY2QxYWM2OGY4Zjg2ZjhiNjQ2ODM1ZWY1MTc5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBWaW5lZXQgR3VwdGEgPHZndXB0YUBzeW5vcHN5cy5jb20+CkRh
dGU6IFR1ZSwgMjQgTm92IDIwMTUgMDk6NDY6MDUgKzA1MzAKU3ViamVjdDogW1BBVENIXSBhcmM6
IGZpeCB3cmVha2FnZSBvZiBjb252ZXJzaW9uIHRvIGRtYV9tYXBfb3BzCgpPYnZpb3VzbHkgdGhl
IGluaXRpYWwgcGF0Y2ggd2FzIG5vdCBidWlsZCB0ZXN0ZWQuCgpSZXBvcnRlZC1ieTogQW50b24g
S29sZXNvdiA8YWtvbGVzb3ZAc3lub3BzeXMuY29tPgpTaWduZWQtb2ZmLWJ5OiBWaW5lZXQgR3Vw
dGEgPHZndXB0YUBzeW5vcHN5cy5jb20+Ci0tLQogYXJjaC9hcmMvbW0vZG1hLmMgfCA4ICsrKyst
LS0tCiAxIGZpbGUgY2hhbmdlZCwgNCBpbnNlcnRpb25zKCspLCA0IGRlbGV0aW9ucygtKQoKZGlm
ZiAtLWdpdCBhL2FyY2gvYXJjL21tL2RtYS5jIGIvYXJjaC9hcmMvbW0vZG1hLmMKaW5kZXggZGEy
ODljYjMwY2E1Li42OTUwMjlmNDFhNDggMTAwNjQ0Ci0tLSBhL2FyY2gvYXJjL21tL2RtYS5jCisr
KyBiL2FyY2gvYXJjL21tL2RtYS5jCkBAIC00Niw3ICs0Niw3IEBAIHN0YXRpYyB2b2lkICphcmNf
ZG1hX2FsbG9jKHN0cnVjdCBkZXZpY2UgKmRldiwgc2l6ZV90IHNpemUsCiAJICogICAodnMuIGFs
d2F5cyBnb2luZyB0byBtZW1vcnkgLSB0aHVzIGFyZSBmYXN0ZXIpCiAJICovCiAJaWYgKChpc19p
c2FfYXJjdjIoKSAmJiBpb2NfZXhpc3RzKSB8fAotCSAgICBkbWFfZ2V0X2F0dHIoRE1BX0FUVFJf
Tk9OX0NPTlNJU1RFTlQsIGF0dHJzKQorCSAgICBkbWFfZ2V0X2F0dHIoRE1BX0FUVFJfTk9OX0NP
TlNJU1RFTlQsIGF0dHJzKSkKIAkJcmV0dXJuIHBhZGRyOwogCiAJLyogVGhpcyBpcyBrZXJuZWwg
VmlydHVhbCBhZGRyZXNzICgweDcwMDBfMDAwMCBiYXNlZCkgKi8KQEAgLTc0LDcgKzc0LDcgQEAg
c3RhdGljIHZvaWQgYXJjX2RtYV9mcmVlKHN0cnVjdCBkZXZpY2UgKmRldiwgc2l6ZV90IHNpemUs
IHZvaWQgKnZhZGRyLAogewogCWlmICghKGlzX2lzYV9hcmN2MigpICYmIGlvY19leGlzdHMpIHx8
CiAJICAgIGRtYV9nZXRfYXR0cihETUFfQVRUUl9OT05fQ09OU0lTVEVOVCwgYXR0cnMpKQotCQlp
b3VubWFwKCh2b2lkIF9fZm9yY2UgX19pb21lbSAqKWt2YWRkcik7CisJCWlvdW5tYXAoKHZvaWQg
X19mb3JjZSBfX2lvbWVtICopdmFkZHIpOwogCiAJZnJlZV9wYWdlc19leGFjdCgodm9pZCAqKWRt
YV9oYW5kbGUsIHNpemUpOwogfQpAQCAtMTM1LDcgKzEzNSw3IEBAIHN0YXRpYyB2b2lkIGFyY19k
bWFfc3luY19zaW5nbGVfZm9yX2RldmljZShzdHJ1Y3QgZGV2aWNlICpkZXYsCiAJX2RtYV9jYWNo
ZV9zeW5jKGRtYV9oYW5kbGUsIHNpemUsIERNQV9UT19ERVZJQ0UpOwogfQogCi1zdGF0aWMgdm9p
ZCBhcm1fZG1hX3N5bmNfc2dfZm9yX2NwdShzdHJ1Y3QgZGV2aWNlICpkZXYsCitzdGF0aWMgdm9p
ZCBhcmNfZG1hX3N5bmNfc2dfZm9yX2NwdShzdHJ1Y3QgZGV2aWNlICpkZXYsCiAJCXN0cnVjdCBz
Y2F0dGVybGlzdCAqc2dsaXN0LCBpbnQgbmVsZW1zLAogCQllbnVtIGRtYV9kYXRhX2RpcmVjdGlv
biBkaXIpCiB7CkBAIC0xNzEsNyArMTcxLDcgQEAgc3RydWN0IGRtYV9tYXBfb3BzIGFyY19kbWFf
b3BzID0gewogCS5zeW5jX3NpbmdsZV9mb3JfZGV2aWNlCT0gYXJjX2RtYV9zeW5jX3NpbmdsZV9m
b3JfZGV2aWNlLAogCS5zeW5jX3NpbmdsZV9mb3JfY3B1CT0gYXJjX2RtYV9zeW5jX3NpbmdsZV9m
b3JfY3B1LAogCS5zeW5jX3NnX2Zvcl9jcHUJPSBhcmNfZG1hX3N5bmNfc2dfZm9yX2NwdSwKLQku
c3luY19zZ19mb3JfZGV2CT0gYXJjX2RtYV9zeW5jX3NnX2Zvcl9kZXZpY2UsCisJLnN5bmNfc2df
Zm9yX2RldmljZQk9IGFyY19kbWFfc3luY19zZ19mb3JfZGV2aWNlLAogCS5kbWFfc3VwcG9ydGVk
CQk9IGFyY19kbWFfc3VwcG9ydGVkLAogfTsKIEVYUE9SVF9TWU1CT0woYXJjX2RtYV9vcHMpOwot
LSAKMS45LjEKCg==

--_002_C2D7FE5348E1B147BCA15975FBA23075F44D2EEFIN01WEMBXAinter_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
