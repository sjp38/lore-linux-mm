Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By note With Smtp ;
	Tue, 30 May 2006 17:36:37 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:36:36 +1000 (EST)
Subject: [Patch 14/17] PTI: Abstract mempolicy iterator
Message-ID: <Pine.LNX.4.61.0605301734530.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Finish the swapfile abstraction.

  Abstract mempolicy iterator for NUMA.

  include/linux/default-pt-read-iterators.h |   88 ++++++++++++++++++
  include/linux/default-pt.h                |    1
  mm/mempolicy.c                            |  144 
++++++++----------------------
  mm/swapfile.c                             |   19 +++
  4 files changed, 146 insertions(+), 106 deletions(-)
Index: linux-rc5/mm/swapfile.c
===================================================================
--- linux-rc5.orig/mm/swapfile.c	2006-05-28 20:30:09.237586464 
+1000
+++ linux-rc5/mm/swapfile.c	2006-05-28 20:30:20.677279104 +1000
@@ -28,6 +28,7 @@
  #include <linux/mutex.h>
  #include <linux/capability.h>
  #include <linux/syscalls.h>
+#include <linux/default-pt.h>

  #include <asm/pgtable.h>
  #include <asm/tlbflush.h>
@@ -499,9 +500,25 @@
  	activate_page(page);
  }

+static int unuse_vma(struct vm_area_struct *vma,
+				swp_entry_t entry, struct page *page)
+{
+	unsigned long addr, end;

+	if (page->mapping) {
+		addr = page_address_in_vma(page, vma);
+		if (addr == -EFAULT)
+			return 0;
+		else
+			end = addr + PAGE_SIZE;
+	} else {
+		addr = vma->vm_start;
+		end = vma->vm_end;
+	}

-
+	return unuse_vma_read_iterator(vma, addr, end,
+		entry, page, unuse_pte);
+}

  static int unuse_mm(struct mm_struct *mm,
  				swp_entry_t entry, struct page *page)
Index: linux-rc5/include/linux/default-pt-read-iterators.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt-read-iterators.h	2006-05-28 
20:30:09.238587312 +1000
+++ linux-rc5/include/linux/default-pt-read-iterators.h	2006-05-28 
20:30:20.678279952 +1000
@@ -410,5 +410,93 @@
  	return 0;
  }

+#ifdef CONFIG_NUMA
+
+/*
+ * check_policy_read_iterator: Called in mempolicy.c
+ */
+
+typedef int (*mempolicy_check_pte_t)(struct vm_area_struct *vma, unsigned 
long addr,
+		pte_t *pte, const nodemask_t *, unsigned long, void *);
+
+/* Scan through pages checking if pages follow certain conditions. */
+static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long addr, unsigned long end,
+		const nodemask_t *nodes, unsigned long flags,
+		void *private, mempolicy_check_pte_t func)
+{
+	pte_t *orig_pte;
+	pte_t *pte;
+	spinlock_t *ptl;
+	int ret;
+
+	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	do {
+		ret = func(vma, addr, pte, nodes, flags, private);
+		if(ret)
+			break;
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(orig_pte, ptl);
+	return addr != end;
+}
+
+static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
+		unsigned long addr, unsigned long end, const nodemask_t 
*nodes,
+		unsigned long flags, void *private, mempolicy_check_pte_t 
func)
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
+				    flags, private, func))
+			return -EIO;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int check_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
+		unsigned long addr, unsigned long end, const nodemask_t 
*nodes,
+		unsigned long flags, void *private, mempolicy_check_pte_t 
func)
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
+				    flags, private, func))
+			return -EIO;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int check_policy_read_iterator(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end, const nodemask_t 
*nodes,
+		unsigned long flags, void *private, mempolicy_check_pte_t 
func)
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
+				    flags, private, func))
+			return -EIO;
+	} while (pgd++, addr = next, addr != end);
+	return 0;
+}
+
+#endif

  #endif
Index: linux-rc5/mm/mempolicy.c
===================================================================
--- linux-rc5.orig/mm/mempolicy.c	2006-05-28 20:30:09.238587312 
+1000
+++ linux-rc5/mm/mempolicy.c	2006-05-28 20:30:20.679280800 +1000
@@ -87,6 +87,7 @@
  #include <linux/seq_file.h>
  #include <linux/proc_fs.h>
  #include <linux/migrate.h>
+#include <linux/default-pt.h>

  #include <asm/tlbflush.h>
  #include <asm/uaccess.h>
@@ -199,111 +200,44 @@
  static void migrate_page_add(struct page *page, struct list_head 
*pagelist,
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
+int mempolicy_check_pte(struct vm_area_struct *vma, unsigned long addr,
+				pte_t *pte, const nodemask_t *nodes, 
unsigned long flags,
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

@@ -356,8 +290,8 @@
  				endvma = end;
  			if (vma->vm_start > start)
  				start = vma->vm_start;
-			err = check_pgd_range(vma, start, endvma, nodes,
-						flags, private);
+			err = check_policy_read_iterator(vma, start, 
endvma, nodes,
+						flags, private, 
mempolicy_check_pte);
  			if (err) {
  				first = ERR_PTR(err);
  				break;
@@ -1833,8 +1767,8 @@
  		check_huge_range(vma, vma->vm_start, vma->vm_end, md);
  		seq_printf(m, " huge");
  	} else {
-		check_pgd_range(vma, vma->vm_start, vma->vm_end,
-				&node_online_map, MPOL_MF_STATS, md);
+		check_policy_read_iterator(vma, vma->vm_start, 
vma->vm_end,
+				&node_online_map, MPOL_MF_STATS, md, 
mempolicy_check_pte);
  	}

  	if (!md->pages)
Index: linux-rc5/include/linux/default-pt.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt.h	2006-05-28 
20:30:09.238587312 +1000
+++ linux-rc5/include/linux/default-pt.h	2006-05-28 
20:30:20.680281648 +1000
@@ -3,6 +3,7 @@

  #include <linux/swap.h>
  #include <linux/swapops.h>
+#include <linux/rmap.h>

  #include <asm/tlb.h>
  #include <asm/pgalloc.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
