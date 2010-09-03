Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C27736B004D
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 00:40:34 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/10] Hugepage migration (v4)
Date: Fri,  3 Sep 2010 13:37:28 +0900
Message-Id: <1283488658-23137-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

This is the 4th version of "hugepage migration" set.

Major changes: (see individual patches for more details)
- Folded alloc_buddy_huge_page_node() into alloc_buddy_huge_page().
- Fixed race condition between dequeue function and allocate function.
  This is based on the draft patch from Wu Fengguang. Thank you.
- Enabled missing path of recovery from uncorrected error on free hugepage.
- Change semantics of refcount of isolated hugepage from freelist.


Future works:

- Migration can fail for various reasons depending on various factors,
  so it's useful if soft offline can be retried when it noticed migration
  fails. This problem is a more general one because it's applied for
  soft offline of normal-sized pages. So we leave it as a future work.
  
- Corrupted hugepage counter implemeted in the previous version was dropped
  because it's not directly related to migration topic and have no serious
  impact on kernel behavior. We also leave it as the next work.


Summary:

 [PATCH 01/10] hugetlb: fix metadata corruption in hugetlb_fault()
 [PATCH 02/10] hugetlb: add allocate function for hugepage migration
 [PATCH 03/10] hugetlb: redefine hugepage copy functions
 [PATCH 04/10] hugetlb: hugepage migration core
 [PATCH 05/10] HWPOISON, hugetlb: add free check to dequeue_hwpoison_huge_page()
 [PATCH 06/10] hugetlb: move refcounting in hugepage allocation inside hugetlb_lock
 [PATCH 07/10] HWPOSION, hugetlb: recover from free hugepage error when !MF_COUNT_INCREASED
 [PATCH 08/10] HWPOISON, hugetlb: soft offlining for hugepage
 [PATCH 09/10] HWPOISON, hugetlb: fix unpoison for hugepage
 [PATCH 10/10] page-types.c: fix name of unpoison interface

 Documentation/vm/page-types.c |    2 +-
 fs/hugetlbfs/inode.c          |   15 +++
 include/linux/hugetlb.h       |   11 ++-
 include/linux/migrate.h       |   12 ++
 mm/hugetlb.c                  |  225 ++++++++++++++++++++++++++++------------
 mm/memory-failure.c           |   93 +++++++++++++----
 mm/migrate.c                  |  192 +++++++++++++++++++++++++++++++----
 mm/vmscan.c                   |    9 ++-
 8 files changed, 446 insertions(+), 113 deletions(-)


Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
