Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6646182995
	for <linux-mm@kvack.org>; Tue,  6 May 2014 10:38:09 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so586877pab.15
        for <linux-mm@kvack.org>; Tue, 06 May 2014 07:38:08 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id vw5si12102222pab.333.2014.05.06.07.38.08
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 07:38:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 0/8] remap_file_pages() decommission
Date: Tue,  6 May 2014 17:37:24 +0300
Message-Id: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Andrew,

This patchset replaces the syscall with emulation which creates new VMA on
each remap and remove code to support non-linear mappings.

Nonlinear mappings are pain to support and it seems there's no legitimate
use-cases nowadays since 64-bit systems are widely available.

It's not yet ready to apply. Just to give rough idea of what can we get if
we'll deprecated remap_file_pages().

I need to split patches properly and write correct commit messages. And there's
still code to remove.

Comments?

Kirill A. Shutemov (8):
  mm: replace remap_file_pages() syscall with emulation
  mm: kill vm_operations_struct->remap_pages
  mm: kill zap_details->nonlinear_vma
  mm, rmap: kill rmap_walk_control->file_nonlinear()
  mm, rmap: kill vma->shared.nonlinear
  mm, rmap: kill mapping->i_mmap_nonlinear
  mm: kill VM_NONLINEAR and FAULT_FLAG_NONLINEAR
  mm, x86: kill pte_to_pgoff(), pgoff_to_pte() and pte_file*()

 Documentation/cachetlb.txt            |   4 +-
 arch/x86/include/asm/pgtable-2level.h |  39 -----
 arch/x86/include/asm/pgtable-3level.h |   4 -
 arch/x86/include/asm/pgtable.h        |  20 ---
 arch/x86/include/asm/pgtable_64.h     |   4 -
 arch/x86/include/asm/pgtable_types.h  |   3 +-
 drivers/gpu/drm/drm_vma_manager.c     |   3 +-
 fs/9p/vfs_file.c                      |   2 -
 fs/btrfs/file.c                       |   1 -
 fs/ceph/addr.c                        |   1 -
 fs/cifs/file.c                        |   1 -
 fs/ext4/file.c                        |   1 -
 fs/f2fs/file.c                        |   1 -
 fs/fuse/file.c                        |   1 -
 fs/gfs2/file.c                        |   1 -
 fs/inode.c                            |   1 -
 fs/nfs/file.c                         |   1 -
 fs/nilfs2/file.c                      |   1 -
 fs/ocfs2/mmap.c                       |   1 -
 fs/proc/task_mmu.c                    |  10 --
 fs/ubifs/file.c                       |   1 -
 fs/xfs/xfs_file.c                     |   1 -
 include/linux/fs.h                    |   6 +-
 include/linux/mm.h                    |  12 --
 include/linux/mm_types.h              |  12 +-
 include/linux/rmap.h                  |   2 -
 include/linux/swapops.h               |   4 +-
 kernel/fork.c                         |   8 +-
 mm/Makefile                           |   2 +-
 mm/filemap.c                          |   1 -
 mm/filemap_xip.c                      |   1 -
 mm/fremap.c                           | 282 ----------------------------------
 mm/interval_tree.c                    |  34 ++--
 mm/ksm.c                              |   2 +-
 mm/madvise.c                          |  13 +-
 mm/memcontrol.c                       |   7 +-
 mm/memory.c                           | 201 +++++++-----------------
 mm/migrate.c                          |  32 ----
 mm/mincore.c                          |   5 +-
 mm/mmap.c                             |  89 +++++++++--
 mm/mprotect.c                         |   2 +-
 mm/mremap.c                           |   2 -
 mm/nommu.c                            |   8 -
 mm/rmap.c                             | 222 +-------------------------
 mm/shmem.c                            |   1 -
 mm/swap.c                             |   1 -
 46 files changed, 168 insertions(+), 883 deletions(-)
 delete mode 100644 mm/fremap.c

-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
