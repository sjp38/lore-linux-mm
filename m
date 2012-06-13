Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id EF21B6B0071
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 07:50:48 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout4.samsung.com [203.254.224.34])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5K00EYJ0WM5100@mailout4.samsung.com> for
 linux-mm@kvack.org; Wed, 13 Jun 2012 20:50:47 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5K00JMG0WB4X70@mmp1.samsung.com> for linux-mm@kvack.org;
 Wed, 13 Jun 2012 20:50:46 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv2 0/6] ARM: DMA-mapping: new extensions for buffer sharing
Date: Wed, 13 Jun 2012 13:50:12 +0200
Message-id: <1339588218-24398-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subash.ramaswamy@linaro.org>, Sumit Semwal <sumit.semwal@linaro.org>, Abhinav Kochhar <abhinav.k@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

Hello,

This is an updated version of the patch series introducing a new
features to DMA mapping subsystem to let drivers share the allocated
buffers (preferably using recently introduced dma_buf framework) easy
and efficient.

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

The third extension solves the performance issues which we observed with
some advanced buffer sharing use cases, which require creating a dma
mapping for the same memory buffer for more than one device. From the
DMA-mapping perspective this requires to call one of the
dma_map_{page,single,sg} function for the given memory buffer a few
times, for each of the devices. Each dma_map_* call performs CPU cache
synchronization, what might be a time consuming operation, especially
when the buffers are large. We would like to avoid any useless and time
consuming operations, so that was the main reason for introducing
another attribute for DMA-mapping subsystem: DMA_ATTR_SKIP_CPU_SYNC,
which lets dma-mapping core to skip CPU cache synchronization in certain
cases.

The proposed patches have been rebased on the latest Linux kernel
v3.5-rc2 with 'ARM: replace custom consistent dma region with vmalloc'
patches applied (for more information, please refer to the 
http://www.spinics.net/lists/arm-kernel/msg179202.html thread).

The patches together with all dependences are also available on the
following GIT branch:

git://git.linaro.org/people/mszyprowski/linux-dma-mapping.git 3.5-rc2-dma-ext-v2

Best regards
Marek Szyprowski
Samsung Poland R&D Center

Changelog:

v2:
- rebased onto v3.5-rc2 and adapted for CMA and dma-mapping changes
- renamed dma_get_sgtable() to dma_get_sgtable_attrs() to match the convention
  of the other dma-mapping calls with attributes
- added generic fallback function for dma_get_sgtable() for architectures with
  simple dma-mapping implementations

v1: http://thread.gmane.org/gmane.linux.kernel.mm/78644
    http://thread.gmane.org/gmane.linux.kernel.cross-arch/14435 (part 2)
- initial version

Patch summary:

Marek Szyprowski (6):
  common: DMA-mapping: add DMA_ATTR_NO_KERNEL_MAPPING attribute
  ARM: dma-mapping: add support for DMA_ATTR_NO_KERNEL_MAPPING
    attribute
  common: dma-mapping: introduce dma_get_sgtable() function
  ARM: dma-mapping: add support for dma_get_sgtable()
  common: DMA-mapping: add DMA_ATTR_SKIP_CPU_SYNC attribute
  ARM: dma-mapping: add support for DMA_ATTR_SKIP_CPU_SYNC attribute

 Documentation/DMA-attributes.txt         |   42 ++++++++++++++++++
 arch/arm/common/dmabounce.c              |    1 +
 arch/arm/include/asm/dma-mapping.h       |    3 +
 arch/arm/mm/dma-mapping.c                |   69 ++++++++++++++++++++++++------
 drivers/base/dma-mapping.c               |   18 ++++++++
 include/asm-generic/dma-mapping-common.h |   18 ++++++++
 include/linux/dma-attrs.h                |    2 +
 include/linux/dma-mapping.h              |    3 +
 8 files changed, 142 insertions(+), 14 deletions(-)

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
