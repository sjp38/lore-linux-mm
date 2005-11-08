Date: Tue, 8 Nov 2005 15:24:48 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH 1/2] private pointer in check_range and MPOL_MF_INVERT
Message-ID: <Pine.LNX.4.62.0511081520540.32262@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

A part of this functionality is also contained in the direct migration
pathset. The functionality here is more generic and independent of that
patchset. If this patch gets accepted then the policy layer updates
of the next direct migration patchset may be simplified.

- Add internal flag MPOL_MF_INVERT to control check_range() behavior.

- Replace the pagelist passed through check range by a general
  private pointer that may be used for other purposes.
  (The following patch will use that to merge numa_maps into
  mempolicy.c)

- Improve some comments.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.14-mm1.orig/mm/mempolicy.c	2005-11-07 11:48:26.000000000 -0800
+++ linux-2.6.14-mm1/mm/mempolicy.c	2005-11-08 14:59:31.000000000 -0800
@@ -87,8 +87,9 @@
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
 
-/* Internal MPOL_MF_xxx flags */
+/* Internal flags */
 #define MPOL_MF_DISCONTIG_OK (1<<20)	/* Skip checks for continuous vmas */
+#define MPOL_MF_INVERT (1<<21)		/* Invert check for nodemask */
 
 static kmem_cache_t *policy_cache;
 static kmem_cache_t *sn_cache;
@@ -234,11 +235,11 @@ static void migrate_page_add(struct vm_a
 	}
 }
 
-/* Ensure all existing pages follow the policy. */
+/* Scan through pages checking if pages follow certain conditions. */
 static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end,
 		const nodemask_t *nodes, unsigned long flags,
-		struct list_head *pagelist)
+		void *private)
 {
 	pte_t *orig_pte;
 	pte_t *pte;
@@ -248,6 +249,7 @@ static int check_pte_range(struct vm_are
 	do {
 		unsigned long pfn;
 		unsigned int nid;
+		struct page *page;
 
 		if (!pte_present(*pte))
 			continue;
@@ -256,15 +258,16 @@ static int check_pte_range(struct vm_are
 			print_bad_pte(vma, *pte, addr);
 			continue;
 		}
-		nid = pfn_to_nid(pfn);
-		if (!node_isset(nid, *nodes)) {
-			if (pagelist) {
-				struct page *page = pfn_to_page(pfn);
+		page = pfn_to_page(pfn);
+		nid = page_to_nid(page);
+		if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
+			continue;
+
+		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+			migrate_page_add(vma, page, private, flags);
+		else
+			break;
 
-				migrate_page_add(vma, page, pagelist, flags);
-			} else
-				break;
-		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	pte_unmap_unlock(orig_pte, ptl);
 	return addr != end;
@@ -273,7 +276,7 @@ static int check_pte_range(struct vm_are
 static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 		unsigned long addr, unsigned long end,
 		const nodemask_t *nodes, unsigned long flags,
-		struct list_head *pagelist)
+		void *private)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -284,7 +287,7 @@ static inline int check_pmd_range(struct
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		if (check_pte_range(vma, pmd, addr, next, nodes,
-				    flags, pagelist))
+				    flags, private))
 			return -EIO;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
@@ -293,7 +296,7 @@ static inline int check_pmd_range(struct
 static inline int check_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 		unsigned long addr, unsigned long end,
 		const nodemask_t *nodes, unsigned long flags,
-		struct list_head *pagelist)
+		void *private)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -304,7 +307,7 @@ static inline int check_pud_range(struct
 		if (pud_none_or_clear_bad(pud))
 			continue;
 		if (check_pmd_range(vma, pud, addr, next, nodes,
-				    flags, pagelist))
+				    flags, private))
 			return -EIO;
 	} while (pud++, addr = next, addr != end);
 	return 0;
@@ -313,7 +316,7 @@ static inline int check_pud_range(struct
 static inline int check_pgd_range(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end,
 		const nodemask_t *nodes, unsigned long flags,
-		struct list_head *pagelist)
+		void *private)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -324,7 +327,7 @@ static inline int check_pgd_range(struct
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
 		if (check_pud_range(vma, pgd, addr, next, nodes,
-				    flags, pagelist))
+				    flags, private))
 			return -EIO;
 	} while (pgd++, addr = next, addr != end);
 	return 0;
@@ -351,7 +354,7 @@ static inline int vma_migratable(struct 
  */
 static struct vm_area_struct *
 check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
-	    const nodemask_t *nodes, unsigned long flags, struct list_head *pagelist)
+	    const nodemask_t *nodes, unsigned long flags, void *private)
 {
 	int err;
 	struct vm_area_struct *first, *vma, *prev;
@@ -380,7 +383,7 @@ check_range(struct mm_struct *mm, unsign
 			if (vma->vm_start > start)
 				start = vma->vm_start;
 			err = check_pgd_range(vma, start, endvma, nodes,
-						flags, pagelist);
+						flags, private);
 			if (err) {
 				first = ERR_PTR(err);
 				break;
@@ -455,9 +458,11 @@ long do_mbind(unsigned long start, unsig
 	int err;
 	LIST_HEAD(pagelist);
 
-	if ((flags & ~(unsigned long)(MPOL_MF_STRICT | MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+	if ((flags & ~(unsigned long)(MPOL_MF_STRICT |
+				      MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
 	    || mode > MPOL_MAX)
 		return -EINVAL;
+
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_RESOURCE))
 		return -EPERM;
 
@@ -493,8 +498,9 @@ long do_mbind(unsigned long start, unsig
 			mode,nodes_addr(nodes)[0]);
 
 	down_write(&mm->mmap_sem);
-	vma = check_range(mm, start, end, nmask, flags,
-	      (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) ? &pagelist : NULL);
+	vma = check_range(mm, start, end, nmask,
+			  flags | MPOL_MF_INVERT, &pagelist);
+
 	err = PTR_ERR(vma);
 	if (!IS_ERR(vma)) {
 		err = mbind_range(vma, start, end, new);
@@ -646,7 +652,6 @@ int do_migrate_pages(struct mm_struct *m
 	nodemask_t nodes;
 
 	nodes_andnot(nodes, *from_nodes, *to_nodes);
-	nodes_complement(nodes, nodes);
 
 	down_read(&mm->mmap_sem);
 	check_range(mm, mm->mmap->vm_start, TASK_SIZE, &nodes,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
