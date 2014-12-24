Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 394C06B0032
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:02 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so9852666pac.8
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:01 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id mm8si17586481pbc.198.2014.12.24.04.22.59
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:00 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 00/38] mm: remove non-linear mess
Date: Wed, 24 Dec 2014 14:22:08 +0200
Message-Id: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We have remap_file_pages(2) emulation in -mm tree for few release cycles
and we plan to have it mainline in v3.20. This patchset removes rest of
VM_NONLINEAR infrastructure.

Patches 1-8 take care about generic code. They are pretty
straight-forward and can be applied without other of patches.

Rest patches removes pte_file()-related stuff from architecture-specific
code. It usually frees up one bit in non-present pte. I've tried to reuse
that bit for swap offset, where I was able to figure out how to do that.

For obvious reason I cannot test all that arch-specific code and would
like to see acks from maintainers.

In total, remap_file_pages(2) required about 1.4K lines of not-so-trivial
kernel code. That's too much for functionality nobody uses.

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git remap_file_pages

Kirill A. Shutemov (38):
  mm: drop support of non-linear mapping from unmap/zap codepath
  mm: drop support of non-linear mapping from fault codepath
  mm: drop vm_ops->remap_pages and generic_file_remap_pages() stub
  proc: drop handling non-linear mappings
  rmap: drop support of non-linear mappings
  mm: replace vma->sharead.linear with vma->shared
  mm: remove rest usage of VM_NONLINEAR and pte_file()
  asm-generic: drop unused pte_file* helpers
  alpha: drop _PAGE_FILE and pte_file()-related helpers
  arc: drop _PAGE_FILE and pte_file()-related helpers
  arm64: drop PTE_FILE and pte_file()-related helpers
  arm: drop L_PTE_FILE and pte_file()-related helpers
  avr32: drop _PAGE_FILE and pte_file()-related helpers
  blackfin: drop pte_file()
  c6x: drop pte_file()
  cris: drop _PAGE_FILE and pte_file()-related helpers
  frv: drop _PAGE_FILE and pte_file()-related helpers
  hexagon: drop _PAGE_FILE and pte_file()-related helpers
  ia64: drop _PAGE_FILE and pte_file()-related helpers
  m32r: drop _PAGE_FILE and pte_file()-related helpers
  m68k: drop _PAGE_FILE and pte_file()-related helpers
  metag: drop _PAGE_FILE and pte_file()-related helpers
  microblaze: drop _PAGE_FILE and pte_file()-related helpers
  mips: drop _PAGE_FILE and pte_file()-related helpers
  mn10300: drop _PAGE_FILE and pte_file()-related helpers
  nios2: drop _PAGE_FILE and pte_file()-related helpers
  openrisc: drop _PAGE_FILE and pte_file()-related helpers
  parisc: drop _PAGE_FILE and pte_file()-related helpers
  powerpc: drop _PAGE_FILE and pte_file()-related helpers
  s390: drop pte_file()-related helpers
  score: drop _PAGE_FILE and pte_file()-related helpers
  sh: drop _PAGE_FILE and pte_file()-related helpers
  sparc: drop pte_file()-related helpers
  tile: drop pte_file()-related helpers
  um: drop _PAGE_FILE and pte_file()-related helpers
  unicore32: drop pte_file()-related helpers
  x86: drop _PAGE_FILE and pte_file()-related helpers
  xtensa: drop _PAGE_FILE and pte_file()-related helpers

 Documentation/cachetlb.txt                 |   8 +-
 arch/alpha/include/asm/pgtable.h           |   7 -
 arch/arc/include/asm/pgtable.h             |  15 +-
 arch/arm/include/asm/pgtable-2level.h      |   1 -
 arch/arm/include/asm/pgtable-3level.h      |   1 -
 arch/arm/include/asm/pgtable-nommu.h       |   2 -
 arch/arm/include/asm/pgtable.h             |  20 +--
 arch/arm/mm/proc-macros.S                  |   2 +-
 arch/arm64/include/asm/pgtable.h           |  22 +--
 arch/avr32/include/asm/pgtable.h           |  25 ----
 arch/blackfin/include/asm/pgtable.h        |   5 -
 arch/c6x/include/asm/pgtable.h             |   5 -
 arch/cris/include/arch-v10/arch/mmu.h      |   3 -
 arch/cris/include/arch-v32/arch/mmu.h      |   3 -
 arch/cris/include/asm/pgtable.h            |   4 -
 arch/frv/include/asm/pgtable.h             |  27 +---
 arch/hexagon/include/asm/pgtable.h         |  60 ++------
 arch/ia64/include/asm/pgtable.h            |  25 +---
 arch/m32r/include/asm/pgtable-2level.h     |   4 -
 arch/m32r/include/asm/pgtable.h            |  11 --
 arch/m68k/include/asm/mcf_pgtable.h        |  23 +--
 arch/m68k/include/asm/motorola_pgtable.h   |  15 --
 arch/m68k/include/asm/pgtable_no.h         |   2 -
 arch/m68k/include/asm/sun3_pgtable.h       |  15 --
 arch/metag/include/asm/pgtable.h           |   6 -
 arch/microblaze/include/asm/pgtable.h      |  11 --
 arch/mips/include/asm/pgtable-32.h         |  36 -----
 arch/mips/include/asm/pgtable-64.h         |   9 --
 arch/mips/include/asm/pgtable-bits.h       |   9 --
 arch/mips/include/asm/pgtable.h            |   2 -
 arch/mn10300/include/asm/pgtable.h         |  17 +--
 arch/nios2/include/asm/pgtable-bits.h      |   1 -
 arch/nios2/include/asm/pgtable.h           |  10 +-
 arch/openrisc/include/asm/pgtable.h        |   8 -
 arch/openrisc/kernel/head.S                |   5 -
 arch/parisc/include/asm/pgtable.h          |  10 --
 arch/powerpc/include/asm/pgtable-ppc32.h   |   9 +-
 arch/powerpc/include/asm/pgtable-ppc64.h   |   5 +-
 arch/powerpc/include/asm/pgtable.h         |   1 -
 arch/powerpc/include/asm/pte-40x.h         |   1 -
 arch/powerpc/include/asm/pte-44x.h         |   5 -
 arch/powerpc/include/asm/pte-8xx.h         |   1 -
 arch/powerpc/include/asm/pte-book3e.h      |   1 -
 arch/powerpc/include/asm/pte-fsl-booke.h   |   3 -
 arch/powerpc/include/asm/pte-hash32.h      |   1 -
 arch/powerpc/include/asm/pte-hash64.h      |   1 -
 arch/powerpc/mm/pgtable_64.c               |   2 +-
 arch/s390/include/asm/pgtable.h            |  29 +---
 arch/score/include/asm/pgtable-bits.h      |   1 -
 arch/score/include/asm/pgtable.h           |  18 +--
 arch/sh/include/asm/pgtable_32.h           |  31 +---
 arch/sh/include/asm/pgtable_64.h           |   9 +-
 arch/sparc/include/asm/pgtable_32.h        |  24 ---
 arch/sparc/include/asm/pgtable_64.h        |  40 -----
 arch/sparc/include/asm/pgtsrmmu.h          |  14 +-
 arch/tile/include/asm/pgtable.h            |  11 --
 arch/tile/mm/homecache.c                   |   4 -
 arch/um/include/asm/pgtable-2level.h       |   9 --
 arch/um/include/asm/pgtable-3level.h       |  20 ---
 arch/um/include/asm/pgtable.h              |   9 --
 arch/unicore32/include/asm/pgtable-hwdef.h |   1 -
 arch/unicore32/include/asm/pgtable.h       |  14 --
 arch/x86/include/asm/pgtable-2level.h      |  38 +----
 arch/x86/include/asm/pgtable-3level.h      |  12 --
 arch/x86/include/asm/pgtable.h             |  20 ---
 arch/x86/include/asm/pgtable_64.h          |   6 +-
 arch/x86/include/asm/pgtable_types.h       |   3 -
 arch/xtensa/include/asm/pgtable.h          |  10 --
 drivers/gpu/drm/drm_vma_manager.c          |   3 +-
 fs/9p/vfs_file.c                           |   2 -
 fs/btrfs/file.c                            |   1 -
 fs/ceph/addr.c                             |   1 -
 fs/cifs/file.c                             |   1 -
 fs/ext4/file.c                             |   1 -
 fs/f2fs/file.c                             |   1 -
 fs/fuse/file.c                             |   1 -
 fs/gfs2/file.c                             |   1 -
 fs/inode.c                                 |   1 -
 fs/nfs/file.c                              |   1 -
 fs/nilfs2/file.c                           |   1 -
 fs/ocfs2/mmap.c                            |   1 -
 fs/proc/task_mmu.c                         |  16 --
 fs/ubifs/file.c                            |   1 -
 fs/xfs/xfs_file.c                          |   1 -
 include/asm-generic/pgtable.h              |  15 --
 include/linux/fs.h                         |  10 +-
 include/linux/mm.h                         |  27 +---
 include/linux/mm_types.h                   |  12 +-
 include/linux/rmap.h                       |   2 -
 include/linux/swapops.h                    |   4 +-
 kernel/fork.c                              |   8 +-
 mm/debug.c                                 |   1 -
 mm/filemap.c                               |   1 -
 mm/filemap_xip.c                           |   1 -
 mm/gup.c                                   |   2 +-
 mm/interval_tree.c                         |  34 ++---
 mm/ksm.c                                   |   2 +-
 mm/madvise.c                               |  13 +-
 mm/memcontrol.c                            |   4 +-
 mm/memory.c                                | 225 +++++++++--------------------
 mm/migrate.c                               |  32 ----
 mm/mincore.c                               |   5 +-
 mm/mmap.c                                  |  24 +--
 mm/mprotect.c                              |   2 +-
 mm/mremap.c                                |   2 -
 mm/msync.c                                 |   5 +-
 mm/rmap.c                                  | 225 +----------------------------
 mm/shmem.c                                 |   1 -
 mm/swap.c                                  |   4 +-
 109 files changed, 187 insertions(+), 1290 deletions(-)

-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
