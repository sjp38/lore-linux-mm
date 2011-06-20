Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A74BF6B00E7
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 03:50:40 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LN200A0PWGEY870@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 08:50:38 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LN2005S5WG8O3@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 08:50:37 +0100 (BST)
Date: Mon, 20 Jun 2011 09:50:05 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH/RFC 0/8] ARM: DMA-mapping framework redesign
Message-id: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

Hello,

This patch series is a continuation of my works on implementing generic
IOMMU support in DMA mapping framework for ARM architecture. Now I
focused on the DMA mapping framework itself. It turned out that adding
support for common dma_map_ops structure was not that hard as I initally
thought. After some modification most of the code fits really well to
the generic dma_map_ops methods.

The only change required to dma_map_ops is a new alloc function. During
the discussion on Linaro Memory Management meeting in Budapest we got
the idea that we can have only one alloc/free/mmap function with
additional attributes argument. This way all different kinds of
architecture specific buffer mappings can be hidden behind the
attributes without the need of creating several versions of dma_alloc_
function. I also noticed that the dma_alloc_noncoherent() function can
be also implemented this way with DMA_ATTRIB_NON_COHERENT attribute.
Systems that just defines dma_alloc_noncoherent as dma_alloc_coherent
will just ignore such attribute.

Another good use case for alloc methods with attributes is the
possibility to allocate buffer without a valid kernel mapping. There are
a number of drivers (mainly V4L2 and ALSA) that only exports the DMA
buffers to user space. Such drivers don't touch the buffer data at all.
For such buffers we can avoid the creation of a mapping in kernel
virtual address space, saving precious vmalloc area. Such buffers might
be allocated once a new attribute DMA_ATTRIB_NO_KERNEL_MAPPING.

All the changes introduced in this patch series are intended to prepare
a good ground for upcoming generic IOMMU integration to DMA mapping
framework on ARM architecture.

For more information about proof-of-concept IOMMU implementation in DMA
mapping framework, please refer to my previous set of patches:
http://www.spinics.net/lists/linux-mm/msg19856.html

I've tried to split the redesign into a set of single-step changes for
easier review and understanding. If there is anything that needs further
clarification, please don't hesitate to ask.

The patches are prepared on top of Linux Kernel v3.0-rc3.

The proposed changes have been tested on Samsung Exynos4 platform. I've
also tested dmabounce code (by manually registering support for DMA
bounce for some of the devices available on my board), although my
hardware have no such strict requirements. Would be great if one could
test my patches on different ARM architectures to check if I didn't
break anything.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



Patch summary:

Marek Szyprowski (8):
  ARM: dma-mapping: remove offset parameter to prepare for generic
    dma_ops
  ARM: dma-mapping: implement dma_map_single on top of dma_map_page
  ARM: dma-mapping: use asm-generic/dma-mapping-common.h
  ARM: dma-mapping: implement dma sg methods on top of generic dma ops
  ARM: dma-mapping: move all dma bounce code to separate dma ops
    structure
  ARM: dma-mapping: remove redundant code and cleanup
  common: dma-mapping: change alloc/free_coherent method to more
    generic alloc/free_attrs
  ARM: dma-mapping: use alloc, mmap, free from dma_ops

 arch/arm/Kconfig                   |    1 +
 arch/arm/common/dmabounce.c        |  112 +++--
 arch/arm/include/asm/device.h      |    1 +
 arch/arm/include/asm/dma-mapping.h |  835 +++++++++++++-----------------------
 arch/arm/mm/dma-mapping.c          |  278 +++++++------
 include/linux/dma-attrs.h          |    1 +
 include/linux/dma-mapping.h        |   13 +-
 7 files changed, 539 insertions(+), 702 deletions(-)
 rewrite arch/arm/include/asm/dma-mapping.h (66%)

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
