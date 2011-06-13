Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7A76C6B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:12:17 -0400 (EDT)
Received: by ywb26 with SMTP id 26so2636969ywb.14
        for <linux-mm@kvack.org>; Mon, 13 Jun 2011 07:12:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
Date: Mon, 13 Jun 2011 23:12:05 +0900
Message-ID: <BANLkTi=HtrFETnjk1Zu0v9wqa==r0OALvA@mail.gmail.com>
Subject: Re: [RFC 0/2] ARM: DMA-mapping & IOMMU integration
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

I don't think dma_alloc_writecombine() is useful
because it is actually not different from dma_alloc_coherent().
Moreover, no architecture implements it except ARM and AVR32
and 'struct dma_map_ops' in <linux/dma-mapping.h> does not cover it.

The only difference of dma_alloc_writecombine() from dma_alloc_coherent() i=
s
whether a caller needs to decide to use memory barrier after call
dma_alloc_writecombine().

Of course, the mapping created by by dma_alloc_writecombine()
may be more efficient for CPU to update the DMA buffer.
But I think mapping with dma_alloc_coherent() is not such a
performance bottleneck.

I think it is better to remove dma_alloc_writecombine() and replace
all of it with dma_alloc_coherent().

In addition, IMHO, mapping to user's address is not a duty of dma_map_ops.
dma_mmap_*() is not suitable for a system that has IOMMU
because a DMA address does not equal to its correspondent physical
address semantically.

I think DMA APIs of ARM must be changed drastically to support IOMMU
because IOMMU API does not manage virtual address space.

I've also concerned about IOMMU implementation in ARM architecture for
several months.
But i found that there are some obstacles to overcome.

Best regards.

On Wed, May 25, 2011 at 4:35 PM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
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
> http://git.infradead.org/users/kmpark/linux-2.6-samsung/shortlog/refs/hea=
ds/dma-mapping
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
> 7. resolve issues that might araise during discussion & comments
>
> Please note that this is very early version of patches, definitely NOT
> intended for merging. I just wanted to make sure that the direction is
> right and share the code with others that might want to cooperate on
> dma-mapping improvements.
>
> Best regards
> --
> Marek Szyprowski
> Samsung Poland R&D Center
>
>
>
> Patch summary:
>
> Marek Szyprowski (2):
> =A0ARM: Move dma related inlines into arm_dma_ops methods
> =A0ARM: initial proof-of-concept IOMMU mapper for DMA-mapping
>
> =A0arch/arm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0arch/arm/include/asm/device.h =A0 =A0 =A0| =A0 =A03 +
> =A0arch/arm/include/asm/dma-iommu.h =A0 | =A0 30 ++
> =A0arch/arm/include/asm/dma-mapping.h | =A0653 +++++++++++---------------=
---
> =A0arch/arm/mm/dma-mapping.c =A0 =A0 =A0 =A0 =A0| =A0817 ++++++++++++++++=
+++++++++++++++++---
> =A0arch/arm/mm/vmregion.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0include/linux/dma-attrs.h =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A07 files changed, 1033 insertions(+), 474 deletions(-)
> =A0create mode 100644 arch/arm/include/asm/dma-iommu.h
>
> --
> 1.7.1.569.g6f426
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
