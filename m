Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 023B56B006C
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:48:37 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so8593112wib.17
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:48:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ex4si3680185wjd.141.2014.06.12.14.48.35
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 14:48:36 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v2 06/11] pagewalk: add size to struct mm_walk
Date: Thu, 12 Jun 2014 17:48:06 -0400
Message-Id: <1402609691-13950-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

This variable is helpful if we try to share the callback function between
multiple slots (for example between pte_entry() and pmd_entry()) as done
in later patches.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/mm.h | 2 ++
 mm/pagewalk.c      | 5 +++++
 2 files changed, 7 insertions(+)

diff --git mmotm-2014-05-21-16-57.orig/include/linux/mm.h mmotm-2014-05-21-16-57/include/linux/mm.h
index 0a20674c84e2..cbe17d9cbd7f 100644
--- mmotm-2014-05-21-16-57.orig/include/linux/mm.h
+++ mmotm-2014-05-21-16-57/include/linux/mm.h
@@ -1108,6 +1108,7 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  * @vma:       vma currently walked
  * @pmd:       current pmd entry
  * @ptl:       page table lock associated with current entry
+ * @size:      size of current entry
  * @private:   private data for callbacks' use
  *
  * (see the comment on walk_page_range() for more details)
@@ -1127,6 +1128,7 @@ struct mm_walk {
 	struct vm_area_struct *vma;
 	pmd_t *pmd;
 	spinlock_t *ptl;
+	long size;
 	void *private;
 };
 
diff --git mmotm-2014-05-21-16-57.orig/mm/pagewalk.c mmotm-2014-05-21-16-57/mm/pagewalk.c
index 61d6bd9545d6..b46c8882c643 100644
--- mmotm-2014-05-21-16-57.orig/mm/pagewalk.c
+++ mmotm-2014-05-21-16-57/mm/pagewalk.c
@@ -11,6 +11,7 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr,
 	pte_t *orig_pte;
 	int err = 0;
 
+	walk->size = PAGE_SIZE;
 	walk->pmd = pmd;
 	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &walk->ptl);
 	do {
@@ -42,6 +43,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr,
 	unsigned long next;
 	int err = 0;
 
+	walk->size = PMD_SIZE;
 	pmd = pmd_offset(pud, addr);
 	do {
 again:
@@ -97,6 +99,7 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr,
 	unsigned long next;
 	int err = 0;
 
+	walk->size = PUD_SIZE;
 	pud = pud_offset(pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
@@ -126,6 +129,7 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
 	unsigned long next;
 	int err = 0;
 
+	walk->size = PGDIR_SIZE;
 	pgd = pgd_offset(walk->mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -167,6 +171,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 	pte_t *pte;
 	int err = 0;
 
+	walk->size = huge_page_size(h);
 	do {
 		next = hugetlb_entry_end(h, addr, end);
 		pte = huge_pte_offset(walk->mm, addr & hmask);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
