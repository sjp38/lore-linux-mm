Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id ED2516B003C
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 09:30:12 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so8707042pdj.16
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 06:30:12 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUC00EXPQT6AJ20@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 08 Oct 2013 14:30:07 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [PATCH v3 5/6] zswap: replace tree in zswap with radix tree in zbud
Date: Tue, 08 Oct 2013 15:29:39 +0200
Message-id: <1381238980-2491-6-git-send-email-k.kozlowski@samsung.com>
In-reply-to: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
References: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

This allows migration of zbud pages.

Add radix tree to zbud replacing the red-black tree in zswap. Use
offset as index to this tree so effectively the handle concept is not
needed anymore. Zswap uses only offset to access data stored in zbud.

Functionality of red-black tree from zswap was merged into zbud's radix
tree.

The patch changes the way of storing duplicated pages. Now zswap refused
to store them.

This change also exposes and fixes race condition between:
 - zbud_reclaim_page() (called from zswap_frontswap_store())
and
 - zbud_free() (called from zswap_frontswap_invalidate_page()).
This race was present already but additional locking and in-direct use
of handle makes it frequent during high memory pressure.

Race typically looks like:
 - thread 1: zbud_reclaim_page()
   - thread 1: zswap_writeback_entry()
     - zbud_map()
 - thread 0: zswap_frontswap_invalidate_page()
   - zbud_free()
 - thread 1: read zswap_entry from memory or call zbud_unmap(), now on
   invalid memory address

The zbud_reclaim_page() calls evict handler (zswap_writeback_entry())
without holding pool lock. The zswap_writeback_entry() reads
memory under address obtained from zbud_map() without any lock held.
If invalidate happens during this time the zbud_free() will remove handle
from the tree and zbud_unmap() won't succeed.

The new map_count fields in zbud_header try to address this problem by
protecting handles from freeing.

Still are some things to do in this patch:
1. Accept storing of duplicated pages (as it was in original zswap).
2. Use RCU for radix tree reads and updates.
3. Optimize locking in zbud_free_all().
4. Iterate over LRU list instead of radix tree in zbud_free_all().

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 include/linux/zbud.h |   27 +++-
 mm/zbud.c            |  387 +++++++++++++++++++++++++++++++++++-----------
 mm/zswap.c           |  419 +++++++++-----------------------------------------
 3 files changed, 388 insertions(+), 445 deletions(-)

diff --git a/include/linux/zbud.h b/include/linux/zbud.h
index 2571a5c..c4e091a 100644
--- a/include/linux/zbud.h
+++ b/include/linux/zbud.h
@@ -6,17 +6,32 @@
 struct zbud_pool;
 
 struct zbud_ops {
-	int (*evict)(struct zbud_pool *pool, unsigned long handle);
+	int (*evict)(struct zbud_pool *pool, pgoff_t offset, unsigned int type);
+};
+
+/*
+ * One entry stored in zbud, mapped and valid only between
+ * zbud_map() and zbud_unmap() calls.
+ *
+ * length  - length of stored data (compressed)
+ * addr    - mapped address where compressed data resides
+ */
+struct zbud_mapped_entry {
+	unsigned int length;
+	void *addr;
 };
 
 struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
 void zbud_destroy_pool(struct zbud_pool *pool);
 int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
-	unsigned long *handle);
-void zbud_free(struct zbud_pool *pool, unsigned long handle);
-int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
-void *zbud_map(struct zbud_pool *pool, unsigned long handle);
-void zbud_unmap(struct zbud_pool *pool, unsigned long handle);
+	pgoff_t offset);
+int zbud_free(struct zbud_pool *pool, pgoff_t offset);
+int zbud_free_all(struct zbud_pool *pool);
+int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries,
+	unsigned int type);
+int zbud_map(struct zbud_pool *pool, pgoff_t offset,
+	struct zbud_mapped_entry *entry);
+int zbud_unmap(struct zbud_pool *pool, pgoff_t offset);
 u64 zbud_get_pool_size(struct zbud_pool *pool);
 
 #endif /* _ZBUD_H_ */
diff --git a/mm/zbud.c b/mm/zbud.c
index 0edd880..1b2496e 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -34,10 +34,10 @@
  * zbud page.
  *
  * The zbud API differs from that of conventional allocators in that the
- * allocation function, zbud_alloc(), returns an opaque handle to the user,
- * not a dereferenceable pointer.  The user must map the handle using
+ * allocation function, zbud_alloc(), allocates memory for given offset and
+ * does not return dereferenceable pointer. The user must map the offset using
  * zbud_map() in order to get a usable pointer by which to access the
- * allocation data and unmap the handle with zbud_unmap() when operations
+ * allocation data and unmap the offset with zbud_unmap() when operations
  * on the allocation data are complete.
  */
 
@@ -50,6 +50,7 @@
 #include <linux/preempt.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/radix-tree.h>
 #include <linux/zbud.h>
 
 /*****************
@@ -83,6 +84,8 @@
  * @pages_nr:	number of zbud pages in the pool.
  * @ops:	pointer to a structure of user defined operations specified at
  *		pool creation time.
+ * @tree:	mapping offset->zbud_header for zbud_map and migration;
+ *		many pools may exist so do not use the mapping->page_tree
  *
  * This structure is allocated at pool creation time and maintains metadata
  * pertaining to a particular zbud pool.
@@ -94,6 +97,7 @@ struct zbud_pool {
 	struct list_head lru;
 	u64 pages_nr;
 	struct zbud_ops *ops;
+	struct radix_tree_root tree;
 };
 
 /*
@@ -101,14 +105,25 @@ struct zbud_pool {
  *			zbud page.
  * @buddy:	links the zbud page into the unbuddied/buddied lists in the pool
  * @lru:	links the zbud page into the lru list in the pool
- * @first_chunks:	the size of the first buddy in chunks, 0 if free
- * @last_chunks:	the size of the last buddy in chunks, 0 if free
+ * @first_offset:	offset to page stored in first buddy
+ * @last_offset:	offset to page stored in last buddy
+ * @first_size:		the size of the first buddy in bytes, 0 if free
+ * @last_size:		the size of the last buddy in bytes, 0 if free
+ * @first_map_count:	mapped count of page stored in first buddy
+ * @last_map_count:	mapped count of page stored in last buddy
+ *
+ * When map count reaches zero the corresponding offset is removed
+ * from radix tree and cannot be used any longer.
  */
 struct zbud_header {
 	struct list_head buddy;
 	struct list_head lru;
-	unsigned int first_chunks;
-	unsigned int last_chunks;
+	pgoff_t first_offset;
+	pgoff_t last_offset;
+	unsigned int first_size;
+	unsigned int last_size;
+	short int first_map_count;
+	short int last_map_count;
 };
 
 /*****************
@@ -140,32 +155,25 @@ static struct zbud_header *init_zbud_page(struct page *page)
 }
 
 /*
- * Encodes the handle of a particular buddy within a zbud page
+ * Calculates the address of a particular buddy within a zbud page.
  * Pool lock should be held as this function accesses first|last_chunks
  */
-static unsigned long encode_handle(struct zbud_header *zhdr, enum buddy bud)
+static unsigned long calc_addr(struct zbud_header *zhdr, pgoff_t offset)
 {
-	unsigned long handle;
+	unsigned long addr;
 
 	/*
-	 * For now, the encoded handle is actually just the pointer to the data
-	 * but this might not always be the case.  A little information hiding.
-	 * Add CHUNK_SIZE to the handle if it is the first allocation to jump
+	 * Add CHUNK_SIZE to the offset if it is the first allocation to jump
 	 * over the zbud header in the first chunk.
 	 */
-	handle = (unsigned long)zhdr;
-	if (bud == FIRST)
+	addr = (unsigned long)zhdr;
+	if (offset == zhdr->first_offset)
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
+	else /* offset == zhdr->last_offset */
+		addr += PAGE_SIZE -
+			(size_to_chunks(zhdr->last_size) << CHUNK_SHIFT);
+	return addr;
 }
 
 /* Returns the number of free chunks in a zbud page */
@@ -176,7 +184,8 @@ static int num_free_chunks(struct zbud_header *zhdr)
 	 * free buddies have a length of zero to simplify everything. -1 at the
 	 * end for the zbud header.
 	 */
-	return NCHUNKS - zhdr->first_chunks - zhdr->last_chunks - 1;
+	return NCHUNKS - size_to_chunks(zhdr->first_size) -
+		size_to_chunks(zhdr->last_size) - 1;
 }
 
 /*
@@ -189,7 +198,7 @@ static void get_zbud_page(struct zbud_header *zhdr)
 
 /*
  * Decreases ref count for zbud page and frees the page if it reaches 0
- * (no external references, e.g. handles).
+ * (no external references, e.g. offsets).
  *
  * Returns 1 if page was freed and 0 otherwise.
  */
@@ -206,6 +215,57 @@ static int put_zbud_page(struct zbud_header *zhdr)
 	return 0;
 }
 
+/*
+ * Increases map count for given offset.
+ *
+ * The map count is used to prevent any races between zbud_reclaim()
+ * and zbud_free().
+ *
+ * Must be called under pool->lock.
+ */
+static void get_map_count(struct zbud_header *zhdr, pgoff_t offset)
+{
+	VM_BUG_ON(offset == 0);
+	if (zhdr->first_offset == offset)
+		zhdr->first_map_count++;
+	else
+		zhdr->last_map_count++;
+}
+
+/*
+ * Decreases map count for given offset.
+ *
+ * Must be called under pool->lock.
+ *
+ * Returns 1 if no more map counts for offset exist and 0 otherwise.
+ */
+static int put_map_count(struct zbud_header *zhdr, pgoff_t offset)
+{
+	VM_BUG_ON(offset == 0);
+	if (zhdr->first_offset == offset) {
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
+ * Returns NULL if offset could not be found.
+ *
+ * Handle could not be found in case of race between:
+ *  - zswap_writeback_entry() (called from zswap_frontswap_store())
+ * and
+ *  - zbud_free() (called from zswap_frontswap_invalidate())
+ *
+ */
+static inline struct zbud_header *offset_to_zbud_header(struct zbud_pool *pool,
+		pgoff_t offset)
+{
+	return radix_tree_lookup(&pool->tree, offset);
+}
 
 /*****************
  * API Functions
@@ -231,6 +291,7 @@ struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
 	INIT_LIST_HEAD(&pool->buddied);
 	INIT_LIST_HEAD(&pool->lru);
+	INIT_RADIX_TREE(&pool->tree, GFP_ATOMIC);
 	pool->pages_nr = 0;
 	pool->ops = ops;
 	return pool;
@@ -252,7 +313,7 @@ void zbud_destroy_pool(struct zbud_pool *pool)
  * @pool:	zbud pool from which to allocate
  * @size:	size in bytes of the desired allocation
  * @gfp:	gfp flags used if the pool needs to grow
- * @handle:	handle of the new allocation
+ * @offset:	offset of the new allocation
  *
  * This function will attempt to find a free region in the pool large enough to
  * satisfy the allocation request.  A search of the unbuddied lists is
@@ -262,14 +323,16 @@ void zbud_destroy_pool(struct zbud_pool *pool)
  * gfp should not set __GFP_HIGHMEM as highmem pages cannot be used
  * as zbud pool pages.
  *
- * Return: 0 if success and handle is set, otherwise -EINVAL if the size or
- * gfp arguments are invalid or -ENOMEM if the pool was unable to allocate
- * a new page.
+ * Return: 0 if success and offset is added to the tree, otherwise -EINVAL if
+ * the size or gfp arguments are invalid, -ENOMEM if the pool was unable to
+ * allocate a new page, -EEXIST if offset is already stored.
+ *
+ * TODO: handle duplicate insertion into radix tree
  */
 int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
-			unsigned long *handle)
+			pgoff_t offset)
 {
-	int chunks, i;
+	int chunks, i, err;
 	struct zbud_header *zhdr = NULL;
 	enum buddy bud;
 	struct page *page;
@@ -287,8 +350,13 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 		if (!list_empty(&pool->unbuddied[i])) {
 			zhdr = list_first_entry(&pool->unbuddied[i],
 					struct zbud_header, buddy);
+			err = radix_tree_insert(&pool->tree, offset, zhdr);
+			if (unlikely(err)) {
+				spin_unlock(&pool->lock);
+				return err;
+			}
 			list_del(&zhdr->buddy);
-			if (zhdr->first_chunks == 0)
+			if (zhdr->first_size == 0)
 				bud = FIRST;
 			else
 				bud = LAST;
@@ -303,7 +371,6 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	if (!page)
 		return -ENOMEM;
 	spin_lock(&pool->lock);
-	pool->pages_nr++;
 	/*
 	 * We will be using zhdr instead of page, so
 	 * don't increase the page count.
@@ -312,13 +379,25 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	SetPageZbud(page);
 	bud = FIRST;
 
+	err = radix_tree_insert(&pool->tree, offset, zhdr);
+	if (unlikely(err)) {
+		put_zbud_page(zhdr);
+		spin_unlock(&pool->lock);
+		return err;
+	}
+	pool->pages_nr++;
+
 found:
-	if (bud == FIRST)
-		zhdr->first_chunks = chunks;
-	else
-		zhdr->last_chunks = chunks;
+	if (bud == FIRST) {
+		zhdr->first_size = size;
+		zhdr->first_offset = offset;
+	} else {
+		zhdr->last_size = size;
+		zhdr->last_offset = offset;
+	}
+	get_map_count(zhdr, offset);
 
-	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0) {
+	if (zhdr->first_size == 0 || zhdr->last_size == 0) {
 		/* Add to unbuddied list */
 		int freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
@@ -332,40 +411,34 @@ found:
 		list_del(&zhdr->lru);
 	list_add(&zhdr->lru, &pool->lru);
 
-	*handle = encode_handle(zhdr, bud);
 	spin_unlock(&pool->lock);
 
 	return 0;
 }
 
-/**
- * zbud_free() - frees the allocation associated with the given handle
- * @pool:	pool in which the allocation resided
- * @handle:	handle associated with the allocation returned by zbud_alloc()
- *
- * This function sets first|last_chunks to 0, removes zbud header from
- * appropriate lists (LRU, buddied/unbuddied) and puts the reference count
- * for it. The page is actually freed once both buddies are evicted
- * (zbud_free() called on both handles or page reclaim in zbud_reclaim_page()
- * below).
+/*
+ * Real code for freeing zbud buddy under given offset.
+ * Removes offset from radix tree, empties buddy data,
+ * removes buddy from lists and finally puts page.
  */
-void zbud_free(struct zbud_pool *pool, unsigned long handle)
+static void zbud_header_free(struct zbud_pool *pool, struct zbud_header *zhdr,
+		pgoff_t offset)
 {
-	struct zbud_header *zhdr;
+	struct zbud_header *old = radix_tree_delete(&pool->tree, offset);
+	VM_BUG_ON(old != zhdr);
 
-	spin_lock(&pool->lock);
-	zhdr = handle_to_zbud_header(handle);
-
-	/* If first buddy, handle will be page aligned */
-	if ((handle - ZHDR_SIZE_ALIGNED) & ~PAGE_MASK)
-		zhdr->last_chunks = 0;
-	else
-		zhdr->first_chunks = 0;
+	if (zhdr->first_offset == offset) {
+		zhdr->first_size = 0;
+		zhdr->first_offset = 0;
+	} else {
+		zhdr->last_size = 0;
+		zhdr->last_offset = 0;
+	}
 
 	/* Remove from existing buddy list */
 	list_del(&zhdr->buddy);
 
-	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
+	if (zhdr->first_size == 0 && zhdr->last_size == 0) {
 		list_del(&zhdr->lru);
 		pool->pages_nr--;
 	} else {
@@ -373,9 +446,88 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 		int freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
 	}
-
 	put_zbud_page(zhdr);
+}
+
+/**
+ * zbud_free() - frees the allocation associated with the given offset
+ * @pool:	pool in which the allocation resided
+ * @offset:	offset associated with the allocation
+ *
+ * This function sets first|last_size to 0, removes zbud header from
+ * appropriate lists (LRU, buddied/unbuddied) and radix tree, puts the
+ * reference count for it. The page is actually freed once both buddies
+ * are evicted (zbud_free() called on both offsets or page reclaim
+ * in zbud_reclaim_page() below).
+ *
+ * Return: 0 if success, otherwise -ENOENT if offset wasn't present in zbud
+ * (e.g. already freed by other path).
+ */
+int zbud_free(struct zbud_pool *pool, pgoff_t offset)
+{
+	struct zbud_header *zhdr;
+
+	spin_lock(&pool->lock);
+	zhdr = offset_to_zbud_header(pool, offset);
+	if (!zhdr) {
+		/* already freed by writeback or invalidate */
+		spin_unlock(&pool->lock);
+		return -ENOENT;
+	}
+
+	if (!put_map_count(zhdr, offset)) {
+		/*
+		 * Still mapped, so just put page count and
+		 * zbud_unmap() will free later.
+		 */
+		put_zbud_page(zhdr);
+	} else {
+		zbud_header_free(pool, zhdr, offset);
+	}
 	spin_unlock(&pool->lock);
+	return 0;
+}
+
+/**
+ * zbud_free_all() - frees all allocations in pool
+ * @pool:	pool in which the allocations resided
+ *
+ * Iterates over all stored pages and frees them by putting
+ * the map count, removing zbud header from lists and radix tree,
+ * putting reference count to zbud page.
+ * If some offsets are mapped then freeing of such pages will be
+ * delayed and done in zbud_unmap().
+ *
+ * Return: number of freed allocations
+ */
+int zbud_free_all(struct zbud_pool *pool)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+	int freed = 0;
+
+	/*
+	 * TODO: Can it be done under rcu_read_lock?
+	 * Spin lock would be held only for zbud_header_free().
+	 */
+	spin_lock(&pool->lock);
+	/* TODO: Iterate over pool->lru list? It may be faster. */
+	radix_tree_for_each_slot(slot, &pool->tree, &iter, 0) {
+		struct zbud_header *zhdr = radix_tree_deref_slot(slot);
+		VM_BUG_ON(!zhdr);
+		if (!put_map_count(zhdr, iter.index)) {
+			/*
+			 * Still mapped, so just put page count and
+			 * zbud_unmap() will free later.
+			 */
+			put_zbud_page(zhdr);
+		} else {
+			zbud_header_free(pool, zhdr, iter.index);
+		}
+		freed++;
+	}
+	spin_unlock(&pool->lock);
+	return freed;
 }
 
 #define list_tail_entry(ptr, type, member) \
@@ -386,6 +538,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
  * @pool:	pool from which a page will attempt to be evicted
  * @retires:	number of pages on the LRU list for which eviction will
  *		be attempted before failing
+ * @type:	type used by layer above (typically: swp_type)
  *
  * zbud reclaim is different from normal system reclaim in that the reclaim is
  * done from the bottom, up.  This is because only the bottom layer, zbud, has
@@ -398,17 +551,17 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
  * The user detects a page should be reclaimed and calls zbud_reclaim_page().
  * zbud_reclaim_page() will move zbud page to the beginning of the pool
  * LRU list, increase the page reference count and call the user-defined
- * eviction handler with the pool and handle as arguments.
+ * eviction handler with the pool and offset as arguments.
  *
- * If the handle can not be evicted, the eviction handler should return
+ * If the offset can not be evicted, the eviction handler should return
  * non-zero. zbud_reclaim_page() will drop the reference count for page
  * obtained earlier and try the next zbud page on the LRU up to
  * a user defined number of retries.
  *
- * If the handle is successfully evicted, the eviction handler should
- * return 0 _and_ should have called zbud_free() on the handle. zbud_free()
+ * If the offset is successfully evicted, the eviction handler should
+ * return 0 _and_ should have called zbud_free() on the offset. zbud_free()
  * will remove the page from appropriate lists (LRU, buddied/unbuddied) and
- * drop the reference count associated with given handle.
+ * drop the reference count associated with given offset.
  * Then the zbud_reclaim_page() will drop reference count obtained earlier.
  *
  * If all buddies in the zbud page are successfully evicted, then dropping
@@ -418,11 +571,12 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
  * no pages to evict or an eviction handler is not registered, -EAGAIN if
  * the retry limit was hit.
  */
-int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
+int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries,
+		unsigned int type)
 {
 	int i, ret;
 	struct zbud_header *zhdr;
-	unsigned long first_handle = 0, last_handle = 0;
+	pgoff_t first_offset = 0, last_offset = 0;
 
 	spin_lock(&pool->lock);
 	if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
@@ -450,25 +604,21 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 		/* Protect zbud page against free */
 		get_zbud_page(zhdr);
 		/*
-		 * We need encode the handles before unlocking, since we can
+		 * Grab offsets before unlocking, since we can
 		 * race with free that will set (first|last)_chunks to 0
 		 */
-		first_handle = 0;
-		last_handle = 0;
-		if (zhdr->first_chunks)
-			first_handle = encode_handle(zhdr, FIRST);
-		if (zhdr->last_chunks)
-			last_handle = encode_handle(zhdr, LAST);
+		first_offset = zhdr->first_offset;
+		last_offset = zhdr->last_offset;
 		spin_unlock(&pool->lock);
 
 		/* Issue the eviction callback(s) */
-		if (first_handle) {
-			ret = pool->ops->evict(pool, first_handle);
+		if (first_offset) {
+			ret = pool->ops->evict(pool, first_offset, type);
 			if (ret)
 				goto next;
 		}
-		if (last_handle) {
-			ret = pool->ops->evict(pool, last_handle);
+		if (last_offset) {
+			ret = pool->ops->evict(pool, last_offset, type);
 			if (ret)
 				goto next;
 		}
@@ -482,29 +632,80 @@ next:
 }
 
 /**
- * zbud_map() - maps the allocation associated with the given handle
+ * zbud_map() - maps the allocation associated with the given offset
  * @pool:	pool in which the allocation resides
- * @handle:	handle associated with the allocation to be mapped
+ * @offset:	offset to be mapped
+ * @entry:	entry to fill with allocation data; data is valid
+ *              only between zbud_map() and zbud_unmap() calls
  *
- * While trivial for zbud, the mapping functions for others allocators
- * implementing this allocation API could have more complex information encoded
- * in the handle and could create temporary mappings to make the data
- * accessible to the user.
+ * Increases the page ref count and map count for offset.
  *
- * Returns: a pointer to the mapped allocation
+ * Returns: 0 on successful mapping and -ENOENT if allocation was not
+ * present
  */
-void *zbud_map(struct zbud_pool *pool, unsigned long handle)
+int zbud_map(struct zbud_pool *pool, pgoff_t offset,
+		struct zbud_mapped_entry *entry)
 {
-	return (void *)(handle);
+	struct zbud_header *zhdr;
+
+	/*
+	 * Grab lock to prevent races with zbud_free or migration.
+	 */
+	spin_lock(&pool->lock);
+	zhdr = offset_to_zbud_header(pool, offset);
+	if (!zhdr) {
+		spin_unlock(&pool->lock);
+		return -ENOENT;
+	}
+	/*
+	 * Get page so zbud_free or migration could detect that it is
+	 * mapped by someone.
+	 */
+	get_zbud_page(zhdr);
+	get_map_count(zhdr, offset);
+	entry->addr = (void *)calc_addr(zhdr, offset);
+	if (zhdr->first_offset == offset)
+		entry->length = zhdr->first_size;
+	else
+		entry->length = zhdr->last_size;
+	spin_unlock(&pool->lock);
+
+	return 0;
 }
 
 /**
- * zbud_unmap() - maps the allocation associated with the given handle
+ * zbud_unmap() - unmaps the allocation associated with the given offset
  * @pool:	pool in which the allocation resides
- * @handle:	handle associated with the allocation to be unmapped
+ * @offset:	offset to be unmapped
+ *
+ * Decreases the page ref count and map count for offset.
+ * If map count reaches 0 then offset is freed (it must be freed because
+ * zbud_free() was called already on it) and -EFAULT is returned.
+ *
+ * Returns: 0 on successful unmap, -ENOENT if offset could not be found
+ * in the tree, -EFAULT indicating that offset was invalidated already by
+ * zbud_free() and cannot be used anymore
  */
-void zbud_unmap(struct zbud_pool *pool, unsigned long handle)
+int zbud_unmap(struct zbud_pool *pool, pgoff_t offset)
 {
+	struct zbud_header *zhdr;
+
+	spin_lock(&pool->lock);
+	zhdr = offset_to_zbud_header(pool, offset);
+	if (unlikely(!zhdr)) {
+		spin_unlock(&pool->lock);
+		return -ENOENT;
+	}
+	if (put_map_count(zhdr, offset)) {
+		/* racing zbud_free() could not free the offset because
+		 * we were still using it so it is our job to free */
+		zbud_header_free(pool, zhdr, offset);
+		spin_unlock(&pool->lock);
+		return -EFAULT;
+	}
+	put_zbud_page(zhdr);
+	spin_unlock(&pool->lock);
+	return 0;
 }
 
 /**
diff --git a/mm/zswap.c b/mm/zswap.c
index 841e35f..abbe457 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -30,7 +30,6 @@
 #include <linux/types.h>
 #include <linux/atomic.h>
 #include <linux/frontswap.h>
-#include <linux/rbtree.h>
 #include <linux/swap.h>
 #include <linux/crypto.h>
 #include <linux/mempool.h>
@@ -151,139 +150,7 @@ static void zswap_comp_exit(void)
 /*********************************
 * data structures
 **********************************/
-/*
- * struct zswap_entry
- *
- * This structure contains the metadata for tracking a single compressed
- * page within zswap.
- *
- * rbnode - links the entry into red-black tree for the appropriate swap type
- * refcount - the number of outstanding reference to the entry. This is needed
- *            to protect against premature freeing of the entry by code
- *            concurent calls to load, invalidate, and writeback.  The lock
- *            for the zswap_tree structure that contains the entry must
- *            be held while changing the refcount.  Since the lock must
- *            be held, there is no reason to also make refcount atomic.
- * offset - the swap offset for the entry.  Index into the red-black tree.
- * handle - zsmalloc allocation handle that stores the compressed page data
- * length - the length in bytes of the compressed page data.  Needed during
- *           decompression
- */
-struct zswap_entry {
-	struct rb_node rbnode;
-	pgoff_t offset;
-	int refcount;
-	unsigned int length;
-	unsigned long handle;
-};
-
-struct zswap_header {
-	swp_entry_t swpentry;
-};
-
-/*
- * The tree lock in the zswap_tree struct protects a few things:
- * - the rbtree
- * - the refcount field of each entry in the tree
- */
-struct zswap_tree {
-	struct rb_root rbroot;
-	spinlock_t lock;
-	struct zbud_pool *pool;
-};
-
-static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
-
-/*********************************
-* zswap entry functions
-**********************************/
-static struct kmem_cache *zswap_entry_cache;
-
-static int zswap_entry_cache_create(void)
-{
-	zswap_entry_cache = KMEM_CACHE(zswap_entry, 0);
-	return (zswap_entry_cache == NULL);
-}
-
-static void zswap_entry_cache_destory(void)
-{
-	kmem_cache_destroy(zswap_entry_cache);
-}
-
-static struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
-{
-	struct zswap_entry *entry;
-	entry = kmem_cache_alloc(zswap_entry_cache, gfp);
-	if (!entry)
-		return NULL;
-	entry->refcount = 1;
-	return entry;
-}
-
-static void zswap_entry_cache_free(struct zswap_entry *entry)
-{
-	kmem_cache_free(zswap_entry_cache, entry);
-}
-
-/* caller must hold the tree lock */
-static void zswap_entry_get(struct zswap_entry *entry)
-{
-	entry->refcount++;
-}
-
-/* caller must hold the tree lock */
-static int zswap_entry_put(struct zswap_entry *entry)
-{
-	entry->refcount--;
-	return entry->refcount;
-}
-
-/*********************************
-* rbtree functions
-**********************************/
-static struct zswap_entry *zswap_rb_search(struct rb_root *root, pgoff_t offset)
-{
-	struct rb_node *node = root->rb_node;
-	struct zswap_entry *entry;
-
-	while (node) {
-		entry = rb_entry(node, struct zswap_entry, rbnode);
-		if (entry->offset > offset)
-			node = node->rb_left;
-		else if (entry->offset < offset)
-			node = node->rb_right;
-		else
-			return entry;
-	}
-	return NULL;
-}
-
-/*
- * In the case that a entry with the same offset is found, a pointer to
- * the existing entry is stored in dupentry and the function returns -EEXIST
- */
-static int zswap_rb_insert(struct rb_root *root, struct zswap_entry *entry,
-			struct zswap_entry **dupentry)
-{
-	struct rb_node **link = &root->rb_node, *parent = NULL;
-	struct zswap_entry *myentry;
-
-	while (*link) {
-		parent = *link;
-		myentry = rb_entry(parent, struct zswap_entry, rbnode);
-		if (myentry->offset > entry->offset)
-			link = &(*link)->rb_left;
-		else if (myentry->offset < entry->offset)
-			link = &(*link)->rb_right;
-		else {
-			*dupentry = myentry;
-			return -EEXIST;
-		}
-	}
-	rb_link_node(&entry->rbnode, parent, link);
-	rb_insert_color(&entry->rbnode, root);
-	return 0;
-}
+static struct zbud_pool *zbud_pools[MAX_SWAPFILES];
 
 /*********************************
 * per-cpu code
@@ -369,15 +236,14 @@ static bool zswap_is_full(void)
 }
 
 /*
- * Carries out the common pattern of freeing and entry's zsmalloc allocation,
+ * Carries out the common pattern of freeing and entry's allocation,
  * freeing the entry itself, and decrementing the number of stored pages.
  */
-static void zswap_free_entry(struct zswap_tree *tree, struct zswap_entry *entry)
+static void zswap_free_entry(struct zbud_pool *pool, pgoff_t offset)
 {
-	zbud_free(tree->pool, entry->handle);
-	zswap_entry_cache_free(entry);
-	atomic_dec(&zswap_stored_pages);
-	zswap_pool_pages = zbud_get_pool_size(tree->pool);
+	if (zbud_free(pool, offset) == 0)
+		atomic_dec(&zswap_stored_pages);
+	zswap_pool_pages = zbud_get_pool_size(pool);
 }
 
 /*********************************
@@ -492,41 +358,20 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
  * the swap cache, the compressed version stored by zswap can be
  * freed.
  */
-static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
+static int zswap_writeback_entry(struct zbud_pool *pool, pgoff_t offset,
+		unsigned int type)
 {
-	struct zswap_header *zhdr;
-	swp_entry_t swpentry;
-	struct zswap_tree *tree;
-	pgoff_t offset;
-	struct zswap_entry *entry;
+	swp_entry_t swpentry = swp_entry(type, offset);
+	struct zbud_mapped_entry entry;
 	struct page *page;
 	u8 *src, *dst;
 	unsigned int dlen;
-	int ret, refcount;
+	int ret, unmap_ret;
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_NONE,
 	};
 
-	/* extract swpentry from data */
-	zhdr = zbud_map(pool, handle);
-	swpentry = zhdr->swpentry; /* here */
-	zbud_unmap(pool, handle);
-	tree = zswap_trees[swp_type(swpentry)];
-	offset = swp_offset(swpentry);
-	BUG_ON(pool != tree->pool);
-
-	/* find and ref zswap entry */
-	spin_lock(&tree->lock);
-	entry = zswap_rb_search(&tree->rbroot, offset);
-	if (!entry) {
-		/* entry was invalidated */
-		spin_unlock(&tree->lock);
-		return 0;
-	}
-	zswap_entry_get(entry);
-	spin_unlock(&tree->lock);
-	BUG_ON(offset != entry->offset);
-
+	VM_BUG_ON(zbud_pools[type] != pool);
 	/* try to allocate swap cache page */
 	switch (zswap_get_swap_cache_page(swpentry, &page)) {
 	case ZSWAP_SWAPCACHE_NOMEM: /* no memory */
@@ -542,15 +387,18 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 	case ZSWAP_SWAPCACHE_NEW: /* page is locked */
 		/* decompress */
 		dlen = PAGE_SIZE;
-		src = (u8 *)zbud_map(tree->pool, entry->handle) +
-			sizeof(struct zswap_header);
+		ret = zbud_map(pool, offset, &entry);
+		if (ret)
+			goto fail;
+		src = (u8 *)entry.addr;
 		dst = kmap_atomic(page);
 		ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src,
-				entry->length, dst, &dlen);
+				entry.length, dst, &dlen);
 		kunmap_atomic(dst);
-		zbud_unmap(tree->pool, entry->handle);
+		unmap_ret = zbud_unmap(pool, offset);
 		BUG_ON(ret);
 		BUG_ON(dlen != PAGE_SIZE);
+		BUG_ON(unmap_ret);
 
 		/* page is up to date */
 		SetPageUptodate(page);
@@ -560,39 +408,10 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 	__swap_writepage(page, &wbc, end_swap_bio_write);
 	page_cache_release(page);
 	zswap_written_back_pages++;
-
-	spin_lock(&tree->lock);
-
-	/* drop local reference */
-	zswap_entry_put(entry);
-	/* drop the initial reference from entry creation */
-	refcount = zswap_entry_put(entry);
-
-	/*
-	 * There are three possible values for refcount here:
-	 * (1) refcount is 1, load is in progress, unlink from rbtree,
-	 *     load will free
-	 * (2) refcount is 0, (normal case) entry is valid,
-	 *     remove from rbtree and free entry
-	 * (3) refcount is -1, invalidate happened during writeback,
-	 *     free entry
-	 */
-	if (refcount >= 0) {
-		/* no invalidate yet, remove from rbtree */
-		rb_erase(&entry->rbnode, &tree->rbroot);
-	}
-	spin_unlock(&tree->lock);
-	if (refcount <= 0) {
-		/* free the entry */
-		zswap_free_entry(tree, entry);
-		return 0;
-	}
-	return -EAGAIN;
+	zswap_free_entry(pool, offset);
+	return 0;
 
 fail:
-	spin_lock(&tree->lock);
-	zswap_entry_put(entry);
-	spin_unlock(&tree->lock);
 	return ret;
 }
 
@@ -600,19 +419,22 @@ fail:
 * frontswap hooks
 **********************************/
 /* attempts to compress and store an single page */
+/*
+ * TODO: solve duplication issue. Previously in case of storing duplicated
+ * entry the old entry was removed and new data was stored.
+ * Now zbud rejects new entry with -EEXIST and duplicated
+ * entries are not stored.
+ */
 static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 				struct page *page)
 {
-	struct zswap_tree *tree = zswap_trees[type];
-	struct zswap_entry *entry, *dupentry;
+	struct zbud_pool *pool = zbud_pools[type];
+	struct zbud_mapped_entry entry;
 	int ret;
-	unsigned int dlen = PAGE_SIZE, len;
-	unsigned long handle;
-	char *buf;
+	unsigned int dlen = PAGE_SIZE;
 	u8 *src, *dst;
-	struct zswap_header *zhdr;
 
-	if (!tree) {
+	if (!pool) {
 		ret = -ENODEV;
 		goto reject;
 	}
@@ -620,21 +442,13 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	/* reclaim space if needed */
 	if (zswap_is_full()) {
 		zswap_pool_limit_hit++;
-		if (zbud_reclaim_page(tree->pool, 8)) {
+		if (zbud_reclaim_page(pool, 8, type)) {
 			zswap_reject_reclaim_fail++;
 			ret = -ENOMEM;
 			goto reject;
 		}
 	}
 
-	/* allocate entry */
-	entry = zswap_entry_cache_alloc(GFP_KERNEL);
-	if (!entry) {
-		zswap_reject_kmemcache_fail++;
-		ret = -ENOMEM;
-		goto reject;
-	}
-
 	/* compress */
 	dst = get_cpu_var(zswap_dstmem);
 	src = kmap_atomic(page);
@@ -646,54 +460,39 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	}
 
 	/* store */
-	len = dlen + sizeof(struct zswap_header);
-	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
-		&handle);
+	ret = zbud_alloc(pool, dlen, __GFP_NORETRY | __GFP_NOWARN,
+		offset);
 	if (ret == -ENOSPC) {
 		zswap_reject_compress_poor++;
 		goto freepage;
 	}
+	if (ret == -EEXIST) {
+		zswap_duplicate_entry++;
+		goto freepage;
+	}
 	if (ret) {
 		zswap_reject_alloc_fail++;
 		goto freepage;
 	}
-	zhdr = zbud_map(tree->pool, handle);
-	zhdr->swpentry = swp_entry(type, offset);
-	buf = (u8 *)(zhdr + 1);
-	memcpy(buf, dst, dlen);
-	zbud_unmap(tree->pool, handle);
+	ret = zbud_map(pool, offset, &entry);
+	if (ret) {
+		zbud_free(pool, offset);
+		ret = -EINVAL;
+		goto freepage;
+	}
+	memcpy((u8 *)entry.addr, dst, dlen);
+	ret = zbud_unmap(pool, offset);
 	put_cpu_var(zswap_dstmem);
-
-	/* populate entry */
-	entry->offset = offset;
-	entry->handle = handle;
-	entry->length = dlen;
-
-	/* map */
-	spin_lock(&tree->lock);
-	do {
-		ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
-		if (ret == -EEXIST) {
-			zswap_duplicate_entry++;
-			/* remove from rbtree */
-			rb_erase(&dupentry->rbnode, &tree->rbroot);
-			if (!zswap_entry_put(dupentry)) {
-				/* free */
-				zswap_free_entry(tree, dupentry);
-			}
-		}
-	} while (ret == -EEXIST);
-	spin_unlock(&tree->lock);
+	BUG_ON(ret);
 
 	/* update stats */
 	atomic_inc(&zswap_stored_pages);
-	zswap_pool_pages = zbud_get_pool_size(tree->pool);
+	zswap_pool_pages = zbud_get_pool_size(pool);
 
 	return 0;
 
 freepage:
 	put_cpu_var(zswap_dstmem);
-	zswap_entry_cache_free(entry);
 reject:
 	return ret;
 }
@@ -705,50 +504,26 @@ reject:
 static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 				struct page *page)
 {
-	struct zswap_tree *tree = zswap_trees[type];
-	struct zswap_entry *entry;
-	u8 *src, *dst;
+	struct zbud_pool *pool = zbud_pools[type];
+	struct zbud_mapped_entry entry;
+	u8 *dst;
 	unsigned int dlen;
-	int refcount, ret;
-
-	/* find */
-	spin_lock(&tree->lock);
-	entry = zswap_rb_search(&tree->rbroot, offset);
-	if (!entry) {
-		/* entry was written back */
-		spin_unlock(&tree->lock);
-		return -1;
-	}
-	zswap_entry_get(entry);
-	spin_unlock(&tree->lock);
+	int ret, unmap_ret;
 
 	/* decompress */
 	dlen = PAGE_SIZE;
-	src = (u8 *)zbud_map(tree->pool, entry->handle) +
-			sizeof(struct zswap_header);
+	ret = zbud_map(pool, offset, &entry);
+	if (ret)
+		return ret;
+	VM_BUG_ON(!entry.addr);
 	dst = kmap_atomic(page);
-	ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
-		dst, &dlen);
+	ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, (u8 *)entry.addr,
+			entry.length, dst, &dlen);
 	kunmap_atomic(dst);
-	zbud_unmap(tree->pool, entry->handle);
+	unmap_ret = zbud_unmap(pool, offset);
 	BUG_ON(ret);
-
-	spin_lock(&tree->lock);
-	refcount = zswap_entry_put(entry);
-	if (likely(refcount)) {
-		spin_unlock(&tree->lock);
-		return 0;
-	}
-	spin_unlock(&tree->lock);
-
-	/*
-	 * We don't have to unlink from the rbtree because
-	 * zswap_writeback_entry() or zswap_frontswap_invalidate page()
-	 * has already done this for us if we are the last reference.
-	 */
-	/* free */
-
-	zswap_free_entry(tree, entry);
+	BUG_ON(dlen != PAGE_SIZE);
+	BUG_ON(unmap_ret);
 
 	return 0;
 }
@@ -756,54 +531,26 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 /* frees an entry in zswap */
 static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
 {
-	struct zswap_tree *tree = zswap_trees[type];
-	struct zswap_entry *entry;
-	int refcount;
-
-	/* find */
-	spin_lock(&tree->lock);
-	entry = zswap_rb_search(&tree->rbroot, offset);
-	if (!entry) {
-		/* entry was written back */
-		spin_unlock(&tree->lock);
-		return;
-	}
-
-	/* remove from rbtree */
-	rb_erase(&entry->rbnode, &tree->rbroot);
-
-	/* drop the initial reference from entry creation */
-	refcount = zswap_entry_put(entry);
+	struct zbud_pool *pool = zbud_pools[type];
 
-	spin_unlock(&tree->lock);
-
-	if (refcount) {
-		/* writeback in progress, writeback will free */
+	if (!pool)
 		return;
-	}
 
-	/* free */
-	zswap_free_entry(tree, entry);
+	zswap_free_entry(pool, offset);
 }
 
 /* frees all zswap entries for the given swap type */
 static void zswap_frontswap_invalidate_area(unsigned type)
 {
-	struct zswap_tree *tree = zswap_trees[type];
-	struct zswap_entry *entry, *n;
+	struct zbud_pool *pool = zbud_pools[type];
+	int freed;
 
-	if (!tree)
+	if (!pool)
 		return;
 
-	/* walk the tree and free everything */
-	spin_lock(&tree->lock);
-	rbtree_postorder_for_each_entry_safe(entry, n, &tree->rbroot, rbnode) {
-		zbud_free(tree->pool, entry->handle);
-		zswap_entry_cache_free(entry);
-		atomic_dec(&zswap_stored_pages);
-	}
-	tree->rbroot = RB_ROOT;
-	spin_unlock(&tree->lock);
+	freed = zbud_free_all(pool);
+	atomic_sub(freed, &zswap_stored_pages);
+	zswap_pool_pages = zbud_get_pool_size(pool);
 }
 
 static struct zbud_ops zswap_zbud_ops = {
@@ -812,23 +559,9 @@ static struct zbud_ops zswap_zbud_ops = {
 
 static void zswap_frontswap_init(unsigned type)
 {
-	struct zswap_tree *tree;
-
-	tree = kzalloc(sizeof(struct zswap_tree), GFP_KERNEL);
-	if (!tree)
-		goto err;
-	tree->pool = zbud_create_pool(GFP_KERNEL, &zswap_zbud_ops);
-	if (!tree->pool)
-		goto freetree;
-	tree->rbroot = RB_ROOT;
-	spin_lock_init(&tree->lock);
-	zswap_trees[type] = tree;
-	return;
-
-freetree:
-	kfree(tree);
-err:
-	pr_err("alloc failed, zswap disabled for swap type %d\n", type);
+	zbud_pools[type] = zbud_create_pool(GFP_KERNEL, &zswap_zbud_ops);
+	if (!zbud_pools[type])
+		pr_err("alloc failed, zswap disabled for swap type %d\n", type);
 }
 
 static struct frontswap_ops zswap_frontswap_ops = {
@@ -900,10 +633,6 @@ static int __init init_zswap(void)
 		return 0;
 
 	pr_info("loading zswap\n");
-	if (zswap_entry_cache_create()) {
-		pr_err("entry cache creation failed\n");
-		goto error;
-	}
 	if (zswap_comp_init()) {
 		pr_err("compressor initialization failed\n");
 		goto compfail;
@@ -919,8 +648,6 @@ static int __init init_zswap(void)
 pcpufail:
 	zswap_comp_exit();
 compfail:
-	zswap_entry_cache_destory();
-error:
 	return -ENOMEM;
 }
 /* must be late so crypto has time to come up */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
