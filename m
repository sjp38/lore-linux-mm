Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 01CB96B004D
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:06:17 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so3145560pdj.35
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 05:06:17 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 19/22] thp: handle file pages in split_huge_page()
Date: Mon, 23 Sep 2013 15:05:47 +0300
Message-Id: <1379937950-8411-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The base scheme is the same as for anonymous pages, but we walk by
mapping->i_mmap rather then anon_vma->rb_root.

When we add a huge page to page cache we take only reference to head
page, but on split we need to take addition reference to all tail pages
since they are still in page cache after splitting.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 120 +++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 107 insertions(+), 13 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 59f099b93f..3c45c62cde 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1584,6 +1584,7 @@ static void __split_huge_page_refcount(struct page *page,
 	struct zone *zone = page_zone(page);
 	struct lruvec *lruvec;
 	int tail_count = 0;
+	int initial_tail_refcount;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
@@ -1593,6 +1594,13 @@ static void __split_huge_page_refcount(struct page *page,
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(page);
 
+	/*
+	 * When we add a huge page to page cache we take only reference to head
+	 * page, but on split we need to take addition reference to all tail
+	 * pages since they are still in page cache after splitting.
+	 */
+	initial_tail_refcount = PageAnon(page) ? 0 : 1;
+
 	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
 		struct page *page_tail = page + i;
 
@@ -1615,8 +1623,9 @@ static void __split_huge_page_refcount(struct page *page,
 		 * atomic_set() here would be safe on all archs (and
 		 * not only on x86), it's safer to use atomic_add().
 		 */
-		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
-			   &page_tail->_count);
+		atomic_add(initial_tail_refcount + page_mapcount(page) +
+				page_mapcount(page_tail) + 1,
+				&page_tail->_count);
 
 		/* after clearing PageTail the gup refcount can be released */
 		smp_mb();
@@ -1655,23 +1664,23 @@ static void __split_huge_page_refcount(struct page *page,
 		*/
 		page_tail->_mapcount = page->_mapcount;
 
-		BUG_ON(page_tail->mapping);
 		page_tail->mapping = page->mapping;
 
 		page_tail->index = page->index + i;
 		page_nid_xchg_last(page_tail, page_nid_last(page));
 
-		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
 		BUG_ON(!PageDirty(page_tail));
-		BUG_ON(!PageSwapBacked(page_tail));
 
 		lru_add_page_tail(page, page_tail, lruvec, list);
 	}
 	atomic_sub(tail_count, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
-	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
+	if (PageAnon(page))
+		__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
+	else
+		__mod_zone_page_state(zone, NR_FILE_TRANSPARENT_HUGEPAGES, -1);
 
 	ClearPageCompound(page);
 	compound_unlock(page);
@@ -1771,7 +1780,7 @@ static int __split_huge_page_map(struct page *page,
 }
 
 /* must be called with anon_vma->root->rwsem held */
-static void __split_huge_page(struct page *page,
+static void __split_anon_huge_page(struct page *page,
 			      struct anon_vma *anon_vma,
 			      struct list_head *list)
 {
@@ -1795,7 +1804,7 @@ static void __split_huge_page(struct page *page,
 	 * and establishes a child pmd before
 	 * __split_huge_page_splitting() freezes the parent pmd (so if
 	 * we fail to prevent copy_huge_pmd() from running until the
-	 * whole __split_huge_page() is complete), we will still see
+	 * whole __split_anon_huge_page() is complete), we will still see
 	 * the newly established pmd of the child later during the
 	 * walk, to be able to set it as pmd_trans_splitting too.
 	 */
@@ -1826,14 +1835,11 @@ static void __split_huge_page(struct page *page,
  * from the hugepage.
  * Return 0 if the hugepage is split successfully otherwise return 1.
  */
-int split_huge_page_to_list(struct page *page, struct list_head *list)
+static int split_anon_huge_page(struct page *page, struct list_head *list)
 {
 	struct anon_vma *anon_vma;
 	int ret = 1;
 
-	BUG_ON(is_huge_zero_page(page));
-	BUG_ON(!PageAnon(page));
-
 	/*
 	 * The caller does not necessarily hold an mmap_sem that would prevent
 	 * the anon_vma disappearing so we first we take a reference to it
@@ -1851,7 +1857,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		goto out_unlock;
 
 	BUG_ON(!PageSwapBacked(page));
-	__split_huge_page(page, anon_vma, list);
+	__split_anon_huge_page(page, anon_vma, list);
 	count_vm_event(THP_SPLIT);
 
 	BUG_ON(PageCompound(page));
@@ -1862,6 +1868,94 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+static void __split_file_mapping(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	struct radix_tree_iter iter;
+	void **slot;
+	int count = 1;
+
+	spin_lock(&mapping->tree_lock);
+	radix_tree_for_each_slot(slot, &mapping->page_tree,
+			&iter, page->index + 1) {
+		struct page *slot_page;
+
+		slot_page = radix_tree_deref_slot_protected(slot,
+				&mapping->tree_lock);
+		BUG_ON(slot_page != page);
+		radix_tree_replace_slot(slot, page + count);
+		if (++count == HPAGE_CACHE_NR)
+			break;
+	}
+	BUG_ON(count != HPAGE_CACHE_NR);
+	spin_unlock(&mapping->tree_lock);
+}
+
+static int split_file_huge_page(struct page *page, struct list_head *list)
+{
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	int mapcount, mapcount2;
+
+	BUG_ON(!PageHead(page));
+	BUG_ON(PageTail(page));
+
+	down_write(&inode->i_split_sem);
+	mutex_lock(&mapping->i_mmap_mutex);
+	mapcount = 0;
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+		unsigned long addr = vma_address(page, vma);
+		mapcount += __split_huge_page_splitting(page, vma, addr);
+	}
+
+	if (mapcount != page_mapcount(page))
+		printk(KERN_ERR "mapcount %d page_mapcount %d\n",
+		       mapcount, page_mapcount(page));
+	BUG_ON(mapcount != page_mapcount(page));
+
+	__split_huge_page_refcount(page, list);
+	__split_file_mapping(page);
+
+	mapcount2 = 0;
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+		unsigned long addr = vma_address(page, vma);
+		mapcount2 += __split_huge_page_map(page, vma, addr);
+	}
+
+	if (mapcount != mapcount2)
+		printk(KERN_ERR "mapcount %d mapcount2 %d page_mapcount %d\n",
+		       mapcount, mapcount2, page_mapcount(page));
+	BUG_ON(mapcount != mapcount2);
+	count_vm_event(THP_SPLIT);
+	mutex_unlock(&mapping->i_mmap_mutex);
+	up_write(&inode->i_split_sem);
+
+	/*
+	 * Drop small pages beyond i_size if any.
+	 */
+	truncate_inode_pages(mapping, i_size_read(inode));
+	return 0;
+}
+#else
+static int split_file_huge_page(struct page *page, struct list_head *list)
+{
+	BUG();
+}
+#endif
+
+int split_huge_page_to_list(struct page *page, struct list_head *list)
+{
+	BUG_ON(is_huge_zero_page(page));
+
+	if (PageAnon(page))
+		return split_anon_huge_page(page, list);
+	else
+		return split_file_huge_page(page, list);
+}
+
 #define VM_NO_THP (VM_SPECIAL|VM_MIXEDMAP|VM_HUGETLB|VM_SHARED|VM_MAYSHARE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
