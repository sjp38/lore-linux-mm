Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1D31A6B0257
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 03:12:46 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so100311545pab.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 00:12:45 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id df1si31753089pad.84.2015.08.10.00.12.33
        for <linux-mm@kvack.org>;
        Mon, 10 Aug 2015 00:12:35 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC zsmalloc 3/4] zsmalloc: squeeze freelist into page->mapping
Date: Mon, 10 Aug 2015 16:12:22 +0900
Message-Id: <1439190743-13933-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1439190743-13933-1-git-send-email-minchan@kernel.org>
References: <1439190743-13933-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: gioh.kim@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Zsmalloc stores free object's position into first_page's freelist
in each zspage. If we change it with object offset from first_page
instead of free object's location, we could squeeze it into page->
mapping because the number of bit we need to store it is at most
11bit.

For example, 64K page system, class_size 32, in this case
class->pages_per_zspage is 1 so max_objects is 2048.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 232 ++++++++++++++++++++++++++++++----------------------------
 1 file changed, 122 insertions(+), 110 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 75fefba..55dc066 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -18,9 +18,7 @@
  * Usage of struct page fields:
  *	page->first_page: points to the first component (0-order) page
  *	page->index (union with page->freelist): offset of the first object
- *		starting in this page. For the first page, this is
- *		always 0, so we use this field (aka freelist) to point
- *		to the first free object in zspage.
+ *		starting in this page.
  *	page->lru: links together all component pages (except the first page)
  *		of a zspage
  *
@@ -30,9 +28,6 @@
  *		component page after the first page
  *		If the page is first_page for huge object, it stores handle.
  *		Look at size_class->huge.
- *	page->freelist: points to the first free object in zspage.
- *		Free objects are linked together using in-place
- *		metadata.
  *	page->lru: links together first pages of various zspages.
  *		Basically forming list of zspages in a fullness group.
  *	page->mapping: override by struct zs_meta
@@ -132,14 +127,16 @@
 /* each chunk includes extra space to keep handle */
 #define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
 
+#define FREE_OBJ_IDX_BITS 11
+#define FREE_OBJ_IDX_MASK ((1 << FREE_OBJ_IDX_BITS) - 1)
 #define CLASS_IDX_BITS	8
 #define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
 #define FULLNESS_BITS	2
 #define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
 #define INUSE_BITS	11
 #define INUSE_MASK	((1 << INUSE_BITS) - 1)
-#define ETC_BITS	((sizeof(unsigned long) * 8) - CLASS_IDX_BITS \
-				- FULLNESS_BITS - INUSE_BITS)
+#define ETC_BITS	((sizeof(unsigned long) * 8) - FREE_OBJ_IDX_BITS - \
+			CLASS_IDX_BITS - FULLNESS_BITS - INUSE_BITS)
 /*
  * On systems with 4K page size, this gives 255 size classes! There is a
  * trader-off here:
@@ -224,17 +221,14 @@ struct size_class {
 
 /*
  * Placed within free objects to form a singly linked list.
- * For every zspage, first_page->freelist gives head of this list.
+ * For every zspage, first_page->free_obj_idx gives head of this list.
  *
  * This must be power of 2 and less than or equal to ZS_ALIGN
  */
 struct link_free {
 	union {
-		/*
-		 * Position of next free chunk (encodes <PFN, obj_idx>)
-		 * It's valid for non-allocated object
-		 */
-		void *next;
+		/* Next free object index from first page */
+		unsigned long next;
 		/*
 		 * Handle of allocated object.
 		 */
@@ -266,11 +260,12 @@ struct zs_pool {
 };
 
 /*
- * In this implementation, a zspage's class index, fullness group,
+ * In this implementation, a free_idx, zspage's class index, fullness group,
  * inuse object count are encoded in its (first)page->mapping
  * sizeof(struct zs_meta) should be equal to sizeof(unsigned long).
  */
 struct zs_meta {
+	unsigned long free_idx:FREE_OBJ_IDX_BITS;
 	unsigned long class_idx:CLASS_IDX_BITS;
 	unsigned long fullness:FULLNESS_BITS;
 	unsigned long inuse:INUSE_BITS;
@@ -434,6 +429,18 @@ static void set_inuse_obj(struct page *page, int inc)
 	m->inuse += inc;
 }
 
+static void set_free_obj_idx(struct page *first_page, int idx)
+{
+	struct zs_meta *m = (struct zs_meta *)&first_page->mapping;
+	m->free_idx = idx;
+}
+
+static unsigned long get_free_obj_idx(struct page *first_page)
+{
+	struct zs_meta *m = (struct zs_meta *)&first_page->mapping;
+	return m->free_idx;
+}
+
 static void get_zspage_mapping(struct page *page, unsigned int *class_idx,
 				enum fullness_group *fullness)
 {
@@ -816,37 +823,50 @@ static struct page *get_next_page(struct page *page)
 	return next;
 }
 
-/*
- * Encode <page, obj_idx> as a single handle value.
- * We use the least bit of handle for tagging.
- */
-static void *location_to_obj(struct page *page, unsigned long obj_idx)
+static void obj_idx_to_location(struct size_class *class, struct page *first_page,
+				unsigned long obj_idx, struct page **obj_page,
+				unsigned long *ofs_in_page)
 {
-	unsigned long obj;
+	int i;
+	unsigned long ofs;
+	struct page *cursor;
+	int nr_page;
 
-	if (!page) {
-		BUG_ON(obj_idx);
-		return NULL;
-	}
+	BUG_ON(!is_first_page(first_page));
 
-	obj = page_to_pfn(page) << OBJ_INDEX_BITS;
-	obj |= ((obj_idx) & OBJ_INDEX_MASK);
-	obj <<= OBJ_TAG_BITS;
+	ofs = obj_idx * class->size;
+	cursor = first_page;
+	nr_page = ofs / PAGE_SIZE;
 
-	return (void *)obj;
+	*ofs_in_page = ofs % PAGE_SIZE;
+
+	for ( i = 0; i < nr_page; i++)
+		cursor = get_next_page(cursor);
+
+	*obj_page = cursor;
 }
 
-/*
- * Decode <page, obj_idx> pair from the given object handle. We adjust the
- * decoded obj_idx back to its original value since it was adjusted in
- * location_to_obj().
- */
-static void obj_to_location(unsigned long obj, struct page **page,
+
+static void obj_to_obj_idx(unsigned long obj, struct page **obj_page,
 				unsigned long *obj_idx)
 {
 	obj >>= OBJ_TAG_BITS;
-	*page = pfn_to_page(obj >> OBJ_INDEX_BITS);
-	*obj_idx = (obj & OBJ_INDEX_MASK);
+	*obj_idx = obj & OBJ_INDEX_MASK;
+
+	obj >>= OBJ_INDEX_BITS;
+	*obj_page = pfn_to_page(obj);
+}
+
+static unsigned long obj_idx_to_obj(struct page *obj_page,
+				unsigned long obj_idx)
+{
+	unsigned long obj;
+
+	obj = page_to_pfn(obj_page) << OBJ_INDEX_BITS;
+	obj |= ((obj_idx) & OBJ_INDEX_MASK);
+	obj <<= OBJ_TAG_BITS;
+
+	return obj;
 }
 
 static unsigned long handle_to_obj(unsigned long handle)
@@ -864,17 +884,6 @@ static unsigned long obj_to_head(struct size_class *class, struct page *page,
 		return *(unsigned long *)obj;
 }
 
-static unsigned long obj_idx_to_offset(struct page *page,
-				unsigned long obj_idx, int class_size)
-{
-	unsigned long off = 0;
-
-	if (!is_first_page(page))
-		off = page->index;
-
-	return off + obj_idx * class_size;
-}
-
 static inline int trypin_tag(unsigned long handle)
 {
 	unsigned long *ptr = (unsigned long *)handle;
@@ -900,7 +909,6 @@ static void reset_page(struct page *page)
 	clear_bit(PG_private_2, &page->flags);
 	set_page_private(page, 0);
 	page->mapping = NULL;
-	page->freelist = NULL;
 	page_mapcount_reset(page);
 }
 
@@ -932,6 +940,7 @@ static void free_zspage(struct page *first_page)
 /* Initialize a newly allocated zspage */
 static void init_zspage(struct page *first_page, struct size_class *class)
 {
+	int obj_idx = 1;
 	unsigned long off = 0;
 	struct page *page = first_page;
 
@@ -939,14 +948,11 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 	while (page) {
 		struct page *next_page;
 		struct link_free *link;
-		unsigned int i = 1;
 		void *vaddr;
 
 		/*
 		 * page->index stores offset of first object starting
-		 * in the page. For the first page, this is always 0,
-		 * so we use first_page->index (aka ->freelist) to store
-		 * head of corresponding zspage's freelist.
+		 * in the page.
 		 */
 		if (page != first_page)
 			page->index = off;
@@ -955,7 +961,7 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 		link = (struct link_free *)vaddr + off / sizeof(*link);
 
 		while ((off += class->size) < PAGE_SIZE) {
-			link->next = location_to_obj(page, i++);
+			link->next = (obj_idx++ << OBJ_ALLOCATED_TAG);
 			link += class->size / sizeof(*link);
 		}
 
@@ -965,11 +971,16 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 		 * page (if present)
 		 */
 		next_page = get_next_page(page);
-		link->next = location_to_obj(next_page, 0);
+		if (next_page)
+			link->next = (obj_idx++ << OBJ_ALLOCATED_TAG);
+		else
+			link->next = (-1 << OBJ_ALLOCATED_TAG);
 		kunmap_atomic(vaddr);
 		page = next_page;
 		off %= PAGE_SIZE;
 	}
+
+	set_free_obj_idx(first_page, 0);
 }
 
 /*
@@ -1019,7 +1030,6 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 
 	init_zspage(first_page, class);
 
-	first_page->freelist = location_to_obj(first_page, 0);
 	error = 0; /* Success */
 
 cleanup:
@@ -1279,8 +1289,8 @@ EXPORT_SYMBOL_GPL(zs_get_total_pages);
 void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 			enum zs_mapmode mm)
 {
-	struct page *page;
-	unsigned long obj, obj_idx, off;
+	struct page *obj_page, *first_page;
+	unsigned long obj, obj_idx, obj_ofs;
 
 	unsigned int class_idx;
 	enum fullness_group fg;
@@ -1302,26 +1312,29 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	pin_tag(handle);
 
 	obj = handle_to_obj(handle);
-	obj_to_location(obj, &page, &obj_idx);
-	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
+	obj_to_obj_idx(obj, &obj_page, &obj_idx);
+
+	first_page = get_first_page(obj_page);
+	get_zspage_mapping(first_page, &class_idx, &fg);
+
 	class = pool->size_class[class_idx];
-	off = obj_idx_to_offset(page, obj_idx, class->size);
+	obj_ofs = (class->size * obj_idx) % PAGE_SIZE;
 
 	area = &get_cpu_var(zs_map_area);
 	area->vm_mm = mm;
-	if (off + class->size <= PAGE_SIZE) {
+	if (obj_ofs + class->size <= PAGE_SIZE) {
 		/* this object is contained entirely within a page */
-		area->vm_addr = kmap_atomic(page);
-		ret = area->vm_addr + off;
+		area->vm_addr = kmap_atomic(obj_page);
+		ret = area->vm_addr + obj_ofs;
 		goto out;
 	}
 
 	/* this object spans two pages */
-	pages[0] = page;
-	pages[1] = get_next_page(page);
+	pages[0] = obj_page;
+	pages[1] = get_next_page(obj_page);
 	BUG_ON(!pages[1]);
 
-	ret = __zs_map_object(area, pages, off, class->size);
+	ret = __zs_map_object(area, pages, obj_ofs, class->size);
 out:
 	if (!class->huge)
 		ret += ZS_HANDLE_SIZE;
@@ -1332,8 +1345,8 @@ EXPORT_SYMBOL_GPL(zs_map_object);
 
 void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 {
-	struct page *page;
-	unsigned long obj, obj_idx, off;
+	struct page *obj_page, *first_page;
+	unsigned long obj, obj_idx, obj_ofs;
 
 	unsigned int class_idx;
 	enum fullness_group fg;
@@ -1343,22 +1356,24 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	BUG_ON(!handle);
 
 	obj = handle_to_obj(handle);
-	obj_to_location(obj, &page, &obj_idx);
-	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
+
+	obj_to_obj_idx(obj, &obj_page, &obj_idx);
+	first_page = get_first_page(obj_page);
+	get_zspage_mapping(first_page, &class_idx, &fg);
 	class = pool->size_class[class_idx];
-	off = obj_idx_to_offset(page, obj_idx, class->size);
+	obj_ofs = (class->size * obj_idx) % PAGE_SIZE;
 
 	area = this_cpu_ptr(&zs_map_area);
-	if (off + class->size <= PAGE_SIZE)
+	if (obj_ofs + class->size <= PAGE_SIZE)
 		kunmap_atomic(area->vm_addr);
 	else {
 		struct page *pages[2];
 
-		pages[0] = page;
-		pages[1] = get_next_page(page);
+		pages[0] = obj_page;
+		pages[1] = get_next_page(obj_page);
 		BUG_ON(!pages[1]);
 
-		__zs_unmap_object(area, pages, off, class->size);
+		__zs_unmap_object(area, pages, obj_ofs, class->size);
 	}
 	put_cpu_var(zs_map_area);
 	unpin_tag(handle);
@@ -1368,21 +1383,20 @@ EXPORT_SYMBOL_GPL(zs_unmap_object);
 static unsigned long obj_malloc(struct page *first_page,
 		struct size_class *class, unsigned long handle)
 {
-	unsigned long obj;
+	unsigned long obj_idx, obj;
 	struct link_free *link;
 
-	struct page *m_page;
-	unsigned long m_objidx, m_offset;
+	struct page *obj_page;
+	unsigned long obj_ofs;
 	void *vaddr;
 
 	handle |= OBJ_ALLOCATED_TAG;
-	obj = (unsigned long)first_page->freelist;
-	obj_to_location(obj, &m_page, &m_objidx);
-	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
+	obj_idx = get_free_obj_idx(first_page);
+	obj_idx_to_location(class, first_page, obj_idx, &obj_page, &obj_ofs);
 
-	vaddr = kmap_atomic(m_page);
-	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
-	first_page->freelist = link->next;
+	vaddr = kmap_atomic(obj_page);
+	link = (struct link_free *)vaddr + obj_ofs / sizeof(*link);
+	set_free_obj_idx(first_page, link->next >> OBJ_ALLOCATED_TAG);
 	if (!class->huge)
 		/* record handle in the header of allocated chunk */
 		link->handle = handle;
@@ -1393,6 +1407,8 @@ static unsigned long obj_malloc(struct page *first_page,
 	set_inuse_obj(first_page, 1);
 	zs_stat_inc(class, OBJ_USED, 1);
 
+	obj = obj_idx_to_obj(obj_page, obj_idx);
+
 	return obj;
 }
 
@@ -1457,38 +1473,34 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
 			unsigned long obj)
 {
 	struct link_free *link;
-	struct page *first_page, *f_page;
-	unsigned long f_objidx, f_offset;
+	struct page *first_page, *obj_page;
+	unsigned long obj_idx, obj_ofs;
 	void *vaddr;
-	int class_idx;
-	enum fullness_group fullness;
 
 	BUG_ON(!obj);
 
-	obj &= ~OBJ_ALLOCATED_TAG;
-	obj_to_location(obj, &f_page, &f_objidx);
-	first_page = get_first_page(f_page);
+	obj_to_obj_idx(obj, &obj_page, &obj_idx);
+	obj_ofs = (class->size * obj_idx) % PAGE_SIZE;
+	first_page = get_first_page(obj_page);
 
-	get_zspage_mapping(first_page, &class_idx, &fullness);
-	f_offset = obj_idx_to_offset(f_page, f_objidx, class->size);
-
-	vaddr = kmap_atomic(f_page);
+	vaddr = kmap_atomic(obj_page);
 
 	/* Insert this object in containing zspage's freelist */
-	link = (struct link_free *)(vaddr + f_offset);
-	link->next = first_page->freelist;
+	link = (struct link_free *)(vaddr + obj_ofs);
+	link->next = get_free_obj_idx(first_page) << OBJ_ALLOCATED_TAG;
 	if (class->huge)
 		set_page_private(first_page, 0);
 	kunmap_atomic(vaddr);
-	first_page->freelist = (void *)obj;
+	set_free_obj_idx(first_page, obj_idx);
 	set_inuse_obj(first_page, -1);
 	zs_stat_dec(class, OBJ_USED, 1);
+
 }
 
 void zs_free(struct zs_pool *pool, unsigned long handle)
 {
-	struct page *first_page, *f_page;
-	unsigned long obj, f_objidx;
+	struct page *first_page, *obj_page;
+	unsigned long obj, obj_idx;
 	int class_idx;
 	struct size_class *class;
 	enum fullness_group fullness;
@@ -1498,9 +1510,9 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 
 	pin_tag(handle);
 	obj = handle_to_obj(handle);
-	obj_to_location(obj, &f_page, &f_objidx);
-	first_page = get_first_page(f_page);
 
+	obj_to_obj_idx(obj, &obj_page, &obj_idx);
+	first_page = get_first_page(obj_page);
 	get_zspage_mapping(first_page, &class_idx, &fullness);
 	class = pool->size_class[class_idx];
 
@@ -1521,7 +1533,7 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
-static void zs_object_copy(unsigned long dst, unsigned long src,
+static void zs_object_copy(unsigned long dst_obj, unsigned long src_obj,
 				struct size_class *class)
 {
 	struct page *s_page, *d_page;
@@ -1533,11 +1545,11 @@ static void zs_object_copy(unsigned long dst, unsigned long src,
 
 	s_size = d_size = class->size;
 
-	obj_to_location(src, &s_page, &s_objidx);
-	obj_to_location(dst, &d_page, &d_objidx);
+	obj_to_obj_idx(src_obj, &s_page, &s_objidx);
+	obj_to_obj_idx(dst_obj, &d_page, &d_objidx);
 
-	s_off = obj_idx_to_offset(s_page, s_objidx, class->size);
-	d_off = obj_idx_to_offset(d_page, d_objidx, class->size);
+	s_off = (class->size * s_objidx) % PAGE_SIZE;
+	d_off = (class->size * d_objidx) % PAGE_SIZE;
 
 	if (s_off + class->size > PAGE_SIZE)
 		s_size = PAGE_SIZE - s_off;
@@ -2028,8 +2040,8 @@ static int __init zs_init(void)
 	if (ret)
 		goto notifier_fail;
 
-	BUILD_BUG_ON(sizeof(unsigned long) * 8 < (CLASS_IDX_BITS + \
-			FULLNESS_BITS + INUSE_BITS + ETC_BITS));
+	BUILD_BUG_ON(sizeof(unsigned long) * 8 < (FREE_OBJ_IDX_BITS + \
+		CLASS_IDX_BITS + FULLNESS_BITS + INUSE_BITS + ETC_BITS));
 
 	init_zs_size_classes();
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
