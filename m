Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 44A1A28025D
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:56:08 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fu12so85071454pac.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:56:08 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g188si39078344pfc.294.2016.09.15.04.56.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:56:07 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 14/41] filemap: allocate huge page in page_cache_read(), if allowed
Date: Thu, 15 Sep 2016 14:54:56 +0300
Message-Id: <20160915115523.29737-15-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
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
 mm/filemap.c            | 148 +++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 157 insertions(+), 17 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 901e25d495cc..122024ccc739 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1829,6 +1829,11 @@ struct super_operations {
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
index 66a1260b33de..a84f11a672f0 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -191,14 +191,20 @@ static inline int page_cache_add_speculative(struct page *page, int count)
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
@@ -215,6 +221,15 @@ static inline gfp_t readahead_gfp_mask(struct address_space *x)
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
index 6f7f45f47d68..50afe17230e7 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -637,14 +637,14 @@ static int __add_to_page_cache_locked(struct page *page,
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
@@ -653,7 +653,7 @@ static int __add_to_page_cache_locked(struct page *page,
 
 	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error) {
-		if (!huge)
+		if (!hugetlb)
 			mem_cgroup_cancel_charge(page, memcg, false);
 		return error;
 	}
@@ -663,16 +663,55 @@ static int __add_to_page_cache_locked(struct page *page,
 	page->index = offset;
 
 	spin_lock_irq(&mapping->tree_lock);
-	error = page_cache_tree_insert(mapping, page, shadowp);
+	if (PageTransHuge(page)) {
+		struct radix_tree_iter iter;
+		void **slot;
+		void *p;
+
+		error = 0;
+
+		/* Wipe shadow entires */
+		radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, offset) {
+			if (iter.index >= offset + HPAGE_PMD_NR)
+				break;
+
+			p = radix_tree_deref_slot_protected(slot,
+					&mapping->tree_lock);
+			if (!p)
+				continue;
+
+			if (!radix_tree_exception(p)) {
+				error = -EEXIST;
+				break;
+			}
+
+			mapping->nrexceptional--;
+			rcu_assign_pointer(*slot, NULL);
+		}
+
+		if (!error)
+			error = __radix_tree_insert(&mapping->page_tree, offset,
+					compound_order(page), page);
+
+		if (!error) {
+			count_vm_event(THP_FILE_ALLOC);
+			mapping->nrpages += HPAGE_PMD_NR;
+			*shadowp = NULL;
+			__inc_node_page_state(page, NR_FILE_THPS);
+		}
+	} else {
+		error = page_cache_tree_insert(mapping, page, shadowp);
+	}
 	radix_tree_preload_end();
 	if (unlikely(error))
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
@@ -680,7 +719,7 @@ err_insert:
 	page->mapping = NULL;
 	/* Leave page->index set: truncation relies upon it */
 	spin_unlock_irq(&mapping->tree_lock);
-	if (!huge)
+	if (!hugetlb)
 		mem_cgroup_cancel_charge(page, memcg, false);
 	put_page(page);
 	return error;
@@ -737,7 +776,7 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 
 #ifdef CONFIG_NUMA
-struct page *__page_cache_alloc(gfp_t gfp)
+struct page *__page_cache_alloc_order(gfp_t gfp, unsigned int order)
 {
 	int n;
 	struct page *page;
@@ -747,14 +786,14 @@ struct page *__page_cache_alloc(gfp_t gfp)
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
@@ -1149,6 +1188,69 @@ repeat:
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
@@ -2022,19 +2124,37 @@ static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
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
+		if (PageTransHuge(page))
+			hoffset = round_down(offset, HPAGE_PMD_NR);
+		else
+			hoffset = offset;
+
+		ret = add_to_page_cache_lru(page, mapping, hoffset,
+				gfp_mask & GFP_KERNEL);
 		if (ret == 0)
 			ret = mapping->a_ops->readpage(file, page);
 		else if (ret == -EEXIST)
 			ret = 0; /* losing race to add is OK */
 
+		if (ret && PageTransHuge(page)) {
+			delete_from_page_cache(page);
+			unlock_page(page);
+			put_page(page);
+			page = NULL;
+			goto no_huge;
+		}
+
 		put_page(page);
 
 	} while (ret == AOP_TRUNCATED_PAGE);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
