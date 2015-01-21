Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 28D7B6B0074
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 01:14:52 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so8236519pdj.9
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 22:14:51 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id sv1si6952701pbc.195.2015.01.20.22.14.36
        for <linux-mm@kvack.org>;
        Tue, 20 Jan 2015 22:14:38 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 06/10] zsmalloc: support compaction
Date: Wed, 21 Jan 2015 15:14:22 +0900
Message-Id: <1421820866-26521-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1421820866-26521-1-git-send-email-minchan@kernel.org>
References: <1421820866-26521-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>

This patch provides core functions for migration of zsmalloc.
Migraion policy is simple as follows.

It searches source zspages from ZS_ALMOST_EMPTY and destination
zspages from ZS_ALMOST_FULL and try to move objects in source
zspage into destination zspages. If it is lack of destination
pages in ZS_ALMOST_FULL, it falls back to ZS_ALMOST_EMPTY.
If all objects in source zspage moved out, the zspage could be
freed.

Migrate uses rcu freeing to free source zspage in migration
since migration could race with object accessing via
zs_map_object so that we can access size_class from handle
safely with rcu_read_[un]lock but it needs to recheck
handle's validity.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/zsmalloc.h |   1 +
 mm/zsmalloc.c            | 324 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 321 insertions(+), 4 deletions(-)

diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 3283c6a..1338190 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -47,5 +47,6 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
 
 unsigned long zs_get_total_pages(struct zs_pool *pool);
+unsigned long zs_compact(struct zs_pool *pool);
 
 #endif
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 99555da..99bf5bd 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -663,6 +663,11 @@ static unsigned long handle_to_obj(unsigned long handle)
 	return *(unsigned long *)handle;
 }
 
+unsigned long obj_to_head(void *obj)
+{
+	return *(unsigned long *)obj;
+}
+
 static unsigned long obj_idx_to_offset(struct page *page,
 				unsigned long obj_idx, int class_size)
 {
@@ -1044,6 +1049,13 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
 	return true;
 }
 
+static bool zspage_full(struct page *page)
+{
+	BUG_ON(!is_first_page(page));
+
+	return page->inuse == page->objects;
+}
+
 #ifdef CONFIG_ZSMALLOC_STAT
 
 static inline void zs_stat_inc(struct size_class *class,
@@ -1246,12 +1258,27 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	 */
 	BUG_ON(in_interrupt());
 
-	pin_tag(handle);
-
+retry:
+	/*
+	 * Migrating object will not be destroyed so we can get a first_page
+	 * safely but need to verify handle again.
+	 */
+	rcu_read_lock();
 	obj = handle_to_obj(handle);
 	obj_to_location(obj, &page, &obj_idx);
 	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
 	class = pool->size_class[class_idx];
+	spin_lock(&class->lock);
+	if (obj != handle_to_obj(handle)) {
+		/* the object was moved by migration. Then fetch new object */
+		spin_unlock(&class->lock);
+		rcu_read_unlock();
+		goto retry;
+	}
+	rcu_read_unlock();
+	/* From now on, migration cannot move the object */
+	pin_tag(handle);
+	spin_unlock(&class->lock);
 	off = obj_idx_to_offset(page, obj_idx, class->size);
 
 	area = &get_cpu_var(zs_map_area);
@@ -1305,7 +1332,9 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 		__zs_unmap_object(area, pages, off, class->size);
 	}
 	put_cpu_var(zs_map_area);
+	spin_lock(&class->lock);
 	unpin_tag(handle);
+	spin_unlock(&class->lock);
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
 
@@ -1434,9 +1463,9 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 
 	if (unlikely(!handle))
 		return;
-
+retry:
+	rcu_read_lock();
 	obj = handle_to_obj(handle);
-	free_handle(pool, handle);
 	obj_to_location(obj, &f_page, &f_objidx);
 	first_page = get_first_page(f_page);
 
@@ -1444,6 +1473,15 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	class = pool->size_class[class_idx];
 
 	spin_lock(&class->lock);
+	/* Retry if migrate moves object */
+	if (obj != handle_to_obj(handle)) {
+		spin_unlock(&class->lock);
+		rcu_read_unlock();
+		goto retry;
+	}
+	rcu_read_unlock();
+
+	free_handle(pool, handle);
 	obj_free(pool, class, obj);
 	fullness = fix_fullness_group(class, first_page);
 	if (fullness == ZS_EMPTY)
@@ -1459,6 +1497,284 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
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
+			kunmap_atomic(d_addr);
+			kunmap_atomic(s_addr);
+			s_page = get_next_page(s_page);
+			BUG_ON(!s_page);
+			s_addr = kmap_atomic(s_page);
+			d_addr = kmap_atomic(d_page);
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
+	kunmap_atomic(d_addr);
+	kunmap_atomic(s_addr);
+}
+
+/*
+ * Find alloced object in zspage from index object and
+ * return handle.
+ */
+static unsigned long find_alloced_obj(struct page *page, int index,
+					struct size_class *class)
+{
+	unsigned long head;
+	int offset = 0;
+	unsigned long handle = 0;
+	void *addr = kmap_atomic(page);
+
+	if (!is_first_page(page))
+		offset = page->index;
+	offset += class->size * index;
+
+	while (offset < PAGE_SIZE) {
+		head = obj_to_head(addr + offset);
+		if (head & OBJ_ALLOCATED_TAG) {
+			handle = head & ~OBJ_ALLOCATED_TAG;
+			if (!(*(unsigned long *)handle & HANDLE_PIN_TAG))
+				break;
+			handle = 0;
+		}
+
+		offset += class->size;
+		index++;
+	}
+
+	kunmap_atomic(addr);
+	return handle;
+}
+
+struct zs_compact_control {
+	/* from page for migration. It could be subpage, not first page */
+	struct page *s_page;
+	int index; /* start index from @s_page for finding used object */
+	/* to page for migration. It must be first_page */
+	struct page *d_page;
+};
+
+static int migrate_zspage(struct zs_pool *pool, struct zs_compact_control *cc,
+				struct size_class *class)
+{
+	unsigned long used_obj, free_obj;
+	unsigned long handle;
+	struct page *s_page = cc->s_page;
+	struct page *d_page = cc->d_page;
+	unsigned long index = cc->index;
+	int nr_migrated = 0;
+
+	while (1) {
+		handle = find_alloced_obj(s_page, index, class);
+		if (!handle) {
+			s_page = get_next_page(s_page);
+			if (!s_page)
+				break;
+			index = 0;
+			continue;
+		}
+
+		/* stop if there is no more space */
+		if (zspage_full(d_page))
+			break;
+
+		used_obj = handle_to_obj(handle);
+		free_obj = obj_malloc(d_page, class, handle);
+		zs_object_copy(used_obj, free_obj, class);
+		index++;
+		record_obj(handle, free_obj);
+		obj_free(pool, class, used_obj);
+		nr_migrated++;
+	}
+
+	cc->s_page = s_page;
+	cc->index = index;
+
+	return nr_migrated;
+}
+
+static struct page *alloc_target_page(struct size_class *class)
+{
+	int i;
+	struct page *page;
+
+	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
+		page = class->fullness_list[i];
+		if (page) {
+			remove_zspage(page, class, i);
+			break;
+		}
+	}
+
+	return page;
+}
+
+static void rcu_free_zspage(struct rcu_head *h)
+{
+	struct page *first_page;
+
+	first_page = container_of((struct list_head *)h, struct page, lru);
+	free_zspage(first_page);
+}
+
+static void putback_zspage(struct zs_pool *pool, struct size_class *class,
+				struct page *first_page)
+{
+	int class_idx;
+	enum fullness_group fullness;
+
+	BUG_ON(!is_first_page(first_page));
+
+	get_zspage_mapping(first_page, &class_idx, &fullness);
+	insert_zspage(first_page, class, fullness);
+	fullness = fix_fullness_group(class, first_page);
+	if (fullness == ZS_EMPTY) {
+		struct rcu_head *head;
+
+		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
+			class->size, class->pages_per_zspage));
+		atomic_long_sub(class->pages_per_zspage,
+				&pool->pages_allocated);
+		head = (struct rcu_head *)&first_page->lru;
+		call_rcu(head, rcu_free_zspage);
+	}
+}
+
+static struct page *isolate_source_page(struct size_class *class)
+{
+	struct page *page;
+
+	page = class->fullness_list[ZS_ALMOST_EMPTY];
+	if (page)
+		remove_zspage(page, class, ZS_ALMOST_EMPTY);
+
+	return page;
+}
+
+static unsigned long __zs_compact(struct zs_pool *pool,
+				struct size_class *class)
+{
+	unsigned long nr_total_migrated = 0;
+	struct page *src_page;
+	struct page *dst_page = NULL;
+
+	spin_lock(&class->lock);
+	while ((src_page = isolate_source_page(class))) {
+		int nr_to_migrate, nr_migrated;
+		struct zs_compact_control cc;
+
+		BUG_ON(!is_first_page(src_page));
+
+		cc.index = 0;
+		cc.s_page = src_page;
+		nr_to_migrate = src_page->inuse;
+new_target:
+		dst_page = alloc_target_page(class);
+		if (!dst_page)
+			break;
+
+		cc.d_page = dst_page;
+
+		nr_migrated = migrate_zspage(pool, &cc, class);
+		/*
+		 * Allocate new target page if it was failed by
+		 * shortage of free object in the target page
+		 */
+		if (nr_to_migrate > nr_migrated &&
+			zspage_full(dst_page) && cc.s_page != NULL) {
+			putback_zspage(pool, class, cc.d_page);
+			nr_total_migrated += nr_migrated;
+			nr_to_migrate -= nr_migrated;
+			goto new_target;
+		}
+
+		putback_zspage(pool, class, cc.d_page);
+		putback_zspage(pool, class, src_page);
+		spin_unlock(&class->lock);
+		nr_total_migrated += nr_migrated;
+		cond_resched();
+		spin_lock(&class->lock);
+	}
+	if (src_page)
+		putback_zspage(pool, class, src_page);
+
+	spin_unlock(&class->lock);
+
+	return nr_total_migrated;
+}
+
+unsigned long zs_compact(struct zs_pool *pool)
+{
+	int i;
+	unsigned long nr_migrated = 0;
+	struct size_class *class;
+
+	for (i = zs_size_classes - 1; i >= 0; i--) {
+		class = pool->size_class[i];
+		if (!class)
+			continue;
+		if (class->index != i)
+			continue;
+		nr_migrated += __zs_compact(pool, class);
+	}
+
+	if (nr_migrated)
+		synchronize_rcu();
+
+	return nr_migrated;
+}
+EXPORT_SYMBOL_GPL(zs_compact);
+
 /**
  * zs_create_pool - Creates an allocation pool to work from.
  * @flags: allocation flags used to allocate pool metadata
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
