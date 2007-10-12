Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9CJFLTO014218
	for <linux-mm@kvack.org>; Fri, 12 Oct 2007 15:15:21 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9CJFL3v458956
	for <linux-mm@kvack.org>; Fri, 12 Oct 2007 13:15:21 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9CJFL6l031091
	for <linux-mm@kvack.org>; Fri, 12 Oct 2007 13:15:21 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH] hugetlb: Fix dynamic pool resize failure case
Date: Fri, 12 Oct 2007 12:15:20 -0700
Message-Id: <20071012191519.14433.13461.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Adam Litke <agl@us.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Changes since V1
	Added a comment explaining the free logic in gather_surplus_pages.

When gather_surplus_pages() fails to allocate enough huge pages to satisfy
the requested reservation, it frees what it did allocate back to the buddy
allocator.  put_page() should be called instead of update_and_free_page()
to ensure that pool counters are updated as appropriate and the page's
refcount is decremented.

Andrew: This should apply cleanly to my patches in the -mm tree.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 mm/hugetlb.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9b3dfac..ce66c72 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -281,8 +281,17 @@ free:
 		list_del(&page->lru);
 		if ((--needed) >= 0)
 			enqueue_huge_page(page);
-		else
-			update_and_free_page(page);
+		else {
+			/*
+			 * Decrement the refcount and free the page using its
+			 * destructor.  This must be done with hugetlb_lock
+			 * unlocked which is safe because free_huge_page takes
+			 * hugetlb_lock before deciding how to free the page.
+			 */
+			spin_unlock(&hugetlb_lock);
+			put_page(page);
+			spin_lock(&hugetlb_lock);
+		}
 	}
 
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
