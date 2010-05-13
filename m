Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A7E1F6B01FF
	for <linux-mm@kvack.org>; Thu, 13 May 2010 03:57:31 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/7] HWPOISON for hugepage (v5)
Date: Thu, 13 May 2010 16:55:19 +0900
Message-Id: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: n-horiguchi@ah.jp.nec.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset enables error handling for hugepage by containing error
in the affected hugepage.

Until now, memory error (classified as SRAO in MCA language) on hugepage
was simply ignored, which means if someone accesses the error page later,
the second MCE (severer than the first one) occurs and the system panics.

It's useful for some aggressive hugepage users if only affected processes
are killed.  Then other unrelated processes aren't disturbed by the error
and can continue operation.

Moreover, for other extensive hugetlb users which have own "pagecache"
on hugepage, the most valued feature would be being able to receive
the early kill signal BUS_MCEERR_AO, because the cache pages have
good opportunity to be dropped without side effects on BUS_MCEERR_AO.


The design of hugepage error handling is based on that of non-hugepage
error handling, where we:
 1. mark the error page as hwpoison,
 2. unmap the hwpoisoned page from processes using it,
 3. invalidate error page, and
 4. block later accesses to the hwpoisoned pages.

Similarities and differences between huge and non-huge case are
summarized below:

 1. (Difference) when error occurs on a hugepage, PG_hwpoison bits on all pages
    in the hugepage are set, because we have no simple way to break up
    hugepage into individual pages for now. This means there is a some
    risk to be killed by touching non-guilty pages within the error hugepage.

 2. (Similarity) hugetlb entry for the error hugepage is replaced by hwpoison
    swap entry, with which we can detect hwpoisoned memory in VM code.
    This is accomplished by adding rmapping code for hugepage, which enables
    to use try_to_unmap() for hugepage.

 3. (Difference) since hugepage is not linked to LRU list and is unswappable,
    there are not many things to do for page invalidation (only dequeuing
    free/reserved hugepage from freelist. See patch 5/7.)
    If we want to contain the error into one page, there may be more to do.

 4. (Similarity) we block later accesses by forcing page requests for
    hwpoisoned hugepage to fail as done in non-hugepage case in do_wp_page().

ToDo:
- Narrow down the containment region into one raw page.
- Soft-offlining for hugepage is not supported due to the lack of migration
  for hugepage.
- Counting file-mapped/anonymous hugepage in NR_FILE_MAPPED/NR_ANON_PAGES.

 [PATCH 1/7] hugetlb, rmap: add reverse mapping for hugepage
 [PATCH 2/7] HWPOISON, hugetlb: enable error handling path for hugepage
 [PATCH 3/7] HWPOISON, hugetlb: set/clear PG_hwpoison bits on hugepage
 [PATCH 4/7] HWPOISON, hugetlb: maintain mce_bad_pages in handling hugepage error
 [PATCH 5/7] HWPOISON, hugetlb: isolate corrupted hugepage
 [PATCH 6/7] HWPOISON, hugetlb: detect hwpoison in hugetlb code
 [PATCH 7/7] HWPOISON, hugetlb: support hwpoison injection for hugepage

Dependency:
- patch 2 depends on patch 1.
- patch 3 to patch 6 depend on patch 2.

 include/linux/hugetlb.h |    3 +
 mm/hugetlb.c            |   98 ++++++++++++++++++++++++++++++++++++++-
 mm/hwpoison-inject.c    |   15 ++++--
 mm/memory-failure.c     |  120 +++++++++++++++++++++++++++++++++++------------
 mm/rmap.c               |   16 ++++++
 5 files changed, 215 insertions(+), 37 deletions(-)

ChangeLog from v4:
- rebased to 2.6.34-rc7
- add isolation code for free/reserved hugepage in me_huge_page()
- set/clear PG_hwpoison bits of all pages in hugepage.
- mce_bad_pages counts all pages in hugepage.
- rename __hugepage_set_anon_rmap() to hugepage_add_anon_rmap()
- add huge_pte_offset() dummy function in header file on !CONFIG_HUGETLBFS

ChangeLog from v3:
- rebased to 2.6.34-rc5
- support for privately mapped hugepage

ChangeLog from v2:
- rebase to 2.6.34-rc3
- consider mapcount of hugepage
- rename pointer "head" into "hpage"

ChangeLog from v1:
- rebase to 2.6.34-rc1
- add comment from Wu Fengguang

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
