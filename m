Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0306B0088
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:06:34 -0400 (EDT)
Received: by pabru16 with SMTP id ru16so62706630pab.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:34 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id fj8si8819616pdb.93.2015.05.29.08.06.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:06:33 -0700 (PDT)
Received: by pdfh10 with SMTP id h10so55532648pdf.3
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:33 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 06/10] zsmalloc: move compaction functions
Date: Sat, 30 May 2015 00:05:24 +0900
Message-Id: <1432911928-14654-7-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

this patch simply moves compaction functions, so we can call
`static __zs_compaction()' (and friends) from zs_free().

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 426 +++++++++++++++++++++++++++++-----------------------------
 1 file changed, 215 insertions(+), 211 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 54eefc3..c2a640a 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -321,6 +321,7 @@ static int zs_zpool_malloc(void *pool, size_t size, gfp_t gfp,
 	*handle = zs_malloc(pool, size);
 	return *handle ? 0 : -1;
 }
+
 static void zs_zpool_free(void *pool, unsigned long handle)
 {
 	zs_free(pool, handle);
@@ -352,6 +353,7 @@ static void *zs_zpool_map(void *pool, unsigned long handle,
 
 	return zs_map_object(pool, handle, zs_mm);
 }
+
 static void zs_zpool_unmap(void *pool, unsigned long handle)
 {
 	zs_unmap_object(pool, handle);
@@ -590,7 +592,6 @@ static inline void zs_pool_stat_destroy(struct zs_pool *pool)
 }
 #endif
 
-
 /*
  * For each size class, zspages are divided into different groups
  * depending on how "full" they are. This was done so that we could
@@ -1117,7 +1118,6 @@ out:
 	/* enable page faults to match kunmap_atomic() return conditions */
 	pagefault_enable();
 }
-
 #endif /* CONFIG_PGTABLE_MAPPING */
 
 static int zs_cpu_notifier(struct notifier_block *nb, unsigned long action,
@@ -1207,115 +1207,6 @@ static bool zspage_full(struct page *page)
 	return page->inuse == page->objects;
 }
 
-unsigned long zs_get_total_pages(struct zs_pool *pool)
-{
-	return atomic_long_read(&pool->pages_allocated);
-}
-EXPORT_SYMBOL_GPL(zs_get_total_pages);
-
-/**
- * zs_map_object - get address of allocated object from handle.
- * @pool: pool from which the object was allocated
- * @handle: handle returned from zs_malloc
- *
- * Before using an object allocated from zs_malloc, it must be mapped using
- * this function. When done with the object, it must be unmapped using
- * zs_unmap_object.
- *
- * Only one object can be mapped per cpu at a time. There is no protection
- * against nested mappings.
- *
- * This function returns with preemption and page faults disabled.
- */
-void *zs_map_object(struct zs_pool *pool, unsigned long handle,
-			enum zs_mapmode mm)
-{
-	struct page *page;
-	unsigned long obj, obj_idx, off;
-
-	unsigned int class_idx;
-	enum fullness_group fg;
-	struct size_class *class;
-	struct mapping_area *area;
-	struct page *pages[2];
-	void *ret;
-
-	BUG_ON(!handle);
-
-	/*
-	 * Because we use per-cpu mapping areas shared among the
-	 * pools/users, we can't allow mapping in interrupt context
-	 * because it can corrupt another users mappings.
-	 */
-	BUG_ON(in_interrupt());
-
-	/* From now on, migration cannot move the object */
-	pin_tag(handle);
-
-	obj = handle_to_obj(handle);
-	obj_to_location(obj, &page, &obj_idx);
-	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
-	class = pool->size_class[class_idx];
-	off = obj_idx_to_offset(page, obj_idx, class->size);
-
-	area = &get_cpu_var(zs_map_area);
-	area->vm_mm = mm;
-	if (off + class->size <= PAGE_SIZE) {
-		/* this object is contained entirely within a page */
-		area->vm_addr = kmap_atomic(page);
-		ret = area->vm_addr + off;
-		goto out;
-	}
-
-	/* this object spans two pages */
-	pages[0] = page;
-	pages[1] = get_next_page(page);
-	BUG_ON(!pages[1]);
-
-	ret = __zs_map_object(area, pages, off, class->size);
-out:
-	if (!class->huge)
-		ret += ZS_HANDLE_SIZE;
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(zs_map_object);
-
-void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
-{
-	struct page *page;
-	unsigned long obj, obj_idx, off;
-
-	unsigned int class_idx;
-	enum fullness_group fg;
-	struct size_class *class;
-	struct mapping_area *area;
-
-	BUG_ON(!handle);
-
-	obj = handle_to_obj(handle);
-	obj_to_location(obj, &page, &obj_idx);
-	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
-	class = pool->size_class[class_idx];
-	off = obj_idx_to_offset(page, obj_idx, class->size);
-
-	area = this_cpu_ptr(&zs_map_area);
-	if (off + class->size <= PAGE_SIZE)
-		kunmap_atomic(area->vm_addr);
-	else {
-		struct page *pages[2];
-
-		pages[0] = page;
-		pages[1] = get_next_page(page);
-		BUG_ON(!pages[1]);
-
-		__zs_unmap_object(area, pages, off, class->size);
-	}
-	put_cpu_var(zs_map_area);
-	unpin_tag(handle);
-}
-EXPORT_SYMBOL_GPL(zs_unmap_object);
-
 static unsigned long obj_malloc(struct page *first_page,
 		struct size_class *class, unsigned long handle)
 {
@@ -1347,63 +1238,6 @@ static unsigned long obj_malloc(struct page *first_page,
 	return obj;
 }
 
-
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
-{
-	unsigned long handle, obj;
-	struct size_class *class;
-	struct page *first_page;
-
-	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
-		return 0;
-
-	handle = alloc_handle(pool);
-	if (!handle)
-		return 0;
-
-	/* extra space in chunk to keep the handle */
-	size += ZS_HANDLE_SIZE;
-	class = pool->size_class[get_size_class_index(size)];
-
-	spin_lock(&class->lock);
-	first_page = find_get_zspage(class);
-
-	if (!first_page) {
-		spin_unlock(&class->lock);
-		first_page = alloc_zspage(class, pool->flags);
-		if (unlikely(!first_page)) {
-			free_handle(pool, handle);
-			return 0;
-		}
-
-		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
-		atomic_long_add(class->pages_per_zspage,
-					&pool->pages_allocated);
-
-		spin_lock(&class->lock);
-		zs_stat_inc(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
-				class->size, class->pages_per_zspage));
-	}
-
-	obj = obj_malloc(first_page, class, handle);
-	/* Now move the zspage to another fullness group, if required */
-	fix_fullness_group(class, first_page);
-	record_obj(handle, obj);
-	spin_unlock(&class->lock);
-
-	return handle;
-}
-EXPORT_SYMBOL_GPL(zs_malloc);
-
 static void obj_free(struct zs_pool *pool, struct size_class *class,
 			unsigned long obj)
 {
@@ -1436,42 +1270,6 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
 	zs_stat_dec(class, OBJ_USED, 1);
 }
 
-void zs_free(struct zs_pool *pool, unsigned long handle)
-{
-	struct page *first_page, *f_page;
-	unsigned long obj, f_objidx;
-	int class_idx;
-	struct size_class *class;
-	enum fullness_group fullness;
-
-	if (unlikely(!handle))
-		return;
-
-	pin_tag(handle);
-	obj = handle_to_obj(handle);
-	obj_to_location(obj, &f_page, &f_objidx);
-	first_page = get_first_page(f_page);
-
-	get_zspage_mapping(first_page, &class_idx, &fullness);
-	class = pool->size_class[class_idx];
-
-	spin_lock(&class->lock);
-	obj_free(pool, class, obj);
-	fullness = fix_fullness_group(class, first_page);
-	if (fullness == ZS_EMPTY) {
-		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
-				class->size, class->pages_per_zspage));
-		atomic_long_sub(class->pages_per_zspage,
-				&pool->pages_allocated);
-		free_zspage(first_page);
-	}
-	spin_unlock(&class->lock);
-	unpin_tag(handle);
-
-	free_handle(pool, handle);
-}
-EXPORT_SYMBOL_GPL(zs_free);
-
 static void zs_object_copy(unsigned long dst, unsigned long src,
 				struct size_class *class)
 {
@@ -1572,13 +1370,17 @@ static unsigned long find_alloced_obj(struct page *page, int index,
 
 struct zs_compact_control {
 	/* Source page for migration which could be a subpage of zspage. */
-	struct page *s_page;
-	/* Destination page for migration which should be a first page
-	 * of zspage. */
-	struct page *d_page;
-	 /* Starting object index within @s_page which used for live object
-	  * in the subpage. */
-	int index;
+	struct page 	*s_page;
+	/*
+	 * Destination page for migration which should be a first page
+	 * of zspage.
+	 */
+	struct page 	*d_page;
+	 /*
+	  * Starting object index within @s_page which used for live object
+	  * in the subpage.
+	  */
+	int 		index;
 };
 
 static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
@@ -1740,6 +1542,208 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 	spin_unlock(&class->lock);
 }
 
+
+unsigned long zs_get_total_pages(struct zs_pool *pool)
+{
+	return atomic_long_read(&pool->pages_allocated);
+}
+EXPORT_SYMBOL_GPL(zs_get_total_pages);
+
+/**
+ * zs_map_object - get address of allocated object from handle.
+ * @pool: pool from which the object was allocated
+ * @handle: handle returned from zs_malloc
+ *
+ * Before using an object allocated from zs_malloc, it must be mapped using
+ * this function. When done with the object, it must be unmapped using
+ * zs_unmap_object.
+ *
+ * Only one object can be mapped per cpu at a time. There is no protection
+ * against nested mappings.
+ *
+ * This function returns with preemption and page faults disabled.
+ */
+void *zs_map_object(struct zs_pool *pool, unsigned long handle,
+			enum zs_mapmode mm)
+{
+	struct page *page;
+	unsigned long obj, obj_idx, off;
+
+	unsigned int class_idx;
+	enum fullness_group fg;
+	struct size_class *class;
+	struct mapping_area *area;
+	struct page *pages[2];
+	void *ret;
+
+	BUG_ON(!handle);
+
+	/*
+	 * Because we use per-cpu mapping areas shared among the
+	 * pools/users, we can't allow mapping in interrupt context
+	 * because it can corrupt another users mappings.
+	 */
+	BUG_ON(in_interrupt());
+
+	/* From now on, migration cannot move the object */
+	pin_tag(handle);
+
+	obj = handle_to_obj(handle);
+	obj_to_location(obj, &page, &obj_idx);
+	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
+	class = pool->size_class[class_idx];
+	off = obj_idx_to_offset(page, obj_idx, class->size);
+
+	area = &get_cpu_var(zs_map_area);
+	area->vm_mm = mm;
+	if (off + class->size <= PAGE_SIZE) {
+		/* this object is contained entirely within a page */
+		area->vm_addr = kmap_atomic(page);
+		ret = area->vm_addr + off;
+		goto out;
+	}
+
+	/* this object spans two pages */
+	pages[0] = page;
+	pages[1] = get_next_page(page);
+	BUG_ON(!pages[1]);
+
+	ret = __zs_map_object(area, pages, off, class->size);
+out:
+	if (!class->huge)
+		ret += ZS_HANDLE_SIZE;
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(zs_map_object);
+
+void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
+{
+	struct page *page;
+	unsigned long obj, obj_idx, off;
+
+	unsigned int class_idx;
+	enum fullness_group fg;
+	struct size_class *class;
+	struct mapping_area *area;
+
+	BUG_ON(!handle);
+
+	obj = handle_to_obj(handle);
+	obj_to_location(obj, &page, &obj_idx);
+	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
+	class = pool->size_class[class_idx];
+	off = obj_idx_to_offset(page, obj_idx, class->size);
+
+	area = this_cpu_ptr(&zs_map_area);
+	if (off + class->size <= PAGE_SIZE)
+		kunmap_atomic(area->vm_addr);
+	else {
+		struct page *pages[2];
+
+		pages[0] = page;
+		pages[1] = get_next_page(page);
+		BUG_ON(!pages[1]);
+
+		__zs_unmap_object(area, pages, off, class->size);
+	}
+	put_cpu_var(zs_map_area);
+	unpin_tag(handle);
+}
+EXPORT_SYMBOL_GPL(zs_unmap_object);
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
+	unsigned long handle, obj;
+	struct size_class *class;
+	struct page *first_page;
+
+	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
+		return 0;
+
+	handle = alloc_handle(pool);
+	if (!handle)
+		return 0;
+
+	/* extra space in chunk to keep the handle */
+	size += ZS_HANDLE_SIZE;
+	class = pool->size_class[get_size_class_index(size)];
+
+	spin_lock(&class->lock);
+	first_page = find_get_zspage(class);
+
+	if (!first_page) {
+		spin_unlock(&class->lock);
+		first_page = alloc_zspage(class, pool->flags);
+		if (unlikely(!first_page)) {
+			free_handle(pool, handle);
+			return 0;
+		}
+
+		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
+		atomic_long_add(class->pages_per_zspage,
+					&pool->pages_allocated);
+
+		spin_lock(&class->lock);
+		zs_stat_inc(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
+				class->size, class->pages_per_zspage));
+	}
+
+	obj = obj_malloc(first_page, class, handle);
+	/* Now move the zspage to another fullness group, if required */
+	fix_fullness_group(class, first_page);
+	record_obj(handle, obj);
+	spin_unlock(&class->lock);
+
+	return handle;
+}
+EXPORT_SYMBOL_GPL(zs_malloc);
+
+void zs_free(struct zs_pool *pool, unsigned long handle)
+{
+	struct page *first_page, *f_page;
+	unsigned long obj, f_objidx;
+	int class_idx;
+	struct size_class *class;
+	enum fullness_group fullness;
+
+	if (unlikely(!handle))
+		return;
+
+	pin_tag(handle);
+	obj = handle_to_obj(handle);
+	obj_to_location(obj, &f_page, &f_objidx);
+	first_page = get_first_page(f_page);
+
+	get_zspage_mapping(first_page, &class_idx, &fullness);
+	class = pool->size_class[class_idx];
+
+	spin_lock(&class->lock);
+	obj_free(pool, class, obj);
+	fullness = fix_fullness_group(class, first_page);
+	if (fullness == ZS_EMPTY) {
+		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
+				class->size, class->pages_per_zspage));
+		atomic_long_sub(class->pages_per_zspage,
+				&pool->pages_allocated);
+		free_zspage(first_page);
+	}
+	spin_unlock(&class->lock);
+	unpin_tag(handle);
+
+	free_handle(pool, handle);
+}
+EXPORT_SYMBOL_GPL(zs_free);
+
 unsigned long zs_compact(struct zs_pool *pool)
 {
 	int i;
-- 
2.4.2.337.gfae46aa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
