Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1CEB06B0038
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:01:07 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so100952947pac.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:01:06 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id v15si6506924pbs.21.2015.10.09.18.01.05
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:01:06 -0700 (PDT)
Subject: [PATCH v2 00/20] get_user_pages() for dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:55:23 -0400
Message-ID: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mips@linux-mips.org, Dave Hansen <dave@sr71.net>, Boaz Harrosh <boaz@plexistor.com>, David Airlie <airlied@linux.ie>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Keith Busch <keith.busch@intel.com>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, hch@lst.de, Russell King <linux@arm.linux.org.uk>, Richard Weinberger <richard@nod.at>, Peter Zijlstra <peterz@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Matthew Wilcox <willy@linux.intel.com>, ross.zwisler@linux.intel.com, Gleb Natapov <gleb@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Will Deacon <will.deacon@arm.com>, Jeff Dike <jdike@addtoit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Jens Axboe <axboe@kernel.dk>, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Christoffer Dall <christoffer.dall@linaro.org>

Changes since v1 [1]:
1/ Rebased on the accepted cleanups to the memremap() api and the NUMA
   hints for devm allocations. (see libnvdimm-for-next [2]).

2/ Rebased on DAX fixes from Ross [3], currently in -mm, and Dave [4],
   applied locally for now.

3/ Renamed __pfn_t to pfn_t and converted KVM and UM accordingly (Dave
   Hansen)

4/ Make pfn-to-pfn_t conversions a nop (binary identical) for typical
   mapped pfns (Dave Hansen)

5/ Fixed up the devm_memremap_pages() api to require passing in a
   percpu_ref object.  Addresses a crash reported-by Logan.

6/ Moved the back pointer from a page to its hosting 'struct
   dev_pagemap' to share storage with the 'lru' field rather than
   'mapping'.  Enables us to revoke mappings at devm_memunmap_page()
   time and addresses a crash reported-by Logan.

7/ Rework dax_map_bh() into dax_map_atomic() to avoid proliferating
   buffer_head usage deeper into the dax implementation.  Also addresses
   a crash reported by Logan (Dave Chinner)

8/ Include an initial, only lightly tested, implementation of revoking
   usages of ZONE_DEVICE pages when the driver disables the pmem device.
   This coordinates with blk_cleanup_queue() for the pmem gendisk, see
   patch 19.

9/ Include a cleaned up version of the vmem_altmap infrastructure
   allowing the struct page memmap to optionally be allocated from pmem
   itself.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-September/002199.html
[2]: https://git.kernel.org/cgit/linux/kernel/git/nvdimm/nvdimm.git/log/?h=libnvdimm-for-next
[3]: https://git.kernel.org/cgit/linux/kernel/git/nvdimm/nvdimm.git/commit/?h=dax-fixes&id=93fdde069dce
[4]: https://lists.01.org/pipermail/linux-nvdimm/2015-October/002286.html

---
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

This series is available via git here:

  git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm libnvdimm-pending

---

Dan Williams (20):
      block: generic request_queue reference counting
      dax: increase granularity of dax_clear_blocks() operations
      block, dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()
      mm: introduce __get_dev_pagemap()
      x86, mm: introduce vmem_altmap to augment vmemmap_populate()
      libnvdimm, pfn, pmem: allocate memmap array in persistent memory
      avr32: convert to asm-generic/memory_model.h
      hugetlb: fix compile error on tile
      frv: fix compiler warning from definition of __pmd()
      um: kill pfn_t
      kvm: rename pfn_t to kvm_pfn_t
      mips: fix PAGE_MASK definition
      mm, dax, pmem: introduce pfn_t
      mm, dax, gpu: convert vm_insert_mixed to pfn_t, introduce _PAGE_DEVMAP
      mm, dax: convert vmf_insert_pfn_pmd() to pfn_t
      list: introduce list_poison() and LIST_POISON3
      mm, dax, pmem: introduce {get|put}_dev_pagemap() for dax-gup
      block: notify queue death confirmation
      mm, pmem: devm_memunmap_pages(), truncate and unmap ZONE_DEVICE pages
      mm, x86: get_user_pages() for dax mappings


 arch/alpha/include/asm/pgtable.h        |    1 
 arch/arm/include/asm/kvm_mmu.h          |    5 -
 arch/arm/kvm/mmu.c                      |   10 +
 arch/arm64/include/asm/kvm_mmu.h        |    3 
 arch/avr32/include/asm/page.h           |    8 -
 arch/frv/include/asm/page.h             |    2 
 arch/ia64/include/asm/pgtable.h         |    1 
 arch/m68k/include/asm/page_mm.h         |    1 
 arch/m68k/include/asm/page_no.h         |    1 
 arch/mips/include/asm/kvm_host.h        |    6 -
 arch/mips/include/asm/page.h            |    2 
 arch/mips/kvm/emulate.c                 |    2 
 arch/mips/kvm/tlb.c                     |   14 +
 arch/parisc/include/asm/pgtable.h       |    1 
 arch/powerpc/include/asm/kvm_book3s.h   |    4 
 arch/powerpc/include/asm/kvm_ppc.h      |    2 
 arch/powerpc/include/asm/pgtable.h      |    1 
 arch/powerpc/kvm/book3s.c               |    6 -
 arch/powerpc/kvm/book3s_32_mmu_host.c   |    2 
 arch/powerpc/kvm/book3s_64_mmu_host.c   |    2 
 arch/powerpc/kvm/e500.h                 |    2 
 arch/powerpc/kvm/e500_mmu_host.c        |    8 -
 arch/powerpc/kvm/trace_pr.h             |    2 
 arch/powerpc/sysdev/axonram.c           |    8 -
 arch/sparc/include/asm/pgtable_64.h     |    2 
 arch/tile/include/asm/pgtable.h         |    1 
 arch/um/include/asm/page.h              |    6 -
 arch/um/include/asm/pgtable-3level.h    |    5 -
 arch/um/include/asm/pgtable.h           |    2 
 arch/x86/include/asm/pgtable.h          |   24 ++
 arch/x86/include/asm/pgtable_types.h    |    7 +
 arch/x86/kvm/iommu.c                    |   11 +
 arch/x86/kvm/mmu.c                      |   37 ++--
 arch/x86/kvm/mmu_audit.c                |    2 
 arch/x86/kvm/paging_tmpl.h              |    6 -
 arch/x86/kvm/vmx.c                      |    2 
 arch/x86/kvm/x86.c                      |    2 
 arch/x86/mm/gup.c                       |   56 +++++-
 arch/x86/mm/init_64.c                   |   32 +++
 arch/x86/mm/pat.c                       |    4 
 block/blk-core.c                        |   79 +++++++-
 block/blk-mq-sysfs.c                    |    6 -
 block/blk-mq.c                          |   87 +++------
 block/blk-sysfs.c                       |    3 
 block/blk.h                             |   12 +
 drivers/block/brd.c                     |    4 
 drivers/gpu/drm/exynos/exynos_drm_gem.c |    3 
 drivers/gpu/drm/gma500/framebuffer.c    |    3 
 drivers/gpu/drm/msm/msm_gem.c           |    3 
 drivers/gpu/drm/omapdrm/omap_gem.c      |    6 -
 drivers/gpu/drm/ttm/ttm_bo_vm.c         |    3 
 drivers/nvdimm/pfn_devs.c               |    3 
 drivers/nvdimm/pmem.c                   |  128 +++++++++----
 drivers/s390/block/dcssblk.c            |   10 -
 fs/block_dev.c                          |    2 
 fs/dax.c                                |  199 +++++++++++++--------
 include/asm-generic/pgtable.h           |    6 -
 include/linux/blk-mq.h                  |    1 
 include/linux/blkdev.h                  |   12 +
 include/linux/huge_mm.h                 |    2 
 include/linux/hugetlb.h                 |    1 
 include/linux/io.h                      |   17 --
 include/linux/kvm_host.h                |   37 ++--
 include/linux/kvm_types.h               |    2 
 include/linux/list.h                    |   14 +
 include/linux/memory_hotplug.h          |    3 
 include/linux/mm.h                      |  300 +++++++++++++++++++++++++++++--
 include/linux/mm_types.h                |    5 +
 include/linux/pfn.h                     |    9 +
 include/linux/poison.h                  |    1 
 kernel/memremap.c                       |  187 +++++++++++++++++++
 lib/list_debug.c                        |    2 
 mm/gup.c                                |   11 +
 mm/huge_memory.c                        |   10 +
 mm/hugetlb.c                            |   18 ++
 mm/memory.c                             |   17 +-
 mm/memory_hotplug.c                     |   66 +++++--
 mm/page_alloc.c                         |   10 +
 mm/sparse-vmemmap.c                     |   37 ++++
 mm/sparse.c                             |    8 +
 mm/swap.c                               |   15 ++
 virt/kvm/kvm_main.c                     |   47 ++---
 82 files changed, 1264 insertions(+), 418 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
