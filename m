Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 78A176B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 03:50:38 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from spt2.w1.samsung.com ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LP3006JX4GAKF20@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 29 Jul 2011 08:50:34 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LP3009I24G95P@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 29 Jul 2011 08:50:33 +0100 (BST)
Date: Fri, 29 Jul 2011 09:50:32 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [RFC] ARM: dma_map|unmap_sg plus iommu
In-reply-to: 
 <CAB-zwWjb+2ExjNDB3OtHmRmgaHMnO-VgEe9VZk_wU=ryrq_AGw@mail.gmail.com>
Message-id: <000301cc4dc4$31b53630$951fa290$%szyprowski@samsung.com>
Content-language: pl
References: <CAB-zwWjb+2ExjNDB3OtHmRmgaHMnO-VgEe9VZk_wU=ryrq_AGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Ramirez Luna, Omar'" <omar.ramirez@ti.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Joerg Roedel' <joro@8bytes.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Ohad Ben-Cohen' <ohad@wizery.com>, 'Marek Szyprowski' <m.szyprowski@samsung.com>

Hello,

On Thursday, July 28, 2011 11:10 PM Ramirez Luna, Omar wrote:

> I know it is very early but here it is a tryout of the dma_map_sg and
> dma_unmap_sg with iommu, I made it to roughly understand what is needed to
> remove drivers/omap-iovmm.c (which is a virtual memory manager
> implementation on top of omap iommu driver).
> 
> This patch is placed on top of Marek Szyprowsk initial work:
> 
> ARM: DMA-mapping & IOMMU integration
> http://thread.gmane.org/gmane.linux.kernel.mm/63727/
> 
> It was tested on an OMAP zoom3 platform and tidspbridge driver. The patch
> is used to map user space buffers to dsp's iommu, get_user_pages is used to
> form the sg list that will be passed to dma_map_sg.
> 
> While at it, I bumped into some issues that I would like to get some
> feedback or know if they are being considered:
> 
> 1. There is no way to keep track of what virtual address are being mapped
> in the scatterlist, which we need to propagate to the dsp, in order that it
> knows where does the buffers start and end on its virtual address space.
> I ended up adding an iov_address to scatterlist which if accepted should be
> toggled/affected by the selection of CONFIG_IOMMU_API.

Sorry, but your patch is completely wrong. You should not add any additional
entries to scatterlist. dma_addr IS the virtual address in the device's io 
address space, so the dma_addr is a value that your device should put into 
it's own registers to start dma transfer to provided memory pages.

> 2. tidspbridge driver sometimes needs to map a physical address into a
> fixed virtual address (i.e. the start of a firmware section is expected to
> be at dsp va 0x20000000), there is no straight forward way to do this with
> the dma api given that it only expects to receive a cpu_addr, a sg or a
> page, by adding iov_address I could pass phys and iov addresses in a sg
> and overcome this limitation, but, these addresses belong to:

We also encountered the problem of fixed firmware address. We addressed is by
setting io address space start to this address and letting device driver to
rely on the fact that the first call to dma_alloc() will match this address. 

>   2a. Shared memory between ARM and DSP: this memory is allocated through
>       memblock API which takes it out of kernel control to be later
>       ioremap'd and iommu map'd to the dsp (this because a non-cacheable
>       requirement), so, these physical addresses doesn't have a linear
>       virtual address translation, which is what dma api expects.

I hope that the issue with page cache attributes can be resolved if we always
allocate memory from CMA (see the latest CMAv12 patches: 
http://www.spinics.net/lists/linux-media/msg35674.html )

>   2b. Bus addresses: of dsp peripherals which are also ioremap'd and
>       affected by the same thing.

Right now I have no idea how to handle ioremapped areas in dma-mapping 
framework, but do we really need to support them?

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
