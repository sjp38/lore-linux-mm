Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 95CC66B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:04:22 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so28273321pac.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 14:04:22 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id vd2si14197531pab.156.2015.04.23.14.04.21
        for <linux-mm@kvack.org>;
        Thu, 23 Apr 2015 14:04:21 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 00/28] THP refcounting redesign
Date: Fri, 24 Apr 2015 00:03:35 +0300
Message-Id: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hello everybody,

Here's reworked version of my patchset. All known issues were addressed.

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

The patchset drastically lower complexity of get_page()/put_page()
codepaths. I encourage reviewers look on this code before-and-after to
justify time budget on reviewing this patchset.

= Changelog =

v5:
  - Tested-by: Sasha Levin!a?c
  - re-split patchset in hope to improve readability;
  - rebased on top of page flags and ->mapping sanitizing patchset;
  - uncharge compound_mapcount rather than mapcount for hugetlb pages
    during removing from rmap;
  - differentiate page_mapped() from page_mapcount() for compound pages;
  - rework deferred_split_huge_page() to use shrinker interface;
  - fix race in page_remove_rmap();
  - get rid of __get_page_tail();
  - few random bug fixes;
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
order to take memory consumption under control we put partially unmapped
huge page on list. The pages will be split by shrinker if memory pressure
comes. This way we also avoid unnecessary split_huge_page() on exit(2) if
a THP belong to more than one VMA.

= Patches overview =

Patch 1:
        We need to look on all subpages of compound page to calculate
        correct PSS, because they can have different mapcount.

Patch 2:
        With PTE-mapeed THP, rmap cannot rely on PageTransHuge() check to
        decide if map small page or THP. We need to get the info from
        caller.

Patch 3:
        Make memcg aware about new refcounting. Validation needed.

Patch 4:
        Adjust conditions when we can re-use the page on write-protection
        fault.

Patch 5:
        FOLL_SPLIT should be handled on PTE level too.

Patch 6:
	Make generic fast GUP implementation aware about PTE-mapped huge
	pages.

Patch 7:
        Split all pages in mlocked VMA. That should be good enough for
	now.

Patch 8:
        Make khugepaged aware about PTE-mapped huge pages.

Patch 9:
	Rename split_huge_page_pmd() to split_huge_pmd() to reflect that
	page is not going to be split, only PMD.

Patch 10:
        New THP_SPLIT_* vmstats.

Patch 11:
	Up to this point we tried to keep patchset bisectable, but next
	patches are going to change how core of THP refcounting work.
	That's easier to review change if we would disable THP temporally
	and bring it back once everything is ready.

Patch 12:
	Remove all split_huge_page()-related code. It also remove need in
	tail page refcounting.

Patch 13:
	Drop tail page refcounting. Diffstat is nice! :)

Patch 14:
        Remove ugly special case if futex happened to be in tail THP page.
        With new refcounting it much easier to protect against split.

Patch 15:
        Simplify KSM code which handle THP.

Patch 16:
	No need in compound_lock anymore.

Patches 17-18:
        Drop infrastructure for handling PMD splitting. We don't use it
        anymore in split_huge_page(). For now we only remove it from
        generic code and x86. I'll cleanup other architectures later.

Patch 19:
        Store mapcount for compound pages separately: in the first tail
        page ->mapping.

Patch 20:
	Let's define page_mapped() to be true for compound pages if any
	sub-pages of the compound page is mapped (with PMD or PTE).

Patch 21:
	Make numabalancing aware about PTE-mapped THP.

Patch 22:
	Implement new split_huge_pmd().

Patch 23-25:
	Implement new split_huge_page().

Patch 26:
        Handle partial unmap of THP. We put partially unmapped huge page
        list. Pages from list will split via shrinker if memory pressure
	comes. This way we also avoid unnecessary split_huge_page() on
        exit(2) if a THP belong to more than one VMA.

Patch 27:
	Everything is in place. Re-enable THP.

Patch 28:
        Documentation update.

The patchset also available on git:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git thp/refcounting/v5

Please review.

Kirill A. Shutemov (28):
  mm, proc: adjust PSS calculation
  rmap: add argument to charge compound page
  memcg: adjust to support new THP refcounting
  mm, thp: adjust conditions when we can reuse the page on WP fault
  mm: adjust FOLL_SPLIT for new refcounting
  mm: handle PTE-mapped tail pages in gerneric fast gup implementaiton
  thp, mlock: do not allow huge pages in mlocked area
  khugepaged: ignore pmd tables with THP mapped with ptes
  thp: rename split_huge_page_pmd() to split_huge_pmd()
  mm, vmstats: new THP splitting event
  mm: temporally mark THP broken
  thp: drop all split_huge_page()-related code
  mm: drop tail page refcounting
  futex, thp: remove special case for THP in get_futex_key
  ksm: prepare to new THP semantics
  mm, thp: remove compound_lock
  mm, thp: remove infrastructure for handling splitting PMDs
  x86, thp: remove infrastructure for handling splitting PMDs
  mm: store mapcount for compound page separately
  mm: differentiate page_mapped() from page_mapcount() for compound
    pages
  mm, numa: skip PTE-mapped THP on numa fault
  thp: implement split_huge_pmd()
  thp: add option to setup migration entiries during PMD split
  thp, mm: split_huge_page(): caller need to lock page
  thp: reintroduce split_huge_page()
  thp: introduce deferred_split_huge_page()
  mm: re-enable THP
  thp: update documentation

 Documentation/vm/transhuge.txt       |  100 ++--
 arch/arc/mm/cache_arc700.c           |    4 +-
 arch/arm/mm/flush.c                  |    2 +-
 arch/mips/mm/c-r4k.c                 |    3 +-
 arch/mips/mm/cache.c                 |    2 +-
 arch/mips/mm/gup.c                   |    4 -
 arch/mips/mm/init.c                  |    6 +-
 arch/powerpc/mm/hugetlbpage.c        |   13 +-
 arch/powerpc/mm/subpage-prot.c       |    2 +-
 arch/s390/mm/gup.c                   |   13 +-
 arch/sh/mm/cache-sh4.c               |    2 +-
 arch/sh/mm/cache.c                   |    8 +-
 arch/sparc/mm/gup.c                  |   14 +-
 arch/x86/include/asm/pgtable.h       |    9 -
 arch/x86/include/asm/pgtable_types.h |    2 -
 arch/x86/kernel/vm86_32.c            |    6 +-
 arch/x86/mm/gup.c                    |   17 +-
 arch/x86/mm/pgtable.c                |   14 -
 arch/xtensa/mm/tlb.c                 |    2 +-
 fs/proc/page.c                       |    4 +-
 fs/proc/task_mmu.c                   |   51 +-
 include/asm-generic/pgtable.h        |    5 -
 include/linux/huge_mm.h              |   41 +-
 include/linux/memcontrol.h           |   16 +-
 include/linux/mm.h                   |  106 ++--
 include/linux/mm_types.h             |   18 +-
 include/linux/page-flags.h           |   12 +-
 include/linux/pagemap.h              |    9 +-
 include/linux/rmap.h                 |   16 +-
 include/linux/swap.h                 |    3 +-
 include/linux/vm_event_item.h        |    4 +-
 kernel/events/uprobes.c              |   11 +-
 kernel/futex.c                       |   61 +-
 mm/debug.c                           |    8 +-
 mm/filemap.c                         |   10 +-
 mm/filemap_xip.c                     |    2 +-
 mm/gup.c                             |  106 ++--
 mm/huge_memory.c                     | 1076 +++++++++++++++++++---------------
 mm/hugetlb.c                         |   10 +-
 mm/internal.h                        |   70 +--
 mm/ksm.c                             |   61 +-
 mm/madvise.c                         |    2 +-
 mm/memcontrol.c                      |   76 +--
 mm/memory-failure.c                  |   12 +-
 mm/memory.c                          |   71 +--
 mm/mempolicy.c                       |    2 +-
 mm/migrate.c                         |   19 +-
 mm/mincore.c                         |    2 +-
 mm/mlock.c                           |   51 +-
 mm/mprotect.c                        |    2 +-
 mm/mremap.c                          |    2 +-
 mm/page_alloc.c                      |   16 +-
 mm/pagewalk.c                        |    2 +-
 mm/pgtable-generic.c                 |   14 -
 mm/rmap.c                            |  144 +++--
 mm/shmem.c                           |   21 +-
 mm/swap.c                            |  274 +--------
 mm/swapfile.c                        |   16 +-
 mm/vmstat.c                          |    4 +-
 59 files changed, 1144 insertions(+), 1509 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
