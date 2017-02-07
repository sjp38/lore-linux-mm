Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4796B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 09:34:58 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f144so150604481pfa.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 06:34:58 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id s5si4226746pgh.144.2017.02.07.06.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 06:34:57 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mprotect: drop overprotective lock_pte_protection()
Date: Tue,  7 Feb 2017 17:33:47 +0300
Message-Id: <20170207143347.123871-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

lock_pte_protection() uses pmd_lock() to make sure that we have stable
PTE page table before walking pte range.

That's not necessary. We only need to make sure that PTE page table is
established. It cannot vanish under us as long as we hold mmap_sem at
least for read.

And we already have helper for that -- pmd_trans_unstable().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mprotect.c | 43 ++++++++++++-------------------------------
 1 file changed, 12 insertions(+), 31 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index f9c07f54dd62..e919e4613eab 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -33,34 +33,6 @@
 
 #include "internal.h"
 
-/*
- * For a prot_numa update we only hold mmap_sem for read so there is a
- * potential race with faulting where a pmd was temporarily none. This
- * function checks for a transhuge pmd under the appropriate lock. It
- * returns a pte if it was successfully locked or NULL if it raced with
- * a transhuge insertion.
- */
-static pte_t *lock_pte_protection(struct vm_area_struct *vma, pmd_t *pmd,
-			unsigned long addr, int prot_numa, spinlock_t **ptl)
-{
-	pte_t *pte;
-	spinlock_t *pmdl;
-
-	/* !prot_numa is protected by mmap_sem held for write */
-	if (!prot_numa)
-		return pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);
-
-	pmdl = pmd_lock(vma->vm_mm, pmd);
-	if (unlikely(pmd_trans_huge(*pmd) || pmd_none(*pmd))) {
-		spin_unlock(pmdl);
-		return NULL;
-	}
-
-	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);
-	spin_unlock(pmdl);
-	return pte;
-}
-
 static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable, int prot_numa)
@@ -71,7 +43,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	unsigned long pages = 0;
 	int target_node = NUMA_NO_NODE;
 
-	pte = lock_pte_protection(vma, pmd, addr, prot_numa, &ptl);
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	if (!pte)
 		return 0;
 
@@ -177,8 +149,6 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
 				__split_huge_pmd(vma, pmd, addr, false, NULL);
-				if (pmd_trans_unstable(pmd))
-					continue;
 			} else {
 				int nr_ptes = change_huge_pmd(vma, pmd, addr,
 						newprot, prot_numa);
@@ -195,6 +165,17 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 			}
 			/* fall through, the trans huge pmd just split */
 		}
+
+		/*
+		 * For prot_numa update we only hold mmap_sem for read so there
+		 * is a potential race with faulting where a pmd was
+		 * temporarily none.
+		 * Make sure we have PTE page table, before moving forward.
+		 * Page tables cannot go away under us as long as we hold
+		 * mmap_sem at least for read.
+		 */
+		if (pmd_trans_unstable(pmd))
+			continue;
 		this_pages = change_pte_range(vma, pmd, addr, next, newprot,
 				 dirty_accountable, prot_numa);
 		pages += this_pages;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
