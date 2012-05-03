Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id E06396B0083
	for <linux-mm@kvack.org>; Thu,  3 May 2012 02:41:13 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 3/4] zsmalloc use zs_handle instead of void *
Date: Thu,  3 May 2012 15:40:41 +0900
Message-Id: <1336027242-372-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1336027242-372-1-git-send-email-minchan@kernel.org>
References: <1336027242-372-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

We should use zs_handle instead of void * to avoid any
confusion. Without this, users may just treat zs_malloc return value as
a pointer and try to deference it.

Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zcache/zcache-main.c     |    8 ++++----
 drivers/staging/zram/zram_drv.c          |    8 ++++----
 drivers/staging/zram/zram_drv.h          |    2 +-
 drivers/staging/zsmalloc/zsmalloc-main.c |   28 ++++++++++++++--------------
 drivers/staging/zsmalloc/zsmalloc.h      |   15 +++++++++++----
 5 files changed, 34 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 2734dac..9b06948 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -700,12 +700,12 @@ static struct zv_hdr *zv_create(struct zs_pool *pool, uint32_t pool_id,
 	struct zv_hdr *zv;
 	u32 size = clen + sizeof(struct zv_hdr);
 	int chunks = (size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
-	void *handle = NULL;
+	zs_handle handle;
 
 	BUG_ON(!irqs_disabled());
 	BUG_ON(chunks >= NCHUNKS);
 	handle = zs_malloc(pool, size);
-	if (!handle)
+	if (zs_handle_invalid(handle))
 		goto out;
 	atomic_inc(&zv_curr_dist_counts[chunks]);
 	atomic_inc(&zv_cumul_dist_counts[chunks]);
@@ -721,7 +721,7 @@ out:
 	return handle;
 }
 
-static void zv_free(struct zs_pool *pool, void *handle)
+static void zv_free(struct zs_pool *pool, zs_handle handle)
 {
 	unsigned long flags;
 	struct zv_hdr *zv;
@@ -743,7 +743,7 @@ static void zv_free(struct zs_pool *pool, void *handle)
 	local_irq_restore(flags);
 }
 
-static void zv_decompress(struct page *page, void *handle)
+static void zv_decompress(struct page *page, zs_handle handle)
 {
 	unsigned int clen = PAGE_SIZE;
 	char *to_va;
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 685d612..7e42aa2 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -135,7 +135,7 @@ static void zram_set_disksize(struct zram *zram, size_t totalram_bytes)
 
 static void zram_free_page(struct zram *zram, size_t index)
 {
-	void *handle = zram->table[index].handle;
+	zs_handle handle = zram->table[index].handle;
 
 	if (unlikely(!handle)) {
 		/*
@@ -317,7 +317,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	int ret;
 	u32 store_offset;
 	size_t clen;
-	void *handle;
+	zs_handle handle;
 	struct zobj_header *zheader;
 	struct page *page, *page_store;
 	unsigned char *user_mem, *cmem, *src, *uncmem = NULL;
@@ -406,7 +406,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	}
 
 	handle = zs_malloc(zram->mem_pool, clen + sizeof(*zheader));
-	if (!handle) {
+	if (zs_handle_invalid(handle)) {
 		pr_info("Error allocating memory for compressed "
 			"page: %u, size=%zu\n", index, clen);
 		ret = -ENOMEM;
@@ -592,7 +592,7 @@ void __zram_reset_device(struct zram *zram)
 
 	/* Free all pages that are still in this zram device */
 	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
-		void *handle = zram->table[index].handle;
+		zs_handle handle = zram->table[index].handle;
 		if (!handle)
 			continue;
 
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
index fbe8ac9..07d3192 100644
--- a/drivers/staging/zram/zram_drv.h
+++ b/drivers/staging/zram/zram_drv.h
@@ -81,7 +81,7 @@ enum zram_pageflags {
 
 /* Allocated for each disk page */
 struct table {
-	void *handle;
+	zs_handle handle;
 	u16 size;	/* object size (excluding header) */
 	u8 count;	/* object ref count (not yet used) */
 	u8 flags;
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 4496737..51074fa 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -247,7 +247,7 @@ static void *obj_location_to_handle(struct page *page, unsigned long obj_idx)
 }
 
 /* Decode <page, obj_idx> pair from the given object handle */
-static void obj_handle_to_location(void *handle, struct page **page,
+static void obj_handle_to_location(zs_handle handle, struct page **page,
 				unsigned long *obj_idx)
 {
 	unsigned long hval = (unsigned long)handle;
@@ -571,9 +571,9 @@ EXPORT_SYMBOL_GPL(zs_destroy_pool);
  * otherwise NULL.
  * Allocation requests with size > ZS_MAX_ALLOC_SIZE will fail.
  */
-void *zs_malloc(struct zs_pool *pool, size_t size)
+zs_handle zs_malloc(struct zs_pool *pool, size_t size)
 {
-	void *obj;
+	zs_handle handle;
 	struct link_free *link;
 	int class_idx;
 	struct size_class *class;
@@ -602,8 +602,8 @@ void *zs_malloc(struct zs_pool *pool, size_t size)
 		class->pages_allocated += class->pages_per_zspage;
 	}
 
-	obj = first_page->freelist;
-	obj_handle_to_location(obj, &m_page, &m_objidx);
+	handle = first_page->freelist;
+	obj_handle_to_location(handle, &m_page, &m_objidx);
 	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
 
 	link = (struct link_free *)kmap_atomic(m_page) +
@@ -617,11 +617,11 @@ void *zs_malloc(struct zs_pool *pool, size_t size)
 	fix_fullness_group(pool, first_page);
 	spin_unlock(&class->lock);
 
-	return obj;
+	return handle;
 }
 EXPORT_SYMBOL_GPL(zs_malloc);
 
-void zs_free(struct zs_pool *pool, void *obj)
+void zs_free(struct zs_pool *pool, zs_handle handle)
 {
 	struct link_free *link;
 	struct page *first_page, *f_page;
@@ -631,10 +631,10 @@ void zs_free(struct zs_pool *pool, void *obj)
 	struct size_class *class;
 	enum fullness_group fullness;
 
-	if (unlikely(!obj))
+	if (unlikely(zs_handle_invalid(handle)))
 		return;
 
-	obj_handle_to_location(obj, &f_page, &f_objidx);
+	obj_handle_to_location(handle, &f_page, &f_objidx);
 	first_page = get_first_page(f_page);
 
 	get_zspage_mapping(first_page, &class_idx, &fullness);
@@ -648,7 +648,7 @@ void zs_free(struct zs_pool *pool, void *obj)
 							+ f_offset);
 	link->next = first_page->freelist;
 	kunmap_atomic(link);
-	first_page->freelist = obj;
+	first_page->freelist = handle;
 
 	first_page->inuse--;
 	fullness = fix_fullness_group(pool, first_page);
@@ -672,7 +672,7 @@ EXPORT_SYMBOL_GPL(zs_free);
  * this function. When done with the object, it must be unmapped using
  * zs_unmap_object
 */
-void *zs_map_object(struct zs_pool *pool, void *handle)
+void *zs_map_object(struct zs_pool *pool, zs_handle handle)
 {
 	struct page *page;
 	unsigned long obj_idx, off;
@@ -682,7 +682,7 @@ void *zs_map_object(struct zs_pool *pool, void *handle)
 	struct size_class *class;
 	struct mapping_area *area;
 
-	BUG_ON(!handle);
+	BUG_ON(zs_handle_invalid(handle));
 
 	obj_handle_to_location(handle, &page, &obj_idx);
 	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
@@ -712,7 +712,7 @@ void *zs_map_object(struct zs_pool *pool, void *handle)
 }
 EXPORT_SYMBOL_GPL(zs_map_object);
 
-void zs_unmap_object(struct zs_pool *pool, void *handle)
+void zs_unmap_object(struct zs_pool *pool, zs_handle handle)
 {
 	struct page *page;
 	unsigned long obj_idx, off;
@@ -722,7 +722,7 @@ void zs_unmap_object(struct zs_pool *pool, void *handle)
 	struct size_class *class;
 	struct mapping_area *area;
 
-	BUG_ON(!handle);
+	BUG_ON(zs_handle_invalid(handle));
 
 	obj_handle_to_location(handle, &page, &obj_idx);
 	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
diff --git a/drivers/staging/zsmalloc/zsmalloc.h b/drivers/staging/zsmalloc/zsmalloc.h
index 949384e..1ba6d0c 100644
--- a/drivers/staging/zsmalloc/zsmalloc.h
+++ b/drivers/staging/zsmalloc/zsmalloc.h
@@ -16,15 +16,22 @@
 #include <linux/types.h>
 
 struct zs_pool;
+typedef void * zs_handle;
+
+/*
+ * zs_malloc's caller should use zs_handle_invalid instead of if (!handle)
+ * to test successful allocation.
+ */
+#define zs_handle_invalid(zs_handle) !zs_handle
 
 struct zs_pool *zs_create_pool(const char *name, gfp_t flags);
 void zs_destroy_pool(struct zs_pool *pool);
 
-void *zs_malloc(struct zs_pool *pool, size_t size);
-void zs_free(struct zs_pool *pool, void *obj);
+zs_handle zs_malloc(struct zs_pool *pool, size_t size);
+void zs_free(struct zs_pool *pool, zs_handle handle);
 
-void *zs_map_object(struct zs_pool *pool, void *handle);
-void zs_unmap_object(struct zs_pool *pool, void *handle);
+void *zs_map_object(struct zs_pool *pool, zs_handle handle);
+void zs_unmap_object(struct zs_pool *pool, zs_handle handle);
 
 u64 zs_get_total_size_bytes(struct zs_pool *pool);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
