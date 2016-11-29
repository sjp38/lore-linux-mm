Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3D706B027F
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:57 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g186so421899909pgc.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:57 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e1si59452345pfb.241.2016.11.29.03.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:56 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 07/36] filemap: allocate huge page in page_cache_read(), if allowed
Date: Tue, 29 Nov 2016 14:22:35 +0300
Message-Id: <20161129112304.90056-8-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
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
 include/linux/fs.h      |   5 ++
 include/linux/pagemap.h |  21 ++++++-
 mm/filemap.c            | 155 ++++++++++++++++++++++++++++++++++++++----------
 3 files changed, 147 insertions(+), 34 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 03a5a398ae83..be94b922a22f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1799,6 +1799,11 @@ struct super_operations {
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
index f88d69e2419d..e530e7b3b6b2 100644
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
diff --git a/mm/filemap.c b/mm/filemap.c
index 16d39340c106..74341f8b831e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -113,37 +113,50 @@
 static int page_cache_tree_insert(struct address_space *mapping,
 				  struct page *page, void **shadowp)
 {
-	struct radix_tree_node *node;
-	void **slot;
+	struct radix_tree_iter iter;
+	void **slot, *p;
 	int error;
 
-	error = __radix_tree_create(&mapping->page_tree, page->index, 0,
-				    &node, &slot);
-	if (error)
-		return error;
-	if (*slot) {
-		void *p;
+	/* Wipe shadow entires */
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
+			page->index) {
+		if (iter.index >= page->index + hpage_nr_pages(page))
+			break;
 
 		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
-		if (!radix_tree_exceptional_entry(p))
+		if (!p)
+			continue;
+
+		if (!radix_tree_exception(p))
 			return -EEXIST;
 
+		__radix_tree_replace(&mapping->page_tree, iter.node, slot, NULL,
+				workingset_update_node, mapping);
+
 		mapping->nrexceptional--;
-		if (!dax_mapping(mapping)) {
-			if (shadowp)
-				*shadowp = p;
-		} else {
+		if (dax_mapping(mapping)) {
 			/* DAX can replace empty locked entry with a hole */
 			WARN_ON_ONCE(p !=
 				dax_radix_locked_entry(0, RADIX_DAX_EMPTY));
 			/* Wakeup waiters for exceptional entry lock */
 			dax_wake_mapping_entry_waiter(mapping, page->index, p,
 						      false);
+		} else if (!PageTransHuge(page) && shadowp) {
+			*shadowp = p;
 		}
 	}
-	__radix_tree_replace(&mapping->page_tree, node, slot, page,
-			     workingset_update_node, mapping);
-	mapping->nrpages++;
+
+	error = __radix_tree_insert(&mapping->page_tree,
+			page->index, compound_order(page), page);
+	/* This shouldn't happen */
+	if (WARN_ON_ONCE(error))
+		return error;
+
+	mapping->nrpages += hpage_nr_pages(page);
+	if (PageTransHuge(page) && !PageHuge(page)) {
+		count_vm_event(THP_FILE_ALLOC);
+		__inc_node_page_state(page, NR_FILE_THPS);
+	}
 	return 0;
 }
 
@@ -600,14 +613,14 @@ static int __add_to_page_cache_locked(struct page *page,
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
@@ -616,7 +629,7 @@ static int __add_to_page_cache_locked(struct page *page,
 
 	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error) {
-		if (!huge)
+		if (!hugetlb)
 			mem_cgroup_cancel_charge(page, memcg, false);
 		return error;
 	}
@@ -632,10 +645,11 @@ static int __add_to_page_cache_locked(struct page *page,
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
@@ -643,7 +657,7 @@ static int __add_to_page_cache_locked(struct page *page,
 	page->mapping = NULL;
 	/* Leave page->index set: truncation relies upon it */
 	spin_unlock_irq(&mapping->tree_lock);
-	if (!huge)
+	if (!hugetlb)
 		mem_cgroup_cancel_charge(page, memcg, false);
 	put_page(page);
 	return error;
@@ -700,7 +714,7 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 
 #ifdef CONFIG_NUMA
-struct page *__page_cache_alloc(gfp_t gfp)
+struct page *__page_cache_alloc_order(gfp_t gfp, unsigned int order)
 {
 	int n;
 	struct page *page;
@@ -710,14 +724,14 @@ struct page *__page_cache_alloc(gfp_t gfp)
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
@@ -1102,6 +1116,69 @@ struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset)
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
@@ -1941,18 +2018,34 @@ static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
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
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
