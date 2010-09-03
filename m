Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D0B996B0088
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 00:41:45 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 09/10] HWPOISON, hugetlb: fix unpoison for hugepage
Date: Fri,  3 Sep 2010 13:37:37 +0900
Message-Id: <1283488658-23137-10-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1283488658-23137-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1283488658-23137-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Currently unpoisoning hugepages doesn't work correctly because
clearing PG_HWPoison is done outside if (TestClearPageHWPoison).
This patch fixes it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 mm/memory-failure.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git v2.6.36-rc2/mm/memory-failure.c v2.6.36-rc2/mm/memory-failure.c
index 80e71cd..b7fb8cc 100644
--- v2.6.36-rc2/mm/memory-failure.c
+++ v2.6.36-rc2/mm/memory-failure.c
@@ -1202,9 +1202,9 @@ int unpoison_memory(unsigned long pfn)
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
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
