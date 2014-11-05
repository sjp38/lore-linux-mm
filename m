Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD336B0099
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:22 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id v10so866480pde.36
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:22 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id r3si3283728pdp.54.2014.11.05.06.50.07
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:08 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 RFC 00/19] THP refcounting redesign
Date: Wed,  5 Nov 2014 16:49:35 +0200
Message-Id: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hello everybody,

Here's my second version of the patchset on THP refcounting redesign. It's
still RFC and I have quite a few items on todo list. The patches are on
top of next-20140811 + Naoya's patchset on pagewalker. I'll rebase it once
updated pagewalker hits -mm. It's relatively stable: trinity is not able
to crash it in my setup.

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

= Patches overview =

Patches 1-2:
	Remove barely-used FOLL_SPLIT and rearrange split-related code to
	make future changes simpler.

Patches 3-4:
	Make PageAnon() and PG_locked related helpers to loon on head
	page if tail page is passed. It's required sinse pte_page() can
	now point to tail page. It's likely that we need to change other
	pageflags-related helpers too.

Patch 5:
	With PTE-mapeed THP, rmap cannot rely on PageTransHuge() check to
	decide if map small page or THP. We need to get the info from
	caller.

Patch 6:
	Store mapcount for compound pages separately: in the first tail
	page ->mapping.

Patch 7:
	Adjust conditions when we can re-use the page on write-protection
	fault.

Patch 8:
	Prepare migration code to deal with tail pages.

Patch 9:
	split_huge_page_pmd() to split_huge_pmd() to reflect that page is
	not going to be split, only PMD.

Patch 10:
	Temporary make split_huge_page() to return -EBUSY on all split
	requests. This allows to drop tail-page refcounting and change
	implementation of split_huge_pmd() to split PMD to table of PTEs
	without splitting compound page.

Patch 11:
	New THP_SPLIT_* vmstats.

Patch 12:
	Implement new split_huge_page() which fails if the page is pinned.
	For now, we rely on compound_lock() to make page counts stable.

Patches 13-14:
	Drop infrastructure for handling PMD splitting. We don't use it
	anymore in split_huge_page(). For now we only remove it from
	generic code and x86.

Patch 15:
	Remove ugly special case if futex happened to be in tail THP page.
	With new refcounting it much easier to protect against split.

Patch 16:
	Documentation update.

Patch 17:
	Hack to split all THP on mlock(). To be replaced with real
	solution for new refcounting.

Patches 18-19:
	Replaces compound_lock with migration entries as mechanism to
	freeze page counts on split_huge_page(). We don't need
	compound_lock anymore. It makes get_page()/put_page() on tail
	pages faster.

= TODO =

 - As we discussed on the first RFC we need to split THP on munmap() if
   the page is not mapped with PMD anymore. If split is failed (page is
   pinned) we need to queue it for splitting (to vmscan ?).

 - Proper mlock implementation is required.

 - Review all PageTransHuge() users -- consider getting rid of the helper.

 - Memory cgroup adaptation to new refcount -- I haven't checked yet what
   need to be done there, but I would expect some breakage.

 - Check page-flags: whether they should be on the compound page or
   per-4k.

 - Drop pmd splitting infrastructure from rest archs. Should be easy.

 - Check if khugepaged need to be adjusted.

Also munmap() on part of huge page will not split and free unmapped part
immediately. We need to be careful here to keep memory footprint under
control.

As side effect we don't need to mark PMD splitting since we have
split_huge_pmd(). get_page()/put_page() on tail of THP is cheaper (and
cleaner) now.

I will continue with stabilizing this. The patchset also available on
git[1].

Any comments?

Kirill A. Shutemov (19):
  mm, thp: drop FOLL_SPLIT
  thp: cluster split_huge_page* code together
  mm: change PageAnon() to work on tail pages
  mm: avoid PG_locked on tail pages
  rmap: add argument to charge compound page
  mm: store mapcount for compound page separate
  mm, thp: adjust conditions when we can reuse the page on WP fault
  mm: prepare migration code for new THP refcounting
  thp: rename split_huge_page_pmd() to split_huge_pmd()
  thp: PMD splitting without splitting compound page
  mm, vmstats: new THP splitting event
  thp: implement new split_huge_page()
  mm, thp: remove infrastructure for handling splitting PMDs
  x86, thp: remove remove infrastructure for handling splitting PMDs
  futex, thp: remove special case for THP in get_futex_key
  thp: update documentation
  mlock, thp: HACK: split all pages in VM_LOCKED vma
  tho, mm: use migration entries to freeze page counts on split
  mm, thp: remove compound_lock

 Documentation/vm/transhuge.txt       |  95 ++---
 arch/mips/mm/gup.c                   |   4 -
 arch/powerpc/mm/hugetlbpage.c        |  12 -
 arch/powerpc/mm/subpage-prot.c       |   2 +-
 arch/s390/mm/gup.c                   |  13 +-
 arch/s390/mm/pgtable.c               |  17 +-
 arch/sparc/mm/gup.c                  |  14 +-
 arch/x86/include/asm/pgtable.h       |   9 -
 arch/x86/include/asm/pgtable_types.h |   2 -
 arch/x86/kernel/vm86_32.c            |   6 +-
 arch/x86/mm/gup.c                    |  17 +-
 arch/x86/mm/pgtable.c                |  14 -
 fs/proc/task_mmu.c                   |   8 +-
 include/asm-generic/pgtable.h        |   5 -
 include/linux/huge_mm.h              |  55 +--
 include/linux/hugetlb_inline.h       |   9 +-
 include/linux/migrate.h              |   3 +
 include/linux/mm.h                   | 112 +-----
 include/linux/page-flags.h           |  15 +-
 include/linux/pagemap.h              |   5 +
 include/linux/rmap.h                 |  18 +-
 include/linux/swap.h                 |   8 +-
 include/linux/vm_event_item.h        |   4 +-
 kernel/events/uprobes.c              |   4 +-
 kernel/futex.c                       |  61 +--
 mm/filemap.c                         |   1 +
 mm/filemap_xip.c                     |   2 +-
 mm/gup.c                             |  18 +-
 mm/huge_memory.c                     | 730 ++++++++++++++++-------------------
 mm/hugetlb.c                         |   8 +-
 mm/internal.h                        |  31 +-
 mm/ksm.c                             |   4 +-
 mm/memcontrol.c                      |  14 +-
 mm/memory.c                          |  36 +-
 mm/mempolicy.c                       |   2 +-
 mm/migrate.c                         |  50 ++-
 mm/mincore.c                         |   2 +-
 mm/mlock.c                           | 130 +++++--
 mm/mprotect.c                        |   2 +-
 mm/mremap.c                          |   2 +-
 mm/page_alloc.c                      |  16 +-
 mm/pagewalk.c                        |   2 +-
 mm/pgtable-generic.c                 |  14 -
 mm/rmap.c                            |  98 +++--
 mm/slub.c                            |   2 +
 mm/swap.c                            | 260 +++----------
 mm/swapfile.c                        |   7 +-
 mm/vmstat.c                          |   4 +-
 48 files changed, 789 insertions(+), 1158 deletions(-)

-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
