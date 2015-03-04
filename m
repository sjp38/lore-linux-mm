Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 660CB6B006C
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 20:22:11 -0500 (EST)
Received: by pdjz10 with SMTP id z10so1940393pdj.11
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 17:22:11 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id jg3si3142252pac.45.2015.03.03.17.22.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 17:22:10 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 2/4] hugetlbfs: coordinate global and subpool reserve accounting
Date: Tue,  3 Mar 2015 17:21:44 -0800
Message-Id: <1425432106-17214-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com>
References: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>

If the pages for a subpool are reserved, then the reservations
have already been accounted for in the global pool(at mount time).
Therefore, when requesting a new reservation (such as for a
mapping) do not adjust the global reserve count.  Also, when
simply unreserving pages for the subpool do not adjust the global
count.  However, when actually allocating or freeing a hugepage
be sure to adjust the global reserve count so that it corresponds
with the global free count.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 36 ++++++++++++++++++++++++++++--------
 1 file changed, 28 insertions(+), 8 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c6adf65..394bd8f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -879,7 +879,11 @@ void free_huge_page(struct page *page)
 	spin_lock(&hugetlb_lock);
 	hugetlb_cgroup_uncharge_page(hstate_index(h),
 				     pages_per_huge_page(h), page);
-	if (restore_reserve)
+	/*
+	 * When a hugepage in a reserved subpool is free'ed, the global
+	 * reserve count must be adjusted along with the global free count.
+	 */
+	if (restore_reserve || hugepage_subpool_reserved(spool))
 		h->resv_huge_pages++;
 
 	if (h->surplus_huge_pages_node[nid]) {
@@ -2466,7 +2470,12 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 	kref_put(&resv->refs, resv_map_release);
 
 	if (reserve) {
-		hugetlb_acct_memory(h, -reserve);
+		/*
+		 * For reserved subpools, global reservation counts are
+		 * only adjusted at hugepage alloc and free time.
+		 */
+		if (!hugepage_subpool_reserved(spool))
+			hugetlb_acct_memory(h, -reserve);
 		hugepage_subpool_put_pages(spool, reserve);
 	}
 }
@@ -3442,12 +3451,18 @@ int hugetlb_reserve_pages(struct inode *inode,
 
 	/*
 	 * Check enough hugepages are available for the reservation.
-	 * Hand the pages back to the subpool if there are not
+	 * Hand the pages back to the subpool if there are not.  If
+	 * the entire subpool was reserved, we know there are enough
+	 * hugepages and the global count already reflects the reservation.
 	 */
-	ret = hugetlb_acct_memory(h, chg);
-	if (ret < 0) {
-		hugepage_subpool_put_pages(spool, chg);
-		goto out_err;
+	if (hugepage_subpool_reserved(spool))
+		ret = 0;
+	else {
+		ret = hugetlb_acct_memory(h, chg);
+		if (ret < 0) {
+			hugepage_subpool_put_pages(spool, chg);
+			goto out_err;
+		}
 	}
 
 	/*
@@ -3483,7 +3498,12 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 	inode->i_blocks -= (blocks_per_huge_page(h) * freed);
 	spin_unlock(&inode->i_lock);
 
-	hugepage_subpool_put_pages(spool, (chg - freed));
+	/*
+	 * For reserved subpools, global reservation counts are only
+	 * adjusted at hugepage alloc and free time.
+	 */
+	if (!hugepage_subpool_reserved(spool))
+		hugepage_subpool_put_pages(spool, (chg - freed));
 	hugetlb_acct_memory(h, -(chg - freed));
 }
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
