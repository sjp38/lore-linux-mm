Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 145ED6B0279
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:25 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id r13so549154pag.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:25 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y62si17971548pgy.100.2016.10.24.17.14.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:24 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 29/43] mm, hugetlb: switch hugetlbfs to multi-order radix-tree entries
Date: Tue, 25 Oct 2016 03:13:28 +0300
Message-Id: <20161025001342.76126-30-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
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
 mm/filemap.c            | 31 ++++++++++++++++++-------------
 mm/hugetlb.c            | 19 ++++++-------------
 4 files changed, 35 insertions(+), 47 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 4fb7b10f3a05..45992c839794 100644
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
@@ -446,8 +446,7 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 
 				i_mmap_lock_write(mapping);
 				hugetlb_vmdelete_list(&mapping->i_mmap,
-					next * pages_per_huge_page(h),
-					(next + 1) * pages_per_huge_page(h));
+					next, next + 1);
 				i_mmap_unlock_write(mapping);
 			}
 
@@ -466,7 +465,8 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			freed++;
 			if (!truncate_op) {
 				if (unlikely(hugetlb_unreserve_pages(inode,
-							next, next + 1, 1)))
+						(next) << huge_page_order(h),
+						(next + 1) << huge_page_order(h), 1)))
 					hugetlb_fix_reserve_counts(inode);
 			}
 
@@ -550,8 +550,6 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	struct hstate *h = hstate_inode(inode);
 	struct vm_area_struct pseudo_vma;
 	struct mm_struct *mm = current->mm;
-	loff_t hpage_size = huge_page_size(h);
-	unsigned long hpage_shift = huge_page_shift(h);
 	pgoff_t start, index, end;
 	int error;
 	u32 hash;
@@ -567,8 +565,8 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	 * For this range, start is rounded down and end is rounded up
 	 * as well as being converted to page offsets.
 	 */
-	start = offset >> hpage_shift;
-	end = (offset + len + hpage_size - 1) >> hpage_shift;
+	start = offset >> PAGE_SHIFT;
+	end = (offset + len + huge_page_size(h) - 1) >> PAGE_SHIFT;
 
 	inode_lock(inode);
 
@@ -586,7 +584,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
 	pseudo_vma.vm_file = file;
 
-	for (index = start; index < end; index++) {
+	for (index = start; index < end; index += pages_per_huge_page(h)) {
 		/*
 		 * This is supposed to be the vaddr where the page is being
 		 * faulted in, but we have no vaddr here.
@@ -607,10 +605,10 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
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
index f9aa8bede15e..ff2c0fc7fff8 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -390,15 +390,11 @@ static inline struct page *read_mapping_page(struct address_space *mapping,
 
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
 
@@ -424,15 +420,11 @@ static inline loff_t page_file_offset(struct page *page)
 	return ((loff_t)page_index(page)) << PAGE_SHIFT;
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
index ecf5c2dba3fb..85274c4ca2c9 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -121,9 +121,8 @@ static int page_cache_tree_insert_huge(struct address_space *mapping,
 	/* Wipe shadow entires */
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
 			page->index) {
-		if (iter.index >= page->index + HPAGE_PMD_NR)
+		if (iter.index >= page->index + hpage_nr_pages(page))
 			break;
-
 		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
 		if (!p)
 			continue;
@@ -149,10 +148,15 @@ static int page_cache_tree_insert_huge(struct address_space *mapping,
 	if (error)
 		return error;
 
-	count_vm_event(THP_FILE_ALLOC);
-	mapping->nrpages += HPAGE_PMD_NR;
-	*shadowp = NULL;
-	__inc_node_page_state(page, NR_FILE_THPS);
+	if (PageHuge(page)) {
+		mapping->nrpages += 1 << compound_order(page);
+	} else if (PageTransHuge(page)) {
+		count_vm_event(THP_FILE_ALLOC);
+		mapping->nrpages += HPAGE_PMD_NR;
+		*shadowp = NULL;
+		__inc_node_page_state(page, NR_FILE_THPS);
+	} else
+		BUG();
 
 	__radix_tree_lookup(&mapping->page_tree, page->index, &node, NULL);
 	if (node) {
@@ -178,7 +182,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 	void **slot;
 	int error;
 
-	if (PageTransHuge(page))
+	if (PageCompound(page))
 		return page_cache_tree_insert_huge(mapping, page, shadowp);
 
 	error = __radix_tree_create(&mapping->page_tree, page->index, 0,
@@ -235,7 +239,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
 {
 	struct radix_tree_node *node;
 	void **slot;
-	int nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
+	int nr = hpage_nr_pages(page);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageTail(page), page);
@@ -1186,9 +1190,9 @@ struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
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
@@ -1556,16 +1560,17 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
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
index ec49d9ef1eef..121e042c00eb 100644
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
@@ -3514,7 +3507,7 @@ static struct page *hugetlbfs_pagecache_page(struct hstate *h,
 	pgoff_t idx;
 
 	mapping = vma->vm_file->f_mapping;
-	idx = vma_hugecache_offset(h, vma, address);
+	idx = linear_page_index(vma, address);
 
 	return find_lock_page(mapping, idx);
 }
@@ -3531,7 +3524,7 @@ static bool hugetlbfs_pagecache_present(struct hstate *h,
 	struct page *page;
 
 	mapping = vma->vm_file->f_mapping;
-	idx = vma_hugecache_offset(h, vma, address);
+	idx = linear_page_index(vma, address);
 
 	page = find_get_page(mapping, idx);
 	if (page)
@@ -3586,7 +3579,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 retry:
 	page = find_lock_page(mapping, idx);
 	if (!page) {
-		size = i_size_read(mapping->host) >> huge_page_shift(h);
+		size = i_size_read(mapping->host) >> PAGE_SHIFT;
 		if (idx >= size)
 			goto out;
 		page = alloc_huge_page(vma, address, 0);
@@ -3648,7 +3641,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	ptl = huge_pte_lockptr(h, mm, ptep);
 	spin_lock(ptl);
-	size = i_size_read(mapping->host) >> huge_page_shift(h);
+	size = i_size_read(mapping->host) >> PAGE_SHIFT;
 	if (idx >= size)
 		goto backout;
 
@@ -3695,7 +3688,7 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 
 	if (vma->vm_flags & VM_SHARED) {
 		key[0] = (unsigned long) mapping;
-		key[1] = idx;
+		key[1] = idx >> huge_page_order(h);
 	} else {
 		key[0] = (unsigned long) mm;
 		key[1] = address >> huge_page_shift(h);
@@ -3751,7 +3744,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	mapping = vma->vm_file->f_mapping;
-	idx = vma_hugecache_offset(h, vma, address);
+	idx = linear_page_index(vma, address);
 
 	/*
 	 * Serialize hugepage allocation and instantiation, so that we don't
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
