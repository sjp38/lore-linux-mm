Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id BA1476B0062
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 01:54:16 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so7803816pdj.23
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 22:54:16 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id v7si13541359pbi.38.2013.12.17.22.54.11
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 22:54:12 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 14/14] mm, hugetlb: remove a hugetlb_instantiation_mutex
Date: Wed, 18 Dec 2013 15:54:00 +0900
Message-Id: <1387349640-8071-15-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, we have an infrastructure in order to remove a this awkward mutex
which serialize all faulting tasks, so remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 843c554..6edf423 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2595,9 +2595,7 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 
 /*
  * Hugetlb_cow() should be called with page lock of the original hugepage held.
- * Called with hugetlb_instantiation_mutex held and pte_page locked so we
- * cannot race with other handlers or page migration.
- * Keep the pte_same checks anyway to make transition from the mutex easier.
+ * Called with pte_page locked so we cannot race with page migration.
  */
 static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pte_t *ptep, pte_t pte,
@@ -2941,7 +2939,6 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	int ret;
 	struct page *page = NULL;
 	struct page *pagecache_page = NULL;
-	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
 	struct hstate *h = hstate_vma(vma);
 
 	address &= huge_page_mask(h);
@@ -2961,17 +2958,9 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!ptep)
 		return VM_FAULT_OOM;
 
-	/*
-	 * Serialize hugepage allocation and instantiation, so that we don't
-	 * get spurious allocation failures if two CPUs race to instantiate
-	 * the same page in the page cache.
-	 */
-	mutex_lock(&hugetlb_instantiation_mutex);
 	entry = huge_ptep_get(ptep);
-	if (huge_pte_none(entry)) {
-		ret = hugetlb_no_page(mm, vma, address, ptep, flags);
-		goto out_mutex;
-	}
+	if (huge_pte_none(entry))
+		return hugetlb_no_page(mm, vma, address, ptep, flags);
 
 	ret = 0;
 
@@ -2984,10 +2973,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * consumed.
 	 */
 	if ((flags & FAULT_FLAG_WRITE) && !huge_pte_write(entry)) {
-		if (vma_needs_reservation(h, vma, address) < 0) {
-			ret = VM_FAULT_OOM;
-			goto out_mutex;
-		}
+		if (vma_needs_reservation(h, vma, address) < 0)
+			return VM_FAULT_OOM;
 
 		if (!(vma->vm_flags & VM_MAYSHARE))
 			pagecache_page = hugetlbfs_pagecache_page(h,
@@ -3037,9 +3024,6 @@ out_ptl:
 		unlock_page(page);
 	put_page(page);
 
-out_mutex:
-	mutex_unlock(&hugetlb_instantiation_mutex);
-
 	return ret;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
