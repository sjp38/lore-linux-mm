Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BE9F06B0204
	for <linux-mm@kvack.org>; Fri, 14 May 2010 03:39:08 -0400 (EDT)
Date: Fri, 14 May 2010 16:35:40 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/7] HWPOISON for hugepage (v5)
Message-ID: <20100514073540.GC10000@spritzerA.linux.bs1.fc.nec.co.jp>
References: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100513142749.GD27949@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100513142749.GD27949@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

(Add Cc: Andi and Fengguang)

On Thu, May 13, 2010 at 03:27:50PM +0100, Mel Gorman wrote:
> On Thu, May 13, 2010 at 04:55:19PM +0900, Naoya Horiguchi wrote:
> > This patchset enables error handling for hugepage by containing error
> > in the affected hugepage.
> > 
> > Until now, memory error (classified as SRAO in MCA language) on hugepage
> 
> What does SRAO stand for? It doesn't matter, I'm just curious.

SRAO stands for "Software Recoverable Action Optional."
SRAO errors can be contained by software and then become harmless.

> > was simply ignored, which means if someone accesses the error page later,
> > the second MCE (severer than the first one) occurs and the system panics.
> > 
> > It's useful for some aggressive hugepage users if only affected processes
> > are killed.  Then other unrelated processes aren't disturbed by the error
> > and can continue operation.
> > 
> 
> Surely, it's useful for any user of huge pages?

Yes.

> > Moreover, for other extensive hugetlb users which have own "pagecache"
> > on hugepage, the most valued feature would be being able to receive
> > the early kill signal BUS_MCEERR_AO, because the cache pages have
> > good opportunity to be dropped without side effects on BUS_MCEERR_AO.
> > 
> 
> Be careful here. The page cache that hugetlb uses is for MAP_SHARED
> mappings. If the pages are discarded, they are gone and the result is data
> loss. I think what you are suggesting is that a kill signal can instead be
> translated into a harmless loss of page cache. That works for normal files
> but not hugetlb.

"Pagecache" I meant here is not the page cache in Linux kernel,
but a cache managed by an application, e.g. the application reads/writes
the cache contents with direct I/O and manages clean/dirty status itself.
If HWPOISON-aware application catches signal BUS_MCEERR_AO, it can discard
hugepage used as a cache and can reread from the file.

Thanks,
Naoya Horiguchi

> > The design of hugepage error handling is based on that of non-hugepage
> > error handling, where we:
> >  1. mark the error page as hwpoison,
> >  2. unmap the hwpoisoned page from processes using it,
> >  3. invalidate error page, and
> >  4. block later accesses to the hwpoisoned pages.
> > 
> > Similarities and differences between huge and non-huge case are
> > summarized below:
> > 
> >  1. (Difference) when error occurs on a hugepage, PG_hwpoison bits on all pages
> >     in the hugepage are set, because we have no simple way to break up
> >     hugepage into individual pages for now. This means there is a some
> >     risk to be killed by touching non-guilty pages within the error hugepage.
> > 
> 
> You're right in that you cannot easily demote a hugepage. It is possible but
> I cannot see the value of the required effort. If there is an error within
> the hugepage and touching another part of it results in the process being
> unnecessarily killed, then so be it.
> 
> >  2. (Similarity) hugetlb entry for the error hugepage is replaced by hwpoison
> >     swap entry, with which we can detect hwpoisoned memory in VM code.
> >     This is accomplished by adding rmapping code for hugepage, which enables
> >     to use try_to_unmap() for hugepage.
> > 
> 
> This will be interesting. hugetlbfs pages could look like a file or anon
> depending on whether it has been mapped shared or private. It's odd.
> 
> >  3. (Difference) since hugepage is not linked to LRU list and is unswappable,
> >     there are not many things to do for page invalidation (only dequeuing
> >     free/reserved hugepage from freelist. See patch 5/7.)
> >     If we want to contain the error into one page, there may be more to do.
> > 
> >  4. (Similarity) we block later accesses by forcing page requests for
> >     hwpoisoned hugepage to fail as done in non-hugepage case in do_wp_page().
> > 
> > ToDo:
> > - Narrow down the containment region into one raw page.
> > - Soft-offlining for hugepage is not supported due to the lack of migration
> >   for hugepage.
> > - Counting file-mapped/anonymous hugepage in NR_FILE_MAPPED/NR_ANON_PAGES.
> > 
> >  [PATCH 1/7] hugetlb, rmap: add reverse mapping for hugepage
> >  [PATCH 2/7] HWPOISON, hugetlb: enable error handling path for hugepage
> >  [PATCH 3/7] HWPOISON, hugetlb: set/clear PG_hwpoison bits on hugepage
> >  [PATCH 4/7] HWPOISON, hugetlb: maintain mce_bad_pages in handling hugepage error
> >  [PATCH 5/7] HWPOISON, hugetlb: isolate corrupted hugepage
> >  [PATCH 6/7] HWPOISON, hugetlb: detect hwpoison in hugetlb code
> >  [PATCH 7/7] HWPOISON, hugetlb: support hwpoison injection for hugepage
> > 
> > Dependency:
> > - patch 2 depends on patch 1.
> > - patch 3 to patch 6 depend on patch 2.
> > 
> >  include/linux/hugetlb.h |    3 +
> >  mm/hugetlb.c            |   98 ++++++++++++++++++++++++++++++++++++++-
> >  mm/hwpoison-inject.c    |   15 ++++--
> >  mm/memory-failure.c     |  120 +++++++++++++++++++++++++++++++++++------------
> >  mm/rmap.c               |   16 ++++++
> >  5 files changed, 215 insertions(+), 37 deletions(-)
> > 
> > ChangeLog from v4:
> > - rebased to 2.6.34-rc7
> > - add isolation code for free/reserved hugepage in me_huge_page()
> > - set/clear PG_hwpoison bits of all pages in hugepage.
> > - mce_bad_pages counts all pages in hugepage.
> > - rename __hugepage_set_anon_rmap() to hugepage_add_anon_rmap()
> > - add huge_pte_offset() dummy function in header file on !CONFIG_HUGETLBFS
> > 
> > ChangeLog from v3:
> > - rebased to 2.6.34-rc5
> > - support for privately mapped hugepage
> > 
> > ChangeLog from v2:
> > - rebase to 2.6.34-rc3
> > - consider mapcount of hugepage
> > - rename pointer "head" into "hpage"
> > 
> > ChangeLog from v1:
> > - rebase to 2.6.34-rc1
> > - add comment from Wu Fengguang
> > 
> > Thanks,
> > Naoya Horiguchi
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
