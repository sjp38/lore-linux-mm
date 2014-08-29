Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFED6B0039
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 10:55:02 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y13so587059pdi.2
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 07:55:02 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e6si662621pdl.73.2014.08.29.07.55.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 07:55:01 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 3/3] Convert a few VM_BUG_ON callers to VM_BUG_ON_VMA
Date: Fri, 29 Aug 2014 10:54:19 -0400
Message-Id: <1409324059-28692-3-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1409324059-28692-1-git-send-email-sasha.levin@oracle.com>
References: <1409324059-28692-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, khlebnikov@openvz.org, riel@redhat.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, mhocko@suse.cz, hughd@google.com, vbabka@suse.cz, walken@google.com, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>

Trivially convert a few VM_BUG_ON calls to VM_BUG_ON_VMA to extract
more information when they trigger.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/huge_mm.h |    2 +-
 include/linux/rmap.h    |    2 +-
 mm/huge_memory.c        |    6 +++---
 mm/hugetlb.c            |   14 +++++++-------
 mm/interval_tree.c      |    2 +-
 mm/mlock.c              |    4 ++--
 mm/mmap.c               |    6 +++---
 mm/mremap.c             |    2 +-
 mm/rmap.c               |    8 ++++----
 9 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 63579cb..ad9051b 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -132,7 +132,7 @@ extern int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 static inline int pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 		spinlock_t **ptl)
 {
-	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
+	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
 	if (pmd_trans_huge(*pmd))
 		return __pmd_trans_huge_lock(pmd, vma, ptl);
 	else
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index be57450..c0c2bce 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -150,7 +150,7 @@ int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
 static inline void anon_vma_merge(struct vm_area_struct *vma,
 				  struct vm_area_struct *next)
 {
-	VM_BUG_ON(vma->anon_vma != next->anon_vma);
+	VM_BUG_ON_VMA(vma->anon_vma != next->anon_vma, vma);
 	unlink_anon_vmas(next);
 }
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7cfc325..d81f8ba 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1096,7 +1096,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	ptl = pmd_lockptr(mm, pmd);
-	VM_BUG_ON(!vma->anon_vma);
+	VM_BUG_ON_VMA(!vma->anon_vma, vma);
 	haddr = address & HPAGE_PMD_MASK;
 	if (is_huge_zero_pmd(orig_pmd))
 		goto alloc;
@@ -2080,7 +2080,7 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
 	if (vma->vm_ops)
 		/* khugepaged not yet working on file or special mappings */
 		return 0;
-	VM_BUG_ON(vma->vm_flags & VM_NO_THP);
+	VM_BUG_ON_VMA(vma->vm_flags & VM_NO_THP, vma);
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (hstart < hend)
@@ -2403,7 +2403,7 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 		return false;
 	if (is_vma_temporary_stack(vma))
 		return false;
-	VM_BUG_ON(vma->vm_flags & VM_NO_THP);
+	VM_BUG_ON_VMA(vma->vm_flags & VM_NO_THP, vma);
 	return true;
 }
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index eeceeeb..9fd7227 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -434,7 +434,7 @@ static inline struct resv_map *inode_resv_map(struct inode *inode)
 
 static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
 {
-	VM_BUG_ON(!is_vm_hugetlb_page(vma));
+	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
 	if (vma->vm_flags & VM_MAYSHARE) {
 		struct address_space *mapping = vma->vm_file->f_mapping;
 		struct inode *inode = mapping->host;
@@ -449,8 +449,8 @@ static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
 
 static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
 {
-	VM_BUG_ON(!is_vm_hugetlb_page(vma));
-	VM_BUG_ON(vma->vm_flags & VM_MAYSHARE);
+	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
+	VM_BUG_ON_VMA(vma->vm_flags & VM_MAYSHARE, vma);
 
 	set_vma_private_data(vma, (get_vma_private_data(vma) &
 				HPAGE_RESV_MASK) | (unsigned long)map);
@@ -458,15 +458,15 @@ static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
 
 static void set_vma_resv_flags(struct vm_area_struct *vma, unsigned long flags)
 {
-	VM_BUG_ON(!is_vm_hugetlb_page(vma));
-	VM_BUG_ON(vma->vm_flags & VM_MAYSHARE);
+	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
+	VM_BUG_ON_VMA(vma->vm_flags & VM_MAYSHARE, vma);
 
 	set_vma_private_data(vma, get_vma_private_data(vma) | flags);
 }
 
 static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
 {
-	VM_BUG_ON(!is_vm_hugetlb_page(vma));
+	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
 
 	return (get_vma_private_data(vma) & flag) != 0;
 }
@@ -474,7 +474,7 @@ static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
 /* Reset counters to 0 and clear all HPAGE_RESV_* flags */
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
-	VM_BUG_ON(!is_vm_hugetlb_page(vma));
+	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
 	if (!(vma->vm_flags & VM_MAYSHARE))
 		vma->vm_private_data = (void *)0;
 }
diff --git a/mm/interval_tree.c b/mm/interval_tree.c
index 4a5822a..8da581f 100644
--- a/mm/interval_tree.c
+++ b/mm/interval_tree.c
@@ -34,7 +34,7 @@ void vma_interval_tree_insert_after(struct vm_area_struct *node,
 	struct vm_area_struct *parent;
 	unsigned long last = vma_last_pgoff(node);
 
-	VM_BUG_ON(vma_start_pgoff(node) != vma_start_pgoff(prev));
+	VM_BUG_ON_VMA(vma_start_pgoff(node) != vma_start_pgoff(prev), node);
 
 	if (!prev->shared.linear.rb.rb_right) {
 		parent = prev;
diff --git a/mm/mlock.c b/mm/mlock.c
index ce84cb0..d5d09d0 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -233,8 +233,8 @@ long __mlock_vma_pages_range(struct vm_area_struct *vma,
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(end   & ~PAGE_MASK);
-	VM_BUG_ON(start < vma->vm_start);
-	VM_BUG_ON(end   > vma->vm_end);
+	VM_BUG_ON_VMA(start < vma->vm_start, vma);
+	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
 	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
 	gup_flags = FOLL_TOUCH | FOLL_MLOCK;
diff --git a/mm/mmap.c b/mm/mmap.c
index 45dc9ac..9351482 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -786,8 +786,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 	if (!anon_vma && adjust_next)
 		anon_vma = next->anon_vma;
 	if (anon_vma) {
-		VM_BUG_ON(adjust_next && next->anon_vma &&
-			  anon_vma != next->anon_vma);
+		VM_BUG_ON_VMA(adjust_next && next->anon_vma &&
+			  anon_vma != next->anon_vma, next);
 		anon_vma_lock_write(anon_vma);
 		anon_vma_interval_tree_pre_update_vma(vma);
 		if (adjust_next)
@@ -2917,7 +2917,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			 * safe. It is only safe to keep the vm_pgoff
 			 * linear if there are no pages mapped yet.
 			 */
-			VM_BUG_ON(faulted_in_anon_vma);
+			VM_BUG_ON_VMA(faulted_in_anon_vma, new_vma);
 			*vmap = vma = new_vma;
 		}
 		*need_rmap_locks = (new_vma->vm_pgoff <= vma->vm_pgoff);
diff --git a/mm/mremap.c b/mm/mremap.c
index 05f1180..ba7d241 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -195,7 +195,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 		if (pmd_trans_huge(*old_pmd)) {
 			int err = 0;
 			if (extent == HPAGE_PMD_SIZE) {
-				VM_BUG_ON(vma->vm_file || !vma->anon_vma);
+				VM_BUG_ON_VMA(vma->vm_file || !vma->anon_vma, vma);
 				/* See comment in move_ptes() */
 				if (need_rmap_locks)
 					anon_vma_lock_write(vma->anon_vma);
diff --git a/mm/rmap.c b/mm/rmap.c
index 3e8491c..5fbd0fe 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -527,7 +527,7 @@ vma_address(struct page *page, struct vm_area_struct *vma)
 	unsigned long address = __vma_address(page, vma);
 
 	/* page should be within @vma mapping range */
-	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
+	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
 
 	return address;
 }
@@ -897,7 +897,7 @@ void page_move_anon_rmap(struct page *page,
 	struct anon_vma *anon_vma = vma->anon_vma;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON(!anon_vma);
+	VM_BUG_ON_VMA(!anon_vma, vma);
 	VM_BUG_ON_PAGE(page->index != linear_page_index(vma, address), page);
 
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
@@ -1024,7 +1024,7 @@ void do_page_add_anon_rmap(struct page *page,
 void page_add_new_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
 {
-	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
+	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
 	SetPageSwapBacked(page);
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	if (PageTransHuge(page))
@@ -1666,7 +1666,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	 * structure at mapping cannot be freed and reused yet,
 	 * so we can safely take mapping->i_mmap_mutex.
 	 */
-	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
 	if (!mapping)
 		return ret;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
