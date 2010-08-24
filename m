Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id ADE6B6B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 19:56:32 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/8] Hugepage migration (v3)
Date: Wed, 25 Aug 2010 08:55:19 +0900
Message-Id: <1282694127-14609-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

This is the 3rd version of "hugepage migration" set.
I rebased this onto 2.6.36-rc2 and merged many comments from you.

In previous discussion, I explained why hugepage migration encounts no race
with direct I/O without additional page locking. Based on that reasoning,
I made no change on page locking on migration code (i.e. lock only head pages.)


Future works:

- Migration can fail for various reasons depending on various factors,
  so it's useful if soft offline can be retried when it noticed migration
  fails. This problem is a more general one because it's applied for
  soft offline of normal-sized pages. So we leave it as a future work.
  
- Corrupted hugepage counter implemeted in the previous version was dropped
  because it's not directly related to migration topic and have no serious
  impact on kernel behavior. We also leave it as the next work.
  

Summary:

 [PATCH 1/8] hugetlb: fix metadata corruption in hugetlb_fault()
 [PATCH 2/8] hugetlb: add allocate function for hugepage migration
 [PATCH 3/8] hugetlb: rename hugepage allocation functions
 [PATCH 4/8] hugetlb: redefine hugepage copy functions
 [PATCH 5/8] hugetlb: hugepage migration core
 [PATCH 6/8] HWPOISON, hugetlb: soft offlining for hugepage
 [PATCH 7/8] HWPOISON, hugetlb: fix unpoison for hugepage
 [PATCH 8/8] page-types.c: fix name of unpoison interface

 Documentation/vm/page-types.c |    2 +-
 fs/hugetlbfs/inode.c          |   15 +++
 include/linux/hugetlb.h       |    9 ++
 include/linux/migrate.h       |   12 +++
 mm/hugetlb.c                  |  216 ++++++++++++++++++++++++++++++++---------
 mm/memory-failure.c           |   65 +++++++++----
 mm/migrate.c                  |  192 +++++++++++++++++++++++++++++++++----
 mm/vmscan.c                   |    9 ++-
 8 files changed, 434 insertions(+), 86 deletions(-)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
