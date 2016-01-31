Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 50C1F6B0005
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 07:13:27 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id yy13so66137709pab.3
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 04:13:27 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id dg7si16546795pad.75.2016.01.31.04.13.26
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 04:13:26 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH] mm: Use linear_page_index() in do_fault()
Date: Sun, 31 Jan 2016 23:13:21 +1100
Message-Id: <1454242401-17005-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

do_fault assumes that PAGE_SIZE is the same as PAGE_CACHE_SIZE.
Use linear_page_index() to calculate pgoff in the correct units.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 mm/memory.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 554816b..5224c06 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3161,8 +3161,7 @@ static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		unsigned int flags, pte_t orig_pte)
 {
-	pgoff_t pgoff = (((address & PAGE_MASK)
-			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+	pgoff_t pgoff = linear_page_index(vma, address);
 
 	pte_unmap(page_table);
 	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
