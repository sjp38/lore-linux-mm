Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5F96B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:44:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 63so6642640pfx.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:44:07 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id b7si10047740pas.289.2016.08.12.11.38.49
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 28/41] mm, hugetlb: switch hugetlbfs to multi-order radix-tree entries
Date: Fri, 12 Aug 2016 21:38:11 +0300
Message-Id: <1471027104-115213-29-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Currently, hugetlb pages are linked to page cache on the basis of hugepage
offset (derived from vma_hugecache_offset()) for historical reason, which
doesn't match to the generic usage of page cache and requires some routines
to covert page offset <=> hugepage offset in common path. This patch
adjusts code for multi-order radix-tree to avoid the situation.

Main change is on the behavior of page->index for hugetlbfs. Before this
patch, it represented hugepage offset, but with this patch it represents
page offset. So index-related code have to be updated.
Note that hugetlb_fault_mutex_hash() and reservation region handling are
still working with hugepage offset.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
[kirill.shutemov@linux.intel.com: reject fixed]
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/hugetlbfs/inode.c    | 22 ++++++++++------------
 include/linux/pagemap.h | 10 +---------
 mm/filemap.c            | 30 ++++++++++++++++++------------
 mm/hugetlb.c            | 19 ++++++-------------
 4 files changed, 35 insertions(+), 46 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 4ea71eba40a5..fc918c0e33e9 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -388,8 +388,8 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 {
 	struct hstate *h = hstate_inode(inode);
 	struct address_space *mapping = &inode->i_data;
-	const pgoff_t start = lstart >> huge_page_shift(h);
-	const pgoff_t end = lend >> huge_page_shift(h);
+	const pgoff_t start = lstart >> PAGE_SHIFT;
+	const pgoff_t end = lend >> PAGE_SHIFT;
 	struct vm_area_struct pseudo_vma;
 	struct pagevec pvec;
 	pgoff_t next;
@@ -447,8 +447,7 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 
 				i_mmap_lock_write(mapping);
 				hugetlb_vmdelete_list(&mapping->i_mmap,
-					next * pages_per_huge_page(h),
-					(next + 1) * pages_per_huge_page(h));
+					next, next + 1);
 				i_mmap_unlock_write(mapping);
 			}
 
@@ -467,7 +466,8 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			freed++;
 			if (!truncate_op) {
 				if (unlikely(hugetlb_unreserve_pages(inode,
-							next, next + 1, 1)))
+						(next) << huge_page_order(h),
+						(next + 1) << huge_page_order(h), 1)))
 					hugetlb_fix_reserve_counts(inode,
 								rsv_on_error);
 			}
@@ -552,8 +552,6 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	struct hstate *h = hstate_inode(inode);
 	struct vm_area_struct pseudo_vma;
 	struct mm_struct *mm = current->mm;
-	loff_t hpage_size = huge_page_size(h);
-	unsigned long hpage_shift = huge_page_shift(h);
 	pgoff_t start, index, end;
 	int error;
 	u32 hash;
@@ -569,8 +567,8 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	 * For this range, start is rounded down and end is rounded up
 	 * as well as being converted to page offsets.
 	 */
-	start = offset >> hpage_shift;
-	end = (offset + len + hpage_size - 1) >> hpage_shift;
+	start = offset >> PAGE_SHIFT;
+	end = (offset + len + huge_page_size(h) - 1) >> PAGE_SHIFT;
 
 	inode_lock(inode);
 
@@ -588,7 +586,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
 	pseudo_vma.vm_file = file;
 
-	for (index = start; index < end; index++) {
+	for (index = start; index < end; index += pages_per_huge_page(h)) {
 		/*
 		 * This is supposed to be the vaddr where the page is being
 		 * faulted in, but we have no vaddr here.
@@ -609,10 +607,10 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		}
 
 		/* Set numa allocation policy based on index */
-		hugetlb_set_vma_policy(&pseudo_vma, inode, index);
+		hugetlb_set_vma_policy(&pseudo_vma, inode, index >> huge_page_order(h));
 
 		/* addr is the offset within the file (zero based) */
-		addr = index * hpage_size;
+		addr = index << PAGE_SHIFT & ~huge_page_mask(h);
 
 		/* mutex taken here, fault path and hole punch */
 		hash = hugetlb_fault_mutex_hash(h, mm, &pseudo_vma, mapping,
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 24e14ef1cfe5..de3f732528ea 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -380,15 +380,11 @@ static inline struct page *read_mapping_page(struct address_space *mapping,
 
 /*
  * Get the offset in PAGE_SIZE.
- * (TODO: hugepage should have ->index in PAGE_SIZE)
  */
 static inline pgoff_t page_to_pgoff(struct page *page)
 {
 	pgoff_t pgoff;
 
-	if (unlikely(PageHeadHuge(page)))
-		return page->index << compound_order(page);
-
 	if (likely(!PageTransTail(page)))
 		return page->index;
 
@@ -414,15 +410,11 @@ static inline loff_t page_file_offset(struct page *page)
 	return ((loff_t)page_file_index(page)) << PAGE_SHIFT;
 }
 
-extern pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
-				     unsigned long address);
-
 static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 					unsigned long address)
 {
 	pgoff_t pgoff;
-	if (unlikely(is_vm_hugetlb_page(vma)))
-		return linear_hugepage_index(vma, address);
+
 	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
 	pgoff += vma->vm_pgoff;
 	return pgoff;
diff --git a/mm/filemap.c b/mm/filemap.c
index 429f9a0962b3..71c0bfdcab05 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -114,7 +114,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
 	struct radix_tree_node *node;
-	int nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
+	int nr = hpage_nr_pages(page);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageTail(page), page);
@@ -668,7 +668,7 @@ static int __add_to_page_cache_locked(struct page *page,
 	page->index = offset;
 
 	spin_lock_irq(&mapping->tree_lock);
-	if (PageTransHuge(page)) {
+	if (PageCompound(page)) {
 		struct radix_tree_iter iter;
 		void **slot;
 		void *p;
@@ -677,7 +677,7 @@ static int __add_to_page_cache_locked(struct page *page,
 
 		/* Wipe shadow entires */
 		radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, offset) {
-			if (iter.index >= offset + HPAGE_PMD_NR)
+			if (iter.index >= offset + hpage_nr_pages(page))
 				break;
 
 			p = radix_tree_deref_slot_protected(slot,
@@ -699,10 +699,15 @@ static int __add_to_page_cache_locked(struct page *page,
 					compound_order(page), page);
 
 		if (!error) {
-			count_vm_event(THP_FILE_ALLOC);
-			mapping->nrpages += HPAGE_PMD_NR;
-			*shadowp = NULL;
-			__inc_node_page_state(page, NR_FILE_THPS);
+			if (hugetlb) {
+				mapping->nrpages += 1 << compound_order(page);
+			} else if (PageTransHuge(page)) {
+				count_vm_event(THP_FILE_ALLOC);
+				mapping->nrpages += HPAGE_PMD_NR;
+				*shadowp = NULL;
+				__inc_node_page_state(page, NR_FILE_THPS);
+			} else
+				BUG();
 		}
 	} else {
 		error = page_cache_tree_insert(mapping, page, shadowp);
@@ -1144,9 +1149,9 @@ repeat:
 		}
 
 		/* For multi-order entries, find relevant subpage */
-		if (PageTransHuge(page)) {
+		if (PageCompound(page)) {
 			VM_BUG_ON(offset - page->index < 0);
-			VM_BUG_ON(offset - page->index >= HPAGE_PMD_NR);
+			VM_BUG_ON(offset - page->index >= 1 << compound_order(page));
 			page += offset - page->index;
 		}
 	}
@@ -1514,16 +1519,17 @@ repeat:
 		}
 
 		/* For multi-order entries, find relevant subpage */
-		if (PageTransHuge(page)) {
+		if (PageCompound(page)) {
 			VM_BUG_ON(index - page->index < 0);
-			VM_BUG_ON(index - page->index >= HPAGE_PMD_NR);
+			VM_BUG_ON(index - page->index >=
+					1 << compound_order(page));
 			page += index - page->index;
 		}
 
 		pages[ret] = page;
 		if (++ret == nr_pages)
 			break;
-		if (!PageTransCompound(page))
+		if (PageHuge(page) || !PageTransCompound(page))
 			continue;
 		for (refs = 0; ret < nr_pages &&
 				(index + 1) % HPAGE_PMD_NR;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3b6dc790ce78..559cab109895 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -622,13 +622,6 @@ static pgoff_t vma_hugecache_offset(struct hstate *h,
 			(vma->vm_pgoff >> huge_page_order(h));
 }
 
-pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
-				     unsigned long address)
-{
-	return vma_hugecache_offset(hstate_vma(vma), vma, address);
-}
-EXPORT_SYMBOL_GPL(linear_hugepage_index);
-
 /*
  * Return the size of the pages allocated when backing a VMA. In the majority
  * cases this will be same size as used by the page table entries.
@@ -3486,7 +3479,7 @@ static struct page *hugetlbfs_pagecache_page(struct hstate *h,
 	pgoff_t idx;
 
 	mapping = vma->vm_file->f_mapping;
-	idx = vma_hugecache_offset(h, vma, address);
+	idx = linear_page_index(vma, address);
 
 	return find_lock_page(mapping, idx);
 }
@@ -3503,7 +3496,7 @@ static bool hugetlbfs_pagecache_present(struct hstate *h,
 	struct page *page;
 
 	mapping = vma->vm_file->f_mapping;
-	idx = vma_hugecache_offset(h, vma, address);
+	idx = linear_page_index(vma, address);
 
 	page = find_get_page(mapping, idx);
 	if (page)
@@ -3558,7 +3551,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 retry:
 	page = find_lock_page(mapping, idx);
 	if (!page) {
-		size = i_size_read(mapping->host) >> huge_page_shift(h);
+		size = i_size_read(mapping->host) >> PAGE_SHIFT;
 		if (idx >= size)
 			goto out;
 		page = alloc_huge_page(vma, address, 0);
@@ -3620,7 +3613,7 @@ retry:
 
 	ptl = huge_pte_lockptr(h, mm, ptep);
 	spin_lock(ptl);
-	size = i_size_read(mapping->host) >> huge_page_shift(h);
+	size = i_size_read(mapping->host) >> PAGE_SHIFT;
 	if (idx >= size)
 		goto backout;
 
@@ -3667,7 +3660,7 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 
 	if (vma->vm_flags & VM_SHARED) {
 		key[0] = (unsigned long) mapping;
-		key[1] = idx;
+		key[1] = idx >> huge_page_order(h);
 	} else {
 		key[0] = (unsigned long) mm;
 		key[1] = address >> huge_page_shift(h);
@@ -3723,7 +3716,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	mapping = vma->vm_file->f_mapping;
-	idx = vma_hugecache_offset(h, vma, address);
+	idx = linear_page_index(vma, address);
 
 	/*
 	 * Serialize hugepage allocation and instantiation, so that we don't
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
