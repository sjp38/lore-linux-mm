From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16994.40538.327768.911229@gargle.gargle.HOWL>
Date: Sun, 17 Apr 2005 21:35:22 +0400
Subject: [PATCH]: VM 2/8 rmap.c cleanup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <AKPM@Osdl.ORG>
List-ID: <linux-mm.kvack.org>

mm/rmap.c:page_referenced_one() and mm/rmap.c:try_to_unmap_one() contain
identical code that

 - takes mm->page_table_lock;

 - drills through page tables;

 - checks that correct pte is reached.

Coalesce this into page_check_address()

Signed-off-by: Nikita Danilov <nikita@clusterfs.com>


 mm/rmap.c |  113 +++++++++++++++++++++++++++-----------------------------------
 1 files changed, 50 insertions(+), 63 deletions(-)

diff -puN mm/rmap.c~rmap-cleanup mm/rmap.c
--- bk-linux/mm/rmap.c~rmap-cleanup	2005-04-17 17:52:48.000000000 +0400
+++ bk-linux-nikita/mm/rmap.c	2005-04-17 17:52:48.000000000 +0400
@@ -243,6 +243,42 @@ unsigned long page_address_in_vma(struct
 }
 
 /*
+ * Check that @page is mapped at @address into @mm.
+ *
+ * On success returns with mapped pte and locked mm->page_table_lock.
+ */
+static pte_t *page_check_address(struct page *page, struct mm_struct *mm,
+					unsigned long address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	/*
+	 * We need the page_table_lock to protect us from page faults,
+	 * munmap, fork, etc...
+	 */
+	spin_lock(&mm->page_table_lock);
+	pgd = pgd_offset(mm, address);
+	if (likely(pgd_present(*pgd))) {
+		pud = pud_offset(pgd, address);
+		if (likely(pud_present(*pud))) {
+			pmd = pmd_offset(pud, address);
+			if (likely(pmd_present(*pmd))) {
+				pte = pte_offset_map(pmd, address);
+				if (likely(pte_present(*pte) &&
+					   page_to_pfn(page) == pte_pfn(*pte)))
+					return pte;
+				pte_unmap(pte);
+			}
+		}
+	}
+	spin_unlock(&mm->page_table_lock);
+	return ERR_PTR(-ENOENT);
+}
+
+/*
  * Subfunctions of page_referenced: page_referenced_one called
  * repeatedly from either page_referenced_anon or page_referenced_file.
  */
@@ -251,9 +287,6 @@ static int page_referenced_one(struct pa
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
 	pte_t *pte;
 	int referenced = 0;
 
@@ -263,39 +296,18 @@ static int page_referenced_one(struct pa
 	if (address == -EFAULT)
 		goto out;
 
-	spin_lock(&mm->page_table_lock);
-
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
-		goto out_unlock;
-
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		goto out_unlock;
-
-	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd))
-		goto out_unlock;
-
-	pte = pte_offset_map(pmd, address);
-	if (!pte_present(*pte))
-		goto out_unmap;
-
-	if (page_to_pfn(page) != pte_pfn(*pte))
-		goto out_unmap;
-
-	if (ptep_clear_flush_young(vma, address, pte))
-		referenced++;
-
-	if (mm != current->mm && !ignore_token && has_swap_token(mm))
-		referenced++;
+	pte = page_check_address(page, mm, address);
+	if (!IS_ERR(pte)) {
+		if (ptep_clear_flush_young(vma, address, pte))
+			referenced++;
 
-	(*mapcount)--;
+		if (mm != current->mm && !ignore_token && has_swap_token(mm))
+			referenced++;
 
-out_unmap:
-	pte_unmap(pte);
-out_unlock:
-	spin_unlock(&mm->page_table_lock);
+		(*mapcount)--;
+		pte_unmap(pte);
+		spin_unlock(&mm->page_table_lock);
+	}
 out:
 	return referenced;
 }
@@ -502,9 +514,6 @@ static int try_to_unmap_one(struct page 
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
 	pte_t *pte;
 	pte_t pteval;
 	int ret = SWAP_AGAIN;
@@ -515,30 +524,9 @@ static int try_to_unmap_one(struct page 
 	if (address == -EFAULT)
 		goto out;
 
-	/*
-	 * We need the page_table_lock to protect us from page faults,
-	 * munmap, fork, etc...
-	 */
-	spin_lock(&mm->page_table_lock);
-
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
-		goto out_unlock;
-
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		goto out_unlock;
-
-	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd))
-		goto out_unlock;
-
-	pte = pte_offset_map(pmd, address);
-	if (!pte_present(*pte))
-		goto out_unmap;
-
-	if (page_to_pfn(page) != pte_pfn(*pte))
-		goto out_unmap;
+	pte = page_check_address(page, mm, address);
+	if (IS_ERR(pte))
+		goto out;
 
 	/*
 	 * If the page is mlock()d, we cannot swap it out.
@@ -604,7 +592,6 @@ static int try_to_unmap_one(struct page 
 
 out_unmap:
 	pte_unmap(pte);
-out_unlock:
 	spin_unlock(&mm->page_table_lock);
 out:
 	return ret;
@@ -708,7 +695,6 @@ static void try_to_unmap_cluster(unsigne
 	}
 
 	pte_unmap(pte);
-
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
 }
@@ -860,3 +846,4 @@ int try_to_unmap(struct page *page)
 		ret = SWAP_SUCCESS;
 	return ret;
 }
+

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
