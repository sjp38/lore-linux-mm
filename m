From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:29:40 +1000
Message-Id: <20060713042940.9978.24934.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 18/18] PTI - Mempolicy iterator abstraction
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

Abstracts mempolicy iterator from mempolicy.c and 
puts it in pt_default.c

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 mempolicy.c  |  140 +++++++++++++++--------------------------------------------
 pt-default.c |   83 ++++++++++++++++++++++++++++++++++
 2 files changed, 120 insertions(+), 103 deletions(-)
Index: linux-2.6.17.2/mm/mempolicy.c
===================================================================
--- linux-2.6.17.2.orig/mm/mempolicy.c	2006-06-30 10:17:23.000000000 +1000
+++ linux-2.6.17.2/mm/mempolicy.c	2006-07-08 22:04:39.561542952 +1000
@@ -87,6 +87,7 @@
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
 #include <linux/migrate.h>
+#include <linux/pt.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -199,111 +200,44 @@
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
-		unsigned int nid;
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
+int mempolicy_check_one_pte(struct vm_area_struct *vma, unsigned long addr,
+				pte_t *pte, const nodemask_t *nodes, unsigned long flags,
+				void *private)
 {
-	pud_t *pud;
-	unsigned long next;
+	struct page *page;
+	unsigned int nid;
 
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
+	if (!pte_present(*pte))
+		return 0;
+	page = vm_normal_page(vma, addr, *pte);
+	if (!page)
+		return 0;
+	if (!page)
+			return 0;
+	/*
+	 * The check for PageReserved here is important to avoid
+	 * handling zero pages and other pages that may have been
+	 * marked special by the system.
+	 *
+	 * If the PageReserved would not be checked here then f.e.
+	 * the location of the zero page could have an influence
+	 * on MPOL_MF_STRICT, zero pages would be counted for
+	 * the per node stats, and there would be useless attempts
+	 * to put zero pages on the migration list.
+	 */
+	if (PageReserved(page))
+		return 0;
+	nid = page_to_nid(page);
+	if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
+		return 0;
 
-static inline int check_pgd_range(struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags,
-		void *private)
-{
-	pgd_t *pgd;
-	unsigned long next;
+	if (flags & MPOL_MF_STATS)
+		gather_stats(page, private, pte_dirty(*pte));
+	else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+		migrate_page_add(page, private, flags);
+	else
+		return 1;
 
-	pgd = pgd_offset(vma->vm_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		if (check_pud_range(vma, pgd, addr, next, nodes,
-				    flags, private))
-			return -EIO;
-	} while (pgd++, addr = next, addr != end);
 	return 0;
 }
 
@@ -356,7 +290,7 @@
 				endvma = end;
 			if (vma->vm_start > start)
 				start = vma->vm_start;
-			err = check_pgd_range(vma, start, endvma, nodes,
+			err = check_policy_read_iterator(vma, start, endvma, nodes,
 						flags, private);
 			if (err) {
 				first = ERR_PTR(err);
@@ -1833,7 +1767,7 @@
 		check_huge_range(vma, vma->vm_start, vma->vm_end, md);
 		seq_printf(m, " huge");
 	} else {
-		check_pgd_range(vma, vma->vm_start, vma->vm_end,
+		check_policy_read_iterator(vma, vma->vm_start, vma->vm_end,
 				&node_online_map, MPOL_MF_STATS, md);
 	}
 
Index: linux-2.6.17.2/mm/pt-default.c
===================================================================
--- linux-2.6.17.2.orig/mm/pt-default.c	2006-07-08 22:01:25.216087952 +1000
+++ linux-2.6.17.2/mm/pt-default.c	2006-07-08 22:06:07.221216656 +1000
@@ -1121,3 +1121,86 @@
 	} while (pgd++, addr = next, addr != end);
 	return 0;
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
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
