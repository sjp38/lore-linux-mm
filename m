Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id E7E406B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 10:58:21 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id q63so14957666pfb.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 07:58:21 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 26si5727860pfj.93.2016.02.24.07.58.21
        for <linux-mm@kvack.org>;
        Wed, 24 Feb 2016 07:58:21 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: call pmdp_invalidate() with correct virtual address
Date: Wed, 24 Feb 2016 18:58:03 +0300
Message-Id: <1456329483-4220-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Will Deacon <will.deacon@arm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Sebastian Ott and Gerald Schaefer reported random crashes on s390.
It was bisected to my THP refcounting patchset.

The problem is that pmdp_invalidated() called with wrong virtual
address. It got offset up by HPAGE_PMD_SIZE by loop over ptes.

The solution is to introduce new variable to be used in loop and don't
touch 'haddr'.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Reported-by Sebastian Ott <sebott@linux.vnet.ibm.com>
---
 mm/huge_memory.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1c317b85ea7d..e10a4fee88d2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2836,6 +2836,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	pgtable_t pgtable;
 	pmd_t _pmd;
 	bool young, write, dirty;
+	unsigned long addr;
 	int i;
 
 	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
@@ -2865,7 +2866,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmd_populate(mm, &_pmd, pgtable);
 
-	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
 		pte_t entry, *pte;
 		/*
 		 * Note that NUMA hinting access restrictions are not
@@ -2886,9 +2887,9 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		}
 		if (dirty)
 			SetPageDirty(page + i);
-		pte = pte_offset_map(&_pmd, haddr);
+		pte = pte_offset_map(&_pmd, addr);
 		BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, haddr, pte, entry);
+		set_pte_at(mm, addr, pte, entry);
 		atomic_inc(&page[i]._mapcount);
 		pte_unmap(pte);
 	}
@@ -2938,7 +2939,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	pmd_populate(mm, pmd, pgtable);
 
 	if (freeze) {
-		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+		for (i = 0; i < HPAGE_PMD_NR; i++) {
 			page_remove_rmap(page + i, false);
 			put_page(page + i);
 		}
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
