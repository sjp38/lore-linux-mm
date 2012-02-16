Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 8FE1B6B0092
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 13:05:35 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH 13/18] Zapping and freeing huge mappings
Date: Thu, 16 Feb 2012 15:31:40 +0100
Message-Id: <1329402705-25454-13-git-send-email-mail@smogura.eu>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

Changes to VM subsytem allowing zapping and freeing huge pages,
additional functions for removing mapping.

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 include/asm-generic/tlb.h |   21 ++++++
 include/linux/huge_mm.h   |   13 ++++-
 mm/huge_memory.c          |  153 ++++++++++++++++++++++++++++++++++++++++++---
 mm/memory.c               |   39 +++++++-----
 4 files changed, 202 insertions(+), 24 deletions(-)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index f96a5b5..f7fc543 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -126,6 +126,27 @@ static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 		tlb_flush_mmu(tlb);
 }
 
+/** Compound page must be getted frozen. */
+static inline void tlb_remove_page_huge(struct mmu_gather *tlb,
+	struct page *head)
+{
+	struct page *page;
+
+	VM_BUG_ON(!PageHead(head));
+	VM_BUG_ON(atomic_read(&head[2]._compound_usage) == 1);
+
+	tlb_remove_page(tlb, head);
+	tlb_remove_page(tlb, head + 1);
+	if (likely(compound_order(head) > 1)) {
+		for (page = head+2; page->__first_page == head; page++) {
+			tlb_remove_page(tlb, page);
+			/* Such situation should not happen, it means we mapped
+			 * dangling page.
+			 */
+			BUG_ON(!PageAnon(page) && !page->mapping);
+		}
+	}
+}
 /**
  * tlb_remove_tlb_entry - remember a pte unmapping for later tlb invalidation.
  *
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index c2407e4..c72a849 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -88,12 +88,21 @@ extern int handle_pte_fault(struct mm_struct *mm,
 			    pte_t *pte, pmd_t *pmd, unsigned int flags);
 extern int split_huge_page(struct page *page);
 extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
+extern void __split_huge_page_pmd_vma(struct vm_area_struct *vma,
+	unsigned long address, pmd_t *pmd);
+
 #define split_huge_page_pmd(__mm, __pmd)				\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
-		if (unlikely(pmd_trans_huge(*____pmd)))			\
+	if (unlikely(pmd_trans_huge(*____pmd)))			\
 			__split_huge_page_pmd(__mm, ____pmd);		\
 	}  while (0)
+#define split_huge_page_pmd_vma(__vma, __addr, __pmd)			\
+	do {								\
+		pmd_t *____pmd = (__pmd);				\
+		if (unlikely(pmd_trans_huge(*____pmd)))			\
+			__split_huge_page_pmd_vma(__vma, __addr, ____pmd);\
+	}  while (0)
 #define wait_split_huge_page(__anon_vma, __pmd)				\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
@@ -160,6 +169,8 @@ static inline int split_huge_page(struct page *page)
 }
 #define split_huge_page_pmd(__mm, __pmd)	\
 	do { } while (0)
+#define split_huge_page_pmd_vma(__vma, __addr, __pmd) do { } while (0)
+
 #define wait_split_huge_page(__anon_vma, __pmd)	\
 	do { } while (0)
 #define compound_trans_head(page) compound_head(page)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 74d2e84..95c9ce7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -807,6 +807,9 @@ pgtable_t get_pmd_huge_pte(struct mm_struct *mm)
 
 	/* FIFO */
 	pgtable = mm->pmd_huge_pte;
+	if (!pgtable)
+		return NULL;
+	
 	if (list_empty(&pgtable->lru))
 		mm->pmd_huge_pte = NULL;
 	else {
@@ -1029,27 +1032,56 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
 	int ret = 0;
+	pmd_t pmd_val;
 
+	/* We are going to get page, but if we will be during split, split may
+	 * lock page_table_lock, then we may wait for compound_get, and split
+	 * may wait for page_table_lock, we have here. So... double check
+	 * locking.
+	 */
+again:
 	spin_lock(&tlb->mm->page_table_lock);
-	if (likely(pmd_trans_huge(*pmd))) {
-		if (unlikely(pmd_trans_splitting(*pmd))) {
+	pmd_val = *pmd;
+	if (likely(pmd_trans_huge(pmd_val))) {
+		if (unlikely(pmd_trans_splitting(pmd_val))) {
 			spin_unlock(&tlb->mm->page_table_lock);
 			wait_split_huge_page(vma->anon_vma,
 					     pmd);
 		} else {
 			struct page *page;
 			pgtable_t pgtable;
+
 			pgtable = get_pmd_huge_pte(tlb->mm);
 			page = pmd_page(*pmd);
+			spin_unlock(&tlb->mm->page_table_lock);
+			if (!compound_get(page))
+				return 0;
+			spin_lock(&tlb->mm->page_table_lock);
+			smp_rmb();
+			if (unlikely(!pmd_same(pmd_val, *pmd))) {
+				spin_unlock(&tlb->mm->page_table_lock);
+				compound_put(page);
+				goto again;
+			}
 			pmd_clear(pmd);
 			tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
-			page_remove_rmap(page);
+			if (PageAnon(page))
+				page_remove_rmap(page);
+			else
+				page_remove_rmap_huge(page);
+
 			VM_BUG_ON(page_mapcount(page) < 0);
-			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+			add_mm_counter(tlb->mm, PageAnon(page) ?
+				MM_ANONPAGES : MM_FILEPAGES, -HPAGE_PMD_NR);
 			VM_BUG_ON(!PageHead(page));
 			spin_unlock(&tlb->mm->page_table_lock);
-			tlb_remove_page(tlb, page);
-			pte_free(tlb->mm, pgtable);
+			if (PageAnon(page))
+				tlb_remove_page(tlb, page);
+			else
+				tlb_remove_page_huge(tlb, page);
+			if (pgtable)
+				pte_free(tlb->mm, pgtable);
+			compound_put(page);
 		}
 	} else
 		spin_unlock(&tlb->mm->page_table_lock);
@@ -2368,16 +2400,121 @@ static int khugepaged(void *none)
 	return 0;
 }
 
-void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd)
+/** Makes inplace split of huge pmd to normal pmd, pmd is filled
+ * with ptes compatible with pmd,
+ * <br/>
+ * On success new page table is modified and flushed.
+ * May work only for file pmds.
+ *
+ * This method copies logic from __pte_alloc.
+ */
+int __inplace_split_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
+	unsigned long address, pmd_t *pmd)
+{
+	unsigned long addr, end_addr;
+	pmd_t pmdv, pmd_fake;
+	pte_t pte, pte_pmd;
+	pte_t *ptep;
+	pgtable_t new;
+	struct page *page;
+
+	address &= HPAGE_PMD_MASK;
+
+	/* TODO Good place to change locking technique for pmds. */
+repeat:
+	addr = address & HPAGE_PMD_MASK;
+
+	smp_mb();
+	if (pmd_none(*pmd) || !pmd_trans_huge(*pmd))
+		return 0;
+
+	new = pte_alloc_one(mm, addr);
+
+	if (!new)
+		return -ENOMEM;
+	pmdv = *pmd;
+
+	pmd_fake = pmdv;
+	pte_pmd = pte_clrhuge(*((pte_t *) &pmd_fake));
+	pmd_fake = *((pmd_t *) &pte_pmd);
+
+	pmd_populate(mm, &pmd_fake, new);
+
+	page = pmd_page(pmdv);
+	end_addr = pmd_addr_end(addr, 0L);
+	for (; addr < end_addr; addr += PAGE_SIZE, page++) {
+		if (!pmd_present(pmdv))
+			continue;
+		/* Copy protection from pmd. */
+		pte = mk_pte(page, vma->vm_page_prot);
+
+		if (pmd_dirty(pmdv))
+			pte = pte_mkdirty(pte);
+		if (pmd_write(pmdv))
+			pte = pte_mkwrite(pte);
+		if (pmd_exec(pmdv))
+			pte = pte_mkexec(pte);
+		if (pmd_young(pmdv))
+			pte = pte_mkyoung(pte);
+
+		ptep = pte_offset_map(&pmd_fake, addr);
+		set_pte_at(mm, addr, ptep, pte);
+		pte_unmap(ptep);
+	}
+
+	/* Ensure everything is visible before populating pmd. */
+	smp_mb();
+
+	spin_lock(&mm->page_table_lock);
+	if (pmd_same(pmdv, *pmd)) {
+		set_pmd(pmd, pmd_fake);
+		mm->nr_ptes++;
+		new = NULL;
+	}
+	spin_unlock(&mm->page_table_lock);
+
+	/* Now we have new tlb, make it visible to all. */
+	flush_tlb_range(vma, address, address + HPAGE_SIZE);
+
+	if (new) {
+		pte_free(mm, new);
+		goto repeat;
+	}
+
+	return 0;
+}
+
+/** Splits huge page for vma. */
+void __split_huge_page_pmd_vma(struct vm_area_struct *vma,
+	unsigned long address, pmd_t *pmd)
 {
 	struct page *page;
+	int anonPage;
+	/* XXX Ineficient locking for pmd. */
+	spin_lock(&vma->vm_mm->page_table_lock);
+	if (!pmd_trans_huge(*pmd)) {
+		spin_unlock(&vma->vm_mm->page_table_lock);
+		return;
+	}
+	page = pmd_page(*pmd);
+	anonPage = PageAnon(page);
+	spin_unlock(&vma->vm_mm->page_table_lock);
 
+	if (anonPage)
+		__split_huge_page_pmd(vma->vm_mm, pmd);
+	else
+		__inplace_split_pmd(vma->vm_mm, vma, address, pmd);
+}
+void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd)
+{
+	struct page *page = pmd_page(*pmd);
+
+	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_trans_huge(*pmd))) {
 		spin_unlock(&mm->page_table_lock);
 		return;
 	}
-	page = pmd_page(*pmd);
 	VM_BUG_ON(!page_count(page));
 	get_page(page);
 	spin_unlock(&mm->page_table_lock);
diff --git a/mm/memory.c b/mm/memory.c
index 7427c9b..539d1f4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -572,22 +572,28 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		unlink_file_vma(vma);
 
 		if (is_vm_hugetlb_page(vma)) {
-			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
-				floor, next? next->vm_start: ceiling);
-		} else {
-			/*
-			 * Optimization: gather nearby vmas into one call down
-			 */
-			while (next && next->vm_start <= vma->vm_end + PMD_SIZE
-			       && !is_vm_hugetlb_page(next)) {
-				vma = next;
-				next = vma->vm_next;
-				unlink_anon_vmas(vma);
-				unlink_file_vma(vma);
+			if (vma->vm_file) {
+				if (vma->vm_file->f_mapping->a_ops->defragpage)
+					goto free_normal;
 			}
-			free_pgd_range(tlb, addr, vma->vm_end,
+			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
+		} 
+
+free_normal:		
+		/*
+		* Optimization: gather nearby vmas into one call down
+		*/
+		while (next && next->vm_start <= vma->vm_end + PMD_SIZE
+			&& !is_vm_hugetlb_page(next)) {
+			vma = next;
+			next = vma->vm_next;
+			unlink_anon_vmas(vma);
+			unlink_file_vma(vma);
 		}
+		free_pgd_range(tlb, addr, vma->vm_end,
+			floor, next? next->vm_start: ceiling);
+
 		vma = next;
 	}
 }
@@ -1248,8 +1254,11 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd)) {
 			if (next-addr != HPAGE_PMD_SIZE) {
-				VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem));
-				split_huge_page_pmd(vma->vm_mm, pmd);
+				/* And now we go again in conflict with, THP...
+				 * THP requires semaphore, we require compound
+				 * frozen, why...?
+				 */
+				split_huge_page_pmd_vma(vma, addr, pmd);
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				continue;
 			/* fall through */
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
