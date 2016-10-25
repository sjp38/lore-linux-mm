Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1426B0266
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e6so131294544pfk.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:15 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p187si17912762pfg.145.2016.10.24.17.14.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 13/43] filemap: allocate huge page in page_cache_read(), if allowed
Date: Tue, 25 Oct 2016 03:13:12 +0300
Message-Id: <20161025001342.76126-14-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch adds basic functionality to put huge page into page cache.

At the moment we only put huge pages into radix-tree if the range covered
by the huge page is empty.

We ignore shadow entires for now, just remove them from the tree before
inserting huge page.

Later we can add logic to accumulate information from shadow entires to
return to caller (average eviction time?).

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/fs.h         |   5 ++
 include/linux/pagemap.h    |  21 +++++-
 include/linux/radix-tree.h |  10 +++
 include/linux/swap.h       |   2 +
 mm/filemap.c               | 174 +++++++++++++++++++++++++++++++++++++++++----
 mm/truncate.c              |  18 +----
 mm/workingset.c            |  23 ++++++
 7 files changed, 218 insertions(+), 35 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 16d2b6e874d6..d4c60f914610 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1838,6 +1838,11 @@ struct super_operations {
 #else
 #define S_DAX		0	/* Make all the DAX code disappear */
 #endif
+#define S_HUGE_MODE		0xc000
+#define S_HUGE_NEVER		0x0000
+#define S_HUGE_ALWAYS		0x4000
+#define S_HUGE_WITHIN_SIZE	0x8000
+#define S_HUGE_ADVISE		0xc000
 
 /*
  * Note that nosuid etc flags are inode-specific: setting some file-system
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index dd15d39e1985..712343108d31 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -201,14 +201,20 @@ static inline int page_cache_add_speculative(struct page *page, int count)
 }
 
 #ifdef CONFIG_NUMA
-extern struct page *__page_cache_alloc(gfp_t gfp);
+extern struct page *__page_cache_alloc_order(gfp_t gfp, unsigned int order);
 #else
-static inline struct page *__page_cache_alloc(gfp_t gfp)
+static inline struct page *__page_cache_alloc_order(gfp_t gfp,
+		unsigned int order)
 {
-	return alloc_pages(gfp, 0);
+	return alloc_pages(gfp, order);
 }
 #endif
 
+static inline struct page *__page_cache_alloc(gfp_t gfp)
+{
+	return __page_cache_alloc_order(gfp, 0);
+}
+
 static inline struct page *page_cache_alloc(struct address_space *x)
 {
 	return __page_cache_alloc(mapping_gfp_mask(x));
@@ -225,6 +231,15 @@ static inline gfp_t readahead_gfp_mask(struct address_space *x)
 				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN;
 }
 
+extern bool __page_cache_allow_huge(struct address_space *x, pgoff_t offset);
+static inline bool page_cache_allow_huge(struct address_space *x,
+		pgoff_t offset)
+{
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+		return false;
+	return __page_cache_allow_huge(x, offset);
+}
+
 typedef int filler_t(void *, struct page *);
 
 pgoff_t page_cache_next_hole(struct address_space *mapping,
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index f84780aefd06..88ea6a6a0539 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -418,6 +418,16 @@ void **radix_tree_iter_retry(struct radix_tree_iter *iter)
 	return NULL;
 }
 
+static inline __must_check
+struct radix_tree_node *radix_tree_iter_to_node(struct radix_tree_root *root,
+		struct radix_tree_iter *iter, void **slot)
+{
+       if ((void **)&root->rnode == slot)
+               return NULL;
+       slot -= (iter->index >> iter_shift(iter)) & RADIX_TREE_MAP_MASK;
+       return container_of(slot, struct radix_tree_node, slots[0]);
+}
+
 static inline unsigned long
 __radix_tree_iter_add(struct radix_tree_iter *iter, unsigned long slots)
 {
diff --git a/include/linux/swap.h b/include/linux/swap.h
index a56523cefb9b..7e961b5a2f98 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -246,6 +246,8 @@ struct swap_info_struct {
 void *workingset_eviction(struct address_space *mapping, struct page *page);
 bool workingset_refault(void *shadow);
 void workingset_activation(struct page *page);
+void workingset_clear_exceptional_entry(struct address_space *mapping,
+		struct radix_tree_node *node, void **slot);
 extern struct list_lru workingset_shadow_nodes;
 
 static inline unsigned int workingset_node_pages(struct radix_tree_node *node)
diff --git a/mm/filemap.c b/mm/filemap.c
index e9376610ad3c..f8387488636f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -110,6 +110,67 @@
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
 
+static int page_cache_tree_insert_huge(struct address_space *mapping,
+				  struct page *page, void **shadowp)
+{
+	struct radix_tree_node *node;
+	struct radix_tree_iter iter;
+	void **slot, *p;
+	int error = 0;
+
+	/* Wipe shadow entires */
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
+			page->index) {
+		if (iter.index >= page->index + HPAGE_PMD_NR)
+			break;
+
+		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
+		if (!p)
+			continue;
+
+		if (!radix_tree_exception(p)) {
+			error = -EEXIST;
+			break;
+		}
+
+		node = radix_tree_iter_to_node(&mapping->page_tree,
+				&iter, slot);
+		if (node) {
+			workingset_clear_exceptional_entry(mapping,
+					node, slot);
+			__radix_tree_delete_node(&mapping->page_tree, node);
+		}
+	}
+
+	if (!error)
+		error = __radix_tree_insert(&mapping->page_tree,
+				page->index, compound_order(page), page);
+
+	if (error)
+		return error;
+
+	count_vm_event(THP_FILE_ALLOC);
+	mapping->nrpages += HPAGE_PMD_NR;
+	*shadowp = NULL;
+	__inc_node_page_state(page, NR_FILE_THPS);
+
+	__radix_tree_lookup(&mapping->page_tree, page->index, &node, NULL);
+	if (node) {
+		/*
+		 * Don't track node that contains actual pages.
+		 *
+		 * Avoid acquiring the list_lru lock if already
+		 * untracked.  The list_empty() test is safe as
+		 * node->private_list is protected by
+		 * mapping->tree_lock.
+		 */
+		if (!list_empty(&node->private_list))
+			list_lru_del(&workingset_shadow_nodes,
+					&node->private_list);
+	}
+	return 0;
+}
+
 static int page_cache_tree_insert(struct address_space *mapping,
 				  struct page *page, void **shadowp)
 {
@@ -117,6 +178,9 @@ static int page_cache_tree_insert(struct address_space *mapping,
 	void **slot;
 	int error;
 
+	if (PageTransHuge(page))
+		return page_cache_tree_insert_huge(mapping, page, shadowp);
+
 	error = __radix_tree_create(&mapping->page_tree, page->index, 0,
 				    &node, &slot);
 	if (error)
@@ -653,14 +717,14 @@ static int __add_to_page_cache_locked(struct page *page,
 				      pgoff_t offset, gfp_t gfp_mask,
 				      void **shadowp)
 {
-	int huge = PageHuge(page);
+	int hugetlb = PageHuge(page);
 	struct mem_cgroup *memcg;
 	int error;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageSwapBacked(page), page);
 
-	if (!huge) {
+	if (!hugetlb) {
 		error = mem_cgroup_try_charge(page, current->mm,
 					      gfp_mask, &memcg, false);
 		if (error)
@@ -669,7 +733,7 @@ static int __add_to_page_cache_locked(struct page *page,
 
 	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error) {
-		if (!huge)
+		if (!hugetlb)
 			mem_cgroup_cancel_charge(page, memcg, false);
 		return error;
 	}
@@ -685,10 +749,11 @@ static int __add_to_page_cache_locked(struct page *page,
 		goto err_insert;
 
 	/* hugetlb pages do not participate in page cache accounting. */
-	if (!huge)
-		__inc_node_page_state(page, NR_FILE_PAGES);
+	if (!hugetlb)
+		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES,
+				hpage_nr_pages(page));
 	spin_unlock_irq(&mapping->tree_lock);
-	if (!huge)
+	if (!hugetlb)
 		mem_cgroup_commit_charge(page, memcg, false, false);
 	trace_mm_filemap_add_to_page_cache(page);
 	return 0;
@@ -696,7 +761,7 @@ static int __add_to_page_cache_locked(struct page *page,
 	page->mapping = NULL;
 	/* Leave page->index set: truncation relies upon it */
 	spin_unlock_irq(&mapping->tree_lock);
-	if (!huge)
+	if (!hugetlb)
 		mem_cgroup_cancel_charge(page, memcg, false);
 	put_page(page);
 	return error;
@@ -753,7 +818,7 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 
 #ifdef CONFIG_NUMA
-struct page *__page_cache_alloc(gfp_t gfp)
+struct page *__page_cache_alloc_order(gfp_t gfp, unsigned int order)
 {
 	int n;
 	struct page *page;
@@ -763,14 +828,14 @@ struct page *__page_cache_alloc(gfp_t gfp)
 		do {
 			cpuset_mems_cookie = read_mems_allowed_begin();
 			n = cpuset_mem_spread_node();
-			page = __alloc_pages_node(n, gfp, 0);
+			page = __alloc_pages_node(n, gfp, order);
 		} while (!page && read_mems_allowed_retry(cpuset_mems_cookie));
 
 		return page;
 	}
-	return alloc_pages(gfp, 0);
+	return alloc_pages(gfp, order);
 }
-EXPORT_SYMBOL(__page_cache_alloc);
+EXPORT_SYMBOL(__page_cache_alloc_order);
 #endif
 
 /*
@@ -1165,6 +1230,69 @@ struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset)
 }
 EXPORT_SYMBOL(find_lock_entry);
 
+bool __page_cache_allow_huge(struct address_space *mapping, pgoff_t offset)
+{
+	struct inode *inode = mapping->host;
+	struct radix_tree_iter iter;
+	void **slot;
+	struct page *page;
+
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
+		return false;
+
+	offset = round_down(offset, HPAGE_PMD_NR);
+
+	switch (inode->i_flags & S_HUGE_MODE) {
+	case S_HUGE_NEVER:
+		return false;
+	case S_HUGE_ALWAYS:
+		break;
+	case S_HUGE_WITHIN_SIZE:
+		if (DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE) <
+				offset + HPAGE_PMD_NR)
+			return false;
+		break;
+	case S_HUGE_ADVISE:
+		/* TODO */
+		return false;
+	default:
+		WARN_ON_ONCE(1);
+		return false;
+	}
+
+	rcu_read_lock();
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, offset) {
+		if (iter.index >= offset + HPAGE_PMD_NR)
+			break;
+
+		/* Shadow entires are fine */
+		page = radix_tree_deref_slot(slot);
+		if (page && !radix_tree_exception(page)) {
+			rcu_read_unlock();
+			return false;
+		}
+	}
+	rcu_read_unlock();
+
+	return true;
+
+}
+
+static struct page *page_cache_alloc_huge(struct address_space *mapping,
+		pgoff_t offset, gfp_t gfp_mask)
+{
+	struct page *page;
+
+	if (!page_cache_allow_huge(mapping, offset))
+		return NULL;
+
+	gfp_mask |= __GFP_COMP | __GFP_NORETRY | __GFP_NOWARN;
+	page = __page_cache_alloc_order(gfp_mask, HPAGE_PMD_ORDER);
+	if (page)
+		prep_transhuge_page(page);
+	return page;
+}
+
 /**
  * pagecache_get_page - find and get a page reference
  * @mapping: the address_space to search
@@ -2044,18 +2172,34 @@ static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
 {
 	struct address_space *mapping = file->f_mapping;
 	struct page *page;
+	pgoff_t hoffset;
 	int ret;
 
 	do {
-		page = __page_cache_alloc(gfp_mask|__GFP_COLD);
+		page = page_cache_alloc_huge(mapping, offset, gfp_mask);
+no_huge:
+		if (!page)
+			page = __page_cache_alloc(gfp_mask|__GFP_COLD);
 		if (!page)
 			return -ENOMEM;
 
-		ret = add_to_page_cache_lru(page, mapping, offset, gfp_mask & GFP_KERNEL);
-		if (ret == 0)
+		if (PageTransHuge(page))
+			hoffset = round_down(offset, HPAGE_PMD_NR);
+		else
+			hoffset = offset;
+
+		ret = add_to_page_cache_lru(page, mapping, hoffset,
+				gfp_mask & GFP_KERNEL);
+
+		if (ret == -EEXIST && PageTransHuge(page)) {
+			put_page(page);
+			page = NULL;
+			goto no_huge;
+		} else if (ret == 0) {
 			ret = mapping->a_ops->readpage(file, page);
-		else if (ret == -EEXIST)
+		} else if (ret == -EEXIST) {
 			ret = 0; /* losing race to add is OK */
+		}
 
 		put_page(page);
 
diff --git a/mm/truncate.c b/mm/truncate.c
index 393bf9447231..f88e2f1eb6f0 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -49,23 +49,7 @@ static void clear_exceptional_entry(struct address_space *mapping,
 		goto unlock;
 	if (*slot != entry)
 		goto unlock;
-	radix_tree_replace_slot(slot, NULL);
-	mapping->nrexceptional--;
-	if (!node)
-		goto unlock;
-	workingset_node_shadows_dec(node);
-	/*
-	 * Don't track node without shadow entries.
-	 *
-	 * Avoid acquiring the list_lru lock if already untracked.
-	 * The list_empty() test is safe as node->private_list is
-	 * protected by mapping->tree_lock.
-	 */
-	if (!workingset_node_shadows(node) &&
-	    !list_empty(&node->private_list))
-		list_lru_del(&workingset_shadow_nodes,
-				&node->private_list);
-	__radix_tree_delete_node(&mapping->page_tree, node);
+	workingset_clear_exceptional_entry(mapping, node, slot);
 unlock:
 	spin_unlock_irq(&mapping->tree_lock);
 }
diff --git a/mm/workingset.c b/mm/workingset.c
index 617475f529f4..915f1f76e1ac 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -322,6 +322,29 @@ void workingset_activation(struct page *page)
 	rcu_read_unlock();
 }
 
+void workingset_clear_exceptional_entry(struct address_space *mapping,
+		struct radix_tree_node *node, void **slot)
+{
+	radix_tree_replace_slot(slot, NULL);
+	mapping->nrexceptional--;
+	if (!node)
+		return;
+
+	workingset_node_shadows_dec(node);
+	/*
+	 * Don't track node without shadow entries.
+	 *
+	 * Avoid acquiring the list_lru lock if already untracked.
+	 * The list_empty() test is safe as node->private_list is
+	 * protected by mapping->tree_lock.
+	 */
+	if (!workingset_node_shadows(node) &&
+	    !list_empty(&node->private_list))
+		list_lru_del(&workingset_shadow_nodes,
+				&node->private_list);
+	__radix_tree_delete_node(&mapping->page_tree, node);
+}
+
 /*
  * Shadow entries reflect the share of the working set that does not
  * fit into memory, so their number depends on the access pattern of
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
