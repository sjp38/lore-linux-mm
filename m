Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 104806B004A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 18:22:03 -0500 (EST)
Date: Tue, 6 Mar 2012 23:21:38 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
Message-ID: <20120306232138.GF15201@n2100.arm.linux.org.uk>
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com> <1330527862-16234-10-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1330527862-16234-10-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, Feb 29, 2012 at 04:04:22PM +0100, Marek Szyprowski wrote:
> +static int arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma,
> +		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
> +		    struct dma_attrs *attrs)
> +{
> +	struct arm_vmregion *c;
> +
> +	vma->vm_page_prot = __get_dma_pgprot(attrs, vma->vm_page_prot);
> +	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);

What protects this against other insertions/removals from the list?

> +
> +	if (c) {
> +		struct page **pages = c->priv;
> +
> +		unsigned long uaddr = vma->vm_start;
> +		unsigned long usize = vma->vm_end - vma->vm_start;
> +		int i = 0;
> +
> +		do {
> +			int ret;
> +
> +			ret = vm_insert_page(vma, uaddr, pages[i++]);
> +			if (ret) {
> +				pr_err("Remapping memory, error: %d\n", ret);
> +				return ret;
> +			}
> +
> +			uaddr += PAGE_SIZE;
> +			usize -= PAGE_SIZE;
> +		} while (usize > 0);
> +	}
> +	return 0;
> +}
> +
> +/*
> + * free a page as defined by the above mapping.
> + * Must not be called with IRQs disabled.
> + */
> +void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,
> +			  dma_addr_t handle, struct dma_attrs *attrs)
> +{
> +	struct arm_vmregion *c;
> +	size = PAGE_ALIGN(size);
> +
> +	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);

What protects this against other insertions/removals from the list?

> +	if (c) {
> +		struct page **pages = c->priv;
> +		__dma_free_remap(cpu_addr, size);
> +		__iommu_remove_mapping(dev, handle, size);
> +		__iommu_free_buffer(dev, pages, size);
> +	}
> +}
> +
> +/*
> + * Map a part of the scatter-gather list into contiguous io address space
> + */
> +static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
> +			  size_t size, dma_addr_t *handle,
> +			  enum dma_data_direction dir)
> +{
> +	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> +	dma_addr_t iova, iova_base;
> +	int ret = 0;
> +	unsigned int count;
> +	struct scatterlist *s;
> +
> +	size = PAGE_ALIGN(size);
> +	*handle = ARM_DMA_ERROR;
> +
> +	iova_base = iova = __alloc_iova(mapping, size);
> +	if (iova == ARM_DMA_ERROR)
> +		return -ENOMEM;
> +
> +	for (count = 0, s = sg; count < (size >> PAGE_SHIFT); s = sg_next(s))
> +	{
> +		phys_addr_t phys = page_to_phys(sg_page(s));
> +		unsigned int len = PAGE_ALIGN(s->offset + s->length);
> +
> +		if (!arch_is_coherent())
> +			__dma_page_cpu_to_dev(sg_page(s), s->offset, s->length, dir);
> +
> +		ret = iommu_map(mapping->domain, iova, phys, len, 0);

Dealing with phys addresses on one part and pages + offset + length
in a different part doesn't look like a good idea.  Why can't there
be some consistency?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
