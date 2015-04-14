Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 304106B0078
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 16:57:00 -0400 (EDT)
Received: by iget9 with SMTP id t9so83389921ige.1
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 13:57:00 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id c18si11488686igr.39.2015.04.14.13.56.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 13:56:46 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [RFC 09/11] mm: debug: kill VM_BUG_ON_VMA
Date: Tue, 14 Apr 2015 16:56:31 -0400
Message-Id: <1429044993-1677-10-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org

Just use VM_BUG() instead.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/huge_mm.h |    2 +-
 include/linux/mmdebug.h |    8 --------
 include/linux/rmap.h    |    2 +-
 mm/gup.c                |    4 ++--
 mm/huge_memory.c        |    6 +++---
 mm/hugetlb.c            |   14 +++++++-------
 mm/interval_tree.c      |    2 +-
 mm/mmap.c               |   11 +++++------
 mm/mremap.c             |    4 ++--
 mm/rmap.c               |    6 +++---
 10 files changed, 25 insertions(+), 34 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 44a840a..cfd745b 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -136,7 +136,7 @@ extern int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 static inline int pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 		spinlock_t **ptl)
 {
-	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
+	VM_BUG(!rwsem_is_locked(&vma->vm_mm->mmap_sem), "%pZv", vma);
 	if (pmd_trans_huge(*pmd))
 		return __pmd_trans_huge_lock(pmd, vma, ptl);
 	else
diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index f43f868..5106ab5 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -20,13 +20,6 @@ char *format_mm(const struct mm_struct *mm, char *buf, char *end);
 		}							\
 	} while (0)
 #define VM_BUG_ON(cond) VM_BUG(cond, "%s\n", __stringify(cond))
-#define VM_BUG_ON_VMA(cond, vma)					\
-	do {								\
-		if (unlikely(cond)) {					\
-			pr_emerg("%pZv", vma);				\
-			BUG();						\
-		}							\
-	} while (0)
 #define VM_BUG_ON_MM(cond, mm)						\
 	do {								\
 		if (unlikely(cond)) {					\
@@ -48,7 +41,6 @@ static char *format_mm(const struct mm_struct *mm, char *buf, char *end)
 }
 #define VM_BUG(cond, fmt...) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
-#define VM_BUG_ON_VMA(cond, vma) VM_BUG_ON(cond)
 #define VM_BUG_ON_MM(cond, mm) VM_BUG_ON(cond)
 #define VM_WARN_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ON_ONCE(cond) BUILD_BUG_ON_INVALID(cond)
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index bf36b6e..54beb2f 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -153,7 +153,7 @@ int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
 static inline void anon_vma_merge(struct vm_area_struct *vma,
 				  struct vm_area_struct *next)
 {
-	VM_BUG_ON_VMA(vma->anon_vma != next->anon_vma, vma);
+	VM_BUG(vma->anon_vma != next->anon_vma, "%pZv", vma);
 	unlink_anon_vmas(next);
 }
 
diff --git a/mm/gup.c b/mm/gup.c
index 743648e..0b851ac 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -846,8 +846,8 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(end   & ~PAGE_MASK);
-	VM_BUG_ON_VMA(start < vma->vm_start, vma);
-	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
+	VM_BUG(start < vma->vm_start, "%pZv", vma);
+	VM_BUG(end > vma->vm_end, "%pZv", vma);
 	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
 
 	gup_flags = FOLL_TOUCH | FOLL_POPULATE;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7ba3947..d4b20cd 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1093,7 +1093,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	gfp_t huge_gfp;			/* for allocation and charge */
 
 	ptl = pmd_lockptr(mm, pmd);
-	VM_BUG_ON_VMA(!vma->anon_vma, vma);
+	VM_BUG(!vma->anon_vma, "%pZv", vma);
 	haddr = address & HPAGE_PMD_MASK;
 	if (is_huge_zero_pmd(orig_pmd))
 		goto alloc;
@@ -2108,7 +2108,7 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 	if (vma->vm_ops)
 		/* khugepaged not yet working on file or special mappings */
 		return 0;
-	VM_BUG_ON_VMA(vm_flags & VM_NO_THP, vma);
+	VM_BUG(vm_flags & VM_NO_THP, "%pZv", vma);
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (hstart < hend)
@@ -2466,7 +2466,7 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 		return false;
 	if (is_vma_temporary_stack(vma))
 		return false;
-	VM_BUG_ON_VMA(vma->vm_flags & VM_NO_THP, vma);
+	VM_BUG(vma->vm_flags & VM_NO_THP, "%pZv", vma);
 	return true;
 }
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 584b516..3c6767b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -503,7 +503,7 @@ static inline struct resv_map *inode_resv_map(struct inode *inode)
 
 static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
 {
-	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
+	VM_BUG(!is_vm_hugetlb_page(vma), "%pZv", vma);
 	if (vma->vm_flags & VM_MAYSHARE) {
 		struct address_space *mapping = vma->vm_file->f_mapping;
 		struct inode *inode = mapping->host;
@@ -518,8 +518,8 @@ static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
 
 static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
 {
-	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
-	VM_BUG_ON_VMA(vma->vm_flags & VM_MAYSHARE, vma);
+	VM_BUG(!is_vm_hugetlb_page(vma), "%pZv", vma);
+	VM_BUG(vma->vm_flags & VM_MAYSHARE, "%pZv", vma);
 
 	set_vma_private_data(vma, (get_vma_private_data(vma) &
 				HPAGE_RESV_MASK) | (unsigned long)map);
@@ -527,15 +527,15 @@ static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
 
 static void set_vma_resv_flags(struct vm_area_struct *vma, unsigned long flags)
 {
-	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
-	VM_BUG_ON_VMA(vma->vm_flags & VM_MAYSHARE, vma);
+	VM_BUG(!is_vm_hugetlb_page(vma), "%pZv", vma);
+	VM_BUG(vma->vm_flags & VM_MAYSHARE, "%pZv", vma);
 
 	set_vma_private_data(vma, get_vma_private_data(vma) | flags);
 }
 
 static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
 {
-	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
+	VM_BUG(!is_vm_hugetlb_page(vma), "%pZv", vma);
 
 	return (get_vma_private_data(vma) & flag) != 0;
 }
@@ -543,7 +543,7 @@ static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
 /* Reset counters to 0 and clear all HPAGE_RESV_* flags */
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
-	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
+	VM_BUG(!is_vm_hugetlb_page(vma), "%pZv", vma);
 	if (!(vma->vm_flags & VM_MAYSHARE))
 		vma->vm_private_data = (void *)0;
 }
diff --git a/mm/interval_tree.c b/mm/interval_tree.c
index f2c2492..49d4f53 100644
--- a/mm/interval_tree.c
+++ b/mm/interval_tree.c
@@ -34,7 +34,7 @@ void vma_interval_tree_insert_after(struct vm_area_struct *node,
 	struct vm_area_struct *parent;
 	unsigned long last = vma_last_pgoff(node);
 
-	VM_BUG_ON_VMA(vma_start_pgoff(node) != vma_start_pgoff(prev), node);
+	VM_BUG(vma_start_pgoff(node) != vma_start_pgoff(prev), "%pZv", node);
 
 	if (!prev->shared.rb.rb_right) {
 		parent = prev;
diff --git a/mm/mmap.c b/mm/mmap.c
index bb50cac..f2db320 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -426,9 +426,8 @@ static void validate_mm_rb(struct rb_root *root, struct vm_area_struct *ignore)
 	for (nd = rb_first(root); nd; nd = rb_next(nd)) {
 		struct vm_area_struct *vma;
 		vma = rb_entry(nd, struct vm_area_struct, vm_rb);
-		VM_BUG_ON_VMA(vma != ignore &&
-			vma->rb_subtree_gap != vma_compute_subtree_gap(vma),
-			vma);
+		VM_BUG(vma != ignore && vma->rb_subtree_gap != vma_compute_subtree_gap(vma),
+		       "%pZv", vma);
 	}
 }
 
@@ -805,8 +804,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 	if (!anon_vma && adjust_next)
 		anon_vma = next->anon_vma;
 	if (anon_vma) {
-		VM_BUG_ON_VMA(adjust_next && next->anon_vma &&
-			  anon_vma != next->anon_vma, next);
+		VM_BUG(adjust_next && next->anon_vma && anon_vma != next->anon_vma,
+		       "%pZv", next);
 		anon_vma_lock_write(anon_vma);
 		anon_vma_interval_tree_pre_update_vma(vma);
 		if (adjust_next)
@@ -2932,7 +2931,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			 * safe. It is only safe to keep the vm_pgoff
 			 * linear if there are no pages mapped yet.
 			 */
-			VM_BUG_ON_VMA(faulted_in_anon_vma, new_vma);
+			VM_BUG(faulted_in_anon_vma, "%pZv", new_vma);
 			*vmap = vma = new_vma;
 		}
 		*need_rmap_locks = (new_vma->vm_pgoff <= vma->vm_pgoff);
diff --git a/mm/mremap.c b/mm/mremap.c
index afa3ab7..47f208e 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -193,8 +193,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 		if (pmd_trans_huge(*old_pmd)) {
 			int err = 0;
 			if (extent == HPAGE_PMD_SIZE) {
-				VM_BUG_ON_VMA(vma->vm_file || !vma->anon_vma,
-					      vma);
+				VM_BUG(vma->vm_file || !vma->anon_vma,
+				       "%pZv", vma);
 				/* See comment in move_ptes() */
 				if (need_rmap_locks)
 					anon_vma_lock_write(vma->anon_vma);
diff --git a/mm/rmap.c b/mm/rmap.c
index f8a6bca..1ef7e6f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -576,7 +576,7 @@ vma_address(struct page *page, struct vm_area_struct *vma)
 	unsigned long address = __vma_address(page, vma);
 
 	/* page should be within @vma mapping range */
-	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
+	VM_BUG(address < vma->vm_start || address >= vma->vm_end, "%pZv", vma);
 
 	return address;
 }
@@ -972,7 +972,7 @@ void page_move_anon_rmap(struct page *page,
 	struct anon_vma *anon_vma = vma->anon_vma;
 
 	VM_BUG(!PageLocked(page), "%pZp", page);
-	VM_BUG_ON_VMA(!anon_vma, vma);
+	VM_BUG(!anon_vma, "%pZv", vma);
 	VM_BUG(page->index != linear_page_index(vma, address), "%pZp", page);
 
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
@@ -1099,7 +1099,7 @@ void do_page_add_anon_rmap(struct page *page,
 void page_add_new_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
 {
-	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
+	VM_BUG(address < vma->vm_start || address >= vma->vm_end, "%pZv", vma);
 	SetPageSwapBacked(page);
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	if (PageTransHuge(page))
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
