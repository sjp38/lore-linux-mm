Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A59E96B0254
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 17:59:27 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id td3so83182673pab.2
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 14:59:27 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id x72si16742916pfi.196.2016.03.11.14.59.25
        for <linux-mm@kvack.org>;
        Fri, 11 Mar 2016 14:59:25 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 00/25] THP-enabled tmpfs/shmem
Date: Sat, 12 Mar 2016 01:58:52 +0300
Message-Id: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here is an updated version of huge pages support implementation in
tmpfs/shmem.

All known issues has been fixed. I'll continue with validation.
I will also send follow up patch with documentation update.

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

Git tree:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v4

Rebased onto linux-next:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v4-next

== Changelog ==

v4:
  - first four patch were applied to -mm tree;

  - drop pages beyond i_size on split_huge_pages;

  - few small random bugfixes;

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

  - Lockless access is prevented by setting the head->_count to 0 during
    split, so get_page_unless_zero() would fail;

  - After split, some pages can be beyond i_size. We drop them from
    radix-tree.

  - We don't setup migration entries. Just unmap pages. It helps
    handling cases when i_size is in the middle of the page: no need
    handle unmap pages beyond i_size manually.

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
I don't think this will be a problem.

== Patchset overview ==

[01-04/25]
        Rework fault path and rmap to handle file pmd. Unlike DAX with
        vm_ops->pmd_fault, we don't need to ask filesystem twice -- first
        for huge page and then for small. If ->fault happened to return
        huge page and VMA is suitable for mapping it as huge, we would
	do so.
[05/25]
	Add support for huge file pages in rmap;

[06-16/25]
        Various preparation of THP core for file pages.

[17-21/25]
        Various preparation of MM core for file pages.

[22-24/25]
        And finally, bring huge pages into tmpfs/shmem.

[25/25]
	Wire up madvise() existing hints for file THP.
	We can implement fadvise() later.

[1] http://lkml.kernel.org/g/alpine.LSU.2.11.1502201941340.14414@eggly.anvils

Hugh Dickins (1):
  shmem: get_unmapped_area align huge page

Kirill A. Shutemov (24):
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
 include/linux/huge_mm.h           |  26 +-
 include/linux/mm.h                |  51 ++-
 include/linux/mmzone.h            |   3 +-
 include/linux/page-flags.h        |  19 +-
 include/linux/radix-tree.h        |   1 +
 include/linux/rmap.h              |   2 +-
 include/linux/shmem_fs.h          |   5 +-
 include/linux/userfaultfd_k.h     |   8 +-
 include/linux/vm_event_item.h     |   7 +
 ipc/shm.c                         |   6 +-
 lib/radix-tree.c                  |  68 ++-
 mm/filemap.c                      | 220 +++++++---
 mm/gup.c                          |   7 +-
 mm/huge_memory.c                  | 564 ++++++++++++++-----------
 mm/internal.h                     |   4 +-
 mm/ksm.c                          |   3 +-
 mm/memory.c                       | 852 +++++++++++++++++++++-----------------
 mm/mempolicy.c                    |   4 +-
 mm/migrate.c                      |   5 +-
 mm/mmap.c                         |  26 +-
 mm/mremap.c                       |  22 +-
 mm/nommu.c                        |   3 +-
 mm/page-writeback.c               |   1 +
 mm/page_alloc.c                   |   2 +
 mm/rmap.c                         |  76 +++-
 mm/shmem.c                        | 621 +++++++++++++++++++++++----
 mm/swap.c                         |   2 +
 mm/truncate.c                     |  22 +-
 mm/util.c                         |   6 +
 mm/vmscan.c                       |  15 +-
 mm/vmstat.c                       |   3 +
 68 files changed, 1866 insertions(+), 925 deletions(-)

-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
