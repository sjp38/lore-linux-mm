Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA486B0081
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:21 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so866303pdj.40
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:21 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id k1si3243625pdj.98.2014.11.05.06.50.07
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:07 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 01/19] mm, thp: drop FOLL_SPLIT
Date: Wed,  5 Nov 2014 16:49:36 +0200
Message-Id: <1415198994-15252-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index 19daa53a3da4..a43f4d33f376 100644
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
index c9f866760df8..98c11c5be0ad 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1985,7 +1985,6 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
 #define FOLL_NOWAIT	0x20	/* if a disk transfer is needed, start the IO
 				 * and return without waiting upon it */
 #define FOLL_MLOCK	0x40	/* mark page as mlocked */
-#define FOLL_SPLIT	0x80	/* don't return transhuge pages, split them */
 #define FOLL_HWPOISON	0x100	/* check page is hwpoisoned */
 #define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
 #define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
diff --git a/mm/gup.c b/mm/gup.c
index 91d044b1600d..03f34c417591 100644
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
index f78ec9bd454d..ad4694515f31 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1236,7 +1236,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		if (!vma || pp->addr < vma->vm_start || !vma_migratable(vma))
 			goto set_status;
 
-		page = follow_page(vma, pp->addr, FOLL_GET|FOLL_SPLIT);
+		page = follow_page(vma, pp->addr, FOLL_GET);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
@@ -1246,6 +1246,11 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
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
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
