Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C3F1E90016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 05:28:04 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LN600GKVQAQ1P@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 22 Jun 2011 10:28:02 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LN600BINQAPSQ@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Jun 2011 10:28:01 +0100 (BST)
Date: Wed, 22 Jun 2011 11:27:55 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCH/RFC 0/8] ARM: DMA-mapping framework redesign
In-reply-to: <4E01AD7B.3070806@gmail.com>
Message-id: <002701cc30be$ab296cc0$017c4640$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <4E017539.30505@gmail.com>
 <001d01cc30a9$ebe5e460$c3b1ad20$%szyprowski@samsung.com>
 <4E01AD7B.3070806@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Subash Patel' <subashrp@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Joerg Roedel' <joro@8bytes.org>, 'Arnd Bergmann' <arnd@arndb.de>, Marek Szyprowski <m.szyprowski@samsung.com>

Hello,

On Wednesday, June 22, 2011 10:53 AM Subash Patel wrote:

> On 06/22/2011 12:29 PM, Marek Szyprowski wrote:
> > Hello,
> >
> > On Wednesday, June 22, 2011 6:53 AM Subash Patel wrote:
> >
> >> On 06/20/2011 01:20 PM, Marek Szyprowski wrote:
> >>> Hello,
> >>>
> >>> This patch series is a continuation of my works on implementing generic
> >>> IOMMU support in DMA mapping framework for ARM architecture. Now I
> >>> focused on the DMA mapping framework itself. It turned out that adding
> >>> support for common dma_map_ops structure was not that hard as I
> initally
> >>> thought. After some modification most of the code fits really well to
> >>> the generic dma_map_ops methods.
> >>>
> >>> The only change required to dma_map_ops is a new alloc function. During
> >>> the discussion on Linaro Memory Management meeting in Budapest we got
> >>> the idea that we can have only one alloc/free/mmap function with
> >>> additional attributes argument. This way all different kinds of
> >>> architecture specific buffer mappings can be hidden behind the
> >>> attributes without the need of creating several versions of dma_alloc_
> >>> function. I also noticed that the dma_alloc_noncoherent() function can
> >>> be also implemented this way with DMA_ATTRIB_NON_COHERENT attribute.
> >>> Systems that just defines dma_alloc_noncoherent as dma_alloc_coherent
> >>> will just ignore such attribute.
> >>>
> >>> Another good use case for alloc methods with attributes is the
> >>> possibility to allocate buffer without a valid kernel mapping. There
> are
> >>> a number of drivers (mainly V4L2 and ALSA) that only exports the DMA
> >>> buffers to user space. Such drivers don't touch the buffer data at all.
> >>> For such buffers we can avoid the creation of a mapping in kernel
> >>> virtual address space, saving precious vmalloc area. Such buffers might
> >>> be allocated once a new attribute DMA_ATTRIB_NO_KERNEL_MAPPING.
> >>
> >> Are you trying to say here, that the buffer would be allocated in the
> >> user space, and we just use it to map it to the device in DMA+IOMMU
> >> framework?
> >
> > Nope. I proposed an extension which would allow you to allocate a buffer
> > without creating the kernel mapping for it. Right now
> dma_alloc_coherent()
> > performs 3 operations:
> > 1. allocates memory for the buffer
> > 2. creates coherent kernel mapping for the buffer
> > 3. translates physical buffer address to DMA address that can be used by
> > the hardware.
> >
> > dma_mmap_coherent makes additional mapping for the buffer in user process
> > virtual address space.
> >
> > I want make the step 2 in dma_alloc_coherent() optional to save virtual
> > address space: it is really limited resource. I really want to avoid
> > wasting it for mapping 128MiB buffers just to create full-HD processing
> > hardware pipeline, where no drivers will use kernel mapping at all.
> >
> 
> I think by (2) above, you are referring to
> __dma_alloc_remap()->arm_vmregion_alloc() to allocate the kernel virtual
> address for the drivers use. That makes sense now.

Well, this is particular implementation which is used on ARM. Other 
architectures might implement it differently, that's why I used generic 
description and didn't point to any particular function.

> I have a query in similar lines, but related to user virtual address
> space. Is it feasible to extend these DMA interfaces(and IOMMU), to map
> a user allocated buffer into the hardware?

This can be done with the current API, although it may not look so 
straightforward. You just need to create a scatter list of user pages
(these can be gathered with get_user_pages function) and use dma_map_sg()
function. If the dma-mapping support iommu, it can map all these pages
into a single contiguous buffer on device (DMA) address space.

Some additional 'magic' might be required to get access to pages that are
mapped with pure PFN (VM_PFNMAP flag), but imho it still can be done.

I will try to implement this feature in videobuf2-dma-config allocator
together with the next version of my patches for dma-mapping&iommu.

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
