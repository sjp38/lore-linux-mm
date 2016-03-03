Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id BCC126B0256
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 11:52:41 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fy10so17584720pac.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 08:52:41 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id f63si66596958pfj.137.2016.03.03.08.52.33
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 08:52:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 00/29] huge tmpfs implementation using compound pages
Date: Thu,  3 Mar 2016 19:51:50 +0300
Message-Id: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here is an updated version of huge pages support implementation in
tmpfs/shmem.

I consider it feature complete for initial step into upstream. I'll focus
on validation now. I work with Sasha on that.

Hugh, I would be glad to hear your opinion on this patchset.

The main difference with Hugh's approach[1] is that I continue with
compound pages, where Hugh invents new way couple pages: team pages.
I believe THP refcounting rework made team pages unnecessary: compound
page are flexible enough to serve needs of page cache.

Many ideas and some patches were stolen from Hugh's patchset. Having this
patchset around was very helpful.

I will continue with code validation. I would expect mlock require some
more attention.

Please, review and test the code.

[1] http://lkml.kernel.org/g/alpine.LSU.2.11.1502201941340.14414@eggly.anvils

Git tree:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v3

== Changelog ==

v3:
  - huge= mountoption now can have values always, within_size, advice and
    never;

  - sysctl handle is replaced with sysfs knob;

  - MADV_HUGEPAGE/MADV_NOHUGEPAGE is now respected on page allocation via
    page fault;

  - mlock() handling had been fixed;

  - bunch of smaller bugfixes and cleanups.

== Design overview ==

Huge pages are allocated by shmem when it's allowed (by mount option) and
there's no entries for the range in radix-tree. Huge page is represented by
HPAGE_PMD_NR entries in radix-tree.

MM core maps a page with PMD if ->fault() returns huge page and the VMA is
suitable for huge pages (size, alignment). There's no need into two
requests to file system: filesystem returns huge page if it can,
graceful fallback to small pages otherwise.

As with DAX, split_huge_pmd() is implemented by unmapping the PMD: we can
re-fault the page with PTEs later.

Basic scheme for split_huge_page() is the same as for anon-THP.
Few differences:

  - File pages are on radix-tree, so we have head->_count offset by
    HPAGE_PMD_NR. The count got distributed to small pages during split.

  - mapping->tree_lock prevents non-lockless access to pages under split
    over radix-tree;

  - lockless access is prevented by setting the head->_count to 0 during
    split, so get_page_unless_zero() would fail;

After the page is split, some of small pages can be beyond i_size. We
cannot drop them right away in split_huge_page() due unsuitable locking
context -- one of such pages can be locked by split_huge_page() caller,
which can lead to deadlock in shmem_undo_range(). For now, I leave these
pages alone. I'll look into the problem more for v4.

COW mapping handled on PTE-level. It's not clear how beneficial would be
allocation of huge pages on COW faults. And it would require some code to
make them work.

I think at some point we can consider teaching khugepaged to collapse
pages in COW mappings, but allocating huge on fault is probably overkill.

As with anon THP, we mlock file huge page only if it mapped with PMD.
PTE-mapped THPs are never mlocked. This way we can avoid all sorts of
scenarios when we can leak mlocked page.

As with anon THP, we split huge page on swap out.

Truncate and punch hole that only cover part of THP range is implemented
by zero out this part of THP.

This have visible effect on fallocate(FALLOC_FL_PUNCH_HOLE) behaviour.
As we don't really create hole in this case, lseek(SEEK_HOLE) may have
inconsistent results depending what pages happened to be allocated.
Not sure if it should be considered ABI break or not.


== Patchset overview ==

[01-04/29]
	These patches were posted separately. They simplify
	split_huge_page() code with speed trade off. I'm not sure if they
	should go upstream, but they make my life easier for now.
	Patches were slightly adjust to handle file pages too.

[05-09/29]
        Rework fault path and rmap to handle file pmd. Unlike DAX with
        vm_ops->pmd_fault, we don't need to ask filesystem twice -- first
        for huge page and then for small. If ->fault happened to return
        huge page and VMA is suitable for mapping it as huge, we would
	do so.
[10/29]
	Add support for huge file pages in rmap;

[11-20/29]
        Various preparation of THP core for file pages.

[21-25/29]
        Various preparation of MM core for file pages.

[26-28/29]
        And finally, bring huge pages into tmpfs/shmem.
        Two of three patches came from Hugh's patchset. :)
[29/29]
	Wire up madvise() existing hints for file THP.
	We can implement fadvise() later.

Hugh Dickins (1):
  shmem: get_unmapped_area align huge page

Kirill A. Shutemov (28):
  rmap: introduce rmap_walk_locked()
  rmap: extend try_to_unmap() to be usable by split_huge_page()
  mm: make remove_migration_ptes() beyond mm/migration.c
  thp: rewrite freeze_page()/unfreeze_page() with generic rmap walkers
  mm: do not pass mm_struct into handle_mm_fault
  mm: introduce fault_env
  mm: postpone page table allocation until we have page to map
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
  thp, mlock: do not mlock PTE-mapped file huge pages
  vmscan: split file huge pages before paging them out
  page-flags: relax policy for PG_mappedtodisk and PG_reclaim
  radix-tree: implement radix_tree_maybe_preload_order()
  filemap: prepare find and delete operations for huge pages
  truncate: handle file thp
  shmem: prepare huge= mount option and sysfs knob
  shmem: add huge pages support
  shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappings

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
 include/linux/huge_mm.h           |  33 +-
 include/linux/mm.h                |  51 ++-
 include/linux/mmzone.h            |   3 +-
 include/linux/page-flags.h        |  19 +-
 include/linux/radix-tree.h        |   1 +
 include/linux/rmap.h              |   8 +-
 include/linux/shmem_fs.h          |   5 +-
 include/linux/userfaultfd_k.h     |   8 +-
 include/linux/vm_event_item.h     |   7 +
 ipc/shm.c                         |   6 +-
 lib/radix-tree.c                  |  68 ++-
 mm/filemap.c                      | 220 +++++++---
 mm/gup.c                          |   7 +-
 mm/huge_memory.c                  | 763 +++++++++++++++-------------------
 mm/internal.h                     |   4 +-
 mm/ksm.c                          |   3 +-
 mm/memory.c                       | 852 +++++++++++++++++++++-----------------
 mm/mempolicy.c                    |   4 +-
 mm/migrate.c                      |  20 +-
 mm/mmap.c                         |  26 +-
 mm/mremap.c                       |  22 +-
 mm/nommu.c                        |   3 +-
 mm/page-writeback.c               |   1 +
 mm/page_alloc.c                   |   2 +
 mm/rmap.c                         | 141 +++++--
 mm/shmem.c                        | 620 +++++++++++++++++++++++----
 mm/swap.c                         |   2 +
 mm/truncate.c                     |  22 +-
 mm/util.c                         |   6 +
 mm/vmscan.c                       |  15 +-
 mm/vmstat.c                       |   3 +
 68 files changed, 1944 insertions(+), 1138 deletions(-)

-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
