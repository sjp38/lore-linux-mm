Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 989546B0273
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 17:37:27 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ra7so11523536pab.5
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 14:37:27 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id ya10si19081301pab.213.2016.10.25.14.37.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 14:37:26 -0700 (PDT)
Subject: [net-next PATCH 00/27] Add support for DMA writable pages being
 writable by the network stack
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 25 Oct 2016 11:36:48 -0400
Message-ID: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: davem@davemloft.net, brouer@redhat.com

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

The last 3 patches use these updates in the igb driver to allow for us to
reimpelement the use of build_skb.

My hope is to get the series accepted into the net-next tree as I have a
number of other Intel drivers I could then begin updating once these
patches are accepted.

v1: Split out changes DMA_ERROR_CODE fix for swiotlb-xen
    Minor fixes based on issues found by kernel build bot
    Few minor changes for issues found on code review
    Added Acked-by for patches that were acked and not changed

---

Alexander Duyck (27):
      swiotlb: Drop unused function swiotlb_map_sg
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
      igb: Revert "igb: Revert support for build_skb in igb"


 arch/arc/mm/dma.c                         |    5 +
 arch/arm/common/dmabounce.c               |   16 +-
 arch/arm/xen/mm.c                         |    1 
 arch/avr32/mm/dma-coherent.c              |    7 +
 arch/blackfin/kernel/dma-mapping.c        |    8 +
 arch/c6x/kernel/dma.c                     |   14 +-
 arch/frv/mb93090-mb00/pci-dma-nommu.c     |   14 +-
 arch/frv/mb93090-mb00/pci-dma.c           |    9 +
 arch/hexagon/kernel/dma.c                 |    6 +
 arch/m68k/kernel/dma.c                    |    8 +
 arch/metag/kernel/dma.c                   |   16 ++
 arch/microblaze/kernel/dma.c              |   10 +
 arch/mips/loongson64/common/dma-swiotlb.c |    2 
 arch/mips/mm/dma-default.c                |    8 +
 arch/nios2/mm/dma-mapping.c               |   26 +++-
 arch/openrisc/kernel/dma.c                |    3 
 arch/parisc/kernel/pci-dma.c              |   20 ++-
 arch/powerpc/kernel/dma.c                 |    9 +
 arch/sh/kernel/dma-nommu.c                |    7 +
 arch/sparc/kernel/iommu.c                 |    4 -
 arch/sparc/kernel/ioport.c                |    4 -
 arch/tile/kernel/pci-dma.c                |   12 +-
 arch/x86/xen/pci-swiotlb-xen.c            |    1 
 arch/xtensa/kernel/pci-dma.c              |    7 +
 drivers/net/ethernet/intel/igb/igb.h      |   36 ++++-
 drivers/net/ethernet/intel/igb/igb_main.c |  207 +++++++++++++++++++++++------
 drivers/xen/swiotlb-xen.c                 |   27 ++--
 include/linux/dma-mapping.h               |   20 ++-
 include/linux/gfp.h                       |    2 
 include/linux/swiotlb.h                   |   10 +
 include/xen/swiotlb-xen.h                 |    3 
 lib/swiotlb.c                             |   56 ++++----
 mm/page_alloc.c                           |   14 ++
 33 files changed, 433 insertions(+), 159 deletions(-)

--
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
