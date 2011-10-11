Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2E9CC6B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 04:20:01 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LSW00DJZ759C110@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 11 Oct 2011 09:19:57 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LSW001JG759J2@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 11 Oct 2011 09:19:57 +0100 (BST)
Date: Tue, 11 Oct 2011 10:19:46 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCH 1/2] ARM: initial proof-of-concept IOMMU
 mapper for DMA-mapping
In-reply-to: <401E54CE964CD94BAE1EB4A729C7087E37225197F8@HQMAIL04.nvidia.com>
Message-id: <00b101cc87ee$8976c410$9c644c30$%szyprowski@samsung.com>
Content-language: pl
References: <1314971786-15140-1-git-send-email-m.szyprowski@samsung.com>
 <1314971786-15140-2-git-send-email-m.szyprowski@samsung.com>
 <594816116217195c28de13accaf1f9f2.squirrel@www.codeaurora.org>
 <001f01cc786d$d55222c0$7ff66840$%szyprowski@samsung.com>
 <401E54CE964CD94BAE1EB4A729C7087E37225197F8@HQMAIL04.nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Krishna Reddy' <vdumpa@nvidia.com>
Cc: linux-arch@vger.kernel.org, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, linux-arm-kernel@lists.infradead.org, 'Laura Abbott' <lauraa@codeaurora.org>

Hello,

On Monday, October 10, 2011 11:57 PM Krishna Reddy wrote:

> Marek,
> Here is a patch that has fixes to get SDHC driver work as a DMA IOMMU client. Here is the
> overview of changes.
> 
> 1. Converted the mutex to spinlock to handle atomic context calls and used spinlock in
> necessary places.
> 2. Implemented arm_iommu_map_page and arm_iommu_unmap_page, which are used by MMC host stack.
> 3. Fixed the bugs identified during testing with SDHC driver.

Thanks for your work! I agree that spinlock protection is the correct approach. However
I have some comments on your changes. Please see the code.

> From: Krishna Reddy <vdumpa@nvidia.com>
> Date: Fri, 7 Oct 2011 17:25:59 -0700
> Subject: [PATCH] ARM: dma-mapping: Implement arm_iommu_map_page/unmap_page and fix issues.
> 
> Change-Id: I47a1a0065538fa0a161dd6d551b38079bd8f84fd
> ---
>  arch/arm/include/asm/dma-iommu.h |    3 +-
>  arch/arm/mm/dma-mapping.c        |  182 +++++++++++++++++++++-----------------
>  2 files changed, 102 insertions(+), 83 deletions(-)
> 
> diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-iommu.h
> index 0b2677e..ad1a4d9 100644
> --- a/arch/arm/include/asm/dma-iommu.h
> +++ b/arch/arm/include/asm/dma-iommu.h
> @@ -7,6 +7,7 @@
>  #include <linux/scatterlist.h>
>  #include <linux/dma-debug.h>
>  #include <linux/kmemcheck.h>
> +#include <linux/spinlock_types.h>
> 
>  #include <asm/memory.h>
> 
> @@ -19,7 +20,7 @@ struct dma_iommu_mapping {
>  	unsigned int		order;
>  	dma_addr_t		base;
> 
> -	struct mutex		lock;
> +	spinlock_t		lock;
>  };
> 
>  int arm_iommu_attach_device(struct device *dev, dma_addr_t base,
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 020bde1..0befd88 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -739,32 +739,42 @@ fs_initcall(dma_debug_do_init);
> 
>  /* IOMMU */
> 
> -static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping, size_t size)
> +static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,
> +					size_t size)
>  {
> -	unsigned int order = get_order(size);
>  	unsigned int align = 0;
>  	unsigned int count, start;
> +	unsigned long flags;
> 
> -	if (order > mapping->order)
> -		align = (1 << (order - mapping->order)) - 1;
> +	count = ((PAGE_ALIGN(size) >> PAGE_SHIFT) +
> +		 (1 << mapping->order) - 1) >> mapping->order;
> 
> -	count = ((size >> PAGE_SHIFT) + (1 << mapping->order) - 1) >> mapping->order;
> -
> -	start = bitmap_find_next_zero_area(mapping->bitmap, mapping->bits, 0, count, align);
> -	if (start > mapping->bits)
> +	spin_lock_irqsave(&mapping->lock, flags);
> +	start = bitmap_find_next_zero_area(mapping->bitmap, mapping->bits,
> +					    0, count, align);
> +	if (start > mapping->bits) {
> +		spin_unlock_irqrestore(&mapping->lock, flags);
>  		return ~0;
> +	}
> 
>  	bitmap_set(mapping->bitmap, start, count);
> +	spin_unlock_irqrestore(&mapping->lock, flags);
> 
>  	return mapping->base + (start << (mapping->order + PAGE_SHIFT));
>  }
> 
> -static inline void __free_iova(struct dma_iommu_mapping *mapping, dma_addr_t addr, size_t
> size)
> +static inline void __free_iova(struct dma_iommu_mapping *mapping,
> +				dma_addr_t addr, size_t size)
>  {
> -	unsigned int start = (addr - mapping->base) >> (mapping->order + PAGE_SHIFT);
> -	unsigned int count = ((size >> PAGE_SHIFT) + (1 << mapping->order) - 1) >> mapping-
> >order;
> +	unsigned int start = (addr - mapping->base) >>
> +			     (mapping->order + PAGE_SHIFT);
> +	unsigned int count = ((PAGE_ALIGN(size) >> PAGE_SHIFT) +
> +			      (1 << mapping->order) - 1) >> mapping->order;
> +	unsigned long flags;
> 
> +	spin_lock_irqsave(&mapping->lock, flags);
>  	bitmap_clear(mapping->bitmap, start, count);
> +	spin_unlock_irqrestore(&mapping->lock, flags);
>  }
> 
>  static struct page **__iommu_alloc_buffer(struct device *dev, size_t size, gfp_t gfp)
> @@ -867,7 +877,7 @@ __iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_t
> prot)
>  static dma_addr_t __iommu_create_mapping(struct device *dev, struct page **pages, size_t
> size)
>  {
>  	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> -	unsigned int count = size >> PAGE_SHIFT;
> +	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
>  	dma_addr_t dma_addr, iova;
>  	int i, ret = ~0;
> 
> @@ -892,13 +902,12 @@ fail:
>  static int __iommu_remove_mapping(struct device *dev, dma_addr_t iova, size_t size)
>  {
>  	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> -	unsigned int count = size >> PAGE_SHIFT;
> +	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
>  	int i;
> 
> -	for (i=0; i<count; i++) {
> -		iommu_unmap(mapping->domain, iova, 0);
> -		iova += PAGE_SIZE;
> -	}
> +	iova = iova & PAGE_MASK;
> +	for (i=0; i<count; i++)
> +		iommu_unmap(mapping->domain, iova + i * PAGE_SIZE, 0);
>  	__free_iova(mapping, iova, size);
>  	return 0;
>  }
> @@ -906,7 +915,6 @@ static int __iommu_remove_mapping(struct device *dev, dma_addr_t iova,
> size_t si
>  static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
>  	    dma_addr_t *handle, gfp_t gfp, struct dma_attrs *attrs)
>  {
> -	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
>  	pgprot_t prot = __get_dma_pgprot(attrs, pgprot_kernel);
>  	struct page **pages;
>  	void *addr = NULL;
> @@ -914,11 +922,9 @@ static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
>  	*handle = ~0;
>  	size = PAGE_ALIGN(size);
> 
> -	mutex_lock(&mapping->lock);
> -
>  	pages = __iommu_alloc_buffer(dev, size, gfp);
>  	if (!pages)
> -		goto err_unlock;
> +		goto exit;
> 
>  	*handle = __iommu_create_mapping(dev, pages, size);
>  	if (*handle == ~0)
> @@ -928,15 +934,13 @@ static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
>  	if (!addr)
>  		goto err_mapping;
> 
> -	mutex_unlock(&mapping->lock);
>  	return addr;
> 
>  err_mapping:
>  	__iommu_remove_mapping(dev, *handle, size);
>  err_buffer:
>  	__iommu_free_buffer(dev, pages, size);
> -err_unlock:
> -	mutex_unlock(&mapping->lock);
> +exit:
>  	return NULL;
>  }
> 
> @@ -944,11 +948,9 @@ static int arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct
> *vma,
>  		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
>  		    struct dma_attrs *attrs)
>  {
> -	unsigned long user_size;
>  	struct arm_vmregion *c;
> 
>  	vma->vm_page_prot = __get_dma_pgprot(attrs, vma->vm_page_prot);
> -	user_size = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
> 
>  	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
>  	if (c) {
> @@ -981,11 +983,9 @@ static int arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct
> *vma,
>  void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,
>  			  dma_addr_t handle, struct dma_attrs *attrs)
>  {
> -	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
>  	struct arm_vmregion *c;
>  	size = PAGE_ALIGN(size);
> 
> -	mutex_lock(&mapping->lock);
>  	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
>  	if (c) {
>  		struct page **pages = c->priv;
> @@ -993,7 +993,6 @@ void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,
>  		__iommu_remove_mapping(dev, handle, size);
>  		__iommu_free_buffer(dev, pages, size);
>  	}
> -	mutex_unlock(&mapping->lock);
>  }
> 
>  static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
> @@ -1001,80 +1000,93 @@ static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
>  			  enum dma_data_direction dir)
>  {
>  	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> -	dma_addr_t dma_addr, iova;
> +	dma_addr_t iova;
>  	int ret = 0;
> +	unsigned long i;
> +	phys_addr_t phys = page_to_phys(sg_page(sg));
> 
> +	size = PAGE_ALIGN(size);
>  	*handle = ~0;
> -	mutex_lock(&mapping->lock);
> 
> -	iova = dma_addr = __alloc_iova(mapping, size);
> -	if (dma_addr == 0)
> -		goto fail;
> -
> -	while (size) {
> -		unsigned int phys = page_to_phys(sg_page(sg));
> -		unsigned int len = sg->offset + sg->length;
> +	iova = __alloc_iova(mapping, size);
> +	if (iova == 0)
> +		return -ENOMEM;
> 
> -		if (!arch_is_coherent())
> -			__dma_page_cpu_to_dev(sg_page(sg), sg->offset, sg->length, dir);
> -
> -		while (len) {
> -			ret = iommu_map(mapping->domain, iova, phys, 0, 0);
> -			if (ret < 0)
> -				goto fail;
> -			iova += PAGE_SIZE;
> -			len -= PAGE_SIZE;
> -			size -= PAGE_SIZE;
> -		}
> -		sg = sg_next(sg);
> +	if (!arch_is_coherent())
> +		__dma_page_cpu_to_dev(sg_page(sg), sg->offset,
> +					sg->length, dir);
> +	for (i = 0; i < (size >> PAGE_SHIFT); i++) {
> +		ret = iommu_map(mapping->domain, iova + i * PAGE_SIZE,
> +				phys + i * PAGE_SIZE, 0, 0);
> +		if (ret < 0)
> +			goto fail;
>  	}
> -
> -	*handle = dma_addr;
> -	mutex_unlock(&mapping->lock);
> +	*handle = iova;
> 
>  	return 0;
>  fail:
> +	while (i--)
> +		iommu_unmap(mapping->domain, iova + i * PAGE_SIZE, 0);
> +
>  	__iommu_remove_mapping(dev, iova, size);
> -	mutex_unlock(&mapping->lock);
>  	return ret;
>  }
> 
> +static dma_addr_t arm_iommu_map_page(struct device *dev, struct page *page,
> +	     unsigned long offset, size_t size, enum dma_data_direction dir,
> +	     struct dma_attrs *attrs)
> +{
> +	dma_addr_t dma_addr;
> +
> +	if (!arch_is_coherent())
> +		__dma_page_cpu_to_dev(page, offset, size, dir);
> +
> +	BUG_ON((offset+size) > PAGE_SIZE);
> +	dma_addr = __iommu_create_mapping(dev, &page, PAGE_SIZE);
> +	return dma_addr + offset;
> +}
> +
> +static void arm_iommu_unmap_page(struct device *dev, dma_addr_t handle,
> +		size_t size, enum dma_data_direction dir,
> +		struct dma_attrs *attrs)
> +{
> +	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> +	phys_addr_t phys;
> +
> +	phys = iommu_iova_to_phys(mapping->domain, handle);
> +	__iommu_remove_mapping(dev, handle, size);
> +	if (!arch_is_coherent())
> +		__dma_page_dev_to_cpu(pfn_to_page(__phys_to_pfn(phys)),
> +				      phys & ~PAGE_MASK, size, dir);
> +}
> +
>  int arm_iommu_map_sg(struct device *dev, struct scatterlist *sg, int nents,
>  		     enum dma_data_direction dir, struct dma_attrs *attrs)
>  {
> -	struct scatterlist *s = sg, *dma = sg, *start = sg;
> -	int i, count = 1;
> -	unsigned int offset = s->offset;
> -	unsigned int size = s->offset + s->length;
> +	struct scatterlist *s;
> +	unsigned int size;
> +	int i, count = 0;
> 
> -	for (i = 1; i < nents; i++) {
> +	for_each_sg(sg, s, nents, i) {
>  		s->dma_address = ~0;
>  		s->dma_length = 0;
> +		size = s->offset + s->length;
> 
> -		s = sg_next(s);
> -
> -		if (s->offset || (size & (PAGE_SIZE - 1))) {
> -			if (__map_sg_chunk(dev, start, size, &dma->dma_address, dir) < 0)
> -				goto bad_mapping;
> -
> -			dma->dma_address += offset;
> -			dma->dma_length = size;
> +		if (__map_sg_chunk(dev, s, size, &s->dma_address, dir) < 0)
> +			goto bad_mapping;
> 
> -			size = offset = s->offset;
> -			start = s;
> -			dma = sg_next(dma);
> -			count += 1;
> -		}
> -		size += sg->length;
> +		s->dma_address += s->offset;
> +		s->dma_length = s->length;
> +		count++;
>  	}
> -	__map_sg_chunk(dev, start, size, &dma->dma_address, dir);
> -	d->dma_address += offset;
> 
>  	return count;
> 
>  bad_mapping:
> -	for_each_sg(sg, s, count-1, i)
> -		__iommu_remove_mapping(dev, sg_dma_address(s), sg_dma_len(s));
> +	for_each_sg(sg, s, count, i) {
> +		__iommu_remove_mapping(dev, sg_dma_address(s),
> +					PAGE_ALIGN(sg_dma_len(s)));
> +	}
>  	return 0;
>  }

It looks that You have simplified arm_iommu_map_sg() function too much. 
The main advantage of the iommu is to map scattered memory pages into 
contiguous dma address space. DMA-mapping is allowed to merge consecutive
entries in the scatter list if hardware supports that. With IOMMU a call
to map_sg() might create only one dma element if the memory described by
the scatter list can be seen as contiguous (all chunks start and end on
page boundary). This means that arm_iommu_map_sg() should map all pages
into dma address returned in sg_dma_address(sg[0]) sg_dma_len(sg[0]) 
pair. I'm also not convinced that this is the best approach, but that's
how I was told to implement it: 

http://article.gmane.org/gmane.linux.kernel/1128416

I agree that the API will be a bit cleaner if there is separate function 
to map a scatter list into dma address space chunk-by-chunk (like 
dma_map_sg() does it in most cases) and a function to map a scatter list
into one contiguous dma address. This would also simplify the buffer 
management in the device drivers.

I'm not sure if mmc drivers are aware of coalescing the SG entries together.
If not the code must be updated to use dma_sg_len() and the dma entries
number returned from dma_map_sg() call.

(snipped)

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
