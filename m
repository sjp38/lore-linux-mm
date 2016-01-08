Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 11A08828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 14:50:00 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id uo6so269213223pac.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 11:50:00 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id um10si18630224pab.110.2016.01.08.11.49.56
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 11:49:56 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v3 0/8] Support for transparent PUD pages for DAX files
Date: Fri,  8 Jan 2016 14:49:44 -0500
Message-Id: <1452282592-27290-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

Andrew, I think this is ready for a spin in -mm.

v3: Rebased against current mmtom
v2: Reduced churn in filesystems by switching to ->huge_fault interface
    Addressed concerns from Kirill

We have customer demand to use 1GB pages to map DAX files.  Unlike the 2MB
page support, the Linux MM does not currently support PUD pages, so I have
attempted to add support for the necessary pieces for DAX huge PUD pages.

Filesystems still need work to allocate 1GB pages.  With ext4, I can
only get 16MB of contiguous space, although it is aligned.  With XFS,
I can get 80MB less than 1GB, and it's not aligned.  The XFS problem
may be due to the small amount of RAM in my test machine.

This patch set is against something approximately current -mm.  I'd like
to thank Dave Chinner & Kirill Shutemov for their reviews of v1.
The conversion of pmd_fault & pud_fault to huge_fault is thanks to
Dave's poking, and Kirill spotted a couple of problems in the MM code.
Version 2 of the patch set is about 200 lines smaller (1016 insertions,
23 deletions in v1).

I've done some light testing using a program to mmap a block device
with DAX enabled, calling mincore() and examining /proc/smaps and
/proc/pagemap.

Matthew Wilcox (8):
  mm: Convert an open-coded VM_BUG_ON_VMA
  mm,fs,dax: Change ->pmd_fault to ->huge_fault
  mm: Add support for PUD-sized transparent hugepages
  mincore: Add support for PUDs
  procfs: Add support for PUDs to smaps, clear_refs and pagemap
  x86: Add support for PUD-sized transparent hugepages
  dax: Support for transparent PUD pages
  ext4: Support for PUD-sized transparent huge pages

 Documentation/filesystems/dax.txt     |  12 +-
 arch/Kconfig                          |   3 +
 arch/x86/Kconfig                      |   1 +
 arch/x86/include/asm/paravirt.h       |  11 ++
 arch/x86/include/asm/paravirt_types.h |   2 +
 arch/x86/include/asm/pgtable.h        |  94 ++++++++++++
 arch/x86/include/asm/pgtable_64.h     |  13 ++
 arch/x86/kernel/paravirt.c            |   1 +
 arch/x86/mm/pgtable.c                 |  31 ++++
 fs/block_dev.c                        |  10 +-
 fs/dax.c                              | 272 +++++++++++++++++++++++++---------
 fs/ext2/file.c                        |  27 +---
 fs/ext4/file.c                        |  60 +++-----
 fs/proc/task_mmu.c                    | 109 ++++++++++++++
 fs/xfs/xfs_file.c                     |  25 ++--
 fs/xfs/xfs_trace.h                    |   2 +-
 include/asm-generic/pgtable.h         |  62 +++++++-
 include/asm-generic/tlb.h             |  14 ++
 include/linux/dax.h                   |  17 ---
 include/linux/huge_mm.h               |  50 +++++++
 include/linux/mm.h                    |  43 +++++-
 include/linux/mmu_notifier.h          |  13 ++
 include/linux/pfn_t.h                 |   8 +
 mm/huge_memory.c                      | 151 +++++++++++++++++++
 mm/memory.c                           | 101 +++++++++++--
 mm/mincore.c                          |  13 ++
 mm/pagewalk.c                         |  19 ++-
 mm/pgtable-generic.c                  |  14 ++
 28 files changed, 980 insertions(+), 198 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
