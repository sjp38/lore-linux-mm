Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 1B4CD6B005C
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 07:28:00 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LWN005JUPAMO240@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Dec 2011 12:27:58 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LWN003GZPALM1@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Dec 2011 12:27:58 +0000 (GMT)
Date: Fri, 23 Dec 2011 13:27:19 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 00/14] DMA-mapping framework redesign preparation
Message-id: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

Hello eveyone,

On Linaro Memory Management meeting in Budapest (May 2011) we have
discussed about the design of DMA mapping framework. We tried to
identify the drawbacks and limitations as well as to provide some a
solution for them. The discussion was mainly about ARM architecture, but
some of the conclusions need to be applied to cross-architecture code.

The first issue we identified is the fact that on some platform (again,
mainly ARM) there are several functions for allocating DMA buffers:
dma_alloc_coherent, dma_alloc_writecombine and dma_alloc_noncoherent
(not functional now). For each of them there is a match dma_free_*
function. This gives us quite a lot of functions in the public API and
complicates things when we need to have several different
implementations for different devices selected in runtime (if IOMMU
controller is available only for a few devices in the system). Also the
drivers which use less common variants are less portable because of the
lacks of dma_alloc_writecombine on other architectures.

The solution we found is to introduce a new public dma mapping functions
with additional attributes argument: dma_alloc_attrs and
dma_free_attrs(). This way all different kinds of architecture specific
buffer mappings can be hidden behind the attributes without the need of
creating several versions of dma_alloc_ function.

dma_alloc_coherent() can be wrapped on top of new dma_alloc_attrs() with
NULL attrs parameter. dma_alloc_writecombine and dma_alloc_noncoherent
can be implemented as a simple wrappers which sets attributes to
DMA_ATTRS_WRITECOMBINE or DMA_ATTRS_NON_CONSISTENT respectively. These
new attributes will be implemented only on the architectures that really
support them, the others will simply ignore them defaulting to the
dma_alloc_coherent equivalent.

The next step in dma mapping framework update is the introduction of
dma_mmap/dma_mmap_attrs() function. There are a number of drivers
(mainly V4L2 and ALSA) that only exports the DMA buffers to user space.
Creating a userspace mapping with correct page attributes is not an easy
task for the driver. Also the DMA-mapping framework is the only place
where the complete information about the allocated pages is available,
especially if the implementation uses IOMMU controller to provide a
contiguous buffer in DMA address space which is scattered in physical
memory space.

Usually these drivers don't touch the buffer data at all, so the mapping
in kernel virtual address space is not needed. We can introduce
DMA_ATTRIB_NO_KERNEL_MAPPING attribute which lets kernel to skip/ignore
creation of kernel virtual mapping. This way we can save previous
vmalloc area and simply some mapping operation on a few architectures.

This patch series is a preparation for the above changes in the public
dma mapping API. The main goal is to modify dma_map_ops structure and
let all users to use for implementation of the new public funtions.

The proof-of-concept patches for ARM architecture have been already
posted a few times and now they are working resonably well. They perform
conversion to dma_map_ops based implementation and add support for
generic IOMMU-based dma mapping implementation. To get them merged we
first need to get acceptance for the changes in the common,
cross-architecture structures. More information about these patches can
be found in the following threads:

http://www.spinics.net/lists/linux-mm/msg19856.html
http://www.spinics.net/lists/linux-mm/msg21241.html
http://lists.linaro.org/pipermail/linaro-mm-sig/2011-September/000571.html
http://lists.linaro.org/pipermail/linaro-mm-sig/2011-September/000577.html
http://www.spinics.net/lists/linux-mm/msg25490.html

The patches are prepared on top of Linux Kernel v3.2-rc6. I would
appreciate any comments and help with getting this patch series into
linux-next tree.

The idea apllied in this patch set have been also presented during the
Kernel Summit 2011 and ELC-E 2011 in Prague, in the presentation 'ARM
DMA-Mapping Framework Redesign and IOMMU integration'.

I'm really sorry if I missed any of the relevant architecture mailing
lists. I've did my best to include everyone. Feel free to forward this
patchset to all interested developers and maintainers. I've already feel
like a nasty spammer.

Best regards
Marek Szyprowski
Samsung Poland R&D Center


Patch summary:

Andrzej Pietrasiewicz (9):
  X86: adapt for dma_map_ops changes
  MIPS: adapt for dma_map_ops changes
  PowerPC: adapt for dma_map_ops changes
  IA64: adapt for dma_map_ops changes
  SPARC: adapt for dma_map_ops changes
  Alpha: adapt for dma_map_ops changes
  SH: adapt for dma_map_ops changes
  Microblaze: adapt for dma_map_ops changes
  Unicore32: adapt for dma_map_ops changes

Marek Szyprowski (5):
  common: dma-mapping: introduce alloc_attrs and free_attrs methods
  common: dma-mapping: remove old alloc_coherent and free_coherent
    methods
  common: dma-mapping: introduce mmap method
  common: DMA-mapping: add WRITE_COMBINE attribute
  common: DMA-mapping: add NON-CONSISTENT attribute

 Documentation/DMA-attributes.txt          |   19 +++++++++++++++++++
 arch/alpha/include/asm/dma-mapping.h      |   18 ++++++++++++------
 arch/alpha/kernel/pci-noop.c              |   10 ++++++----
 arch/alpha/kernel/pci_iommu.c             |   10 ++++++----
 arch/ia64/hp/common/sba_iommu.c           |   11 ++++++-----
 arch/ia64/include/asm/dma-mapping.h       |   18 ++++++++++++------
 arch/ia64/kernel/pci-swiotlb.c            |    9 +++++----
 arch/ia64/sn/pci/pci_dma.c                |    9 +++++----
 arch/microblaze/include/asm/dma-mapping.h |   18 ++++++++++++------
 arch/microblaze/kernel/dma.c              |   10 ++++++----
 arch/mips/include/asm/dma-mapping.h       |   18 ++++++++++++------
 arch/mips/mm/dma-default.c                |    8 ++++----
 arch/powerpc/include/asm/dma-mapping.h    |   24 ++++++++++++++++--------
 arch/powerpc/kernel/dma-iommu.c           |   10 ++++++----
 arch/powerpc/kernel/dma-swiotlb.c         |    4 ++--
 arch/powerpc/kernel/dma.c                 |   10 ++++++----
 arch/powerpc/kernel/ibmebus.c             |   10 ++++++----
 arch/powerpc/platforms/cell/iommu.c       |   16 +++++++++-------
 arch/powerpc/platforms/ps3/system-bus.c   |   13 +++++++------
 arch/sh/include/asm/dma-mapping.h         |   28 ++++++++++++++++++----------
 arch/sh/kernel/dma-nommu.c                |    4 ++--
 arch/sh/mm/consistent.c                   |    6 ++++--
 arch/sparc/include/asm/dma-mapping.h      |   18 ++++++++++++------
 arch/sparc/kernel/iommu.c                 |   10 ++++++----
 arch/sparc/kernel/ioport.c                |   18 ++++++++++--------
 arch/sparc/kernel/pci_sun4v.c             |    9 +++++----
 arch/unicore32/include/asm/dma-mapping.h  |   18 ++++++++++++------
 arch/unicore32/mm/dma-swiotlb.c           |    4 ++--
 arch/x86/include/asm/dma-mapping.h        |   26 ++++++++++++++++----------
 arch/x86/kernel/amd_gart_64.c             |   11 ++++++-----
 arch/x86/kernel/pci-calgary_64.c          |    9 +++++----
 arch/x86/kernel/pci-dma.c                 |    3 ++-
 arch/x86/kernel/pci-nommu.c               |    6 +++---
 arch/x86/kernel/pci-swiotlb.c             |   12 +++++++-----
 arch/x86/xen/pci-swiotlb-xen.c            |    4 ++--
 drivers/iommu/amd_iommu.c                 |   10 ++++++----
 drivers/iommu/intel-iommu.c               |    9 +++++----
 drivers/xen/swiotlb-xen.c                 |    5 +++--
 include/linux/dma-attrs.h                 |    2 ++
 include/linux/dma-mapping.h               |   13 +++++++++----
 include/linux/swiotlb.h                   |    6 ++++--
 include/xen/swiotlb-xen.h                 |    6 ++++--
 lib/swiotlb.c                             |    5 +++--
 43 files changed, 305 insertions(+), 182 deletions(-)

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
