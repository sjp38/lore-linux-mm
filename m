Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id E01196B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 07:48:58 -0500 (EST)
Received: by ykek133 with SMTP id k133so69547529yke.2
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 04:48:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 71si744813vkc.117.2015.11.04.04.48.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 04:48:58 -0800 (PST)
From: Aaron Tomlin <atomlin@redhat.com>
Subject: [RESEND PATCH v2] thp: Remove unused vma parameter from khugepaged_alloc_page
Date: Wed,  4 Nov 2015 12:48:55 +0000
Message-Id: <1446641335-5603-1-git-send-email-atomlin@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, lwoodman@redhat.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, vbabka@suse.cz, willy@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, atomlin@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Resending due to incomplete subject.

Changes since v2:

 - Fixed incorrect commit message

The "vma" parameter to khugepaged_alloc_page() is unused.
It has to remain unused or the drop read lock 'map_sem' optimisation
introduce by commit 8b1645685acf ("mm, THP: don't hold mmap_sem in
khugepaged when allocating THP") wouldn't be safe. So let's remove it.

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
