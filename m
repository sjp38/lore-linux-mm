Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C7E296B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 21:50:11 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so12365841pad.41
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 18:50:11 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id oo1si31461410pbb.174.2014.12.01.18.50.08
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 18:50:10 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 4/6] zsmalloc: encode alloced mark in handle object
Date: Tue,  2 Dec 2014 11:49:45 +0900
Message-Id: <1417488587-28609-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1417488587-28609-1-git-send-email-minchan@kernel.org>
References: <1417488587-28609-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Minchan Kim <minchan@kernel.org>

For compaction, we need to look up using object in zspage
to migrate but there is no way to distinguish it from
free objects without walking all of free objects via
first_page->freelist, which would be haavy.

This patch encodes alloced mark in handle's least bit
so compaction can find it with small cost.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 1eec2a539f77..16c40081c22e 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -133,7 +133,9 @@
 #endif
 #endif
 #define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)
-#define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS)
+#define OBJ_ALLOCATED	1
+#define OBJ_ALLOC_BITS	1
+#define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS - OBJ_ALLOC_BITS)
 #define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
 
 #define MAX(a, b) ((a) >= (b) ? (a) : (b))
@@ -555,9 +557,6 @@ static struct page *get_next_page(struct page *page)
 
 /*
  * Encode <page, obj_idx> as a single handle value.
- * On hardware platforms with physical memory starting at 0x0 the pfn
- * could be 0 so we ensure that the handle will never be 0 by adjusting the
- * encoded obj_idx value before encoding.
  */
 static void *obj_location_to_handle(struct page *page, unsigned long obj_idx)
 {
@@ -568,22 +567,20 @@ static void *obj_location_to_handle(struct page *page, unsigned long obj_idx)
 		return NULL;
 	}
 
-	handle = page_to_pfn(page) << OBJ_INDEX_BITS;
-	handle |= ((obj_idx + 1) & OBJ_INDEX_MASK);
+	handle = page_to_pfn(page) << (OBJ_INDEX_BITS + OBJ_ALLOC_BITS);
+	handle |= (obj_idx & OBJ_INDEX_MASK) << OBJ_ALLOC_BITS;
 
 	return (void *)handle;
 }
 
 /*
- * Decode <page, obj_idx> pair from the given object handle. We adjust the
- * decoded obj_idx back to its original value since it was adjusted in
- * obj_location_to_handle().
+ * Decode <page, obj_idx> pair from the given object handle.
  */
 static void obj_to_location(unsigned long handle, struct page **page,
 				unsigned long *obj_idx)
 {
-	*page = pfn_to_page(handle >> OBJ_INDEX_BITS);
-	*obj_idx = (handle & OBJ_INDEX_MASK) - 1;
+	*page = pfn_to_page(handle >> (OBJ_INDEX_BITS + OBJ_ALLOC_BITS));
+	*obj_idx = ((handle >> OBJ_ALLOC_BITS) & OBJ_INDEX_MASK);
 }
 
 static unsigned long obj_idx_to_offset(struct page *page,
@@ -623,8 +620,21 @@ static unsigned long handle_to_obj(struct zs_pool *pool, unsigned long handle)
 
 static unsigned long alloc_handle(struct zs_pool *pool)
 {
-	return __zs_malloc(pool, pool->handle_class,
+	unsigned long handle;
+
+	handle = __zs_malloc(pool, pool->handle_class,
 			pool->flags & ~__GFP_HIGHMEM, 0);
+	/*
+	 * OBJ_ALLOCATED marks the object allocated tag so compaction
+	 * can identify it among free objects in zspage.
+	 * In addtion, on hardware platforms with physical memory
+	 * starting at 0x0 the pfn could be 0 so it ensure that the
+	 * handle will never be 0 which means fail of allocation now.
+	 */
+	if (likely(handle))
+		handle |= OBJ_ALLOCATED;
+
+	return handle;
 }
 
 static void free_handle(struct zs_pool *pool, unsigned long handle)
@@ -1259,6 +1269,7 @@ static void __zs_free(struct zs_pool *pool, struct size_class *class,
 	spin_lock(&class->lock);
 	/* Insert this object in containing zspage's freelist */
 	link = (struct link_free *)(vaddr + f_offset);
+	link->handle &= ~OBJ_ALLOCATED;
 	link->next = first_page->freelist;
 	first_page->freelist = (void *)handle;
 
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
