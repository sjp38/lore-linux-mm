Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8FD6B0074
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 00:00:57 -0500 (EST)
Received: by pdev10 with SMTP id v10so7827826pde.0
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 21:00:56 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ww6si3651788pbc.52.2015.03.03.21.00.44
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 21:00:46 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 1/7] zsmalloc: decouple handle and object
Date: Wed,  4 Mar 2015 14:01:26 +0900
Message-Id: <1425445292-29061-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1425445292-29061-1-git-send-email-minchan@kernel.org>
References: <1425445292-29061-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, opensource.ganesh@gmail.com, Minchan Kim <minchan@kernel.org>

Currently, handle of zsmalloc encodes object's location directly
so it makes support of migration hard.

This patch decouples handle and object via adding indirect layer.
For that, it allocates handle dynamically and returns it to user.
The handle is the address allocated by slab allocation so it's
unique and we could keep object's location in the memory space
allocated for handle.

With it, we can change object's position without changing handle
itself.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 128 ++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 98 insertions(+), 30 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0dec1fa5f656..2df2f1b08aaa 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -110,6 +110,8 @@
 #define ZS_MAX_ZSPAGE_ORDER 2
 #define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
 
+#define ZS_HANDLE_SIZE (sizeof(unsigned long))
+
 /*
  * Object location (<PFN>, <obj_idx>) is encoded as
  * as single (unsigned long) handle value.
@@ -140,7 +142,8 @@
 /* ZS_MIN_ALLOC_SIZE must be multiple of ZS_ALIGN */
 #define ZS_MIN_ALLOC_SIZE \
 	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
-#define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
+/* each chunk includes extra space to keep handle */
+#define ZS_MAX_ALLOC_SIZE	(PAGE_SIZE + ZS_HANDLE_SIZE)
 
 /*
  * On systems with 4K page size, this gives 255 size classes! There is a
@@ -233,14 +236,24 @@ struct size_class {
  * This must be power of 2 and less than or equal to ZS_ALIGN
  */
 struct link_free {
-	/* Handle of next free chunk (encodes <PFN, obj_idx>) */
-	void *next;
+	union {
+		/*
+		 * Position of next free chunk (encodes <PFN, obj_idx>)
+		 * It's valid for non-allocated object
+		 */
+		void *next;
+		/*
+		 * Handle of allocated object.
+		 */
+		unsigned long handle;
+	};
 };
 
 struct zs_pool {
 	char *name;
 
 	struct size_class **size_class;
+	struct kmem_cache *handle_cachep;
 
 	gfp_t flags;	/* allocation flags used when growing pool */
 	atomic_long_t pages_allocated;
@@ -269,6 +282,34 @@ struct mapping_area {
 	enum zs_mapmode vm_mm; /* mapping mode */
 };
 
+static int create_handle_cache(struct zs_pool *pool)
+{
+	pool->handle_cachep = kmem_cache_create("zs_handle", ZS_HANDLE_SIZE,
+					0, 0, NULL);
+	return pool->handle_cachep ? 0 : 1;
+}
+
+static void destroy_handle_cache(struct zs_pool *pool)
+{
+	kmem_cache_destroy(pool->handle_cachep);
+}
+
+static unsigned long alloc_handle(struct zs_pool *pool)
+{
+	return (unsigned long)kmem_cache_alloc(pool->handle_cachep,
+		pool->flags & ~__GFP_HIGHMEM);
+}
+
+static void free_handle(struct zs_pool *pool, unsigned long handle)
+{
+	kmem_cache_free(pool->handle_cachep, (void *)handle);
+}
+
+static void record_obj(unsigned long handle, unsigned long obj)
+{
+	*(unsigned long *)handle = obj;
+}
+
 /* zpool driver */
 
 #ifdef CONFIG_ZPOOL
@@ -595,13 +636,18 @@ static void *obj_location_to_handle(struct page *page, unsigned long obj_idx)
  * decoded obj_idx back to its original value since it was adjusted in
  * obj_location_to_handle().
  */
-static void obj_handle_to_location(unsigned long handle, struct page **page,
+static void obj_to_location(unsigned long handle, struct page **page,
 				unsigned long *obj_idx)
 {
 	*page = pfn_to_page(handle >> OBJ_INDEX_BITS);
 	*obj_idx = (handle & OBJ_INDEX_MASK) - 1;
 }
 
+static unsigned long handle_to_obj(unsigned long handle)
+{
+	return *(unsigned long *)handle;
+}
+
 static unsigned long obj_idx_to_offset(struct page *page,
 				unsigned long obj_idx, int class_size)
 {
@@ -860,12 +906,16 @@ static void __zs_unmap_object(struct mapping_area *area,
 {
 	int sizes[2];
 	void *addr;
-	char *buf = area->vm_buf;
+	char *buf;
 
 	/* no write fastpath */
 	if (area->vm_mm == ZS_MM_RO)
 		goto out;
 
+	buf = area->vm_buf + ZS_HANDLE_SIZE;
+	size -= ZS_HANDLE_SIZE;
+	off += ZS_HANDLE_SIZE;
+
 	sizes[0] = PAGE_SIZE - off;
 	sizes[1] = size - sizes[0];
 
@@ -1153,13 +1203,14 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 			enum zs_mapmode mm)
 {
 	struct page *page;
-	unsigned long obj_idx, off;
+	unsigned long obj, obj_idx, off;
 
 	unsigned int class_idx;
 	enum fullness_group fg;
 	struct size_class *class;
 	struct mapping_area *area;
 	struct page *pages[2];
+	void *ret;
 
 	BUG_ON(!handle);
 
@@ -1170,7 +1221,8 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	 */
 	BUG_ON(in_interrupt());
 
-	obj_handle_to_location(handle, &page, &obj_idx);
+	obj = handle_to_obj(handle);
+	obj_to_location(obj, &page, &obj_idx);
 	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
 	class = pool->size_class[class_idx];
 	off = obj_idx_to_offset(page, obj_idx, class->size);
@@ -1180,7 +1232,8 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	if (off + class->size <= PAGE_SIZE) {
 		/* this object is contained entirely within a page */
 		area->vm_addr = kmap_atomic(page);
-		return area->vm_addr + off;
+		ret = area->vm_addr + off;
+		goto out;
 	}
 
 	/* this object spans two pages */
@@ -1188,14 +1241,16 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	pages[1] = get_next_page(page);
 	BUG_ON(!pages[1]);
 
-	return __zs_map_object(area, pages, off, class->size);
+	ret = __zs_map_object(area, pages, off, class->size);
+out:
+	return ret + ZS_HANDLE_SIZE;
 }
 EXPORT_SYMBOL_GPL(zs_map_object);
 
 void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 {
 	struct page *page;
-	unsigned long obj_idx, off;
+	unsigned long obj, obj_idx, off;
 
 	unsigned int class_idx;
 	enum fullness_group fg;
@@ -1204,7 +1259,8 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 
 	BUG_ON(!handle);
 
-	obj_handle_to_location(handle, &page, &obj_idx);
+	obj = handle_to_obj(handle);
+	obj_to_location(obj, &page, &obj_idx);
 	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
 	class = pool->size_class[class_idx];
 	off = obj_idx_to_offset(page, obj_idx, class->size);
@@ -1236,7 +1292,7 @@ EXPORT_SYMBOL_GPL(zs_unmap_object);
  */
 unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 {
-	unsigned long obj;
+	unsigned long handle, obj;
 	struct link_free *link;
 	struct size_class *class;
 	void *vaddr;
@@ -1244,9 +1300,15 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	struct page *first_page, *m_page;
 	unsigned long m_objidx, m_offset;
 
-	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
+	if (unlikely(!size || (size + ZS_HANDLE_SIZE) > ZS_MAX_ALLOC_SIZE))
 		return 0;
 
+	handle = alloc_handle(pool);
+	if (!handle)
+		return 0;
+
+	/* extra space in chunk to keep the handle */
+	size += ZS_HANDLE_SIZE;
 	class = pool->size_class[get_size_class_index(size)];
 
 	spin_lock(&class->lock);
@@ -1255,8 +1317,10 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	if (!first_page) {
 		spin_unlock(&class->lock);
 		first_page = alloc_zspage(class, pool->flags);
-		if (unlikely(!first_page))
+		if (unlikely(!first_page)) {
+			free_handle(pool, handle);
 			return 0;
+		}
 
 		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
 		atomic_long_add(class->pages_per_zspage,
@@ -1268,40 +1332,45 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	}
 
 	obj = (unsigned long)first_page->freelist;
-	obj_handle_to_location(obj, &m_page, &m_objidx);
+	obj_to_location(obj, &m_page, &m_objidx);
 	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
 
 	vaddr = kmap_atomic(m_page);
 	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
 	first_page->freelist = link->next;
-	memset(link, POISON_INUSE, sizeof(*link));
+
+	/* record handle in the header of allocated chunk */
+	link->handle = handle;
 	kunmap_atomic(vaddr);
 
 	first_page->inuse++;
 	zs_stat_inc(class, OBJ_USED, 1);
 	/* Now move the zspage to another fullness group, if required */
 	fix_fullness_group(pool, first_page);
+	record_obj(handle, obj);
 	spin_unlock(&class->lock);
 
-	return obj;
+	return handle;
 }
 EXPORT_SYMBOL_GPL(zs_malloc);
 
-void zs_free(struct zs_pool *pool, unsigned long obj)
+void zs_free(struct zs_pool *pool, unsigned long handle)
 {
 	struct link_free *link;
 	struct page *first_page, *f_page;
-	unsigned long f_objidx, f_offset;
+	unsigned long obj, f_objidx, f_offset;
 	void *vaddr;
 
 	int class_idx;
 	struct size_class *class;
 	enum fullness_group fullness;
 
-	if (unlikely(!obj))
+	if (unlikely(!handle))
 		return;
 
-	obj_handle_to_location(obj, &f_page, &f_objidx);
+	obj = handle_to_obj(handle);
+	free_handle(pool, handle);
+	obj_to_location(obj, &f_page, &f_objidx);
 	first_page = get_first_page(f_page);
 
 	get_zspage_mapping(first_page, &class_idx, &fullness);
@@ -1356,18 +1425,16 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
 		return NULL;
 
 	pool->name = kstrdup(name, GFP_KERNEL);
-	if (!pool->name) {
-		kfree(pool);
-		return NULL;
-	}
+	if (!pool->name)
+		goto err;
+
+	if (create_handle_cache(pool))
+		goto err;
 
 	pool->size_class = kcalloc(zs_size_classes, sizeof(struct size_class *),
 			GFP_KERNEL);
-	if (!pool->size_class) {
-		kfree(pool->name);
-		kfree(pool);
-		return NULL;
-	}
+	if (!pool->size_class)
+		goto err;
 
 	/*
 	 * Iterate reversly, because, size of size_class that we want to use
@@ -1450,6 +1517,7 @@ void zs_destroy_pool(struct zs_pool *pool)
 		kfree(class);
 	}
 
+	destroy_handle_cache(pool);
 	kfree(pool->size_class);
 	kfree(pool->name);
 	kfree(pool);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
