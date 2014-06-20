Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id B5D226B0062
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 16:12:11 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id x13so4132011wgg.33
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 13:12:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id eh8si3944353wic.28.2014.06.20.13.12.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jun 2014 13:12:10 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 11/13] mempolicy: apply page table walker on queue_pages_range()
Date: Fri, 20 Jun 2014 16:11:37 -0400
Message-Id: <1403295099-6407-12-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

queue_pages_range() does page table walking in its own way now, but there
is some code duplicate. This patch applies page table walker to reduce
lines of code.

queue_pages_range() has to do some precheck to determine whether we really
walk over the vma or just skip it. Now we have test_walk() callback in
mm_walk for this purpose, so we can do this replacement cleanly.
queue_pages_test_walk() depends on not only the current vma but also the
previous one, so queue_pages->prev is introduced to remember it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/mempolicy.c | 228 +++++++++++++++++++++++----------------------------------
 1 file changed, 93 insertions(+), 135 deletions(-)

diff --git v3.16-rc1.orig/mm/mempolicy.c v3.16-rc1/mm/mempolicy.c
index 284974230459..17467d476c63 100644
--- v3.16-rc1.orig/mm/mempolicy.c
+++ v3.16-rc1/mm/mempolicy.c
@@ -479,24 +479,34 @@ static const struct mempolicy_operations mpol_ops[MPOL_MAX] = {
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags);
 
+struct queue_pages {
+	struct list_head *pagelist;
+	unsigned long flags;
+	nodemask_t *nmask;
+	struct vm_area_struct *prev;
+};
+
 /*
  * Scan through pages checking if pages follow certain conditions,
  * and move them to the pagelist if they do.
  */
-static int queue_pages_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long addr, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags,
-		void *private)
+static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
+			unsigned long end, struct mm_walk *walk)
 {
-	pte_t *orig_pte;
+	struct vm_area_struct *vma = walk->vma;
+	struct page *page;
+	struct queue_pages *qp = walk->private;
+	unsigned long flags = qp->flags;
+	int nid;
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	do {
-		struct page *page;
-		int nid;
+	split_huge_page_pmd(vma, addr, pmd);
+	if (pmd_trans_unstable(pmd))
+		return 0;
 
+	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE) {
 		if (!pte_present(*pte))
 			continue;
 		page = vm_normal_page(vma, addr, *pte);
@@ -509,114 +519,46 @@ static int queue_pages_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		if (PageReserved(page))
 			continue;
 		nid = page_to_nid(page);
-		if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
+		if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
 			continue;
 
 		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
-			migrate_page_add(page, private, flags);
-		else
-			break;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(orig_pte, ptl);
-	return addr != end;
+			migrate_page_add(page, qp->pagelist, flags);
+	}
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+	return 0;
 }
 
-static void queue_pages_hugetlb_pmd_range(struct vm_area_struct *vma,
-		pmd_t *pmd, const nodemask_t *nodes, unsigned long flags,
-				    void *private)
+static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
+			       unsigned long addr, unsigned long end,
+			       struct mm_walk *walk)
 {
 #ifdef CONFIG_HUGETLB_PAGE
+	struct queue_pages *qp = walk->private;
+	unsigned long flags = qp->flags;
 	int nid;
 	struct page *page;
 	spinlock_t *ptl;
 	pte_t entry;
 
-	ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pmd);
-	entry = huge_ptep_get((pte_t *)pmd);
+	ptl = huge_pte_lock(hstate_vma(walk->vma), walk->mm, pte);
+	entry = huge_ptep_get(pte);
 	if (!pte_present(entry))
 		goto unlock;
 	page = pte_page(entry);
 	nid = page_to_nid(page);
-	if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
+	if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
 		goto unlock;
 	/* With MPOL_MF_MOVE, we migrate only unshared hugepage. */
 	if (flags & (MPOL_MF_MOVE_ALL) ||
 	    (flags & MPOL_MF_MOVE && page_mapcount(page) == 1))
-		isolate_huge_page(page, private);
+		isolate_huge_page(page, qp->pagelist);
 unlock:
 	spin_unlock(ptl);
 #else
 	BUG();
 #endif
-}
-
-static inline int queue_pages_pmd_range(struct vm_area_struct *vma, pud_t *pud,
-		unsigned long addr, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags,
-		void *private)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (!pmd_present(*pmd))
-			continue;
-		if (pmd_huge(*pmd) && is_vm_hugetlb_page(vma)) {
-			queue_pages_hugetlb_pmd_range(vma, pmd, nodes,
-						flags, private);
-			continue;
-		}
-		split_huge_page_pmd(vma, addr, pmd);
-		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
-			continue;
-		if (queue_pages_pte_range(vma, pmd, addr, next, nodes,
-				    flags, private))
-			return -EIO;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int queue_pages_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
-		unsigned long addr, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags,
-		void *private)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_huge(*pud) && is_vm_hugetlb_page(vma))
-			continue;
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		if (queue_pages_pmd_range(vma, pud, addr, next, nodes,
-				    flags, private))
-			return -EIO;
-	} while (pud++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int queue_pages_pgd_range(struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags,
-		void *private)
-{
-	pgd_t *pgd;
-	unsigned long next;
-
-	pgd = pgd_offset(vma->vm_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		if (queue_pages_pud_range(vma, pgd, addr, next, nodes,
-				    flags, private))
-			return -EIO;
-	} while (pgd++, addr = next, addr != end);
 	return 0;
 }
 
@@ -649,6 +591,44 @@ static unsigned long change_prot_numa(struct vm_area_struct *vma,
 }
 #endif /* CONFIG_NUMA_BALANCING */
 
+static int queue_pages_test_walk(unsigned long start, unsigned long end,
+				struct mm_walk *walk)
+{
+	struct vm_area_struct *vma = walk->vma;
+	struct queue_pages *qp = walk->private;
+	unsigned long endvma = vma->vm_end;
+	unsigned long flags = qp->flags;
+
+	if (endvma > end)
+		endvma = end;
+	if (vma->vm_start > start)
+		start = vma->vm_start;
+
+	if (!(flags & MPOL_MF_DISCONTIG_OK)) {
+		if (!vma->vm_next && vma->vm_end < end)
+			return -EFAULT;
+		if (qp->prev && qp->prev->vm_end < vma->vm_start)
+			return -EFAULT;
+	}
+
+	qp->prev = vma;
+
+	if (vma->vm_flags & VM_PFNMAP)
+		return 1;
+
+	if (flags & MPOL_MF_LAZY) {
+		change_prot_numa(vma, start, endvma);
+		return 1;
+	}
+
+	if ((flags & MPOL_MF_STRICT) ||
+	    ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
+	     vma_migratable(vma)))
+		/* queue pages from current vma */
+		return 0;
+	return 1;
+}
+
 /*
  * Walk through page tables and collect pages to be migrated.
  *
@@ -658,51 +638,29 @@ static unsigned long change_prot_numa(struct vm_area_struct *vma,
  */
 static struct vm_area_struct *
 queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags, void *private)
+		nodemask_t *nodes, unsigned long flags,
+		struct list_head *pagelist)
 {
 	int err;
-	struct vm_area_struct *first, *vma, *prev;
-
-
-	first = find_vma(mm, start);
-	if (!first)
-		return ERR_PTR(-EFAULT);
-	prev = NULL;
-	for (vma = first; vma && vma->vm_start < end; vma = vma->vm_next) {
-		unsigned long endvma = vma->vm_end;
-
-		if (endvma > end)
-			endvma = end;
-		if (vma->vm_start > start)
-			start = vma->vm_start;
-
-		if (!(flags & MPOL_MF_DISCONTIG_OK)) {
-			if (!vma->vm_next && vma->vm_end < end)
-				return ERR_PTR(-EFAULT);
-			if (prev && prev->vm_end < vma->vm_start)
-				return ERR_PTR(-EFAULT);
-		}
-
-		if (flags & MPOL_MF_LAZY) {
-			change_prot_numa(vma, start, endvma);
-			goto next;
-		}
-
-		if ((flags & MPOL_MF_STRICT) ||
-		     ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
-		      vma_migratable(vma))) {
-
-			err = queue_pages_pgd_range(vma, start, endvma, nodes,
-						flags, private);
-			if (err) {
-				first = ERR_PTR(err);
-				break;
-			}
-		}
-next:
-		prev = vma;
-	}
-	return first;
+	struct queue_pages qp = {
+		.pagelist = pagelist,
+		.flags = flags,
+		.nmask = nodes,
+		.prev = NULL,
+	};
+	struct mm_walk queue_pages_walk = {
+		.hugetlb_entry = queue_pages_hugetlb,
+		.pmd_entry = queue_pages_pte_range,
+		.test_walk = queue_pages_test_walk,
+		.mm = mm,
+		.private = &qp,
+	};
+
+	err = walk_page_range(start, end, &queue_pages_walk);
+	if (err < 0)
+		return ERR_PTR(err);
+	else
+		return find_vma(mm, start);
 }
 
 /*
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
