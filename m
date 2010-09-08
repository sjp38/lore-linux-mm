Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1FAAF6B0085
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 21:29:46 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 07/10] HWPOSION, hugetlb: recover from free hugepage error when !MF_COUNT_INCREASED
Date: Wed,  8 Sep 2010 10:19:38 +0900
Message-Id: <1283908781-13810-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Currently error recovery for free hugepage works only for MF_COUNT_INCREASED.
This patch enables !MF_COUNT_INCREASED case.

Free hugepages can be handled directly by alloc_huge_page() and
dequeue_hwpoisoned_huge_page(), and both of them are protected
by hugetlb_lock, so there is no race between them.

Note that this patch defines the refcount of HWPoisoned hugepage
dequeued from freelist is 1, deviated from present 0, thereby we
can avoid race between unpoison and memory failure on free hugepage.
This is reasonable because unlikely to free buddy pages, free hugepage
is governed by hugetlbfs even after error handling finishes.
And it also makes unpoison code added in the later patch cleaner.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 mm/hugetlb.c        |    1 +
 mm/memory-failure.c |   33 ++++++++++++++++++++++++++++++++-
 2 files changed, 33 insertions(+), 1 deletions(-)

diff --git v2.6.36-rc2/mm/hugetlb.c v2.6.36-rc2/mm/hugetlb.c
index adb5dfa..79a049a 100644
--- v2.6.36-rc2/mm/hugetlb.c
+++ v2.6.36-rc2/mm/hugetlb.c
@@ -2972,6 +2972,7 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
 	spin_lock(&hugetlb_lock);
 	if (is_hugepage_on_freelist(hpage)) {
 		list_del(&hpage->lru);
+		set_page_refcounted(hpage);
 		h->free_huge_pages--;
 		h->free_huge_pages_node[nid]--;
 		ret = 0;
diff --git v2.6.36-rc2/mm/memory-failure.c v2.6.36-rc2/mm/memory-failure.c
index c67f801..dfeb8b8 100644
--- v2.6.36-rc2/mm/memory-failure.c
+++ v2.6.36-rc2/mm/memory-failure.c
@@ -983,7 +983,10 @@ int __memory_failure(unsigned long pfn, int trapno, int flags)
 	 * We need/can do nothing about count=0 pages.
 	 * 1) it's a free page, and therefore in safe hand:
 	 *    prep_new_page() will be the gate keeper.
-	 * 2) it's part of a non-compound high order page.
+	 * 2) it's a free hugepage, which is also safe:
+	 *    an affected hugepage will be dequeued from hugepage freelist,
+	 *    so there's no concern about reusing it ever after.
+	 * 3) it's part of a non-compound high order page.
 	 *    Implies some kernel user: cannot stop them from
 	 *    R/W the page; let's pray that the page has been
 	 *    used and will be freed some time later.
@@ -995,6 +998,24 @@ int __memory_failure(unsigned long pfn, int trapno, int flags)
 		if (is_free_buddy_page(p)) {
 			action_result(pfn, "free buddy", DELAYED);
 			return 0;
+		} else if (PageHuge(hpage)) {
+			/*
+			 * Check "just unpoisoned", "filter hit", and
+			 * "race with other subpage."
+			 */
+			lock_page_nosync(hpage);
+			if (!PageHWPoison(hpage)
+			    || (hwpoison_filter(p) && TestClearPageHWPoison(p))
+			    || (p != hpage && TestSetPageHWPoison(hpage))) {
+				atomic_long_sub(nr_pages, &mce_bad_pages);
+				return 0;
+			}
+			set_page_hwpoison_huge_page(hpage);
+			res = dequeue_hwpoisoned_huge_page(hpage);
+			action_result(pfn, "free huge",
+				      res ? IGNORED : DELAYED);
+			unlock_page(hpage);
+			return res;
 		} else {
 			action_result(pfn, "high order kernel", IGNORED);
 			return -EBUSY;
@@ -1156,6 +1177,16 @@ int unpoison_memory(unsigned long pfn)
 	nr_pages = 1 << compound_order(page);
 
 	if (!get_page_unless_zero(page)) {
+		/*
+		 * Since HWPoisoned hugepage should have non-zero refcount,
+		 * race between memory failure and unpoison seems to happen.
+		 * In such case unpoison fails and memory failure runs
+		 * to the end.
+		 */
+		if (PageHuge(page)) {
+			pr_debug("MCE: Memory failure is now running on free hugepage %#lx\n", pfn);
+			return 0;
+		}
 		if (TestClearPageHWPoison(p))
 			atomic_long_sub(nr_pages, &mce_bad_pages);
 		pr_debug("MCE: Software-unpoisoned free page %#lx\n", pfn);
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
