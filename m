Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 03A0A6B009D
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 12:04:45 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v10so4938227pde.4
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 09:04:45 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id zc3si31175492pbc.176.2014.06.09.09.04.44
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 09:04:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 01/10] mm, thp: drop FOLL_SPLIT
Date: Mon,  9 Jun 2014 19:04:12 +0300
Message-Id: <1402329861-7037-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

FOLL_SPLIT is used only in two places: migration and s390.

Let's replace it with explicit split and remove FOLL_SPLIT.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/transhuge.txt | 11 -----------
 arch/s390/mm/pgtable.c         | 17 +++++++++++------
 include/linux/mm.h             |  1 -
 mm/gup.c                       |  4 ----
 mm/migrate.c                   |  7 ++++++-
 5 files changed, 17 insertions(+), 23 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 6b31cfbe2a9a..df1794a9071f 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -263,17 +263,6 @@ same constrains that applies to hugetlbfs too, so any driver capable
 of handling GUP on hugetlbfs will also work fine on transparent
 hugepage backed mappings.
 
-In case you can't handle compound pages if they're returned by
-follow_page, the FOLL_SPLIT bit can be specified as parameter to
-follow_page, so that it will split the hugepages before returning
-them. Migration for example passes FOLL_SPLIT as parameter to
-follow_page because it's not hugepage aware and in fact it can't work
-at all on hugetlbfs (but it instead works fine on transparent
-hugepages thanks to FOLL_SPLIT). migration simply can't deal with
-hugepages being returned (as it's not only checking the pfn of the
-page and pinning it during the copy but it pretends to migrate the
-memory in regular page sizes and with regular pte/pmd mappings).
-
 == Optimizing the applications ==
 
 To be guaranteed that the kernel will map a 2M page immediately in any
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 37b8241ec784..a5643b9c0d03 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -1248,20 +1248,25 @@ void tlb_remove_table(struct mmu_gather *tlb, void *table)
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static inline void thp_split_vma(struct vm_area_struct *vma)
+static int thp_split_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
+		struct mm_walk *walk)
 {
-	unsigned long addr;
-
-	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE)
-		follow_page(vma, addr, FOLL_SPLIT);
+	struct vm_area_struct *vma = walk->vma;
+	split_huge_page_pmd(vma, addr, pmd);
+	return 0;
 }
 
 static inline void thp_split_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 
+	struct mm_walk thp_split_walk = {
+		.mm = mm,
+		.pmd_entry = thp_split_pmd,
+
+	};
 	for (vma = mm->mmap; vma != NULL; vma = vma->vm_next) {
-		thp_split_vma(vma);
+		walk_page_vma(vma, &thp_split_walk);
 		vma->vm_flags &= ~VM_HUGEPAGE;
 		vma->vm_flags |= VM_NOHUGEPAGE;
 	}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5ac1cea7750b..9f4960bf505b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1993,7 +1993,6 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
 #define FOLL_NOWAIT	0x20	/* if a disk transfer is needed, start the IO
 				 * and return without waiting upon it */
 #define FOLL_MLOCK	0x40	/* mark page as mlocked */
-#define FOLL_SPLIT	0x80	/* don't return transhuge pages, split them */
 #define FOLL_HWPOISON	0x100	/* check page is hwpoisoned */
 #define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
 #define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
diff --git a/mm/gup.c b/mm/gup.c
index cc5a9e7adea7..ac01800abce6 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -192,10 +192,6 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
 		return no_page_table(vma, flags);
 	if (pmd_trans_huge(*pmd)) {
-		if (flags & FOLL_SPLIT) {
-			split_huge_page_pmd(vma, address, pmd);
-			return follow_page_pte(vma, address, pmd, flags);
-		}
 		ptl = pmd_lock(mm, pmd);
 		if (likely(pmd_trans_huge(*pmd))) {
 			if (unlikely(pmd_trans_splitting(*pmd))) {
diff --git a/mm/migrate.c b/mm/migrate.c
index 63f0cd559999..82c0ba922481 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1243,7 +1243,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		if (!vma || pp->addr < vma->vm_start || !vma_migratable(vma))
 			goto set_status;
 
-		page = follow_page(vma, pp->addr, FOLL_GET|FOLL_SPLIT);
+		page = follow_page(vma, pp->addr, FOLL_GET);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
@@ -1253,6 +1253,11 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		if (!page)
 			goto set_status;
 
+		if (PageTransHuge(page) && split_huge_page(page)) {
+			err = -EBUSY;
+			goto set_status;
+		}
+
 		/* Use PageReserved to check for zero page */
 		if (PageReserved(page))
 			goto put_and_set;
-- 
2.0.0.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
