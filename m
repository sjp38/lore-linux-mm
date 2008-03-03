Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m23I6Kat019003
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 13:06:20 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m23I6wdb186892
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 11:06:58 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m23I6vgU022082
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 11:06:58 -0700
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 3/3] hugetlb: Decrease hugetlb_lock cycling in gather_surplus_huge_pages
Date: Mon, 03 Mar 2008 10:06:55 -0800
Message-Id: <20080303180655.5383.48596.stgit@kernel>
In-Reply-To: <20080303180622.5383.20868.stgit@kernel>
References: <20080303180622.5383.20868.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

To reduce hugetlb_lock acquisitions and releases when freeing excess
surplus pages, scan the page list in two parts.  First, transfer the needed
pages to the hugetlb pool.  Then drop the lock and free the remaining
pages back to the buddy allocator.

In the common case there are zero excess pages and no lock operations are
required.

Thanks Mel Gorman for this improvement.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>
---

 mm/hugetlb.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f6ce740..b0d48bf 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -350,11 +350,19 @@ retry:
 	resv_huge_pages += delta;
 	ret = 0;
 free:
+	/* Free the needed pages to the hugetlb pool */
 	list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
+		if ((--needed) < 0)
+			break;
 		list_del(&page->lru);
-		if ((--needed) >= 0)
-			enqueue_huge_page(page);
-		else {
+		enqueue_huge_page(page);
+	}
+
+	/* Free unnecessary surplus pages to the buddy allocator */
+	if (!list_empty(&surplus_list)) {
+		spin_unlock(&hugetlb_lock);
+		list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
+			list_del(&page->lru);
 			/*
 			 * The page has a reference count of zero already, so
 			 * call free_huge_page directly instead of using
@@ -362,10 +370,9 @@ free:
 			 * unlocked which is safe because free_huge_page takes
 			 * hugetlb_lock before deciding how to free the page.
 			 */
-			spin_unlock(&hugetlb_lock);
 			free_huge_page(page);
-			spin_lock(&hugetlb_lock);
 		}
+		spin_lock(&hugetlb_lock);
 	}
 
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
