Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B7D026B00FF
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 10:31:34 -0400 (EDT)
Received: by pzk4 with SMTP id 4so4556647pzk.14
        for <linux-mm@kvack.org>; Mon, 20 Jun 2011 07:31:32 -0700 (PDT)
Message-ID: <4DFF59BB.100@gmail.com>
Date: Mon, 20 Jun 2011 20:01:23 +0530
From: Subash Patel <subashrp@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/2] ARM: DMA-mapping & IOMMU integration
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joerg Roedel <joro@8bytes.org>, Arnd Bergmann <arnd@arndb.de>

Hi Marek,

In function: 
dma_alloc_coherent()->arm_iommu_alloc_attrs()->__iommu_alloc_buffer()

I have following questions:

a) Before we come to this point, we would have enabled SYSMMU in a call 
to arm_iommu_init(). Shouldnt the SYSMMU be enabled after call to 
__iommu_alloc_buffer(), but before __iommu_create_mapping()? If in case 
the __iommu_alloc_buffer() fails, we dont disable the SYSMMU.

b) For huge buffer sizes, the pressure on SYSMMU would be very high. 
Cant we have option to dictate the page size for the IOMMU from driver 
in such cases? Should it always be the size of system pages?

Regards,
Subash
SISO-SLG

On 05/25/2011 01:05 PM, Marek Szyprowski wrote:
> Hello,
>
> Folloing the discussion about the driver for IOMMU controller for
> Samsung Exynos4 platform and Arnd's suggestions I've decided to start
> working on redesign of dma-mapping implementation for ARM architecture.
> The goal is to add support for IOMMU in the way preffered by the
> community :)
>
> Some of the ideas about merging dma-mapping api and iommu api comes from
> the following threads:
> http://www.spinics.net/lists/linux-media/msg31453.html
> http://www.spinics.net/lists/arm-kernel/msg122552.html
> http://www.spinics.net/lists/arm-kernel/msg124416.html
>
> They were also discussed on Linaro memory management meeting at UDS
> (Budapest 9-12 May).
>
> I've finaly managed to clean up a bit my works and present the initial,
> very proof-of-concept version of patches that were ready just before
> Linaro meeting.
>
> What have been implemented:
>
> 1. Introduced arm_dma_ops
>
> dma_map_ops from include/linux/dma-mapping.h suffers from the following
> limitations:
> - lack of start address for sync operations
> - lack of write-combine methods
> - lack of mmap to user-space methods
> - lack of map_single method
>
> For the initial version I've decided to use custom arm_dma_ops.
> Extending common interface will take time, until that I wanted to have
> something already working.
>
> dma_{alloc,free,mmap}_{coherent,writecombine} have been consolidated
> into dma_{alloc,free,mmap}_attrib what have been suggested on Linaro
> meeting. New attribute for WRITE_COMBINE memory have been introduced.
>
> 2. moved all inline ARM dma-mapping related operations to
> arch/arm/mm/dma-mapping.c and put them as methods in generic arm_dma_ops
> structure. The dma-mapping.c code deinitely needs cleanup, but this is
> just a first step.
>
> 3. Added very initial IOMMU support. Right now it is limited only to
> dma_alloc_attrib, dma_free_attrib and dma_mmap_attrib. It have been
> tested with s5p-fimc driver on Samsung Exynos4 platform.
>
> 4. Adapted Samsung Exynos4 IOMUU driver to make use of the introduced
> iommu_dma proposal.
>
> This patch series contains only patches for common dma-mapping part.
> There is also a patch that adds driver for Samsung IOMMU controller on
> Exynos4 platform. All required patches are available on:
>
> git://git.infradead.org/users/kmpark/linux-2.6-samsung dma-mapping branch
>
> Git web interface:
> http://git.infradead.org/users/kmpark/linux-2.6-samsung/shortlog/refs/heads/dma-mapping
>
>
> Future:
>
> 1. Add all missing operations for IOMMU mappings (map_single/page/sg,
> sync_*)
>
> 2. Move sync_* operations into separate function for better code sharing
> between iommu and non-iommu dma-mapping code
>
> 3. Splitting out dma bounce code from non-bounce into separate set of
> dma methods. Right now dma-bounce code is compiled conditionally and
> spread over arch/arm/mm/dma-mapping.c and arch/arm/common/dmabounce.c.
>
> 4. Merging dma_map_single with dma_map_page. I haven't investigated
> deeply why they have separate implementation on ARM. If this is a
> requirement then dma_map_ops need to be extended with another method.
>
> 5. Fix dma_alloc to unmap from linear mapping.
>
> 6. Convert IO address space management code from gen-alloc to some
> simpler bitmap based solution.
>
> 7. resolve issues that might araise during discussion&  comments
>
> Please note that this is very early version of patches, definitely NOT
> intended for merging. I just wanted to make sure that the direction is
> right and share the code with others that might want to cooperate on
> dma-mapping improvements.
>
> Best regards

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
