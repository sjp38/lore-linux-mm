Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C2BF38D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 01:33:11 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 5/7] hugetlb: fix race condition between hugepage soft offline and page fault
Date: Fri, 21 Jan 2011 15:28:58 +0900
Message-Id: <1295591340-1862-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <tatsu@ab.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>, tony.luck@intel.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

When hugepage soft offline succeeds, the old hugepage is expected
to be temporarily enqueued to free hugepage list, and then dequeued
as a HWPOISONed hugepage.

But there is a race window, which collapses reference counting.
See the following list:

  soft offline                       page fault

  soft_offline_huge_page
    migrate_huge_pages
      unmap_and_move_huge_page
        lock_page
        try_to_unmap
        move_to_new_page
          migrate_page
            migrate_page_copy
                                     hugetlb_fault
                                       migration_hugepage_entry_wait
                                         get_page_unless_zero
                                         wait_on_page_locked
          remove_migration_ptes
        unlock_page
  -------------------------------------------------------------------
        put_page                         put_page
    dequeue_hwpoisoned_huge_page


Two put_page()s below the horizontal line are racy.
If put_page() from soft offline comes first, the HWPOISONed hugepage
remains in free hugepage list, causing wrong results.

It's hard to fix this problem by locking because we cannot control
page fault by page lock.
So this patch just adds to free_huge_page() a HWPOISON check,
which ensures that the last user of the old hugepage dequeues it
from free hugepage list.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c |   28 +++++++++++++++++++++-------
 1 files changed, 21 insertions(+), 7 deletions(-)

diff --git v2.6.38-rc1/mm/hugetlb.c v2.6.38-rc1/mm/hugetlb.c
index d3b856a..b777c81 100644
--- v2.6.38-rc1/mm/hugetlb.c
+++ v2.6.38-rc1/mm/hugetlb.c
@@ -524,6 +524,8 @@ struct hstate *size_to_hstate(unsigned long size)
 	return NULL;
 }
 
+static int __dequeue_hwpoisoned_huge_page(struct page *hpage, struct hstate *h);
+
 static void free_huge_page(struct page *page)
 {
 	/*
@@ -548,6 +550,8 @@ static void free_huge_page(struct page *page)
 		h->surplus_huge_pages_node[nid]--;
 	} else {
 		enqueue_huge_page(h, page);
+		if (unlikely(PageHWPoison(page)))
+			__dequeue_hwpoisoned_huge_page(page, h);
 	}
 	spin_unlock(&hugetlb_lock);
 	if (mapping)
@@ -2932,17 +2936,11 @@ static int is_hugepage_on_freelist(struct page *hpage)
 	return 0;
 }
 
-/*
- * This function is called from memory failure code.
- * Assume the caller holds page lock of the head page.
- */
-int dequeue_hwpoisoned_huge_page(struct page *hpage)
+static int __dequeue_hwpoisoned_huge_page(struct page *hpage, struct hstate *h)
 {
-	struct hstate *h = page_hstate(hpage);
 	int nid = page_to_nid(hpage);
 	int ret = -EBUSY;
 
-	spin_lock(&hugetlb_lock);
 	if (is_hugepage_on_freelist(hpage)) {
 		list_del(&hpage->lru);
 		set_page_refcounted(hpage);
@@ -2950,6 +2948,22 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
 		h->free_huge_pages_node[nid]--;
 		ret = 0;
 	}
+	return ret;
+}
+
+/*
+ * This function is called from memory failure code.
+ * Assume the caller holds page lock of the head page.
+ */
+int dequeue_hwpoisoned_huge_page(struct page *hpage)
+{
+	struct hstate *h = page_hstate(hpage);
+	int ret;
+
+	if (!h)
+		return 0;
+	spin_lock(&hugetlb_lock);
+	ret = __dequeue_hwpoisoned_huge_page(hpage, h);
 	spin_unlock(&hugetlb_lock);
 	return ret;
 }
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
