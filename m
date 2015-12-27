Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8D89982FD8
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 03:34:00 -0500 (EST)
Received: by mail-lb0-f173.google.com with SMTP id sv6so73966839lbb.0
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 00:34:00 -0800 (PST)
Received: from mail-lb0-x242.google.com (mail-lb0-x242.google.com. [2a00:1450:4010:c04::242])
        by mx.google.com with ESMTPS id pm6si34072880lbb.170.2015.12.27.00.33.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Dec 2015 00:33:58 -0800 (PST)
Received: by mail-lb0-x242.google.com with SMTP id ti8so9184777lbb.3
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 00:33:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
Date: Sun, 27 Dec 2015 16:33:58 +0800
Message-ID: <CAA_GA1f44ADq7dw7LUM=rEex8m0vMXvGeOdW1YKkisbv51iuKw@mail.gmail.com>
Subject: Re: [-mm PATCH v4 00/18] get_user_pages() for dax pte and pmd mappings
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, David Airlie <airlied@linux.ie>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Linux-MM <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Christoph Hellwig <hch@lst.de>, Andrea Arcangeli <aarcange@redhat.com>, kbuild test robot <lkp@intel.com>, linux-nvdimm@lists.01.org, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Christoffer Dall <christoffer.dall@linaro.org>, Paolo Bonzini <pbonzini@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hey Dan,

On Mon, Dec 21, 2015 at 1:44 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> Changes since v3 [1]:
>
> 1/ Minimize the impact of the modifications to get_page() by moving
>    zone_device manipulations out of line and marking them unlikely().  In
>    v3 a simple function like:
>
>                 get_page(page);
>                 do_something_with_page(page);
>                 put_page(page);
>
>    ...had a text size of 672 bytes.  That is now down to 289 bytes,
>    compared to the pre-patch baseline size of 267 bytes.  Disassembly shows
>    that aside from conditional branch on the page zone number, data which
>    should already be dcache hot, there is no icache impact in the typical
>    path.  (Andrew, Dave Hansen)
>
> 2/ Minimize the impact to mm.h by moving ~200 lines of definitions to
>    pfn_t.h and memremap.h.  (Andrew)
>
> 3/ Move struct vmem_altmap helper routines to the only C file that
>    consumes them. (Andrew)
>
> 4/ Clean up definitions of pfn_pte, pfn_pmd, pte_devmap, and pmd_devmap
>    to have proper dependencies on CONFIG_MMU and
>    CONFIG_TRANSPARENT_HUGEPAGE to avoid the need to touch arch headers
>    outside of x86.
>
> 5/ Skip registering 'memory block' sysfs devices for zone_device ranges
>    since they are not normal memory and are not eligible to be 'onlined'.
>
> 6/ Improve the diagnostic debug messages in fs/dax.c to include
>    buffer_head details.  (Willy)
>
> These replace the following 18 patches:
>
>     kvm-rename-pfn_t-to-kvm_pfn_t.patch..dax-re-enable-dax-pmd-mappings.patch
>
> ...in the current -mm series, the other 7 patches from v3 are
> unmodified.  They have received a build success notification from the
> kbuild robot over 108 configs.
>
> [1]: https://lists.01.org/pipermail/linux-nvdimm/2015-December/003370.html
>
> ---
> Original summary:
>
> To date, we have implemented two I/O usage models for persistent memory,
> PMEM (a persistent "ram disk") and DAX (mmap persistent memory into
> userspace).  This series adds a third, DAX-GUP, that allows DAX mappings
> to be the target of direct-i/o.  It allows userspace to coordinate
> DMA/RDMA from/to persistent memory.
>
> The implementation leverages the ZONE_DEVICE mm-zone that went into
> 4.3-rc1 (also discussed at kernel summit) to flag pages that are owned
> and dynamically mapped by a device driver.  The pmem driver, after
> mapping a persistent memory range into the system memmap via
> devm_memremap_pages(), arranges for DAX to distinguish pfn-only versus
> page-backed pmem-pfns via flags in the new pfn_t type.
>
> The DAX code, upon seeing a PFN_DEV+PFN_MAP flagged pfn, flags the
> resulting pte(s) inserted into the process page tables with a new
> _PAGE_DEVMAP flag.  Later, when get_user_pages() is walking ptes it keys
> off _PAGE_DEVMAP to pin the device hosting the page range active.
> Finally, get_page() and put_page() are modified to take references
> against the device driver established page mapping.
>
> Finally, this need for "struct page" for persistent memory requires
> memory capacity to store the memmap array.  Given the memmap array for a
> large pool of persistent may exhaust available DRAM introduce a
> mechanism to allocate the memmap from persistent memory.  The new


What about space for page tables?
Page tables(mapping all memory in PMEM to virtual address space) may
also consume significantly DRAM space if  huge page is not enabled or
split.
Should we also consider to allocate pte page tables from PMEM in future?

Thanks,
Bob

> "struct vmem_altmap *"  parameter to devm_memremap_pages() enables
> arch_add_memory() to use reserved pmem capacity rather than the page
> allocator.
>
> ---
>
> Dan Williams (18):
>       kvm: rename pfn_t to kvm_pfn_t
>       mm, dax, pmem: introduce pfn_t
>       mm: skip memory block registration for ZONE_DEVICE
>       mm: introduce find_dev_pagemap()
>       x86, mm: introduce vmem_altmap to augment vmemmap_populate()
>       libnvdimm, pfn, pmem: allocate memmap array in persistent memory
>       avr32: convert to asm-generic/memory_model.h
>       hugetlb: fix compile error on tile
>       frv: fix compiler warning from definition of __pmd()
>       x86, mm: introduce _PAGE_DEVMAP
>       mm, dax, gpu: convert vm_insert_mixed to pfn_t
>       mm, dax: convert vmf_insert_pfn_pmd() to pfn_t
>       libnvdimm, pmem: move request_queue allocation earlier in probe
>       mm, dax, pmem: introduce {get|put}_dev_pagemap() for dax-gup
>       mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd
>       mm, x86: get_user_pages() for dax mappings
>       dax: provide diagnostics for pmd mapping failures
>       dax: re-enable dax pmd mappings
>
>
>  arch/arm/include/asm/kvm_mmu.h          |    5 -
>  arch/arm/kvm/mmu.c                      |   10 +
>  arch/arm64/include/asm/kvm_mmu.h        |    3
>  arch/avr32/include/asm/page.h           |    8 +
>  arch/frv/include/asm/page.h             |    2
>  arch/ia64/include/asm/page.h            |    1
>  arch/mips/include/asm/kvm_host.h        |    6 -
>  arch/mips/kvm/emulate.c                 |    2
>  arch/mips/kvm/tlb.c                     |   14 +-
>  arch/powerpc/include/asm/kvm_book3s.h   |    4 -
>  arch/powerpc/include/asm/kvm_ppc.h      |    2
>  arch/powerpc/kvm/book3s.c               |    6 -
>  arch/powerpc/kvm/book3s_32_mmu_host.c   |    2
>  arch/powerpc/kvm/book3s_64_mmu_host.c   |    2
>  arch/powerpc/kvm/e500.h                 |    2
>  arch/powerpc/kvm/e500_mmu_host.c        |    8 +
>  arch/powerpc/kvm/trace_pr.h             |    2
>  arch/powerpc/sysdev/axonram.c           |    9 +
>  arch/x86/include/asm/pgtable.h          |   26 +++-
>  arch/x86/include/asm/pgtable_types.h    |    7 +
>  arch/x86/kvm/iommu.c                    |   11 +-
>  arch/x86/kvm/mmu.c                      |   37 +++--
>  arch/x86/kvm/mmu_audit.c                |    2
>  arch/x86/kvm/paging_tmpl.h              |    6 -
>  arch/x86/kvm/vmx.c                      |    2
>  arch/x86/kvm/x86.c                      |    2
>  arch/x86/mm/gup.c                       |   57 +++++++-
>  arch/x86/mm/init_64.c                   |   33 ++++-
>  arch/x86/mm/pat.c                       |    5 -
>  drivers/base/memory.c                   |   13 ++
>  drivers/block/brd.c                     |    7 +
>  drivers/gpu/drm/exynos/exynos_drm_gem.c |    4 -
>  drivers/gpu/drm/gma500/framebuffer.c    |    4 -
>  drivers/gpu/drm/msm/msm_gem.c           |    4 -
>  drivers/gpu/drm/omapdrm/omap_gem.c      |    7 +
>  drivers/gpu/drm/ttm/ttm_bo_vm.c         |    4 -
>  drivers/nvdimm/pfn_devs.c               |    3
>  drivers/nvdimm/pmem.c                   |   73 +++++++---
>  drivers/s390/block/dcssblk.c            |   11 +-
>  fs/Kconfig                              |    3
>  fs/dax.c                                |   76 ++++++++--
>  include/asm-generic/pgtable.h           |    6 +
>  include/linux/blkdev.h                  |    5 -
>  include/linux/huge_mm.h                 |   15 ++
>  include/linux/hugetlb.h                 |    1
>  include/linux/io.h                      |   15 --
>  include/linux/kvm_host.h                |   37 +++--
>  include/linux/kvm_types.h               |    2
>  include/linux/list.h                    |   12 ++
>  include/linux/memory_hotplug.h          |    3
>  include/linux/memremap.h                |  114 ++++++++++++++++
>  include/linux/mm.h                      |   72 ++++++++--
>  include/linux/mm_types.h                |    5 +
>  include/linux/pfn.h                     |    9 +
>  include/linux/pfn_t.h                   |  102 ++++++++++++++
>  kernel/memremap.c                       |  227 ++++++++++++++++++++++++++++++-
>  lib/list_debug.c                        |    9 +
>  mm/gup.c                                |   19 ++-
>  mm/huge_memory.c                        |  119 ++++++++++++----
>  mm/memory.c                             |   26 ++--
>  mm/memory_hotplug.c                     |   67 +++++++--
>  mm/mprotect.c                           |    5 -
>  mm/page_alloc.c                         |   11 +-
>  mm/pgtable-generic.c                    |    2
>  mm/sparse-vmemmap.c                     |   76 ++++++++++
>  mm/sparse.c                             |    8 +
>  mm/swap.c                               |    3
>  virt/kvm/kvm_main.c                     |   47 +++---
>  68 files changed, 1204 insertions(+), 298 deletions(-)
>  create mode 100644 include/linux/memremap.h
>  create mode 100644 include/linux/pfn_t.h
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
