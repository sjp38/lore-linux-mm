Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id D059B82F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 11:20:45 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id 78so68218973pfw.2
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 08:20:45 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id se8si9718085pac.136.2015.12.24.08.20.44
        for <linux-mm@kvack.org>;
        Thu, 24 Dec 2015 08:20:44 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 0/8] Support for transparent PUD pages
Date: Thu, 24 Dec 2015 11:20:29 -0500
Message-Id: <1450974037-24775-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

We have customer demand to use 1GB pages to map DAX files.  Unlike the 2MB
page support, the Linux MM does not currently support PUD pages, so I have
attempted to add support for the necessary pieces for DAX huge PUD pages.

Filesystem support is a bit sticky.  I have not been able to persuade ext4
to give me more than 16MB of contiguous space, although it is aligned.
XFS will give me 80MB short of 1GB, but it's not aligned.  I'm in no
hurry to get patches 7 & 8 merged until the block allocation problem is
solved in those filesystems.

This patch set is against something approximately current -mm.  At this
point, I would be most grateful for MM developers to give feedback on
the first three patches.  Review from X86 maintainers on patch 4 would
also be welcome.  I'd like to thank Ross Zwisler for his helpful review
during development.

I've done some light testing using a program to mmap a block device
with DAX enabled, calling mincore() and examining /proc/smaps and
/proc/pagemap.

Matthew Wilcox (8):
  mm: Add optional support for PUD-sized transparent hugepages
  mincore: Add support for PUDs
  procfs: Add support for PUDs to smaps, clear_refs and pagemap
  x86: Add support for PUD-sized transparent hugepages
  dax: Support for transparent PUD pages
  block_dev: Support PUD DAX mappings
  xfs: Support for transparent PUD pages
  ext4: Transparent support for PUD-sized transparent huge pages

 arch/Kconfig                          |   3 +
 arch/x86/Kconfig                      |   1 +
 arch/x86/include/asm/paravirt.h       |  11 ++
 arch/x86/include/asm/paravirt_types.h |   2 +
 arch/x86/include/asm/pgtable.h        |  95 ++++++++++++++
 arch/x86/include/asm/pgtable_64.h     |  13 ++
 arch/x86/kernel/paravirt.c            |   1 +
 arch/x86/mm/pgtable.c                 |  31 +++++
 fs/block_dev.c                        |   7 +
 fs/dax.c                              | 239 +++++++++++++++++++++++++++++++---
 fs/ext4/file.c                        |  37 ++++++
 fs/proc/task_mmu.c                    | 109 ++++++++++++++++
 fs/xfs/xfs_file.c                     |  33 +++++
 fs/xfs/xfs_trace.h                    |   1 +
 include/asm-generic/pgtable.h         |  62 ++++++++-
 include/asm-generic/tlb.h             |  14 ++
 include/linux/dax.h                   |  21 +++
 include/linux/huge_mm.h               |  52 +++++++-
 include/linux/mm.h                    |  30 +++++
 include/linux/mmu_notifier.h          |  13 ++
 mm/huge_memory.c                      | 151 +++++++++++++++++++++
 mm/memory.c                           |  67 ++++++++++
 mm/mincore.c                          |  13 ++
 mm/pagewalk.c                         |  19 ++-
 mm/pgtable-generic.c                  |  14 ++
 25 files changed, 1016 insertions(+), 23 deletions(-)

-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
