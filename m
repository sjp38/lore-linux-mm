Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 0D2046B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 02:39:34 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3] zsmalloc: zsmalloc: use unsigned long instead of void *
Date: Fri,  8 Jun 2012 15:39:25 +0900
Message-Id: <1339137567-29656-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>

We should use unsigned long as handle instead of void * to avoid any
confusion. Without this, users may just treat zs_malloc return value as
a pointer and try to deference it.

This patch passed compile test(zram, zcache and ramster) and zram is
tested on qemu.

changelog
  * from v2
	- remove hval pointed out by Nitin
	- based on next-20120607
  * from v1
	- change zcache's zv_create return value
	- baesd on next-20120604

Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zcache/zcache-main.c     |   12 ++++++------
 drivers/staging/zram/zram_drv.c          |   16 ++++++++--------
 drivers/staging/zram/zram_drv.h          |    2 +-
 drivers/staging/zsmalloc/zsmalloc-main.c |   28 +++++++++++++---------------
 drivers/staging/zsmalloc/zsmalloc.h      |    8 ++++----
 5 files changed, 32 insertions(+), 34 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 784c796..03f690b 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -693,14 +693,14 @@ static unsigned int zv_max_mean_zsize = (PAGE_SIZE / 8) * 5;
 static atomic_t zv_curr_dist_counts[NCHUNKS];
 static atomic_t zv_cumul_dist_counts[NCHUNKS];
 
-static struct zv_hdr *zv_create(struct zs_pool *pool, uint32_t pool_id,
+static unsigned long zv_create(struct zs_pool *pool, uint32_t pool_id,
 				struct tmem_oid *oid, uint32_t index,
 				void *cdata, unsigned clen)
 {
 	struct zv_hdr *zv;
 	u32 size = clen + sizeof(struct zv_hdr);
 	int chunks = (size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
-	void *handle = NULL;
+	unsigned long handle = 0;
 
 	BUG_ON(!irqs_disabled());
 	BUG_ON(chunks >= NCHUNKS);
@@ -721,7 +721,7 @@ out:
 	return handle;
 }
 
-static void zv_free(struct zs_pool *pool, void *handle)
+static void zv_free(struct zs_pool *pool, unsigned long handle)
 {
 	unsigned long flags;
 	struct zv_hdr *zv;
@@ -743,7 +743,7 @@ static void zv_free(struct zs_pool *pool, void *handle)
 	local_irq_restore(flags);
 }
 
-static void zv_decompress(struct page *page, void *handle)
+static void zv_decompress(struct page *page, unsigned long handle)
 {
 	unsigned int clen = PAGE_SIZE;
 	char *to_va;
@@ -1247,7 +1247,7 @@ static int zcache_pampd_get_data(char *data, size_t *bufsize, bool raw,
 	int ret = 0;
 
 	BUG_ON(is_ephemeral(pool));
-	zv_decompress((struct page *)(data), pampd);
+	zv_decompress((struct page *)(data), (unsigned long)pampd);
 	return ret;
 }
 
@@ -1282,7 +1282,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 		atomic_dec(&zcache_curr_eph_pampd_count);
 		BUG_ON(atomic_read(&zcache_curr_eph_pampd_count) < 0);
 	} else {
-		zv_free(cli->zspool, pampd);
+		zv_free(cli->zspool, (unsigned long)pampd);
 		atomic_dec(&zcache_curr_pers_pampd_count);
 		BUG_ON(atomic_read(&zcache_curr_pers_pampd_count) < 0);
 	}
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 685d612..abd69d1 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -135,7 +135,7 @@ static void zram_set_disksize(struct zram *zram, size_t totalram_bytes)
 
 static void zram_free_page(struct zram *zram, size_t index)
 {
-	void *handle = zram->table[index].handle;
+	unsigned long handle = zram->table[index].handle;
 
 	if (unlikely(!handle)) {
 		/*
@@ -150,7 +150,7 @@ static void zram_free_page(struct zram *zram, size_t index)
 	}
 
 	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
-		__free_page(handle);
+		__free_page((struct page *)handle);
 		zram_clear_flag(zram, index, ZRAM_UNCOMPRESSED);
 		zram_stat_dec(&zram->stats.pages_expand);
 		goto out;
@@ -166,7 +166,7 @@ out:
 			zram->table[index].size);
 	zram_stat_dec(&zram->stats.pages_stored);
 
-	zram->table[index].handle = NULL;
+	zram->table[index].handle = 0;
 	zram->table[index].size = 0;
 }
 
@@ -189,7 +189,7 @@ static void handle_uncompressed_page(struct zram *zram, struct bio_vec *bvec,
 	unsigned char *user_mem, *cmem;
 
 	user_mem = kmap_atomic(page);
-	cmem = kmap_atomic(zram->table[index].handle);
+	cmem = kmap_atomic((struct page *)zram->table[index].handle);
 
 	memcpy(user_mem + bvec->bv_offset, cmem + offset, bvec->bv_len);
 	kunmap_atomic(cmem);
@@ -317,7 +317,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	int ret;
 	u32 store_offset;
 	size_t clen;
-	void *handle;
+	unsigned long handle;
 	struct zobj_header *zheader;
 	struct page *page, *page_store;
 	unsigned char *user_mem, *cmem, *src, *uncmem = NULL;
@@ -399,7 +399,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		store_offset = 0;
 		zram_set_flag(zram, index, ZRAM_UNCOMPRESSED);
 		zram_stat_inc(&zram->stats.pages_expand);
-		handle = page_store;
+		handle = (unsigned long)page_store;
 		src = kmap_atomic(page);
 		cmem = kmap_atomic(page_store);
 		goto memstore;
@@ -592,12 +592,12 @@ void __zram_reset_device(struct zram *zram)
 
 	/* Free all pages that are still in this zram device */
 	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
-		void *handle = zram->table[index].handle;
+		unsigned long handle = zram->table[index].handle;
 		if (!handle)
 			continue;
 
 		if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED)))
-			__free_page(handle);
+			__free_page((struct page *)handle);
 		else
 			zs_free(zram->mem_pool, handle);
 	}
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
index fbe8ac9..7a7e256 100644
--- a/drivers/staging/zram/zram_drv.h
+++ b/drivers/staging/zram/zram_drv.h
@@ -81,7 +81,7 @@ enum zram_pageflags {
 
 /* Allocated for each disk page */
 struct table {
-	void *handle;
+	unsigned long handle;
 	u16 size;	/* object size (excluding header) */
 	u8 count;	/* object ref count (not yet used) */
 	u8 flags;
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 4496737..8e830ee 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -247,13 +247,11 @@ static void *obj_location_to_handle(struct page *page, unsigned long obj_idx)
 }
 
 /* Decode <page, obj_idx> pair from the given object handle */
-static void obj_handle_to_location(void *handle, struct page **page,
+static void obj_handle_to_location(unsigned long handle, struct page **page,
 				unsigned long *obj_idx)
 {
-	unsigned long hval = (unsigned long)handle;
-
-	*page = pfn_to_page(hval >> OBJ_INDEX_BITS);
-	*obj_idx = hval & OBJ_INDEX_MASK;
+	*page = pfn_to_page(handle >> OBJ_INDEX_BITS);
+	*obj_idx = handle & OBJ_INDEX_MASK;
 }
 
 static unsigned long obj_idx_to_offset(struct page *page,
@@ -568,12 +566,12 @@ EXPORT_SYMBOL_GPL(zs_destroy_pool);
  * @size: size of block to allocate
  *
  * On success, handle to the allocated object is returned,
- * otherwise NULL.
+ * otherwise 0.
  * Allocation requests with size > ZS_MAX_ALLOC_SIZE will fail.
  */
-void *zs_malloc(struct zs_pool *pool, size_t size)
+unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 {
-	void *obj;
+	unsigned long obj;
 	struct link_free *link;
 	int class_idx;
 	struct size_class *class;
@@ -582,7 +580,7 @@ void *zs_malloc(struct zs_pool *pool, size_t size)
 	unsigned long m_objidx, m_offset;
 
 	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
-		return NULL;
+		return 0;
 
 	class_idx = get_size_class_index(size);
 	class = &pool->size_class[class_idx];
@@ -595,14 +593,14 @@ void *zs_malloc(struct zs_pool *pool, size_t size)
 		spin_unlock(&class->lock);
 		first_page = alloc_zspage(class, pool->flags);
 		if (unlikely(!first_page))
-			return NULL;
+			return 0;
 
 		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
 		spin_lock(&class->lock);
 		class->pages_allocated += class->pages_per_zspage;
 	}
 
-	obj = first_page->freelist;
+	obj = (unsigned long)first_page->freelist;
 	obj_handle_to_location(obj, &m_page, &m_objidx);
 	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
 
@@ -621,7 +619,7 @@ void *zs_malloc(struct zs_pool *pool, size_t size)
 }
 EXPORT_SYMBOL_GPL(zs_malloc);
 
-void zs_free(struct zs_pool *pool, void *obj)
+void zs_free(struct zs_pool *pool, unsigned long obj)
 {
 	struct link_free *link;
 	struct page *first_page, *f_page;
@@ -648,7 +646,7 @@ void zs_free(struct zs_pool *pool, void *obj)
 							+ f_offset);
 	link->next = first_page->freelist;
 	kunmap_atomic(link);
-	first_page->freelist = obj;
+	first_page->freelist = (void *)obj;
 
 	first_page->inuse--;
 	fullness = fix_fullness_group(pool, first_page);
@@ -672,7 +670,7 @@ EXPORT_SYMBOL_GPL(zs_free);
  * this function. When done with the object, it must be unmapped using
  * zs_unmap_object
 */
-void *zs_map_object(struct zs_pool *pool, void *handle)
+void *zs_map_object(struct zs_pool *pool, unsigned long handle)
 {
 	struct page *page;
 	unsigned long obj_idx, off;
@@ -712,7 +710,7 @@ void *zs_map_object(struct zs_pool *pool, void *handle)
 }
 EXPORT_SYMBOL_GPL(zs_map_object);
 
-void zs_unmap_object(struct zs_pool *pool, void *handle)
+void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 {
 	struct page *page;
 	unsigned long obj_idx, off;
diff --git a/drivers/staging/zsmalloc/zsmalloc.h b/drivers/staging/zsmalloc/zsmalloc.h
index 949384e..485cbb1 100644
--- a/drivers/staging/zsmalloc/zsmalloc.h
+++ b/drivers/staging/zsmalloc/zsmalloc.h
@@ -20,11 +20,11 @@ struct zs_pool;
 struct zs_pool *zs_create_pool(const char *name, gfp_t flags);
 void zs_destroy_pool(struct zs_pool *pool);
 
-void *zs_malloc(struct zs_pool *pool, size_t size);
-void zs_free(struct zs_pool *pool, void *obj);
+unsigned long zs_malloc(struct zs_pool *pool, size_t size);
+void zs_free(struct zs_pool *pool, unsigned long obj);
 
-void *zs_map_object(struct zs_pool *pool, void *handle);
-void zs_unmap_object(struct zs_pool *pool, void *handle);
+void *zs_map_object(struct zs_pool *pool, unsigned long handle);
+void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
 
 u64 zs_get_total_size_bytes(struct zs_pool *pool);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
