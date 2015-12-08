Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 322F66B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:43:44 -0500 (EST)
Received: by pfnn128 with SMTP id n128so16130558pfn.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:43:43 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id ra6si6746791pab.90.2015.12.08.10.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 10:43:43 -0800 (PST)
References: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <5667249F.6040507@deltatee.com>
Date: Tue, 8 Dec 2015 11:42:39 -0700
MIME-Version: 1.0
In-Reply-To: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH -mm 00/25] get_user_pages() for dax pte and pmd mappings
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Dave Hansen <dave@sr71.net>, David Airlie <airlied@linux.ie>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Christoph Hellwig <hch@lst.de>, Andrea Arcangeli <aarcange@redhat.com>, kbuild test robot <lkp@intel.com>, linux-nvdimm@lists.01.org, Richard Weinberger <richard@nod.at>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jeff Dike <jdike@addtoit.com>, Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Christoffer Dall <christoffer.dall@linaro.org>, Stephen Bates <Stephen.Bates@pmcs.com>

Hi Dan,

Perfect. This latest version of the patch set is once again passing all
my tests without any issues.

Tested-By: Logan Gunthorpe <logang@deltatee.com>

Thanks,

Logan


On 07/12/15 06:32 PM, Dan Williams wrote:
> Andrew, please pull dax-gup support into -mm.
> 
> This series, based on next-20151203, has been out for review in one form
> or another since September [1].  The concept was reviewed at Kernel
> Summit in the "ZONE_DEVICE" tech-topic presentation.  Since the RFC
> posting [2] it has received fixes and is now passing the unit tests from
> ndctl [3] and nvml [4].
> 
> Logan Gunthorpe has also offered up functional testing of his use case
> for devm_memremap_pages() [5] (a "Tested-by" for the latest revision is
> still pending).
> 
> [1]: https://lists.01.org/pipermail/linux-nvdimm/2015-September/002199.html
> [2]: https://lists.01.org/pipermail/linux-nvdimm/2015-November/003033.html
> [3]: https://github.com/pmem/ndctl
> [4]: https://github.com/pmem/nvml
> [5]: https://lists.01.org/pipermail/linux-nvdimm/2015-October/002576.html
> 
> A git tree of this set is available here:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm libnvdimm-pending
> 
> The libnvdimm-pending branch has received a build success notification
> from the kbuild-test-robot over 105 configs.
> 
> ---
> 
> Summary:
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
> mechanism to allocate the memmap from persistent memory.  The new "struct
> vmem_altmap *"  parameter to devm_memremap_pages() enables
> arch_add_memory() to use reserved pmem capacity rather than the page
> allocator.
> 
> ---
> 
> Dan Williams (23):
>       pmem, dax: clean up clear_pmem()
>       dax: increase granularity of dax_clear_blocks() operations
>       dax: guarantee page aligned results from bdev_direct_access()
>       dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()
>       um: kill pfn_t
>       kvm: rename pfn_t to kvm_pfn_t
>       mm, dax, pmem: introduce pfn_t
>       mm: introduce find_dev_pagemap()
>       x86, mm: introduce vmem_altmap to augment vmemmap_populate()
>       libnvdimm, pfn, pmem: allocate memmap array in persistent memory
>       avr32: convert to asm-generic/memory_model.h
>       hugetlb: fix compile error on tile
>       frv: fix compiler warning from definition of __pmd()
>       x86, mm: introduce _PAGE_DEVMAP
>       mm, dax, gpu: convert vm_insert_mixed to pfn_t
>       mm, dax: convert vmf_insert_pfn_pmd() to pfn_t
>       list: introduce list_del_poison()
>       libnvdimm, pmem: move request_queue allocation earlier in probe
>       mm, dax, pmem: introduce {get|put}_dev_pagemap() for dax-gup
>       mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd
>       mm, x86: get_user_pages() for dax mappings
>       dax: provide diagnostics for pmd mapping failures
>       dax: re-enable dax pmd mappings
> 
> Ross Zwisler (1):
>       mm, dax: fix livelock, allow dax pmd mappings to become writeable
> 
> Toshi Kani (1):
>       dax: Split pmd map when fallback on COW
> 
> 
>  arch/alpha/include/asm/pgtable.h        |    1 
>  arch/arm/include/asm/kvm_mmu.h          |    5 -
>  arch/arm/kvm/mmu.c                      |   10 +
>  arch/arm64/include/asm/kvm_mmu.h        |    3 
>  arch/avr32/include/asm/page.h           |    8 -
>  arch/frv/include/asm/page.h             |    2 
>  arch/ia64/include/asm/page.h            |    1 
>  arch/ia64/include/asm/pgtable.h         |    1 
>  arch/m68k/include/asm/page_mm.h         |    1 
>  arch/m68k/include/asm/page_no.h         |    1 
>  arch/mips/include/asm/kvm_host.h        |    6 -
>  arch/mips/kvm/emulate.c                 |    2 
>  arch/mips/kvm/tlb.c                     |   14 +
>  arch/mn10300/include/asm/page.h         |    1 
>  arch/parisc/include/asm/pgtable.h       |    1 
>  arch/powerpc/include/asm/kvm_book3s.h   |    4 
>  arch/powerpc/include/asm/kvm_ppc.h      |    2 
>  arch/powerpc/include/asm/pgtable.h      |    1 
>  arch/powerpc/kvm/book3s.c               |    6 -
>  arch/powerpc/kvm/book3s_32_mmu_host.c   |    2 
>  arch/powerpc/kvm/book3s_64_mmu_host.c   |    2 
>  arch/powerpc/kvm/e500.h                 |    2 
>  arch/powerpc/kvm/e500_mmu_host.c        |    8 -
>  arch/powerpc/kvm/trace_pr.h             |    2 
>  arch/powerpc/sysdev/axonram.c           |    8 -
>  arch/sh/include/asm/pgtable-3level.h    |    1 
>  arch/sparc/include/asm/pgtable_64.h     |    2 
>  arch/tile/include/asm/pgtable.h         |    1 
>  arch/um/include/asm/page.h              |    7 -
>  arch/um/include/asm/pgtable-3level.h    |    5 -
>  arch/um/include/asm/pgtable.h           |    2 
>  arch/x86/include/asm/page_types.h       |    3 
>  arch/x86/include/asm/pgtable.h          |   26 +++
>  arch/x86/include/asm/pgtable_types.h    |    7 +
>  arch/x86/include/asm/pmem.h             |    7 -
>  arch/x86/kvm/iommu.c                    |   11 +
>  arch/x86/kvm/mmu.c                      |   37 ++--
>  arch/x86/kvm/mmu_audit.c                |    2 
>  arch/x86/kvm/paging_tmpl.h              |    6 -
>  arch/x86/kvm/vmx.c                      |    2 
>  arch/x86/kvm/x86.c                      |    2 
>  arch/x86/mm/gup.c                       |   56 +++++-
>  arch/x86/mm/init_64.c                   |   32 +++
>  arch/x86/mm/pat.c                       |    4 
>  drivers/block/brd.c                     |    4 
>  drivers/gpu/drm/exynos/exynos_drm_gem.c |    3 
>  drivers/gpu/drm/gma500/framebuffer.c    |    3 
>  drivers/gpu/drm/msm/msm_gem.c           |    3 
>  drivers/gpu/drm/omapdrm/omap_gem.c      |    6 -
>  drivers/gpu/drm/ttm/ttm_bo_vm.c         |    3 
>  drivers/nvdimm/pfn_devs.c               |    3 
>  drivers/nvdimm/pmem.c                   |   70 +++++--
>  drivers/s390/block/dcssblk.c            |   10 -
>  fs/Kconfig                              |    3 
>  fs/block_dev.c                          |   15 +-
>  fs/dax.c                                |  290 +++++++++++++++++++----------
>  include/asm-generic/pgtable.h           |   10 +
>  include/linux/blkdev.h                  |   19 ++
>  include/linux/huge_mm.h                 |   15 +-
>  include/linux/hugetlb.h                 |    1 
>  include/linux/io.h                      |   15 --
>  include/linux/kvm_host.h                |   37 ++--
>  include/linux/kvm_types.h               |    2 
>  include/linux/list.h                    |   17 ++
>  include/linux/memory_hotplug.h          |    3 
>  include/linux/mm.h                      |  310 ++++++++++++++++++++++++++++++-
>  include/linux/mm_types.h                |    5 +
>  include/linux/pfn.h                     |    9 +
>  kernel/memremap.c                       |  188 ++++++++++++++++++-
>  lib/list_debug.c                        |    4 
>  mm/gup.c                                |   18 ++
>  mm/huge_memory.c                        |  131 +++++++++----
>  mm/memory.c                             |   25 +--
>  mm/memory_hotplug.c                     |   66 +++++--
>  mm/mprotect.c                           |    5 -
>  mm/page_alloc.c                         |   10 +
>  mm/pgtable-generic.c                    |    2 
>  mm/sparse-vmemmap.c                     |   37 ++++
>  mm/sparse.c                             |    8 +
>  mm/swap.c                               |   15 ++
>  virt/kvm/kvm_main.c                     |   47 ++---
>  81 files changed, 1302 insertions(+), 417 deletions(-)
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
