Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id DBBF86B0069
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 03:03:21 -0400 (EDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] mm: introduce mm_find_pmd()
Date: Tue, 23 Oct 2012 15:02:51 +0800
Message-ID: <1350975771-7930-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, rientjes@google.com, mhocko@suse.cz, mgorman@suse.de, minchan@kernel.org, linux-mm@kvack.org, Bob Liu <lliubbo@gmail.com>

Several place need to find the pmd by(mm_struct, address), so introduce a
function to simple it.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/huge_memory.c |   55 ++++++++++--------------------------------------------
 mm/internal.h    |    5 +++++
 mm/ksm.c         |   14 ++------------
 mm/migrate.c     |   14 ++------------
 mm/rmap.c        |   46 ++++++++++++++++++++++++---------------------
 5 files changed, 44 insertions(+), 90 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 96a2ccc..dcf5642 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1145,22 +1145,14 @@ pmd_t *page_check_address_pmd(struct page *page,
 			      unsigned long address,
 			      enum page_check_address_pmd_flag flag)
 {
-	pgd_t *pgd;
-	pud_t *pud;
 	pmd_t *pmd, *ret = NULL;
 
 	if (address & ~HPAGE_PMD_MASK)
 		goto out;
 
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
+	pmd = mm_find_pmd(mm, address);
+	if (!pmd)
 		goto out;
-
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		goto out;
-
-	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd))
 		goto out;
 	if (pmd_page(*pmd) != page)
@@ -1907,8 +1899,6 @@ static void collapse_huge_page(struct mm_struct *mm,
 				   struct vm_area_struct *vma,
 				   int node)
 {
-	pgd_t *pgd;
-	pud_t *pud;
 	pmd_t *pmd, _pmd;
 	pte_t *pte;
 	pgtable_t pgtable;
@@ -1954,17 +1944,10 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out;
 	VM_BUG_ON(vma->vm_flags & VM_NO_THP);
 
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
+	pmd = mm_find_pmd(mm, address);
+	if (!pmd)
 		goto out;
-
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		goto out;
-
-	pmd = pmd_offset(pud, address);
-	/* pmd can't go away or become huge under us */
-	if (!pmd_present(*pmd) || pmd_trans_huge(*pmd))
+	if (pmd_trans_huge(*pmd))
 		goto out;
 
 	anon_vma_lock(vma->anon_vma);
@@ -2047,8 +2030,6 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 			       unsigned long address,
 			       struct page **hpage)
 {
-	pgd_t *pgd;
-	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
 	int ret = 0, referenced = 0, none = 0;
@@ -2059,16 +2040,10 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
+	pmd = mm_find_pmd(mm, address);
+	if (!pmd)
 		goto out;
-
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		goto out;
-
-	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd) || pmd_trans_huge(*pmd))
+	if (pmd_trans_huge(*pmd))
 		goto out;
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
@@ -2362,22 +2337,12 @@ void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd)
 static void split_huge_page_address(struct mm_struct *mm,
 				    unsigned long address)
 {
-	pgd_t *pgd;
-	pud_t *pud;
 	pmd_t *pmd;
 
 	VM_BUG_ON(!(address & ~HPAGE_PMD_MASK));
 
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
-		return;
-
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		return;
-
-	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd))
+	pmd = mm_find_pmd(mm, address);
+	if (!pmd)
 		return;
 	/*
 	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
diff --git a/mm/internal.h b/mm/internal.h
index a4fa284..52d1fa9 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -92,6 +92,11 @@ extern int isolate_lru_page(struct page *page);
 extern void putback_lru_page(struct page *page);
 
 /*
+ * in mm/rmap.c:
+ */
+extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
+
+/*
  * in mm/page_alloc.c
  */
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
diff --git a/mm/ksm.c b/mm/ksm.c
index ae539f0..31ae5ea 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -778,8 +778,6 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 			struct page *kpage, pte_t orig_pte)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	pgd_t *pgd;
-	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *ptep;
 	spinlock_t *ptl;
@@ -792,18 +790,10 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	if (addr == -EFAULT)
 		goto out;
 
-	pgd = pgd_offset(mm, addr);
-	if (!pgd_present(*pgd))
+	pmd = mm_find_pmd(mm, addr);
+	if (!pmd)
 		goto out;
-
-	pud = pud_offset(pgd, addr);
-	if (!pud_present(*pud))
-		goto out;
-
-	pmd = pmd_offset(pud, addr);
 	BUG_ON(pmd_trans_huge(*pmd));
-	if (!pmd_present(*pmd))
-		goto out;
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
diff --git a/mm/migrate.c b/mm/migrate.c
index 77ed2d7..1dc4598 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -91,8 +91,6 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	swp_entry_t entry;
- 	pgd_t *pgd;
- 	pud_t *pud;
  	pmd_t *pmd;
 	pte_t *ptep, pte;
  	spinlock_t *ptl;
@@ -103,19 +101,11 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 			goto out;
 		ptl = &mm->page_table_lock;
 	} else {
-		pgd = pgd_offset(mm, addr);
-		if (!pgd_present(*pgd))
+		pmd = mm_find_pmd(mm, addr);
+		if (!pmd)
 			goto out;
-
-		pud = pud_offset(pgd, addr);
-		if (!pud_present(*pud))
-			goto out;
-
-		pmd = pmd_offset(pud, addr);
 		if (pmd_trans_huge(*pmd))
 			goto out;
-		if (!pmd_present(*pmd))
-			goto out;
 
 		ptep = pte_offset_map(pmd, addr);
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 7df7984..0f47993 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -561,6 +561,27 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 	return address;
 }
 
+pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd = NULL;
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		goto out;
+
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		goto out;
+
+	pmd = pmd_offset(pud, address);
+	if (!pmd_present(*pmd))
+		pmd = NULL;
+out:
+	return pmd;
+}
+
 /*
  * Check that @page is mapped at @address into @mm.
  *
@@ -573,8 +594,6 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 pte_t *__page_check_address(struct page *page, struct mm_struct *mm,
 			  unsigned long address, spinlock_t **ptlp, int sync)
 {
-	pgd_t *pgd;
-	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 	spinlock_t *ptl;
@@ -585,17 +604,10 @@ pte_t *__page_check_address(struct page *page, struct mm_struct *mm,
 		goto check;
 	}
 
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
-		return NULL;
-
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
+	pmd = mm_find_pmd(mm, address);
+	if (!pmd)
 		return NULL;
 
-	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd))
-		return NULL;
 	if (pmd_trans_huge(*pmd))
 		return NULL;
 
@@ -1356,16 +1368,8 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 	if (end > vma->vm_end)
 		end = vma->vm_end;
 
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
-		return ret;
-
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		return ret;
-
-	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd))
+	pmd = mm_find_pmd(mm, address);
+	if (!pmd)
 		return ret;
 
 	mmun_start = address;
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
