Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1511C6B0037
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 16:21:43 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id vb8so11060630obc.39
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 13:21:42 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id q10si31795898oex.27.2014.07.01.13.21.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 13:21:41 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 2/2] mm,hugetlb: simplify error handling in hugetlb_cow()
Date: Tue,  1 Jul 2014 13:21:37 -0700
Message-Id: <1404246097-18810-2-git-send-email-davidlohr@hp.com>
In-Reply-To: <1404246097-18810-1-git-send-email-davidlohr@hp.com>
References: <1404246097-18810-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: davidlohr@hp.com, aswin@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When returning from hugetlb_cow(), we always (1) put back the refcount
for each referenced page -- always 'old', and 'new' if allocation was
successful. And (2) retake the page table lock right before returning,
as the callers expects. This logic can be simplified and encapsulated,
as proposed in this patch. In addition to cleaner code, we also shave
a few bytes off in instruction text:

   text    data     bss     dec     hex filename
  28399     462   41328   70189   1122d mm/hugetlb.o-baseline
  28367     462   41328   70157   1120d mm/hugetlb.o-patched

Passes libhugetlbfs testcases.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 mm/hugetlb.c | 35 ++++++++++++++++-------------------
 1 file changed, 16 insertions(+), 19 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3c4d535..172bc1d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2807,7 +2807,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct hstate *h = hstate_vma(vma);
 	struct page *old_page, *new_page;
-	int outside_reserve = 0;
+	int ret = 0, outside_reserve = 0;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
@@ -2837,14 +2837,14 @@ retry_avoidcopy:
 
 	page_cache_get(old_page);
 
-	/* Drop page table lock as buddy allocator may be called */
+	/* 
+	 * Drop page table lock as buddy allocator may be called. It will
+	 * be acquired again before returning to the caller, as expected.
+	 */
 	spin_unlock(ptl);
 	new_page = alloc_huge_page(vma, address, outside_reserve);
 
 	if (IS_ERR(new_page)) {
-		long err = PTR_ERR(new_page);
-		page_cache_release(old_page);
-
 		/*
 		 * If a process owning a MAP_PRIVATE mapping fails to COW,
 		 * it is due to references held by a child and an insufficient
@@ -2853,6 +2853,7 @@ retry_avoidcopy:
 		 * may get SIGKILLed if it later faults.
 		 */
 		if (outside_reserve) {
+			page_cache_release(old_page);
 			BUG_ON(huge_pte_none(pte));
 			unmap_ref_private(mm, vma, old_page, address);
 			BUG_ON(huge_pte_none(pte));
@@ -2868,12 +2869,9 @@ retry_avoidcopy:
 			return 0;
 		}
 
-		/* Caller expects lock to be held */
-		spin_lock(ptl);
-		if (err == -ENOMEM)
-			return VM_FAULT_OOM;
-		else
-			return VM_FAULT_SIGBUS;
+		ret = (PTR_ERR(new_page) == -ENOMEM) ?
+			VM_FAULT_OOM : VM_FAULT_SIGBUS;
+		goto out_release_old;
 	}
 
 	/*
@@ -2881,11 +2879,8 @@ retry_avoidcopy:
 	 * anon_vma prepared.
 	 */
 	if (unlikely(anon_vma_prepare(vma))) {
-		page_cache_release(new_page);
-		page_cache_release(old_page);
-		/* Caller expects lock to be held */
-		spin_lock(ptl);
-		return VM_FAULT_OOM;
+		ret = VM_FAULT_OOM;
+		goto out_release_all;
 	}
 
 	copy_user_huge_page(new_page, old_page, address, vma,
@@ -2895,6 +2890,7 @@ retry_avoidcopy:
 	mmun_start = address & huge_page_mask(h);
 	mmun_end = mmun_start + huge_page_size(h);
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+
 	/*
 	 * Retake the page table lock to check for racing updates
 	 * before the page tables are altered
@@ -2915,12 +2911,13 @@ retry_avoidcopy:
 	}
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+out_release_all:
 	page_cache_release(new_page);
+out_release_old:
 	page_cache_release(old_page);
 
-	/* Caller expects lock to be held */
-	spin_lock(ptl);
-	return 0;
+	spin_lock(ptl); /* Caller expects lock to be held */
+	return ret;
 }
 
 /* Return the pagecache page at a given address within a VMA */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
