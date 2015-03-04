Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2CC6B006E
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 11:33:24 -0500 (EST)
Received: by pabli10 with SMTP id li10so34711230pab.13
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 08:33:24 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id q3si5528855pdj.219.2015.03.04.08.33.20
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 08:33:21 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 00/24] THP refcounting redesign
Date: Wed,  4 Mar 2015 18:32:48 +0200
Message-Id: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hello everybody,

It's bug-fix update of my thp refcounting work.

The goal of patchset is to make refcounting on THP pages cheaper with
simpler semantics and allow the same THP compound page to be mapped with
PMD and PTEs. This is required to get reasonable THP-pagecache
implementation.

With the new refcounting design it's much easier to protect against
split_huge_page(): simple reference on a page will make you the deal.
It makes gup_fast() implementation simpler and doesn't require
special-case in futex code to handle tail THP pages.

It should improve THP utilization over the system since splitting THP in
one process doesn't necessary lead to splitting the page in all other
processes have the page mapped.

= Changelog =

v4:
  - fix sizes reported in smaps;
  - defines instead of enum for RMAP_{EXCLUSIVE,COMPOUND};
  - skip THP pages on munlock_vma_pages_range(): they are never mlocked;
  - properly handle huge zero page on FOLL_SPLIT;
  - fix lock_page() slow path on tail pages;
  - account page_get_anon_vma() fail to THP_SPLIT_PAGE_FAILED;
  - fix split_huge_page() on huge page with unmapped head page;
  - fix transfering 'write' and 'young' from pmd to ptes on split_huge_pmd;
  - call page_remove_rmap() in unfreeze_page under ptl.

= Design overview =

The main reason why we can't map THP with 4k is how refcounting on THP
designed. It built around two requirements:

  - split of huge page should never fail;
  - we can't change interface of get_user_page();

To be able to split huge page at any point we have to track which tail
page was pinned. It leads to tricky and expensive get_page() on tail pages
and also occupy tail_page->_mapcount.

Most split_huge_page*() users want PMD to be split into table of PTEs and
don't care whether compound page is going to be split or not.

The plan is:

 - allow split_huge_page() to fail if the page is pinned. It's trivial to
   split non-pinned page and it doesn't require tail page refcounting, so
   tail_page->_mapcount is free to be reused.

 - introduce new routine -- split_huge_pmd() -- to split PMD into table of
   PTEs. It splits only one PMD, not touching other PMDs the page is
   mapped with or underlying compound page. Unlike new split_huge_page(),
   split_huge_pmd() never fails.

Fortunately, we have only few places where split_huge_page() is needed:
swap out, memory failure, migration, KSM. And all of them can handle
split_huge_page() fail.

In new scheme we use page->_mapcount is used to account how many time
the page is mapped with PTEs. We have separate compound_mapcount() to
count mappings with PMD. page_mapcount() returns sum of PTE and PMD
mappings of the page.

Introducing split_huge_pmd() effectively allows THP to be mapped with 4k.
It may be a surprise to some code to see a PTE which points to tail page
or VMA start/end in the middle of compound page.

munmap() part of THP will split PMD, but doesn't split the huge page. In
order to take memory consuption under control we put partially unmapped
huge page on per-zone list, which would be drained on first shrink_zone()
call. This way we also avoid unnecessary split_huge_page() on exit(2) if a
THP belong to more than one VMA.

= Patches overview =

Patch 1:
        Move split_huge_page code around. Preparation for future changes.

Patches 2-3:
        Make PageAnon() and PG_locked related helpers to look on head
        page if tail page is passed. It's required since pte_page() can
        now point to tail page. It's likely that we need to change other
        pageflags-related helpers too, but I haven't step on any other
        yet.

Patch 4:
        With PTE-mapeed THP, rmap cannot rely on PageTransHuge() check to
        decide if map small page or THP. We need to get the info from
        caller.

Patch 5:
        We need to look on all subpages of compound page to calculate
        correct PSS, because they can have different mapcount.

Patch 6:
        Store mapcount for compound pages separately: in the first tail
        page ->mapping.

Patch 7:
        Adjust conditions when we can re-use the page on write-protection
        fault.

Patch 8:
        FOLL_SPLIT should be handled on PTE level too.

Patch 9:
        Split all pages in mlocked VMA. We would need to look on this
        again later.

Patch 10:
        Make khugepaged aware about PTE-mapped huge pages.

Patch 11:
        split_huge_page_pmd() to split_huge_pmd() to reflect that page is
        not going to be split, only PMD.

Patch 12:
        Temporary make split_huge_page() to return -EBUSY on all split
        requests. This allows to drop tail-page refcounting and change
        implementation of split_huge_pmd() to split PMD to table of PTEs
        without splitting compound page.

Patch 13:
        New THP_SPLIT_* vmstats.

Patch 14:
        Implement new split_huge_page() which fails if the page is pinned.
        For now, we rely on compound_lock() to make page counts stable.

Patches 15-16:
        Drop infrastructure for handling PMD splitting. We don't use it
        anymore in split_huge_page(). For now we only remove it from
        generic code and x86. I'll cleanup other architectures later.

Patch 17:
        Remove ugly special case if futex happened to be in tail THP page.
        With new refcounting it much easier to protect against split.

Patches 18-20:
        Replaces compound_lock with migration entries as mechanism to
        freeze page counts on split_huge_page(). We don't need
        compound_lock anymore. It makes get_page()/put_page() on tail
        pages faster.

Patch 21:
        Handle partial unmap of THP. We put partially unmapped huge page
        on per-zone list, which would be drained on first shrink_zone()
        call. This way we also avoid unnecessary split_huge_page() on
        exit(2) if a THP belong to more than one VMA.

Patch 22:
        Make memcg aware about new refcounting. Validation needed.

Patch 23:
        Fix never-succeed split_huge_page() inside KSM machinery.

Patch 24:
        Documentation update.

I believe all known bugs have been fixed, but I'm sure Sasha will bring more
reports.

The patchset also available on git:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git thp/refcounting/v4

Comments?
Kirill A. Shutemov (24):
  thp: cluster split_huge_page* code together
  mm: change PageAnon() and page_anon_vma() to work on tail pages
  mm: avoid PG_locked on tail pages
  rmap: add argument to charge compound page
  mm, proc: adjust PSS calculation
  mm: store mapcount for compound page separately
  mm, thp: adjust conditions when we can reuse the page on WP fault
  mm: adjust FOLL_SPLIT for new refcounting
  thp, mlock: do not allow huge pages in mlocked area
  khugepaged: ignore pmd tables with THP mapped with ptes
  thp: rename split_huge_page_pmd() to split_huge_pmd()
  thp: PMD splitting without splitting compound page
  mm, vmstats: new THP splitting event
  thp: implement new split_huge_page()
  mm, thp: remove infrastructure for handling splitting PMDs
  x86, thp: remove infrastructure for handling splitting PMDs
  futex, thp: remove special case for THP in get_futex_key
  thp, mm: split_huge_page(): caller need to lock page
  thp, mm: use migration entries to freeze page counts on split
  mm, thp: remove compound_lock
  thp: introduce deferred_split_huge_page()
  memcg: adjust to support new THP refcounting
  ksm: split huge pages on follow_page()
  thp: update documentation

 Documentation/vm/transhuge.txt       | 100 ++--
 arch/mips/mm/gup.c                   |   4 -
 arch/powerpc/mm/hugetlbpage.c        |  13 +-
 arch/powerpc/mm/subpage-prot.c       |   2 +-
 arch/s390/mm/gup.c                   |  13 +-
 arch/sparc/mm/gup.c                  |  14 +-
 arch/x86/include/asm/pgtable.h       |   9 -
 arch/x86/include/asm/pgtable_types.h |   2 -
 arch/x86/kernel/vm86_32.c            |   6 +-
 arch/x86/mm/gup.c                    |  17 +-
 arch/x86/mm/pgtable.c                |  14 -
 fs/proc/task_mmu.c                   |  51 ++-
 include/asm-generic/pgtable.h        |   5 -
 include/linux/huge_mm.h              |  40 +-
 include/linux/hugetlb_inline.h       |   9 +-
 include/linux/memcontrol.h           |  16 +-
 include/linux/migrate.h              |   3 +
 include/linux/mm.h                   | 134 ++----
 include/linux/mm_types.h             |  20 +-
 include/linux/mmzone.h               |   5 +
 include/linux/page-flags.h           |  15 +-
 include/linux/pagemap.h              |  14 +-
 include/linux/rmap.h                 |  17 +-
 include/linux/swap.h                 |   3 +-
 include/linux/vm_event_item.h        |   4 +-
 kernel/events/uprobes.c              |  11 +-
 kernel/futex.c                       |  61 +--
 mm/debug.c                           |   8 +-
 mm/filemap.c                         |  19 +-
 mm/gup.c                             |  96 ++--
 mm/huge_memory.c                     | 866 ++++++++++++++++++-----------------
 mm/hugetlb.c                         |   8 +-
 mm/internal.h                        |  57 +--
 mm/ksm.c                             |  60 +--
 mm/madvise.c                         |   2 +-
 mm/memcontrol.c                      |  76 +--
 mm/memory-failure.c                  |  12 +-
 mm/memory.c                          |  67 ++-
 mm/mempolicy.c                       |   2 +-
 mm/migrate.c                         |  97 ++--
 mm/mincore.c                         |   2 +-
 mm/mlock.c                           |  51 +--
 mm/mprotect.c                        |   2 +-
 mm/mremap.c                          |   2 +-
 mm/page_alloc.c                      |  13 +-
 mm/pagewalk.c                        |   2 +-
 mm/pgtable-generic.c                 |  14 -
 mm/rmap.c                            | 121 +++--
 mm/shmem.c                           |  21 +-
 mm/slub.c                            |   2 +
 mm/swap.c                            | 260 ++---------
 mm/swapfile.c                        |  16 +-
 mm/vmscan.c                          |   3 +
 mm/vmstat.c                          |   4 +-
 54 files changed, 1069 insertions(+), 1416 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
