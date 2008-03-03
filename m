Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m23I6ZfB024124
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 13:06:35 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m23I6ZFR066174
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 11:06:35 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m23I6ZXN008662
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 11:06:35 -0700
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 1/3] hugetlb: Correct page count for surplus huge pages
Date: Mon, 03 Mar 2008 10:06:32 -0800
Message-Id: <20080303180632.5383.7661.stgit@kernel>
In-Reply-To: <20080303180622.5383.20868.stgit@kernel>
References: <20080303180622.5383.20868.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Free pages in the hugetlb pool are free and as such have a reference
count of zero.  Regular allocations into the pool from the buddy are
"freed" into the pool which results in their page_count dropping to zero.
However, surplus pages can be directly utilized by the caller without first
being freed to the pool.  Therefore, a call to put_page_testzero() is in
order so that such a page will be handed to the caller with a correct
count.

This has not effected end users because the bad page count is reset before
the page is handed off.  However, under CONFIG_DEBUG_VM this triggers a BUG
when the page count is validated.

Thanks go to Mel for first spotting this issue and providing an initial
fix.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>
---

 mm/hugetlb.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index db861d8..819d6d9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -267,6 +267,12 @@ static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
 
 	spin_lock(&hugetlb_lock);
 	if (page) {
+		/*
+		 * This page is now managed by the hugetlb allocator and has
+		 * no users -- drop the buddy allocator's reference.
+		 */
+		int page_count = put_page_testzero(page);
+		BUG_ON(page_count != 0);
 		nid = page_to_nid(page);
 		set_compound_page_dtor(page, free_huge_page);
 		/*
@@ -345,13 +351,14 @@ free:
 			enqueue_huge_page(page);
 		else {
 			/*
-			 * Decrement the refcount and free the page using its
-			 * destructor.  This must be done with hugetlb_lock
+			 * The page has a reference count of zero already, so
+			 * call free_huge_page directly instead of using
+			 * put_page.  This must be done with hugetlb_lock
 			 * unlocked which is safe because free_huge_page takes
 			 * hugetlb_lock before deciding how to free the page.
 			 */
 			spin_unlock(&hugetlb_lock);
-			put_page(page);
+			free_huge_page(page);
 			spin_lock(&hugetlb_lock);
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
