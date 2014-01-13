Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id BC1C26B0055
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 11:54:44 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so3475075eaj.40
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 08:54:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id p46si29680541eem.231.2014.01.13.08.54.43
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 08:54:44 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 11/11] mempolicy: apply page table walker on queue_pages_range()
Date: Mon, 13 Jan 2014 11:54:11 -0500
Message-Id: <1389632051-25159-12-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1389632051-25159-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1389632051-25159-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

queue_pages_range() does page table walking in its own way now,
so this patch rewrites it with walk_page_range().
One difficulty was that queue_pages_range() needed to check vmas
to determine whether we queue pages from a given vma or skip it.
Now we have test_walk() callback in mm_walk for that purpose,
so we can do the replacement cleanly. queue_pages_test_walk()
depends on not only the current vma but also the previous one,
so we use queue_pages->prev to keep it.

ChangeLog v2:
- rebase onto mmots
- add VM_PFNMAP check on queue_pages_test_walk()

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/mempolicy.c | 255 ++++++++++++++++++++++-----------------------------------
 1 file changed, 99 insertions(+), 156 deletions(-)

diff --git mmotm-2014-01-09-16-23.orig/mm/mempolicy.c mmotm-2014-01-09-16-23/mm/mempolicy.c
index 9bfb1a020aa6..1007bed55678 100644
--- mmotm-2014-01-09-16-23.orig/mm/mempolicy.c
+++ mmotm-2014-01-09-16-23/mm/mempolicy.c
@@ -476,140 +476,66 @@ static const struct mempolicy_operations mpol_ops[MPOL_MAX] = {
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
+static int queue_pages_pte(pte_t *pte, unsigned long addr,
+			unsigned long next, struct mm_walk *walk)
 {
-	pte_t *orig_pte;
-	pte_t *pte;
-	spinlock_t *ptl;
-
-	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	do {
-		struct page *page;
-		int nid;
+	struct vm_area_struct *vma = walk->vma;
+	struct page *page;
+	struct queue_pages *qp = walk->private;
+	unsigned long flags = qp->flags;
+	int nid;
 
-		if (!pte_present(*pte))
-			continue;
-		page = vm_normal_page(vma, addr, *pte);
-		if (!page)
-			continue;
-		/*
-		 * vm_normal_page() filters out zero pages, but there might
-		 * still be PageReserved pages to skip, perhaps in a VDSO.
-		 */
-		if (PageReserved(page))
-			continue;
-		nid = page_to_nid(page);
-		if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
-			continue;
+	if (!pte_present(*pte))
+		return 0;
+	page = vm_normal_page(vma, addr, *pte);
+	if (!page)
+		return 0;
+	/*
+	 * vm_normal_page() filters out zero pages, but there might
+	 * still be PageReserved pages to skip, perhaps in a VDSO.
+	 */
+	if (PageReserved(page))
+		return 0;
+	nid = page_to_nid(page);
+	if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
+		return 0;
 
-		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
-			migrate_page_add(page, private, flags);
-		else
-			break;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(orig_pte, ptl);
-	return addr != end;
+	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+		migrate_page_add(page, qp->pagelist, flags);
+	return 0;
 }
 
-static void queue_pages_hugetlb_pmd_range(struct vm_area_struct *vma,
-		pmd_t *pmd, const nodemask_t *nodes, unsigned long flags,
-				    void *private)
+static int queue_pages_hugetlb(pte_t *pte, unsigned long addr,
+				unsigned long next, struct mm_walk *walk)
 {
 #ifdef CONFIG_HUGETLB_PAGE
+	struct queue_pages *qp = walk->private;
+	unsigned long flags = qp->flags;
 	int nid;
 	struct page *page;
-	spinlock_t *ptl;
 
-	ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pmd);
-	page = pte_page(huge_ptep_get((pte_t *)pmd));
+	page = pte_page(huge_ptep_get(pte));
 	nid = page_to_nid(page);
-	if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
-		goto unlock;
+	if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
+		return 0;
 	/* With MPOL_MF_MOVE, we migrate only unshared hugepage. */
 	if (flags & (MPOL_MF_MOVE_ALL) ||
 	    (flags & MPOL_MF_MOVE && page_mapcount(page) == 1))
-		isolate_huge_page(page, private);
-unlock:
-	spin_unlock(ptl);
+		isolate_huge_page(page, qp->pagelist);
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
 
@@ -643,6 +569,45 @@ static unsigned long change_prot_numa(struct vm_area_struct *vma,
 }
 #endif /* CONFIG_ARCH_USES_NUMA_PROT_NONE */
 
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
+	walk->skip = 1;
+
+	if (vma->vm_flags & VM_PFNMAP)
+		return 0;
+
+	if (flags & MPOL_MF_LAZY) {
+		change_prot_numa(vma, start, endvma);
+		return 0;
+	}
+
+	if ((flags & MPOL_MF_STRICT) ||
+	    ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
+	     vma_migratable(vma)))
+		/* queue pages from current vma */
+		walk->skip = 0;
+	return 0;
+}
+
 /*
  * Walk through page tables and collect pages to be migrated.
  *
@@ -652,51 +617,29 @@ static unsigned long change_prot_numa(struct vm_area_struct *vma,
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
+		.pte_entry = queue_pages_pte,
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
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
