Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 8494B6B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 11:17:31 -0500 (EST)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M0I004B8VX5AU@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 07 Mar 2012 16:17:29 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M0I00C54VX5VZ@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 07 Mar 2012 16:17:29 +0000 (GMT)
Date: Wed, 07 Mar 2012 17:17:25 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
In-reply-to: <20120306232138.GF15201@n2100.arm.linux.org.uk>
Message-id: <00f801ccfc7d$c8da6810$5a8f3830$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
 <1330527862-16234-10-git-send-email-m.szyprowski@samsung.com>
 <20120306232138.GF15201@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'KyongHo Cho' <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>

Hello,

On Wednesday, March 07, 2012 12:22 AM Russell King - ARM Linux wrote:

> On Wed, Feb 29, 2012 at 04:04:22PM +0100, Marek Szyprowski wrote:
> > +static int arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma,
> > +		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
> > +		    struct dma_attrs *attrs)
> > +{
> > +	struct arm_vmregion *c;
> > +
> > +	vma->vm_page_prot = __get_dma_pgprot(attrs, vma->vm_page_prot);
> > +	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
> 
> What protects this against other insertions/removals from the list?

arm_vmregion_* functions have their own spinlock.

(snipped)

> > +	if (c) {
> > +		struct page **pages = c->priv;
> > +		__dma_free_remap(cpu_addr, size);
> > +		__iommu_remove_mapping(dev, handle, size);
> > +		__iommu_free_buffer(dev, pages, size);
> > +	}
> > +}
> > +
> > +/*
> > + * Map a part of the scatter-gather list into contiguous io address space
> > + */
> > +static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
> > +			  size_t size, dma_addr_t *handle,
> > +			  enum dma_data_direction dir)
> > +{
> > +	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> > +	dma_addr_t iova, iova_base;
> > +	int ret = 0;
> > +	unsigned int count;
> > +	struct scatterlist *s;
> > +
> > +	size = PAGE_ALIGN(size);
> > +	*handle = ARM_DMA_ERROR;
> > +
> > +	iova_base = iova = __alloc_iova(mapping, size);
> > +	if (iova == ARM_DMA_ERROR)
> > +		return -ENOMEM;
> > +
> > +	for (count = 0, s = sg; count < (size >> PAGE_SHIFT); s = sg_next(s))
> > +	{
> > +		phys_addr_t phys = page_to_phys(sg_page(s));
> > +		unsigned int len = PAGE_ALIGN(s->offset + s->length);
> > +
> > +		if (!arch_is_coherent())
> > +			__dma_page_cpu_to_dev(sg_page(s), s->offset, s->length, dir);
> > +
> > +		ret = iommu_map(mapping->domain, iova, phys, len, 0);
> 
> Dealing with phys addresses on one part and pages + offset + length
> in a different part doesn't look like a good idea.  Why can't there
> be some consistency?

Well, I have no idea how to be more consistent here. scatter-lists operates on 
pages + offsets + length parameters. iommu api operates on the whole pages, but
they are referred with physical address. Right now I cannot change any of it, 
at least not it the near future.

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
