Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85AA46B02A1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 13:13:04 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hc3so1775540pac.4
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 10:13:04 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id n19si4121668pgk.202.2016.11.02.10.13.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 10:13:03 -0700 (PDT)
Subject: [mm PATCH v2 00/26] Add support for DMA writable pages being
 writable by the network stack
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 02 Nov 2016 07:12:06 -0400
Message-ID: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org

The first 22 patches in the set add support for the DMA attribute
DMA_ATTR_SKIP_CPU_SYNC on multiple platforms/architectures.  This is needed
so that we can flag the calls to dma_map/unmap_page so that we do not
invalidate cache lines that do not currently belong to the device.  Instead
we have to take care of this in the driver via a call to
sync_single_range_for_cpu prior to freeing the Rx page.

Patch 23 adds support for dma_map_page_attrs and dma_unmap_page_attrs so
that we can unmap and map a page using the DMA_ATTR_SKIP_CPU_SYNC
attribute.

Patch 24 adds support for freeing a page that has multiple references being
held by a single caller.  This way we can free page fragments that were
allocated by a given driver.

The last 2 patches use these updates in the igb driver, and lay the
groundwork to allow for us to reimpelement the use of build_skb.

v1: Split out changes DMA_ERROR_CODE fix for swiotlb-xen
    Minor fixes based on issues found by kernel build bot
    Few minor changes for issues found on code review
    Added Acked-by for patches that were acked and not changed

v2: Added a few more Acked-by
    Added swiotlb_unmap_sg to functions dropped in patch 1, dropped Acked-by
    Submitting patches to mm instead of net-next

---

Alexander Duyck (26):
      swiotlb: Drop unused functions swiotlb_map_sg and swiotlb_unmap_sg
      swiotlb-xen: Enforce return of DMA_ERROR_CODE in mapping function
      swiotlb: Add support for DMA_ATTR_SKIP_CPU_SYNC
      arch/arc: Add option to skip sync on DMA mapping
      arch/arm: Add option to skip sync on DMA map and unmap
      arch/avr32: Add option to skip sync on DMA map
      arch/blackfin: Add option to skip sync on DMA map
      arch/c6x: Add option to skip sync on DMA map and unmap
      arch/frv: Add option to skip sync on DMA map
      arch/hexagon: Add option to skip DMA sync as a part of mapping
      arch/m68k: Add option to skip DMA sync as a part of mapping
      arch/metag: Add option to skip DMA sync as a part of map and unmap
      arch/microblaze: Add option to skip DMA sync as a part of map and unmap
      arch/mips: Add option to skip DMA sync as a part of map and unmap
      arch/nios2: Add option to skip DMA sync as a part of map and unmap
      arch/openrisc: Add option to skip DMA sync as a part of mapping
      arch/parisc: Add option to skip DMA sync as a part of map and unmap
      arch/powerpc: Add option to skip DMA sync as a part of mapping
      arch/sh: Add option to skip DMA sync as a part of mapping
      arch/sparc: Add option to skip DMA sync as a part of map and unmap
      arch/tile: Add option to skip DMA sync as a part of map and unmap
      arch/xtensa: Add option to skip DMA sync as a part of mapping
      dma: Add calls for dma_map_page_attrs and dma_unmap_page_attrs
      mm: Add support for releasing multiple instances of a page
      igb: Update driver to make use of DMA_ATTR_SKIP_CPU_SYNC
      igb: Update code to better handle incrementing page count


 arch/arc/mm/dma.c                         |    5 ++
 arch/arm/common/dmabounce.c               |   16 ++++--
 arch/arm/xen/mm.c                         |    1 
 arch/avr32/mm/dma-coherent.c              |    7 ++-
 arch/blackfin/kernel/dma-mapping.c        |    8 +++
 arch/c6x/kernel/dma.c                     |   14 ++++-
 arch/frv/mb93090-mb00/pci-dma-nommu.c     |   14 ++++-
 arch/frv/mb93090-mb00/pci-dma.c           |    9 +++
 arch/hexagon/kernel/dma.c                 |    6 ++
 arch/m68k/kernel/dma.c                    |    8 +++
 arch/metag/kernel/dma.c                   |   16 +++++-
 arch/microblaze/kernel/dma.c              |   10 +++-
 arch/mips/loongson64/common/dma-swiotlb.c |    2 -
 arch/mips/mm/dma-default.c                |    8 ++-
 arch/nios2/mm/dma-mapping.c               |   26 +++++++---
 arch/openrisc/kernel/dma.c                |    3 +
 arch/parisc/kernel/pci-dma.c              |   20 ++++++--
 arch/powerpc/kernel/dma.c                 |    9 +++
 arch/sh/kernel/dma-nommu.c                |    7 ++-
 arch/sparc/kernel/iommu.c                 |    4 +-
 arch/sparc/kernel/ioport.c                |    4 +-
 arch/tile/kernel/pci-dma.c                |   12 ++++-
 arch/x86/xen/pci-swiotlb-xen.c            |    1 
 arch/xtensa/kernel/pci-dma.c              |    7 ++-
 drivers/net/ethernet/intel/igb/igb.h      |    7 ++-
 drivers/net/ethernet/intel/igb/igb_main.c |   77 +++++++++++++++++++----------
 drivers/xen/swiotlb-xen.c                 |   27 +++++-----
 include/linux/dma-mapping.h               |   20 +++++---
 include/linux/gfp.h                       |    2 +
 include/linux/swiotlb.h                   |   14 ++---
 include/xen/swiotlb-xen.h                 |    3 -
 lib/swiotlb.c                             |   64 +++++++++++-------------
 mm/page_alloc.c                           |   14 +++++
 33 files changed, 291 insertions(+), 154 deletions(-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
