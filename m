Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 154FA82F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 06:52:00 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id e65so15257525pfe.1
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 03:52:00 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id y17si33421025pfa.150.2015.12.24.03.51.58
        for <linux-mm@kvack.org>;
        Thu, 24 Dec 2015 03:51:58 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/4] thp: fix regression in handling mlocked pages in __split_huge_pmd()
Date: Thu, 24 Dec 2015 14:51:21 +0300
Message-Id: <1450957883-96356-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

This patch fixes regression caused by patch
 "mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd"

The patch makes pmd_trans_huge() check and "page = pmd_page(*pmd)" after
__split_huge_pmd_locked(). It can never succeed, since the pmd already
points to a page table. As result the page is never get munlocked.

It causes crashes like this:
 http://lkml.kernel.org/r/5661FBB6.6050307@oracle.com

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/huge_memory.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 99f2a0ecb621..1a988d9b86ef 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3024,14 +3024,12 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)))
 		goto out;
-	__split_huge_pmd_locked(vma, pmd, haddr, false);
-
-	if (pmd_trans_huge(*pmd))
-		page = pmd_page(*pmd);
-	if (page && PageMlocked(page))
+	page = pmd_page(*pmd);
+	if (PageMlocked(page))
 		get_page(page);
 	else
 		page = NULL;
+	__split_huge_pmd_locked(vma, pmd, haddr, false);
 out:
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
