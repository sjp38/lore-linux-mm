From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:47:52 +1100
Message-Id: <20070113024752.29682.76413.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 25/29] Abstact mempolicy iterator
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 25
 * Start moving the mempolicy iterator from mempolicy.c to pt_default.c

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 mempolicy.c  |  108 -----------------------------------------------------------
 pt-default.c |   84 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 84 insertions(+), 108 deletions(-)
Index: linux-2.6.20-rc3/mm/mempolicy.c
===================================================================
--- linux-2.6.20-rc3.orig/mm/mempolicy.c	2007-01-09 16:01:20.604363000 +1100
+++ linux-2.6.20-rc3/mm/mempolicy.c	2007-01-09 16:05:35.496363000 +1100
@@ -208,114 +208,6 @@
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
-		 * The check for PageReserved here is important to avoid
-		 * handling zero pages and other pages that may have been
-		 * marked special by the system.
-		 *
-		 * If the PageReserved would not be checked here then f.e.
-		 * the location of the zero page could have an influence
-		 * on MPOL_MF_STRICT, zero pages would be counted for
-		 * the per node stats, and there would be useless attempts
-		 * to put zero pages on the migration list.
-		 */
-		if (PageReserved(page))
-			continue;
-		nid = page_to_nid(page);
-		if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
-			continue;
-
-		if (flags & MPOL_MF_STATS)
-			gather_stats(page, private, pte_dirty(*pte));
-		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
-			migrate_page_add(page, private, flags);
-		else
-			break;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(orig_pte, ptl);
-	return addr != end;
-}
-
-static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
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
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		if (check_pte_range(vma, pmd, addr, next, nodes,
-				    flags, private))
-			return -EIO;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int check_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
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
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		if (check_pmd_range(vma, pud, addr, next, nodes,
-				    flags, private))
-			return -EIO;
-	} while (pud++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int check_pgd_range(struct vm_area_struct *vma,
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
-		if (check_pud_range(vma, pgd, addr, next, nodes,
-				    flags, private))
-			return -EIO;
-	} while (pgd++, addr = next, addr != end);
-	return 0;
-}
-
 /* Check if a vma is migratable */
 static inline int vma_migratable(struct vm_area_struct *vma)
 {
Index: linux-2.6.20-rc3/mm/pt-default.c
===================================================================
--- linux-2.6.20-rc3.orig/mm/pt-default.c	2007-01-09 16:05:30.932363000 +1100
+++ linux-2.6.20-rc3/mm/pt-default.c	2007-01-09 16:05:35.496363000 +1100
@@ -974,3 +974,87 @@
 		smaps_pud_range(vma, pgd, addr, next, mss);
 	} while (pgd++, addr = next, addr != end);
 }
+
+#ifdef CONFIG_NUMA
+/* Scan through pages checking if pages follow certain conditions. */
+static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long addr, unsigned long end,
+		const nodemask_t *nodes, unsigned long flags,
+		void *private)
+{
+	pte_t *orig_pte;
+	pte_t *pte;
+	spinlock_t *ptl;
+	int ret;
+
+	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	do {
+		ret = mempolicy_check_one_pte(vma, addr, pte, nodes, flags, private);
+		if(ret)
+			break;
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(orig_pte, ptl);
+	return addr != end;
+}
+
+static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
+		unsigned long addr, unsigned long end,
+		const nodemask_t *nodes, unsigned long flags,
+		void *private)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		if (check_pte_range(vma, pmd, addr, next, nodes,
+				    flags, private))
+			return -EIO;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int check_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
+		unsigned long addr, unsigned long end,
+		const nodemask_t *nodes, unsigned long flags,
+		void *private)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		if (check_pmd_range(vma, pud, addr, next, nodes,
+				    flags, private))
+			return -EIO;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+int check_policy_read_iterator(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end,
+		const nodemask_t *nodes, unsigned long flags,
+		void *private)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	pgd = pgd_offset(vma->vm_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		if (check_pud_range(vma, pgd, addr, next, nodes,
+				    flags, private))
+			return -EIO;
+	} while (pgd++, addr = next, addr != end);
+	return 0;
+}
+
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
