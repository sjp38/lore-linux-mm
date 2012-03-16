Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 192016B00EB
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:04 -0400 (EDT)
Message-Id: <20120316144240.161191161@chello.nl>
Date: Fri, 16 Mar 2012 15:40:29 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 01/26] mm, mpol: Re-implement check_*_range() using walk_page_range()
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=mempol-pagewalk.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

Fixes-by: Dan Smith <danms@us.ibm.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/mempolicy.c |  141 ++++++++++++++++++---------------------------------------
 1 file changed, 45 insertions(+), 96 deletions(-)
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -460,105 +460,45 @@ static const struct mempolicy_operations
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags);
 
-/* Scan through pages checking if pages follow certain conditions. */
-static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long addr, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags,
-		void *private)
-{
-	pte_t *orig_pte;
-	pte_t *pte;
-	spinlock_t *ptl;
-
-	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	do {
-		struct page *page;
-		int nid;
-
-		if (!pte_present(*pte))
-			continue;
-		page = vm_normal_page(vma, addr, *pte);
-		if (!page)
-			continue;
-		/*
-		 * vm_normal_page() filters out zero pages, but there might
-		 * still be PageReserved pages to skip, perhaps in a VDSO.
-		 * And we cannot move PageKsm pages sensibly or safely yet.
-		 */
-		if (PageReserved(page) || PageKsm(page))
-			continue;
-		nid = page_to_nid(page);
-		if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
-			continue;
-
-		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
-			migrate_page_add(page, private, flags);
-		else
-			break;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(orig_pte, ptl);
-	return addr != end;
-}
+struct mempol_walk_data {
+	struct vm_area_struct *vma;
+	const nodemask_t *nodes;
+	unsigned long flags;
+	void *private;
+};
 
-static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
-		unsigned long addr, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags,
-		void *private)
+static int check_pte_entry(pte_t *pte, unsigned long addr,
+			   unsigned long end, struct mm_walk *walk)
 {
-	pmd_t *pmd;
-	unsigned long next;
+	struct mempol_walk_data *data = walk->private;
+	struct page *page;
+	int nid;
 
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		split_huge_page_pmd(vma->vm_mm, pmd);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		if (check_pte_range(vma, pmd, addr, next, nodes,
-				    flags, private))
-			return -EIO;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
+	if (!pte_present(*pte))
+		return 0;
 
-static inline int check_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
-		unsigned long addr, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags,
-		void *private)
-{
-	pud_t *pud;
-	unsigned long next;
+	page = vm_normal_page(data->vma, addr, *pte);
+	if (!page)
+		return 0;
 
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		if (check_pmd_range(vma, pud, addr, next, nodes,
-				    flags, private))
-			return -EIO;
-	} while (pud++, addr = next, addr != end);
-	return 0;
-}
+	/*
+	 * vm_normal_page() filters out zero pages, but there might
+	 * still be PageReserved pages to skip, perhaps in a VDSO.
+	 * And we cannot move PageKsm pages sensibly or safely yet.
+	 */
+	if (PageReserved(page) || PageKsm(page))
+		return 0;
 
-static inline int check_pgd_range(struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags,
-		void *private)
-{
-	pgd_t *pgd;
-	unsigned long next;
+	nid = page_to_nid(page);
+	if (node_isset(nid, *data->nodes) == !!(data->flags & MPOL_MF_INVERT))
+		return 0;
 
-	pgd = pgd_offset(vma->vm_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		if (check_pud_range(vma, pgd, addr, next, nodes,
-				    flags, private))
-			return -EIO;
-	} while (pgd++, addr = next, addr != end);
-	return 0;
+	if (data->flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
+		migrate_page_add(page, data->private, data->flags);
+		return 0;
+	}
+
+	return -EIO;
 }
 
 /*
@@ -570,9 +510,18 @@ static struct vm_area_struct *
 check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 		const nodemask_t *nodes, unsigned long flags, void *private)
 {
-	int err;
 	struct vm_area_struct *first, *vma, *prev;
-
+	struct mempol_walk_data data = {
+		.nodes = nodes,
+		.flags = flags,
+		.private = private,
+	};
+	struct mm_walk walk = {
+		.pte_entry = check_pte_entry,
+		.mm = mm,
+		.private = &data,
+	};
+	int err;
 
 	first = find_vma(mm, start);
 	if (!first)
@@ -595,8 +544,8 @@ check_range(struct mm_struct *mm, unsign
 				endvma = end;
 			if (vma->vm_start > start)
 				start = vma->vm_start;
-			err = check_pgd_range(vma, start, endvma, nodes,
-						flags, private);
+			data.vma = vma;
+			err = walk_page_range(start, endvma, &walk);
 			if (err) {
 				first = ERR_PTR(err);
 				break;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
