Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9710A6B025E
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 14:56:43 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id 137so53789309vkl.4
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 11:56:43 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 137si16190854vkf.241.2017.01.09.11.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 11:56:42 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] mm/hugetlb.c: fix reservation race when freeing surplus pages
Date: Mon,  9 Jan 2017 11:56:07 -0800
Message-Id: <1483991767-6879-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Paul Cassella <cassella@cray.com>, Michal Hocko <mhocko@kernel.org>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>

The routine return_unused_surplus_pages decrements the global
reservation count, and frees any unused surplus pages that were
backing the reservation.  Commit 7848a4bf51b3 ("mm/hugetlb.c:
add cond_resched_lock() in return_unused_surplus_pages()") added
a call to cond_resched_lock in the loop freeing the pages.  As
a result, the hugetlb_lock could be dropped, and someone else
could use the pages that will be freed in subsequent iterations
of the loop.  This could result in inconsistent global hugetlb
page state, application api failures (such as mmap) failures or
application crashes.

When dropping the lock in return_unused_surplus_pages, make sure
that the global reservation count (resv_huge_pages) remains
sufficiently large to prevent someone else from claiming pages
about to be freed.

Fixes: 7848a4bf51b3 ("mm/hugetlb.c: add cond_resched_lock() in return_unused_surplus_pages()")
Reported-and-analyzed-by: Paul Cassella <cassella@cray.com>
Suggested-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 37 ++++++++++++++++++++++++++++---------
 1 file changed, 28 insertions(+), 9 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 418bf01..a1760fa 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1773,23 +1773,32 @@ static int gather_surplus_pages(struct hstate *h, int delta)
 }
 
 /*
- * When releasing a hugetlb pool reservation, any surplus pages that were
- * allocated to satisfy the reservation must be explicitly freed if they were
- * never used.
- * Called with hugetlb_lock held.
+ * This routine has two main purposes:
+ * 1) Decrement the reservation count (resv_huge_pages) by the value passed
+ *    in unused_resv_pages.  This corresponds to the prior adjustments made
+ *    to the associated reservation map.
+ * 2) Free any unused surplus pages that may have been allocated to satisfy
+ *    the reservation.  As many as unused_resv_pages may be freed.
+ *
+ * Called with hugetlb_lock held.  However, the lock could be dropped (and
+ * reacquired) during calls to cond_resched_lock.  Whenever dropping the lock,
+ * we must make sure nobody else can claim pages we are in the process of
+ * freeing.  Do this by ensuring resv_huge_page always is greater than the
+ * number of huge pages we plan to free when dropping the lock.
  */
 static void return_unused_surplus_pages(struct hstate *h,
 					unsigned long unused_resv_pages)
 {
 	unsigned long nr_pages;
 
-	/* Uncommit the reservation */
-	h->resv_huge_pages -= unused_resv_pages;
-
 	/* Cannot return gigantic pages currently */
 	if (hstate_is_gigantic(h))
-		return;
+		goto out;
 
+	/*
+	 * Part (or even all) of the reservation could have been backed
+	 * by pre-allocated pages. Only free surplus pages.
+	 */
 	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
 
 	/*
@@ -1799,12 +1808,22 @@ static void return_unused_surplus_pages(struct hstate *h,
 	 * when the nodes with surplus pages have no free pages.
 	 * free_pool_huge_page() will balance the the freed pages across the
 	 * on-line nodes with memory and will handle the hstate accounting.
+	 *
+	 * Note that we decrement resv_huge_pages as we free the pages.  If
+	 * we drop the lock, resv_huge_pages will still be sufficiently large
+	 * to cover subsequent pages we may free.
 	 */
 	while (nr_pages--) {
+		h->resv_huge_pages--;
+		unused_resv_pages--;
 		if (!free_pool_huge_page(h, &node_states[N_MEMORY], 1))
-			break;
+			goto out;
 		cond_resched_lock(&hugetlb_lock);
 	}
+
+out:
+	/* Fully uncommit the reservation */
+	h->resv_huge_pages -= unused_resv_pages;
 }
 
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
