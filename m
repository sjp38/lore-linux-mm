Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 855AD6B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 11:10:32 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M0F00LXI69I0I00@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 05 Mar 2012 16:10:30 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M0F00DTX63RAI@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 05 Mar 2012 16:07:03 +0000 (GMT)
Date: Mon, 05 Mar 2012 17:07:02 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
In-reply-to: <20120305134721.0ab0d0e6de56fa30250059b1@nvidia.com>
Message-id: <000001ccfaea$00c16f70$02444e50$%szyprowski@samsung.com>
Content-language: pl
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
 <1330527862-16234-10-git-send-email-m.szyprowski@samsung.com>
 <20120305134721.0ab0d0e6de56fa30250059b1@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hiroshi Doyu' <hdoyu@nvidia.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'KyongHo Cho' <pullip.cho@samsung.com>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>

Hello,

On Monday, March 05, 2012 12:47 PM Hiroshi Doyu wrote:

> On Wed, 29 Feb 2012 16:04:22 +0100
> Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> 
> > This patch add a complete implementation of DMA-mapping API for
> > devices that have IOMMU support. All DMA-mapping calls are supported.
> >
> > This patch contains some of the code kindly provided by Krishna Reddy
> > <vdumpa@nvidia.com> and Andrzej Pietrasiewicz <andrzej.p@samsung.com>
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > ---

(snipped)

> > +/**
> > + * arm_iommu_create_mapping
> > + * @bus: pointer to the bus holding the client device (for IOMMU calls)
> > + * @base: start address of the valid IO address space
> > + * @size: size of the valid IO address space
> > + * @order: accuracy of the IO addresses allocations
> > + *
> > + * Creates a mapping structure which holds information about used/unused
> > + * IO address ranges, which is required to perform memory allocation and
> > + * mapping with IOMMU aware functions.
> > + *
> > + * The client device need to be attached to the mapping with
> > + * arm_iommu_attach_device function.
> > + */
> > +struct dma_iommu_mapping *
> > +arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t size,
> > +                        int order)
> > +{
> > +       unsigned int count = (size >> PAGE_SHIFT) - order;
> > +       unsigned int bitmap_size = BITS_TO_LONGS(count) * sizeof(long);
> > +       struct dma_iommu_mapping *mapping;
> > +       int err = -ENOMEM;
> > +
> > +       mapping = kzalloc(sizeof(struct dma_iommu_mapping), GFP_KERNEL);
> > +       if (!mapping)
> > +               goto err;
> > +
> > +       mapping->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> > +       if (!mapping->bitmap)
> > +               goto err2;
> > +
> > +       mapping->base = base;
> > +       mapping->bits = bitmap_size;
> 
> Shouldn't the above be as below?
> 
> From 093c77ac6f19899679f2f2447a9d2c684eab7b2e Mon Sep 17 00:00:00 2001
> From: Hiroshi DOYU <hdoyu@nvidia.com>
> Date: Mon, 5 Mar 2012 13:04:38 +0200
> Subject: [PATCH 1/1] dma-mapping: Fix mapping->bits size
> 
> Amount of bits should be mutiplied by BITS_PER_BITE.
> 
> Signed-off-by: Hiroshi DOYU <hdoyu@nvidia.com>
> ---
>  arch/arm/mm/dma-mapping.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index e55f425..5ec7747 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -1495,7 +1495,7 @@ arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t
> size,
>  		goto err2;
> 
>  	mapping->base = base;
> -	mapping->bits = bitmap_size;
> +	mapping->bits = BITS_PER_BYTE * bitmap_size;
>  	mapping->order = order;
>  	spin_lock_init(&mapping->lock);

You are right, thanks for spotting this issue!

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
