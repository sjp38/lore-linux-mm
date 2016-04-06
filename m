Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id B90A56B0264
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:51:33 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id n1so42342893pfn.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:51:33 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qn9si7245269pab.159.2016.04.06.15.51.27
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:27 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 00/30] THP-enabled tmpfs/shmem using compound pages
Date: Thu,  7 Apr 2016 01:50:50 +0300
Message-Id: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hugh pointed that collapse (or recovery) support is a deal breaker for my
hugetmpfs patchset to be consider for inclusion.

So I try to catch up on that. :)

I've extended khugepaged to deal with shmem. This part is still
experimental, but it seems works fine with use-cases I've tested it.
Some bugs are expected. I'm committed to make it work.

The main part of patchset (excluding khugepaged patches) I consider good
enough for -mm tree.

I was a bit frustrated with fast-tracking Hugh's patchset into -mm tree.
We haven't had chance to discuss interface differences and consolidate
approaches. It's required to be able to switch to compound pages based
implementation later.

And I still hope we can consider my approach for initial implementation of
huge pages. I've just finished other major infrastructure rework under
THP. It wasn't fun... :-/


I had trouble to choose appropriate base for the patchset. I've end up
with 4a2d057e4fc4 (v4.6-rc2 + PAGE_CACHE_* removal, from Linus' tree) plus
cherry-picked khugepaged swapin patches form -mm tree.

Git tree:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v6

== Changelog ==

v6:
  - experimental collapse support;

  - fix swapout mapped huge pages;

  - fix page leak in faularound code;

  - fix exessive huge page allocation with huge=within_size;

  - rename VM_NO_THP to VM_NO_KHUGEPAGED;

  - fix condition in hugepage_madvise();

  - accounting reworked again;

v5:
  - add FileHugeMapped to /proc/PID/smaps;

  - make FileHugeMapped in meminfo aligned with other fields;

  - Documentation/vm/transhuge.txt updated;

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

[01/30]
	Update documentation on THP vs. mlock. I've posted it separately
	before. It can go in.

[02-04/30]
        Rework fault path and rmap to handle file pmd. Unlike DAX with
        vm_ops->pmd_fault, we don't need to ask filesystem twice -- first
        for huge page and then for small. If ->fault happened to return
        huge page and VMA is suitable for mapping it as huge, we would
	do so.
[05/30]
	Add support for huge file pages in rmap;

[06-16/30]
        Various preparation of THP core for file pages.

[17-21/30]
        Various preparation of MM core for file pages.

[22-25/30]
        And finally, bring huge pages into tmpfs/shmem.

[26/30]
	Wire up madvise() existing hints for file THP.
	We can implement fadvise() later.

[27/30]
	Documentation update.

[28-30/30]
	Extend khugepaged to support shmem/tmpfs.

Hugh Dickins (1):
  shmem: get_unmapped_area align huge page

Kirill A. Shutemov (29):
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
  mm, rmap: account shmem thp pages
  shmem: prepare huge= mount option and sysfs knob
  shmem: add huge pages support
  shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappings
  thp: update Documentation/vm/transhuge.txt
  thp: extract khugepaged from mm/huge_memory.c
  khugepaged: move up_read(mmap_sem) out of khugepaged_alloc_page()
  khugepaged: add support of collapse for tmpfs/shmem pages

 Documentation/filesystems/Locking    |   10 +-
 Documentation/vm/transhuge.txt       |  130 ++-
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
 include/linux/shmem_fs.h             |   30 +-
 include/linux/userfaultfd_k.h        |    8 +-
 include/linux/vm_event_item.h        |    7 +
 include/trace/events/huge_memory.h   |    3 +-
 ipc/shm.c                            |    6 +-
 lib/radix-tree.c                     |   68 +-
 mm/Makefile                          |    2 +-
 mm/filemap.c                         |  226 ++--
 mm/gup.c                             |    7 +-
 mm/huge_memory.c                     | 2028 ++++++----------------------------
 mm/internal.h                        |    4 +-
 mm/khugepaged.c                      | 1748 +++++++++++++++++++++++++++++
 mm/ksm.c                             |    5 +-
 mm/memory.c                          |  870 ++++++++-------
 mm/mempolicy.c                       |    4 +-
 mm/migrate.c                         |    5 +-
 mm/mmap.c                            |   26 +-
 mm/mremap.c                          |   22 +-
 mm/nommu.c                           |    3 +-
 mm/page-writeback.c                  |    1 +
 mm/page_alloc.c                      |   21 +
 mm/rmap.c                            |   78 +-
 mm/shmem.c                           |  713 ++++++++++--
 mm/swap.c                            |    2 +
 mm/truncate.c                        |   22 +-
 mm/util.c                            |    6 +
 mm/vmscan.c                          |    6 +
 mm/vmstat.c                          |    4 +
 75 files changed, 3922 insertions(+), 2426 deletions(-)
 create mode 100644 mm/khugepaged.c

-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
