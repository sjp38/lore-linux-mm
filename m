From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 13:15:17 +1000 (EST)
Subject: [PATCH 4/15] PTI: move mlpt behind interface cont.
In-Reply-To: <Pine.LNX.4.61.0505211305230.12627@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211313160.17972@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211305230.12627@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 4 of 15.

This patch continues moving mlpt code behind the interface.
 	*mlpt directory allocation functions are moved behind the
 	 page table interface to mlpt.c from memory.c.
 	*Their prototypes were abstracted from mm.h to mm-mlpt.h
 	 in a previous patch.
 	*Functions for clearing bad pgds, pmds and puds are moved
 	 from memory.c to mlpt.c also.  The prototypes for these
 	 functions are abstracted in the next patch.

  mm/fixed-mlpt/mlpt.c |  146 
++++++++++++++++++++++++++++++++++++++++++++++++++
  mm/memory.c          |  147 
---------------------------------------------------
  2 files changed, 146 insertions(+), 147 deletions(-)

Index: linux-2.6.12-rc4/mm/memory.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/memory.c	2005-05-19 17:40:54.000000000 
+1000
+++ linux-2.6.12-rc4/mm/memory.c	2005-05-19 17:41:04.000000000 
+1000
@@ -82,82 +82,6 @@
  EXPORT_SYMBOL(vmalloc_earlyreserve);

  /*
- * If a p?d_bad entry is found while walking page tables, report
- * the error, before resetting entry to p?d_none.  Usually (but
- * very seldom) called out from the p?d_none_or_clear_bad macros.
- */
-
-void pgd_clear_bad(pgd_t *pgd)
-{
-	pgd_ERROR(*pgd);
-	pgd_clear(pgd);
-}
-
-void pud_clear_bad(pud_t *pud)
-{
-	pud_ERROR(*pud);
-	pud_clear(pud);
-}
-
-void pmd_clear_bad(pmd_t *pmd)
-{
-	pmd_ERROR(*pmd);
-	pmd_clear(pmd);
-}
-
-pte_t fastcall *pte_alloc_map(struct mm_struct *mm, pmd_t *pmd,
-				unsigned long address)
-{
-	if (!pmd_present(*pmd)) {
-		struct page *new;
-
-		spin_unlock(&mm->page_table_lock);
-		new = pte_alloc_one(mm, address);
-		spin_lock(&mm->page_table_lock);
-		if (!new)
-			return NULL;
-		/*
-		 * Because we dropped the lock, we should re-check the
-		 * entry, as somebody else could have populated it..
-		 */
-		if (pmd_present(*pmd)) {
-			pte_free(new);
-			goto out;
-		}
-		mm->nr_ptes++;
-		inc_page_state(nr_page_table_pages);
-		pmd_populate(mm, pmd, new);
-	}
-out:
-	return pte_offset_map(pmd, address);
-}
-
-pte_t fastcall * pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, 
unsigned long address)
-{
-	if (!pmd_present(*pmd)) {
-		pte_t *new;
-
-		spin_unlock(&mm->page_table_lock);
-		new = pte_alloc_one_kernel(mm, address);
-		spin_lock(&mm->page_table_lock);
-		if (!new)
-			return NULL;
-
-		/*
-		 * Because we dropped the lock, we should re-check the
-		 * entry, as somebody else could have populated it..
-		 */
-		if (pmd_present(*pmd)) {
-			pte_free_kernel(new);
-			goto out;
-		}
-		pmd_populate_kernel(mm, pmd, new);
-	}
-out:
-	return pte_offset_kernel(pmd, address);
-}
-
-/*
   * copy one vm_area from one task to the other. Assumes the page tables
   * already present in the new task to be cleared in the whole range
   * covered by this vma.
@@ -1890,77 +1814,6 @@
  	return VM_FAULT_OOM;
  }

-#ifndef __PAGETABLE_PUD_FOLDED
-/*
- * Allocate page upper directory.
- *
- * We've already handled the fast-path in-line, and we own the
- * page table lock.
- */
-pud_t fastcall *__pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned 
long address)
-{
-	pud_t *new;
-
-	spin_unlock(&mm->page_table_lock);
-	new = pud_alloc_one(mm, address);
-	spin_lock(&mm->page_table_lock);
-	if (!new)
-		return NULL;
-
-	/*
-	 * Because we dropped the lock, we should re-check the
-	 * entry, as somebody else could have populated it..
-	 */
-	if (pgd_present(*pgd)) {
-		pud_free(new);
-		goto out;
-	}
-	pgd_populate(mm, pgd, new);
- out:
-	return pud_offset(pgd, address);
-}
-#endif /* __PAGETABLE_PUD_FOLDED */
-
-#ifndef __PAGETABLE_PMD_FOLDED
-/*
- * Allocate page middle directory.
- *
- * We've already handled the fast-path in-line, and we own the
- * page table lock.
- */
-pmd_t fastcall *__pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned 
long address)
-{
-	pmd_t *new;
-
-	spin_unlock(&mm->page_table_lock);
-	new = pmd_alloc_one(mm, address);
-	spin_lock(&mm->page_table_lock);
-	if (!new)
-		return NULL;
-
-	/*
-	 * Because we dropped the lock, we should re-check the
-	 * entry, as somebody else could have populated it..
-	 */
-#ifndef __ARCH_HAS_4LEVEL_HACK
-	if (pud_present(*pud)) {
-		pmd_free(new);
-		goto out;
-	}
-	pud_populate(mm, pud, new);
-#else
-	if (pgd_present(*pud)) {
-		pmd_free(new);
-		goto out;
-	}
-	pgd_populate(mm, pud, new);
-#endif /* __ARCH_HAS_4LEVEL_HACK */
-
- out:
-	return pmd_offset(pud, address);
-}
-#endif /* __PAGETABLE_PMD_FOLDED */
-
  int make_pages_present(unsigned long addr, unsigned long end)
  {
  	int ret, len, write;
Index: linux-2.6.12-rc4/mm/fixed-mlpt/mlpt.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/fixed-mlpt/mlpt.c	2005-05-19 
17:40:54.000000000 +1000
+++ linux-2.6.12-rc4/mm/fixed-mlpt/mlpt.c	2005-05-19 
17:41:04.000000000 +1000
@@ -192,3 +192,149 @@
  	}
  }

+/*
+ * If a p?d_bad entry is found while walking page tables, report
+ * the error, before resetting entry to p?d_none.  Usually (but
+ * very seldom) called out from the p?d_none_or_clear_bad macros.
+ */
+
+void pgd_clear_bad(pgd_t *pgd)
+{
+	pgd_ERROR(*pgd);
+	pgd_clear(pgd);
+}
+
+void pud_clear_bad(pud_t *pud)
+{
+	pud_ERROR(*pud);
+	pud_clear(pud);
+}
+
+void pmd_clear_bad(pmd_t *pmd)
+{
+	pmd_ERROR(*pmd);
+	pmd_clear(pmd);
+}
+
+pte_t fastcall *pte_alloc_map(struct mm_struct *mm, pmd_t *pmd,
+				unsigned long address)
+{
+	if (!pmd_present(*pmd)) {
+		struct page *new;
+
+		spin_unlock(&mm->page_table_lock);
+		new = pte_alloc_one(mm, address);
+		spin_lock(&mm->page_table_lock);
+		if (!new)
+			return NULL;
+		/*
+		 * Because we dropped the lock, we should re-check the
+		 * entry, as somebody else could have populated it..
+		 */
+		if (pmd_present(*pmd)) {
+			pte_free(new);
+			goto out;
+		}
+		mm->nr_ptes++;
+		inc_page_state(nr_page_table_pages);
+		pmd_populate(mm, pmd, new);
+	}
+out:
+	return pte_offset_map(pmd, address);
+}
+
+pte_t fastcall * pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, 
unsigned long address)
+{
+	if (!pmd_present(*pmd)) {
+		pte_t *new;
+
+		spin_unlock(&mm->page_table_lock);
+		new = pte_alloc_one_kernel(mm, address);
+		spin_lock(&mm->page_table_lock);
+		if (!new)
+			return NULL;
+
+		/*
+		 * Because we dropped the lock, we should re-check the
+		 * entry, as somebody else could have populated it..
+		 */
+		if (pmd_present(*pmd)) {
+			pte_free_kernel(new);
+			goto out;
+		}
+		pmd_populate_kernel(mm, pmd, new);
+	}
+out:
+	return pte_offset_kernel(pmd, address);
+}
+
+#ifndef __PAGETABLE_PUD_FOLDED
+/*
+ * Allocate page upper directory.
+ *
+ * We've already handled the fast-path in-line, and we own the
+ * page table lock.
+ */
+pud_t fastcall *__pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned 
long address)
+{
+	pud_t *new;
+
+	spin_unlock(&mm->page_table_lock);
+	new = pud_alloc_one(mm, address);
+	spin_lock(&mm->page_table_lock);
+	if (!new)
+		return NULL;
+
+	/*
+	 * Because we dropped the lock, we should re-check the
+	 * entry, as somebody else could have populated it..
+	 */
+	if (pgd_present(*pgd)) {
+		pud_free(new);
+		goto out;
+	}
+	pgd_populate(mm, pgd, new);
+ out:
+	return pud_offset(pgd, address);
+}
+#endif /* __PAGETABLE_PUD_FOLDED */
+
+#ifndef __PAGETABLE_PMD_FOLDED
+/*
+ * Allocate page middle directory.
+ *
+ * We've already handled the fast-path in-line, and we own the
+ * page table lock.
+ */
+pmd_t fastcall *__pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned 
long address)
+{
+	pmd_t *new;
+
+	spin_unlock(&mm->page_table_lock);
+	new = pmd_alloc_one(mm, address);
+	spin_lock(&mm->page_table_lock);
+	if (!new)
+		return NULL;
+
+	/*
+	 * Because we dropped the lock, we should re-check the
+	 * entry, as somebody else could have populated it..
+	 */
+#ifndef __ARCH_HAS_4LEVEL_HACK
+	if (pud_present(*pud)) {
+		pmd_free(new);
+		goto out;
+	}
+	pud_populate(mm, pud, new);
+#else
+	if (pgd_present(*pud)) {
+		pmd_free(new);
+		goto out;
+	}
+	pgd_populate(mm, pud, new);
+#endif /* __ARCH_HAS_4LEVEL_HACK */
+
+ out:
+	return pmd_offset(pud, address);
+}
+#endif /* __PAGETABLE_PMD_FOLDED */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
