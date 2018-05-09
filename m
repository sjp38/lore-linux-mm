Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id F14956B030C
	for <linux-mm@kvack.org>; Tue,  8 May 2018 21:34:16 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l65so5527327qke.21
        for <linux-mm@kvack.org>; Tue, 08 May 2018 18:34:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f31-v6sor16506518qta.8.2018.05.08.18.34.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 18:34:15 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 01/10] mempool: Add mempool_init()/mempool_exit()
Date: Tue,  8 May 2018 21:33:49 -0400
Message-Id: <20180509013358.16399-2-kent.overstreet@gmail.com>
In-Reply-To: <20180509013358.16399-1-kent.overstreet@gmail.com>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>

Allows mempools to be embedded in other structs, getting rid of a
pointer indirection from allocation fastpaths.

mempool_exit() is safe to call on an uninitialized but zeroed mempool.

Signed-off-by: Kent Overstreet <kent.overstreet@gmail.com>
---
 include/linux/mempool.h |  34 +++++++++++++
 mm/mempool.c            | 108 ++++++++++++++++++++++++++++++----------
 2 files changed, 115 insertions(+), 27 deletions(-)

diff --git a/include/linux/mempool.h b/include/linux/mempool.h
index b51f5c430c..0c964ac107 100644
--- a/include/linux/mempool.h
+++ b/include/linux/mempool.h
@@ -25,6 +25,18 @@ typedef struct mempool_s {
 	wait_queue_head_t wait;
 } mempool_t;
 
+static inline bool mempool_initialized(mempool_t *pool)
+{
+	return pool->elements != NULL;
+}
+
+void mempool_exit(mempool_t *pool);
+int mempool_init_node(mempool_t *pool, int min_nr, mempool_alloc_t *alloc_fn,
+		      mempool_free_t *free_fn, void *pool_data,
+		      gfp_t gfp_mask, int node_id);
+int mempool_init(mempool_t *pool, int min_nr, mempool_alloc_t *alloc_fn,
+		 mempool_free_t *free_fn, void *pool_data);
+
 extern mempool_t *mempool_create(int min_nr, mempool_alloc_t *alloc_fn,
 			mempool_free_t *free_fn, void *pool_data);
 extern mempool_t *mempool_create_node(int min_nr, mempool_alloc_t *alloc_fn,
@@ -43,6 +55,14 @@ extern void mempool_free(void *element, mempool_t *pool);
  */
 void *mempool_alloc_slab(gfp_t gfp_mask, void *pool_data);
 void mempool_free_slab(void *element, void *pool_data);
+
+static inline int
+mempool_init_slab_pool(mempool_t *pool, int min_nr, struct kmem_cache *kc)
+{
+	return mempool_init(pool, min_nr, mempool_alloc_slab,
+			    mempool_free_slab, (void *) kc);
+}
+
 static inline mempool_t *
 mempool_create_slab_pool(int min_nr, struct kmem_cache *kc)
 {
@@ -56,6 +76,13 @@ mempool_create_slab_pool(int min_nr, struct kmem_cache *kc)
  */
 void *mempool_kmalloc(gfp_t gfp_mask, void *pool_data);
 void mempool_kfree(void *element, void *pool_data);
+
+static inline int mempool_init_kmalloc_pool(mempool_t *pool, int min_nr, size_t size)
+{
+	return mempool_init(pool, min_nr, mempool_kmalloc,
+			    mempool_kfree, (void *) size);
+}
+
 static inline mempool_t *mempool_create_kmalloc_pool(int min_nr, size_t size)
 {
 	return mempool_create(min_nr, mempool_kmalloc, mempool_kfree,
@@ -68,6 +95,13 @@ static inline mempool_t *mempool_create_kmalloc_pool(int min_nr, size_t size)
  */
 void *mempool_alloc_pages(gfp_t gfp_mask, void *pool_data);
 void mempool_free_pages(void *element, void *pool_data);
+
+static inline int mempool_init_page_pool(mempool_t *pool, int min_nr, int order)
+{
+	return mempool_init(pool, min_nr, mempool_alloc_pages,
+			    mempool_free_pages, (void *)(long)order);
+}
+
 static inline mempool_t *mempool_create_page_pool(int min_nr, int order)
 {
 	return mempool_create(min_nr, mempool_alloc_pages, mempool_free_pages,
diff --git a/mm/mempool.c b/mm/mempool.c
index 5c9dce3471..df90ace400 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -137,6 +137,28 @@ static void *remove_element(mempool_t *pool, gfp_t flags)
 	return element;
 }
 
+/**
+ * mempool_destroy - exit a mempool initialized with mempool_init()
+ * @pool:      pointer to the memory pool which was initialized with
+ *             mempool_init().
+ *
+ * Free all reserved elements in @pool and @pool itself.  This function
+ * only sleeps if the free_fn() function sleeps.
+ *
+ * May be called on a zeroed but uninitialized mempool (i.e. allocated with
+ * kzalloc()).
+ */
+void mempool_exit(mempool_t *pool)
+{
+	while (pool->curr_nr) {
+		void *element = remove_element(pool, GFP_KERNEL);
+		pool->free(element, pool->pool_data);
+	}
+	kfree(pool->elements);
+	pool->elements = NULL;
+}
+EXPORT_SYMBOL(mempool_exit);
+
 /**
  * mempool_destroy - deallocate a memory pool
  * @pool:      pointer to the memory pool which was allocated via
@@ -150,15 +172,65 @@ void mempool_destroy(mempool_t *pool)
 	if (unlikely(!pool))
 		return;
 
-	while (pool->curr_nr) {
-		void *element = remove_element(pool, GFP_KERNEL);
-		pool->free(element, pool->pool_data);
-	}
-	kfree(pool->elements);
+	mempool_exit(pool);
 	kfree(pool);
 }
 EXPORT_SYMBOL(mempool_destroy);
 
+int mempool_init_node(mempool_t *pool, int min_nr, mempool_alloc_t *alloc_fn,
+		      mempool_free_t *free_fn, void *pool_data,
+		      gfp_t gfp_mask, int node_id)
+{
+	spin_lock_init(&pool->lock);
+	pool->min_nr	= min_nr;
+	pool->pool_data = pool_data;
+	pool->alloc	= alloc_fn;
+	pool->free	= free_fn;
+	init_waitqueue_head(&pool->wait);
+
+	pool->elements = kmalloc_array_node(min_nr, sizeof(void *),
+					    gfp_mask, node_id);
+	if (!pool->elements)
+		return -ENOMEM;
+
+	/*
+	 * First pre-allocate the guaranteed number of buffers.
+	 */
+	while (pool->curr_nr < pool->min_nr) {
+		void *element;
+
+		element = pool->alloc(gfp_mask, pool->pool_data);
+		if (unlikely(!element)) {
+			mempool_exit(pool);
+			return -ENOMEM;
+		}
+		add_element(pool, element);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(mempool_init_node);
+
+/**
+ * mempool_init - initialize a memory pool
+ * @min_nr:    the minimum number of elements guaranteed to be
+ *             allocated for this pool.
+ * @alloc_fn:  user-defined element-allocation function.
+ * @free_fn:   user-defined element-freeing function.
+ * @pool_data: optional private data available to the user-defined functions.
+ *
+ * Like mempool_create(), but initializes the pool in (i.e. embedded in another
+ * structure).
+ */
+int mempool_init(mempool_t *pool, int min_nr, mempool_alloc_t *alloc_fn,
+		 mempool_free_t *free_fn, void *pool_data)
+{
+	return mempool_init_node(pool, min_nr, alloc_fn, free_fn,
+				 pool_data, GFP_KERNEL, NUMA_NO_NODE);
+
+}
+EXPORT_SYMBOL(mempool_init);
+
 /**
  * mempool_create - create a memory pool
  * @min_nr:    the minimum number of elements guaranteed to be
@@ -186,35 +258,17 @@ mempool_t *mempool_create_node(int min_nr, mempool_alloc_t *alloc_fn,
 			       gfp_t gfp_mask, int node_id)
 {
 	mempool_t *pool;
+
 	pool = kzalloc_node(sizeof(*pool), gfp_mask, node_id);
 	if (!pool)
 		return NULL;
-	pool->elements = kmalloc_array_node(min_nr, sizeof(void *),
-				      gfp_mask, node_id);
-	if (!pool->elements) {
+
+	if (mempool_init_node(pool, min_nr, alloc_fn, free_fn, pool_data,
+			      gfp_mask, node_id)) {
 		kfree(pool);
 		return NULL;
 	}
-	spin_lock_init(&pool->lock);
-	pool->min_nr = min_nr;
-	pool->pool_data = pool_data;
-	init_waitqueue_head(&pool->wait);
-	pool->alloc = alloc_fn;
-	pool->free = free_fn;
 
-	/*
-	 * First pre-allocate the guaranteed number of buffers.
-	 */
-	while (pool->curr_nr < pool->min_nr) {
-		void *element;
-
-		element = pool->alloc(gfp_mask, pool->pool_data);
-		if (unlikely(!element)) {
-			mempool_destroy(pool);
-			return NULL;
-		}
-		add_element(pool, element);
-	}
 	return pool;
 }
 EXPORT_SYMBOL(mempool_create_node);
-- 
2.17.0
