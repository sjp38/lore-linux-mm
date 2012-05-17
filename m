Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 229C46B0044
	for <linux-mm@kvack.org>; Thu, 17 May 2012 12:53:27 -0400 (EDT)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M46009HIEWTFB@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 17 May 2012 17:53:17 +0100 (BST)
Received: from ubuntu.arm.acom ([106.210.236.191])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M46008IQEWVMY@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 17:53:25 +0100 (BST)
Date: Thu, 17 May 2012 18:53:03 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH/RFC 0/3] ARM: DMA-mapping: new extensions for buffer sharing
Message-id: <1337273586-11089-1-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subash.ramaswamy@linaro.org>, Sumit Semwal <sumit.semwal@linaro.org>, Abhinav Kochhar <abhinav.k@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

Hello,

This patch series introduces a new features to DMA mapping subsystem
to let drivers share the allocated buffers (preferably using recently
introduced dma_buf framework) easy and efficient.

The first extension is DMA_ATTR_NO_KERNEL_MAPPING attribute. It is
intended for use with dma_{alloc, mmap, free}_attrs functions. It can be
used to notify dma-mapping core that the driver will not use kernel
mapping for the allocated buffer at all, so the core can skip creating
it. This saves precious kernel virtual address space. Such buffer can be
accessed from userspace, after calling dma_mmap_attrs() for it (a
typical use case for multimedia buffers). The value returned by
dma_alloc_attrs() with this attribute should be considered as a DMA
cookie, which needs to be passed to dma_mmap_attrs() and
dma_free_attrs() funtions.

The second extension is required to let drivers to share the buffers
allocated by DMA-mapping subsystem. Right now the driver gets a dma
address of the allocated buffer and the kernel virtual mapping for it.
If it wants to share it with other device (= map into its dma address
space) it usually hacks around kernel virtual addresses to get pointers
to pages or assumes that both devices share the DMA address space. Both
solutions are just hacks for the special cases, which should be avoided
in the final version of buffer sharing. To solve this issue in a generic
way, a new call to DMA mapping has been introduced - dma_get_sgtable().
It allocates a scatter-list which describes the allocated buffer and
lets the driver(s) to use it with other device(s) by calling
dma_map_sg() on it.

The proposed patches have been generated on top of the ARM DMA-mapping
redesign patch series on Linux v3.4-rc7. They are also available on the
following GIT branch:

git://git.linaro.org/people/mszyprowski/linux-dma-mapping.git 3.4-rc7-arm-dma-v10-ext

with all require patches on top of vanilla v3.4-rc7 kernel.

Best regards
Marek Szyprowski
Samsung Poland R&D Center


Patch summary:

Marek Szyprowski (3):
  common: DMA-mapping: add DMA_ATTR_NO_KERNEL_MAPPING attribute
  ARM: dma-mapping: add support for DMA_ATTR_NO_KERNEL_MAPPING
    attribute
  ARM: dma-mapping: add support for dma_get_sgtable()

 Documentation/DMA-attributes.txt   |   18 +++++++++++++
 arch/arm/include/asm/dma-mapping.h |   12 +++++++++
 arch/arm/mm/dma-mapping.c          |   51 ++++++++++++++++++++++++++++++++----
 include/linux/dma-attrs.h          |    1 +
 include/linux/dma-mapping.h        |    3 +++
 5 files changed, 80 insertions(+), 5 deletions(-)

-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
