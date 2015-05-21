Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 302406B0166
	for <linux-mm@kvack.org>; Thu, 21 May 2015 11:48:44 -0400 (EDT)
Received: by pdea3 with SMTP id a3so112369808pde.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 08:48:43 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ep5si6162118pbd.5.2015.05.21.08.48.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 08:48:43 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v3 PATCH 02/10] mm/hugetlb: handle races in alloc_huge_page and hugetlb_reserve_pages
Date: Thu, 21 May 2015 08:47:36 -0700
Message-Id: <1432223264-4414-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
References: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

alloc_huge_page and hugetlb_reserve_pages use region_chg to
calculate the number of pages which will be added to the reserve
map.  Subpool and global reserve counts are adjusted based on
the output of region_chg.  Before the pages are actually added
to the reserve map, these routines could race and add fewer
pages than expected.  If this happens, the subpool and global
reserve counts are not correct.

Compare the number of pages actually added (region_add) to those
expected to added (region_chg).  If fewer pages are actually added,
this indicates a race and adjust counters accordingly.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 37 +++++++++++++++++++++++++++++++++----
 1 file changed, 33 insertions(+), 4 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7f64034..63f6d43 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1374,13 +1374,16 @@ static long vma_commit_reservation(struct hstate *h,
 		return 0;
 }
 
+/* Forward declaration */
+static int hugetlb_acct_memory(struct hstate *h, long delta);
+
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
 				    unsigned long addr, int avoid_reserve)
 {
 	struct hugepage_subpool *spool = subpool_vma(vma);
 	struct hstate *h = hstate_vma(vma);
 	struct page *page;
-	long chg;
+	long chg, commit;
 	int ret, idx;
 	struct hugetlb_cgroup *h_cg;
 
@@ -1421,7 +1424,20 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 
 	set_page_private(page, (unsigned long)spool);
 
-	vma_commit_reservation(h, vma, addr);
+	commit = vma_commit_reservation(h, vma, addr);
+	if (unlikely(chg > commit)) {
+		/*
+		 * The page was added to the reservation map between
+		 * vma_needs_reservation and vma_commit_reservation.
+		 * This indicates a race with hugetlb_reserve_pages.
+		 * Adjust for the subpool count incremented above AND
+		 * in hugetlb_reserve_pages for the same page.  Also,
+		 * the reservation count added in hugetlb_reserve_pages
+		 * no longer applies.
+		 */
+		hugepage_subpool_put_pages(spool, 1);
+		hugetlb_acct_memory(h, -1);
+	}
 	return page;
 
 out_uncharge_cgroup:
@@ -3512,8 +3528,21 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * consumed reservations are stored in the map. Hence, nothing
 	 * else has to be done for private mappings here
 	 */
-	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		region_add(resv_map, from, to);
+	if (!vma || vma->vm_flags & VM_MAYSHARE) {
+		long add = region_add(resv_map, from, to);
+
+		if (unlikely(chg > add)) {
+			/*
+			 * pages in this range were added to the reserve
+			 * map between region_chg and region_add.  This
+			 * indicates a race with alloc_huge_page.  Adjust
+			 * the subpool and reserve counts modified above
+			 * based on the difference.
+			 */
+			hugepage_subpool_put_pages(spool, chg - add);
+			hugetlb_acct_memory(h, -(chg - ret));
+		}
+	}
 	return 0;
 out_err:
 	if (vma && is_vma_resv_set(vma, HPAGE_RESV_OWNER))
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
