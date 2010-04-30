Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 65EBD6B024F
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 14:30:14 -0400 (EDT)
Date: Fri, 30 Apr 2010 20:28:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/2] Fix migration races in rmap_walk() V3
Message-ID: <20100430182853.GK22108@random.random>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1272529930-29505-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

with mainline + my exec-migrate race fix + your patch1 in this series,
and the below patches, THP should work safe also on top of new
anon-vma code. I'm keeping them incremental but I'll keep them applied
also in aa.git as these patches should work for both the new and old
anon-vma semantics (if there are rejects they're minor). aa.git will
stick longer with old anon-vma code to avoid testing too much stuff at
the same time.

I'm sending the changes below for review.

I think I'll also try to use quilt guards to maintain two trees one
with new anon-vma ready for merging and one with the old
anon-vma. aa.git origin/master will stick to the old anon-vma code.

Thanks,
Andrea

---
Subject: update to the new anon-vma semantics

From: Andrea Arcangeli <aarcange@redhat.com>

The new anon-vma code broke for example wait_split_huge_page because the
vma->anon_vma->lock isn't necessarily the one that split_huge_page holds.
split_huge_page holds the page->mapping/anon_vma->lock if "page" is a shared
readonly hugepage.

The code that works with the new anon-vma code also works with the old one, so
it's better to apply it uncoditionally so it gets more testing also on top of
the old anon-vma code.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -74,24 +74,13 @@ extern int handle_pte_fault(struct mm_st
 			    pte_t *pte, pmd_t *pmd, unsigned int flags);
 extern int split_huge_page(struct page *page);
 extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
+extern void wait_split_huge_page(struct mm_struct *mm, pmd_t *pmd);
 #define split_huge_page_pmd(__mm, __pmd)				\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
 		if (unlikely(pmd_trans_huge(*____pmd)))			\
 			__split_huge_page_pmd(__mm, ____pmd);		\
 	}  while (0)
-#define wait_split_huge_page(__anon_vma, __pmd)				\
-	do {								\
-		pmd_t *____pmd = (__pmd);				\
-		spin_unlock_wait(&(__anon_vma)->lock);			\
-		/*							\
-		 * spin_unlock_wait() is just a loop in C and so the	\
-		 * CPU can reorder anything around it.			\
-		 */							\
-		smp_mb();						\
-		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
-		       pmd_trans_huge(*____pmd));			\
-	} while (0)
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
 #if HPAGE_PMD_ORDER > MAX_ORDER
@@ -118,7 +107,7 @@ static inline int split_huge_page(struct
 }
 #define split_huge_page_pmd(__mm, __pmd)	\
 	do { } while (0)
-#define wait_split_huge_page(__anon_vma, __pmd)	\
+#define wait_split_huge_page(__mm, __pmd)	\
 	do { } while (0)
 #define PageTransHuge(page) 0
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -162,6 +162,9 @@ int try_to_munlock(struct page *);
  */
 struct anon_vma *page_lock_anon_vma(struct page *page);
 void page_unlock_anon_vma(struct anon_vma *anon_vma);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+void wait_page_lock_anon_vma(struct page *page);
+#endif
 int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
 /*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -314,7 +314,7 @@ int copy_huge_pmd(struct mm_struct *dst_
 		spin_unlock(&src_mm->page_table_lock);
 		spin_unlock(&dst_mm->page_table_lock);
 
-		wait_split_huge_page(vma->anon_vma, src_pmd); /* src_vma */
+		wait_split_huge_page(src_mm, src_pmd); /* src_vma */
 		goto out;
 	}
 	src_page = pmd_page(pmd);
@@ -551,8 +551,7 @@ int zap_huge_pmd(struct mmu_gather *tlb,
 	if (likely(pmd_trans_huge(*pmd))) {
 		if (unlikely(pmd_trans_splitting(*pmd))) {
 			spin_unlock(&tlb->mm->page_table_lock);
-			wait_split_huge_page(vma->anon_vma,
-					     pmd);
+			wait_split_huge_page(tlb->mm, pmd);
 		} else {
 			struct page *page;
 			pgtable_t pgtable;
@@ -879,3 +878,35 @@ void __split_huge_page_pmd(struct mm_str
 	put_page(page);
 	BUG_ON(pmd_trans_huge(*pmd));
 }
+
+void wait_split_huge_page(struct mm_struct *mm, pmd_t *pmd)
+{
+	struct page *page;
+
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_trans_huge(*pmd))) {
+		spin_unlock(&mm->page_table_lock);
+		VM_BUG_ON(pmd_trans_splitting(*pmd));
+		return;
+	}
+	page = pmd_page(*pmd);
+	get_page(page);
+	spin_unlock(&mm->page_table_lock);
+
+	/*
+	 * The vma->anon_vma->lock is the wrong lock if the page is shared,
+	 * the anon_vma->lock pointed by page->mapping is the right one.
+	 */
+	wait_page_lock_anon_vma(page);
+
+	put_page(page);
+
+	/*
+	 * spin_unlock_wait() is just a loop in C and so the
+	 * CPU can reorder anything around it.
+	 */
+	smp_mb();
+
+	BUG_ON(pmd_trans_huge(*pmd));
+	VM_BUG_ON(pmd_trans_splitting(*pmd));
+}
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -400,7 +400,7 @@ int __pte_alloc(struct mm_struct *mm, st
 		pmd_t *pmd, unsigned long address)
 {
 	pgtable_t new = pte_alloc_one(mm, address);
-	int wait_split_huge_page;
+	int need_wait_split_huge_page;
 	if (!new)
 		return -ENOMEM;
 
@@ -420,18 +420,18 @@ int __pte_alloc(struct mm_struct *mm, st
 	smp_wmb(); /* Could be smp_wmb__xxx(before|after)_spin_lock */
 
 	spin_lock(&mm->page_table_lock);
-	wait_split_huge_page = 0;
+	need_wait_split_huge_page = 0;
 	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
 		mm->nr_ptes++;
 		pmd_populate(mm, pmd, new);
 		new = NULL;
 	} else if (unlikely(pmd_trans_splitting(*pmd)))
-		wait_split_huge_page = 1;
+		need_wait_split_huge_page = 1;
 	spin_unlock(&mm->page_table_lock);
 	if (new)
 		pte_free(mm, new);
-	if (wait_split_huge_page)
-		wait_split_huge_page(vma->anon_vma, pmd);
+	if (need_wait_split_huge_page)
+		wait_split_huge_page(mm, pmd);
 	return 0;
 }
 
@@ -1302,7 +1302,7 @@ struct page *follow_page(struct vm_area_
 		if (likely(pmd_trans_huge(*pmd))) {
 			if (unlikely(pmd_trans_splitting(*pmd))) {
 				spin_unlock(&mm->page_table_lock);
-				wait_split_huge_page(vma->anon_vma, pmd);
+				wait_split_huge_page(mm, pmd);
 			} else {
 				page = follow_trans_huge_pmd(mm, address,
 							     pmd, flags);
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -225,6 +225,30 @@ void page_unlock_anon_vma(struct anon_vm
 	rcu_read_unlock();
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+/*
+ * Getting a lock on a stable anon_vma from a page off the LRU is
+ * tricky: page_lock_anon_vma rely on RCU to guard against the races.
+ */
+void wait_page_lock_anon_vma(struct page *page)
+{
+	struct anon_vma *anon_vma;
+	unsigned long anon_mapping;
+
+	rcu_read_lock();
+	anon_mapping = (unsigned long) ACCESS_ONCE(page->mapping);
+	if ((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON)
+		goto out;
+	if (!page_mapped(page))
+		goto out;
+
+	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
+	spin_unlock_wait(&anon_vma->lock);
+out:
+	rcu_read_unlock();
+}
+#endif
+
 /*
  * At what user virtual address is page expected in @vma?
  * Returns virtual address or -EFAULT if page's index/offset is not




----
Subject: adapt mincore to anon_vma chain semantics

From: Andrea Arcangeli <aarcange@redhat.com>

wait_split_huge_page interface changed.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -905,7 +905,7 @@ int mincore_huge_pmd(struct vm_area_stru
 		ret = !pmd_trans_splitting(*pmd);
 		spin_unlock(&vma->vm_mm->page_table_lock);
 		if (unlikely(!ret))
-			wait_split_huge_page(vma->anon_vma, pmd);
+			wait_split_huge_page(vma->vm_mm, pmd);
 		else {
 			/*
 			 * All logical pages in the range are present
-----
Subject: adapt mprotect to anon_vma chain semantics

From: Andrea Arcangeli <aarcange@redhat.com>

wait_split_huge_page interface changed.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -929,7 +929,7 @@ int change_huge_pmd(struct vm_area_struc
 	if (likely(pmd_trans_huge(*pmd))) {
 		if (unlikely(pmd_trans_splitting(*pmd))) {
 			spin_unlock(&mm->page_table_lock);
-			wait_split_huge_page(vma->anon_vma, pmd);
+			wait_split_huge_page(mm, pmd);
 		} else {
 			pmd_t entry;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
