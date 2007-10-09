Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l99FwmV6017417
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 11:58:48 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l99Fwl8h412648
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 09:58:47 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l99FwkMb027493
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 09:58:46 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH] hugetlb: Fix dynamic pool resize failure case
Date: Tue, 09 Oct 2007 08:58:45 -0700
Message-Id: <20071009155845.20191.85647.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When gather_surplus_pages() fails to allocate enough huge pages to satisfy
the requested reservation, it frees what it did allocate back to the buddy
allocator.  put_page() should be called instead of update_and_free_page()
to ensure that pool counters are updated as appropriate and the page's
refcount is decremented.

Andrew: This should apply cleanly to my patches in the -mm tree.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 mm/hugetlb.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9b3dfac..f349c16 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -281,8 +281,11 @@ free:
 		list_del(&page->lru);
 		if ((--needed) >= 0)
 			enqueue_huge_page(page);
-		else
-			update_and_free_page(page);
+		else {
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
