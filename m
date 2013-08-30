Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 63F9C6B003C
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 04:43:31 -0400 (EDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MSC00FVQ5K8X990@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Aug 2013 09:43:29 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC PATCH 3/4] mm: use indirect zbud handle and radix tree
Date: Fri, 30 Aug 2013 10:42:55 +0200
Message-id: <1377852176-30970-4-git-send-email-k.kozlowski@samsung.com>
In-reply-to: <1377852176-30970-1-git-send-email-k.kozlowski@samsung.com>
References: <1377852176-30970-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Add radix tree to zbud pool and use indirect zbud handle as radix tree
index.

This allows migration of zbud pages while the handle used by zswap
remains untouched. Previously zbud handles were virtual addresses. This
imposed problem when page was migrated.

This change also exposes and fixes race condition between:
 - zbud_reclaim_page() (called from zswap_frontswap_store())
and
 - zbud_free() (called from zswap_frontswap_invalidate_page()).
This race was present already but additional locking and in-direct use
handle makes it frequent during high memory pressure.

Race typically looks like:
 - thread 1: zbud_reclaim_page()
   - thread 1: zswap_writeback_entry()
     - zbud_map()
 - thread 0: zswap_frontswap_invalidate_page()
   - zbud_free()
 - thread 1: read zswap_entry from memory or call zbud_unmap(), now on
   invalid memory address

The zbud_reclaim_page() calls evict function (zswap_writeback_entry())
without holding pool lock. The zswap_writeback_entry() reads
zswap_header from memory obtained from zbud_map() without holding
tree's lock. If invalidate happens during this time the zbud_free()
will remove handle from the tree.

The new map_count fields in zbud_header try to address this problem by
protecting handles from freeing.
Also the call to zbud_unmap() in zswap_writeback_entry() was moved
further - when the tree's lock could be obtained.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 include/linux/zbud.h |    2 +-
 mm/zbud.c            |  313 +++++++++++++++++++++++++++++++++++++++++---------
 mm/zswap.c           |   24 +++-
 3 files changed, 280 insertions(+), 59 deletions(-)

diff --git a/include/linux/zbud.h b/include/linux/zbud.h
index 2571a5c..12d72df 100644
--- a/include/linux/zbud.h
+++ b/include/linux/zbud.h
@@ -16,7 +16,7 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 void zbud_free(struct zbud_pool *pool, unsigned long handle);
 int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
 void *zbud_map(struct zbud_pool *pool, unsigned long handle);
-void zbud_unmap(struct zbud_pool *pool, unsigned long handle);
+int zbud_unmap(struct zbud_pool *pool, unsigned long handle);
 u64 zbud_get_pool_size(struct zbud_pool *pool);
 
 #endif /* _ZBUD_H_ */
diff --git a/mm/zbud.c b/mm/zbud.c
index 9267cd9..5ff4ffa 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -50,6 +50,7 @@
 #include <linux/preempt.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/radix-tree.h>
 #include <linux/zbud.h>
 
 /*****************
@@ -69,6 +70,9 @@
 #define NCHUNKS		(PAGE_SIZE >> CHUNK_SHIFT)
 #define ZHDR_SIZE_ALIGNED CHUNK_SIZE
 
+/* Empty handle, not yet allocated */
+#define HANDLE_EMPTY	0
+
 /**
  * struct zbud_pool - stores metadata for each zbud pool
  * @lock:	protects all pool fields and first|last_chunk fields of any
@@ -83,6 +87,10 @@
  * @pages_nr:	number of zbud pages in the pool.
  * @ops:	pointer to a structure of user defined operations specified at
  *		pool creation time.
+ * @page_tree:	mapping handle->zbud_header for zbud_map and migration;
+ *		many pools may exist so do not use the mapping->page_tree
+ * @last_handle: last handle calculated; used as starting point when searching
+ *		for next handle in page_tree in zbud_alloc.
  *
  * This structure is allocated at pool creation time and maintains metadata
  * pertaining to a particular zbud pool.
@@ -94,6 +102,8 @@ struct zbud_pool {
 	struct list_head lru;
 	u64 pages_nr;
 	struct zbud_ops *ops;
+	struct radix_tree_root page_tree;
+	unsigned long last_handle;
 };
 
 /*
@@ -103,12 +113,23 @@ struct zbud_pool {
  * @lru:	links the zbud page into the lru list in the pool
  * @first_chunks:	the size of the first buddy in chunks, 0 if free
  * @last_chunks:	the size of the last buddy in chunks, 0 if free
+ * @first_handle:	handle to page stored in first buddy
+ * @last_handle:	handle to page stored in last buddy
+ * @first_map_count:	mapped count of page stored in first buddy
+ * @last_map_count:	mapped count of page stored in last buddy
+ *
+ * When map count reaches zero the corresponding handle is removed
+ * from radix tree and cannot be used any longer.
  */
 struct zbud_header {
 	struct list_head buddy;
 	struct list_head lru;
+	unsigned long first_handle;
+	unsigned long last_handle;
 	unsigned int first_chunks;
 	unsigned int last_chunks;
+	short int first_map_count;
+	short int last_map_count;
 };
 
 /*****************
@@ -135,38 +156,34 @@ static struct zbud_header *init_zbud_page(struct page *page)
 	struct zbud_header *zhdr = page_address(page);
 	zhdr->first_chunks = 0;
 	zhdr->last_chunks = 0;
+	zhdr->first_handle = HANDLE_EMPTY;
+	zhdr->last_handle = HANDLE_EMPTY;
+	zhdr->first_map_count = 0;
+	zhdr->last_map_count = 0;
 	INIT_LIST_HEAD(&zhdr->buddy);
 	INIT_LIST_HEAD(&zhdr->lru);
 	return zhdr;
 }
 
 /*
- * Encodes the handle of a particular buddy within a zbud page
+ * Encodes the address of a particular buddy within a zbud page
  * Pool lock should be held as this function accesses first|last_chunks
  */
-static unsigned long encode_handle(struct zbud_header *zhdr, enum buddy bud)
+static unsigned long calc_addr(struct zbud_header *zhdr, unsigned long handle)
 {
-	unsigned long handle;
+	unsigned long addr;
 
 	/*
-	 * For now, the encoded handle is actually just the pointer to the data
-	 * but this might not always be the case.  A little information hiding.
 	 * Add CHUNK_SIZE to the handle if it is the first allocation to jump
 	 * over the zbud header in the first chunk.
 	 */
-	handle = (unsigned long)zhdr;
-	if (bud == FIRST)
+	addr = (unsigned long)zhdr;
+	if (handle == zhdr->first_handle)
 		/* skip over zbud header */
-		handle += ZHDR_SIZE_ALIGNED;
-	else /* bud == LAST */
-		handle += PAGE_SIZE - (zhdr->last_chunks  << CHUNK_SHIFT);
-	return handle;
-}
-
-/* Returns the zbud page where a given handle is stored */
-static struct zbud_header *handle_to_zbud_header(unsigned long handle)
-{
-	return (struct zbud_header *)(handle & PAGE_MASK);
+		addr += ZHDR_SIZE_ALIGNED;
+	else /* handle == zhdr->last_handle */
+		addr += PAGE_SIZE - (zhdr->last_chunks  << CHUNK_SHIFT);
+	return addr;
 }
 
 /* Returns the number of free chunks in a zbud page */
@@ -207,6 +224,109 @@ static int put_zbud_page(struct zbud_header *zhdr)
 	return 0;
 }
 
+/*
+ * Increases map count for given handle.
+ *
+ * The map count is used to prevent any races between zbud_reclaim()
+ * and zbud_free().
+ *
+ * Must be called under pool->lock.
+ */
+static void get_map_count(struct zbud_header *zhdr, unsigned long handle)
+{
+	VM_BUG_ON(handle == HANDLE_EMPTY);
+	if (zhdr->first_handle == handle)
+		zhdr->first_map_count++;
+	else
+		zhdr->last_map_count++;
+}
+
+/*
+ * Decreases map count for given handle.
+ *
+ * Must be called under pool->lock.
+ *
+ * Returns 1 if no more map counts for handle exist and 0 otherwise.
+ */
+static int put_map_count(struct zbud_header *zhdr, unsigned long handle)
+{
+	VM_BUG_ON(handle == HANDLE_EMPTY);
+	if (zhdr->first_handle == handle) {
+		VM_BUG_ON(!zhdr->first_map_count);
+		return ((--zhdr->first_map_count) == 0);
+	} else {
+		VM_BUG_ON(!zhdr->last_map_count);
+		return ((--zhdr->last_map_count) == 0);
+	}
+}
+
+/*
+ * Searches for zbud header in radix tree.
+ * Returns NULL if handle could not be found.
+ *
+ * Handle could not be found in case of race between:
+ *  - zswap_writeback_entry() (called from zswap_frontswap_store())
+ * and
+ *  - zbud_free() (called from zswap_frontswap_invalidate())
+ *
+ */
+static struct zbud_header *handle_to_zbud_header(struct zbud_pool *pool,
+		unsigned long handle)
+{
+	struct zbud_header *zhdr;
+
+	rcu_read_lock();
+	zhdr = radix_tree_lookup(&pool->page_tree, handle);
+	rcu_read_unlock();
+	if (unlikely(!zhdr)) {
+		/* race: zswap_writeback_entry() and zswap_invalidate() */
+		pr_err("error: could not lookup handle %lu in tree\n", handle);
+	}
+	return zhdr;
+}
+
+/*
+ * Scans radix tree for next free handle and returns it.
+ * Returns HANDLE_EMPTY (0) if no free handle could be found.
+ *
+ * Must be called under pool->lock to be sure that there
+ * won't be other users of found handle.
+ */
+static unsigned long search_next_handle(struct zbud_pool *pool)
+{
+	unsigned long handle = pool->last_handle;
+	unsigned int retries = 0;
+	do {
+		/* 0 will be returned in case of search failure as we'll hit
+		 * the max index.
+		 */
+		handle = radix_tree_next_hole(&pool->page_tree,
+				handle + 1, ULONG_MAX);
+	} while ((handle == HANDLE_EMPTY) && (++retries < 2));
+	WARN((retries == 2), "%s: reached max number of retries (%u) when " \
+		"searching for next handle (last handle: %lu)\n",
+		       __func__, retries, pool->last_handle);
+	return handle;
+}
+
+/*
+ * Searches for next free handle in page_tree and inserts zbud_header
+ * under it. Stores the handle under given pointer and updates
+ * pool->last_handle.
+ *
+ * Must be called under pool->lock.
+ *
+ * Returns 0 on success or negative otherwise.
+ */
+static int tree_insert_zbud_header(struct zbud_pool *pool,
+		struct zbud_header *zhdr, unsigned long *handle)
+{
+	*handle = search_next_handle(pool);
+	if (unlikely(*handle == HANDLE_EMPTY))
+		return -ENOSPC;
+	pool->last_handle = *handle;
+	return radix_tree_insert(&pool->page_tree, *handle, zhdr);
+}
 
 /*****************
  * API Functions
@@ -232,8 +352,10 @@ struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
 	INIT_LIST_HEAD(&pool->buddied);
 	INIT_LIST_HEAD(&pool->lru);
+	INIT_RADIX_TREE(&pool->page_tree, GFP_ATOMIC);
 	pool->pages_nr = 0;
 	pool->ops = ops;
+	pool->last_handle = HANDLE_EMPTY;
 	return pool;
 }
 
@@ -270,10 +392,11 @@ void zbud_destroy_pool(struct zbud_pool *pool)
 int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 			unsigned long *handle)
 {
-	int chunks, i;
+	int chunks, i, err;
 	struct zbud_header *zhdr = NULL;
 	enum buddy bud;
 	struct page *page;
+	unsigned long next_handle;
 
 	if (size <= 0 || gfp & __GFP_HIGHMEM)
 		return -EINVAL;
@@ -288,6 +411,11 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 		if (!list_empty(&pool->unbuddied[i])) {
 			zhdr = list_first_entry(&pool->unbuddied[i],
 					struct zbud_header, buddy);
+			err = tree_insert_zbud_header(pool, zhdr, &next_handle);
+			if (unlikely(err)) {
+				spin_unlock(&pool->lock);
+				return err;
+			}
 			list_del(&zhdr->buddy);
 			if (zhdr->first_chunks == 0)
 				bud = FIRST;
@@ -313,11 +441,22 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	SetPageZbud(page);
 	bud = FIRST;
 
+	err = tree_insert_zbud_header(pool, zhdr, &next_handle);
+	if (unlikely(err)) {
+		put_zbud_page(zhdr);
+		spin_unlock(&pool->lock);
+		return err;
+	}
+
 found:
-	if (bud == FIRST)
+	if (bud == FIRST) {
 		zhdr->first_chunks = chunks;
-	else
+		zhdr->first_handle = next_handle;
+	} else {
 		zhdr->last_chunks = chunks;
+		zhdr->last_handle = next_handle;
+	}
+	get_map_count(zhdr, next_handle);
 
 	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0) {
 		/* Add to unbuddied list */
@@ -333,12 +472,45 @@ found:
 		list_del(&zhdr->lru);
 	list_add(&zhdr->lru, &pool->lru);
 
-	*handle = encode_handle(zhdr, bud);
+	*handle = next_handle;
 	spin_unlock(&pool->lock);
 
 	return 0;
 }
 
+/*
+ * Real code for freeing handle.
+ * Removes handle from radix tree, empties chunks and handle in zbud header,
+ * removes buddy from lists and finally puts page.
+ */
+static void zbud_header_free(struct zbud_pool *pool, struct zbud_header *zhdr,
+		unsigned long handle)
+{
+	struct zbud_header *old = radix_tree_delete(&pool->page_tree, handle);
+	VM_BUG_ON(old != zhdr);
+
+	if (zhdr->first_handle == handle) {
+		zhdr->first_chunks = 0;
+		zhdr->first_handle = HANDLE_EMPTY;
+	} else {
+		zhdr->last_chunks = 0;
+		zhdr->last_handle = HANDLE_EMPTY;
+	}
+
+	/* Remove from existing buddy list */
+	list_del(&zhdr->buddy);
+
+	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
+		list_del(&zhdr->lru);
+		pool->pages_nr--;
+	} else {
+		/* Add to unbuddied list */
+		int freechunks = num_free_chunks(zhdr);
+		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+	}
+	put_zbud_page(zhdr);
+}
+
 /**
  * zbud_free() - frees the allocation associated with the given handle
  * @pool:	pool in which the allocation resided
@@ -354,27 +526,18 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 	struct zbud_header *zhdr;
 
 	spin_lock(&pool->lock);
-	zhdr = handle_to_zbud_header(handle);
-
-	/* If first buddy, handle will be page aligned */
-	if ((handle - ZHDR_SIZE_ALIGNED) & ~PAGE_MASK)
-		zhdr->last_chunks = 0;
-	else
-		zhdr->first_chunks = 0;
-
-	/* Remove from existing buddy list */
-	list_del(&zhdr->buddy);
+	zhdr = handle_to_zbud_header(pool, handle);
+	VM_BUG_ON(!zhdr);
 
-	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
-		list_del(&zhdr->lru);
-		pool->pages_nr--;
+	if (!put_map_count(zhdr, handle)) {
+		/*
+		 * Still mapped, so just put page count and
+		 * zbud_unmap() will free later.
+		 */
+		put_zbud_page(zhdr);
 	} else {
-		/* Add to unbuddied list */
-		int freechunks = num_free_chunks(zhdr);
-		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		zbud_header_free(pool, zhdr, handle);
 	}
-
-	put_zbud_page(zhdr);
 	spin_unlock(&pool->lock);
 }
 
@@ -448,15 +611,11 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 		/* Protect zbud page against free */
 		get_zbud_page(zhdr);
 		/*
-		 * We need encode the handles before unlocking, since we can
+		 * Grab handles before unlocking, since we can
 		 * race with free that will set (first|last)_chunks to 0
 		 */
-		first_handle = 0;
-		last_handle = 0;
-		if (zhdr->first_chunks)
-			first_handle = encode_handle(zhdr, FIRST);
-		if (zhdr->last_chunks)
-			last_handle = encode_handle(zhdr, LAST);
+		first_handle = zhdr->first_handle;
+		last_handle = zhdr->last_handle;
 		spin_unlock(&pool->lock);
 
 		/* Issue the eviction callback(s) */
@@ -482,27 +641,69 @@ next:
 /**
  * zbud_map() - maps the allocation associated with the given handle
  * @pool:	pool in which the allocation resides
- * @handle:	handle associated with the allocation to be mapped
+ * @handle:	handle to be mapped
  *
- * While trivial for zbud, the mapping functions for others allocators
- * implementing this allocation API could have more complex information encoded
- * in the handle and could create temporary mappings to make the data
- * accessible to the user.
+ * Increases the page ref count and map count for handle.
  *
- * Returns: a pointer to the mapped allocation
+ * Returns: a pointer to the mapped allocation or NULL if page could
+ * not be found in radix tree for given handle.
  */
 void *zbud_map(struct zbud_pool *pool, unsigned long handle)
 {
-	return (void *)(handle);
+	struct zbud_header *zhdr;
+	void *addr;
+
+	/*
+	 * Grab lock to prevent races with zbud_free or migration.
+	 */
+	spin_lock(&pool->lock);
+	zhdr = handle_to_zbud_header(pool, handle);
+	if (!zhdr) {
+		spin_unlock(&pool->lock);
+		return NULL;
+	}
+	/*
+	 * Get page so zbud_free or migration could detect that it is
+	 * mapped by someone.
+	 */
+	get_zbud_page(zhdr);
+	get_map_count(zhdr, handle);
+	addr = (void *)calc_addr(zhdr, handle);
+	spin_unlock(&pool->lock);
+
+	return addr;
 }
 
 /**
- * zbud_unmap() - maps the allocation associated with the given handle
+ * zbud_unmap() - unmaps the allocation associated with the given handle
  * @pool:	pool in which the allocation resides
- * @handle:	handle associated with the allocation to be unmapped
+ * @handle:	handle to be unmapped
+ *
+ * Decreases the page ref count and map count for handle.
+ * If map count reaches 0 then handle is freed (it must be freed because
+ * zbud_free() was called already on it) and -EFAULT is returned.
+ *
+ * Returns: 0 on successful unmap, negative on error indicating that handle
+ * was invalidated already by zbud_free() and cannot be used anymore
  */
-void zbud_unmap(struct zbud_pool *pool, unsigned long handle)
+int zbud_unmap(struct zbud_pool *pool, unsigned long handle)
 {
+	struct zbud_header *zhdr;
+
+	zhdr = handle_to_zbud_header(pool, handle);
+	if (unlikely(!zhdr))
+		return -ENOENT;
+	spin_lock(&pool->lock);
+	if (put_map_count(zhdr, handle)) {
+		/* racing zbud_free() could not free the handle because
+		 * we were still using it so it is our job to free */
+		zbud_header_free(pool, zhdr, handle);
+		spin_unlock(&pool->lock);
+		return -EFAULT;
+	}
+	put_zbud_page(zhdr);
+	spin_unlock(&pool->lock);
+	return 0;
 }
 
 /**
diff --git a/mm/zswap.c b/mm/zswap.c
index deda2b6..706046a 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -509,8 +509,15 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 
 	/* extract swpentry from data */
 	zhdr = zbud_map(pool, handle);
+	if (!zhdr) {
+		/*
+		 * Race with zbud_free() (called from invalidate).
+		 * Entry was invalidated already.
+		 */
+		return 0;
+	}
 	swpentry = zhdr->swpentry; /* here */
-	zbud_unmap(pool, handle);
+	VM_BUG_ON(swp_type(swpentry) >= MAX_SWAPFILES);
 	tree = zswap_trees[swp_type(swpentry)];
 	offset = swp_offset(swpentry);
 	BUG_ON(pool != tree->pool);
@@ -520,10 +527,20 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 	entry = zswap_rb_search(&tree->rbroot, offset);
 	if (!entry) {
 		/* entry was invalidated */
+		zbud_unmap(pool, handle);
 		spin_unlock(&tree->lock);
 		return 0;
 	}
 	zswap_entry_get(entry);
+	/*
+	 * Unmap zbud after obtaining tree lock and entry ref to prevent
+	 * any races with invalidate.
+	 */
+	if (zbud_unmap(pool, handle)) {
+		zswap_entry_put(entry);
+		spin_unlock(&tree->lock);
+		return 0;
+	}
 	spin_unlock(&tree->lock);
 	BUG_ON(offset != entry->offset);
 
@@ -544,6 +561,7 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 		dlen = PAGE_SIZE;
 		src = (u8 *)zbud_map(tree->pool, entry->handle) +
 			sizeof(struct zswap_header);
+		VM_BUG_ON(!src);
 		dst = kmap_atomic(page);
 		ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src,
 				entry->length, dst, &dlen);
@@ -661,8 +679,9 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	zhdr->swpentry = swp_entry(type, offset);
 	buf = (u8 *)(zhdr + 1);
 	memcpy(buf, dst, dlen);
-	zbud_unmap(tree->pool, handle);
+	ret = zbud_unmap(tree->pool, handle);
 	put_cpu_var(zswap_dstmem);
+	VM_BUG_ON(ret);
 
 	/* populate entry */
 	entry->offset = offset;
@@ -726,6 +745,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 	dlen = PAGE_SIZE;
 	src = (u8 *)zbud_map(tree->pool, entry->handle) +
 			sizeof(struct zswap_header);
+	VM_BUG_ON(!src);
 	dst = kmap_atomic(page);
 	ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
 		dst, &dlen);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
