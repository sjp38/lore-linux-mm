Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C2196828E1
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 18:55:41 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id td3so51689499pab.2
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 15:55:41 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id e69si1448939pfd.66.2016.03.10.15.55.38
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 15:55:38 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 00/14] Support for transparent PUD pages for DAX files
Date: Thu, 10 Mar 2016 18:55:17 -0500
Message-Id: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, willy@linux.intel.com

We have customer demand to use 1GB pages to map DAX files.  Unlike the 2MB
page support, the Linux MM does not currently support PUD pages, so I have
attempted to add support for the necessary pieces for DAX huge PUD pages.

Filesystems still need work to allocate 1GB pages.  With ext4, I can
only get 16MB of contiguous space, although it is aligned.  With XFS,
I can get 80MB less than 1GB, and it's not aligned.  The XFS problem
may be due to the small amount of RAM in my test machine.

This patch set is against v4.5-rc7-mmots-2016-03-08-15-59.  I'd like
to thank Dave Chinner & Kirill Shutemov for their reviews of v1.
The conversion of pmd_fault & pud_fault to huge_fault is thanks to Dave's
poking, and Kirill spotted a couple of problems in the MM code.

I've done some light testing using a program to mmap a block device
with DAX enabled, calling mincore() and examining /proc/smaps and
/proc/pagemap.

v5: Fix compilation bug with GCC 4.5 and earlier by initialising vm_fault.pmd
    and vm_fault.pud later
  - Fix report from Sergey Senozhatsky about compilation on x86-64 with
    CONFIG_TRANSPARENT_HUGEPAGE=n (also reported by Sudip Mukherjee)
  - Fix report from Stephen Rothwell about touch_pud() / follow_devmap_pud()
    not compiling on pSeries by moving these functions under
    CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
  - Fix wrong order of arguments to VM_BUG_ON_VMA (reported by Andrew Morton)
  - Fix VM_BUG_ON_* not checking its arguments in non-debug case
  - Fix duplicate definition of native_pud_clear() with X86_PAE
  - Fix linking with X86_PAE by making pud_trans_huge() and pud_devmap()
    return 0
  - Fix several whitespace issues in x86 patches
  - Add some DAX cleanups on top of the 1GB changes

v4: Updated to current mmotm
  - Converted pud_trans_huge_lock to the same calling conventions as
    pmd_trans_huge_lock.
  - Fill in vm_fault ->gfp_flags and ->pgoff, at Jan Kara's suggestion
  - Replace use of page table lock with pud_lock in __pud_alloc (cosmetic)
  - Fix compilation problems with various config settings
  - Convert dax_pmd_fault and dax_pud_fault to take a vm_fault instead of
    individual pieces
  - Add copy_huge_pud() and follow_devmap_pud() so fork() should now work
  - Fix typo of PMD for PUD

v3: Rebased against current mmtom
v2: Reduced churn in filesystems by switching to ->huge_fault interface
    Addressed concerns from Kirill

Matthew Wilcox (14):
  mmdebug: Always evaluate the arguments to VM_BUG_ON_*
  mm: Convert an open-coded VM_BUG_ON_VMA
  mm,fs,dax: Change ->pmd_fault to ->huge_fault
  mm: Add support for PUD-sized transparent hugepages
  mincore: Add support for PUDs
  procfs: Add support for PUDs to smaps, clear_refs and pagemap
  x86: Unify native_*_get_and_clear !SMP case
  x86: Fix whitespace issues
  x86: Add support for PUD-sized transparent hugepages
  dax: Support for transparent PUD pages
  ext4: Support for PUD-sized transparent huge pages
  dax: Use vmf->gfp_mask
  dax: Remove unnecessary rechecking of i_size
  dax: Use vmf->pgoff in fault handlers

 Documentation/filesystems/dax.txt     |  12 +-
 arch/Kconfig                          |   3 +
 arch/x86/Kconfig                      |   1 +
 arch/x86/include/asm/paravirt.h       |  11 +
 arch/x86/include/asm/paravirt_types.h |   2 +
 arch/x86/include/asm/pgtable-2level.h |  21 +-
 arch/x86/include/asm/pgtable-3level.h |  27 ++-
 arch/x86/include/asm/pgtable.h        | 162 ++++++++++++++-
 arch/x86/include/asm/pgtable_64.h     |  23 +--
 arch/x86/kernel/paravirt.c            |   1 +
 arch/x86/mm/pgtable.c                 |  31 +++
 fs/block_dev.c                        |  10 +-
 fs/dax.c                              | 370 ++++++++++++++++++++--------------
 fs/ext2/file.c                        |  25 +--
 fs/ext4/file.c                        |  58 ++----
 fs/proc/task_mmu.c                    | 109 ++++++++++
 fs/xfs/xfs_file.c                     |  25 +--
 fs/xfs/xfs_trace.h                    |   2 +-
 include/asm-generic/pgtable.h         |  73 ++++++-
 include/asm-generic/tlb.h             |  14 ++
 include/linux/dax.h                   |  32 +--
 include/linux/huge_mm.h               |  84 +++++++-
 include/linux/mm.h                    |  48 ++++-
 include/linux/mmdebug.h               |  21 +-
 include/linux/mmu_notifier.h          |  14 ++
 include/linux/pfn_t.h                 |   8 +
 mm/gup.c                              |   7 +
 mm/huge_memory.c                      | 246 ++++++++++++++++++++++
 mm/memory.c                           | 131 ++++++++++--
 mm/mincore.c                          |  13 ++
 mm/pagewalk.c                         |  19 +-
 mm/pgtable-generic.c                  |  13 ++
 32 files changed, 1284 insertions(+), 332 deletions(-)

-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
