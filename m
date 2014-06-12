Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id B31D66B003A
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:48:33 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id u57so1895671wes.19
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:48:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id bu8si3738236wjc.35.2014.06.12.14.48.30
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 14:48:31 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v2 01/11] pagewalk: remove pgd_entry() and pud_entry()
Date: Thu, 12 Jun 2014 17:48:01 -0400
Message-Id: <1402609691-13950-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
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

diff --git mmotm-2014-05-21-16-57.orig/include/linux/mm.h mmotm-2014-05-21-16-57/include/linux/mm.h
index 563c79ea07bd..b4aa6579f2b1 100644
--- mmotm-2014-05-21-16-57.orig/include/linux/mm.h
+++ mmotm-2014-05-21-16-57/include/linux/mm.h
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
diff --git mmotm-2014-05-21-16-57.orig/mm/pagewalk.c mmotm-2014-05-21-16-57/mm/pagewalk.c
index 2eda3dbe0b52..e734f63276c2 100644
--- mmotm-2014-05-21-16-57.orig/mm/pagewalk.c
+++ mmotm-2014-05-21-16-57/mm/pagewalk.c
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
