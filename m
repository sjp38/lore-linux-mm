Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAE786B02AD
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:50:06 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 71so92405088ioe.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:50:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w67si6177704ioe.190.2016.12.16.06.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:29 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 42/42] mm: mprotect: use pmd_trans_unstable instead of taking the pmd_lock
Date: Fri, 16 Dec 2016 15:48:21 +0100
Message-Id: <20161216144821.5183-43-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

pmd_trans_unstable does an atomic read on the pmd so it doesn't
require the pmd_lock for the same check.

This also removes the special assumption that the mmap_sem is hold for
writing if prot_numa is not set. userfaultfd will hold the mmap_sem
only for reading in change_pte_range like prot_numa, but it will not
set prot_numa.

This is always a valid micro-optimization regardless of userfaultfd.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mprotect.c | 44 +++++++++++++++-----------------------------
 1 file changed, 15 insertions(+), 29 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index cc2459c..98acf7d 100644
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
@@ -71,7 +43,21 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	unsigned long pages = 0;
 	int target_node = NUMA_NO_NODE;
 
-	pte = lock_pte_protection(vma, pmd, addr, prot_numa, &ptl);
+	/*
+	 * Can be called with only the mmap_sem for reading by
+	 * prot_numa so we must check the pmd isn't constantly
+	 * changing from under us from pmd_none to pmd_trans_huge
+	 * and/or the other way around.
+	 */
+	if (pmd_trans_unstable(pmd))
+		return 0;
+
+	/*
+	 * The pmd points to a regular pte so the pmd can't change
+	 * from under us even if the mmap_sem is only hold for
+	 * reading.
+	 */
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	if (!pte)
 		return 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
