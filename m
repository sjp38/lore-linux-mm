Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id ADCC96B0253
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:30:53 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so72643797wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 05:30:53 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id t23si4076752wmt.106.2016.02.26.05.30.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 05:30:52 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id a4so70054045wme.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 05:30:52 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v3 1/7] kasan: Modify kmalloc_large_oob_right(), add kmalloc_pagealloc_oob_right()
Date: Fri, 26 Feb 2016 14:30:40 +0100
Message-Id: <3d20f2bc34a72acdb407a9f8b95249ed7dd9fbe3.1456492360.git.glider@google.com>
In-Reply-To: <cover.1456492360.git.glider@google.com>
References: <cover.1456492360.git.glider@google.com>
In-Reply-To: <cover.1456492360.git.glider@google.com>
References: <cover.1456492360.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Rename kmalloc_large_oob_right() to kmalloc_pagealloc_oob_right(), as the
test only checks the page allocator functionality.
Also reimplement kmalloc_large_oob_right() so that the test allocates a
large enough chunk of memory that still does not trigger the page
allocator fallback.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
v2: - Merged "kasan: Change the behavior of kmalloc_large_oob_right" and
  "kasan: Changed kmalloc_large_oob_right, added kmalloc_pagealloc_oob_right"
  from v1

v3: - Minor description changes
---
 lib/test_kasan.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index c32f3b0..90ad74f 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -65,11 +65,34 @@ static noinline void __init kmalloc_node_oob_right(void)
 	kfree(ptr);
 }
 
-static noinline void __init kmalloc_large_oob_right(void)
+#ifdef CONFIG_SLUB
+static noinline void __init kmalloc_pagealloc_oob_right(void)
 {
 	char *ptr;
 	size_t size = KMALLOC_MAX_CACHE_SIZE + 10;
 
+	/* Allocate a chunk that does not fit into a SLUB cache to trigger
+	 * the page allocator fallback.
+	 */
+	pr_info("kmalloc pagealloc allocation: out-of-bounds to right\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	ptr[size] = 0;
+	kfree(ptr);
+}
+#endif
+
+static noinline void __init kmalloc_large_oob_right(void)
+{
+	char *ptr;
+	size_t size = KMALLOC_MAX_CACHE_SIZE - 256;
+	/* Allocate a chunk that is large enough, but still fits into a slab
+	 * and does not trigger the page allocator fallback in SLUB.
+	 */
 	pr_info("kmalloc large allocation: out-of-bounds to right\n");
 	ptr = kmalloc(size, GFP_KERNEL);
 	if (!ptr) {
@@ -324,6 +347,9 @@ static int __init kmalloc_tests_init(void)
 	kmalloc_oob_right();
 	kmalloc_oob_left();
 	kmalloc_node_oob_right();
+#ifdef CONFIG_SLUB
+	kmalloc_pagealloc_oob_right();
+#endif
 	kmalloc_large_oob_right();
 	kmalloc_oob_krealloc_more();
 	kmalloc_oob_krealloc_less();
-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
