Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D745D9003C7
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 16:29:35 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so189836697pdb.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:29:35 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id dx5si4577642pbc.22.2015.07.10.13.29.34
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 13:29:35 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 00/10] Huge page support for DAX files
Date: Fri, 10 Jul 2015 16:29:15 -0400
Message-Id: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

This series of patches adds support for using PMD page table entries
to map DAX files.  We expect NV-DIMMs to start showing up that are
many gigabytes in size and the memory consumption of 4kB PTEs will
be astronomical.

The patch series leverages much of the Transparant Huge Pages
infrastructure, going so far as to borrow one of Kirill's patches from
his THP page cache series.

The ext2 and XFS patches are merely compile tested.  The ext4 code has
survived the NVML test suite, some Trinity testing and an xfstests run.

Kirill A. Shutemov (1):
  thp: vma_adjust_trans_huge(): adjust file-backed VMA too

Matthew Wilcox (9):
  dax: Move DAX-related functions to a new header
  thp: Prepare for DAX huge pages
  mm: Add a pmd_fault handler
  mm: Export various functions for the benefit of DAX
  mm: Add vmf_insert_pfn_pmd()
  dax: Add huge page fault support
  ext2: Huge page fault support
  ext4: Huge page fault support
  xfs: Huge page fault support

 Documentation/filesystems/dax.txt |   7 +-
 fs/block_dev.c                    |   1 +
 fs/dax.c                          | 152 ++++++++++++++++++++++++++++++++++++++
 fs/ext2/file.c                    |  10 ++-
 fs/ext2/inode.c                   |   1 +
 fs/ext4/file.c                    |  11 ++-
 fs/ext4/indirect.c                |   1 +
 fs/ext4/inode.c                   |   1 +
 fs/xfs/xfs_buf.h                  |   1 +
 fs/xfs/xfs_file.c                 |  30 +++++++-
 fs/xfs/xfs_trace.h                |   1 +
 include/linux/dax.h               |  39 ++++++++++
 include/linux/fs.h                |  14 ----
 include/linux/huge_mm.h           |  23 +++---
 include/linux/mm.h                |   2 +
 mm/huge_memory.c                  | 100 ++++++++++++++++++-------
 mm/memory.c                       |  30 ++++++--
 17 files changed, 362 insertions(+), 62 deletions(-)
 create mode 100644 include/linux/dax.h

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
