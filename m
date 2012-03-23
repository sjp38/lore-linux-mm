Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id AA0256B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 08:12:23 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M1C00COT78D8M30@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Mar 2012 12:12:13 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1C004UM78K7F@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Mar 2012 12:12:21 +0000 (GMT)
Date: Fri, 23 Mar 2012 13:12:16 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv7 8/9] ARM: dma-mapping: use alloc, mmap, free from dma_ops
In-reply-to: <4F6B2CDE.4020601@gmail.com>
Message-id: <08af01cd08ee$2fd04770$8f70d650$%szyprowski@samsung.com>
Content-language: pl
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
 <1330527862-16234-9-git-send-email-m.szyprowski@samsung.com>
 <4F6B2CDE.4020601@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Subash Patel' <subashrp@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'KyongHo Cho' <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>

Hello,

On Thursday, March 22, 2012 2:45 PM Subash Patel wrote:

> I have found out an issue with dma_mmap_writecombine() and coherent devices.
> 
> On 02/29/2012 08:34 PM, Marek Szyprowski wrote:
> > This patch converts dma_alloc/free/mmap_{coherent,writecombine}
> > functions to use generic alloc/free/mmap methods from dma_map_ops
> > structure. A new DMA_ATTR_WRITE_COMBINE DMA attribute have been
> > introduced to implement writecombine methods.
> >
> > Signed-off-by: Marek Szyprowski<m.szyprowski@samsung.com>
> > Signed-off-by: Kyungmin Park<kyungmin.park@samsung.com>
> > ---
> >   arch/arm/common/dmabounce.c        |    3 +
> >   arch/arm/include/asm/dma-mapping.h |  107 ++++++++++++++++++++++++++----------
> >   arch/arm/mm/dma-mapping.c          |   53 ++++++------------
> >   3 files changed, 98 insertions(+), 65 deletions(-)
> >
> > diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
> > index 119f487..dbae5ad 100644
> > --- a/arch/arm/common/dmabounce.c
> > +++ b/arch/arm/common/dmabounce.c
> > @@ -449,6 +449,9 @@ static int dmabounce_set_mask(struct device *dev, u64 dma_mask)
> >   }
> >
> >   static struct dma_map_ops dmabounce_ops = {
> > +	.alloc			= arm_dma_alloc,
> > +	.free			= arm_dma_free,
> > +	.mmap			= arm_dma_mmap,
> >   	.map_page		= dmabounce_map_page,
> >   	.unmap_page		= dmabounce_unmap_page,
> >   	.sync_single_for_cpu	= dmabounce_sync_for_cpu,
> > diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
> > index 266cba6..4342b75 100644
> > --- a/arch/arm/include/asm/dma-mapping.h
> > +++ b/arch/arm/include/asm/dma-mapping.h
> > @@ -5,6 +5,7 @@
> >
> >   #include<linux/mm_types.h>
> >   #include<linux/scatterlist.h>
> > +#include<linux/dma-attrs.h>
> >   #include<linux/dma-debug.h>
> >
> >   #include<asm-generic/dma-coherent.h>
> > @@ -110,68 +111,115 @@ static inline void dma_free_noncoherent(struct device *dev, size_t
> size,
> >   extern int dma_supported(struct device *dev, u64 mask);
> >
> >   /**
> > - * dma_alloc_coherent - allocate consistent memory for DMA
> > + * arm_dma_alloc - allocate consistent memory for DMA
> >    * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
> >    * @size: required memory size
> >    * @handle: bus-specific DMA address
> > + * @attrs: optinal attributes that specific mapping properties
> >    *
> > - * Allocate some uncached, unbuffered memory for a device for
> > - * performing DMA.  This function allocates pages, and will
> > - * return the CPU-viewed address, and sets @handle to be the
> > - * device-viewed address.
> > + * Allocate some memory for a device for performing DMA.  This function
> > + * allocates pages, and will return the CPU-viewed address, and sets @handle
> > + * to be the device-viewed address.
> >    */
> > -extern void *dma_alloc_coherent(struct device *, size_t, dma_addr_t *, gfp_t);
> > +extern void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
> > +			   gfp_t gfp, struct dma_attrs *attrs);
> > +
> > +#define dma_alloc_coherent(d,s,h,f) dma_alloc_attrs(d,s,h,f,NULL)
> > +
> > +static inline void *dma_alloc_attrs(struct device *dev, size_t size,
> > +				       dma_addr_t *dma_handle, gfp_t flag,
> > +				       struct dma_attrs *attrs)
> > +{
> > +	struct dma_map_ops *ops = get_dma_ops(dev);
> > +	void *cpu_addr;
> > +	BUG_ON(!ops);
> > +
> > +	cpu_addr = ops->alloc(dev, size, dma_handle, flag, attrs);
> > +	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
> > +	return cpu_addr;
> > +}
> >
> >   /**
> > - * dma_free_coherent - free memory allocated by dma_alloc_coherent
> > + * arm_dma_free - free memory allocated by arm_dma_alloc
> >    * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
> >    * @size: size of memory originally requested in dma_alloc_coherent
> >    * @cpu_addr: CPU-view address returned from dma_alloc_coherent
> >    * @handle: device-view address returned from dma_alloc_coherent
> > + * @attrs: optinal attributes that specific mapping properties
> >    *
> >    * Free (and unmap) a DMA buffer previously allocated by
> > - * dma_alloc_coherent().
> > + * arm_dma_alloc().
> >    *
> >    * References to memory and mappings associated with cpu_addr/handle
> >    * during and after this call executing are illegal.
> >    */
> > -extern void dma_free_coherent(struct device *, size_t, void *, dma_addr_t);
> > +extern void arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
> > +			 dma_addr_t handle, struct dma_attrs *attrs);
> > +
> > +#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
> > +
> > +static inline void dma_free_attrs(struct device *dev, size_t size,
> > +				     void *cpu_addr, dma_addr_t dma_handle,
> > +				     struct dma_attrs *attrs)
> > +{
> > +	struct dma_map_ops *ops = get_dma_ops(dev);
> > +	BUG_ON(!ops);
> > +
> > +	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
> > +	ops->free(dev, size, cpu_addr, dma_handle, attrs);
> > +}
> >
> >   /**
> > - * dma_mmap_coherent - map a coherent DMA allocation into user space
> > + * arm_dma_mmap - map a coherent DMA allocation into user space
> >    * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
> >    * @vma: vm_area_struct describing requested user mapping
> >    * @cpu_addr: kernel CPU-view address returned from dma_alloc_coherent
> >    * @handle: device-view address returned from dma_alloc_coherent
> >    * @size: size of memory originally requested in dma_alloc_coherent
> > + * @attrs: optinal attributes that specific mapping properties
> >    *
> >    * Map a coherent DMA buffer previously allocated by dma_alloc_coherent
> >    * into user space.  The coherent DMA buffer must not be freed by the
> >    * driver until the user space mapping has been released.
> >    */
> > -int dma_mmap_coherent(struct device *, struct vm_area_struct *,
> > -		void *, dma_addr_t, size_t);
> > +extern int arm_dma_mmap(struct device *dev, struct vm_area_struct *vma,
> > +			void *cpu_addr, dma_addr_t dma_addr, size_t size,
> > +			struct dma_attrs *attrs);
> >
> > +#define dma_mmap_coherent(d,v,c,h,s) dma_mmap_attrs(d,v,c,h,s,NULL)
> >
> > -/**
> > - * dma_alloc_writecombine - allocate writecombining memory for DMA
> > - * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
> > - * @size: required memory size
> > - * @handle: bus-specific DMA address
> > - *
> > - * Allocate some uncached, buffered memory for a device for
> > - * performing DMA.  This function allocates pages, and will
> > - * return the CPU-viewed address, and sets @handle to be the
> > - * device-viewed address.
> > - */
> > -extern void *dma_alloc_writecombine(struct device *, size_t, dma_addr_t *,
> > -		gfp_t);
> > +static inline int dma_mmap_attrs(struct device *dev, struct vm_area_struct *vma,
> > +				  void *cpu_addr, dma_addr_t dma_addr,
> > +				  size_t size, struct dma_attrs *attrs)
> > +{
> > +	struct dma_map_ops *ops = get_dma_ops(dev);
> > +	BUG_ON(!ops);
> > +	return ops->mmap(dev, vma, cpu_addr, dma_addr, size, attrs);
> > +}
> >
> > -#define dma_free_writecombine(dev,size,cpu_addr,handle) \
> > -	dma_free_coherent(dev,size,cpu_addr,handle)
> > +static inline void *dma_alloc_writecombine(struct device *dev, size_t size,
> > +				       dma_addr_t *dma_handle, gfp_t flag)
> > +{
> > +	DEFINE_DMA_ATTRS(attrs);
> > +	dma_set_attr(DMA_ATTR_WRITE_COMBINE,&attrs);
> > +	return dma_alloc_attrs(dev, size, dma_handle, flag,&attrs);
> > +}
> >
> > -int dma_mmap_writecombine(struct device *, struct vm_area_struct *,
> > -		void *, dma_addr_t, size_t);
> > +static inline void dma_free_writecombine(struct device *dev, size_t size,
> > +				     void *cpu_addr, dma_addr_t dma_handle)
> > +{
> > +	DEFINE_DMA_ATTRS(attrs);
> > +	dma_set_attr(DMA_ATTR_WRITE_COMBINE,&attrs);
> > +	return dma_free_attrs(dev, size, cpu_addr, dma_handle,&attrs);
> > +}
> > +
> > +static inline int dma_mmap_writecombine(struct device *dev, struct vm_area_struct *vma,
> > +		      void *cpu_addr, dma_addr_t dma_addr, size_t size)
> > +{
> > +	DEFINE_DMA_ATTRS(attrs);
> > +	dma_set_attr(DMA_ATTR_WRITE_COMBINE,&attrs);
> > +	return dma_mmap_attrs(dev, vma, cpu_addr, dma_addr, size,&attrs);
> > +}
> >
> For devices, which do not have a coherent/reserved pool, then the
> allocation in function __dma_alloc() happens, and the memory will be
> remapped by calling __dma_alloc_remap(). In the above function,
> arm_vmregion_find() will be called, and it succeeds to get the map and
> it will be mapped to used.
> 
> This has issues with devices with coherent memory. If we have any device
> which has declared coherent memory, then the allocation happens from
> per-device coherent area. Eg: Exynos MFC which declares:
> s5p_mfc_reserve_mem(). In that case, dma_mmap_writecombine() fails, and
> hence vb2_dc_mmap() fails as well.

Right, I missed that case. Now I prepared a fix, I will send the patches in a minute. 
Please check if it works for you.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
