Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id F0EA76B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 07:59:41 -0500 (EST)
Date: Wed, 25 Jan 2012 12:59:16 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 8/8 RESEND] ARM: dma-mapping: add support for IOMMU
	mapper
Message-ID: <20120125125916.GE1068@n2100.arm.linux.org.uk>
References: <1323448798-18184-9-git-send-email-m.szyprowski@samsung.com> <1326124161-2220-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1326124161-2220-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Mon, Jan 09, 2012 at 04:49:21PM +0100, Marek Szyprowski wrote:
> This patch add a complete implementation of DMA-mapping API for
> devices that have IOMMU support. All DMA-mapping calls are supported.
> 
> This patch contains some of the code kindly provided by Krishna Reddy
> <vdumpa@nvidia.com> and Andrzej Pietrasiewicz <andrzej.p@samsung.com>
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> 
> ---
> 
> Hello,
> 
> This is the corrected version of the previous patch from the "[PATCH 0/8
> v4] ARM: DMA-mapping framework redesign" thread which can be found here:
> http://www.spinics.net/lists/linux-mm/msg27382.html
> 
> Previous version had very nasty bug which causes memory trashing if
> DMA-mapping managed to allocate pages larger than 4KiB. The problem was
> in __iommu_alloc_buffer() function which did not check how many pages
> has been left to allocate.

This patch seems to be incomplete.

If the standard DMA API is used (the one which exists in current kernels)
and NEED_SG_DMA_LENGTH is enabled, then where do we set the DMA length
in the scatterlist?

> diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-iommu.h
> new file mode 100644
> index 0000000..6668b41
> --- /dev/null
> +++ b/arch/arm/include/asm/dma-iommu.h
> @@ -0,0 +1,36 @@
> +#ifndef ASMARM_DMA_IOMMU_H
> +#define ASMARM_DMA_IOMMU_H
> +
> +#ifdef __KERNEL__
> +
> +#include <linux/mm_types.h>
> +#include <linux/scatterlist.h>
> +#include <linux/dma-debug.h>
> +#include <linux/kmemcheck.h>
> +
> +#include <asm/memory.h>

I can't see anything in here which needs asm/memory.h - if files which
include this need it, please include it in there so we can see why it's
needed.

> +
> +struct dma_iommu_mapping {
> +	/* iommu specific data */
> +	struct iommu_domain	*domain;
> +
> +	void			*bitmap;
> +	size_t			bits;
> +	unsigned int		order;
> +	dma_addr_t		base;
> +
> +	spinlock_t		lock;
> +	struct kref		kref;
> +};
> +
> +struct dma_iommu_mapping *
> +arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t size,
> +			 int order);
> +
> +void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping);
> +
> +int arm_iommu_attach_device(struct device *dev,
> +					struct dma_iommu_mapping *mapping);
> +
> +#endif /* __KERNEL__ */
> +#endif
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 4845c09..2287b01 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -27,6 +27,9 @@
>  #include <asm/sizes.h>
>  #include <asm/mach/arch.h>
>  
> +#include <linux/iommu.h>

linux/ includes should be grouped together.

> diff --git a/arch/arm/mm/vmregion.h b/arch/arm/mm/vmregion.h
> index 15e9f04..6bbc402 100644
> --- a/arch/arm/mm/vmregion.h
> +++ b/arch/arm/mm/vmregion.h
> @@ -17,7 +17,7 @@ struct arm_vmregion {
>  	struct list_head	vm_list;
>  	unsigned long		vm_start;
>  	unsigned long		vm_end;
> -	struct page		*vm_pages;
> +	void			*priv;

I want to think about that - I may wish to export the vm_pages via
the new dma-mappings file to provide additional information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
