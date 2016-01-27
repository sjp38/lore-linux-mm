Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id F16F8680F7F
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:25:33 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id n5so39836020wmn.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:25:33 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id k4si10045163wje.12.2016.01.27.10.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 10:25:28 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id l66so16090036wml.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:25:28 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v1 7/8] kasan: Changed kmalloc_large_oob_right, added kmalloc_pagealloc_oob_right
Date: Wed, 27 Jan 2016 19:25:12 +0100
Message-Id: <41041db4c8ee177dbc05341b0430da2e282948c3.1453918525.git.glider@google.com>
In-Reply-To: <cover.1453918525.git.glider@google.com>
References: <cover.1453918525.git.glider@google.com>
In-Reply-To: <cover.1453918525.git.glider@google.com>
References: <cover.1453918525.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Signed-off-by: Alexander Potapenko <glider@google.com>
---
 lib/test_kasan.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 5498a78..822c804 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -65,7 +65,8 @@ static noinline void __init kmalloc_node_oob_right(void)
 	kfree(ptr);
 }
 
-static noinline void __init kmalloc_large_oob_right(void)
+#ifdef CONFIG_SLUB
+static noinline void __init kmalloc_pagealloc_oob_right(void)
 {
 	char *ptr;
 	size_t size;
@@ -85,6 +86,18 @@ static noinline void __init kmalloc_large_oob_right(void)
 		size = KMALLOC_MAX_CACHE_SIZE + 10;
 	}
 
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
@@ -341,6 +354,9 @@ static int __init kmalloc_tests_init(void)
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
