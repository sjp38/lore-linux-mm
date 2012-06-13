Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 72D556B0070
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 07:02:14 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout4.samsung.com [203.254.224.34])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5J0008AYNOQ111@mailout4.samsung.com> for
 linux-mm@kvack.org; Wed, 13 Jun 2012 20:02:12 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5J00EDHYN9NO40@mmp2.samsung.com> for linux-mm@kvack.org;
 Wed, 13 Jun 2012 20:02:12 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv3 0/3] ARM: replace custom consistent dma region with vmalloc
Date: Wed, 13 Jun 2012 13:01:43 +0200
Message-id: <1339585306-7147-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>, Minchan Kim <minchan@kernel.org>

Hello!

This patchset replaces custom consistent dma regions usage in
dma-mapping framework in favour of generic vmalloc areas created on
demand for each allocation. The main purpose for this patchset is to
remove 2MiB limit of dma coherent/writecombine allocations.

Atomic allocations are served from special pool preallocated on boot,
becasue vmalloc areas cannot be reliably created in atomic context.

Linux v3.5-rc1 introduced a lot of changes to ARM dma-mapping subsystem
(CMA and dmamap_ops based implementation has been finally merged), so
the previous version of these patches is not applicable anymore. This
version provides an update required for applying them on v3.5-rc2 kernel
as well as some changes requested by Minchan Kim in his review.

This patch is based on vanilla v3.5-rc2 release.

Atomic allocations have been tested with s3c-sdhci driver on Samsung
UniversalC210 board with dmabounce code enabled to force
dma_alloc_coherent() use on each dma_map_* call (some of them are made
from interrupts).

Best regards
Marek Szyprowski
Samsung Poland R&D Center

Changelog:

v3:
- rebased onto v3.4-rc2: added support for IOMMU-aware implementation 
  of dma-mapping calls, unified with CMA coherent dma pool
- implemented changes requested by Minchan Kim: added more checks for
  vmarea->flags & VM_DMA, renamed some variables, removed obsole locks,
  squashed find_vm_area() exporting patch into the main redesign patch 

v2: http://thread.gmane.org/gmane.linux.kernel.mm/78563
- added support for atomic allocations (served from preallocated pool)
- minor cleanup here and there
- rebased onto v3.4-rc7

v1: http://thread.gmane.org/gmane.linux.kernel.mm/76703
- initial version

Patch summary:

Marek Szyprowski (3):
  mm: vmalloc: use const void * for caller argument
  mm: vmalloc: add VM_DMA flag to indicate areas used by dma-mapping
    framework
  ARM: dma-mapping: remove custom consistent dma region

 Documentation/kernel-parameters.txt |    2 +-
 arch/arm/include/asm/dma-mapping.h  |    2 +-
 arch/arm/mm/dma-mapping.c           |  503 ++++++++++++-----------------------
 include/linux/vmalloc.h             |   10 +-
 mm/vmalloc.c                        |   31 ++-
 5 files changed, 206 insertions(+), 342 deletions(-)

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
