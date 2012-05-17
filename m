Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 40D1D6B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 06:55:00 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M450065OYAB7340@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 11:54:11 +0100 (BST)
Received: from ubuntu.arm.acom ([106.210.236.191])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4500MKCYBFX2@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 11:54:57 +0100 (BST)
Date: Thu, 17 May 2012 12:54:41 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv2 0/4] ARM: replace custom consistent dma region with vmalloc
Message-id: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

Hello!

Recent changes to ioremap and unification of vmalloc regions on ARM
significantly reduces the possible size of the consistent dma region.
They are significantly limited allowed dma coherent/writecombine
allocations.

This experimental patchset replaces custom consistent dma regions usage
in dma-mapping framework in favour of generic vmalloc areas created on
demand for each coherent and writecombine allocations. The main purpose
for this patchset is to remove 2MiB limit of dma coherent/writecombine
allocations.

Atomic allocations are served from special pool preallocated on boot,
becasue vmalloc areas cannot be reliably created in atomic context.

This patch is based on vanilla v3.4-rc7 release.

Atomic allocations have been tested with s3c-sdhci driver on Samsung
UniversalC210 board with dmabounce code enabled to force
dma_alloc_coherent() use on each dma_map_* call (some of them are made
from interrupts).

Best regards
Marek Szyprowski
Samsung Poland R&D Center

Changelog:

v2:
- added support for atomic allocations (served from preallocated pool)
- minor cleanup here and there
- rebased onto v3.4-rc7

v1: http://thread.gmane.org/gmane.linux.kernel.mm/76703
- initial version

Patch summary:

Marek Szyprowski (4):
  mm: vmalloc: use const void * for caller argument
  mm: vmalloc: export find_vm_area() function
  mm: vmalloc: add VM_DMA flag to indicate areas used by dma-mapping
    framework
  ARM: dma-mapping: remove custom consistent dma region

 Documentation/kernel-parameters.txt |    4 +
 arch/arm/include/asm/dma-mapping.h  |    2 +-
 arch/arm/mm/dma-mapping.c           |  360 ++++++++++++++++-------------------
 include/linux/vmalloc.h             |   10 +-
 mm/vmalloc.c                        |   31 ++--
 5 files changed, 185 insertions(+), 196 deletions(-)

-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
