Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 010196B0260
	for <linux-mm@kvack.org>; Mon, 30 May 2016 01:44:40 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id c127so418744428ywb.1
        for <linux-mm@kvack.org>; Sun, 29 May 2016 22:44:39 -0700 (PDT)
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com. [129.33.205.209])
        by mx.google.com with ESMTPS id q3si26853069qtd.97.2016.05.29.22.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 29 May 2016 22:44:39 -0700 (PDT)
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 30 May 2016 01:44:38 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 1/4] mm/hugetlb: Simplify hugetlb unmap
Date: Mon, 30 May 2016 11:14:19 +0530
Message-Id: <1464587062-17745-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

For hugetlb like THP (and unlike regular page), we do tlb flush after
dropping ptl. Because of the above, we don't need to track force_flush
like we do now. Instead we can simply call tlb_remove_page() which
will do the flush if needed.

No functionality change in this patch.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c | 54 +++++++++++++++++++++---------------------------------
 1 file changed, 21 insertions(+), 33 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e4168484f249..8dd91cd5571c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3138,7 +3138,6 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			    unsigned long start, unsigned long end,
 			    struct page *ref_page)
 {
-	int force_flush = 0;
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pte_t *ptep;
@@ -3157,19 +3156,22 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	tlb_start_vma(tlb, vma);
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	address = start;
-again:
 	for (; address < end; address += sz) {
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
 			continue;
 
 		ptl = huge_pte_lock(h, mm, ptep);
-		if (huge_pmd_unshare(mm, &address, ptep))
-			goto unlock;
+		if (huge_pmd_unshare(mm, &address, ptep)) {
+			spin_unlock(ptl);
+			continue;
+		}
 
 		pte = huge_ptep_get(ptep);
-		if (huge_pte_none(pte))
-			goto unlock;
+		if (huge_pte_none(pte)) {
+			spin_unlock(ptl);
+			continue;
+		}
 
 		/*
 		 * Migrating hugepage or HWPoisoned hugepage is already
@@ -3177,7 +3179,8 @@ again:
 		 */
 		if (unlikely(!pte_present(pte))) {
 			huge_pte_clear(mm, address, ptep);
-			goto unlock;
+			spin_unlock(ptl);
+			continue;
 		}
 
 		page = pte_page(pte);
@@ -3187,9 +3190,10 @@ again:
 		 * are about to unmap is the actual page of interest.
 		 */
 		if (ref_page) {
-			if (page != ref_page)
-				goto unlock;
-
+			if (page != ref_page) {
+				spin_unlock(ptl);
+				continue;
+			}
 			/*
 			 * Mark the VMA as having unmapped its page so that
 			 * future faults in this VMA will fail rather than
@@ -3205,30 +3209,14 @@ again:
 
 		hugetlb_count_sub(pages_per_huge_page(h), mm);
 		page_remove_rmap(page, true);
-		force_flush = !__tlb_remove_page(tlb, page);
-		if (force_flush) {
-			address += sz;
-			spin_unlock(ptl);
-			break;
-		}
-		/* Bail out after unmapping reference page if supplied */
-		if (ref_page) {
-			spin_unlock(ptl);
-			break;
-		}
-unlock:
+
 		spin_unlock(ptl);
-	}
-	/*
-	 * mmu_gather ran out of room to batch pages, we break out of
-	 * the PTE lock to avoid doing the potential expensive TLB invalidate
-	 * and page-free while holding it.
-	 */
-	if (force_flush) {
-		force_flush = 0;
-		tlb_flush_mmu(tlb);
-		if (address < end && !ref_page)
-			goto again;
+		tlb_remove_page(tlb, page);
+		/*
+		 * Bail out after unmapping reference page if supplied
+		 */
+		if (ref_page)
+			break;
 	}
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	tlb_end_vma(tlb, vma);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
