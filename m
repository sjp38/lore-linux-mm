Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 43DBC6B006E
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 17:59:39 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id wp4so21510625obc.10
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:59:39 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id df10si2784977oeb.100.2015.02.27.14.59.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 14:59:38 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC 2/3] hugetlbfs: coordinate global and subpool reserve accounting
Date: Fri, 27 Feb 2015 14:58:12 -0800
Message-Id: <1425077893-18366-5-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr@hp.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>

If the pages for a subpool are reserved, then the reservations have
already been accounted for in the global pool.  Therefore, when
requesting a new reservation (such as for a mapping) for the subpool
do not count again in global pool.  However, when actually allocating
a page for the subpool decrement gobal reserve count to correspond to
with decrement in global free pages.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c6adf65..4ef8379 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -879,7 +879,7 @@ void free_huge_page(struct page *page)
 	spin_lock(&hugetlb_lock);
 	hugetlb_cgroup_uncharge_page(hstate_index(h),
 				     pages_per_huge_page(h), page);
-	if (restore_reserve)
+	if (restore_reserve || subpool_reserved(spool))
 		h->resv_huge_pages++;
 
 	if (h->surplus_huge_pages_node[nid]) {
@@ -2466,7 +2466,8 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 	kref_put(&resv->refs, resv_map_release);
 
 	if (reserve) {
-		hugetlb_acct_memory(h, -reserve);
+		if (!subpool_reserved(spool))
+			hugetlb_acct_memory(h, -reserve);
 		hugepage_subpool_put_pages(spool, reserve);
 	}
 }
@@ -3444,10 +3445,14 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * Check enough hugepages are available for the reservation.
 	 * Hand the pages back to the subpool if there are not
 	 */
-	ret = hugetlb_acct_memory(h, chg);
-	if (ret < 0) {
-		hugepage_subpool_put_pages(spool, chg);
-		goto out_err;
+	if (subpool_reserved(spool))
+		ret = 0;
+	else {
+		ret = hugetlb_acct_memory(h, chg);
+		if (ret < 0) {
+			hugepage_subpool_put_pages(spool, chg);
+			goto out_err;
+		}
 	}
 
 	/*
@@ -3483,7 +3488,8 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 	inode->i_blocks -= (blocks_per_huge_page(h) * freed);
 	spin_unlock(&inode->i_lock);
 
-	hugepage_subpool_put_pages(spool, (chg - freed));
+	if (!subpool_reserved(spool))
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
