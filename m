Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 57A506B0262
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 03:47:30 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id dx6so56971342pad.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 00:47:30 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id sg7si3943411pac.221.2016.04.27.00.47.27
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 00:47:27 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 06/12] zsmalloc: use accessor
Date: Wed, 27 Apr 2016 16:48:19 +0900
Message-Id: <1461743305-19970-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1461743305-19970-1-git-send-email-minchan@kernel.org>
References: <1461743305-19970-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Upcoming patch will change how to encode zspage meta so for easy review,
this patch wraps code to access metadata as accessor.

Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 82 +++++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 60 insertions(+), 22 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index d75d9e4b6a4d..8c22b0ca1df7 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -267,10 +267,14 @@ struct zs_pool {
  * A zspage's class index and fullness group
  * are encoded in its (first)page->mapping
  */
-#define CLASS_IDX_BITS	28
 #define FULLNESS_BITS	4
-#define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
-#define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
+#define CLASS_BITS	28
+
+#define FULLNESS_SHIFT	0
+#define CLASS_SHIFT	(FULLNESS_SHIFT + FULLNESS_BITS)
+
+#define FULLNESS_MASK	((1UL << FULLNESS_BITS) - 1)
+#define CLASS_MASK	((1UL << CLASS_BITS) - 1)
 
 struct mapping_area {
 #ifdef CONFIG_PGTABLE_MAPPING
@@ -412,6 +416,41 @@ static int is_last_page(struct page *page)
 	return PagePrivate2(page);
 }
 
+static inline int get_zspage_inuse(struct page *first_page)
+{
+	return first_page->inuse;
+}
+
+static inline void set_zspage_inuse(struct page *first_page, int val)
+{
+	first_page->inuse = val;
+}
+
+static inline void mod_zspage_inuse(struct page *first_page, int val)
+{
+	first_page->inuse += val;
+}
+
+static inline int get_first_obj_offset(struct page *page)
+{
+	return page->index;
+}
+
+static inline void set_first_obj_offset(struct page *page, int offset)
+{
+	page->index = offset;
+}
+
+static inline unsigned long get_freeobj(struct page *first_page)
+{
+	return (unsigned long)first_page->freelist;
+}
+
+static inline void set_freeobj(struct page *first_page, unsigned long obj)
+{
+	first_page->freelist = (void *)obj;
+}
+
 static void get_zspage_mapping(struct page *first_page,
 				unsigned int *class_idx,
 				enum fullness_group *fullness)
@@ -420,8 +459,8 @@ static void get_zspage_mapping(struct page *first_page,
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
 	m = (unsigned long)first_page->mapping;
-	*fullness = m & FULLNESS_MASK;
-	*class_idx = (m >> FULLNESS_BITS) & CLASS_IDX_MASK;
+	*fullness = (m >> FULLNESS_SHIFT) & FULLNESS_MASK;
+	*class_idx = (m >> CLASS_SHIFT) & CLASS_MASK;
 }
 
 static void set_zspage_mapping(struct page *first_page,
@@ -431,8 +470,7 @@ static void set_zspage_mapping(struct page *first_page,
 	unsigned long m;
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
-	m = ((class_idx & CLASS_IDX_MASK) << FULLNESS_BITS) |
-			(fullness & FULLNESS_MASK);
+	m = (class_idx << CLASS_SHIFT) | (fullness << FULLNESS_SHIFT);
 	first_page->mapping = (struct address_space *)m;
 }
 
@@ -634,7 +672,7 @@ static enum fullness_group get_fullness_group(struct size_class *class,
 
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
-	inuse = first_page->inuse;
+	inuse = get_zspage_inuse(first_page);
 	objs_per_zspage = class->objs_per_zspage;
 
 	if (inuse == 0)
@@ -680,7 +718,7 @@ static void insert_zspage(struct size_class *class,
 	 * empty/full. Put pages with higher ->inuse first.
 	 */
 	list_add_tail(&first_page->lru, &(*head)->lru);
-	if (first_page->inuse >= (*head)->inuse)
+	if (get_zspage_inuse(first_page) >= get_zspage_inuse(*head))
 		*head = first_page;
 }
 
@@ -857,7 +895,7 @@ static unsigned long obj_idx_to_offset(struct page *page,
 	unsigned long off = 0;
 
 	if (!is_first_page(page))
-		off = page->index;
+		off = get_first_obj_offset(page);
 
 	return off + obj_idx * class_size;
 }
@@ -892,7 +930,7 @@ static void free_zspage(struct page *first_page)
 	struct page *nextp, *tmp, *head_extra;
 
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
-	VM_BUG_ON_PAGE(first_page->inuse, first_page);
+	VM_BUG_ON_PAGE(get_zspage_inuse(first_page), first_page);
 
 	head_extra = (struct page *)page_private(first_page);
 
@@ -933,7 +971,7 @@ static void init_zspage(struct size_class *class, struct page *first_page)
 		 * head of corresponding zspage's freelist.
 		 */
 		if (page != first_page)
-			page->index = off;
+			set_first_obj_offset(page, off);
 
 		vaddr = kmap_atomic(page);
 		link = (struct link_free *)vaddr + off / sizeof(*link);
@@ -988,7 +1026,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 			SetPagePrivate(page);
 			set_page_private(page, 0);
 			first_page = page;
-			first_page->inuse = 0;
+			set_zspage_inuse(first_page, 0);
 		}
 		if (i == 1)
 			set_page_private(first_page, (unsigned long)page);
@@ -1003,7 +1041,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 
 	init_zspage(class, first_page);
 
-	first_page->freelist = location_to_obj(first_page, 0);
+	set_freeobj(first_page,	(unsigned long)location_to_obj(first_page, 0));
 	error = 0; /* Success */
 
 cleanup:
@@ -1235,7 +1273,7 @@ static bool zspage_full(struct size_class *class, struct page *first_page)
 {
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
-	return first_page->inuse == class->objs_per_zspage;
+	return get_zspage_inuse(first_page) == class->objs_per_zspage;
 }
 
 unsigned long zs_get_total_pages(struct zs_pool *pool)
@@ -1354,13 +1392,13 @@ static unsigned long obj_malloc(struct size_class *class,
 	void *vaddr;
 
 	handle |= OBJ_ALLOCATED_TAG;
-	obj = (unsigned long)first_page->freelist;
+	obj = get_freeobj(first_page);
 	obj_to_location(obj, &m_page, &m_objidx);
 	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
 
 	vaddr = kmap_atomic(m_page);
 	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
-	first_page->freelist = link->next;
+	set_freeobj(first_page, (unsigned long)link->next);
 	if (!class->huge)
 		/* record handle in the header of allocated chunk */
 		link->handle = handle;
@@ -1368,7 +1406,7 @@ static unsigned long obj_malloc(struct size_class *class,
 		/* record handle in first_page->private */
 		set_page_private(first_page, handle);
 	kunmap_atomic(vaddr);
-	first_page->inuse++;
+	mod_zspage_inuse(first_page, 1);
 	zs_stat_inc(class, OBJ_USED, 1);
 
 	return obj;
@@ -1448,12 +1486,12 @@ static void obj_free(struct size_class *class, unsigned long obj)
 
 	/* Insert this object in containing zspage's freelist */
 	link = (struct link_free *)(vaddr + f_offset);
-	link->next = first_page->freelist;
+	link->next = (void *)get_freeobj(first_page);
 	if (class->huge)
 		set_page_private(first_page, 0);
 	kunmap_atomic(vaddr);
-	first_page->freelist = (void *)obj;
-	first_page->inuse--;
+	set_freeobj(first_page, obj);
+	mod_zspage_inuse(first_page, -1);
 	zs_stat_dec(class, OBJ_USED, 1);
 }
 
@@ -1569,7 +1607,7 @@ static unsigned long find_alloced_obj(struct size_class *class,
 	void *addr = kmap_atomic(page);
 
 	if (!is_first_page(page))
-		offset = page->index;
+		offset = get_first_obj_offset(page);
 	offset += class->size * index;
 
 	while (offset < PAGE_SIZE) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
