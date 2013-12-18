Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E9C226B003D
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 01:54:13 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id lj1so5538939pab.15
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 22:54:13 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ty3si13551493pbc.167.2013.12.17.22.54.08
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 22:54:10 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 08/14] mm, hugetlb: call vma_needs_reservation before entering alloc_huge_page()
Date: Wed, 18 Dec 2013 15:53:54 +0900
Message-Id: <1387349640-8071-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In order to validate that this failure is reasonable, we need to know
whether allocation request is for reserved or not on caller function.
So moving vma_needs_reservation() up to the caller of alloc_huge_page().
There is no functional change in this patch and following patch use
this information.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9927407..d960f46 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1177,13 +1177,11 @@ static void vma_commit_reservation(struct hstate *h,
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
-				    unsigned long addr, int avoid_reserve)
+				    unsigned long addr, int use_reserve)
 {
 	struct hugepage_subpool *spool = subpool_vma(vma);
 	struct hstate *h = hstate_vma(vma);
 	struct page *page;
-	long chg;
-	bool use_reserve;
 	int ret, idx;
 	struct hugetlb_cgroup *h_cg;
 
@@ -1196,10 +1194,6 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	 * need pages and subpool limit allocated allocated if no reserve
 	 * mapping overlaps.
 	 */
-	chg = vma_needs_reservation(h, vma, addr);
-	if (chg < 0)
-		return ERR_PTR(-ENOMEM);
-	use_reserve = (!chg && !avoid_reserve);
 	if (!use_reserve)
 		if (hugepage_subpool_get_pages(spool, 1))
 			return ERR_PTR(-ENOSPC);
@@ -1244,7 +1238,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
 				unsigned long addr, int avoid_reserve)
 {
-	struct page *page = alloc_huge_page(vma, addr, avoid_reserve);
+	struct page *page = alloc_huge_page(vma, addr, !avoid_reserve);
 	if (IS_ERR(page))
 		page = NULL;
 	return page;
@@ -2581,6 +2575,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct hstate *h = hstate_vma(vma);
 	struct page *old_page, *new_page;
 	int outside_reserve = 0;
+	long chg;
+	bool use_reserve;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
@@ -2612,7 +2608,17 @@ retry_avoidcopy:
 
 	/* Drop page table lock as buddy allocator may be called */
 	spin_unlock(ptl);
-	new_page = alloc_huge_page(vma, address, outside_reserve);
+	chg = vma_needs_reservation(h, vma, address);
+	if (chg < 0) {
+		page_cache_release(old_page);
+
+		/* Caller expects lock to be held */
+		spin_lock(ptl);
+		return VM_FAULT_OOM;
+	}
+	use_reserve = !chg && !outside_reserve;
+
+	new_page = alloc_huge_page(vma, address, use_reserve);
 
 	if (IS_ERR(new_page)) {
 		long err = PTR_ERR(new_page);
@@ -2742,6 +2748,8 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct address_space *mapping;
 	pte_t new_pte;
 	spinlock_t *ptl;
+	long chg;
+	bool use_reserve;
 
 	/*
 	 * Currently, we are forced to kill the process in the event the
@@ -2767,7 +2775,15 @@ retry:
 		size = i_size_read(mapping->host) >> huge_page_shift(h);
 		if (idx >= size)
 			goto out;
-		page = alloc_huge_page(vma, address, 0);
+
+		chg = vma_needs_reservation(h, vma, address);
+		if (chg == -ENOMEM) {
+			ret = VM_FAULT_OOM;
+			goto out;
+		}
+		use_reserve = !chg;
+
+		page = alloc_huge_page(vma, address, use_reserve);
 		if (IS_ERR(page)) {
 			ret = PTR_ERR(page);
 			if (ret == -ENOMEM)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
