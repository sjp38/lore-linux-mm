Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2184F82F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 13:09:05 -0400 (EDT)
Received: by qgbb65 with SMTP id b65so12032721qgb.2
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 10:09:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b39si12248520qkh.75.2015.10.28.10.09.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 10:09:04 -0700 (PDT)
From: Aaron Tomlin <atomlin@redhat.com>
Subject: [PATCH] thp: Remove unused vma parameter from khugepaged_alloc_page
Date: Wed, 28 Oct 2015 17:09:02 +0000
Message-Id: <1446052142-21935-1-git-send-email-atomlin@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, lwoodman@redhat.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, vbabka@suse.cz, willy@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, atomlin@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The "vma" parameter to khugepaged_alloc_page() is unused.
It has to remain unused or the drop read lock 'map_sem' optimisation
introduce by commit 8b1645685acf ("mm, THP: don't hold mmap_sem in
khugepaged when allocating THP") wouldn't be possible. So let's remove it.

Signed-off-by: Aaron Tomlin <atomlin@redhat.com>
---
 mm/huge_memory.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bbac913..490fa81 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2413,8 +2413,7 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 
 static struct page *
 khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
-		       struct vm_area_struct *vma, unsigned long address,
-		       int node)
+		       unsigned long address, int node)
 {
 	VM_BUG_ON_PAGE(*hpage, *hpage);
 
@@ -2481,8 +2480,7 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 
 static struct page *
 khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
-		       struct vm_area_struct *vma, unsigned long address,
-		       int node)
+		       unsigned long address, int node)
 {
 	up_read(&mm->mmap_sem);
 	VM_BUG_ON(!*hpage);
@@ -2530,7 +2528,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 		__GFP_THISNODE;
 
 	/* release the mmap_sem read lock. */
-	new_page = khugepaged_alloc_page(hpage, gfp, mm, vma, address, node);
+	new_page = khugepaged_alloc_page(hpage, gfp, mm, address, node);
 	if (!new_page)
 		return;
 
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
