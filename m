Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id D17F66B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 00:00:42 -0500 (EST)
Received: by pabli10 with SMTP id li10so30337735pab.2
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 21:00:42 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ff2si3565120pab.111.2015.03.03.21.00.40
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 21:00:41 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 2/7] zsmalloc: factor out obj_[malloc|free]
Date: Wed,  4 Mar 2015 14:01:27 +0900
Message-Id: <1425445292-29061-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1425445292-29061-1-git-send-email-minchan@kernel.org>
References: <1425445292-29061-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, opensource.ganesh@gmail.com, Minchan Kim <minchan@kernel.org>

In later patch, migration needs some part of functions in
zs_malloc and zs_free so this patch factor out them.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 99 ++++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 61 insertions(+), 38 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 2df2f1b08aaa..e52b1b6f5535 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -525,11 +525,10 @@ static void remove_zspage(struct page *page, struct size_class *class,
  * page from the freelist of the old fullness group to that of the new
  * fullness group.
  */
-static enum fullness_group fix_fullness_group(struct zs_pool *pool,
+static enum fullness_group fix_fullness_group(struct size_class *class,
 						struct page *page)
 {
 	int class_idx;
-	struct size_class *class;
 	enum fullness_group currfg, newfg;
 
 	BUG_ON(!is_first_page(page));
@@ -539,7 +538,6 @@ static enum fullness_group fix_fullness_group(struct zs_pool *pool,
 	if (newfg == currfg)
 		goto out;
 
-	class = pool->size_class[class_idx];
 	remove_zspage(page, class, currfg);
 	insert_zspage(page, class, newfg);
 	set_zspage_mapping(page, class_idx, newfg);
@@ -1281,6 +1279,33 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
 
+static unsigned long obj_malloc(struct page *first_page,
+		struct size_class *class, unsigned long handle)
+{
+	unsigned long obj;
+	struct link_free *link;
+
+	struct page *m_page;
+	unsigned long m_objidx, m_offset;
+	void *vaddr;
+
+	obj = (unsigned long)first_page->freelist;
+	obj_to_location(obj, &m_page, &m_objidx);
+	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
+
+	vaddr = kmap_atomic(m_page);
+	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
+	first_page->freelist = link->next;
+	/* record handle in the header of allocated chunk */
+	link->handle = handle;
+	kunmap_atomic(vaddr);
+	first_page->inuse++;
+	zs_stat_inc(class, OBJ_USED, 1);
+
+	return obj;
+}
+
+
 /**
  * zs_malloc - Allocate block of given size from pool.
  * @pool: pool to allocate from
@@ -1293,12 +1318,8 @@ EXPORT_SYMBOL_GPL(zs_unmap_object);
 unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 {
 	unsigned long handle, obj;
-	struct link_free *link;
 	struct size_class *class;
-	void *vaddr;
-
-	struct page *first_page, *m_page;
-	unsigned long m_objidx, m_offset;
+	struct page *first_page;
 
 	if (unlikely(!size || (size + ZS_HANDLE_SIZE) > ZS_MAX_ALLOC_SIZE))
 		return 0;
@@ -1331,22 +1352,9 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 				class->size, class->pages_per_zspage));
 	}
 
-	obj = (unsigned long)first_page->freelist;
-	obj_to_location(obj, &m_page, &m_objidx);
-	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
-
-	vaddr = kmap_atomic(m_page);
-	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
-	first_page->freelist = link->next;
-
-	/* record handle in the header of allocated chunk */
-	link->handle = handle;
-	kunmap_atomic(vaddr);
-
-	first_page->inuse++;
-	zs_stat_inc(class, OBJ_USED, 1);
+	obj = obj_malloc(first_page, class, handle);
 	/* Now move the zspage to another fullness group, if required */
-	fix_fullness_group(pool, first_page);
+	fix_fullness_group(class, first_page);
 	record_obj(handle, obj);
 	spin_unlock(&class->lock);
 
@@ -1354,46 +1362,61 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 }
 EXPORT_SYMBOL_GPL(zs_malloc);
 
-void zs_free(struct zs_pool *pool, unsigned long handle)
+static void obj_free(struct zs_pool *pool, struct size_class *class,
+			unsigned long obj)
 {
 	struct link_free *link;
 	struct page *first_page, *f_page;
-	unsigned long obj, f_objidx, f_offset;
+	unsigned long f_objidx, f_offset;
 	void *vaddr;
-
 	int class_idx;
-	struct size_class *class;
 	enum fullness_group fullness;
 
-	if (unlikely(!handle))
-		return;
+	BUG_ON(!obj);
 
-	obj = handle_to_obj(handle);
-	free_handle(pool, handle);
 	obj_to_location(obj, &f_page, &f_objidx);
 	first_page = get_first_page(f_page);
 
 	get_zspage_mapping(first_page, &class_idx, &fullness);
-	class = pool->size_class[class_idx];
 	f_offset = obj_idx_to_offset(f_page, f_objidx, class->size);
 
-	spin_lock(&class->lock);
+	vaddr = kmap_atomic(f_page);
 
 	/* Insert this object in containing zspage's freelist */
-	vaddr = kmap_atomic(f_page);
 	link = (struct link_free *)(vaddr + f_offset);
 	link->next = first_page->freelist;
 	kunmap_atomic(vaddr);
 	first_page->freelist = (void *)obj;
-
 	first_page->inuse--;
-	fullness = fix_fullness_group(pool, first_page);
-
 	zs_stat_dec(class, OBJ_USED, 1);
+}
+
+void zs_free(struct zs_pool *pool, unsigned long handle)
+{
+	struct page *first_page, *f_page;
+	unsigned long obj, f_objidx;
+
+	int class_idx;
+	struct size_class *class;
+	enum fullness_group fullness;
+
+	if (unlikely(!handle))
+		return;
+
+	obj = handle_to_obj(handle);
+	free_handle(pool, handle);
+	obj_to_location(obj, &f_page, &f_objidx);
+	first_page = get_first_page(f_page);
+
+	get_zspage_mapping(first_page, &class_idx, &fullness);
+	class = pool->size_class[class_idx];
+
+	spin_lock(&class->lock);
+	obj_free(pool, class, obj);
+	fullness = fix_fullness_group(class, first_page);
 	if (fullness == ZS_EMPTY)
 		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
 				class->size, class->pages_per_zspage));
-
 	spin_unlock(&class->lock);
 
 	if (fullness == ZS_EMPTY) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
