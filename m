Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 696456B0266
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:23:14 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id e127so30220653pfe.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:23:14 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id p71si12911708pfi.128.2016.02.11.06.22.47
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:22:47 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 00/28] huge tmpfs implementation using compound pages
Date: Thu, 11 Feb 2016 17:21:28 +0300
Message-Id: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here is my implementation of huge pages support in tmpfs/shmem. It's more
or less complete. I'm comfortable enough with this to run my workstation.

And it hasn't crashed so far. :)

The main difference with Hugh's approach[1] is that I continue with
compound pages, where Hugh invents new way couple pages: team pages.
I believe THP refcounting rework made team pages unnecessary: compound
page are flexible enough to serve needs of page cache.

Many ideas and some patches were stolen from Hugh's patchset. Having this
patchset around was very helpful.

I will continue with code validation. I would expect mlock require some
more attention.

Please, review and test the code.

Git tree:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v2

== Patchset overview ==

[01/28]
	I've posted the patch last night. I stepped on the bug during my
	testing of huge tmpfs, but I think DAX has the same problem, so it
	should be applied now.

[02-05/28]
	These patches also where posted separately. They simplify
	split_huge_page() code with speed trade off. I'm not sure if they
	should go upstream, but they make my life easier for now.
	Patches were slightly adjust to handle file pages too.

[06-11/28]
	Rework fault path and rmap to handle file pmd. Unlike DAX with
	vm_ops->pmd_fault, we don't need to ask filesystem twice -- first
	for huge page and then for small. If ->fault happend to return
	huge page and VMA is suitable for mapping it as huge, we would do
	so.

[12-20/28]
	Various preparation of THP core for file pages.

[21-25/28]
	Various preparation of MM core for file pages.

[26-28/28]
	And finally, bring huge pages into tmpfs/shmem.
	Two of three patches came from Hugh's patchset. :)

[1] http://lkml.kernel.org/g/alpine.LSU.2.11.1502201941340.14414@eggly.anvils

Hugh Dickins (2):
  shmem: prepare huge=N mount option and /proc/sys/vm/shmem_huge
  shmem: get_unmapped_area align huge page

Kirill A. Shutemov (26):
  thp, dax: do not try to withdraw pgtable from non-anon VMA
  rmap: introduce rmap_walk_locked()
  rmap: extend try_to_unmap() to be usable by split_huge_page()
  mm: make remove_migration_ptes() beyond mm/migration.c
  thp: rewrite freeze_page()/unfreeze_page() with generic rmap walkers
  mm: do not pass mm_struct into handle_mm_fault
  mm: introduce fault_env
  mm: postpone page table allocation until do_set_pte()
  rmap: support file thp
  mm: introduce do_set_pmd()
  mm, rmap: account file thp pages
  thp, vmstats: add counters for huge file pages
  thp: support file pages in zap_huge_pmd()
  thp: handle file pages in split_huge_pmd()
  thp: handle file COW faults
  thp: handle file pages in mremap()
  thp: skip file huge pmd on copy_huge_pmd()
  thp: prepare change_huge_pmd() for file thp
  thp: run vma_adjust_trans_huge() outside i_mmap_rwsem
  thp: file pages support for split_huge_page()
  vmscan: split file huge pages before paging them out
  page-flags: relax policy for PG_mappedtodisk and PG_reclaim
  radix-tree: implement radix_tree_maybe_preload_order()
  filemap: prepare find and delete operations for huge pages
  truncate: handle file thp
  shmem: add huge pages support

 Documentation/filesystems/Locking |  10 +-
 arch/alpha/mm/fault.c             |   2 +-
 arch/arc/mm/fault.c               |   2 +-
 arch/arm/mm/fault.c               |   2 +-
 arch/arm64/mm/fault.c             |   2 +-
 arch/avr32/mm/fault.c             |   2 +-
 arch/cris/mm/fault.c              |   2 +-
 arch/frv/mm/fault.c               |   2 +-
 arch/hexagon/mm/vm_fault.c        |   2 +-
 arch/ia64/mm/fault.c              |   2 +-
 arch/m32r/mm/fault.c              |   2 +-
 arch/m68k/mm/fault.c              |   2 +-
 arch/metag/mm/fault.c             |   2 +-
 arch/microblaze/mm/fault.c        |   2 +-
 arch/mips/mm/fault.c              |   2 +-
 arch/mn10300/mm/fault.c           |   2 +-
 arch/nios2/mm/fault.c             |   2 +-
 arch/openrisc/mm/fault.c          |   2 +-
 arch/parisc/mm/fault.c            |   2 +-
 arch/powerpc/mm/copro_fault.c     |   2 +-
 arch/powerpc/mm/fault.c           |   2 +-
 arch/s390/mm/fault.c              |   2 +-
 arch/score/mm/fault.c             |   2 +-
 arch/sh/mm/fault.c                |   2 +-
 arch/sparc/mm/fault_32.c          |   4 +-
 arch/sparc/mm/fault_64.c          |   2 +-
 arch/tile/mm/fault.c              |   2 +-
 arch/um/kernel/trap.c             |   2 +-
 arch/unicore32/mm/fault.c         |   2 +-
 arch/x86/mm/fault.c               |   2 +-
 arch/xtensa/mm/fault.c            |   2 +-
 drivers/base/node.c               |  10 +-
 drivers/char/mem.c                |  24 ++
 drivers/iommu/amd_iommu_v2.c      |   2 +-
 drivers/iommu/intel-svm.c         |   2 +-
 fs/proc/meminfo.c                 |   5 +-
 fs/userfaultfd.c                  |  22 +-
 include/linux/huge_mm.h           |  29 +-
 include/linux/mm.h                |  33 +-
 include/linux/mmzone.h            |   3 +-
 include/linux/page-flags.h        |   6 +-
 include/linux/radix-tree.h        |   1 +
 include/linux/rmap.h              |   8 +-
 include/linux/shmem_fs.h          |  18 +-
 include/linux/userfaultfd_k.h     |   8 +-
 include/linux/vm_event_item.h     |   7 +
 ipc/shm.c                         |   6 +-
 kernel/sysctl.c                   |  12 +
 lib/radix-tree.c                  |  70 +++-
 mm/filemap.c                      | 220 +++++++----
 mm/gup.c                          |   7 +-
 mm/huge_memory.c                  | 714 ++++++++++++++--------------------
 mm/internal.h                     |  20 +-
 mm/ksm.c                          |   3 +-
 mm/memory.c                       | 796 +++++++++++++++++++++-----------------
 mm/mempolicy.c                    |   4 +-
 mm/migrate.c                      |  17 +-
 mm/mmap.c                         |  20 +-
 mm/mremap.c                       |  22 +-
 mm/nommu.c                        |   3 +-
 mm/page-writeback.c               |   1 +
 mm/rmap.c                         | 125 ++++--
 mm/shmem.c                        | 493 +++++++++++++++++++----
 mm/swap.c                         |   2 +
 mm/truncate.c                     |  22 +-
 mm/util.c                         |   6 +
 mm/vmscan.c                       |  15 +-
 mm/vmstat.c                       |   3 +
 68 files changed, 1727 insertions(+), 1104 deletions(-)

-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
