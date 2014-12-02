Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B72DE6B0070
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 21:50:14 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so12522477pad.9
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 18:50:14 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id xu8si31591095pab.121.2014.12.01.18.50.08
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 18:50:10 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 5/6] zsmalloc: support compaction
Date: Tue,  2 Dec 2014 11:49:46 +0900
Message-Id: <1417488587-28609-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1417488587-28609-1-git-send-email-minchan@kernel.org>
References: <1417488587-28609-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Minchan Kim <minchan@kernel.org>

This patch enables zsmalloc compaction so that user can use it
via calling zs_compact(pool).

The migration policy is as follows,

1. find migration target objects in ZS_ALMOST_EMPTY
2. find free space in ZS_ALMOST_FULL. With no found, find it in ZS_ALMOST_EMPTY.
3. migrate objects get by 1 to free spaces get by 2
4. repeat [1-3] on each size class

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/zsmalloc.h |   1 +
 mm/zsmalloc.c            | 344 ++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 330 insertions(+), 15 deletions(-)

diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 05c214760977..04ecd3fc4283 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -47,5 +47,6 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
 
 unsigned long zs_get_total_pages(struct zs_pool *pool);
+unsigned long zs_compact(struct zs_pool *pool);
 
 #endif
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 16c40081c22e..304595d97610 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -227,6 +227,7 @@ struct zs_pool {
 	struct size_class **size_class;
 	struct size_class *handle_class;
 
+	rwlock_t  migrate_lock;
 	gfp_t flags;	/* allocation flags used when growing pool */
 	atomic_long_t pages_allocated;
 };
@@ -618,6 +619,24 @@ static unsigned long handle_to_obj(struct zs_pool *pool, unsigned long handle)
 	return obj;
 }
 
+static unsigned long obj_to_handle(struct zs_pool *pool,
+				struct size_class *class, unsigned long obj)
+{
+	struct page *page;
+	unsigned long obj_idx, off;
+	unsigned long handle;
+	void *addr;
+
+	obj_to_location(obj, &page, &obj_idx);
+	off = obj_idx_to_offset(page, obj_idx, class->size);
+
+	addr = kmap_atomic(page);
+	handle = *(unsigned long *)(addr + off);
+	kunmap_atomic(addr);
+
+	return handle;
+}
+
 static unsigned long alloc_handle(struct zs_pool *pool)
 {
 	unsigned long handle;
@@ -1066,6 +1085,8 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 	if (!pool)
 		return NULL;
 
+	rwlock_init(&pool->migrate_lock);
+
 	if (create_handle_class(pool, ZS_HANDLE_SIZE))
 		goto err;
 
@@ -1157,20 +1178,41 @@ void zs_destroy_pool(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_destroy_pool);
 
-static unsigned long __zs_malloc(struct zs_pool *pool,
-		struct size_class *class, gfp_t flags, unsigned long handle)
+static unsigned long __obj_malloc(struct page *first_page,
+		struct size_class *class, unsigned long handle)
 {
 	unsigned long obj;
 	struct link_free *link;
-	struct page *first_page, *m_page;
+	struct page *m_page;
 	unsigned long m_objidx, m_offset;
 	void *vaddr;
 
+	obj = (unsigned long)first_page->freelist;
+	obj_to_location(obj, &m_page, &m_objidx);
+	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
+
+	vaddr = kmap_atomic(m_page);
+	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
+	first_page->freelist = link->next;
+	link->handle = handle;
+	kunmap_atomic(vaddr);
+
+	first_page->inuse++;
+	return obj;
+}
+
+static unsigned long __zs_malloc(struct zs_pool *pool,
+		struct size_class *class, gfp_t flags, unsigned long handle)
+{
+	struct page *first_page;
+	unsigned long obj;
+
 	spin_lock(&class->lock);
 	first_page = find_get_zspage(class);
 
 	if (!first_page) {
 		spin_unlock(&class->lock);
+		read_unlock(&pool->migrate_lock);
 		first_page = alloc_zspage(class, flags);
 		if (unlikely(!first_page))
 			return 0;
@@ -1178,21 +1220,11 @@ static unsigned long __zs_malloc(struct zs_pool *pool,
 		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
 		atomic_long_add(class->pages_per_zspage,
 					&pool->pages_allocated);
+		read_lock(&pool->migrate_lock);
 		spin_lock(&class->lock);
 	}
 
-	obj = (unsigned long)first_page->freelist;
-	obj_to_location(obj, &m_page, &m_objidx);
-	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
-
-	vaddr = kmap_atomic(m_page);
-	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
-	first_page->freelist = link->next;
-	link->handle = handle;
-	kunmap_atomic(vaddr);
-
-	first_page->inuse++;
-
+	obj = __obj_malloc(first_page, class, handle);
 	if (handle) {
 		unsigned long *h_addr;
 
@@ -1225,6 +1257,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	if (unlikely(!size || (size + ZS_HANDLE_SIZE) > ZS_MAX_ALLOC_SIZE))
 		return 0;
 
+	read_lock(&pool->migrate_lock);
 	/* allocate handle */
 	handle = alloc_handle(pool);
 	if (!handle)
@@ -1240,6 +1273,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 		goto out;
 	}
 out:
+	read_unlock(&pool->migrate_lock);
 	return handle;
 }
 EXPORT_SYMBOL_GPL(zs_malloc);
@@ -1299,6 +1333,7 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	if (unlikely(!handle))
 		return;
 
+	read_lock(&pool->migrate_lock);
 	obj = handle_to_obj(pool, handle);
 	/* free handle */
 	free_handle(pool, handle);
@@ -1311,6 +1346,7 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	class = pool->size_class[class_idx];
 
 	__zs_free(pool, class, obj);
+	read_unlock(&pool->migrate_lock);
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
@@ -1343,6 +1379,7 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 
 	BUG_ON(!handle);
 
+	read_lock(&pool->migrate_lock);
 	/*
 	 * Because we use per-cpu mapping areas shared among the
 	 * pools/users, we can't allow mapping in interrupt context
@@ -1405,6 +1442,7 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 		__zs_unmap_object(area, pages, off, class->size);
 	}
 	put_cpu_var(zs_map_area);
+	read_unlock(&pool->migrate_lock);
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
 
@@ -1414,6 +1452,282 @@ unsigned long zs_get_total_pages(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_get_total_pages);
 
+static void zs_object_copy(unsigned long src, unsigned long dst,
+				struct size_class *class)
+{
+	struct page *s_page, *d_page;
+	unsigned long s_objidx, d_objidx;
+	unsigned long s_off, d_off;
+	void *s_addr, *d_addr;
+	int s_size, d_size, size;
+	int written = 0;
+
+	s_size = d_size = class->size;
+
+	obj_to_location(src, &s_page, &s_objidx);
+	obj_to_location(dst, &d_page, &d_objidx);
+
+	s_off = obj_idx_to_offset(s_page, s_objidx, class->size);
+	d_off = obj_idx_to_offset(d_page, d_objidx, class->size);
+
+	if (s_off + class->size > PAGE_SIZE)
+		s_size = PAGE_SIZE - s_off;
+
+	if (d_off + class->size > PAGE_SIZE)
+		d_size = PAGE_SIZE - d_off;
+
+	s_addr = kmap_atomic(s_page);
+	d_addr = kmap_atomic(d_page);
+
+	while (1) {
+		size = min(s_size, d_size);
+		memcpy(d_addr + d_off, s_addr + s_off, size);
+		written += size;
+
+		if (written == class->size)
+			break;
+
+		if (s_off + size >= PAGE_SIZE) {
+			kunmap_atomic(s_addr);
+			s_page = get_next_page(s_page);
+			BUG_ON(!s_page);
+			s_addr = kmap_atomic(s_page);
+			s_size = class->size - written;
+			s_off = 0;
+		} else {
+			s_off += size;
+			s_size -= size;
+		}
+
+		if (d_off + size >= PAGE_SIZE) {
+			kunmap_atomic(d_addr);
+			d_page = get_next_page(d_page);
+			BUG_ON(!d_page);
+			d_addr = kmap_atomic(d_page);
+			d_size = class->size - written;
+			d_off = 0;
+		} else {
+			d_off += size;
+			d_size -= size;
+		}
+	}
+
+	kunmap_atomic(s_addr);
+	kunmap_atomic(d_addr);
+}
+
+static unsigned long find_alloced_obj(struct page *page, int index,
+					struct size_class *class)
+{
+	int offset = 0;
+	unsigned long obj = 0;
+	void *addr = kmap_atomic(page);
+
+	if (!is_first_page(page))
+		offset = page->index;
+	offset += class->size * index;
+
+	while (offset < PAGE_SIZE) {
+		if (*(unsigned long *)(addr + offset) & OBJ_ALLOCATED) {
+			obj = (unsigned long)obj_location_to_handle(page,
+								index);
+			break;
+		}
+
+		offset += class->size;
+		index++;
+	}
+
+	kunmap_atomic(addr);
+	return obj;
+}
+
+struct zs_compact_control {
+	struct page *s_page; /* from page for migration */
+	int index; /* start index from @s_page for finding used object */
+	struct page *d_page; /* to page for migration */
+	unsigned long nr_migrated;
+	int nr_to_migrate;
+};
+
+static void migrate_zspage(struct zs_pool *pool, struct zs_compact_control *cc,
+				struct size_class *class)
+{
+	unsigned long used_obj, free_obj;
+	unsigned long handle;
+	struct page *s_page = cc->s_page;
+	unsigned long index = cc->index;
+	struct page *d_page = cc->d_page;
+	unsigned long *h_addr;
+	bool exit = false;
+
+	BUG_ON(!is_first_page(d_page));
+
+	while (1) {
+		used_obj = find_alloced_obj(s_page, index, class);
+		if (!used_obj) {
+			s_page = get_next_page(s_page);
+			if (!s_page)
+				break;
+			index = 0;
+			continue;
+		}
+
+		if (d_page->inuse == d_page->objects)
+			break;
+
+		free_obj = __obj_malloc(d_page, class, 0);
+
+		zs_object_copy(used_obj, free_obj, class);
+
+		obj_to_location(used_obj, &s_page, &index);
+		index++;
+
+		handle = obj_to_handle(pool, class, used_obj);
+		h_addr = handle_to_addr(pool, handle);
+		BUG_ON(*h_addr != used_obj);
+		*h_addr = free_obj;
+		cc->nr_migrated++;
+
+		/* Don't need a class->lock due to migrate_lock */
+		insert_zspage(get_first_page(s_page), class, ZS_ALMOST_EMPTY);
+
+		/*
+		 * I don't want __zs_free has return value in case of freeing
+		 * zspage for slow path so let's check page->inuse count
+		 * right before __zs_free and then exit if it is last object.
+		 */
+		if (get_first_page(s_page)->inuse == 1)
+			exit = true;
+
+		__zs_free(pool, class, used_obj);
+		if (exit)
+			break;
+
+		remove_zspage(get_first_page(s_page), class, ZS_ALMOST_EMPTY);
+	}
+
+	cc->s_page = s_page;
+	cc->index = index;
+}
+
+static struct page *alloc_target_page(struct size_class *class)
+{
+	int i;
+	struct page *page;
+
+	spin_lock(&class->lock);
+	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
+		page = class->fullness_list[i];
+		if (page) {
+			remove_zspage(page, class, i);
+			break;
+		}
+	}
+	spin_unlock(&class->lock);
+
+	return page;
+}
+
+static void putback_target_page(struct page *page, struct size_class *class)
+{
+	int class_idx;
+	enum fullness_group currfg;
+
+	BUG_ON(!is_first_page(page));
+
+	spin_lock(&class->lock);
+	get_zspage_mapping(page, &class_idx, &currfg);
+	insert_zspage(page, class, currfg);
+	fix_fullness_group(class, page);
+	spin_unlock(&class->lock);
+}
+
+static struct page *isolate_source_page(struct size_class *class)
+{
+	struct page *page;
+
+	spin_lock(&class->lock);
+	page = class->fullness_list[ZS_ALMOST_EMPTY];
+	if (page)
+		remove_zspage(page, class, ZS_ALMOST_EMPTY);
+	spin_unlock(&class->lock);
+
+	return page;
+}
+
+static void putback_source_page(struct page *page, struct size_class *class)
+{
+	spin_lock(&class->lock);
+	insert_zspage(page, class, ZS_ALMOST_EMPTY);
+	fix_fullness_group(class, page);
+	spin_unlock(&class->lock);
+}
+
+static unsigned long __zs_compact(struct zs_pool *pool,
+				struct size_class *class)
+{
+	unsigned long nr_total_migrated = 0;
+	struct page *src_page, *dst_page;
+
+	write_lock(&pool->migrate_lock);
+	while ((src_page = isolate_source_page(class))) {
+		struct zs_compact_control cc;
+
+		BUG_ON(!is_first_page(src_page));
+
+		cc.index = 0;
+		cc.s_page = src_page;
+		cc.nr_to_migrate = src_page->inuse;
+		cc.nr_migrated = 0;
+
+		BUG_ON(0 >= cc.nr_to_migrate);
+retry:
+		dst_page = alloc_target_page(class);
+		if (!dst_page)
+			break;
+		cc.d_page = dst_page;
+
+		migrate_zspage(pool, &cc, class);
+		putback_target_page(cc.d_page, class);
+
+		if (cc.nr_migrated < cc.nr_to_migrate)
+			goto retry;
+
+		write_unlock(&pool->migrate_lock);
+		write_lock(&pool->migrate_lock);
+		nr_total_migrated += cc.nr_migrated;
+	}
+
+	if (src_page)
+		putback_source_page(src_page, class);
+
+	write_unlock(&pool->migrate_lock);
+
+	return nr_total_migrated;
+}
+
+unsigned long zs_compact(struct zs_pool *pool)
+{
+	int i;
+	unsigned long nr_migrated = 0;
+
+	for (i = 0; i < zs_size_classes; i++) {
+		struct size_class *class = pool->size_class[i];
+
+		if (!class)
+			continue;
+
+		if (class->index != i)
+			continue;
+
+		nr_migrated += __zs_compact(pool, class);
+	}
+
+	return nr_migrated;
+}
+EXPORT_SYMBOL_GPL(zs_compact);
+
 module_init(zs_init);
 module_exit(zs_exit);
 
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
