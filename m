Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1PM1WHK028492
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 17:01:32 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1PM1WCL214784
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 15:01:32 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1PM1VCp029542
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 15:01:31 -0700
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 1/3] hugetlb: Correct page count for surplus huge pages
Date: Mon, 25 Feb 2008 14:01:29 -0800
Message-Id: <20080225220129.23627.5152.stgit@kernel>
In-Reply-To: <20080225220119.23627.33676.stgit@kernel>
References: <20080225220119.23627.33676.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: mel@csn.ul.ie, apw@shadowen.org, nacc@linux.vnet.ibm.com, agl@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Free pages in the hugetlb pool are free and as such have a reference
count of zero.  Regular allocations into the pool from the buddy are
"freed" into the pool which results in their page_count dropping to zero.
However, surplus pages are directly utilized by the caller without first
being freed so an explicit reset of the reference count is needed.

This hasn't effected end users because the bad page count is reset before
the page is handed off.  However, under CONFIG_DEBUG_VM this triggers a BUG
when the page count is validated.

Thanks go to Mel for first spotting this issue and providing an initial
fix.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>
---

 mm/hugetlb.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index db861d8..026e5ee 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -267,6 +267,11 @@ static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
 
 	spin_lock(&hugetlb_lock);
 	if (page) {
+		/*
+		 * This page is now managed by the hugetlb allocator and has
+		 * no current users -- reset its reference count.
+		 */
+		set_page_count(page, 0);
 		nid = page_to_nid(page);
 		set_compound_page_dtor(page, free_huge_page);
 		/*
@@ -345,13 +350,14 @@ free:
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
