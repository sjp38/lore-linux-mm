Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 33A58280250
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:05:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x70so83311231pfk.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:05:04 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id x5si16665231pgf.96.2016.10.24.11.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:05:03 -0700 (PDT)
Subject: [net-next PATCH RFC 00/26] Add support for DMA writable pages being
 writable by the network stack
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:04:26 -0400
Message-ID: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: davem@davemloft.net, brouer@redhat.com

The first 21 patches in the set add support for the DMA attribute
DMA_ATTR_SKIP_CPU_SYNC on multiple platforms/architectures.  This is needed
so that we can flag the calls to dma_map/unmap_page so that we do not
invalidate cache lines that do not currently belong to the device.  Instead
we have to take care of this in the driver via a call to
sync_single_range_for_cpu prior to freeing the Rx page.

Patch 22 adds support for dma_map_page_attrs and dma_unmap_page_attrs so
that we can unmap and map a page using the DMA_ATTR_SKIP_CPU_SYNC
attribute.

Patch 23 adds support for freeing a page that has multiple references being
held by a single caller.  This way we can free page fragments that were
allocated by a given driver.

The last 3 patches use these updates in the igb driver to allow for us to
reimplement the use of build_skb which hands a writable page off to the
stack.

My hope is to get the series accepted into the net-next tree as I have a
number of other Intel drivers I could then begin updating once these
patches are accepted.

Any feedback is welcome.  Specifically if there is something I overlooked
design-wise or an architecture I missed please let me know and I will add
it to this patch set.  If needed I can look into breaking this into a
smaller set of patches but this set is all that should be needed to then
start looking at putting together a DMA page pool per device which I know
is something Jesper has been working on.

---

Alexander Duyck (26):
      swiotlb: Drop unused function swiotlb_map_sg
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


 arch/arc/mm/dma.c                         |    3 
 arch/arm/common/dmabounce.c               |   16 +-
 arch/avr32/mm/dma-coherent.c              |    7 +
 arch/blackfin/kernel/dma-mapping.c        |    7 +
 arch/c6x/kernel/dma.c                     |   16 ++
 arch/frv/mb93090-mb00/pci-dma-nommu.c     |   16 ++
 arch/frv/mb93090-mb00/pci-dma.c           |    7 +
 arch/hexagon/kernel/dma.c                 |    6 +
 arch/m68k/kernel/dma.c                    |    8 +
 arch/metag/kernel/dma.c                   |   16 ++
 arch/microblaze/kernel/dma.c              |   10 +
 arch/mips/loongson64/common/dma-swiotlb.c |    2 
 arch/mips/mm/dma-default.c                |    8 +
 arch/nios2/mm/dma-mapping.c               |   14 ++
 arch/openrisc/kernel/dma.c                |    3 
 arch/parisc/kernel/pci-dma.c              |   20 ++-
 arch/powerpc/kernel/dma.c                 |    9 +
 arch/sh/kernel/dma-nommu.c                |    7 +
 arch/sparc/kernel/iommu.c                 |    4 -
 arch/sparc/kernel/ioport.c                |    4 -
 arch/tile/kernel/pci-dma.c                |   12 +-
 arch/xtensa/kernel/pci-dma.c              |    7 +
 drivers/net/ethernet/intel/igb/igb.h      |   36 ++++-
 drivers/net/ethernet/intel/igb/igb_main.c |  207 +++++++++++++++++++++++------
 drivers/xen/swiotlb-xen.c                 |   40 +++---
 include/linux/dma-mapping.h               |   20 ++-
 include/linux/gfp.h                       |    2 
 include/linux/swiotlb.h                   |   10 +
 lib/swiotlb.c                             |   56 ++++----
 mm/page_alloc.c                           |   14 ++
 30 files changed, 435 insertions(+), 152 deletions(-)

--
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
