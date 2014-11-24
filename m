Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2353380110
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:03:55 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so9556806pab.12
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 06:03:54 -0800 (PST)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id s4si21676862pdj.117.2014.11.24.06.03.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 06:03:53 -0800 (PST)
Received: by mail-pd0-f169.google.com with SMTP id fp1so9718698pdb.28
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 06:03:53 -0800 (PST)
From: Mahendran Ganesh <opensource.ganesh@gmail.com>
Subject: [PATCH] mm/zsmalloc: support allocating obj with size of ZS_MAX_ALLOC_SIZE
Date: Mon, 24 Nov 2014 22:03:40 +0800
Message-Id: <1416837820-6914-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mahendran Ganesh <opensource.ganesh@gmail.com>

I sent a patch [1] for unnecessary check in zsmalloc. And Minchan Kim
found zsmalloc even does not support allocating an obj with the size of
ZS_MAX_ALLOC_SIZE in some situations.

For example:
   In system with 64KB PAGE_SIZE and 32 bit of physical addr. Then:
   ZS_MIN_ALLOC_SIZE is 32 bytes which is calculated by:
      MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
   ZS_MAX_ALLOC_SIZE is 64KB(in current code, is PAGE_SIZE)
   ZS_SIZE_CLASS_DELTA is 256 bytes
   So, ZS_SIZE_CLASSES = (ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) /
                          ZS_SIZE_CLASS_DELTA + 1
                       = 256

   In zs_create_pool(), the max size obj which can be allocated will be:
      ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA = 32 + 255*256 = 65312

   We can see that 65312 < 65536 (ZS_MAX_ALLOC_SIZE). So we can NOT
   allocate objs with size ZS_MAX_ALLOC_SIZE(65536) which we promise upper
   users we can do.

 [1]  http://lkml.iu.edu/hypermail/linux/kernel/1411.2/03835.html
 [2]  http://lkml.iu.edu/hypermail/linux/kernel/1411.2/04534.html

This patch fix this issue by dynamiclly calculating zs_size_classes when
module is loaded, allocates buffer with size ZS_MAX_ALLOC_SIZE. Then
the max obj(size is ZS_MAX_ALLOC_SIZE) can be stored in it.

Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
Suggested-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c |   40 ++++++++++++++++++++++++++++++++--------
 1 file changed, 32 insertions(+), 8 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 480fa4c..a79889b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -155,8 +155,6 @@
  *  (reason above)
  */
 #define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> 8)
-#define ZS_SIZE_CLASSES		((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / \
-					ZS_SIZE_CLASS_DELTA + 1)
 
 /*
  * We do not maintain any list for completely empty or full pages
@@ -171,6 +169,11 @@ enum fullness_group {
 };
 
 /*
+ * number of size_classes
+ */
+static int zs_size_classes;
+
+/*
  * We assign a page to ZS_ALMOST_EMPTY fullness group when:
  *	n <= N / f, where
  * n = number of allocated objects
@@ -214,7 +217,7 @@ struct link_free {
 };
 
 struct zs_pool {
-	struct size_class *size_class[ZS_SIZE_CLASSES];
+	struct size_class **size_class;
 
 	gfp_t flags;	/* allocation flags used when growing pool */
 	atomic_long_t pages_allocated;
@@ -785,7 +788,7 @@ static inline int __zs_cpu_up(struct mapping_area *area)
 	 */
 	if (area->vm_buf)
 		return 0;
-	area->vm_buf = (char *)__get_free_page(GFP_KERNEL);
+	area->vm_buf = kmalloc(ZS_MAX_ALLOC_SIZE, GFP_KERNEL);
 	if (!area->vm_buf)
 		return -ENOMEM;
 	return 0;
@@ -793,8 +796,7 @@ static inline int __zs_cpu_up(struct mapping_area *area)
 
 static inline void __zs_cpu_down(struct mapping_area *area)
 {
-	if (area->vm_buf)
-		free_page((unsigned long)area->vm_buf);
+	kfree(area->vm_buf);
 	area->vm_buf = NULL;
 }
 
@@ -912,6 +914,17 @@ static int zs_register_cpu_notifier(void)
 	return notifier_to_errno(ret);
 }
 
+static void init_zs_size_classes(void)
+{
+	int nr;
+
+	nr = (ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / ZS_SIZE_CLASS_DELTA + 1;
+	if ((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) % ZS_SIZE_CLASS_DELTA)
+		nr += 1;
+
+	zs_size_classes = nr;
+}
+
 static void __exit zs_exit(void)
 {
 #ifdef CONFIG_ZPOOL
@@ -929,6 +942,8 @@ static int __init zs_init(void)
 		return ret;
 	}
 
+	init_zs_size_classes();
+
 #ifdef CONFIG_ZPOOL
 	zpool_register_driver(&zs_zpool_driver);
 #endif
@@ -972,11 +987,18 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 	if (!pool)
 		return NULL;
 
+	pool->size_class = kcalloc(zs_size_classes, sizeof(struct size_class *),
+			GFP_KERNEL);
+	if (!pool->size_class) {
+		kfree(pool);
+		return NULL;
+	}
+
 	/*
 	 * Iterate reversly, because, size of size_class that we want to use
 	 * for merging should be larger or equal to current size.
 	 */
-	for (i = ZS_SIZE_CLASSES - 1; i >= 0; i--) {
+	for (i = zs_size_classes - 1; i >= 0; i--) {
 		int size;
 		int pages_per_zspage;
 		struct size_class *class;
@@ -1030,7 +1052,7 @@ void zs_destroy_pool(struct zs_pool *pool)
 {
 	int i;
 
-	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
+	for (i = 0; i < zs_size_classes; i++) {
 		int fg;
 		struct size_class *class = pool->size_class[i];
 
@@ -1048,6 +1070,8 @@ void zs_destroy_pool(struct zs_pool *pool)
 		}
 		kfree(class);
 	}
+
+	kfree(pool->size_class);
 	kfree(pool);
 }
 EXPORT_SYMBOL_GPL(zs_destroy_pool);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
