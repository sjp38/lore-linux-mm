Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 807EF9000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 10:50:50 -0400 (EDT)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LRV0041FNWM3M@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 21 Sep 2011 15:50:46 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LRV000HMNWMTS@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Sep 2011 15:50:46 +0100 (BST)
Date: Wed, 21 Sep 2011 16:50:41 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCH 1/2] ARM: initial proof-of-concept IOMMU
 mapper for DMA-mapping
In-reply-to: <594816116217195c28de13accaf1f9f2.squirrel@www.codeaurora.org>
Message-id: <001f01cc786d$d55222c0$7ff66840$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1314971786-15140-1-git-send-email-m.szyprowski@samsung.com>
 <1314971786-15140-2-git-send-email-m.szyprowski@samsung.com>
 <594816116217195c28de13accaf1f9f2.squirrel@www.codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Laura Abbott' <lauraa@codeaurora.org>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>

Hello,

On Thursday, September 08, 2011 6:42 PM Laura Abbott wrote:

> Hi, a few comments
> On Fri, September 2, 2011 6:56 am, Marek Szyprowski wrote:
> ...
> > +
> > +struct dma_iommu_mapping {
> > +	/* iommu specific data */
> > +	struct iommu_domain	*domain;
> > +
> > +	void			*bitmap;
> 
> In the earlier version of this patch you had this as a genpool instead of
> just doing the bitmaps manually. Is there a reason genpool can't be used
> to get the iova addresses?

IMHO genpool was a bit overkill in this case and required some additional
patches for aligned allocations. In the next version I also want to extend
this bitmap based allocator to dynamically resize the bitmap for more than
one page if the io address space gets exhausted. 

> > +	size_t			bits;
> > +	unsigned int		order;
> > +	dma_addr_t		base;
> > +
> > +	struct mutex		lock;
> > +};
> <snip>
> > +int arm_iommu_attach_device(struct device *dev, dma_addr_t base, size_t
> > size, int order)
> > +{
> > +	unsigned int count = (size >> PAGE_SHIFT) - order;
> > +	unsigned int bitmap_size = BITS_TO_LONGS(count) * sizeof(long);
> > +	struct dma_iommu_mapping *mapping;
> > +	int err = -ENOMEM;
> > +
> > +	mapping = kzalloc(sizeof(struct dma_iommu_mapping), GFP_KERNEL);
> > +	if (!mapping)
> > +		goto err;
> > +
> > +	mapping->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> > +	if (!mapping->bitmap)
> > +		goto err2;
> > +
> > +	mapping->base = base;
> > +	mapping->bits = bitmap_size;
> > +	mapping->order = order;
> > +	mutex_init(&mapping->lock);
> > +
> > +	mapping->domain = iommu_domain_alloc();
> > +	if (!mapping->domain)
> > +		goto err3;
> > +
> > +	err = iommu_attach_device(mapping->domain, dev);
> > +	if (err != 0)
> > +		goto err4;
> > +
> > +	dev->archdata.mapping = mapping;
> > +	set_dma_ops(dev, &iommu_ops);
> > +
> > +	printk(KERN_INFO "Attached IOMMU controller to %s device.\n",
> > dev_name(dev));
> > +	return 0;
> > +
> > +err4:
> > +	iommu_domain_free(mapping->domain);
> > +err3:
> > +	kfree(mapping->bitmap);
> > +err2:
> > +	kfree(mapping);
> > +err:
> > +	return -ENOMEM;
> > +}
> > +EXPORT_SYMBOL(arm_iommu_attach_device);
> > +
> > +#endif

> Attach makes the assumption that each iommu device will exist in a
> separate domain. What if multiple devices want to use the same iommu
> domain? The msm iommu implementation has many different iommu devices but
> many of these will need the same buffer to be mapped in each context so
> currently many devices share the same domain. Without this, the same map
> call would need to happen for each device, which creates extra map calls
> and overhead.

Ah, right. I forgot about the case when devices need to share one domain.
Moving iommu_domain_alloc out of arm_iommu_attach_device and giving that
function just a pointer to the iommu domain should solve this issue. I will
change this in the next version of the patches.

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
