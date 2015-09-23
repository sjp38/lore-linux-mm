Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 60A266B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:46:57 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so29299095pac.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:46:57 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ry7si7731150pab.17.2015.09.22.21.46.56
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 21:46:56 -0700 (PDT)
Subject: [PATCH 00/15] get_user_pages() for dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Sep 2015 00:41:12 -0400
Message-ID: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jens Axboe <axboe@kernel.dk>, Boaz Harrosh <boaz@plexistor.com>, Dave Hansen <dave@sr71.net>, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, David Airlie <airlied@linux.ie>, Jeff Moyer <jmoyer@redhat.com>, Ingo Molnar <mingo@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

To date, we have implemented two I/O usage models for persistent memory,
PMEM (a persistent "ram disk") and DAX (mmap persistent memory into
userspace).  This series adds a third, DAX-GUP, that allows DAX mappings
to be the target of direct-i/o.  It allows userspace to coordinate
DMA/RDMA from/to persitent memory.

The implementation leverages the ZONE_DEVICE mm-zone that went into
4.3-rc1 to flag pages that are owned and dynamically mapped by a device
driver.  The pmem driver, after mapping a persistent memory range into
the system memmap via devm_memremap_pages(), arranges for DAX to
distinguish pfn-only versus page-backed pmem-pfns via flags in the new
__pfn_t type.  The DAX code, upon seeing a PFN_DEV+PFN_MAP flagged pfn,
flags the resulting pte(s) inserted into the process page tables with a
new _PAGE_DEVMAP flag.  Later, when get_user_pages() is walking ptes it
keys off _PAGE_DEVMAP to pin the device hosting the page range active.
Finally, get_page() and put_page() are modified to take references
against the device driver established page mapping.

Next step, more testing specifically DAX-get_user_pages() vs truncate.

Patches 1 - 3 are general compilation fixups from 0day-kbuild reports
while developing this series.

Patches 4 - 7 are minor cleanups and reworks of the devm_memremap_* api.

Patches 8 - 10 add a reference counter for pinning the pmem driver
active while it is in use.  It turns out, prior to these changes, you
can reliably crash the kernel on shutdown if the pmem device is unbound
while hosting a mounted filesystem.

Patches 11 - 15 use __pfn_t and the _PAGE_DEVMAP flag to implement the
dax-gup path.

This series is built on 4.3-rc2 plus the __dax_pmd_fault fix from Ross:
https://patchwork.kernel.org/patch/7244961/

---

Dan Williams (15):
      avr32: convert to asm-generic/memory_model.h
      hugetlb: fix compile error on tile
      frv: fix compiler warning from definition of __pmd()
      x86, mm: quiet arch_add_memory()
      pmem: kill memremap_pmem()
      devm_memunmap: use devres_release()
      devm_memremap: convert to return ERR_PTR
      block, dax, pmem: reference counting infrastructure
      block, pmem: fix null pointer de-reference on shutdown, check for queue death
      block, dax: fix lifetime of in-kernel dax mappings
      mm, dax, pmem: introduce __pfn_t
      mm, dax, gpu: convert vm_insert_mixed to __pfn_t, introduce _PAGE_DEVMAP
      mm, dax: convert vmf_insert_pfn_pmd() to __pfn_t
      mm, dax, pmem: introduce {get|put}_dev_pagemap() for dax-gup
      mm, x86: get_user_pages() for dax mappings


 arch/alpha/include/asm/pgtable.h        |    1 
 arch/avr32/include/asm/page.h           |    8 +
 arch/frv/include/asm/page.h             |    2 
 arch/ia64/include/asm/pgtable.h         |    1 
 arch/m68k/include/asm/page_no.h         |    1 
 arch/parisc/include/asm/pgtable.h       |    1 
 arch/powerpc/include/asm/pgtable.h      |    1 
 arch/powerpc/sysdev/axonram.c           |   10 +
 arch/sparc/include/asm/pgtable_64.h     |    2 
 arch/tile/include/asm/pgtable.h         |    1 
 arch/um/include/asm/pgtable-3level.h    |    1 
 arch/x86/include/asm/pgtable.h          |   24 ++++
 arch/x86/include/asm/pgtable_types.h    |    7 +
 arch/x86/mm/gup.c                       |   56 ++++++++
 arch/x86/mm/init.c                      |    4 -
 arch/x86/mm/init_64.c                   |    4 -
 arch/x86/mm/pat.c                       |    4 -
 block/blk-core.c                        |   86 ++++++++++++-
 block/blk-mq-sysfs.c                    |    2 
 block/blk-mq.c                          |   48 ++-----
 block/blk-sysfs.c                       |    9 +
 block/blk.h                             |    3 
 drivers/block/brd.c                     |    6 -
 drivers/gpu/drm/exynos/exynos_drm_gem.c |    3 
 drivers/gpu/drm/gma500/framebuffer.c    |    2 
 drivers/gpu/drm/msm/msm_gem.c           |    3 
 drivers/gpu/drm/omapdrm/omap_gem.c      |    6 +
 drivers/gpu/drm/ttm/ttm_bo_vm.c         |    3 
 drivers/nvdimm/pmem.c                   |   57 +++++---
 drivers/s390/block/dcssblk.c            |   12 +-
 fs/block_dev.c                          |    2 
 fs/dax.c                                |  140 +++++++++++++-------
 include/asm-generic/pgtable.h           |    6 +
 include/linux/blkdev.h                  |   24 +++-
 include/linux/huge_mm.h                 |    2 
 include/linux/hugetlb.h                 |    1 
 include/linux/io.h                      |   17 --
 include/linux/mm.h                      |  212 +++++++++++++++++++++++++++++--
 include/linux/mm_types.h                |    6 +
 include/linux/pfn.h                     |    9 +
 include/linux/pmem.h                    |   26 ----
 kernel/memremap.c                       |   78 +++++++++++
 mm/gup.c                                |   11 +-
 mm/huge_memory.c                        |   10 +
 mm/hugetlb.c                            |   18 ++-
 mm/memory.c                             |   17 +-
 mm/swap.c                               |   15 ++
 47 files changed, 729 insertions(+), 233 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
