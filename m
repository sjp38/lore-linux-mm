Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id AD8B86B025E
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 02:30:11 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id u190so254106639pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 23:30:11 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id e72si3941073pfb.126.2016.03.20.23.30.06
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 23:30:07 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 03/18] zsmalloc: clean up many BUG_ON
Date: Mon, 21 Mar 2016 15:30:52 +0900
Message-Id: <1458541867-27380-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1458541867-27380-1-git-send-email-minchan@kernel.org>
References: <1458541867-27380-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

There are many BUG_ON in zsmalloc.c which is not recommened so
change them as alternatives.

Normal rule is as follows:

1. avoid BUG_ON if possible. Instead, use VM_BUG_ON or VM_BUG_ON_PAGE
2. use VM_BUG_ON_PAGE if we need to see struct page's fields
3. use those assertion in primitive functions so higher functions
can rely on the assertion in the primitive function.
4. Don't use assertion if following instruction can trigger Oops

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 42 +++++++++++++++---------------------------
 1 file changed, 15 insertions(+), 27 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b09a80d398c9..6a7b9313ee8c 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -418,7 +418,7 @@ static void get_zspage_mapping(struct page *first_page,
 				enum fullness_group *fullness)
 {
 	unsigned long m;
-	BUG_ON(!is_first_page(first_page));
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
 	m = (unsigned long)first_page->mapping;
 	*fullness = m & FULLNESS_MASK;
@@ -430,7 +430,7 @@ static void set_zspage_mapping(struct page *first_page,
 				enum fullness_group fullness)
 {
 	unsigned long m;
-	BUG_ON(!is_first_page(first_page));
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
 	m = ((class_idx & CLASS_IDX_MASK) << FULLNESS_BITS) |
 			(fullness & FULLNESS_MASK);
@@ -631,7 +631,8 @@ static enum fullness_group get_fullness_group(struct page *first_page)
 {
 	int inuse, max_objects;
 	enum fullness_group fg;
-	BUG_ON(!is_first_page(first_page));
+
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
 	inuse = first_page->inuse;
 	max_objects = first_page->objects;
@@ -659,7 +660,7 @@ static void insert_zspage(struct page *first_page, struct size_class *class,
 {
 	struct page **head;
 
-	BUG_ON(!is_first_page(first_page));
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
 	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
 		return;
@@ -691,13 +692,13 @@ static void remove_zspage(struct page *first_page, struct size_class *class,
 {
 	struct page **head;
 
-	BUG_ON(!is_first_page(first_page));
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
 	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
 		return;
 
 	head = &class->fullness_list[fullness];
-	BUG_ON(!*head);
+	VM_BUG_ON_PAGE(!*head, first_page);
 	if (list_empty(&(*head)->lru))
 		*head = NULL;
 	else if (*head == first_page)
@@ -724,8 +725,6 @@ static enum fullness_group fix_fullness_group(struct size_class *class,
 	int class_idx;
 	enum fullness_group currfg, newfg;
 
-	BUG_ON(!is_first_page(first_page));
-
 	get_zspage_mapping(first_page, &class_idx, &currfg);
 	newfg = get_fullness_group(first_page);
 	if (newfg == currfg)
@@ -811,7 +810,7 @@ static void *location_to_obj(struct page *page, unsigned long obj_idx)
 	unsigned long obj;
 
 	if (!page) {
-		BUG_ON(obj_idx);
+		VM_BUG_ON(obj_idx);
 		return NULL;
 	}
 
@@ -844,7 +843,7 @@ static unsigned long obj_to_head(struct size_class *class, struct page *page,
 			void *obj)
 {
 	if (class->huge) {
-		VM_BUG_ON(!is_first_page(page));
+		VM_BUG_ON_PAGE(!is_first_page(page), page);
 		return page_private(page);
 	} else
 		return *(unsigned long *)obj;
@@ -894,8 +893,8 @@ static void free_zspage(struct page *first_page)
 {
 	struct page *nextp, *tmp, *head_extra;
 
-	BUG_ON(!is_first_page(first_page));
-	BUG_ON(first_page->inuse);
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+	VM_BUG_ON_PAGE(first_page->inuse, first_page);
 
 	head_extra = (struct page *)page_private(first_page);
 
@@ -921,7 +920,8 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 	unsigned long off = 0;
 	struct page *page = first_page;
 
-	BUG_ON(!is_first_page(first_page));
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+
 	while (page) {
 		struct page *next_page;
 		struct link_free *link;
@@ -1238,7 +1238,7 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
 
 static bool zspage_full(struct page *first_page)
 {
-	BUG_ON(!is_first_page(first_page));
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
 	return first_page->inuse == first_page->objects;
 }
@@ -1276,14 +1276,12 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	struct page *pages[2];
 	void *ret;
 
-	BUG_ON(!handle);
-
 	/*
 	 * Because we use per-cpu mapping areas shared among the
 	 * pools/users, we can't allow mapping in interrupt context
 	 * because it can corrupt another users mappings.
 	 */
-	BUG_ON(in_interrupt());
+	WARN_ON_ONCE(in_interrupt());
 
 	/* From now on, migration cannot move the object */
 	pin_tag(handle);
@@ -1327,8 +1325,6 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	struct size_class *class;
 	struct mapping_area *area;
 
-	BUG_ON(!handle);
-
 	obj = handle_to_obj(handle);
 	obj_to_location(obj, &page, &obj_idx);
 	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
@@ -1448,8 +1444,6 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
 	unsigned long f_objidx, f_offset;
 	void *vaddr;
 
-	BUG_ON(!obj);
-
 	obj &= ~OBJ_ALLOCATED_TAG;
 	obj_to_location(obj, &f_page, &f_objidx);
 	first_page = get_first_page(f_page);
@@ -1549,7 +1543,6 @@ static void zs_object_copy(unsigned long dst, unsigned long src,
 			kunmap_atomic(d_addr);
 			kunmap_atomic(s_addr);
 			s_page = get_next_page(s_page);
-			BUG_ON(!s_page);
 			s_addr = kmap_atomic(s_page);
 			d_addr = kmap_atomic(d_page);
 			s_size = class->size - written;
@@ -1559,7 +1552,6 @@ static void zs_object_copy(unsigned long dst, unsigned long src,
 		if (d_off >= PAGE_SIZE) {
 			kunmap_atomic(d_addr);
 			d_page = get_next_page(d_page);
-			BUG_ON(!d_page);
 			d_addr = kmap_atomic(d_page);
 			d_size = class->size - written;
 			d_off = 0;
@@ -1694,8 +1686,6 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 {
 	enum fullness_group fullness;
 
-	BUG_ON(!is_first_page(first_page));
-
 	fullness = get_fullness_group(first_page);
 	insert_zspage(first_page, class, fullness);
 	set_zspage_mapping(first_page, class->index, fullness);
@@ -1756,8 +1746,6 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 	spin_lock(&class->lock);
 	while ((src_page = isolate_source_page(class))) {
 
-		BUG_ON(!is_first_page(src_page));
-
 		if (!zs_can_compact(class))
 			break;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
