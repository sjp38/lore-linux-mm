Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id EA94F6B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 04:00:20 -0400 (EDT)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M1M004BMZJKX1@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 29 Mar 2012 08:59:44 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1M001ZXZKID0@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 29 Mar 2012 09:00:18 +0100 (BST)
Date: Thu, 29 Mar 2012 10:00:14 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
In-reply-to: <20120329101927.8ab6b1993475b7e16ae2258f@nvidia.com>
Message-id: <01b301cd0d81$f935d750$eba185f0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
 <1330527862-16234-10-git-send-email-m.szyprowski@samsung.com>
 <20120329101927.8ab6b1993475b7e16ae2258f@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hiroshi Doyu' <hdoyu@nvidia.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'KyongHo Cho' <pullip.cho@samsung.com>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>

Hello,

On Thursday, March 29, 2012 9:19 AM Hiroshi Doyu wrote:

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
> >  arch/arm/Kconfig                 |    8 +
> >  arch/arm/include/asm/device.h    |    3 +
> >  arch/arm/include/asm/dma-iommu.h |   34 ++
> >  arch/arm/mm/dma-mapping.c        |  726 +++++++++++++++++++++++++++++++++++++-
> >  arch/arm/mm/vmregion.h           |    2 +-
> >  5 files changed, 758 insertions(+), 15 deletions(-)
> >  create mode 100644 arch/arm/include/asm/dma-iommu.h
> >
> 
> <snip>
> 
> > +/*
> > + * Map a part of the scatter-gather list into contiguous io address space
> > + */
> > +static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
> > +                         size_t size, dma_addr_t *handle,
> > +                         enum dma_data_direction dir)
> > +{
> > +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> > +       dma_addr_t iova, iova_base;
> > +       int ret = 0;
> > +       unsigned int count;
> > +       struct scatterlist *s;
> > +
> > +       size = PAGE_ALIGN(size);
> > +       *handle = ARM_DMA_ERROR;
> > +
> > +       iova_base = iova = __alloc_iova(mapping, size);
> > +       if (iova == ARM_DMA_ERROR)
> > +               return -ENOMEM;
> > +
> > +       for (count = 0, s = sg; count < (size >> PAGE_SHIFT); s = sg_next(s))
> > +       {
> > +               phys_addr_t phys = page_to_phys(sg_page(s));
> > +               unsigned int len = PAGE_ALIGN(s->offset + s->length);
> > +
> > +               if (!arch_is_coherent())
> > +                       __dma_page_cpu_to_dev(sg_page(s), s->offset, s->length, dir);
> > +
> > +               ret = iommu_map(mapping->domain, iova, phys, len, 0);
> > +               if (ret < 0)
> > +                       goto fail;
> > +               count += len >> PAGE_SHIFT;
> > +               iova += len;
> > +       }
> > +       *handle = iova_base;
> > +
> > +       return 0;
> > +fail:
> > +       iommu_unmap(mapping->domain, iova_base, count * PAGE_SIZE);
> > +       __free_iova(mapping, iova_base, size);
> > +       return ret;
> > +}
> 
> Do we need to set dma_address as below?

Nope, this one is not correct. Please check the arm_iommu_map_sg() function. It calls 
__map_sg_chunk() and gives it &dma->dma_address as one of the arguments, so the dma 
address is correctly stored in the scatter list. Please note that scatterlist is really
non-trivial structure and information about physical memory pages/chunks is disjoint 
from the information about dma address space chunks, although both are stored on the 
same list. In arm_iommu_map_sg() 's' pointer is used for physical memory chunks and 
'dma' pointer is used for dma address space chunks. 

The number of dma address space chunks (returned by arm_iommu_map_sq) can be lower 
than the number of physical memory chunks (given as nents argument).

In case of IOMMU you usually construct the scatter list in such a way, that you get
only one dma address chunk (so in fact you get a buffer mapped contiguously in 
virtual io address space).

> From e8bcc3cdac5375b5d7f5ac5b3f716a11c1008f38 Mon Sep 17 00:00:00 2001
> From: Hiroshi DOYU <hdoyu@nvidia.com>
> Date: Thu, 29 Mar 2012 09:59:04 +0300
> Subject: [PATCH 1/1] ARM: dma-mapping: Fix dma_address in sglist
> 
> s->dma_address wasn't set at mapping.
> 
> Signed-off-by: Hiroshi DOYU <hdoyu@nvidia.com>
> ---
>  arch/arm/mm/dma-mapping.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 3347c37..11a9d65 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -1111,6 +1111,8 @@ static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
>  		ret = iommu_map(mapping->domain, iova, phys, len, 0);
>  		if (ret < 0)
>  			goto fail;
> +		s->dma_address = iova;
> +
>  		count += len >> PAGE_SHIFT;
>  		iova += len;
>  	}

The above patch is not needed at all.

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
