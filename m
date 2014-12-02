Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9AAE26B006E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 21:50:13 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so12343032pab.5
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 18:50:13 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id i1si22792159pdk.67.2014.12.01.18.50.08
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 18:50:10 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 3/6] zsmalloc: implement reverse mapping
Date: Tue,  2 Dec 2014 11:49:44 +0900
Message-Id: <1417488587-28609-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1417488587-28609-1-git-send-email-minchan@kernel.org>
References: <1417488587-28609-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Minchan Kim <minchan@kernel.org>

This patch supports reverse mapping which gets handle from object.
For keeping handle per object, it allocates ZS_HANDLE_SIZE greater
than size user requested and stores handle in there.
IOW, *(mapped address by zs_map_object - ZS_HANDLE_SIZE) == handle.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 55 +++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 35 insertions(+), 20 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 5f3f9119705e..1eec2a539f77 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -213,8 +213,12 @@ struct size_class {
  * This must be power of 2 and less than or equal to ZS_ALIGN
  */
 struct link_free {
-	/* Handle of next free chunk (encodes <PFN, obj_idx>) */
-	void *next;
+	union {
+		/* Handle of next free chunk (encodes <PFN, obj_idx>) */
+		void *next;
+		/* Handle of object allocated to user */
+		unsigned long handle;
+	};
 };
 
 struct zs_pool {
@@ -245,7 +249,9 @@ struct mapping_area {
 };
 
 static unsigned long __zs_malloc(struct zs_pool *pool,
-			struct size_class *class, gfp_t flags);
+			struct size_class *class, gfp_t flags,
+			unsigned long handle);
+
 static void __zs_free(struct zs_pool *pool, struct size_class *class,
 			unsigned long handle);
 
@@ -618,7 +624,7 @@ static unsigned long handle_to_obj(struct zs_pool *pool, unsigned long handle)
 static unsigned long alloc_handle(struct zs_pool *pool)
 {
 	return __zs_malloc(pool, pool->handle_class,
-			pool->flags & ~__GFP_HIGHMEM);
+			pool->flags & ~__GFP_HIGHMEM, 0);
 }
 
 static void free_handle(struct zs_pool *pool, unsigned long handle)
@@ -873,18 +879,22 @@ static void __zs_unmap_object(struct mapping_area *area,
 {
 	int sizes[2];
 	void *addr;
-	char *buf = area->vm_buf;
+	char *buf;
 
 	/* no write fastpath */
 	if (area->vm_mm == ZS_MM_RO)
 		goto out;
 
-	sizes[0] = PAGE_SIZE - off;
+	/* We shouldn't overwrite handle */
+	buf = area->vm_buf + ZS_HANDLE_SIZE;
+	size -= ZS_HANDLE_SIZE;
+
+	sizes[0] = PAGE_SIZE - off - ZS_HANDLE_SIZE;
 	sizes[1] = size - sizes[0];
 
 	/* copy per-cpu buffer to object */
 	addr = kmap_atomic(pages[0]);
-	memcpy(addr + off, buf, sizes[0]);
+	memcpy(addr + off + ZS_HANDLE_SIZE, buf, sizes[0]);
 	kunmap_atomic(addr);
 	addr = kmap_atomic(pages[1]);
 	memcpy(addr, buf + sizes[0], sizes[1]);
@@ -1138,7 +1148,7 @@ void zs_destroy_pool(struct zs_pool *pool)
 EXPORT_SYMBOL_GPL(zs_destroy_pool);
 
 static unsigned long __zs_malloc(struct zs_pool *pool,
-			struct size_class *class, gfp_t flags)
+		struct size_class *class, gfp_t flags, unsigned long handle)
 {
 	unsigned long obj;
 	struct link_free *link;
@@ -1168,10 +1178,19 @@ static unsigned long __zs_malloc(struct zs_pool *pool,
 	vaddr = kmap_atomic(m_page);
 	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
 	first_page->freelist = link->next;
-	memset(link, POISON_INUSE, sizeof(*link));
+	link->handle = handle;
 	kunmap_atomic(vaddr);
 
 	first_page->inuse++;
+
+	if (handle) {
+		unsigned long *h_addr;
+
+		/* associate handle with obj */
+		h_addr = handle_to_addr(pool, handle);
+		*h_addr = obj;
+	}
+
 	/* Now move the zspage to another fullness group, if required */
 	fix_fullness_group(class, first_page);
 	spin_unlock(&class->lock);
@@ -1192,9 +1211,8 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 {
 	unsigned long obj, handle;
 	struct size_class *class;
-	unsigned long *h_addr;
 
-	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
+	if (unlikely(!size || (size + ZS_HANDLE_SIZE) > ZS_MAX_ALLOC_SIZE))
 		return 0;
 
 	/* allocate handle */
@@ -1202,18 +1220,15 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	if (!handle)
 		goto out;
 
-	/* allocate obj */
+	/* allocate obj and associate it with handle */
+	size += ZS_HANDLE_SIZE;
 	class = pool->size_class[get_size_class_index(size)];
-	obj = __zs_malloc(pool, class, pool->flags);
+	obj = __zs_malloc(pool, class, pool->flags, handle);
 	if (!obj) {
-		__zs_free(pool, pool->handle_class, handle);
+		free_handle(pool, handle);
 		handle = 0;
 		goto out;
 	}
-
-	/* associate handle with obj */
-	h_addr = handle_to_addr(pool, handle);
-	*h_addr = obj;
 out:
 	return handle;
 }
@@ -1335,7 +1350,7 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	if (off + class->size <= PAGE_SIZE) {
 		/* this object is contained entirely within a page */
 		area->vm_addr = kmap_atomic(page);
-		return area->vm_addr + off;
+		return area->vm_addr + off + ZS_HANDLE_SIZE;
 	}
 
 	/* this object spans two pages */
@@ -1343,7 +1358,7 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	pages[1] = get_next_page(page);
 	BUG_ON(!pages[1]);
 
-	return __zs_map_object(area, pages, off, class->size);
+	return __zs_map_object(area, pages, off, class->size) + ZS_HANDLE_SIZE;
 }
 EXPORT_SYMBOL_GPL(zs_map_object);
 
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
