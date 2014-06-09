Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id BC0116B0092
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 12:04:34 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so8368pab.15
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 09:04:34 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ew3si31177133pbb.184.2014.06.09.09.04.33
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 09:04:33 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 00/10] THP refcounting redesign
Date: Mon,  9 Jun 2014 19:04:11 +0300
Message-Id: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hello everybody,

We've discussed few times that is would be nice to allow huge pages to be
mapped with 4k pages too. Here's my first attempt to actually implement
this. It's early prototype and not stabilized yet, but I want to share it
to discuss any potential show stoppers early.

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

In new scheme we use tail_page->_mapcount is used to account how many time
the tail page is mapped. head_page->_mapcount is used for both PMD mapping
of whole huge page and PTE mapping of the firt 4k page of the compound
page. It seems work fine, except the fact that we don't have a cheap way
to check whether the page mapped with PMDs or not.

Introducing split_huge_pmd() effectively allows THP to be mapped with 4k.
It can break some kernel expectations. I.e. VMA now can start and end in
middle of compound page. IIUC, it will break compactation and probably
something else (any hints?).

Also munmap() on part of huge page will not split and free unmapped part
immediately. We need to be careful here to keep memory footprint under
control.

As side effect we don't need to mark PMD splitting since we have
split_huge_pmd(). get_page()/put_page() on tail of THP is cheaper (and
cleaner) now.

I will continue with stabilizing this. The patchset also available on
git[1].

Any commemnt?

[1] git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git thp/refcounting/v1

Kirill A. Shutemov (10):
  mm, thp: drop FOLL_SPLIT
  mm: change PageAnon() to work on tail pages
  thp: rename split_huge_page_pmd() to split_huge_pmd()
  thp: PMD splitting without splitting compound page
  mm, vmstats: new THP splitting event
  thp: implement new split_huge_page()
  mm, thp: remove infrastructure for handling splitting PMDs
  x86, thp: remove remove infrastructure for handling splitting PMDs
  futex, thp: remove special case for THP in get_futex_key
  thp: update documentation

 Documentation/vm/transhuge.txt       |  95 ++++----
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
 arch/x86/mm/pgtable.c                |  14 --
 fs/proc/task_mmu.c                   |   9 +-
 include/asm-generic/pgtable.h        |   5 -
 include/linux/huge_mm.h              |  48 +---
 include/linux/hugetlb_inline.h       |   9 +-
 include/linux/mm.h                   |  66 +-----
 include/linux/vm_event_item.h        |   4 +-
 kernel/futex.c                       |  62 ++----
 mm/gup.c                             |  18 +-
 mm/huge_memory.c                     | 412 ++++++++++-------------------------
 mm/internal.h                        |  31 +--
 mm/memcontrol.c                      |  16 +-
 mm/memory.c                          |  20 +-
 mm/migrate.c                         |   7 +-
 mm/mprotect.c                        |   2 +-
 mm/mremap.c                          |   2 +-
 mm/pagewalk.c                        |   2 +-
 mm/pgtable-generic.c                 |  14 --
 mm/rmap.c                            |   4 +-
 mm/swap.c                            | 285 +++++++-----------------
 mm/vmstat.c                          |   4 +-
 32 files changed, 328 insertions(+), 897 deletions(-)

-- 
2.0.0.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
