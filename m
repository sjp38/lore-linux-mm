Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E81CC828DF
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 07:22:46 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id x125so68111420pfb.0
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 04:22:46 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id rt5si16561416pab.98.2016.01.31.04.22.46
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 04:22:46 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH] mm: Fix(?) memory leak in copy_huge_pmd()
Date: Sun, 31 Jan 2016 23:22:09 +1100
Message-Id: <1454242929-18164-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

We allocate a pgtable but do not attach it to anything if the PMD is in
a DAX VMA, causing it to leak.

We certainly try to not free pgtables associated with the huge zero page
if the zero page is in a DAX VMA, so I think this is the right solution.
This needs to be properly audited.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 mm/huge_memory.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4b9f2cb..1632e02 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -889,7 +889,8 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 		return false;
 	entry = mk_pmd(zero_page, vma->vm_page_prot);
 	entry = pmd_mkhuge(entry);
-	pgtable_trans_huge_deposit(mm, pmd, pgtable);
+	if (pgtable)
+		pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, haddr, pmd, entry);
 	atomic_long_inc(&mm->nr_ptes);
 	return true;
@@ -1176,13 +1177,15 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	spinlock_t *dst_ptl, *src_ptl;
 	struct page *src_page;
 	pmd_t pmd;
-	pgtable_t pgtable;
+	pgtable_t pgtable = NULL;
 	int ret;
 
-	ret = -ENOMEM;
-	pgtable = pte_alloc_one(dst_mm, addr);
-	if (unlikely(!pgtable))
-		goto out;
+	if (!vma_is_dax(vma)) {
+		ret = -ENOMEM;
+		pgtable = pte_alloc_one(dst_mm, addr);
+		if (unlikely(!pgtable))
+			goto out;
+	}
 
 	dst_ptl = pmd_lock(dst_mm, dst_pmd);
 	src_ptl = pmd_lockptr(src_mm, src_pmd);
@@ -1213,7 +1216,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		goto out_unlock;
 	}
 
-	if (pmd_trans_huge(pmd)) {
+	if (!vma_is_dax(vma)) {
 		/* thp accounting separate from pmd_devmap accounting */
 		src_page = pmd_page(pmd);
 		VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
