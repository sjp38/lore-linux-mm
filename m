Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCDB6B01C0
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 10:36:22 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/5] mincore: break do_mincore() into logical pieces
Date: Tue, 23 Mar 2010 15:34:59 +0100
Message-Id: <1269354902-18975-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1269354902-18975-1-git-send-email-hannes@cmpxchg.org>
References: <1269354902-18975-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Split out functions to handle hugetlb ranges, pte ranges and unmapped
ranges, to improve readability but also to prepare the file structure
for nested page table walks.

No semantic changes intended.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/mincore.c |  171 +++++++++++++++++++++++++++++++++-------------------------
 1 files changed, 97 insertions(+), 74 deletions(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index c35f8f0..ba80bb8 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -19,6 +19,42 @@
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 
+static void mincore_hugetlb_page_range(struct vm_area_struct *vma,
+				unsigned long addr, unsigned long nr,
+				unsigned char *vec)
+{
+#ifdef CONFIG_HUGETLB_PAGE
+	struct hstate *h;
+	int i;
+
+	i = 0;
+	h = hstate_vma(vma);
+	while (1) {
+		unsigned char present;
+		pte_t *ptep;
+		/*
+		 * Huge pages are always in RAM for now, but
+		 * theoretically it needs to be checked.
+		 */
+		ptep = huge_pte_offset(current->mm,
+				       addr & huge_page_mask(h));
+		present = ptep && !huge_pte_none(huge_ptep_get(ptep));
+		while (1) {
+			vec[i++] = present;
+			addr += PAGE_SIZE;
+			/* reach buffer limit */
+			if (i == nr)
+				return;
+			/* check hugepage border */
+			if (!(addr & ~huge_page_mask(h)))
+				break;
+		}
+	}
+#else
+	BUG();
+#endif
+}
+
 /*
  * Later we can get more picky about what "in core" means precisely.
  * For now, simply check to see if the page is in the page cache,
@@ -49,6 +85,64 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 	return present;
 }
 
+static void mincore_unmapped_range(struct vm_area_struct *vma,
+				unsigned long addr, unsigned long nr,
+				unsigned char *vec)
+{
+	int i;
+
+	if (vma->vm_file) {
+		pgoff_t pgoff;
+
+		pgoff = linear_page_index(vma, addr);
+		for (i = 0; i < nr; i++, pgoff++)
+			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
+	} else {
+		for (i = 0; i < nr; i++)
+			vec[i] = 0;
+	}
+}
+
+static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+			unsigned long addr, unsigned long nr,
+			unsigned char *vec)
+{
+	spinlock_t *ptl;
+	pte_t *ptep;
+	int i;
+
+	ptep = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	for (i = 0; i < nr; i++, ptep++, addr += PAGE_SIZE) {
+		pte_t pte = *ptep;
+		pgoff_t pgoff;
+
+		if (pte_none(pte))
+			mincore_unmapped_range(vma, addr, 1, vec);
+		else if (pte_present(pte))
+			vec[i] = 1;
+		else if (pte_file(pte)) {
+			pgoff = pte_to_pgoff(pte);
+			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
+		} else { /* pte is a swap entry */
+			swp_entry_t entry = pte_to_swp_entry(pte);
+
+			if (is_migration_entry(entry)) {
+				/* migration entries are always uptodate */
+				vec[i] = 1;
+			} else {
+#ifdef CONFIG_SWAP
+				pgoff = entry.val;
+				vec[i] = mincore_page(&swapper_space, pgoff);
+#else
+				WARN_ON(1);
+				vec[i] = 1;
+#endif
+			}
+		}
+	}
+	pte_unmap_unlock(ptep - 1, ptl);
+}
+
 /*
  * Do a chunk of "sys_mincore()". We've already checked
  * all the arguments, we hold the mmap semaphore: we should
@@ -59,11 +153,7 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
-	pte_t *ptep;
-	spinlock_t *ptl;
 	unsigned long nr;
-	int i;
-	pgoff_t pgoff;
 	struct vm_area_struct *vma;
 
 	vma = find_vma(current->mm, addr);
@@ -72,35 +162,10 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 
 	nr = min(pages, (vma->vm_end - addr) >> PAGE_SHIFT);
 
-#ifdef CONFIG_HUGETLB_PAGE
 	if (is_vm_hugetlb_page(vma)) {
-		struct hstate *h;
-
-		i = 0;
-		h = hstate_vma(vma);
-		while (1) {
-			unsigned char present;
-			/*
-			 * Huge pages are always in RAM for now, but
-			 * theoretically it needs to be checked.
-			 */
-			ptep = huge_pte_offset(current->mm,
-					       addr & huge_page_mask(h));
-			present = ptep && !huge_pte_none(huge_ptep_get(ptep));
-			while (1) {
-				vec[i++] = present;
-				addr += PAGE_SIZE;
-				/* reach buffer limit */
-				if (i == nr)
-					return nr;
-				/* check hugepage border */
-				if (!(addr & ~huge_page_mask(h)))
-					break;
-			}
-		}
+		mincore_hugetlb_page_range(vma, addr, nr, vec);
 		return nr;
 	}
-#endif
 
 	/*
 	 * Calculate how many pages there are left in the last level of the
@@ -119,53 +184,11 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 	if (pmd_none_or_clear_bad(pmd))
 		goto none_mapped;
 
-	ptep = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	for (i = 0; i < nr; i++, ptep++, addr += PAGE_SIZE) {
-		pte_t pte = *ptep;
-
-		if (pte_none(pte)) {
-			if (vma->vm_file) {
-				pgoff = linear_page_index(vma, addr);
-				vec[i] = mincore_page(vma->vm_file->f_mapping,
-						pgoff);
-			} else
-				vec[i] = 0;
-		} else if (pte_present(pte))
-			vec[i] = 1;
-		else if (pte_file(pte)) {
-			pgoff = pte_to_pgoff(pte);
-			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
-		} else { /* pte is a swap entry */
-			swp_entry_t entry = pte_to_swp_entry(pte);
-
-			if (is_migration_entry(entry)) {
-				/* migration entries are always uptodate */
-				vec[i] = 1;
-			} else {
-#ifdef CONFIG_SWAP
-				pgoff = entry.val;
-				vec[i] = mincore_page(&swapper_space, pgoff);
-#else
-				WARN_ON(1);
-				vec[i] = 1;
-#endif
-			}
-		}
-	}
-	pte_unmap_unlock(ptep - 1, ptl);
-
+	mincore_pte_range(vma, pmd, addr, nr, vec);
 	return nr;
 
 none_mapped:
-	if (vma->vm_file) {
-		pgoff = linear_page_index(vma, addr);
-		for (i = 0; i < nr; i++, pgoff++)
-			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
-	} else {
-		for (i = 0; i < nr; i++)
-			vec[i] = 0;
-	}
-
+	mincore_unmapped_range(vma, addr, nr, vec);
 	return nr;
 }
 
-- 
1.7.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
