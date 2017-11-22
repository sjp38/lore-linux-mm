Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 206D76B02D0
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:25 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q187so998247pga.6
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z3si14023392pln.252.2017.11.22.13.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:18 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 34/62] page cache: Use xarray for adding pages
Date: Wed, 22 Nov 2017 13:07:11 -0800
Message-Id: <20171122210739.29916-35-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Use the XArray APIs to add and replace pages in the page cache.  This
removes two uses of the radix tree preload API and is significantly
shorter code.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h |  13 +++++
 mm/filemap.c           | 131 +++++++++++++++++++++----------------------------
 2 files changed, 69 insertions(+), 75 deletions(-)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 8d7cd70beb8e..1648eda4a20d 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -542,6 +542,19 @@ static inline void xas_set_order(struct xa_state *xas, unsigned long index,
 	xas->xa_node = XAS_RESTART;
 }
 
+/**
+ * xas_set_update() - Set up XArray operation state for a callback.
+ * @xas: XArray operation state.
+ * @update: Function to call when updating a node.
+ *
+ * The XArray can notify a caller after it has updated an xa_node.
+ * This is advanced functionality and is only needed by the page cache.
+ */
+static inline void xas_set_update(struct xa_state *xas, xa_update_node_t update)
+{
+	xas->xa_update = update;
+}
+
 /* Skip over any of these entries when iterating */
 static inline bool xa_iter_skip(void *entry)
 {
diff --git a/mm/filemap.c b/mm/filemap.c
index accc350f9544..1d520748789b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -112,34 +112,6 @@
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
 
-static int page_cache_tree_insert(struct address_space *mapping,
-				  struct page *page, void **shadowp)
-{
-	struct radix_tree_node *node;
-	void **slot;
-	int error;
-
-	error = __radix_tree_create(&mapping->pages, page->index, 0,
-				    &node, &slot);
-	if (error)
-		return error;
-	if (*slot) {
-		void *p;
-
-		p = radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock);
-		if (!xa_is_value(p))
-			return -EEXIST;
-
-		mapping->nrexceptional--;
-		if (shadowp)
-			*shadowp = p;
-	}
-	__radix_tree_replace(&mapping->pages, node, slot, page,
-			     workingset_lookup_update(mapping));
-	mapping->nrpages++;
-	return 0;
-}
-
 static void page_cache_tree_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
@@ -775,51 +747,44 @@ EXPORT_SYMBOL(file_write_and_wait_range);
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
+	XA_STATE(xas, old->index);
+	struct address_space *mapping = old->mapping;
+	void (*freepage)(struct page *) = mapping->a_ops->freepage;
+	pgoff_t offset = old->index;
+	unsigned long flags;
 
 	VM_BUG_ON_PAGE(!PageLocked(old), old);
 	VM_BUG_ON_PAGE(!PageLocked(new), new);
 	VM_BUG_ON_PAGE(new->mapping, new);
 
-	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
-	if (!error) {
-		struct address_space *mapping = old->mapping;
-		void (*freepage)(struct page *);
-		unsigned long flags;
-
-		pgoff_t offset = old->index;
-		freepage = mapping->a_ops->freepage;
-
-		get_page(new);
-		new->mapping = mapping;
-		new->index = offset;
+	get_page(new);
+	new->mapping = mapping;
+	new->index = offset;
 
-		xa_lock_irqsave(&mapping->pages, flags);
-		__delete_from_page_cache(old, NULL);
-		error = page_cache_tree_insert(mapping, new, NULL);
-		BUG_ON(error);
+	xa_lock_irqsave(&mapping->pages, flags);
+	xas_store(&mapping->pages, &xas, new);
 
-		/*
-		 * hugetlb pages do not participate in page cache accounting.
-		 */
-		if (!PageHuge(new))
-			__inc_node_page_state(new, NR_FILE_PAGES);
-		if (PageSwapBacked(new))
-			__inc_node_page_state(new, NR_SHMEM);
-		xa_unlock_irqrestore(&mapping->pages, flags);
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
+	xa_unlock_irqrestore(&mapping->pages, flags);
+	mem_cgroup_migrate(old, new);
+	if (freepage)
+		freepage(old);
+	put_page(old);
 
-	return error;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(replace_page_cache_page);
 
@@ -828,12 +793,15 @@ static int __add_to_page_cache_locked(struct page *page,
 				      pgoff_t offset, gfp_t gfp_mask,
 				      void **shadowp)
 {
+	XA_STATE(xas, offset);
 	int huge = PageHuge(page);
 	struct mem_cgroup *memcg;
 	int error;
+	void *old;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageSwapBacked(page), page);
+	xas_set_update(&xas, workingset_lookup_update(mapping));
 
 	if (!huge) {
 		error = mem_cgroup_try_charge(page, current->mm,
@@ -842,35 +810,48 @@ static int __add_to_page_cache_locked(struct page *page,
 			return error;
 	}
 
-	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
-	if (error) {
-		if (!huge)
-			mem_cgroup_cancel_charge(page, memcg, false);
-		return error;
-	}
-
 	get_page(page);
 	page->mapping = mapping;
 	page->index = offset;
 
+retry:
 	xa_lock_irq(&mapping->pages);
-	error = page_cache_tree_insert(mapping, page, shadowp);
-	radix_tree_preload_end();
-	if (unlikely(error))
-		goto err_insert;
+	old = xas_create(&mapping->pages, &xas);
+	error = xas_error(&xas);
+	if (error) {
+		xa_unlock_irq(&mapping->pages);
+		if (xas_nomem(&xas, gfp_mask & ~__GFP_HIGHMEM))
+			goto retry;
+		goto error;
+	}
+
+	if (xa_is_value(old)) {
+		mapping->nrexceptional--;
+		if (shadowp)
+			*shadowp = old;
+	} else if (old) {
+		goto exist;
+	}
+
+	xas_store(&mapping->pages, &xas, page);
+	mapping->nrpages++;
 
 	/* hugetlb pages do not participate in page cache accounting. */
 	if (!huge)
 		__inc_node_page_state(page, NR_FILE_PAGES);
 	xa_unlock_irq(&mapping->pages);
+	xas_destroy(&xas);
 	if (!huge)
 		mem_cgroup_commit_charge(page, memcg, false, false);
 	trace_mm_filemap_add_to_page_cache(page);
 	return 0;
-err_insert:
+exist:
+	xa_unlock_irq(&mapping->pages);
+	error = -EEXIST;
+error:
+	xas_destroy(&xas);
 	page->mapping = NULL;
 	/* Leave page->index set: truncation relies upon it */
-	xa_unlock_irq(&mapping->pages);
 	if (!huge)
 		mem_cgroup_cancel_charge(page, memcg, false);
 	put_page(page);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
