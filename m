Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4EFEA8D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 01:33:17 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 6/7] HWPOISON: pass order to set/clear_page_hwpoison_huge_page()
Date: Fri, 21 Jan 2011 15:28:59 +0900
Message-Id: <1295591340-1862-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <tatsu@ab.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>, tony.luck@intel.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

When a surplus hugepage is soft-offlined, the old hugepage will
be freed into buddy directly. Then we'll have no access to hstate.
So we need to pass page order to PG_HWPoison set/clear functions.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git v2.6.38-rc1/mm/memory-failure.c v2.6.38-rc1/mm/memory-failure.c
index b4910e8..eed1846 100644
--- v2.6.38-rc1/mm/memory-failure.c
+++ v2.6.38-rc1/mm/memory-failure.c
@@ -927,18 +927,18 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	return ret;
 }
 
-static void set_page_hwpoison_huge_page(struct page *hpage)
+static void set_page_hwpoison_huge_page(struct page *hpage, int order)
 {
 	int i;
-	int nr_pages = 1 << compound_trans_order(hpage);
+	int nr_pages = 1 << order;
 	for (i = 0; i < nr_pages; i++)
 		SetPageHWPoison(hpage + i);
 }
 
-static void clear_page_hwpoison_huge_page(struct page *hpage)
+static void clear_page_hwpoison_huge_page(struct page *hpage, int order)
 {
 	int i;
-	int nr_pages = 1 << compound_trans_order(hpage);
+	int nr_pages = 1 << order;
 	for (i = 0; i < nr_pages; i++)
 		ClearPageHWPoison(hpage + i);
 }
@@ -1002,7 +1002,8 @@ int __memory_failure(unsigned long pfn, int trapno, int flags)
 				atomic_long_sub(nr_pages, &mce_bad_pages);
 				return 0;
 			}
-			set_page_hwpoison_huge_page(hpage);
+			set_page_hwpoison_huge_page(hpage,
+						    compound_order(hpage));
 			res = dequeue_hwpoisoned_huge_page(hpage);
 			action_result(pfn, "free huge",
 				      res ? IGNORED : DELAYED);
@@ -1078,7 +1079,7 @@ int __memory_failure(unsigned long pfn, int trapno, int flags)
 	 * page lock held, we can safely set PG_hwpoison bits on tail pages.
 	 */
 	if (PageHuge(p))
-		set_page_hwpoison_huge_page(hpage);
+		set_page_hwpoison_huge_page(hpage, compound_order(hpage));
 
 	wait_on_page_writeback(p);
 
@@ -1197,7 +1198,8 @@ int unpoison_memory(unsigned long pfn)
 		atomic_long_sub(nr_pages, &mce_bad_pages);
 		freeit = 1;
 		if (PageHuge(page))
-			clear_page_hwpoison_huge_page(page);
+			clear_page_hwpoison_huge_page(page,
+						      compound_order(page));
 	}
 	unlock_page(page);
 
@@ -1275,6 +1277,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
 	struct page *hpage = compound_head(page);
+	int order = compound_order(hpage);
 	LIST_HEAD(pagelist);
 
 	ret = get_any_page(page, pfn, flags);
@@ -1303,8 +1306,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	}
 done:
 	if (!PageHWPoison(hpage))
-		atomic_long_add(1 << compound_trans_order(hpage), &mce_bad_pages);
-	set_page_hwpoison_huge_page(hpage);
+		atomic_long_add(1 << order, &mce_bad_pages);
+	set_page_hwpoison_huge_page(hpage, order);
 	dequeue_hwpoisoned_huge_page(hpage);
 	/* keep elevated page count for bad page */
 	return ret;
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
