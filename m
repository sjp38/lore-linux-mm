Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6B96B02C7
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 05:33:05 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 7/9] HWPOISON, hugetlb: fix unpoison for hugepage
Date: Tue, 10 Aug 2010 18:27:42 +0900
Message-Id: <1281432464-14833-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Currently unpoisoning hugepages doesn't work because it's not enough
to just clear PG_HWPoison bits and we need to link the hugepage
to be unpoisoned back to the free hugepage list.
To do this, we get and put hwpoisoned hugepage whose refcount is 0.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 mm/memory-failure.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git linux-mce-hwpoison/mm/memory-failure.c linux-mce-hwpoison/mm/memory-failure.c
index 0bfe5b3..1f54901 100644
--- linux-mce-hwpoison/mm/memory-failure.c
+++ linux-mce-hwpoison/mm/memory-failure.c
@@ -1153,9 +1153,19 @@ int unpoison_memory(unsigned long pfn)
 	nr_pages = 1 << compound_order(page);
 
 	if (!get_page_unless_zero(page)) {
-		if (TestClearPageHWPoison(p))
+		/* The page to be unpoisoned was free one when hwpoisoned */
+		if (TestClearPageHWPoison(page))
 			atomic_long_sub(nr_pages, &mce_bad_pages);
 		pr_debug("MCE: Software-unpoisoned free page %#lx\n", pfn);
+		if (PageHuge(page)) {
+			/*
+			 * To unpoison free hugepage, we get and put it
+			 * to move it back to the free list.
+			 */
+			get_page(page);
+			clear_page_hwpoison_huge_page(page);
+			put_page(page);
+		}
 		return 0;
 	}
 
@@ -1170,9 +1180,9 @@ int unpoison_memory(unsigned long pfn)
 		pr_debug("MCE: Software-unpoisoned page %#lx\n", pfn);
 		atomic_long_sub(nr_pages, &mce_bad_pages);
 		freeit = 1;
+		if (PageHuge(page))
+			clear_page_hwpoison_huge_page(page);
 	}
-	if (PageHuge(p))
-		clear_page_hwpoison_huge_page(page);
 	unlock_page(page);
 
 	put_page(page);
-- 
1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
