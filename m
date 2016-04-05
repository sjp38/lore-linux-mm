Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 08ADD6B0296
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:23:08 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id n1so18453758pfn.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:23:08 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id so10si10014606pab.173.2016.04.05.14.23.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:23:07 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id 184so18511719pff.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:23:07 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:23:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 08/31] huge tmpfs: try_to_unmap_one use
 page_check_address_transhuge
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051421260.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Anon THP's huge pages are split for reclaim in add_to_swap(), before they
reach try_to_unmap(); migrate_misplaced_transhuge_page() does its own pmd
remapping, instead of needing try_to_unmap(); migratable hugetlbfs pages
masquerade as pte-mapped in page_check_address().  So try_to_unmap_one()
did not need to handle transparent pmd mappings as page_referenced_one()
does (beyond the TTU_SPLIT_HUGE_PMD case; though what about TTU_MUNLOCK?).

But tmpfs huge pages are split a little later in the reclaim sequence,
when pageout() calls shmem_writepage(): so try_to_unmap_one() now needs
to handle pmd-mapped pages by using page_check_address_transhuge(), and
a function unmap_team_by_pmd() that we shall place in huge_memory.c in
a later patch, but just use a stub for now.

Refine the lookup in page_check_address_transhuge() slightly, to match
what mm_find_pmd() does, and we've been using for a year: take a pmdval
snapshot of *pmd first, to avoid pmd_lock before the pmd_page check,
with a retry if it changes in between.  Was the code wrong before?
I don't think it was, but I am more comfortable with how it is now.

Change its check on hpage_nr_pages() to use compound_order() instead,
two reasons for that: one being that there's now a case in anon THP
splitting where the new call to page_check_address_transhuge() may be on
a PageTail, which hits VM_BUG_ON in PageTransHuge in hpage_nr_pages();
the other being that hpage_nr_pages() on PageTeam gets more interesting
in a later patch, and would no longer be appropriate here.

Say "pmdval" as usual, instead of the "pmde" I made up for mm_find_pmd()
before.  Update the comment in mm_find_pmd() to generalise it away from
just the anon_vma lock.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/pageteam.h |    6 +++
 mm/rmap.c                |   65 +++++++++++++++++++++----------------
 2 files changed, 43 insertions(+), 28 deletions(-)

--- a/include/linux/pageteam.h
+++ b/include/linux/pageteam.h
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
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -47,6 +47,7 @@
 
 #include <linux/mm.h>
 #include <linux/pagemap.h>
+#include <linux/pageteam.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/slab.h>
@@ -687,7 +688,7 @@ pmd_t *mm_find_pmd(struct mm_struct *mm,
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd = NULL;
-	pmd_t pmde;
+	pmd_t pmdval;
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
@@ -700,12 +701,12 @@ pmd_t *mm_find_pmd(struct mm_struct *mm,
 	pmd = pmd_offset(pud, address);
 	/*
 	 * Some THP functions use the sequence pmdp_huge_clear_flush(), set_pmd_at()
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
@@ -800,6 +801,7 @@ bool page_check_address_transhuge(struct
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
+	pmd_t pmdval;
 	pte_t *pte;
 	spinlock_t *ptl;
 
@@ -821,32 +823,24 @@ bool page_check_address_transhuge(struct
 	if (!pud_present(*pud))
 		return false;
 	pmd = pmd_offset(pud, address);
+again:
+	pmdval = *pmd;
+	barrier();
+	if (!pmd_present(pmdval))
+		return false;
 
-	if (pmd_trans_huge(*pmd)) {
+	if (pmd_trans_huge(pmdval)) {
+		if (pmd_page(pmdval) != page)
+			return false;
 		ptl = pmd_lock(mm, pmd);
-		if (!pmd_present(*pmd))
-			goto unlock_pmd;
-		if (unlikely(!pmd_trans_huge(*pmd))) {
+		if (unlikely(!pmd_same(*pmd, pmdval))) {
 			spin_unlock(ptl);
-			goto map_pte;
+			goto again;
 		}
-
-		if (pmd_page(*pmd) != page)
-			goto unlock_pmd;
-
 		pte = NULL;
 		goto found;
-unlock_pmd:
-		spin_unlock(ptl);
-		return false;
-	} else {
-		pmd_t pmde = *pmd;
-
-		barrier();
-		if (!pmd_present(pmde) || pmd_trans_huge(pmde))
-			return false;
 	}
-map_pte:
+
 	pte = pte_offset_map(pmd, address);
 	if (!pte_present(*pte)) {
 		pte_unmap(pte);
@@ -863,7 +857,7 @@ check_pte:
 	}
 
 	/* THP can be referenced by any subpage */
-	if (pte_pfn(*pte) - page_to_pfn(page) >= hpage_nr_pages(page)) {
+	if (pte_pfn(*pte) - page_to_pfn(page) >= (1 << compound_order(page))) {
 		pte_unmap_unlock(pte, ptl);
 		return false;
 	}
@@ -1404,6 +1398,7 @@ static int try_to_unmap_one(struct page
 		     unsigned long address, void *arg)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	pmd_t *pmd;
 	pte_t *pte;
 	pte_t pteval;
 	spinlock_t *ptl;
@@ -1423,8 +1418,7 @@ static int try_to_unmap_one(struct page
 			goto out;
 	}
 
-	pte = page_check_address(page, mm, address, &ptl, 0);
-	if (!pte)
+	if (!page_check_address_transhuge(page, mm, address, &pmd, &pte, &ptl))
 		goto out;
 
 	/*
@@ -1442,6 +1436,19 @@ static int try_to_unmap_one(struct page
 		if (flags & TTU_MUNLOCK)
 			goto out_unmap;
 	}
+
+	if (!pte) {
+		if (!(flags & TTU_IGNORE_ACCESS) &&
+		    IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
+		    pmdp_clear_flush_young_notify(vma, address, pmd)) {
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
+		spin_unlock(ptl);
+		unmap_team_by_pmd(vma, address, pmd, page);
+		goto out;
+	}
+
 	if (!(flags & TTU_IGNORE_ACCESS)) {
 		if (ptep_clear_flush_young_notify(vma, address, pte)) {
 			ret = SWAP_FAIL;
@@ -1542,7 +1549,9 @@ discard:
 	put_page(page);
 
 out_unmap:
-	pte_unmap_unlock(pte, ptl);
+	spin_unlock(ptl);
+	if (pte)
+		pte_unmap(pte);
 	if (ret != SWAP_FAIL && ret != SWAP_MLOCK && !(flags & TTU_MUNLOCK))
 		mmu_notifier_invalidate_page(mm, address);
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
