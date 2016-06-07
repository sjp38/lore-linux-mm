Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D68B26B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 07:00:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so15389950pfa.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 04:00:55 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id f10si34490098pfj.137.2016.06.07.04.00.53
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 04:00:54 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased 00/32] THP-enabled tmpfs/shmem using compound pages
Date: Tue,  7 Jun 2016 14:00:14 +0300
Message-Id: <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It's the same as v9, but rebased to v4.7-rc2-mmotm-2016-06-06-16-15 to
solve khugepaged-related conflicts.

It also can be found at

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v9-rebased

Hugh Dickins (1):
  shmem: get_unmapped_area align huge page

Kirill A. Shutemov (31):
  thp, mlock: update unevictable-lru.txt
  mm: do not pass mm_struct into handle_mm_fault
  mm: introduce fault_env
  mm: postpone page table allocation until we have page to map
  rmap: support file thp
  mm: introduce do_set_pmd()
  thp, vmstats: add counters for huge file pages
  thp: support file pages in zap_huge_pmd()
  thp: handle file pages in split_huge_pmd()
  thp: handle file COW faults
  thp: skip file huge pmd on copy_huge_pmd()
  thp: prepare change_huge_pmd() for file thp
  thp: run vma_adjust_trans_huge() outside i_mmap_rwsem
  thp: file pages support for split_huge_page()
  thp, mlock: do not mlock PTE-mapped file huge pages
  vmscan: split file huge pages before paging them out
  page-flags: relax policy for PG_mappedtodisk and PG_reclaim
  radix-tree: implement radix_tree_maybe_preload_order()
  filemap: prepare find and delete operations for huge pages
  truncate: handle file thp
  mm, rmap: account shmem thp pages
  shmem: prepare huge= mount option and sysfs knob
  shmem: add huge pages support
  shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappings
  thp: extract khugepaged from mm/huge_memory.c
  khugepaged: move up_read(mmap_sem) out of khugepaged_alloc_page()
  shmem: make shmem_inode_info::lock irq-safe
  khugepaged: add support of collapse for tmpfs/shmem pages
  thp: introduce CONFIG_TRANSPARENT_HUGE_PAGECACHE
  shmem: split huge pages beyond i_size under memory pressure
  thp: update Documentation/{vm/transhuge,filesystems/proc}.txt

 Documentation/filesystems/Locking    |   10 +-
 Documentation/filesystems/proc.txt   |    9 +
 Documentation/vm/transhuge.txt       |  128 ++-
 Documentation/vm/unevictable-lru.txt |   21 +
 arch/alpha/mm/fault.c                |    2 +-
 arch/arc/mm/fault.c                  |    2 +-
 arch/arm/mm/fault.c                  |    2 +-
 arch/arm64/mm/fault.c                |    2 +-
 arch/avr32/mm/fault.c                |    2 +-
 arch/cris/mm/fault.c                 |    2 +-
 arch/frv/mm/fault.c                  |    2 +-
 arch/hexagon/mm/vm_fault.c           |    2 +-
 arch/ia64/mm/fault.c                 |    2 +-
 arch/m32r/mm/fault.c                 |    2 +-
 arch/m68k/mm/fault.c                 |    2 +-
 arch/metag/mm/fault.c                |    2 +-
 arch/microblaze/mm/fault.c           |    2 +-
 arch/mips/mm/fault.c                 |    2 +-
 arch/mn10300/mm/fault.c              |    2 +-
 arch/nios2/mm/fault.c                |    2 +-
 arch/openrisc/mm/fault.c             |    2 +-
 arch/parisc/mm/fault.c               |    2 +-
 arch/powerpc/mm/copro_fault.c        |    2 +-
 arch/powerpc/mm/fault.c              |    2 +-
 arch/s390/mm/fault.c                 |    2 +-
 arch/score/mm/fault.c                |    2 +-
 arch/sh/mm/fault.c                   |    2 +-
 arch/sparc/mm/fault_32.c             |    4 +-
 arch/sparc/mm/fault_64.c             |    2 +-
 arch/tile/mm/fault.c                 |    2 +-
 arch/um/kernel/trap.c                |    2 +-
 arch/unicore32/mm/fault.c            |    2 +-
 arch/x86/mm/fault.c                  |    2 +-
 arch/xtensa/mm/fault.c               |    2 +-
 drivers/base/node.c                  |   13 +-
 drivers/char/mem.c                   |   24 +
 drivers/iommu/amd_iommu_v2.c         |    3 +-
 drivers/iommu/intel-svm.c            |    2 +-
 fs/proc/meminfo.c                    |    7 +-
 fs/proc/task_mmu.c                   |   10 +-
 fs/userfaultfd.c                     |   22 +-
 include/linux/huge_mm.h              |   36 +-
 include/linux/khugepaged.h           |    6 +
 include/linux/mm.h                   |   51 +-
 include/linux/mmzone.h               |    4 +-
 include/linux/page-flags.h           |   19 +-
 include/linux/radix-tree.h           |    1 +
 include/linux/rmap.h                 |    2 +-
 include/linux/shmem_fs.h             |   45 +-
 include/linux/userfaultfd_k.h        |    8 +-
 include/linux/vm_event_item.h        |    7 +
 include/trace/events/huge_memory.h   |    3 +-
 ipc/shm.c                            |   10 +-
 lib/radix-tree.c                     |   84 +-
 mm/Kconfig                           |    8 +
 mm/Makefile                          |    2 +-
 mm/filemap.c                         |  217 ++--
 mm/gup.c                             |    7 +-
 mm/huge_memory.c                     | 2101 ++++++----------------------------
 mm/internal.h                        |    4 +-
 mm/khugepaged.c                      | 1910 +++++++++++++++++++++++++++++++
 mm/ksm.c                             |    5 +-
 mm/memory.c                          |  879 +++++++-------
 mm/mempolicy.c                       |    2 +-
 mm/migrate.c                         |    5 +-
 mm/mmap.c                            |   26 +-
 mm/nommu.c                           |    3 +-
 mm/page-writeback.c                  |    1 +
 mm/page_alloc.c                      |   21 +
 mm/rmap.c                            |   78 +-
 mm/shmem.c                           |  918 +++++++++++++--
 mm/swap.c                            |    2 +
 mm/truncate.c                        |   28 +-
 mm/util.c                            |    6 +
 mm/vmscan.c                          |    6 +
 mm/vmstat.c                          |    4 +
 76 files changed, 4330 insertions(+), 2490 deletions(-)
 create mode 100644 mm/khugepaged.c

-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
