Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 0E1D86B005D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 08:04:19 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout4.samsung.com [203.254.224.34])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M7T00L1AIUVH860@mailout4.samsung.com> for
 linux-mm@kvack.org; Fri, 27 Jul 2012 21:04:08 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M7T00HELIUD2SA0@mmp2.samsung.com> for linux-mm@kvack.org;
 Fri, 27 Jul 2012 21:04:07 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv5 0/2] ARM: replace custom consistent dma region with vmalloc
Date: Fri, 27 Jul 2012 14:03:37 +0200
Message-id: <1343390619-20456-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>, Minchan Kim <minchan@kernel.org>

Hello!

This is yet another quick update on the patchset which replaces custom 
consistent dma regions usage in dma-mapping framework in favour of
generic vmalloc areas created on demand for each allocation. The main
purpose for this patchset is to remove 2MiB limit of dma
coherent/writecombine allocations.

This version addresses a few minor issues pointed by Minchan Kim.

This patch is based on vanilla v3.5 release.

Best regards
Marek Szyprowski
Samsung Poland R&D Center

Changelog:

v5:
- fixed another minor issues pointed by Minchan Kim: added more comments
  here and there, changed pr_err() + stack_dump() to WARN(), added a fix
  for no-MMU systems

v4: http://thread.gmane.org/gmane.linux.kernel.mm/80906
- replaced arch-independent VM_DMA flag with ARM-specific
  VM_ARM_DMA_CONSISTENT flag

v3: http://thread.gmane.org/gmane.linux.kernel.mm/80028
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


Marek Szyprowski (2):
  mm: vmalloc: use const void * for caller argument
  ARM: dma-mapping: remove custom consistent dma region

 Documentation/kernel-parameters.txt |    2 +-
 arch/arm/include/asm/dma-mapping.h  |    2 +-
 arch/arm/mm/dma-mapping.c           |  511 +++++++++++++----------------------
 arch/arm/mm/mm.h                    |    3 +
 include/linux/vmalloc.h             |    9 +-
 mm/vmalloc.c                        |   28 ++-
 6 files changed, 210 insertions(+), 345 deletions(-)

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
