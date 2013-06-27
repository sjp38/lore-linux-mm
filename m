Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 9D6AC6B0034
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 07:42:47 -0400 (EDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MP1004A5V70JG10@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 27 Jun 2013 12:42:45 +0100 (BST)
Message-id: <51CC2530.2060605@samsung.com>
Date: Thu, 27 Jun 2013 13:42:40 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC PATCH 1/3] mm/cma: Move dma contiguous changes into a
 seperate config
References: <1372062327-7028-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-reply-to: <1372062327-7028-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, Michal Nazarewicz <mina86@mina86.com>

Hello,

On 6/24/2013 10:25 AM, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>
> We want to use CMA for allocating hash page table and real mode area for
> PPC64. Hence move DMA contiguous related changes into a seperate config
> so that ppc64 can enable CMA without requiring DMA contiguous.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

It's nice to see that CMA is gaining another client in mainline Linux 
kernel.
I also like the idea of adding CONFIG_DMA_CMA for DMA-mapping related CMA
use to let others to use alloc_contig_range() interface.

However I noticed that You have almost copied the whole drivers/base.c for
separate use with PPC64 KVM. Is this really necessary? I think it should be
possible to isolate some common code, which plays with contiguous region
management and use it for both alloc_contig_range() clients (dma-mapping and
ppc64 kvm).

> ---
>   arch/arm/configs/omap2plus_defconfig  |  2 +-
>   arch/arm/configs/tegra_defconfig      |  2 +-
>   arch/arm/include/asm/dma-contiguous.h |  2 +-
>   arch/arm/mm/dma-mapping.c             |  6 +++---
>   drivers/base/Kconfig                  | 21 +++++----------------
>   drivers/base/Makefile                 |  2 +-
>   include/linux/dma-contiguous.h        |  2 +-
>   mm/Kconfig                            | 20 ++++++++++++++++++++
>   8 files changed, 33 insertions(+), 24 deletions(-)
>
> diff --git a/arch/arm/configs/omap2plus_defconfig b/arch/arm/configs/omap2plus_defconfig
> index abbe319..098268f 100644
> --- a/arch/arm/configs/omap2plus_defconfig
> +++ b/arch/arm/configs/omap2plus_defconfig
> @@ -71,7 +71,7 @@ CONFIG_MAC80211=m
>   CONFIG_MAC80211_RC_PID=y
>   CONFIG_MAC80211_RC_DEFAULT_PID=y
>   CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
> -CONFIG_CMA=y
> +CONFIG_DMA_CMA=y
>   CONFIG_CONNECTOR=y
>   CONFIG_DEVTMPFS=y
>   CONFIG_DEVTMPFS_MOUNT=y
> diff --git a/arch/arm/configs/tegra_defconfig b/arch/arm/configs/tegra_defconfig
> index f7ba3161..34ae8f2 100644
> --- a/arch/arm/configs/tegra_defconfig
> +++ b/arch/arm/configs/tegra_defconfig
> @@ -79,7 +79,7 @@ CONFIG_RFKILL_GPIO=y
>   CONFIG_DEVTMPFS=y
>   CONFIG_DEVTMPFS_MOUNT=y
>   # CONFIG_FIRMWARE_IN_KERNEL is not set
> -CONFIG_CMA=y
> +CONFIG_DMA_CMA=y
>   CONFIG_MTD=y
>   CONFIG_MTD_CHAR=y
>   CONFIG_MTD_M25P80=y
> diff --git a/arch/arm/include/asm/dma-contiguous.h b/arch/arm/include/asm/dma-contiguous.h
> index 3ed37b4..e072bb2 100644
> --- a/arch/arm/include/asm/dma-contiguous.h
> +++ b/arch/arm/include/asm/dma-contiguous.h
> @@ -2,7 +2,7 @@
>   #define ASMARM_DMA_CONTIGUOUS_H
>   
>   #ifdef __KERNEL__
> -#ifdef CONFIG_CMA
> +#ifdef CONFIG_DMA_CMA
>   
>   #include <linux/types.h>
>   #include <asm-generic/dma-contiguous.h>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index ef3e0f3..1fb40dc 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -358,7 +358,7 @@ static int __init atomic_pool_init(void)
>   	if (!pages)
>   		goto no_pages;
>   
> -	if (IS_ENABLED(CONFIG_CMA))
> +	if (IS_ENABLED(CONFIG_DMA_CMA))
>   		ptr = __alloc_from_contiguous(NULL, pool->size, prot, &page,
>   					      atomic_pool_init);
>   	else
> @@ -670,7 +670,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
>   		addr = __alloc_simple_buffer(dev, size, gfp, &page);
>   	else if (!(gfp & __GFP_WAIT))
>   		addr = __alloc_from_pool(size, &page);
> -	else if (!IS_ENABLED(CONFIG_CMA))
> +	else if (!IS_ENABLED(CONFIG_DMA_CMA))
>   		addr = __alloc_remap_buffer(dev, size, gfp, prot, &page, caller);
>   	else
>   		addr = __alloc_from_contiguous(dev, size, prot, &page, caller);
> @@ -759,7 +759,7 @@ static void __arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
>   		__dma_free_buffer(page, size);
>   	} else if (__free_from_pool(cpu_addr, size)) {
>   		return;
> -	} else if (!IS_ENABLED(CONFIG_CMA)) {
> +	} else if (!IS_ENABLED(CONFIG_DMA_CMA)) {
>   		__dma_free_remap(cpu_addr, size);
>   		__dma_free_buffer(page, size);
>   	} else {
> diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
> index 07abd9d..74b7c98 100644
> --- a/drivers/base/Kconfig
> +++ b/drivers/base/Kconfig
> @@ -202,11 +202,10 @@ config DMA_SHARED_BUFFER
>   	  APIs extension; the file's descriptor can then be passed on to other
>   	  driver.
>   
> -config CMA
> -	bool "Contiguous Memory Allocator"
> -	depends on HAVE_DMA_CONTIGUOUS && HAVE_MEMBLOCK
> -	select MIGRATION
> -	select MEMORY_ISOLATION
> +config DMA_CMA
> +	bool "DMA Contiguous Memory Allocator"
> +	depends on HAVE_DMA_CONTIGUOUS
> +	select CMA
>   	help
>   	  This enables the Contiguous Memory Allocator which allows drivers
>   	  to allocate big physically-contiguous blocks of memory for use with
> @@ -215,17 +214,7 @@ config CMA
>   	  For more information see <include/linux/dma-contiguous.h>.
>   	  If unsure, say "n".
>   
> -if CMA
> -
> -config CMA_DEBUG
> -	bool "CMA debug messages (DEVELOPMENT)"
> -	depends on DEBUG_KERNEL
> -	help
> -	  Turns on debug messages in CMA.  This produces KERN_DEBUG
> -	  messages for every CMA call as well as various messages while
> -	  processing calls such as dma_alloc_from_contiguous().
> -	  This option does not affect warning and error messages.
> -
> +if  DMA_CMA
>   comment "Default contiguous memory area size:"
>   
>   config CMA_SIZE_MBYTES
> diff --git a/drivers/base/Makefile b/drivers/base/Makefile
> index 4e22ce3..5d93bb5 100644
> --- a/drivers/base/Makefile
> +++ b/drivers/base/Makefile
> @@ -6,7 +6,7 @@ obj-y			:= core.o bus.o dd.o syscore.o \
>   			   attribute_container.o transport_class.o \
>   			   topology.o
>   obj-$(CONFIG_DEVTMPFS)	+= devtmpfs.o
> -obj-$(CONFIG_CMA) += dma-contiguous.o
> +obj-$(CONFIG_DMA_CMA) += dma-contiguous.o
>   obj-y			+= power/
>   obj-$(CONFIG_HAS_DMA)	+= dma-mapping.o
>   obj-$(CONFIG_HAVE_GENERIC_DMA_COHERENT) += dma-coherent.o
> diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.h
> index 01b5c84..00141d3 100644
> --- a/include/linux/dma-contiguous.h
> +++ b/include/linux/dma-contiguous.h
> @@ -57,7 +57,7 @@ struct cma;
>   struct page;
>   struct device;
>   
> -#ifdef CONFIG_CMA
> +#ifdef CONFIG_DMA_CMA
>   
>   /*
>    * There is always at least global CMA area and a few optional device
> diff --git a/mm/Kconfig b/mm/Kconfig
> index e742d06..b362369 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -477,3 +477,23 @@ config FRONTSWAP
>   	  and swap data is stored as normal on the matching swap device.
>   
>   	  If unsure, say Y to enable frontswap.
> +
> +config CMA
> +	bool "Contiguous Memory Allocator"
> +	depends on HAVE_MEMBLOCK
> +	select MIGRATION
> +	select MEMORY_ISOLATION
> +	help
> +	  This enables the Contiguous Memory Allocator which allows other
> +	  subsystem to allocate big physically-contiguous blocks of memory
> +
> +	  If unsure, say "n".
> +
> +config CMA_DEBUG
> +	bool "CMA debug messages (DEVELOPMENT)"
> +	depends on DEBUG_KERNEL && CMA
> +	help
> +	  Turns on debug messages in CMA.  This produces KERN_DEBUG
> +	  messages for every CMA call as well as various messages while
> +	  processing calls such as dma_alloc_from_contiguous().
> +	  This option does not affect warning and error messages.

Best regards
-- 
Marek Szyprowski
Samsung R&D Institute Poland


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
