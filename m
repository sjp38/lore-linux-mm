Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 121C26B0093
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 09:47:50 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so7756160pdb.2
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 06:47:49 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id yw2si34699806pbc.95.2015.06.23.06.47.35
        for <linux-mm@kvack.org>;
        Tue, 23 Jun 2015 06:47:35 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 00/36] THP refcounting redesign
Date: Tue, 23 Jun 2015 16:46:10 +0300
Message-Id: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hello everybody,

Here's bugfix release of my THP refcounting rework patchset.
Many thanks to Vlastimil for review.

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
codepaths. I encourage people look on this code before-and-after to
justify time budget on reviewing this patchset.

= Changelog =

v7:
  - avoid situation during split_huge_pmd() where we can temporarily drop
    page_mapcount() to zero. It can lead to races e.g. with unmap code;
  - update documentation;
  - fix NR_ANON_PAGES accounting in page_remove_rmap();
  - fix page_mapped();
  - optimize page_mapped() and page_mapcount();
  - fix PSS calculation for non-shared pages;

v6:
  - rebase to since-4.0;
  - optimize mapcount handling: significantely reduce overhead for most
    common cases.
  - split pages on migrate_pages();
  - remove infrastructure for handling splitting PMDs on all architectures;
  - fix page_mapcount() for hugetlb pages;

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

= Refcounts and transparent huge pages =

  - get_page() and put_page() work *only* on head page's ->_count.
    We don't touch tail pages at all for these oprations. We stopped
    touching ->_mapcount in tail pages to store it's pins.

  - ->_count in tail pages is always zero: get_page_unless_zero() never
    succeed on tail pages. Nothing changed in this respect.

  - map/unmap of the pages with PTE entry increment/decrement ->_mapcount
    on relevent sub-page of the compound page.

  - map/unmap of the whole compound page accounted in compound_mapcount
    (stored in first tail page).

  - PageDoubleMap() indicates that ->_mapcount in all subpages is offset
    up by one. This additional reference is required to get race-free
    detection of unmap of subpages when we have them mapped with both PMDs
    and PTEs.

    This is optimization required to lower overhead of per-subpage
    mapcount tracking. The alternative is alter ->_mapcount in all
    subpages on each map/unmap of the whole compound page.

    We set PG_double_map when a PMD of the page got split for the first
    time, but still have PMD mapping. The addtional references go away
    with last compound_mapcount.

= Benchmarks =

Kernel build benchmark:

			baseline		v6

Amean    user-2       447.76 (  0.00%)      451.24 ( -0.78%)
Amean    user-4       314.94 (  0.00%)      310.10 (  1.54%)
Amean    user-8       388.91 (  0.00%)      388.95 ( -0.01%)
Amean    user-16      518.68 (  0.00%)      518.60 (  0.02%)
Amean    user-24      533.58 (  0.00%)      535.35 ( -0.33%)
Amean    syst-2        77.52 (  0.00%)       70.16 (  9.49%)
Amean    syst-4        51.21 (  0.00%)       44.55 ( 13.00%)
Amean    syst-8        42.12 (  0.00%)       42.59 ( -1.12%)
Amean    syst-16       50.29 (  0.00%)       50.14 (  0.30%)
Amean    syst-24       49.36 (  0.00%)       48.54 (  1.65%)
Amean    elsp-2       242.64 (  0.00%)      244.46 ( -0.75%)
Amean    elsp-4        93.78 (  0.00%)       92.89 (  0.95%)
Amean    elsp-8        61.51 (  0.00%)       61.92 ( -0.66%)
Amean    elsp-16       53.95 (  0.00%)       53.80 (  0.29%)
Amean    elsp-24       52.75 (  0.00%)       53.14 ( -0.74%)
Stddev   user-2        15.49 (  0.00%)       13.75 ( 11.24%)
Stddev   user-4         7.85 (  0.00%)        4.42 ( 43.68%)
Stddev   user-8         1.29 (  0.00%)        2.77 (-114.28%)
Stddev   user-16        2.56 (  0.00%)        1.54 ( 39.89%)
Stddev   user-24        1.75 (  0.00%)        1.06 ( 39.75%)
Stddev   syst-2         3.02 (  0.00%)        2.00 ( 33.86%)
Stddev   syst-4         1.23 (  0.00%)        0.91 ( 26.65%)
Stddev   syst-8         0.41 (  0.00%)        0.30 ( 28.32%)
Stddev   syst-16        0.51 (  0.00%)        0.71 (-38.07%)
Stddev   syst-24        0.92 (  0.00%)        0.70 ( 23.86%)
Stddev   elsp-2         8.70 (  0.00%)        7.99 (  8.13%)
Stddev   elsp-4         1.74 (  0.00%)        0.59 ( 66.08%)
Stddev   elsp-8         0.40 (  0.00%)        0.30 ( 25.11%)
Stddev   elsp-16        0.45 (  0.00%)        0.37 ( 17.73%)
Stddev   elsp-24        0.57 (  0.00%)        0.38 ( 33.64%)

Changes are mostly non-significant. The only noticble part is reduction of
system time for -j2 and -j4: 9.49% and 13.00%.

specjvm
                                    base                    v6
Ops compiler                   569.52 (  0.00%)       618.74 (  8.64%)
Ops compress                   456.32 (  0.00%)       469.20 (  2.82%)
Ops crypto                     424.34 (  0.00%)       413.64 ( -2.52%)
Ops derby                      535.15 (  0.00%)       536.96 (  0.34%)
Ops mpegaudio                  291.03 (  0.00%)       286.35 ( -1.61%)
Ops scimark.large               75.91 (  0.00%)        77.21 (  1.71%)
Ops scimark.small              529.19 (  0.00%)       527.07 ( -0.40%)
Ops serial                     316.13 (  0.00%)       316.40 (  0.09%)
Ops sunflow                    154.90 (  0.00%)       154.85 ( -0.03%)
Ops xml                        612.94 (  0.00%)       575.20 ( -6.16%)
Ops compiler.compiler          770.11 (  0.00%)       878.22 ( 14.04%)
Ops compiler.sunflow           421.17 (  0.00%)       435.92 (  3.50%)
Ops compress                   456.32 (  0.00%)       469.20 (  2.82%)
Ops crypto.aes                 153.17 (  0.00%)       151.30 ( -1.22%)
Ops crypto.rsa                 607.43 (  0.00%)       564.65 ( -7.04%)
Ops crypto.signverify          821.23 (  0.00%)       828.40 (  0.87%)
Ops derby                      535.15 (  0.00%)       536.96 (  0.34%)
Ops mpegaudio                  291.03 (  0.00%)       286.35 ( -1.61%)
Ops scimark.fft.large           69.59 (  0.00%)        69.81 (  0.32%)
Ops scimark.lu.large            20.31 (  0.00%)        20.32 (  0.05%)
Ops scimark.sor.large          114.57 (  0.00%)       113.99 ( -0.51%)
Ops scimark.sparse.large        55.56 (  0.00%)        61.71 ( 11.07%)
Ops scimark.monte_carlo        280.13 (  0.00%)       275.09 ( -1.80%)
Ops scimark.fft.small          815.19 (  0.00%)       819.55 (  0.53%)
Ops scimark.lu.small          1072.62 (  0.00%)      1081.47 (  0.83%)
Ops scimark.sor.small          674.47 (  0.00%)       674.24 ( -0.03%)
Ops scimark.sparse.small       251.20 (  0.00%)       247.43 ( -1.50%)
Ops serial                     316.13 (  0.00%)       316.40 (  0.09%)
Ops sunflow                    154.90 (  0.00%)       154.85 ( -0.03%)
Ops xml.transform              538.16 (  0.00%)       519.64 ( -3.44%)
Ops xml.validation             698.10 (  0.00%)       636.70 ( -8.80%)

Results are mixed.

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

Patches 17-25:
        Drop infrastructure for handling PMD splitting. We don't use it
        anymore in split_huge_page().

Patch 26:
        Store mapcount for compound pages separately: in the first tail
        page ->mapping.

Patch 27:
	Let's define page_mapped() to be true for compound pages if any
	sub-pages of the compound page is mapped (with PMD or PTE).

Patch 28:
	Make numabalancing aware about PTE-mapped THP.

Patch 29:
	Implement new split_huge_pmd().

Patch 30-32:
	Implement new split_huge_page().

Patch 33:
	Split pages instaed of PMDs on migrate_pages.

Patch 34:
        Handle partial unmap of THP. We put partially unmapped huge page
        list. Pages from list will split via shrinker if memory pressure
	comes. This way we also avoid unnecessary split_huge_page() on
        exit(2) if a THP belong to more than one VMA.

Patch 35:
	Everything is in place. Re-enable THP.

Patch 36:
        Documentation update.

The patchset also available on git:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git thp/refcounting/v5

Please review.
Kirill A. Shutemov (36):
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
  arm64, thp: remove infrastructure for handling splitting PMDs
  arm, thp: remove infrastructure for handling splitting PMDs
  mips, thp: remove infrastructure for handling splitting PMDs
  powerpc, thp: remove infrastructure for handling splitting PMDs
  s390, thp: remove infrastructure for handling splitting PMDs
  sparc, thp: remove infrastructure for handling splitting PMDs
  tile, thp: remove infrastructure for handling splitting PMDs
  x86, thp: remove infrastructure for handling splitting PMDs
  mm, thp: remove infrastructure for handling splitting PMDs
  mm: rework mapcount accounting to enable 4k mapping of THPs
  mm: differentiate page_mapped() from page_mapcount() for compound
    pages
  mm, numa: skip PTE-mapped THP on numa fault
  thp: implement split_huge_pmd()
  thp: add option to setup migration entiries during PMD split
  thp, mm: split_huge_page(): caller need to lock page
  thp: reintroduce split_huge_page()
  migrate_pages: try to split pages on qeueuing
  thp: introduce deferred_split_huge_page()
  mm: re-enable THP
  thp: update documentation

 Documentation/vm/transhuge.txt           |  151 ++--
 arch/arc/mm/cache_arc700.c               |    4 +-
 arch/arm/include/asm/pgtable-3level.h    |   10 -
 arch/arm/lib/uaccess_with_memcpy.c       |    5 +-
 arch/arm/mm/flush.c                      |   17 +-
 arch/arm64/include/asm/pgtable.h         |    9 -
 arch/arm64/mm/flush.c                    |   16 -
 arch/mips/include/asm/pgtable-bits.h     |    6 +-
 arch/mips/include/asm/pgtable.h          |   18 -
 arch/mips/mm/c-r4k.c                     |    3 +-
 arch/mips/mm/cache.c                     |    2 +-
 arch/mips/mm/gup.c                       |   17 +-
 arch/mips/mm/init.c                      |    6 +-
 arch/mips/mm/pgtable-64.c                |   14 -
 arch/mips/mm/tlbex.c                     |    1 -
 arch/powerpc/include/asm/kvm_book3s_64.h |    6 -
 arch/powerpc/include/asm/pgtable-ppc64.h |   25 +-
 arch/powerpc/mm/hugepage-hash64.c        |    3 -
 arch/powerpc/mm/hugetlbpage.c            |   20 +-
 arch/powerpc/mm/pgtable_64.c             |   49 --
 arch/powerpc/mm/subpage-prot.c           |    2 +-
 arch/s390/include/asm/pgtable.h          |   15 +-
 arch/s390/mm/gup.c                       |   24 +-
 arch/s390/mm/pgtable.c                   |   16 -
 arch/sh/mm/cache-sh4.c                   |    2 +-
 arch/sh/mm/cache.c                       |    8 +-
 arch/sparc/include/asm/pgtable_64.h      |   16 -
 arch/sparc/mm/fault_64.c                 |    3 -
 arch/sparc/mm/gup.c                      |   16 +-
 arch/tile/include/asm/pgtable.h          |   10 -
 arch/x86/include/asm/pgtable.h           |    9 -
 arch/x86/include/asm/pgtable_types.h     |    2 -
 arch/x86/kernel/vm86_32.c                |    6 +-
 arch/x86/mm/gup.c                        |   17 +-
 arch/x86/mm/pgtable.c                    |   14 -
 arch/xtensa/mm/tlb.c                     |    2 +-
 fs/proc/page.c                           |    4 +-
 fs/proc/task_mmu.c                       |   55 +-
 include/asm-generic/pgtable.h            |    9 -
 include/linux/huge_mm.h                  |   55 +-
 include/linux/memcontrol.h               |   16 +-
 include/linux/mm.h                       |  113 ++-
 include/linux/mm_types.h                 |   18 +-
 include/linux/page-flags.h               |   49 +-
 include/linux/pagemap.h                  |   13 +-
 include/linux/rmap.h                     |   16 +-
 include/linux/swap.h                     |    3 +-
 include/linux/vm_event_item.h            |    4 +-
 kernel/events/uprobes.c                  |   11 +-
 kernel/futex.c                           |   61 +-
 mm/debug.c                               |    8 +-
 mm/filemap.c                             |   10 +-
 mm/gup.c                                 |  111 ++-
 mm/huge_memory.c                         | 1102 +++++++++++++++++-------------
 mm/hugetlb.c                             |   10 +-
 mm/internal.h                            |   70 +-
 mm/ksm.c                                 |   61 +-
 mm/madvise.c                             |    2 +-
 mm/memcontrol.c                          |   84 +--
 mm/memory-failure.c                      |   10 +-
 mm/memory.c                              |   73 +-
 mm/mempolicy.c                           |   37 +-
 mm/migrate.c                             |   19 +-
 mm/mincore.c                             |    2 +-
 mm/mlock.c                               |   51 +-
 mm/mprotect.c                            |    2 +-
 mm/mremap.c                              |   15 +-
 mm/page_alloc.c                          |   16 +-
 mm/pagewalk.c                            |    2 +-
 mm/pgtable-generic.c                     |   14 -
 mm/rmap.c                                |  162 +++--
 mm/shmem.c                               |   21 +-
 mm/swap.c                                |  273 +-------
 mm/swapfile.c                            |   16 +-
 mm/userfaultfd.c                         |    8 +-
 mm/vmstat.c                              |    4 +-
 76 files changed, 1347 insertions(+), 1807 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
