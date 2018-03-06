Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B5AE16B0008
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 02:06:55 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k62so8369161pgd.11
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 23:06:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t4-v6sor4573278plb.45.2018.03.05.23.06.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 23:06:54 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCHv2 1/2] zsmalloc: introduce zs_huge_class_size() function
Date: Tue,  6 Mar 2018 16:06:38 +0900
Message-Id: <20180306070639.7389-2-sergey.senozhatsky@gmail.com>
In-Reply-To: <20180306070639.7389-1-sergey.senozhatsky@gmail.com>
References: <20180306070639.7389-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Not every object can be share its zspage with other objects, e.g.
when the object is as big as zspage or nearly as big a zspage.
For such objects zsmalloc has a so called huge class - every object
which belongs to huge class consumes the entire zspage (which
consists of a physical page). On x86_64, PAGE_SHIFT 12 box, the
first non-huge class size is 3264, so starting down from size 3264,
objects can share page(-s) and thus minimize memory wastage.

ZRAM, however, has its own statically defined watermark for huge
objects - "3 * PAGE_SIZE / 4 = 3072", and forcibly stores every
object larger than this watermark (3072) as a PAGE_SIZE object,
in other words, to a huge class, while zsmalloc can keep some of
those objects in non-huge classes. This results in increased
memory consumption.

zsmalloc knows better if the object is huge or not. Introduce
zs_huge_class_size() function which tells if the given object can be
stored in one of non-huge classes or not. This will let us to drop
ZRAM's huge object watermark and fully rely on zsmalloc when we
decide if the object is huge.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 include/linux/zsmalloc.h |  2 ++
 mm/zsmalloc.c            | 40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 42 insertions(+)

diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 57a8e98f2708..753c1af4d2cb 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -47,6 +47,8 @@ void zs_destroy_pool(struct zs_pool *pool);
 unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags);
 void zs_free(struct zs_pool *pool, unsigned long obj);
 
+size_t zs_huge_class_size(void);
+
 void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 			enum zs_mapmode mm);
 void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index a583ab111a43..63422cf35b94 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -193,6 +193,7 @@ static struct vfsmount *zsmalloc_mnt;
  * (see: fix_fullness_group())
  */
 static const int fullness_threshold_frac = 4;
+static size_t huge_class_size;
 
 struct size_class {
 	spinlock_t lock;
@@ -1407,6 +1408,24 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
 
+/**
+ * zs_huge_class_size() - Returns the size (in bytes) of the first huge
+ *                        zsmalloc &size_class.
+ *
+ * The function returns the size of the first huge class - any object of equal
+ * or bigger size will be stored in zspage consisting of a single physical
+ * page.
+ *
+ * Context: Any context.
+ *
+ * Return: the size (in bytes) of the first huge zsmalloc &size_class.
+ */
+size_t zs_huge_class_size(void)
+{
+	return huge_class_size;
+}
+EXPORT_SYMBOL_GPL(zs_huge_class_size);
+
 static unsigned long obj_malloc(struct size_class *class,
 				struct zspage *zspage, unsigned long handle)
 {
@@ -2363,6 +2382,27 @@ struct zs_pool *zs_create_pool(const char *name)
 		pages_per_zspage = get_pages_per_zspage(size);
 		objs_per_zspage = pages_per_zspage * PAGE_SIZE / size;
 
+		/*
+		 * We iterate from biggest down to smallest classes,
+		 * so huge_class_size holds the size of the first huge
+		 * class. Any object bigger than or equal to that will
+		 * endup in the huge class.
+		 */
+		if (pages_per_zspage != 1 && objs_per_zspage != 1 &&
+				!huge_class_size) {
+			huge_class_size = size;
+			/*
+			 * The object uses ZS_HANDLE_SIZE bytes to store the
+			 * handle. We need to subtract it, because zs_malloc()
+			 * unconditionally adds handle size before it performs
+			 * size class search - so object may be smaller than
+			 * huge class size, yet it still can end up in the huge
+			 * class because it grows by ZS_HANDLE_SIZE extra bytes
+			 * right before class lookup.
+			 */
+			huge_class_size -= (ZS_HANDLE_SIZE - 1);
+		}
+
 		/*
 		 * size_class is used for normal zsmalloc operation such
 		 * as alloc/free for that size. Although it is natural that we
-- 
2.16.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
