Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 252E36B0265
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:10:54 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id td3so33024632pab.2
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:10:54 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id w88si4323558pfi.231.2016.03.30.00.10.39
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 00:10:39 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 08/16] zsmalloc: squeeze freelist into page->mapping
Date: Wed, 30 Mar 2016 16:12:07 +0900
Message-Id: <1459321935-3655-9-git-send-email-minchan@kernel.org>
In-Reply-To: <1459321935-3655-1-git-send-email-minchan@kernel.org>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

Zsmalloc stores first free object's position into first_page->freelist
in each zspage. If we change it with object index from first_page
instead of location, we could squeeze it into page->mapping because
the number of bit we need to store offset is at most 11bit.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 158 +++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 96 insertions(+), 62 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0f6cce9b9119..807998462539 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -18,9 +18,7 @@
  * Usage of struct page fields:
  *	page->private: points to the first component (0-order) page
  *	page->index (union with page->freelist): offset of the first object
- *		starting in this page. For the first page, this is
- *		always 0, so we use this field (aka freelist) to point
- *		to the first free object in zspage.
+ *		starting in this page.
  *	page->lru: links together all component pages (except the first page)
  *		of a zspage
  *
@@ -29,9 +27,6 @@
  *	page->private: refers to the component page after the first page
  *		If the page is first_page for huge object, it stores handle.
  *		Look at size_class->huge.
- *	page->freelist: points to the first free object in zspage.
- *		Free objects are linked together using in-place
- *		metadata.
  *	page->lru: links together first pages of various zspages.
  *		Basically forming list of zspages in a fullness group.
  *	page->mapping: override by struct zs_meta
@@ -131,6 +126,7 @@
 /* each chunk includes extra space to keep handle */
 #define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
 
+#define FREEOBJ_BITS 11
 #define CLASS_BITS	8
 #define CLASS_MASK	((1 << CLASS_BITS) - 1)
 #define FULLNESS_BITS	2
@@ -228,17 +224,17 @@ struct size_class {
 
 /*
  * Placed within free objects to form a singly linked list.
- * For every zspage, first_page->freelist gives head of this list.
+ * For every zspage, first_page->freeobj gives head of this list.
  *
  * This must be power of 2 and less than or equal to ZS_ALIGN
  */
 struct link_free {
 	union {
 		/*
-		 * Position of next free chunk (encodes <PFN, obj_idx>)
+		 * free object list
 		 * It's valid for non-allocated object
 		 */
-		void *next;
+		unsigned long next;
 		/*
 		 * Handle of allocated object.
 		 */
@@ -270,6 +266,7 @@ struct zs_pool {
 };
 
 struct zs_meta {
+	unsigned long freeobj:FREEOBJ_BITS;
 	unsigned long class:CLASS_BITS;
 	unsigned long fullness:FULLNESS_BITS;
 	unsigned long inuse:INUSE_BITS;
@@ -446,6 +443,26 @@ static void mod_zspage_inuse(struct page *first_page, int val)
 	m->inuse += val;
 }
 
+static void set_freeobj(struct page *first_page, int idx)
+{
+	struct zs_meta *m;
+
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+
+	m = (struct zs_meta *)&first_page->mapping;
+	m->freeobj = idx;
+}
+
+static unsigned long get_freeobj(struct page *first_page)
+{
+	struct zs_meta *m;
+
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+
+	m = (struct zs_meta *)&first_page->mapping;
+	return m->freeobj;
+}
+
 static void get_zspage_mapping(struct page *first_page,
 				unsigned int *class_idx,
 				enum fullness_group *fullness)
@@ -837,30 +854,33 @@ static struct page *get_next_page(struct page *page)
 	return next;
 }
 
-/*
- * Encode <page, obj_idx> as a single handle value.
- * We use the least bit of handle for tagging.
- */
-static void *location_to_obj(struct page *page, unsigned long obj_idx)
+static void objidx_to_page_and_offset(struct size_class *class,
+				struct page *first_page,
+				unsigned long obj_idx,
+				struct page **obj_page,
+				unsigned long *offset_in_page)
 {
-	unsigned long obj;
+	int i;
+	unsigned long offset;
+	struct page *cursor;
+	int nr_page;
 
-	if (!page) {
-		VM_BUG_ON(obj_idx);
-		return NULL;
-	}
+	offset = obj_idx * class->size;
+	cursor = first_page;
+	nr_page = offset >> PAGE_SHIFT;
 
-	obj = page_to_pfn(page) << OBJ_INDEX_BITS;
-	obj |= ((obj_idx) & OBJ_INDEX_MASK);
-	obj <<= OBJ_TAG_BITS;
+	*offset_in_page = offset & ~PAGE_MASK;
+
+	for (i = 0; i < nr_page; i++)
+		cursor = get_next_page(cursor);
 
-	return (void *)obj;
+	*obj_page = cursor;
 }
 
-/*
- * Decode <page, obj_idx> pair from the given object handle. We adjust the
- * decoded obj_idx back to its original value since it was adjusted in
- * location_to_obj().
+/**
+ * obj_to_location - get (<page>, <obj_idx>) from encoded object value
+ * @page: page object resides in zspage
+ * @obj_idx: object index
  */
 static void obj_to_location(unsigned long obj, struct page **page,
 				unsigned long *obj_idx)
@@ -870,6 +890,23 @@ static void obj_to_location(unsigned long obj, struct page **page,
 	*obj_idx = (obj & OBJ_INDEX_MASK);
 }
 
+/**
+ * location_to_obj - get obj value encoded from (<page>, <obj_idx>)
+ * @page: page object resides in zspage
+ * @obj_idx: object index
+ */
+static unsigned long location_to_obj(struct page *page,
+				unsigned long obj_idx)
+{
+	unsigned long obj;
+
+	obj = page_to_pfn(page) << OBJ_INDEX_BITS;
+	obj |= obj_idx & OBJ_INDEX_MASK;
+	obj <<= OBJ_TAG_BITS;
+
+	return obj;
+}
+
 static unsigned long handle_to_obj(unsigned long handle)
 {
 	return *(unsigned long *)handle;
@@ -885,17 +922,6 @@ static unsigned long obj_to_head(struct size_class *class, struct page *page,
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
@@ -952,6 +978,7 @@ static void free_zspage(struct page *first_page)
 /* Initialize a newly allocated zspage */
 static void init_zspage(struct size_class *class, struct page *first_page)
 {
+	int freeobj = 1;
 	unsigned long off = 0;
 	struct page *page = first_page;
 
@@ -960,14 +987,11 @@ static void init_zspage(struct size_class *class, struct page *first_page)
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
@@ -976,7 +1000,7 @@ static void init_zspage(struct size_class *class, struct page *first_page)
 		link = (struct link_free *)vaddr + off / sizeof(*link);
 
 		while ((off += class->size) < PAGE_SIZE) {
-			link->next = location_to_obj(page, i++);
+			link->next = freeobj++ << OBJ_ALLOCATED_TAG;
 			link += class->size / sizeof(*link);
 		}
 
@@ -986,11 +1010,21 @@ static void init_zspage(struct size_class *class, struct page *first_page)
 		 * page (if present)
 		 */
 		next_page = get_next_page(page);
-		link->next = location_to_obj(next_page, 0);
+		if (next_page) {
+			link->next = freeobj++ << OBJ_ALLOCATED_TAG;
+		} else {
+			/*
+			 * Reset OBJ_ALLOCATED_TAG bit to last link for
+			 * migration to know it is allocated object or not.
+			 */
+			link->next = -1 << OBJ_ALLOCATED_TAG;
+		}
 		kunmap_atomic(vaddr);
 		page = next_page;
 		off %= PAGE_SIZE;
 	}
+
+	set_freeobj(first_page, 0);
 }
 
 /*
@@ -1040,7 +1074,6 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 
 	init_zspage(class, first_page);
 
-	first_page->freelist = location_to_obj(first_page, 0);
 	error = 0; /* Success */
 
 cleanup:
@@ -1320,7 +1353,7 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	obj_to_location(obj, &page, &obj_idx);
 	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
 	class = pool->size_class[class_idx];
-	off = obj_idx_to_offset(page, obj_idx, class->size);
+	off = (class->size * obj_idx) & ~PAGE_MASK;
 
 	area = &get_cpu_var(zs_map_area);
 	area->vm_mm = mm;
@@ -1359,7 +1392,7 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	obj_to_location(obj, &page, &obj_idx);
 	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
 	class = pool->size_class[class_idx];
-	off = obj_idx_to_offset(page, obj_idx, class->size);
+	off = (class->size * obj_idx) & ~PAGE_MASK;
 
 	area = this_cpu_ptr(&zs_map_area);
 	if (off + class->size <= PAGE_SIZE)
@@ -1385,17 +1418,17 @@ static unsigned long obj_malloc(struct size_class *class,
 	struct link_free *link;
 
 	struct page *m_page;
-	unsigned long m_objidx, m_offset;
+	unsigned long m_offset;
 	void *vaddr;
 
 	handle |= OBJ_ALLOCATED_TAG;
-	obj = (unsigned long)first_page->freelist;
-	obj_to_location(obj, &m_page, &m_objidx);
-	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
+	obj = get_freeobj(first_page);
+	objidx_to_page_and_offset(class, first_page, obj,
+				&m_page, &m_offset);
 
 	vaddr = kmap_atomic(m_page);
 	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
-	first_page->freelist = link->next;
+	set_freeobj(first_page, link->next >> OBJ_ALLOCATED_TAG);
 	if (!class->huge)
 		/* record handle in the header of allocated chunk */
 		link->handle = handle;
@@ -1406,6 +1439,8 @@ static unsigned long obj_malloc(struct size_class *class,
 	mod_zspage_inuse(first_page, 1);
 	zs_stat_inc(class, OBJ_USED, 1);
 
+	obj = location_to_obj(m_page, obj);
+
 	return obj;
 }
 
@@ -1475,19 +1510,17 @@ static void obj_free(struct size_class *class, unsigned long obj)
 
 	obj &= ~OBJ_ALLOCATED_TAG;
 	obj_to_location(obj, &f_page, &f_objidx);
+	f_offset = (class->size * f_objidx) & ~PAGE_MASK;
 	first_page = get_first_page(f_page);
-
-	f_offset = obj_idx_to_offset(f_page, f_objidx, class->size);
-
 	vaddr = kmap_atomic(f_page);
 
 	/* Insert this object in containing zspage's freelist */
 	link = (struct link_free *)(vaddr + f_offset);
-	link->next = first_page->freelist;
+	link->next = get_freeobj(first_page) << OBJ_ALLOCATED_TAG;
 	if (class->huge)
 		set_page_private(first_page, 0);
 	kunmap_atomic(vaddr);
-	first_page->freelist = (void *)obj;
+	set_freeobj(first_page, f_objidx);
 	mod_zspage_inuse(first_page, -1);
 	zs_stat_dec(class, OBJ_USED, 1);
 }
@@ -1543,8 +1576,8 @@ static void zs_object_copy(struct size_class *class, unsigned long dst,
 	obj_to_location(src, &s_page, &s_objidx);
 	obj_to_location(dst, &d_page, &d_objidx);
 
-	s_off = obj_idx_to_offset(s_page, s_objidx, class->size);
-	d_off = obj_idx_to_offset(d_page, d_objidx, class->size);
+	s_off = (class->size * s_objidx) & ~PAGE_MASK;
+	d_off = (class->size * d_objidx) & ~PAGE_MASK;
 
 	if (s_off + class->size > PAGE_SIZE)
 		s_size = PAGE_SIZE - s_off;
@@ -2034,9 +2067,10 @@ static int __init zs_init(void)
 		goto notifier_fail;
 
 	/*
-	 * A zspage's class index, fullness group, inuse object count are
-	 * encoded in its (first)page->mapping so sizeof(struct zs_meta)
-	 * should be less than sizeof(page->mapping(i.e., unsigned long)).
+	 * A zspage's a free object index, class index, fullness group,
+	 * inuse object count are encoded in its (first)page->mapping
+	 * so sizeof(struct zs_meta) should be less than
+	 * sizeof(page->mapping(i.e., unsigned long)).
 	 */
 	BUILD_BUG_ON(sizeof(struct zs_meta) > sizeof(unsigned long));
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
