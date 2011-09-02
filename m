Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EB94690013C
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 09:56:33 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LQW0060FEQ5A530@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 02 Sep 2011 14:56:29 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LQW000WLEQ53Q@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 02 Sep 2011 14:56:29 +0100 (BST)
Date: Fri, 02 Sep 2011 15:56:24 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [RFC 0/2 v2] ARM: DMA-mapping & IOMMU integration
Message-id: <1314971786-15140-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

Hello,

This short patch series is a snapshot of my proof-of-concept integration
of the generic IOMMU interface with DMA-mapping framework for ARM
architecture and Samsung IOMMU driver.

In this version I rebased the code onto the updated DMA-mapping
framework posted a few minutes ago. Management of io address space have
been moved from genalloc to pure bitmap-based allocator. I've also added
support for mapping a scatterlist with dma_map_sg/dma_unmap_sg. DMA
scatterlist interface turned out to be a bit tricky task. Scatterlist
may describe a set of disjoint buffers that cannot be easily merged
together if they don't start and end on page boundary. In such case we
need to allocate more than one buffer in io address space and map
respective pages. This results in a code that might be bit hard to
understand in the first try.

Right now the code support only 4KiB pages.

The patches have been tested on Samsung Exynos4 platform and FIMC
device. Samsung IOMMU driver has been provided for the reference. It is
still a work-in-progress code, but because of my holidays I wanted to
avoid delaying it further.

Here is the link to the intial version of my ARM & DMA-mapping
integration patches: http://www.spinics.net/lists/linux-mm/msg19856.html

All the patches will be available on the following GIT tree:
git://git.infradead.org/users/kmpark/linux-2.6-samsung dma-mapping-v3

Git web interface:
http://git.infradead.org/users/kmpark/linux-2.6-samsung/shortlog/refs/heads/dma-mapping-v3

Future:

1. Add all missing operations for IOMMU mappings (map_single/page/sync_*)

2. Move sync_* operations into separate function for better code sharing
between iommu and non-iommu dma-mapping code

3. Rebase onto CMA patches and solve the issue with double mapping and
page attributes

4. Add support for pages larger than 4KiB.

Please note that this is very early version of patches, definitely NOT
intended for merging. I just wanted to make sure that the direction is
right and share the code with others that might want to cooperate on
dma-mapping improvements.

Best regards
--
Marek Szyprowski
Samsung Poland R&D Center

Patch summary:

Andrzej Pietrasiewicz (1):
  ARM: Samsung: update/rewrite Samsung SYSMMU (IOMMU) driver

Marek Szyprowski (1):
  ARM: initial proof-of-concept IOMMU mapper for DMA-mapping

 arch/arm/Kconfig                               |    7 +
 arch/arm/include/asm/device.h                  |    4 +
 arch/arm/include/asm/dma-iommu.h               |   29 +
 arch/arm/mach-exynos4/Kconfig                  |    5 -
 arch/arm/mach-exynos4/Makefile                 |    2 +-
 arch/arm/mach-exynos4/clock.c                  |   47 +-
 arch/arm/mach-exynos4/dev-sysmmu.c             |  609 +++++++++++------
 arch/arm/mach-exynos4/include/mach/irqs.h      |   34 +-
 arch/arm/mach-exynos4/include/mach/sysmmu.h    |   46 --
 arch/arm/mm/dma-mapping.c                      |  504 ++++++++++++++-
 arch/arm/mm/vmregion.h                         |    2 +-
 arch/arm/plat-s5p/Kconfig                      |   21 +-
 arch/arm/plat-s5p/include/plat/sysmmu.h        |  119 ++--
 arch/arm/plat-s5p/sysmmu.c                     |  855 ++++++++++++++++++------
 arch/arm/plat-samsung/include/plat/devs.h      |    1 -
 arch/arm/plat-samsung/include/plat/fimc-core.h |   25 +
 16 files changed, 1724 insertions(+), 586 deletions(-)
 create mode 100644 arch/arm/include/asm/dma-iommu.h
 delete mode 100644 arch/arm/mach-exynos4/include/mach/sysmmu.h

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
