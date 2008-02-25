Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1PM1tpc005503
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 17:01:55 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1PM1sMr189590
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 15:01:54 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1PM1sma031202
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 15:01:54 -0700
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 3/3] hugetlb: Decrease hugetlb_lock cycling in gather_surplus_huge_pages
Date: Mon, 25 Feb 2008 14:01:52 -0800
Message-Id: <20080225220152.23627.25591.stgit@kernel>
In-Reply-To: <20080225220119.23627.33676.stgit@kernel>
References: <20080225220119.23627.33676.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: mel@csn.ul.ie, apw@shadowen.org, nacc@linux.vnet.ibm.com, agl@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

To reduce the number of times we acquire and release hugetlb_lock when
freeing excess huge pages, loop through the page list twice: once to siphon
pages into the hugetlb pool, and again to free the excess pages back to the
buddy allocator.  This removes the lock/unlock around free_huge_page().

Note that we still visit each page only once since a page is always removed
from the list when it is visited.

Thanks Mel Gorman for this improvement.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>
---

 mm/hugetlb.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8296431..306d762 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -349,11 +349,19 @@ retry:
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
@@ -361,10 +369,9 @@ free:
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
