Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j9DJMXjV026923
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 12:22:33 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id j9DIK2AQ62741401
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 11:20:02 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id j9DIH1sT95464047
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 11:17:01 -0700 (PDT)
Date: Thu, 13 Oct 2005 11:15:21 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Add page migration support via swap to the NUMA policy layer
Message-ID: <Pine.LNX.4.62.0510131114140.14810@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.62.0510131116550.14847@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel@lists.sourceforge.net
Cc: linux-mm@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

This patch adds page migration support to the NUMA policy layer. An additional
flag MPOL_MF_MOVE is introduced for mbind. If MPOL_MF_MOVE is specified then
pages that do not conform to the memory policy will be evicted from memory.
When they get pages back in new pages will be allocated following the numa policy.

In addition this also adds a move_pages function that may be used from outside
of the policy layer to move pages between nodes (needed by the cpuset support
and the /proc interface). The design is intended to support future direct page
migration without going through swap space.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-rc4/mm/mempolicy.c
===================================================================
--- linux-2.6.14-rc4.orig/mm/mempolicy.c	2005-10-13 10:13:43.000000000 -0700
+++ linux-2.6.14-rc4/mm/mempolicy.c	2005-10-13 11:07:51.000000000 -0700
@@ -83,6 +83,7 @@
 #include <linux/init.h>
 #include <linux/compat.h>
 #include <linux/mempolicy.h>
+#include <linux/swap.h>
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
 
@@ -182,7 +183,8 @@ static struct mempolicy *mpol_new(int mo
 
 /* Ensure all existing pages follow the policy. */
 static int check_pte_range(struct mm_struct *mm, pmd_t *pmd,
-		unsigned long addr, unsigned long end, nodemask_t *nodes)
+		unsigned long addr, unsigned long end,
+		nodemask_t *nodes, struct list_head *pagelist)
 {
 	pte_t *orig_pte;
 	pte_t *pte;
@@ -199,8 +201,14 @@ static int check_pte_range(struct mm_str
 		if (!pfn_valid(pfn))
 			continue;
 		nid = pfn_to_nid(pfn);
-		if (!node_isset(nid, *nodes))
-			break;
+		if (!node_isset(nid, *nodes)) {
+			if (pagelist) {
+				struct page *page = pfn_to_page(pfn);
+
+				WARN_ON(isolate_lru_page(page, pagelist) == 0);
+			} else
+				break;
+		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	pte_unmap(orig_pte);
 	spin_unlock(&mm->page_table_lock);
@@ -208,7 +216,8 @@ static int check_pte_range(struct mm_str
 }
 
 static inline int check_pmd_range(struct mm_struct *mm, pud_t *pud,
-		unsigned long addr, unsigned long end, nodemask_t *nodes)
+		unsigned long addr, unsigned long end,
+		nodemask_t *nodes, struct list_head *pagelist)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -218,14 +227,15 @@ static inline int check_pmd_range(struct
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		if (check_pte_range(mm, pmd, addr, next, nodes))
+		if (check_pte_range(mm, pmd, addr, next, nodes, pagelist))
 			return -EIO;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
 
 static inline int check_pud_range(struct mm_struct *mm, pgd_t *pgd,
-		unsigned long addr, unsigned long end, nodemask_t *nodes)
+		unsigned long addr, unsigned long end,
+		nodemask_t *nodes, struct list_head *pagelist)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -235,14 +245,15 @@ static inline int check_pud_range(struct
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
 			continue;
-		if (check_pmd_range(mm, pud, addr, next, nodes))
+		if (check_pmd_range(mm, pud, addr, next, nodes, pagelist))
 			return -EIO;
 	} while (pud++, addr = next, addr != end);
 	return 0;
 }
 
 static inline int check_pgd_range(struct mm_struct *mm,
-		unsigned long addr, unsigned long end, nodemask_t *nodes)
+		unsigned long addr, unsigned long end,
+		nodemask_t *nodes, struct list_head *pagelist)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -252,7 +263,7 @@ static inline int check_pgd_range(struct
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		if (check_pud_range(mm, pgd, addr, next, nodes))
+		if (check_pud_range(mm, pgd, addr, next, nodes, pagelist))
 			return -EIO;
 	} while (pgd++, addr = next, addr != end);
 	return 0;
@@ -261,7 +272,7 @@ static inline int check_pgd_range(struct
 /* Step 1: check the range */
 static struct vm_area_struct *
 check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
-	    nodemask_t *nodes, unsigned long flags)
+	    nodemask_t *nodes, unsigned long flags, struct list_head *pagelist)
 {
 	int err;
 	struct vm_area_struct *first, *vma, *prev;
@@ -275,14 +286,20 @@ check_range(struct mm_struct *mm, unsign
 			return ERR_PTR(-EFAULT);
 		if (prev && prev->vm_end < vma->vm_start)
 			return ERR_PTR(-EFAULT);
-		if ((flags & MPOL_MF_STRICT) && !is_vm_hugetlb_page(vma)) {
-			unsigned long endvma = vma->vm_end;
+		if (!is_vm_hugetlb_page(vma) &&
+		    ((flags & MPOL_MF_STRICT) ||
+		     ((flags & MPOL_MF_MOVE) &&
+		      ((vma->vm_flags & (VM_LOCKED|VM_IO|VM_RESERVED|VM_DENYWRITE|VM_SHM))==0)
+		   ))) {
+			unsigned long endvma;
+
+			endvma = vma->vm_end;
 			if (endvma > end)
 				endvma = end;
 			if (vma->vm_start > start)
 				start = vma->vm_start;
 			err = check_pgd_range(vma->vm_mm,
-					   start, endvma, nodes);
+					   start, endvma, nodes, pagelist);
 			if (err) {
 				first = ERR_PTR(err);
 				break;
@@ -293,6 +310,36 @@ check_range(struct mm_struct *mm, unsign
 	return first;
 }
 
+/*
+ * Main entry point to page migration.
+ * For now move_pages simply swaps out the pages from nodes that are in
+ * the source set but not in the target set. In the future, we would
+ * want a function that moves pages between the two nodesets in such
+ * a way as to preserve the physical layout as much as possible.
+ *
+ * Returns the number of page that could not be moved.
+ */
+int move_pages(struct mm_struct *mm, unsigned long start, unsigned long end,
+	nodemask_t *from_nodes, nodemask_t *to_nodes)
+{
+	LIST_HEAD(pagelist);
+	int count = 0;
+	nodemask_t nodes;
+
+	nodes_andnot(nodes, *from_nodes, *to_nodes);
+	nodes_complement(nodes, nodes);
+
+	down_read(&mm->mmap_sem);
+	check_range(mm, start, end, &nodes, MPOL_MF_MOVE, &pagelist);
+	if (!list_empty(&pagelist)) {
+		swapout_pages(&pagelist);
+		if (!list_empty(&pagelist))
+			count = putback_lru_pages(&pagelist);
+	}
+	up_read(&mm->mmap_sem);
+	return count;
+}
+
 /* Apply policy to a single VMA */
 static int policy_vma(struct vm_area_struct *vma, struct mempolicy *new)
 {
@@ -356,21 +403,28 @@ long do_mbind(unsigned long start, unsig
 	struct mempolicy *new;
 	unsigned long end;
 	int err;
+	LIST_HEAD(pagelist);
 
-	if ((flags & ~(unsigned long)(MPOL_MF_STRICT)) || mode > MPOL_MAX)
+	if ((flags & ~(unsigned long)(MPOL_MF_STRICT | MPOL_MF_MOVE))
+	    || mode > MPOL_MAX)
 		return -EINVAL;
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
+
 	if (mode == MPOL_DEFAULT)
 		flags &= ~MPOL_MF_STRICT;
+
 	len = (len + PAGE_SIZE - 1) & PAGE_MASK;
 	end = start + len;
+
 	if (end < start)
 		return -EINVAL;
 	if (end == start)
 		return 0;
+
 	if (contextualize_policy(mode, nmask))
 		return -EINVAL;
+
 	new = mpol_new(mode, nmask);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
@@ -379,10 +433,19 @@ long do_mbind(unsigned long start, unsig
 			mode,nodes_addr(nodes)[0]);
 
 	down_write(&mm->mmap_sem);
-	vma = check_range(mm, start, end, nmask, flags);
+	vma = check_range(mm, start, end, nmask, flags,
+			  (flags & MPOL_MF_MOVE) ? &pagelist : NULL);
 	err = PTR_ERR(vma);
-	if (!IS_ERR(vma))
+	if (!IS_ERR(vma)) {
 		err = mbind_range(vma, start, end, new);
+		if (!list_empty(&pagelist))
+			swapout_pages(&pagelist);
+		if (!err  && !list_empty(&pagelist) && (flags & MPOL_MF_STRICT))
+				err = -EIO;
+	}
+	if (!list_empty(&pagelist))
+		putback_lru_pages(&pagelist);
+
 	up_write(&mm->mmap_sem);
 	mpol_free(new);
 	return err;
Index: linux-2.6.14-rc4/include/linux/mempolicy.h
===================================================================
--- linux-2.6.14-rc4.orig/include/linux/mempolicy.h	2005-10-13 10:13:43.000000000 -0700
+++ linux-2.6.14-rc4/include/linux/mempolicy.h	2005-10-13 10:14:10.000000000 -0700
@@ -22,6 +22,7 @@
 
 /* Flags for mbind */
 #define MPOL_MF_STRICT	(1<<0)	/* Verify existing pages in the mapping */
+#define MPOL_MF_MOVE	(1<<1)	/* Move pages to specified nodes */
 
 #ifdef __KERNEL__
 
@@ -157,6 +158,9 @@ extern void numa_default_policy(void);
 extern void numa_policy_init(void);
 extern struct mempolicy default_policy;
 
+extern int move_pages(struct mm_struct *mm, unsigned long from, unsigned long to,
+			nodemask_t *from_nodes, nodemask_t *to_nodes);
+
 #else
 
 struct mempolicy {};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
