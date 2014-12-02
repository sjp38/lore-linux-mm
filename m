Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id D7DE06B0073
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 21:50:16 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so12417204pab.34
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 18:50:16 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id f16si31434403pdl.240.2014.12.01.18.50.09
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 18:50:11 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 2/6] zsmalloc: add indrection layer to decouple handle from object
Date: Tue,  2 Dec 2014 11:49:43 +0900
Message-Id: <1417488587-28609-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1417488587-28609-1-git-send-email-minchan@kernel.org>
References: <1417488587-28609-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Minchan Kim <minchan@kernel.org>

Currently, zram's handle encodes object's location directly so
it makes hard to support migration/compaction.

This patch adds indirection layer for decoupling handle and
object location. With it, we could prepare to support migration/
compaction to prevent fragment problem of zsmalloc. As well,
it could make zram use movable pages in future.

First of all, we need indirection layer to assoicate handle
with object so that this patch introduces logics to support
the decoupling.

Old procedure of zsmalloc is as follows

* zs_malloc -> allocate object -> return object as handle
because object itself is handle.
* zs_map_object -> get object's position from handle -> map pages
* zs_unmap_object -> get object's position from handle -> unmap pages
* zs_free -> free object because handle itself encodes object's location.

New behavior is as follows

* zsmalloc -> allocate handle -> allocate object -> assoicate handle
with object -> return handle, not object.
* zs_map_object-> get object from handle via indiretion layer ->
get object's position from object -> map pages
* zs_unmap_object-> get object from handle via indirection layer ->
get object's position from object -> unmap pages
* zs_free -> get object from handle via indirection layer ->
free handle -> free object

As drawback, it would increase overhead of allocator.
Yet, it's not measured and might separate it with another config
if it's heavy.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 199 +++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 157 insertions(+), 42 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index a806d714924c..5f3f9119705e 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -219,6 +219,7 @@ struct link_free {
 
 struct zs_pool {
 	struct size_class **size_class;
+	struct size_class *handle_class;
 
 	gfp_t flags;	/* allocation flags used when growing pool */
 	atomic_long_t pages_allocated;
@@ -243,6 +244,11 @@ struct mapping_area {
 	enum zs_mapmode vm_mm; /* mapping mode */
 };
 
+static unsigned long __zs_malloc(struct zs_pool *pool,
+			struct size_class *class, gfp_t flags);
+static void __zs_free(struct zs_pool *pool, struct size_class *class,
+			unsigned long handle);
+
 /* zpool driver */
 
 #ifdef CONFIG_ZPOOL
@@ -458,11 +464,10 @@ static void remove_zspage(struct page *page, struct size_class *class,
  * page from the freelist of the old fullness group to that of the new
  * fullness group.
  */
-static enum fullness_group fix_fullness_group(struct zs_pool *pool,
-						struct page *page)
+static enum fullness_group fix_fullness_group(struct size_class *class,
+					struct page *page)
 {
 	int class_idx;
-	struct size_class *class;
 	enum fullness_group currfg, newfg;
 
 	BUG_ON(!is_first_page(page));
@@ -472,7 +477,6 @@ static enum fullness_group fix_fullness_group(struct zs_pool *pool,
 	if (newfg == currfg)
 		goto out;
 
-	class = pool->size_class[class_idx];
 	remove_zspage(page, class, currfg);
 	insert_zspage(page, class, newfg);
 	set_zspage_mapping(page, class_idx, newfg);
@@ -569,7 +573,7 @@ static void *obj_location_to_handle(struct page *page, unsigned long obj_idx)
  * decoded obj_idx back to its original value since it was adjusted in
  * obj_location_to_handle().
  */
-static void obj_handle_to_location(unsigned long handle, struct page **page,
+static void obj_to_location(unsigned long handle, struct page **page,
 				unsigned long *obj_idx)
 {
 	*page = pfn_to_page(handle >> OBJ_INDEX_BITS);
@@ -587,6 +591,41 @@ static unsigned long obj_idx_to_offset(struct page *page,
 	return off + obj_idx * class_size;
 }
 
+static void *handle_to_addr(struct zs_pool *pool, unsigned long handle)
+{
+	struct page *page;
+	unsigned long obj_idx, off;
+	struct size_class *class;
+
+	obj_to_location(handle, &page, &obj_idx);
+	class = pool->handle_class;
+	off = obj_idx_to_offset(page, obj_idx, class->size);
+
+	return lowmem_page_address(page) + off;
+}
+
+static unsigned long handle_to_obj(struct zs_pool *pool, unsigned long handle)
+{
+	unsigned long obj;
+	unsigned long *h_addr;
+
+	h_addr = handle_to_addr(pool, handle);
+	obj = *h_addr;
+
+	return obj;
+}
+
+static unsigned long alloc_handle(struct zs_pool *pool)
+{
+	return __zs_malloc(pool, pool->handle_class,
+			pool->flags & ~__GFP_HIGHMEM);
+}
+
+static void free_handle(struct zs_pool *pool, unsigned long handle)
+{
+	__zs_free(pool, pool->handle_class, handle);
+}
+
 static void reset_page(struct page *page)
 {
 	clear_bit(PG_private, &page->flags);
@@ -968,6 +1007,24 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
 	return true;
 }
 
+static int create_handle_class(struct zs_pool *pool, int handle_size)
+{
+	struct size_class *class;
+
+	class = kzalloc(sizeof(struct size_class), GFP_KERNEL);
+	if (!class)
+		return -ENOMEM;
+
+	class->index = 0;
+	class->size = handle_size;
+	class->pages_per_zspage = 1;
+	BUG_ON(class->pages_per_zspage != get_pages_per_zspage(handle_size));
+	spin_lock_init(&class->lock);
+	pool->handle_class = class;
+
+	return 0;
+}
+
 /**
  * zs_create_pool - Creates an allocation pool to work from.
  * @flags: allocation flags used to allocate pool metadata
@@ -989,12 +1046,13 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 	if (!pool)
 		return NULL;
 
+	if (create_handle_class(pool, ZS_HANDLE_SIZE))
+		goto err;
+
 	pool->size_class = kcalloc(zs_size_classes, sizeof(struct size_class *),
 			GFP_KERNEL);
-	if (!pool->size_class) {
-		kfree(pool);
-		return NULL;
-	}
+	if (!pool->size_class)
+		goto err;
 
 	/*
 	 * Iterate reversly, because, size of size_class that we want to use
@@ -1053,6 +1111,8 @@ void zs_destroy_pool(struct zs_pool *pool)
 {
 	int i;
 
+	kfree(pool->handle_class);
+
 	for (i = 0; i < zs_size_classes; i++) {
 		int fg;
 		struct size_class *class = pool->size_class[i];
@@ -1077,36 +1137,21 @@ void zs_destroy_pool(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_destroy_pool);
 
-/**
- * zs_malloc - Allocate block of given size from pool.
- * @pool: pool to allocate from
- * @size: size of block to allocate
- *
- * On success, handle to the allocated object is returned,
- * otherwise 0.
- * Allocation requests with size > ZS_MAX_ALLOC_SIZE will fail.
- */
-unsigned long zs_malloc(struct zs_pool *pool, size_t size)
+static unsigned long __zs_malloc(struct zs_pool *pool,
+			struct size_class *class, gfp_t flags)
 {
 	unsigned long obj;
 	struct link_free *link;
-	struct size_class *class;
-	void *vaddr;
-
 	struct page *first_page, *m_page;
 	unsigned long m_objidx, m_offset;
-
-	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
-		return 0;
-
-	class = pool->size_class[get_size_class_index(size)];
+	void *vaddr;
 
 	spin_lock(&class->lock);
 	first_page = find_get_zspage(class);
 
 	if (!first_page) {
 		spin_unlock(&class->lock);
-		first_page = alloc_zspage(class, pool->flags);
+		first_page = alloc_zspage(class, flags);
 		if (unlikely(!first_page))
 			return 0;
 
@@ -1117,7 +1162,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	}
 
 	obj = (unsigned long)first_page->freelist;
-	obj_handle_to_location(obj, &m_page, &m_objidx);
+	obj_to_location(obj, &m_page, &m_objidx);
 	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
 
 	vaddr = kmap_atomic(m_page);
@@ -1128,14 +1173,54 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 
 	first_page->inuse++;
 	/* Now move the zspage to another fullness group, if required */
-	fix_fullness_group(pool, first_page);
+	fix_fullness_group(class, first_page);
 	spin_unlock(&class->lock);
 
 	return obj;
 }
+
+/**
+ * zs_malloc - Allocate block of given size from pool.
+ * @pool: pool to allocate from
+ * @size: size of block to allocate
+ *
+ * On success, handle to the allocated object is returned,
+ * otherwise 0.
+ * Allocation requests with size > ZS_MAX_ALLOC_SIZE will fail.
+ */
+unsigned long zs_malloc(struct zs_pool *pool, size_t size)
+{
+	unsigned long obj, handle;
+	struct size_class *class;
+	unsigned long *h_addr;
+
+	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
+		return 0;
+
+	/* allocate handle */
+	handle = alloc_handle(pool);
+	if (!handle)
+		goto out;
+
+	/* allocate obj */
+	class = pool->size_class[get_size_class_index(size)];
+	obj = __zs_malloc(pool, class, pool->flags);
+	if (!obj) {
+		__zs_free(pool, pool->handle_class, handle);
+		handle = 0;
+		goto out;
+	}
+
+	/* associate handle with obj */
+	h_addr = handle_to_addr(pool, handle);
+	*h_addr = obj;
+out:
+	return handle;
+}
 EXPORT_SYMBOL_GPL(zs_malloc);
 
-void zs_free(struct zs_pool *pool, unsigned long obj)
+static void __zs_free(struct zs_pool *pool, struct size_class *class,
+			unsigned long handle)
 {
 	struct link_free *link;
 	struct page *first_page, *f_page;
@@ -1143,38 +1228,64 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
 	void *vaddr;
 
 	int class_idx;
-	struct size_class *class;
 	enum fullness_group fullness;
 
-	if (unlikely(!obj))
+	if (unlikely(!handle))
 		return;
 
-	obj_handle_to_location(obj, &f_page, &f_objidx);
+	obj_to_location(handle, &f_page, &f_objidx);
 	first_page = get_first_page(f_page);
 
 	get_zspage_mapping(first_page, &class_idx, &fullness);
-	class = pool->size_class[class_idx];
 	f_offset = obj_idx_to_offset(f_page, f_objidx, class->size);
 
-	spin_lock(&class->lock);
+	vaddr = kmap_atomic(f_page);
 
+	spin_lock(&class->lock);
 	/* Insert this object in containing zspage's freelist */
-	vaddr = kmap_atomic(f_page);
 	link = (struct link_free *)(vaddr + f_offset);
 	link->next = first_page->freelist;
-	kunmap_atomic(vaddr);
-	first_page->freelist = (void *)obj;
+	first_page->freelist = (void *)handle;
 
 	first_page->inuse--;
-	fullness = fix_fullness_group(pool, first_page);
+	fullness = fix_fullness_group(class, first_page);
 	spin_unlock(&class->lock);
 
+	kunmap_atomic(vaddr);
+
 	if (fullness == ZS_EMPTY) {
 		atomic_long_sub(class->pages_per_zspage,
 				&pool->pages_allocated);
 		free_zspage(first_page);
 	}
 }
+
+void zs_free(struct zs_pool *pool, unsigned long handle)
+{
+	unsigned long obj;
+	struct page *first_page, *f_page;
+	unsigned long f_objidx;
+
+	int class_idx;
+	struct size_class *class;
+	enum fullness_group fullness;
+
+	if (unlikely(!handle))
+		return;
+
+	obj = handle_to_obj(pool, handle);
+	/* free handle */
+	free_handle(pool, handle);
+
+	/* free obj */
+	obj_to_location(obj, &f_page, &f_objidx);
+	first_page = get_first_page(f_page);
+
+	get_zspage_mapping(first_page, &class_idx, &fullness);
+	class = pool->size_class[class_idx];
+
+	__zs_free(pool, class, obj);
+}
 EXPORT_SYMBOL_GPL(zs_free);
 
 /**
@@ -1195,6 +1306,7 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 			enum zs_mapmode mm)
 {
 	struct page *page;
+	unsigned long obj;
 	unsigned long obj_idx, off;
 
 	unsigned int class_idx;
@@ -1212,7 +1324,8 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	 */
 	BUG_ON(in_interrupt());
 
-	obj_handle_to_location(handle, &page, &obj_idx);
+	obj = handle_to_obj(pool, handle);
+	obj_to_location(obj, &page, &obj_idx);
 	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
 	class = pool->size_class[class_idx];
 	off = obj_idx_to_offset(page, obj_idx, class->size);
@@ -1237,6 +1350,7 @@ EXPORT_SYMBOL_GPL(zs_map_object);
 void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 {
 	struct page *page;
+	unsigned long obj;
 	unsigned long obj_idx, off;
 
 	unsigned int class_idx;
@@ -1246,7 +1360,8 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 
 	BUG_ON(!handle);
 
-	obj_handle_to_location(handle, &page, &obj_idx);
+	obj = handle_to_obj(pool, handle);
+	obj_to_location(obj, &page, &obj_idx);
 	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
 	class = pool->size_class[class_idx];
 	off = obj_idx_to_offset(page, obj_idx, class->size);
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
