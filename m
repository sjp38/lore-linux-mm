Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 520936B006C
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 00:00:44 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so28462781pdb.4
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 21:00:44 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id g3si3328580pdb.251.2015.03.03.21.00.41
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 21:00:42 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 3/7] zsmalloc: support compaction
Date: Wed,  4 Mar 2015 14:01:28 +0900
Message-Id: <1425445292-29061-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1425445292-29061-1-git-send-email-minchan@kernel.org>
References: <1425445292-29061-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, opensource.ganesh@gmail.com, Minchan Kim <minchan@kernel.org>

This patch provides core functions for migration of zsmalloc.
Migraion policy is simple as follows.

for each size class {
	while {
		src_page = get zs_page from ZS_ALMOST_EMPTY
		if (!src_page)
			break;
		dst_page = get zs_page from ZS_ALMOST_FULL
		if (!dst_page)
			dst_page = get zs_page from ZS_ALMOST_EMPTY
		if (!dst_page)
			break;
		migrate(from src_page, to dst_page);
	}
}

For migration, we need to identify which objects in zspage are
allocated to migrate them out. We could know it by iterating
of freed objects in a zspage because first_page of zspage keeps
free objects singly-linked list but it's not efficient.
Instead, this patch adds a tag(ie, OBJ_ALLOCATED_TAG) in header
of each object(ie, handle) so we could check whether the object
is allocated easily.

This patch adds another status bit in handle to synchronize
between user access through zs_map_object and migration.
During migration, we cannot move objects user are using due to
data coherency between old object and new object.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/zsmalloc.h |   1 +
 mm/zsmalloc.c            | 377 ++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 359 insertions(+), 19 deletions(-)

diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 3283c6a55425..1338190b5478 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -47,5 +47,6 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
 
 unsigned long zs_get_total_pages(struct zs_pool *pool);
+unsigned long zs_compact(struct zs_pool *pool);
 
 #endif
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e52b1b6f5535..24a581c48aea 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -135,7 +135,26 @@
 #endif
 #endif
 #define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)
-#define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS)
+
+/*
+ * Memory for allocating for handle keeps object position by
+ * encoding <page, obj_idx> and the encoded value has a room
+ * in least bit(ie, look at obj_to_location).
+ * We use the bit to synchronize between object access by
+ * user and migration.
+ */
+#define HANDLE_PIN_BIT	0
+
+/*
+ * Head in allocated object should have OBJ_ALLOCATED_TAG
+ * to identify the object was allocated or not.
+ * It's okay to add the status bit in the least bit because
+ * header keeps handle which is 4byte-aligned address so we
+ * have room for two bit at least.
+ */
+#define OBJ_ALLOCATED_TAG 1
+#define OBJ_TAG_BITS 1
+#define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS - OBJ_TAG_BITS)
 #define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
 
 #define MAX(a, b) ((a) >= (b) ? (a) : (b))
@@ -610,35 +629,35 @@ static struct page *get_next_page(struct page *page)
 
 /*
  * Encode <page, obj_idx> as a single handle value.
- * On hardware platforms with physical memory starting at 0x0 the pfn
- * could be 0 so we ensure that the handle will never be 0 by adjusting the
- * encoded obj_idx value before encoding.
+ * We use the least bit of handle for tagging.
  */
-static void *obj_location_to_handle(struct page *page, unsigned long obj_idx)
+static void *location_to_obj(struct page *page, unsigned long obj_idx)
 {
-	unsigned long handle;
+	unsigned long obj;
 
 	if (!page) {
 		BUG_ON(obj_idx);
 		return NULL;
 	}
 
-	handle = page_to_pfn(page) << OBJ_INDEX_BITS;
-	handle |= ((obj_idx + 1) & OBJ_INDEX_MASK);
+	obj = page_to_pfn(page) << OBJ_INDEX_BITS;
+	obj |= ((obj_idx) & OBJ_INDEX_MASK);
+	obj <<= OBJ_TAG_BITS;
 
-	return (void *)handle;
+	return (void *)obj;
 }
 
 /*
  * Decode <page, obj_idx> pair from the given object handle. We adjust the
  * decoded obj_idx back to its original value since it was adjusted in
- * obj_location_to_handle().
+ * location_to_obj().
  */
-static void obj_to_location(unsigned long handle, struct page **page,
+static void obj_to_location(unsigned long obj, struct page **page,
 				unsigned long *obj_idx)
 {
-	*page = pfn_to_page(handle >> OBJ_INDEX_BITS);
-	*obj_idx = (handle & OBJ_INDEX_MASK) - 1;
+	obj >>= OBJ_TAG_BITS;
+	*page = pfn_to_page(obj >> OBJ_INDEX_BITS);
+	*obj_idx = (obj & OBJ_INDEX_MASK);
 }
 
 static unsigned long handle_to_obj(unsigned long handle)
@@ -646,6 +665,11 @@ static unsigned long handle_to_obj(unsigned long handle)
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
@@ -657,6 +681,25 @@ static unsigned long obj_idx_to_offset(struct page *page,
 	return off + obj_idx * class_size;
 }
 
+static inline int trypin_tag(unsigned long handle)
+{
+	unsigned long *ptr = (unsigned long *)handle;
+
+	return !test_and_set_bit_lock(HANDLE_PIN_BIT, ptr);
+}
+
+static void pin_tag(unsigned long handle)
+{
+	while (!trypin_tag(handle));
+}
+
+static void unpin_tag(unsigned long handle)
+{
+	unsigned long *ptr = (unsigned long *)handle;
+
+	clear_bit_unlock(HANDLE_PIN_BIT, ptr);
+}
+
 static void reset_page(struct page *page)
 {
 	clear_bit(PG_private, &page->flags);
@@ -718,7 +761,7 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 		link = (struct link_free *)vaddr + off / sizeof(*link);
 
 		while ((off += class->size) < PAGE_SIZE) {
-			link->next = obj_location_to_handle(page, i++);
+			link->next = location_to_obj(page, i++);
 			link += class->size / sizeof(*link);
 		}
 
@@ -728,7 +771,7 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 		 * page (if present)
 		 */
 		next_page = get_next_page(page);
-		link->next = obj_location_to_handle(next_page, 0);
+		link->next = location_to_obj(next_page, 0);
 		kunmap_atomic(vaddr);
 		page = next_page;
 		off %= PAGE_SIZE;
@@ -782,7 +825,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 
 	init_zspage(first_page, class);
 
-	first_page->freelist = obj_location_to_handle(first_page, 0);
+	first_page->freelist = location_to_obj(first_page, 0);
 	/* Maximum number of objects we can store in this zspage */
 	first_page->objects = class->pages_per_zspage * PAGE_SIZE / class->size;
 
@@ -1017,6 +1060,13 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
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
@@ -1219,6 +1269,9 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	 */
 	BUG_ON(in_interrupt());
 
+	/* From now on, migration cannot move the object */
+	pin_tag(handle);
+
 	obj = handle_to_obj(handle);
 	obj_to_location(obj, &page, &obj_idx);
 	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
@@ -1276,6 +1329,7 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 		__zs_unmap_object(area, pages, off, class->size);
 	}
 	put_cpu_var(zs_map_area);
+	unpin_tag(handle);
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
 
@@ -1289,6 +1343,7 @@ static unsigned long obj_malloc(struct page *first_page,
 	unsigned long m_objidx, m_offset;
 	void *vaddr;
 
+	handle |= OBJ_ALLOCATED_TAG;
 	obj = (unsigned long)first_page->freelist;
 	obj_to_location(obj, &m_page, &m_objidx);
 	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
@@ -1374,6 +1429,7 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
 
 	BUG_ON(!obj);
 
+	obj &= ~OBJ_ALLOCATED_TAG;
 	obj_to_location(obj, &f_page, &f_objidx);
 	first_page = get_first_page(f_page);
 
@@ -1403,8 +1459,8 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	if (unlikely(!handle))
 		return;
 
+	pin_tag(handle);
 	obj = handle_to_obj(handle);
-	free_handle(pool, handle);
 	obj_to_location(obj, &f_page, &f_objidx);
 	first_page = get_first_page(f_page);
 
@@ -1414,18 +1470,301 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	spin_lock(&class->lock);
 	obj_free(pool, class, obj);
 	fullness = fix_fullness_group(class, first_page);
-	if (fullness == ZS_EMPTY)
+	if (fullness == ZS_EMPTY) {
 		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
 				class->size, class->pages_per_zspage));
+		atomic_long_sub(class->pages_per_zspage,
+				&pool->pages_allocated);
+		free_zspage(first_page);
+	}
 	spin_unlock(&class->lock);
+	unpin_tag(handle);
+
+	free_handle(pool, handle);
+}
+EXPORT_SYMBOL_GPL(zs_free);
+
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
+			if (trypin_tag(handle))
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
+	/* Source page for migration which could be a subpage of zspage. */
+	struct page *s_page;
+	/* Destination page for migration which should be a first page
+	 * of zspage. */
+	struct page *d_page;
+	 /* Starting object index within @s_page which used for live object
+	  * in the subpage. */
+	int index;
+	/* how many of objects are migrated */
+	int nr_migrated;
+};
+
+static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
+				struct zs_compact_control *cc)
+{
+	unsigned long used_obj, free_obj;
+	unsigned long handle;
+	struct page *s_page = cc->s_page;
+	struct page *d_page = cc->d_page;
+	unsigned long index = cc->index;
+	int nr_migrated = 0;
+	int ret = 0;
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
+		/* Stop if there is no more space */
+		if (zspage_full(d_page)) {
+			unpin_tag(handle);
+			ret = -ENOMEM;
+			break;
+		}
 
+		used_obj = handle_to_obj(handle);
+		free_obj = obj_malloc(d_page, class, handle);
+		zs_object_copy(used_obj, free_obj, class);
+		index++;
+		record_obj(handle, free_obj);
+		unpin_tag(handle);
+		obj_free(pool, class, used_obj);
+		nr_migrated++;
+	}
+
+	/* Remember last position in this iteration */
+	cc->s_page = s_page;
+	cc->index = index;
+	cc->nr_migrated = nr_migrated;
+
+	return ret;
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
 	if (fullness == ZS_EMPTY) {
+		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
+			class->size, class->pages_per_zspage));
 		atomic_long_sub(class->pages_per_zspage,
 				&pool->pages_allocated);
+
 		free_zspage(first_page);
 	}
 }
-EXPORT_SYMBOL_GPL(zs_free);
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
+	int nr_to_migrate;
+	struct zs_compact_control cc;
+	struct page *src_page;
+	struct page *dst_page = NULL;
+	unsigned long nr_total_migrated = 0;
+
+	cond_resched();
+
+	spin_lock(&class->lock);
+	while ((src_page = isolate_source_page(class))) {
+
+		BUG_ON(!is_first_page(src_page));
+
+		/* The goal is to migrate all live objects in source page */
+		nr_to_migrate = src_page->inuse;
+		cc.index = 0;
+		cc.s_page = src_page;
+
+		while ((dst_page = alloc_target_page(class))) {
+			cc.d_page = dst_page;
+			/*
+			 * If there is no more space in dst_page, try to
+			 * allocate another zspage.
+			 */
+			if (!migrate_zspage(pool, class, &cc))
+				break;
+
+			putback_zspage(pool, class, dst_page);
+			nr_total_migrated += cc.nr_migrated;
+			nr_to_migrate -= cc.nr_migrated;
+		}
+
+		/* Stop if we couldn't find slot */
+		if (dst_page == NULL)
+			break;
+
+		putback_zspage(pool, class, dst_page);
+		putback_zspage(pool, class, src_page);
+		spin_unlock(&class->lock);
+		nr_total_migrated += cc.nr_migrated;
+		cond_resched();
+		spin_lock(&class->lock);
+	}
+
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
+	synchronize_rcu();
+
+	return nr_migrated;
+}
+EXPORT_SYMBOL_GPL(zs_compact);
 
 /**
  * zs_create_pool - Creates an allocation pool to work from.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
