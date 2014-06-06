Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF526B0087
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 18:58:58 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id 63so5825518qgz.2
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 15:58:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a3si15323610qaa.35.2014.06.06.15.58.57
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 15:58:57 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/7] mm/pagewalk: remove pgd_entry() and pud_entry()
Date: Fri,  6 Jun 2014 18:58:34 -0400
Message-Id: <1402095520-10109-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

Currently no user of page table walker sets ->pgd_entry() or ->pud_entry(),
so checking their existence in each loop is just wasting CPU cycle.
So let's remove it to reduce overhead.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/mm.h |  6 ------
 mm/pagewalk.c      | 18 +-----------------
 2 files changed, 1 insertion(+), 23 deletions(-)

diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/include/linux/mm.h v3.15-rc8-mmots-2014-06-03-16-28/include/linux/mm.h
index 563c79ea07bd..b4aa6579f2b1 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/include/linux/mm.h
+++ v3.15-rc8-mmots-2014-06-03-16-28/include/linux/mm.h
@@ -1092,8 +1092,6 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 
 /**
  * mm_walk - callbacks for walk_page_range
- * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
- * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
  * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
  *	       this handler is required to be able to handle
  *	       pmd_trans_huge() pmds.  They may simply choose to
@@ -1115,10 +1113,6 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  * (see the comment on walk_page_range() for more details)
  */
 struct mm_walk {
-	int (*pgd_entry)(pgd_t *pgd, unsigned long addr,
-			 unsigned long next, struct mm_walk *walk);
-	int (*pud_entry)(pud_t *pud, unsigned long addr,
-	                 unsigned long next, struct mm_walk *walk);
 	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pte_entry)(pte_t *pte, unsigned long addr,
diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/pagewalk.c v3.15-rc8-mmots-2014-06-03-16-28/mm/pagewalk.c
index b2a075ffb96e..15c7585e8684 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/pagewalk.c
+++ v3.15-rc8-mmots-2014-06-03-16-28/mm/pagewalk.c
@@ -115,14 +115,6 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr,
 			continue;
 		}
 
-		if (walk->pud_entry) {
-			err = walk->pud_entry(pud, addr, next, walk);
-			if (skip_lower_level_walking(walk))
-				continue;
-			if (err)
-				break;
-		}
-
 		if (walk->pmd_entry || walk->pte_entry) {
 			err = walk_pmd_range(pud, addr, next, walk);
 			if (err)
@@ -152,15 +144,7 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
 			continue;
 		}
 
-		if (walk->pgd_entry) {
-			err = walk->pgd_entry(pgd, addr, next, walk);
-			if (skip_lower_level_walking(walk))
-				continue;
-			if (err)
-				break;
-		}
-
-		if (walk->pud_entry || walk->pmd_entry || walk->pte_entry) {
+		if (walk->pmd_entry || walk->pte_entry) {
 			err = walk_pud_range(pgd, addr, next, walk);
 			if (err)
 				break;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
