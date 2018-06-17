Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2324D6B02D6
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:02:54 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e1-v6so7648738pld.23
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:02:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n68-v6si11421725pfb.152.2018.06.16.19.00.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:00:59 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 22/74] page cache: Add and replace pages using the XArray
Date: Sat, 16 Jun 2018 19:00:00 -0700
Message-Id: <20180617020052.4759-23-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Use the XArray APIs to add and replace pages in the page cache.  This
removes two uses of the radix tree preload API and is significantly
shorter code.  It also removes the last user of __radix_tree_create()
outside radix-tree.c itself, so make it static.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/radix-tree.h |   3 -
 include/linux/swap.h       |   8 ++-
 lib/radix-tree.c           |   6 +-
 mm/filemap.c               | 139 +++++++++++++++----------------------
 4 files changed, 66 insertions(+), 90 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index f64beb9ba175..4b6f685309fc 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -231,9 +231,6 @@ static inline int radix_tree_exception(void *arg)
 	return unlikely((unsigned long)arg & RADIX_TREE_ENTRY_MASK);
 }
 
-int __radix_tree_create(struct radix_tree_root *, unsigned long index,
-			unsigned order, struct radix_tree_node **nodep,
-			void __rcu ***slotp);
 int __radix_tree_insert(struct radix_tree_root *, unsigned long index,
 			unsigned order, void *);
 static inline int radix_tree_insert(struct radix_tree_root *root,
diff --git a/include/linux/swap.h b/include/linux/swap.h
index f73eafcaf4e9..1b91e7f7bdeb 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -300,8 +300,12 @@ void *workingset_eviction(struct address_space *mapping, struct page *page);
 bool workingset_refault(void *shadow);
 void workingset_activation(struct page *page);
 
-/* Do not use directly, use workingset_lookup_update */
-void workingset_update_node(struct radix_tree_node *node);
+/* Only track the nodes of mappings with shadow entries */
+void workingset_update_node(struct xa_node *node);
+#define mapping_set_update(xas, mapping) do {				\
+	if (!dax_mapping(mapping) && !shmem_mapping(mapping))		\
+		xas_set_update(xas, workingset_update_node);		\
+} while (0)
 
 /* Returns workingset_update_node() if the mapping has shadow entries. */
 #define workingset_lookup_update(mapping)				\
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index f7785f7cbd5f..5c8a262f506c 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -740,9 +740,9 @@ static bool delete_node(struct radix_tree_root *root,
  *
  *	Returns -ENOMEM, or 0 for success.
  */
-int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
-			unsigned order, struct radix_tree_node **nodep,
-			void __rcu ***slotp)
+static int __radix_tree_create(struct radix_tree_root *root,
+		unsigned long index, unsigned order,
+		struct radix_tree_node **nodep, void __rcu ***slotp)
 {
 	struct radix_tree_node *node = NULL, *child;
 	void __rcu **slot = (void __rcu **)&root->xa_head;
diff --git a/mm/filemap.c b/mm/filemap.c
index 8de36e14e22f..965ff68e5b8d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -111,35 +111,6 @@
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
 
-static int page_cache_tree_insert(struct address_space *mapping,
-				  struct page *page, void **shadowp)
-{
-	struct radix_tree_node *node;
-	void **slot;
-	int error;
-
-	error = __radix_tree_create(&mapping->i_pages, page->index, 0,
-				    &node, &slot);
-	if (error)
-		return error;
-	if (*slot) {
-		void *p;
-
-		p = radix_tree_deref_slot_protected(slot,
-						    &mapping->i_pages.xa_lock);
-		if (!xa_is_value(p))
-			return -EEXIST;
-
-		mapping->nrexceptional--;
-		if (shadowp)
-			*shadowp = p;
-	}
-	__radix_tree_replace(&mapping->i_pages, node, slot, page,
-			     workingset_lookup_update(mapping));
-	mapping->nrpages++;
-	return 0;
-}
-
 static void page_cache_tree_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
@@ -775,51 +746,44 @@ EXPORT_SYMBOL(file_write_and_wait_range);
  * locked.  This function does not add the new page to the LRU, the
  * caller must do that.
  *
- * The remove + add is atomic.  The only way this function can fail is
- * memory allocation failure.
+ * The remove + add is atomic.  This function cannot fail.
  */
 int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 {
-	int error;
+	struct address_space *mapping = old->mapping;
+	void (*freepage)(struct page *) = mapping->a_ops->freepage;
+	pgoff_t offset = old->index;
+	XA_STATE(xas, &mapping->i_pages, offset);
+	unsigned long flags;
 
 	VM_BUG_ON_PAGE(!PageLocked(old), old);
 	VM_BUG_ON_PAGE(!PageLocked(new), new);
 	VM_BUG_ON_PAGE(new->mapping, new);
 
-	error = radix_tree_preload(gfp_mask & GFP_RECLAIM_MASK);
-	if (!error) {
-		struct address_space *mapping = old->mapping;
-		void (*freepage)(struct page *);
-		unsigned long flags;
-
-		pgoff_t offset = old->index;
-		freepage = mapping->a_ops->freepage;
+	get_page(new);
+	new->mapping = mapping;
+	new->index = offset;
 
-		get_page(new);
-		new->mapping = mapping;
-		new->index = offset;
+	xas_lock_irqsave(&xas, flags);
+	xas_store(&xas, new);
 
-		xa_lock_irqsave(&mapping->i_pages, flags);
-		__delete_from_page_cache(old, NULL);
-		error = page_cache_tree_insert(mapping, new, NULL);
-		BUG_ON(error);
-
-		/*
-		 * hugetlb pages do not participate in page cache accounting.
-		 */
-		if (!PageHuge(new))
-			__inc_node_page_state(new, NR_FILE_PAGES);
-		if (PageSwapBacked(new))
-			__inc_node_page_state(new, NR_SHMEM);
-		xa_unlock_irqrestore(&mapping->i_pages, flags);
-		mem_cgroup_migrate(old, new);
-		radix_tree_preload_end();
-		if (freepage)
-			freepage(old);
-		put_page(old);
-	}
+	old->mapping = NULL;
+	/* hugetlb pages do not participate in page cache accounting. */
+	if (!PageHuge(old))
+		__dec_node_page_state(new, NR_FILE_PAGES);
+	if (!PageHuge(new))
+		__inc_node_page_state(new, NR_FILE_PAGES);
+	if (PageSwapBacked(old))
+		__dec_node_page_state(new, NR_SHMEM);
+	if (PageSwapBacked(new))
+		__inc_node_page_state(new, NR_SHMEM);
+	xas_unlock_irqrestore(&xas, flags);
+	mem_cgroup_migrate(old, new);
+	if (freepage)
+		freepage(old);
+	put_page(old);
 
-	return error;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(replace_page_cache_page);
 
@@ -828,12 +792,15 @@ static int __add_to_page_cache_locked(struct page *page,
 				      pgoff_t offset, gfp_t gfp_mask,
 				      void **shadowp)
 {
+	XA_STATE(xas, &mapping->i_pages, offset);
 	int huge = PageHuge(page);
 	struct mem_cgroup *memcg;
 	int error;
+	void *old;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageSwapBacked(page), page);
+	mapping_set_update(&xas, mapping);
 
 	if (!huge) {
 		error = mem_cgroup_try_charge(page, current->mm,
@@ -842,39 +809,47 @@ static int __add_to_page_cache_locked(struct page *page,
 			return error;
 	}
 
-	error = radix_tree_maybe_preload(gfp_mask & GFP_RECLAIM_MASK);
-	if (error) {
-		if (!huge)
-			mem_cgroup_cancel_charge(page, memcg, false);
-		return error;
-	}
-
 	get_page(page);
 	page->mapping = mapping;
 	page->index = offset;
 
-	xa_lock_irq(&mapping->i_pages);
-	error = page_cache_tree_insert(mapping, page, shadowp);
-	radix_tree_preload_end();
-	if (unlikely(error))
-		goto err_insert;
+	do {
+		xas_lock_irq(&xas);
+		old = xas_load(&xas);
+		if (old && !xa_is_value(old))
+			xas_set_err(&xas, -EEXIST);
+		xas_store(&xas, page);
+		if (xas_error(&xas))
+			goto unlock;
+
+		if (xa_is_value(old)) {
+			mapping->nrexceptional--;
+			if (shadowp)
+				*shadowp = old;
+		}
+		mapping->nrpages++;
+
+		/* hugetlb pages do not participate in page cache accounting */
+		if (!huge)
+			__inc_node_page_state(page, NR_FILE_PAGES);
+unlock:
+		xas_unlock_irq(&xas);
+	} while (xas_nomem(&xas, gfp_mask & GFP_RECLAIM_MASK));
+
+	if (xas_error(&xas))
+		goto error;
 
-	/* hugetlb pages do not participate in page cache accounting. */
-	if (!huge)
-		__inc_node_page_state(page, NR_FILE_PAGES);
-	xa_unlock_irq(&mapping->i_pages);
 	if (!huge)
 		mem_cgroup_commit_charge(page, memcg, false, false);
 	trace_mm_filemap_add_to_page_cache(page);
 	return 0;
-err_insert:
+error:
 	page->mapping = NULL;
 	/* Leave page->index set: truncation relies upon it */
-	xa_unlock_irq(&mapping->i_pages);
 	if (!huge)
 		mem_cgroup_cancel_charge(page, memcg, false);
 	put_page(page);
-	return error;
+	return xas_error(&xas);
 }
 
 /**
-- 
2.17.1
