Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id BE7456B006E
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:15:07 -0500 (EST)
Received: by padhz1 with SMTP id hz1so12862656pad.9
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:15:07 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id pu5si2094514pdb.218.2015.02.20.20.15.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:15:06 -0800 (PST)
Received: by pdbnh10 with SMTP id nh10so12021584pdb.11
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:15:06 -0800 (PST)
Date: Fri, 20 Feb 2015 20:15:04 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 15/24] huge tmpfs: rework page_referenced_one and
 try_to_unmap_one
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202013470.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

page_referenced_one() currently decides whether to go the huge
pmd route or the small pte route by looking at PageTransHuge(page).
But with huge tmpfs pages simultaneously mappable as small and as huge,
it's not deducible from page flags which is the case.  And the "helpers"
page_check_address, page_check_address_pmd, mm_find_pmd are designed to
hide the information we need now, instead of helping.

Open code (as it once was) with pgd,pud,pmd,pte: get *pmd speculatively,
and if it appears pmd_trans_huge, then acquire pmd_lock and recheck.
The same code is then valid for anon THP and for huge tmpfs, without
any page flag test.

Copy from this template in try_to_unmap_one(), to prepare for its
use on huge tmpfs pages (whereas anon THPs have already been split in
add_to_swap() before getting here); with a stub for unmap_team_by_pmd()
until a later patch implements it.  But unlike page_referenced_one(),
here we must allow for hugetlbfs pages (including non-pmd-based ones),
so must still use huge_pte_offset instead of pmd_trans_huge for those.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/pageteam.h |    6 +
 mm/rmap.c                |  158 +++++++++++++++++++++++++++++--------
 2 files changed, 133 insertions(+), 31 deletions(-)

--- thpfs.orig/include/linux/pageteam.h	2015-02-20 19:34:06.224004747 -0800
+++ thpfs/include/linux/pageteam.h	2015-02-20 19:34:37.851932430 -0800
@@ -29,4 +29,10 @@ static inline struct page *team_head(str
 	return head;
 }
 
+/* Temporary stub for mm/rmap.c until implemented in mm/huge_memory.c */
+static inline void unmap_team_by_pmd(struct vm_area_struct *vma,
+			unsigned long addr, pmd_t *pmd, struct page *page)
+{
+}
+
 #endif /* _LINUX_PAGETEAM_H */
--- thpfs.orig/mm/rmap.c	2015-02-20 19:33:51.496038422 -0800
+++ thpfs/mm/rmap.c	2015-02-20 19:34:37.851932430 -0800
@@ -44,6 +44,7 @@
 
 #include <linux/mm.h>
 #include <linux/pagemap.h>
+#include <linux/pageteam.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/slab.h>
@@ -607,7 +608,7 @@ pmd_t *mm_find_pmd(struct mm_struct *mm,
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd = NULL;
-	pmd_t pmde;
+	pmd_t pmdval;
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
@@ -620,12 +621,12 @@ pmd_t *mm_find_pmd(struct mm_struct *mm,
 	pmd = pmd_offset(pud, address);
 	/*
 	 * Some THP functions use the sequence pmdp_clear_flush(), set_pmd_at()
-	 * without holding anon_vma lock for write.  So when looking for a
-	 * genuine pmde (in which to find pte), test present and !THP together.
+	 * without locking out concurrent rmap lookups.  So when looking for a
+	 * pmd entry, in which to find a pte, test present and !THP together.
 	 */
-	pmde = *pmd;
+	pmdval = *pmd;
 	barrier();
-	if (!pmd_present(pmde) || pmd_trans_huge(pmde))
+	if (!pmd_present(pmdval) || pmd_trans_huge(pmdval))
 		pmd = NULL;
 out:
 	return pmd;
@@ -718,22 +719,41 @@ static int page_referenced_one(struct pa
 			unsigned long address, void *arg)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pmd_t pmdval;
+	pte_t *pte;
 	spinlock_t *ptl;
 	int referenced = 0;
 	struct page_referenced_arg *pra = arg;
 
-	if (unlikely(PageTransHuge(page))) {
-		pmd_t *pmd;
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		return SWAP_AGAIN;
 
-		/*
-		 * rmap might return false positives; we must filter
-		 * these out using page_check_address_pmd().
-		 */
-		pmd = page_check_address_pmd(page, mm, address,
-					     PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
-		if (!pmd)
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		return SWAP_AGAIN;
+
+	pmd = pmd_offset(pud, address);
+again:
+	/* See comment in mm_find_pmd() for why we use pmdval+barrier here */
+	pmdval = *pmd;
+	barrier();
+	if (!pmd_present(pmdval))
+		return SWAP_AGAIN;
+
+	if (pmd_trans_huge(pmdval)) {
+		if (pmd_page(pmdval) != page)
 			return SWAP_AGAIN;
 
+		ptl = pmd_lock(mm, pmd);
+		if (!pmd_same(*pmd, pmdval)) {
+			spin_unlock(ptl);
+			goto again;
+		}
+
 		if (vma->vm_flags & VM_LOCKED) {
 			spin_unlock(ptl);
 			pra->vm_flags |= VM_LOCKED;
@@ -745,15 +765,22 @@ static int page_referenced_one(struct pa
 			referenced++;
 		spin_unlock(ptl);
 	} else {
-		pte_t *pte;
+		pte = pte_offset_map(pmd, address);
 
-		/*
-		 * rmap might return false positives; we must filter
-		 * these out using page_check_address().
-		 */
-		pte = page_check_address(page, mm, address, &ptl, 0);
-		if (!pte)
+		/* Make a quick check before getting the lock */
+		if (!pte_present(*pte)) {
+			pte_unmap(pte);
 			return SWAP_AGAIN;
+		}
+
+		ptl = pte_lockptr(mm, pmd);
+		spin_lock(ptl);
+
+		if (!pte_present(*pte) ||
+		    page_to_pfn(page) != pte_pfn(*pte)) {
+			pte_unmap_unlock(pte, ptl);
+			return SWAP_AGAIN;
+		}
 
 		if (vma->vm_flags & VM_LOCKED) {
 			pte_unmap_unlock(pte, ptl);
@@ -1179,15 +1206,84 @@ static int try_to_unmap_one(struct page
 		     unsigned long address, void *arg)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	pte_t *pte;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pmd_t pmdval;
+	pte_t *pte = NULL;
 	pte_t pteval;
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
 	enum ttu_flags flags = (enum ttu_flags)arg;
 
-	pte = page_check_address(page, mm, address, &ptl, 0);
-	if (!pte)
-		goto out;
+	if (unlikely(PageHuge(page))) {
+		pte = huge_pte_offset(mm, address);
+		if (!pte)
+			return ret;
+		ptl = huge_pte_lockptr(page_hstate(page), mm, pte);
+		goto check;
+	}
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		return ret;
+
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		return ret;
+
+	pmd = pmd_offset(pud, address);
+again:
+	/* See comment in mm_find_pmd() for why we use pmdval+barrier here */
+	pmdval = *pmd;
+	barrier();
+	if (!pmd_present(pmdval))
+		return ret;
+
+	if (pmd_trans_huge(pmdval)) {
+		if (pmd_page(pmdval) != page)
+			return ret;
+
+		ptl = pmd_lock(mm, pmd);
+		if (!pmd_same(*pmd, pmdval)) {
+			spin_unlock(ptl);
+			goto again;
+		}
+
+		if (!(flags & TTU_IGNORE_MLOCK)) {
+			if (vma->vm_flags & VM_LOCKED)
+				goto out_mlock;
+			if (flags & TTU_MUNLOCK)
+				goto out_unmap;
+		}
+		if (!(flags & TTU_IGNORE_ACCESS) &&
+		    pmdp_clear_flush_young_notify(vma, address, pmd)) {
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
+
+		spin_unlock(ptl);
+		unmap_team_by_pmd(vma, address, pmd, page);
+		return ret;
+	}
+
+	pte = pte_offset_map(pmd, address);
+
+	/* Make a quick check before getting the lock */
+	if (!pte_present(*pte)) {
+		pte_unmap(pte);
+		return ret;
+	}
+
+	ptl = pte_lockptr(mm, pmd);
+check:
+	spin_lock(ptl);
+
+	if (!pte_present(*pte) ||
+	    page_to_pfn(page) != pte_pfn(*pte)) {
+		pte_unmap_unlock(pte, ptl);
+		return ret;
+	}
 
 	/*
 	 * If the page is mlock()d, we cannot swap it out.
@@ -1197,7 +1293,6 @@ static int try_to_unmap_one(struct page
 	if (!(flags & TTU_IGNORE_MLOCK)) {
 		if (vma->vm_flags & VM_LOCKED)
 			goto out_mlock;
-
 		if (flags & TTU_MUNLOCK)
 			goto out_unmap;
 	}
@@ -1287,16 +1382,17 @@ static int try_to_unmap_one(struct page
 	page_cache_release(page);
 
 out_unmap:
-	pte_unmap_unlock(pte, ptl);
+	spin_unlock(ptl);
+	if (pte)
+		pte_unmap(pte);
 	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
 		mmu_notifier_invalidate_page(mm, address);
-out:
 	return ret;
 
 out_mlock:
-	pte_unmap_unlock(pte, ptl);
-
-
+	spin_unlock(ptl);
+	if (pte)
+		pte_unmap(pte);
 	/*
 	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
 	 * unstable result and race. Plus, We can't wait here because

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
