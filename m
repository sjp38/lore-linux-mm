Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CBB0A8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 10:17:06 -0400 (EDT)
Received: by pxi10 with SMTP id 10so844009pxi.8
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 07:17:03 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: [PATCH 1/2] mm: page_check_address bug fix and make it validate subpages in huge pages
Date: Mon, 28 Mar 2011 22:16:43 +0800
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201103282216.44059.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Chris Wright <chrisw@sous-sol.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

There is a bug in __page_check_address() that may trigger a rare case of 
schedule in atomic on huge pages if CONFIG_HIGHPTE is enabled:
if a huge page is validated by this function, the returned pte_t * is 
actually a pmd_t* which is not mapped by kmap_atomic(), but will later be
kunmap_atomic(). This may result in a false preempt count. This patch adds
another parameter named "need_pte_unmap" to let it tell outside if this is
a good huge page and should not be pte_unmap(). All callsites have been 
modified to use another new uniformed call:
page_check_address_unmap_unlock(ptl, pte, need_pte_unmap), to finalize the 
page_check_address().

Another tiny bug in huge_pte_offset() is that when it was called in 
__page_check_address(), there is no good-reasoned guarantee that the 
"address" passed in is really mapped to a huge page even if PageHuge(page)
is true. So it's too early to return a pmd without checking its _PAGE_PSE.

This patch also makes the page_check_address() can validate if a subpage is
in its place in a huge page pointed by the address. This can be useful when
ksm does not split huge pages when comparing the subpages one by one.

Signed-off-by: Nai Xia <nai.xia@gmail.com>
---
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 069ce7c..df7c323 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -164,6 +164,8 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 			if (pud_large(*pud))
 				return (pte_t *)pud;
 			pmd = pmd_offset(pud, addr);
+			if (!pmd_huge(*pmd))
+				pmd = NULL;
 		}
 	}
 	return (pte_t *) pmd;
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index e9fd04c..aafb64c 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -9,6 +9,7 @@
 #include <linux/mm.h>
 #include <linux/spinlock.h>
 #include <linux/memcontrol.h>
+#include <linux/highmem.h>
 
 /*
  * The anon_vma heads a list of private "related" vmas, to scan if
@@ -208,20 +209,35 @@ int try_to_unmap_one(struct page *, struct vm_area_struct *,
  * Called from mm/filemap_xip.c to unmap empty zero page
  */
 pte_t *__page_check_address(struct page *, struct mm_struct *,
-				unsigned long, spinlock_t **, int);
+			    unsigned long, spinlock_t **, int, int *);
 
-static inline pte_t *page_check_address(struct page *page, struct mm_struct *mm,
-					unsigned long address,
-					spinlock_t **ptlp, int sync)
+static inline
+pte_t *page_check_address(struct page *page, struct mm_struct *mm,
+			  unsigned long address, spinlock_t **ptlp,
+			  int sync, int *need_pte_unmap)
 {
 	pte_t *ptep;
 
 	__cond_lock(*ptlp, ptep = __page_check_address(page, mm, address,
-						       ptlp, sync));
+						       ptlp, sync,
+						       need_pte_unmap));
 	return ptep;
 }
 
 /*
+ * After a successful page_check_address() call this is the way to finalize
+ */
+static inline
+void page_check_address_unmap_unlock(spinlock_t *ptl, pte_t *pte,
+				     int need_pte_unmap)
+{
+	if (need_pte_unmap)
+		pte_unmap(pte);
+
+	spin_unlock(ptl);
+}
+
+/*
  * Used by swapoff to help locate where page is expected in vma.
  */
 unsigned long page_address_in_vma(struct page *, struct vm_area_struct *);
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 83364df..c8fd402 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -175,6 +175,7 @@ __xip_unmap (struct address_space * mapping,
 	struct page *page;
 	unsigned count;
 	int locked = 0;
+	int need_unmap;
 
 	count = read_seqcount_begin(&xip_sparse_seq);
 
@@ -189,7 +190,8 @@ retry:
 		address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
-		pte = page_check_address(page, mm, address, &ptl, 1);
+		pte = page_check_address(page, mm, address, &ptl, 1,
+					 &need_pte_unmap);
 		if (pte) {
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
@@ -197,7 +199,7 @@ retry:
 			page_remove_rmap(page);
 			dec_mm_counter(mm, MM_FILEPAGES);
 			BUG_ON(pte_dirty(pteval));
-			pte_unmap_unlock(pte, ptl);
+			page_check_address_unmap_unlock(ptl, pte, need_unmap);
 			page_cache_release(page);
 		}
 	}
diff --git a/mm/rmap.c b/mm/rmap.c
index 941bf82..9af9267 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -414,17 +414,25 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
  * On success returns with pte mapped and locked.
  */
 pte_t *__page_check_address(struct page *page, struct mm_struct *mm,
-			  unsigned long address, spinlock_t **ptlp, int sync)
+			    unsigned long address, spinlock_t **ptlp,
+			    int sync, int *need_pte_unmap)
 {
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 	spinlock_t *ptl;
+	unsigned long sub_pfn;
+
+	*need_pte_unmap = 1;
 
 	if (unlikely(PageHuge(page))) {
 		pte = huge_pte_offset(mm, address);
+		if (!pte_present(*pte))
+			return NULL;
+
 		ptl = &mm->page_table_lock;
+		*need_pte_unmap = 0;
 		goto check;
 	}
 
@@ -439,8 +447,12 @@ pte_t *__page_check_address(struct page *page, struct mm_struct *mm,
 	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
 		return NULL;
-	if (pmd_trans_huge(*pmd))
-		return NULL;
+	if (pmd_trans_huge(*pmd)) {
+		pte = (pte_t *) pmd;
+		ptl = &mm->page_table_lock;
+		*need_pte_unmap = 0;
+		goto check;
+	}
 
 	pte = pte_offset_map(pmd, address);
 	/* Make a quick check before getting the lock */
@@ -452,11 +464,23 @@ pte_t *__page_check_address(struct page *page, struct mm_struct *mm,
 	ptl = pte_lockptr(mm, pmd);
 check:
 	spin_lock(ptl);
-	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
+	if (!*need_pte_unmap) {
+		sub_pfn = pte_pfn(*pte) +
+			((address & ~HPAGE_PMD_MASK) >> PAGE_SHIFT);
+
+		if (pte_present(*pte) && page_to_pfn(page) == sub_pfn) {
+			*ptlp = ptl;
+			return pte;
+		}
+	} else if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
 		*ptlp = ptl;
 		return pte;
 	}
-	pte_unmap_unlock(pte, ptl);
+
+	if (*need_pte_unmap)
+		pte_unmap(pte);
+
+	spin_unlock(ptl);
 	return NULL;
 }
 
@@ -474,14 +498,15 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
 	unsigned long address;
 	pte_t *pte;
 	spinlock_t *ptl;
+	int need_pte_unmap;
 
 	address = vma_address(page, vma);
 	if (address == -EFAULT)		/* out of vma range */
 		return 0;
-	pte = page_check_address(page, vma->vm_mm, address, &ptl, 1);
+	pte = page_check_address(page, vma->vm_mm, address, &ptl, 1, &need_pte_unmap);
 	if (!pte)			/* the page is not in this mm */
 		return 0;
-	pte_unmap_unlock(pte, ptl);
+	page_check_address_unmap_unlock(ptl, pte, need_pte_unmap);
 
 	return 1;
 }
@@ -526,12 +551,14 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 	} else {
 		pte_t *pte;
 		spinlock_t *ptl;
+		int need_pte_unmap;
 
 		/*
 		 * rmap might return false positives; we must filter
 		 * these out using page_check_address().
 		 */
-		pte = page_check_address(page, mm, address, &ptl, 0);
+		pte = page_check_address(page, mm, address, &ptl, 0,
+					 &need_pte_unmap);
 		if (!pte)
 			goto out;
 
@@ -553,7 +580,7 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			if (likely(!VM_SequentialReadHint(vma)))
 				referenced++;
 		}
-		pte_unmap_unlock(pte, ptl);
+		page_check_address_unmap_unlock(ptl, pte, need_pte_unmap);
 	}
 
 	/* Pretend the page is referenced if the task has the
@@ -727,8 +754,9 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	pte_t *pte;
 	spinlock_t *ptl;
 	int ret = 0;
+	int need_pte_unmap;
 
-	pte = page_check_address(page, mm, address, &ptl, 1);
+	pte = page_check_address(page, mm, address, &ptl, 1, &need_pte_unmap);
 	if (!pte)
 		goto out;
 
@@ -743,7 +771,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		ret = 1;
 	}
 
-	pte_unmap_unlock(pte, ptl);
+	page_check_address_unmap_unlock(ptl, pte, need_pte_unmap);
 out:
 	return ret;
 }
@@ -817,9 +845,9 @@ void page_move_anon_rmap(struct page *page,
 
 /**
  * __page_set_anon_rmap - set up new anonymous rmap
- * @page:	Page to add to rmap	
+ * @page:	Page to add to rmap
  * @vma:	VM area to add page to.
- * @address:	User virtual address of the mapping	
+ * @address:	User virtual address of the mapping
  * @exclusive:	the page is exclusively owned by the current process
  */
 static void __page_set_anon_rmap(struct page *page,
@@ -1020,8 +1048,9 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	pte_t pteval;
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
+	int need_pte_unmap;
 
-	pte = page_check_address(page, mm, address, &ptl, 0);
+	pte = page_check_address(page, mm, address, &ptl, 0, &need_pte_unmap);
 	if (!pte)
 		goto out;
 
@@ -1106,12 +1135,12 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	page_cache_release(page);
 
 out_unmap:
-	pte_unmap_unlock(pte, ptl);
+	page_check_address_unmap_unlock(ptl, pte, need_pte_unmap);
 out:
 	return ret;
 
 out_mlock:
-	pte_unmap_unlock(pte, ptl);
+	page_check_address_unmap_unlock(ptl, pte, need_pte_unmap);
 
 
 	/*

---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
