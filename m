Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f54.google.com (mail-oa0-f54.google.com [209.85.219.54])
	by kanga.kvack.org (Postfix) with ESMTP id B91EF6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 16:21:42 -0400 (EDT)
Received: by mail-oa0-f54.google.com with SMTP id eb12so11125623oac.13
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 13:21:42 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id r10si31738550oep.103.2014.07.01.13.21.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 13:21:41 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 1/2] mm,hugetlb: make unmap_ref_private() return void
Date: Tue,  1 Jul 2014 13:21:36 -0700
Message-Id: <1404246097-18810-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: davidlohr@hp.com, aswin@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This function always returns 1, thus no need to check return value
in hugetlb_cow(). By doing so, we can get rid of the unnecessary WARN_ON
call. While this logic perhaps existed as a way of identifying future
unmap_ref_private() mishandling, reality is it serves no apparent purpose.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 mm/hugetlb.c | 32 ++++++++++++++------------------
 1 file changed, 14 insertions(+), 18 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2024bbd..3c4d535 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2753,8 +2753,8 @@ void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
  * from other VMAs and let the children be SIGKILLed if they are faulting the
  * same region.
  */
-static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
-				struct page *page, unsigned long address)
+static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
+			      struct page *page, unsigned long address)
 {
 	struct hstate *h = hstate_vma(vma);
 	struct vm_area_struct *iter_vma;
@@ -2793,8 +2793,6 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 					     address + huge_page_size(h), page);
 	}
 	mutex_unlock(&mapping->i_mmap_mutex);
-
-	return 1;
 }
 
 /*
@@ -2856,20 +2854,18 @@ retry_avoidcopy:
 		 */
 		if (outside_reserve) {
 			BUG_ON(huge_pte_none(pte));
-			if (unmap_ref_private(mm, vma, old_page, address)) {
-				BUG_ON(huge_pte_none(pte));
-				spin_lock(ptl);
-				ptep = huge_pte_offset(mm, address & huge_page_mask(h));
-				if (likely(ptep &&
-					   pte_same(huge_ptep_get(ptep), pte)))
-					goto retry_avoidcopy;
-				/*
-				 * race occurs while re-acquiring page table
-				 * lock, and our job is done.
-				 */
-				return 0;
-			}
-			WARN_ON_ONCE(1);
+			unmap_ref_private(mm, vma, old_page, address);
+			BUG_ON(huge_pte_none(pte));
+			spin_lock(ptl);
+			ptep = huge_pte_offset(mm, address & huge_page_mask(h));
+			if (likely(ptep &&
+				   pte_same(huge_ptep_get(ptep), pte)))
+				goto retry_avoidcopy;
+			/*
+			 * race occurs while re-acquiring page table
+			 * lock, and our job is done.
+			 */
+			return 0;
 		}
 
 		/* Caller expects lock to be held */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
