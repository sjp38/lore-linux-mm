Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 3BB7D6B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 07:04:26 -0400 (EDT)
Received: from euspt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M2900L81G1QUP@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 10 Apr 2012 12:03:26 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2900HVPG39K7@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 10 Apr 2012 12:04:21 +0100 (BST)
Date: Tue, 10 Apr 2012 13:04:02 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv8 00/10] ARM: DMA-mapping framework redesign
Message-id: <1334055852-19500-1-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

Hello,

Linux v3.4-rc2, which include dma-mapping preparation patches, has been
released two days ago, now it's time for the next spin of ARM
dma-mapping redesign patches. This version includes various fixes posted
separately to v7, mainly related to incorrect io address space bitmap
setup and a major issue with broken mmap for memory which comes from
dma_declare_coherent(). The patches have been also rebased onto Linux
v3.4-rc2 which comes with dma_map_ops related changes.

The code has been tested on Samsung Exynos4 'UniversalC210' and NURI
boards with IOMMU driver posted by KyongHo Cho, I will put separate
branch which shows how to integrate this driver with this patchset.

The patches are also available on my git repository at:
git://git.linaro.org/people/mszyprowski/linux-dma-mapping.git 3.4-rc2-arm-dma-v8


History of the development:

v1: (initial version of the DMA-mapping redesign patches):
http://www.spinics.net/lists/linux-mm/msg21241.html

v2:
http://lists.linaro.org/pipermail/linaro-mm-sig/2011-September/000571.html
http://lists.linaro.org/pipermail/linaro-mm-sig/2011-September/000577.html

v3:
http://www.spinics.net/lists/linux-mm/msg25490.html

v4 and v5:
http://www.spinics.net/lists/arm-kernel/msg151147.html
http://www.spinics.net/lists/arm-kernel/msg154889.html

v6:
http://www.spinics.net/lists/linux-mm/msg29903.html

v7:
http://www.spinics.net/lists/arm-kernel/msg162149.html

Best regards
Marek Szyprowski
Samsung Poland R&D Center


Patch summary:

Marek Szyprowski (10):
  common: add dma_mmap_from_coherent() function
  ARM: dma-mapping: use pr_* instread of printk
  ARM: dma-mapping: introduce ARM_DMA_ERROR constant
  ARM: dma-mapping: remove offset parameter to prepare for generic
    dma_ops
  ARM: dma-mapping: use asm-generic/dma-mapping-common.h
  ARM: dma-mapping: implement dma sg methods on top of any generic dma
    ops
  ARM: dma-mapping: move all dma bounce code to separate dma ops
    structure
  ARM: dma-mapping: remove redundant code and cleanup
  ARM: dma-mapping: use alloc, mmap, free from dma_ops
  ARM: dma-mapping: add support for IOMMU mapper

 arch/arm/Kconfig                   |    9 +
 arch/arm/common/dmabounce.c        |   84 +++-
 arch/arm/include/asm/device.h      |    4 +
 arch/arm/include/asm/dma-iommu.h   |   34 ++
 arch/arm/include/asm/dma-mapping.h |  407 ++++-----------
 arch/arm/mm/dma-mapping.c          | 1019 ++++++++++++++++++++++++++++++------
 arch/arm/mm/vmregion.h             |    2 +-
 drivers/base/dma-coherent.c        |   42 ++
 include/asm-generic/dma-coherent.h |    4 +-
 9 files changed, 1138 insertions(+), 467 deletions(-)
 create mode 100644 arch/arm/include/asm/dma-iommu.h

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
