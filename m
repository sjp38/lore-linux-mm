Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 669AB6B00F4
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 07:58:40 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv8 10/10] ARM: dma-mapping: add support for IOMMU mapper
Date: Tue, 10 Apr 2012 11:58:29 +0000
References: <1334055852-19500-1-git-send-email-m.szyprowski@samsung.com> <1334055852-19500-11-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1334055852-19500-11-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 8bit
Message-Id: <201204101158.29590.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org, Kyungmin Park <kyungmin.park@samsung.com>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

On Tuesday 10 April 2012, Marek Szyprowski wrote:
> +/**
> + * arm_iommu_create_mapping
> + * @bus: pointer to the bus holding the client device (for IOMMU calls)
> + * @base: start address of the valid IO address space
> + * @size: size of the valid IO address space
> + * @order: accuracy of the IO addresses allocations
> + *
> + * Creates a mapping structure which holds information about used/unused
> + * IO address ranges, which is required to perform memory allocation and
> + * mapping with IOMMU aware functions.
> + *
> + * The client device need to be attached to the mapping with
> + * arm_iommu_attach_device function.
> + */
> +struct dma_iommu_mapping *
> +arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t size,
> +                        int order)
> +{
> +       unsigned int count = size >> (PAGE_SHIFT + order);
> +       unsigned int bitmap_size = BITS_TO_LONGS(count) * sizeof(long);
> +       struct dma_iommu_mapping *mapping;
> +       int err = -ENOMEM;
> +
> +       if (!count)
> +               return ERR_PTR(-EINVAL);
> +
> +       mapping = kzalloc(sizeof(struct dma_iommu_mapping), GFP_KERNEL);
> +       if (!mapping)
> +               goto err;
> +
> +       mapping->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> +       if (!mapping->bitmap)
> +               goto err2;
> +
> +       mapping->base = base;
> +       mapping->bits = BITS_PER_BYTE * bitmap_size;
> +       mapping->order = order;
> +       spin_lock_init(&mapping->lock);
> +
> +       mapping->domain = iommu_domain_alloc(bus);
> +       if (!mapping->domain)
> +               goto err3;
> +
> +       kref_init(&mapping->kref);
> +       return mapping;
> +err3:
> +       kfree(mapping->bitmap);
> +err2:
> +       kfree(mapping);
> +err:
> +       return ERR_PTR(err);
> +}
> +EXPORT_SYMBOL(arm_iommu_create_mapping);

I don't understand this function, mostly I guess because you have not
provided any users. A few questions here:

* What is ARM specific about it that it is named arm_iommu_create_mapping?
  Isn't this completely generic, at least on the interface side?

* Why is this exported to modules? Which device drivers do you expect
  to call it?

* Why do you pass the bus_type in here? That seems like the completely
  wrong thing to do when all devices are on the same bus type (e.g.
  amba or platform) but are connected to different instances that each
  have their own iommu. I guess this is a question for Jorg, because the
  base iommu interface provides iommu_domain_alloc().

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
