Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id EF57A6B007D
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 01:15:01 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so50762786pad.9
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 22:15:01 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id rr7si7187673pab.233.2015.01.20.22.14.38
        for <linux-mm@kvack.org>;
        Tue, 20 Jan 2015 22:14:40 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 10/10] zsmalloc: record handle in page->private for huge object
Date: Wed, 21 Jan 2015 15:14:26 +0900
Message-Id: <1421820866-26521-11-git-send-email-minchan@kernel.org>
In-Reply-To: <1421820866-26521-1-git-send-email-minchan@kernel.org>
References: <1421820866-26521-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>

We stores handle on header of each allocated object so it
increases the size of each object by sizeof(unsigned long).

If zram stores 4096 bytes to zsmalloc(ie, bad compression),
zsmalloc needs 4104B-class to store the data with handle.

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
index 48b702e..c9f9230 100644
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
@@ -160,7 +162,7 @@
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
@@ -461,7 +466,7 @@ static int get_size_class_index(int size)
 		idx = DIV_ROUND_UP(size - ZS_MIN_ALLOC_SIZE,
 				ZS_SIZE_CLASS_DELTA);
 
-	return idx;
+	return min(zs_size_classes - 1, idx);
 }
 
 #ifdef CONFIG_ZSMALLOC_STAT
@@ -847,9 +852,14 @@ static unsigned long handle_to_obj(unsigned long handle)
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
@@ -1126,9 +1136,12 @@ static void __zs_unmap_object(struct mapping_area *area,
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
@@ -1316,7 +1329,10 @@ retry:
 
 	ret = __zs_map_object(area, pages, off, class->size);
 out:
-	return ret + ZS_HANDLE_SIZE;
+	if (!class->huge)
+		ret += ZS_HANDLE_SIZE;
+
+	return ret;
 }
 EXPORT_SYMBOL_GPL(zs_map_object);
 
@@ -1375,8 +1391,12 @@ static unsigned long obj_malloc(struct page *first_page,
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
@@ -1400,7 +1420,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	struct size_class *class;
 	struct page *first_page;
 
-	if (unlikely(!size || (size + ZS_HANDLE_SIZE) > ZS_MAX_ALLOC_SIZE))
+	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
 		return 0;
 
 	handle = alloc_handle(pool);
@@ -1410,6 +1430,11 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
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
@@ -1465,6 +1490,8 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
 	/* Insert this object in containing zspage's freelist */
 	link = (struct link_free *)(vaddr + f_offset);
 	link->next = first_page->freelist;
+	if (class->huge)
+		set_page_private(first_page, 0);
 	kunmap_atomic(vaddr);
 	first_page->freelist = (void *)obj;
 	first_page->inuse--;
@@ -1599,7 +1626,7 @@ static unsigned long find_alloced_obj(struct page *page, int index,
 	offset += class->size * index;
 
 	while (offset < PAGE_SIZE) {
-		head = obj_to_head(addr + offset);
+		head = obj_to_head(class, page, addr + offset);
 		if (head & OBJ_ALLOCATED_TAG) {
 			handle = head & ~OBJ_ALLOCATED_TAG;
 			if (!(*(unsigned long *)handle & HANDLE_PIN_TAG))
@@ -1863,6 +1890,9 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
 		class->size = size;
 		class->index = i;
 		class->pages_per_zspage = pages_per_zspage;
+		if (pages_per_zspage == 1 &&
+			get_maxobj_per_zspage(size, pages_per_zspage) == 1)
+			class->huge = true;
 		spin_lock_init(&class->lock);
 		pool->size_class[i] = class;
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
