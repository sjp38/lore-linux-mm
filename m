Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 7E1AA6B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 02:46:11 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LYE005RXAWXNJ10@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Jan 2012 07:46:09 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LYE00MX9AWWGI@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Jan 2012 07:46:09 +0000 (GMT)
Date: Thu, 26 Jan 2012 08:46:05 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 8/8] ARM: dma-mapping: add support for IOMMU mapper
In-reply-to: <20120125144727.2722b4a1fb8017dd3633d7ad@nvidia.com>
Message-id: <007401ccdbfe$8f024ad0$ad06e070$%szyprowski@samsung.com>
Content-language: pl
References: <1323448798-18184-1-git-send-email-m.szyprowski@samsung.com>
 <1323448798-18184-9-git-send-email-m.szyprowski@samsung.com>
 <20120125144727.2722b4a1fb8017dd3633d7ad@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hiroshi Doyu' <hdoyu@nvidia.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'KyongHo Cho' <pullip.cho@samsung.com>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>

Hello,

On Wednesday, January 25, 2012 1:47 PM Hiroshi Doyu wrote:

> Hi Marek,
> 
> On Fri, 9 Dec 2011 17:39:58 +0100
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
> >
> > Add initial proof of concept implementation of DMA-mapping API for
> > devices that have IOMMU support. Right now only dma_alloc_coherent,
> > dma_free_coherent and dma_mmap_coherent functions are supported.
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > ---
> >  arch/arm/Kconfig                 |    8 +
> >  arch/arm/include/asm/device.h    |    3 +
> >  arch/arm/include/asm/dma-iommu.h |   36 +++
> >  arch/arm/mm/dma-mapping.c        |  637 +++++++++++++++++++++++++++++++++++++-
> >  arch/arm/mm/vmregion.h           |    2 +-
> >  5 files changed, 671 insertions(+), 15 deletions(-)
> >  create mode 100644 arch/arm/include/asm/dma-iommu.h
> >
> > diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> > index 8827c9b..87416fc 100644
> > --- a/arch/arm/Kconfig
> > +++ b/arch/arm/Kconfig
> > @@ -42,6 +42,14 @@ config ARM
> >  config ARM_HAS_SG_CHAIN
> >         bool
> >
> > +config NEED_SG_DMA_LENGTH
> > +       bool
> > +
> > +config ARM_DMA_USE_IOMMU
> > +       select NEED_SG_DMA_LENGTH
> > +       select ARM_HAS_SG_CHAIN
> > +       bool
> > +
> >  config HAVE_PWM
> >         bool
> >
> > diff --git a/arch/arm/include/asm/device.h b/arch/arm/include/asm/device.h
> > index 6e2cb0e..b69c0d3 100644
> > --- a/arch/arm/include/asm/device.h
> > +++ b/arch/arm/include/asm/device.h
> > @@ -14,6 +14,9 @@ struct dev_archdata {
> >  #ifdef CONFIG_IOMMU_API
> >         void *iommu; /* private IOMMU data */
> >  #endif
> > +#ifdef CONFIG_ARM_DMA_USE_IOMMU
> > +       struct dma_iommu_mapping        *mapping;
> > +#endif
> >  };
> >
> >  struct omap_device;
> > diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-iommu.h
> > new file mode 100644
> > index 0000000..6668b41
> > --- /dev/null
> > +++ b/arch/arm/include/asm/dma-iommu.h
> > @@ -0,0 +1,36 @@
> > +#ifndef ASMARM_DMA_IOMMU_H
> > +#define ASMARM_DMA_IOMMU_H
> > +
> > +#ifdef __KERNEL__
> > +
> > +#include <linux/mm_types.h>
> > +#include <linux/scatterlist.h>
> > +#include <linux/dma-debug.h>
> > +#include <linux/kmemcheck.h>
> > +
> > +#include <asm/memory.h>
> > +
> > +struct dma_iommu_mapping {
> > +       /* iommu specific data */
> > +       struct iommu_domain     *domain;
> > +
> > +       void                    *bitmap;
> > +       size_t                  bits;
> > +       unsigned int            order;
> > +       dma_addr_t              base;
> > +
> > +       spinlock_t              lock;
> > +       struct kref             kref;
> > +};
> > +
> > +struct dma_iommu_mapping *
> > +arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t size,
> > +                        int order);
> > +
> > +void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping);
> > +
> > +int arm_iommu_attach_device(struct device *dev,
> > +                                       struct dma_iommu_mapping *mapping);
> > +
> > +#endif /* __KERNEL__ */
> > +#endif
> > diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> > index 4845c09..7ac5a95 100644
> > --- a/arch/arm/mm/dma-mapping.c
> > +++ b/arch/arm/mm/dma-mapping.c
> > @@ -27,6 +27,9 @@
> >  #include <asm/sizes.h>
> >  #include <asm/mach/arch.h>
> >
> > +#include <linux/iommu.h>
> > +#include <asm/dma-iommu.h>
> > +
> >  #include "mm.h"
> >
> >  /*
> .....
> > +
> > +static void arm_iommu_unmap_page(struct device *dev, dma_addr_t handle,
> > +               size_t size, enum dma_data_direction dir,
> > +               struct dma_attrs *attrs)
> > +{
> > +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> > +       dma_addr_t iova = handle & PAGE_MASK;
> > +       struct page *page = phys_to_page(iommu_iova_to_phys(mapping->domain, iova));
> > +       int offset = handle & ~PAGE_MASK;
> > +
> > +       if (!iova)
> > +               return;
> > +
> > +       if (!arch_is_coherent())
> > +               __dma_page_dev_to_cpu(page, offset, size, dir);
> > +
> > +       iommu_unmap(mapping->domain, iova, size);
> 
> Is __free_iova() needed here as below?
> 
> 	Modified arch/arm/mm/dma-mapping.c
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 9aa1675..66830b2 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -1212,6 +1212,7 @@ static void arm_iommu_unmap_page(struct device *dev, dma_addr_t handle,
> 		__dma_page_dev_to_cpu(page, offset, size, dir);
> 
> 	iommu_unmap(mapping->domain, iova, size);
> +       __free_iova(mapping, iova, size);
>  }

Right, thanks for finding this bug!

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
