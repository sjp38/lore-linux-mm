Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8116B0071
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 00:00:50 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so23113806pdb.9
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 21:00:50 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id db5si3573955pbb.100.2015.03.03.21.00.43
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 21:00:44 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 6/7] zsmalloc: record handle in page->private for huge object
Date: Wed,  4 Mar 2015 14:01:31 +0900
Message-Id: <1425445292-29061-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1425445292-29061-1-git-send-email-minchan@kernel.org>
References: <1425445292-29061-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, opensource.ganesh@gmail.com, Minchan Kim <minchan@kernel.org>

We stores handle on header of each allocated object so it
increases the size of each object by sizeof(unsigned long).

If zram stores 4096 bytes to zsmalloc(ie, bad compression),
zsmalloc needs 4104B-class to add handle.

However, 4104B-class has 1-pages_per_zspage so wasted size by
internal fragment is 8192 - 4104, which is terrible.

So this patch records the handle in page->private on such
huge object(ie, pages_per_zspage == 1 && maxobj_per_zspage == 1)
instead of header of each object so we could use 4096B-class,
not 4104B-class.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 54 ++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 42 insertions(+), 12 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 36dcc268720e..c3d9676e47c4 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -57,6 +57,8 @@
  *
  *	page->private (union with page->first_page): refers to the
  *		component page after the first page
+ *		If the page is first_page for huge object, it stores handle.
+ *		Look at size_class->huge.
  *	page->freelist: points to the first free object in zspage.
  *		Free objects are linked together using in-place
  *		metadata.
@@ -162,7 +164,7 @@
 #define ZS_MIN_ALLOC_SIZE \
 	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
 /* each chunk includes extra space to keep handle */
-#define ZS_MAX_ALLOC_SIZE	(PAGE_SIZE + ZS_HANDLE_SIZE)
+#define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
 
 /*
  * On systems with 4K page size, this gives 255 size classes! There is a
@@ -238,6 +240,8 @@ struct size_class {
 
 	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
 	int pages_per_zspage;
+	/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
+	bool huge;
 
 #ifdef CONFIG_ZSMALLOC_STAT
 	struct zs_size_stat stats;
@@ -299,6 +303,7 @@ struct mapping_area {
 #endif
 	char *vm_addr; /* address of kmap_atomic()'ed pages */
 	enum zs_mapmode vm_mm; /* mapping mode */
+	bool huge;
 };
 
 static int create_handle_cache(struct zs_pool *pool)
@@ -456,7 +461,7 @@ static int get_size_class_index(int size)
 		idx = DIV_ROUND_UP(size - ZS_MIN_ALLOC_SIZE,
 				ZS_SIZE_CLASS_DELTA);
 
-	return idx;
+	return min(zs_size_classes - 1, idx);
 }
 
 /*
@@ -665,9 +670,14 @@ static unsigned long handle_to_obj(unsigned long handle)
 	return *(unsigned long *)handle;
 }
 
-unsigned long obj_to_head(void *obj)
+static unsigned long obj_to_head(struct size_class *class, struct page *page,
+			void *obj)
 {
-	return *(unsigned long *)obj;
+	if (class->huge) {
+		VM_BUG_ON(!is_first_page(page));
+		return *(unsigned long *)page_private(page);
+	} else
+		return *(unsigned long *)obj;
 }
 
 static unsigned long obj_idx_to_offset(struct page *page,
@@ -953,9 +963,12 @@ static void __zs_unmap_object(struct mapping_area *area,
 	if (area->vm_mm == ZS_MM_RO)
 		goto out;
 
-	buf = area->vm_buf + ZS_HANDLE_SIZE;
-	size -= ZS_HANDLE_SIZE;
-	off += ZS_HANDLE_SIZE;
+	buf = area->vm_buf;
+	if (!area->huge) {
+		buf = buf + ZS_HANDLE_SIZE;
+		size -= ZS_HANDLE_SIZE;
+		off += ZS_HANDLE_SIZE;
+	}
 
 	sizes[0] = PAGE_SIZE - off;
 	sizes[1] = size - sizes[0];
@@ -1294,7 +1307,10 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 
 	ret = __zs_map_object(area, pages, off, class->size);
 out:
-	return ret + ZS_HANDLE_SIZE;
+	if (!class->huge)
+		ret += ZS_HANDLE_SIZE;
+
+	return ret;
 }
 EXPORT_SYMBOL_GPL(zs_map_object);
 
@@ -1351,8 +1367,12 @@ static unsigned long obj_malloc(struct page *first_page,
 	vaddr = kmap_atomic(m_page);
 	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
 	first_page->freelist = link->next;
-	/* record handle in the header of allocated chunk */
-	link->handle = handle;
+	if (!class->huge)
+		/* record handle in the header of allocated chunk */
+		link->handle = handle;
+	else
+		/* record handle in first_page->private */
+		set_page_private(first_page, handle);
 	kunmap_atomic(vaddr);
 	first_page->inuse++;
 	zs_stat_inc(class, OBJ_USED, 1);
@@ -1376,7 +1396,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	struct size_class *class;
 	struct page *first_page;
 
-	if (unlikely(!size || (size + ZS_HANDLE_SIZE) > ZS_MAX_ALLOC_SIZE))
+	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
 		return 0;
 
 	handle = alloc_handle(pool);
@@ -1386,6 +1406,11 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	/* extra space in chunk to keep the handle */
 	size += ZS_HANDLE_SIZE;
 	class = pool->size_class[get_size_class_index(size)];
+	/* In huge class size, we store the handle into first_page->private */
+	if (class->huge) {
+		size -= ZS_HANDLE_SIZE;
+		class = pool->size_class[get_size_class_index(size)];
+	}
 
 	spin_lock(&class->lock);
 	first_page = find_get_zspage(class);
@@ -1441,6 +1466,8 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
 	/* Insert this object in containing zspage's freelist */
 	link = (struct link_free *)(vaddr + f_offset);
 	link->next = first_page->freelist;
+	if (class->huge)
+		set_page_private(first_page, 0);
 	kunmap_atomic(vaddr);
 	first_page->freelist = (void *)obj;
 	first_page->inuse--;
@@ -1567,7 +1594,7 @@ static unsigned long find_alloced_obj(struct page *page, int index,
 	offset += class->size * index;
 
 	while (offset < PAGE_SIZE) {
-		head = obj_to_head(addr + offset);
+		head = obj_to_head(class, page, addr + offset);
 		if (head & OBJ_ALLOCATED_TAG) {
 			handle = head & ~OBJ_ALLOCATED_TAG;
 			if (trypin_tag(handle))
@@ -1835,6 +1862,9 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
 		class->size = size;
 		class->index = i;
 		class->pages_per_zspage = pages_per_zspage;
+		if (pages_per_zspage == 1 &&
+			get_maxobj_per_zspage(size, pages_per_zspage) == 1)
+			class->huge = true;
 		spin_lock_init(&class->lock);
 		pool->size_class[i] = class;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
