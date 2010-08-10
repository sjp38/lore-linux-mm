Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4A66B02B3
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 05:32:30 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/9] Hugepage migration (v2)
Date: Tue, 10 Aug 2010 18:27:35 +0900
Message-Id: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

This is the 2nd version of "hugepage migration" patchset.

There were two points of issue.

* Dividing hugepage migration functions from original migration code.
  This is to avoid complexity.
  In present version, some high level migration routines are defined to handle
  hugepage, but some low level routines (such as migrate_copy_page() etc.)
  are shared with original migration code in order not to increase duplication.

* Locking problem between direct I/O and hugepage migration
  As a result of digging the race between hugepage I/O and hugepage migration,
  (where hugepage I/O can be seen only in direct I/O,)
  I noticed that without additional locking we can avoid this race condition
  because in direct I/O we can get whether some subpages are under I/O or not
  from reference count of the head page and hugepage migration safely fails
  if some references remain.  So no data lost should occurs on the migration
  concurrent with direct I/O.

This patchset is based on the following commit:

  commit 1c9bc0d7945bbbcdae99f197535588e5ad24bc1c
  "hugetlb: add missing unlock in avoidcopy path in hugetlb_cow()"

on "hwpoison" branch in Andi's tree.

  http://git.kernel.org/?p=linux/kernel/git/ak/linux-mce-2.6.git;a=summary


Summary:

 [PATCH 1/9] HWPOISON, hugetlb: move PG_HWPoison bit check
 [PATCH 2/9] hugetlb: add allocate function for hugepage migration
 [PATCH 3/9] hugetlb: rename hugepage allocation functions
 [PATCH 4/9] hugetlb: redefine hugepage copy functions
 [PATCH 5/9] hugetlb: hugepage migration core
 [PATCH 6/9] HWPOISON, hugetlb: soft offlining for hugepage
 [PATCH 7/9] HWPOISON, hugetlb: fix unpoison for hugepage
 [PATCH 8/9] page-types.c: fix name of unpoison interface
 [PATCH 9/9] hugetlb: add corrupted hugepage counter

 Documentation/vm/page-types.c |    2 +-
 fs/hugetlbfs/inode.c          |   15 +++
 include/linux/hugetlb.h       |   12 ++
 include/linux/migrate.h       |   12 ++
 mm/hugetlb.c                  |  248 +++++++++++++++++++++++++++++++++--------
 mm/memory-failure.c           |   88 ++++++++++++---
 mm/migrate.c                  |  196 +++++++++++++++++++++++++++++----
 7 files changed, 487 insertions(+), 86 deletions(-)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
