Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 073C28D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 01:32:53 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/7] remove putback_lru_pages() in hugepage migration context
Date: Fri, 21 Jan 2011 15:28:56 +0900
Message-Id: <1295591340-1862-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <tatsu@ab.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>, tony.luck@intel.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

This putback_lru_pages() is inserted at cf608ac19c to allow
memory compaction to count the number of migration failed pages.

But we should not do it for a hugepage because page->lru of a hugepage
is used differently from that of a normal page:

   in-use hugepage : page->lru is unlinked,
   free hugepage   : page->lru is linked to the free hugepage list,

so putting back hugepages to LRU lists collapses this rule.
We just drop this change (without any impact on memory compaction.)

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
---
 mm/memory-failure.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git v2.6.38-rc1/mm/memory-failure.c v2.6.38-rc1/mm/memory-failure.c
index 548fbd7..b4910e8 100644
--- v2.6.38-rc1/mm/memory-failure.c
+++ v2.6.38-rc1/mm/memory-failure.c
@@ -1295,7 +1295,6 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	ret = migrate_huge_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, 0,
 				true);
 	if (ret) {
-		putback_lru_pages(&pagelist);
 		pr_debug("soft offline: %#lx: migration failed %d, type %lx\n",
 			 pfn, ret, page->flags);
 		if (ret > 0)
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
