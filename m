Date: Mon, 17 Oct 2005 17:49:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20051018004942.3191.44835.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 2/2] Page migration via Swap V2: MPOL_MF_MOVE interface
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, ak@suse.de, Christoph Lameter <clameter@sgi.com>, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This patch adds page migration support to the NUMA policy layer. An additional
flag MPOL_MF_MOVE is introduced for mbind. If MPOL_MF_MOVE is specified then
pages that do not conform to the memory policy will be evicted from memory.
When they get pages back in new pages will be allocated following the numa policy.

Version 2
- Add vma_migratable() function for future enhancements.
- Remove function with side effects from WARN_ON
- Remove move_pages
- Make patch fit 2.6.14-rc4-mm1

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-rc4-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.14-rc4-mm1.orig/mm/mempolicy.c	2005-10-17 10:24:16.000000000 -0700
+++ linux-2.6.14-rc4-mm1/mm/mempolicy.c	2005-10-17 17:37:39.000000000 -0700
@@ -83,6 +83,7 @@
 #include <linux/init.h>
 #include <linux/compat.h>
 #include <linux/mempolicy.h>
+#include <linux/swap.h>
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
 
@@ -181,7 +182,8 @@ static struct mempolicy *mpol_new(int mo
 
 /* Ensure all existing pages follow the policy. */
 static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long addr, unsigned long end, nodemask_t *nodes)
+		unsigned long addr, unsigned long end,
+		nodemask_t *nodes, struct list_head *pagelist)
 {
 	pte_t *orig_pte;
 	pte_t *pte;
@@ -200,15 +202,28 @@ static int check_pte_range(struct vm_are
 			continue;
 		}
 		nid = pfn_to_nid(pfn);
-		if (!node_isset(nid, *nodes))
-			break;
+		if (!node_isset(nid, *nodes)) {
+			if (pagelist) {
+				struct page *page = pfn_to_page(pfn);
+				int rc = isolate_lru_page(page, pagelist);
+
+				/*
+				 * If the isolate attempt was not successful
+				 * then we just encountered an unswappable
+				 * page. Something must be wrong.
+			 	 */
+				WARN_ON(rc == 0);
+			} else
+				break;
+		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	pte_unmap_unlock(orig_pte, ptl);
 	return addr != end;
 }
 
 static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
-		unsigned long addr, unsigned long end, nodemask_t *nodes)
+		unsigned long addr, unsigned long end,
+		nodemask_t *nodes, struct list_head *pagelist)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -218,14 +233,15 @@ static inline int check_pmd_range(struct
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		if (check_pte_range(vma, pmd, addr, next, nodes))
+		if (check_pte_range(vma, pmd, addr, next, nodes, pagelist))
 			return -EIO;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
 
 static inline int check_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
-		unsigned long addr, unsigned long end, nodemask_t *nodes)
+		unsigned long addr, unsigned long end,
+		nodemask_t *nodes, struct list_head *pagelist)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -235,14 +251,15 @@ static inline int check_pud_range(struct
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
 			continue;
-		if (check_pmd_range(vma, pud, addr, next, nodes))
+		if (check_pmd_range(vma, pud, addr, next, nodes, pagelist))
 			return -EIO;
 	} while (pud++, addr = next, addr != end);
 	return 0;
 }
 
 static inline int check_pgd_range(struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end, nodemask_t *nodes)
+		unsigned long addr, unsigned long end,
+		nodemask_t *nodes, struct list_head *pagelist)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -252,16 +269,30 @@ static inline int check_pgd_range(struct
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		if (check_pud_range(vma, pgd, addr, next, nodes))
+		if (check_pud_range(vma, pgd, addr, next, nodes, pagelist))
 			return -EIO;
 	} while (pgd++, addr = next, addr != end);
 	return 0;
 }
 
+/* Check if a vma is migratable */
+static inline int vma_migratable(struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & (
+			VM_LOCKED |
+			VM_IO |
+			VM_RESERVED |
+			VM_DENYWRITE |
+			VM_SHM
+	   ))
+		return 0;
+	return 1;
+}
+
 /* Step 1: check the range */
 static struct vm_area_struct *
 check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
-	    nodemask_t *nodes, unsigned long flags)
+	    nodemask_t *nodes, unsigned long flags, struct list_head *pagelist)
 {
 	int err;
 	struct vm_area_struct *first, *vma, *prev;
@@ -277,13 +308,16 @@ check_range(struct mm_struct *mm, unsign
 			return ERR_PTR(-EFAULT);
 		if (prev && prev->vm_end < vma->vm_start)
 			return ERR_PTR(-EFAULT);
-		if ((flags & MPOL_MF_STRICT) && !is_vm_hugetlb_page(vma)) {
+		if (!is_vm_hugetlb_page(vma) &&
+		    ((flags & MPOL_MF_STRICT) ||
+		     ((flags & MPOL_MF_MOVE) && vma_migratable(vma))
+		   )) {
 			unsigned long endvma = vma->vm_end;
 			if (endvma > end)
 				endvma = end;
 			if (vma->vm_start > start)
 				start = vma->vm_start;
-			err = check_pgd_range(vma, start, endvma, nodes);
+			err = check_pgd_range(vma, start, endvma, nodes, pagelist);
 			if (err) {
 				first = ERR_PTR(err);
 				break;
@@ -357,21 +391,28 @@ long do_mbind(unsigned long start, unsig
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
 	if (mpol_check_policy(mode, nmask))
 		return -EINVAL;
+
 	new = mpol_new(mode, nmask);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
@@ -380,10 +421,19 @@ long do_mbind(unsigned long start, unsig
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
Index: linux-2.6.14-rc4-mm1/include/linux/mempolicy.h
===================================================================
--- linux-2.6.14-rc4-mm1.orig/include/linux/mempolicy.h	2005-10-17 10:24:13.000000000 -0700
+++ linux-2.6.14-rc4-mm1/include/linux/mempolicy.h	2005-10-17 17:33:34.000000000 -0700
@@ -22,6 +22,7 @@
 
 /* Flags for mbind */
 #define MPOL_MF_STRICT	(1<<0)	/* Verify existing pages in the mapping */
+#define MPOL_MF_MOVE	(1<<1)	/* Move pages to conform to mapping */
 
 #ifdef __KERNEL__
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
