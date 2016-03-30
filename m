Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 66F646B026C
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:11:03 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id 4so34913452pfd.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:11:03 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id v71si4414320pfi.22.2016.03.30.00.10.41
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 00:10:42 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 12/16] zsmalloc: zs_compact refactoring
Date: Wed, 30 Mar 2016 16:12:11 +0900
Message-Id: <1459321935-3655-13-git-send-email-minchan@kernel.org>
In-Reply-To: <1459321935-3655-1-git-send-email-minchan@kernel.org>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

Currently, we rely on class->lock to prevent zspage destruction.
It was okay until now because the critical section is short but
with run-time migration, it could be long so class->lock is not
a good apporach any more.

So, this patch introduces [un]freeze_zspage functions which
freeze allocated objects in the zspage with pinning tag so
user cannot free using object. With those functions, this patch
redesign compaction.

Those functions will be used for implementing zspage runtime
migrations, too.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 393 ++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 257 insertions(+), 136 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b11dcd718502..ac8ca7b10720 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -922,6 +922,13 @@ static unsigned long obj_to_head(struct size_class *class, struct page *page,
 		return *(unsigned long *)obj;
 }
 
+static inline int testpin_tag(unsigned long handle)
+{
+	unsigned long *ptr = (unsigned long *)handle;
+
+	return test_bit(HANDLE_PIN_BIT, ptr);
+}
+
 static inline int trypin_tag(unsigned long handle)
 {
 	unsigned long *ptr = (unsigned long *)handle;
@@ -949,8 +956,7 @@ static void reset_page(struct page *page)
 	page->freelist = NULL;
 }
 
-static void free_zspage(struct zs_pool *pool, struct size_class *class,
-			struct page *first_page)
+static void free_zspage(struct zs_pool *pool, struct page *first_page)
 {
 	struct page *nextp, *tmp, *head_extra;
 
@@ -973,11 +979,6 @@ static void free_zspage(struct zs_pool *pool, struct size_class *class,
 	}
 	reset_page(head_extra);
 	__free_page(head_extra);
-
-	zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
-			class->size, class->pages_per_zspage));
-	atomic_long_sub(class->pages_per_zspage,
-				&pool->pages_allocated);
 }
 
 /* Initialize a newly allocated zspage */
@@ -1325,6 +1326,11 @@ static bool zspage_full(struct size_class *class, struct page *first_page)
 	return get_zspage_inuse(first_page) == class->objs_per_zspage;
 }
 
+static bool zspage_empty(struct size_class *class, struct page *first_page)
+{
+	return get_zspage_inuse(first_page) == 0;
+}
+
 unsigned long zs_get_total_pages(struct zs_pool *pool)
 {
 	return atomic_long_read(&pool->pages_allocated);
@@ -1455,7 +1461,6 @@ static unsigned long obj_malloc(struct size_class *class,
 		set_page_private(first_page, handle | OBJ_ALLOCATED_TAG);
 	kunmap_atomic(vaddr);
 	mod_zspage_inuse(first_page, 1);
-	zs_stat_inc(class, OBJ_USED, 1);
 
 	obj = location_to_obj(m_page, obj);
 
@@ -1510,6 +1515,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	}
 
 	obj = obj_malloc(class, first_page, handle);
+	zs_stat_inc(class, OBJ_USED, 1);
 	/* Now move the zspage to another fullness group, if required */
 	fix_fullness_group(class, first_page);
 	record_obj(handle, obj);
@@ -1540,7 +1546,6 @@ static void obj_free(struct size_class *class, unsigned long obj)
 	kunmap_atomic(vaddr);
 	set_freeobj(first_page, f_objidx);
 	mod_zspage_inuse(first_page, -1);
-	zs_stat_dec(class, OBJ_USED, 1);
 }
 
 void zs_free(struct zs_pool *pool, unsigned long handle)
@@ -1564,10 +1569,19 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 
 	spin_lock(&class->lock);
 	obj_free(class, obj);
+	zs_stat_dec(class, OBJ_USED, 1);
 	fullness = fix_fullness_group(class, first_page);
-	if (fullness == ZS_EMPTY)
-		free_zspage(pool, class, first_page);
+	if (fullness == ZS_EMPTY) {
+		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
+				class->size, class->pages_per_zspage));
+		spin_unlock(&class->lock);
+		atomic_long_sub(class->pages_per_zspage,
+					&pool->pages_allocated);
+		free_zspage(pool, first_page);
+		goto out;
+	}
 	spin_unlock(&class->lock);
+out:
 	unpin_tag(handle);
 
 	free_handle(pool, handle);
@@ -1637,127 +1651,66 @@ static void zs_object_copy(struct size_class *class, unsigned long dst,
 	kunmap_atomic(s_addr);
 }
 
-/*
- * Find alloced object in zspage from index object and
- * return handle.
- */
-static unsigned long find_alloced_obj(struct size_class *class,
-					struct page *page, int index)
+static unsigned long handle_from_obj(struct size_class *class,
+				struct page *first_page, int obj_idx)
 {
-	unsigned long head;
-	int offset = 0;
-	unsigned long handle = 0;
-	void *addr = kmap_atomic(page);
-
-	if (!is_first_page(page))
-		offset = page->index;
-	offset += class->size * index;
-
-	while (offset < PAGE_SIZE) {
-		head = obj_to_head(class, page, addr + offset);
-		if (head & OBJ_ALLOCATED_TAG) {
-			handle = head & ~OBJ_ALLOCATED_TAG;
-			if (trypin_tag(handle))
-				break;
-			handle = 0;
-		}
+	struct page *page;
+	unsigned long offset_in_page;
+	void *addr;
+	unsigned long head, handle = 0;
 
-		offset += class->size;
-		index++;
-	}
+	objidx_to_page_and_offset(class, first_page, obj_idx,
+			&page, &offset_in_page);
 
+	addr = kmap_atomic(page);
+	head = obj_to_head(class, page, addr + offset_in_page);
+	if (head & OBJ_ALLOCATED_TAG)
+		handle = head & ~OBJ_ALLOCATED_TAG;
 	kunmap_atomic(addr);
+
 	return handle;
 }
 
-struct zs_compact_control {
-	/* Source page for migration which could be a subpage of zspage. */
-	struct page *s_page;
-	/* Destination page for migration which should be a first page
-	 * of zspage. */
-	struct page *d_page;
-	 /* Starting object index within @s_page which used for live object
-	  * in the subpage. */
-	int index;
-};
-
-static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
-				struct zs_compact_control *cc)
+static int migrate_zspage(struct size_class *class, struct page *dst_page,
+				struct page *src_page)
 {
-	unsigned long used_obj, free_obj;
 	unsigned long handle;
-	struct page *s_page = cc->s_page;
-	struct page *d_page = cc->d_page;
-	unsigned long index = cc->index;
-	int ret = 0;
+	unsigned long old_obj, new_obj;
+	int i;
+	int nr_migrated = 0;
 
-	while (1) {
-		handle = find_alloced_obj(class, s_page, index);
-		if (!handle) {
-			s_page = get_next_page(s_page);
-			if (!s_page)
-				break;
-			index = 0;
+	for (i = 0; i < class->objs_per_zspage; i++) {
+		handle = handle_from_obj(class, src_page, i);
+		if (!handle)
 			continue;
-		}
-
-		/* Stop if there is no more space */
-		if (zspage_full(class, d_page)) {
-			unpin_tag(handle);
-			ret = -ENOMEM;
+		if (zspage_full(class, dst_page))
 			break;
-		}
-
-		used_obj = handle_to_obj(handle);
-		free_obj = obj_malloc(class, d_page, handle);
-		zs_object_copy(class, free_obj, used_obj);
-		index++;
+		old_obj = handle_to_obj(handle);
+		new_obj = obj_malloc(class, dst_page, handle);
+		zs_object_copy(class, new_obj, old_obj);
+		nr_migrated++;
 		/*
 		 * record_obj updates handle's value to free_obj and it will
 		 * invalidate lock bit(ie, HANDLE_PIN_BIT) of handle, which
 		 * breaks synchronization using pin_tag(e,g, zs_free) so
 		 * let's keep the lock bit.
 		 */
-		free_obj |= BIT(HANDLE_PIN_BIT);
-		record_obj(handle, free_obj);
-		unpin_tag(handle);
-		obj_free(class, used_obj);
+		new_obj |= BIT(HANDLE_PIN_BIT);
+		record_obj(handle, new_obj);
+		obj_free(class, old_obj);
 	}
-
-	/* Remember last position in this iteration */
-	cc->s_page = s_page;
-	cc->index = index;
-
-	return ret;
-}
-
-static struct page *isolate_target_page(struct size_class *class)
-{
-	int i;
-	struct page *page;
-
-	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
-		page = class->fullness_list[i];
-		if (page) {
-			remove_zspage(class, i, page);
-			break;
-		}
-	}
-
-	return page;
+	return nr_migrated;
 }
 
 /*
  * putback_zspage - add @first_page into right class's fullness list
- * @pool: target pool
  * @class: destination class
  * @first_page: target page
  *
  * Return @first_page's updated fullness_group
  */
-static enum fullness_group putback_zspage(struct zs_pool *pool,
-			struct size_class *class,
-			struct page *first_page)
+static enum fullness_group putback_zspage(struct size_class *class,
+					struct page *first_page)
 {
 	enum fullness_group fullness;
 
@@ -1768,17 +1721,155 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 	return fullness;
 }
 
+/*
+ * freeze_zspage - freeze all objects in a zspage
+ * @class: size class of the page
+ * @first_page: first page of zspage
+ *
+ * Freeze all allocated objects in a zspage so objects couldn't be
+ * freed until unfreeze objects. It should be called under class->lock.
+ *
+ * RETURNS:
+ * the number of pinned objects
+ */
+static int freeze_zspage(struct size_class *class, struct page *first_page)
+{
+	unsigned long obj_idx;
+	struct page *obj_page;
+	unsigned long offset;
+	void *addr;
+	int nr_freeze = 0;
+
+	for (obj_idx = 0; obj_idx < class->objs_per_zspage; obj_idx++) {
+		unsigned long head;
+
+		objidx_to_page_and_offset(class, first_page, obj_idx,
+					&obj_page, &offset);
+		addr = kmap_atomic(obj_page);
+		head = obj_to_head(class, obj_page, addr + offset);
+		if (head & OBJ_ALLOCATED_TAG) {
+			unsigned long handle = head & ~OBJ_ALLOCATED_TAG;
+
+			if (!trypin_tag(handle)) {
+				kunmap_atomic(addr);
+				break;
+			}
+			nr_freeze++;
+		}
+		kunmap_atomic(addr);
+	}
+
+	return nr_freeze;
+}
+
+/*
+ * unfreeze_page - unfreeze objects freezed by freeze_zspage in a zspage
+ * @class: size class of the page
+ * @first_page: freezed zspage to unfreeze
+ * @nr_obj: the number of objects to unfreeze
+ *
+ * unfreeze objects in a zspage.
+ */
+static void unfreeze_zspage(struct size_class *class, struct page *first_page,
+			int nr_obj)
+{
+	unsigned long obj_idx;
+	struct page *obj_page;
+	unsigned long offset;
+	void *addr;
+	int nr_unfreeze = 0;
+
+	for (obj_idx = 0; obj_idx < class->objs_per_zspage &&
+			nr_unfreeze < nr_obj; obj_idx++) {
+		unsigned long head;
+
+		objidx_to_page_and_offset(class, first_page, obj_idx,
+					&obj_page, &offset);
+		addr = kmap_atomic(obj_page);
+		head = obj_to_head(class, obj_page, addr + offset);
+		if (head & OBJ_ALLOCATED_TAG) {
+			unsigned long handle = head & ~OBJ_ALLOCATED_TAG;
+
+			VM_BUG_ON(!testpin_tag(handle));
+			unpin_tag(handle);
+			nr_unfreeze++;
+		}
+		kunmap_atomic(addr);
+	}
+}
+
+/*
+ * isolate_source_page - isolate a zspage for migration source
+ * @class: size class of zspage for isolation
+ *
+ * Returns a zspage which are isolated from list so anyone can
+ * allocate a object from that page. As well, freeze all objects
+ * allocated in the zspage so anyone cannot access that objects
+ * (e.g., zs_map_object, zs_free).
+ */
 static struct page *isolate_source_page(struct size_class *class)
 {
 	int i;
 	struct page *page = NULL;
 
 	for (i = ZS_ALMOST_EMPTY; i >= ZS_ALMOST_FULL; i--) {
+		int inuse, freezed;
+
 		page = class->fullness_list[i];
 		if (!page)
 			continue;
 
 		remove_zspage(class, i, page);
+
+		inuse = get_zspage_inuse(page);
+		freezed = freeze_zspage(class, page);
+
+		if (inuse != freezed) {
+			unfreeze_zspage(class, page, freezed);
+			putback_zspage(class, page);
+			page = NULL;
+			continue;
+		}
+
+		break;
+	}
+
+	return page;
+}
+
+/*
+ * isolate_target_page - isolate a zspage for migration target
+ * @class: size class of zspage for isolation
+ *
+ * Returns a zspage which are isolated from list so anyone can
+ * allocate a object from that page. As well, freeze all objects
+ * allocated in the zspage so anyone cannot access that objects
+ * (e.g., zs_map_object, zs_free).
+ */
+static struct page *isolate_target_page(struct size_class *class)
+{
+	int i;
+	struct page *page;
+
+	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
+		int inuse, freezed;
+
+		page = class->fullness_list[i];
+		if (!page)
+			continue;
+
+		remove_zspage(class, i, page);
+
+		inuse = get_zspage_inuse(page);
+		freezed = freeze_zspage(class, page);
+
+		if (inuse != freezed) {
+			unfreeze_zspage(class, page, freezed);
+			putback_zspage(class, page);
+			page = NULL;
+			continue;
+		}
+
 		break;
 	}
 
@@ -1793,9 +1884,11 @@ static struct page *isolate_source_page(struct size_class *class)
 static unsigned long zs_can_compact(struct size_class *class)
 {
 	unsigned long obj_wasted;
+	unsigned long obj_allocated, obj_used;
 
-	obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
-		zs_stat_get(class, OBJ_USED);
+	obj_allocated = zs_stat_get(class, OBJ_ALLOCATED);
+	obj_used = zs_stat_get(class, OBJ_USED);
+	obj_wasted = obj_allocated - obj_used;
 
 	obj_wasted /= get_maxobj_per_zspage(class->size,
 			class->pages_per_zspage);
@@ -1805,53 +1898,81 @@ static unsigned long zs_can_compact(struct size_class *class)
 
 static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 {
-	struct zs_compact_control cc;
-	struct page *src_page;
+	struct page *src_page = NULL;
 	struct page *dst_page = NULL;
 
-	spin_lock(&class->lock);
-	while ((src_page = isolate_source_page(class))) {
+	while (1) {
+		int nr_migrated;
 
-		if (!zs_can_compact(class))
+		spin_lock(&class->lock);
+		if (!zs_can_compact(class)) {
+			spin_unlock(&class->lock);
 			break;
+		}
 
-		cc.index = 0;
-		cc.s_page = src_page;
+		/*
+		 * Isolate source page and freeze all objects in a zspage
+		 * to prevent zspage destroying.
+		 */
+		if (!src_page) {
+			src_page = isolate_source_page(class);
+			if (!src_page) {
+				spin_unlock(&class->lock);
+				break;
+			}
+		}
 
-		while ((dst_page = isolate_target_page(class))) {
-			cc.d_page = dst_page;
-			/*
-			 * If there is no more space in dst_page, resched
-			 * and see if anyone had allocated another zspage.
-			 */
-			if (!migrate_zspage(pool, class, &cc))
+		/* Isolate target page and freeze all objects in the zspage */
+		if (!dst_page) {
+			dst_page = isolate_target_page(class);
+			if (!dst_page) {
+				spin_unlock(&class->lock);
 				break;
+			}
+		}
+		spin_unlock(&class->lock);
+
+		nr_migrated = migrate_zspage(class, dst_page, src_page);
 
-			VM_BUG_ON_PAGE(putback_zspage(pool, class,
-				dst_page) == ZS_EMPTY, dst_page);
+		if (zspage_full(class, dst_page)) {
+			spin_lock(&class->lock);
+			putback_zspage(class, dst_page);
+			unfreeze_zspage(class, dst_page,
+				class->objs_per_zspage);
+			spin_unlock(&class->lock);
+			dst_page = NULL;
 		}
 
-		/* Stop if we couldn't find slot */
-		if (dst_page == NULL)
-			break;
+		if (zspage_empty(class, src_page)) {
+			free_zspage(pool, src_page);
+			spin_lock(&class->lock);
+			zs_stat_dec(class, OBJ_ALLOCATED,
+				get_maxobj_per_zspage(
+				class->size, class->pages_per_zspage));
+			atomic_long_sub(class->pages_per_zspage,
+					&pool->pages_allocated);
 
-		VM_BUG_ON_PAGE(putback_zspage(pool, class,
-				dst_page) == ZS_EMPTY, dst_page);
-		if (putback_zspage(pool, class, src_page) == ZS_EMPTY) {
 			pool->stats.pages_compacted += class->pages_per_zspage;
 			spin_unlock(&class->lock);
-			free_zspage(pool, class, src_page);
-		} else {
-			spin_unlock(&class->lock);
+			src_page = NULL;
 		}
+	}
 
-		cond_resched();
-		spin_lock(&class->lock);
+	if (!src_page && !dst_page)
+		return;
+
+	spin_lock(&class->lock);
+	if (src_page) {
+		putback_zspage(class, src_page);
+		unfreeze_zspage(class, src_page,
+				class->objs_per_zspage);
 	}
 
-	if (src_page)
-		VM_BUG_ON_PAGE(putback_zspage(pool, class,
-				src_page) == ZS_EMPTY, src_page);
+	if (dst_page) {
+		putback_zspage(class, dst_page);
+		unfreeze_zspage(class, dst_page,
+				class->objs_per_zspage);
+	}
 
 	spin_unlock(&class->lock);
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
