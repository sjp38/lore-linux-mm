Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC046B025E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 13:10:14 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id n3so113610480wmn.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 10:10:14 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id u129si19376285wmd.50.2016.04.11.10.10.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 10:10:13 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id f198so154505576wme.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 10:10:13 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v1] mm, kasan: don't call kasan_krealloc() from ksize(). Add a ksize() test.
Date: Mon, 11 Apr 2016 19:10:08 +0200
Message-Id: <192b213b1a3518e98ed7e458aae19283b415ce3d.1460394567.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Instead of calling kasan_krealloc(), which replaces the memory allocation
stack ID (if stack depot is used), just unpoison the whole memory chunk.
Add a test that makes sure ksize() unpoisons the whole chunk.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
 lib/test_kasan.c | 20 ++++++++++++++++++++
 mm/slab.c        |  2 +-
 mm/slub.c        |  5 +++--
 3 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 82169fb..48e5a0b 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -344,6 +344,25 @@ static noinline void __init kasan_stack_oob(void)
 	*(volatile char *)p;
 }
 
+static noinline void __init ksize_unpoisons_memory(void)
+{
+	char *ptr;
+	size_t size = 123, real_size = size;
+
+	pr_info("ksize() unpoisons the whole allocated chunk\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+	real_size = ksize(ptr);
+	/* This access doesn't trigger an error. */
+	ptr[size] = 'x';
+	/* This one does. */
+	ptr[real_size] = 'y';
+	kfree(ptr);
+}
+
 static int __init kmalloc_tests_init(void)
 {
 	kmalloc_oob_right();
@@ -367,6 +386,7 @@ static int __init kmalloc_tests_init(void)
 	kmem_cache_oob();
 	kasan_stack_oob();
 	kasan_global_oob();
+	ksize_unpoisons_memory();
 	return -EAGAIN;
 }
 
diff --git a/mm/slab.c b/mm/slab.c
index 17e2848..de46319 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4324,7 +4324,7 @@ size_t ksize(const void *objp)
 	/* We assume that ksize callers could use the whole allocated area,
 	 * so we need to unpoison this area.
 	 */
-	kasan_krealloc(objp, size, GFP_NOWAIT);
+	kasan_unpoison_shadow(objp, size);
 
 	return size;
 }
diff --git a/mm/slub.c b/mm/slub.c
index 4dbb109e..62194e2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3635,8 +3635,9 @@ size_t ksize(const void *object)
 {
 	size_t size = __ksize(object);
 	/* We assume that ksize callers could use whole allocated area,
-	   so we need unpoison this area. */
-	kasan_krealloc(object, size, GFP_NOWAIT);
+	 * so we need to unpoison this area.
+	 */
+	kasan_unpoison_shadow(object, size);
 	return size;
 }
 EXPORT_SYMBOL(ksize);
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
