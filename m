Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBEC66B0261
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 07:44:48 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id d7so1255640wre.15
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 04:44:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 123sor5058698wme.25.2017.12.27.04.44.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Dec 2017 04:44:47 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 5/5] kasan: detect invalid frees
Date: Wed, 27 Dec 2017 13:44:36 +0100
Message-Id: <cb569193190356beb018a03bb8d6fbae67e7adbc.1514378558.git.dvyukov@google.com>
In-Reply-To: <cover.1514378558.git.dvyukov@google.com>
References: <cover.1514378558.git.dvyukov@google.com>
In-Reply-To: <cover.1514378558.git.dvyukov@google.com>
References: <cover.1514378558.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>

Detect frees of pointers into middle of heap objects.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: kasan-dev@googlegroups.com
---
 lib/test_kasan.c | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.c |  6 ++++++
 2 files changed, 56 insertions(+)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index e9c5d765be66..a808d81b409d 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -523,6 +523,54 @@ static noinline void __init kasan_alloca_oob_right(void)
 	*(volatile char *)p;
 }
 
+static noinline void __init kmem_cache_double_free(void)
+{
+	char *p;
+	size_t size = 200;
+	struct kmem_cache *cache;
+
+	cache = kmem_cache_create("test_cache", size, 0, 0, NULL);
+	if (!cache) {
+		pr_err("Cache allocation failed\n");
+		return;
+	}
+	pr_info("double-free on heap object\n");
+	p = kmem_cache_alloc(cache, GFP_KERNEL);
+	if (!p) {
+		pr_err("Allocation failed\n");
+		kmem_cache_destroy(cache);
+		return;
+	}
+
+	kmem_cache_free(cache, p);
+	kmem_cache_free(cache, p);
+	kmem_cache_destroy(cache);
+}
+
+static noinline void __init kmem_cache_invalid_free(void)
+{
+	char *p;
+	size_t size = 200;
+	struct kmem_cache *cache;
+
+	cache = kmem_cache_create("test_cache", size, 0, SLAB_TYPESAFE_BY_RCU,
+				  NULL);
+	if (!cache) {
+		pr_err("Cache allocation failed\n");
+		return;
+	}
+	pr_info("invalid-free of heap object\n");
+	p = kmem_cache_alloc(cache, GFP_KERNEL);
+	if (!p) {
+		pr_err("Allocation failed\n");
+		kmem_cache_destroy(cache);
+		return;
+	}
+
+	kmem_cache_free(cache, p + 1);
+	kmem_cache_destroy(cache);
+}
+
 static int __init kmalloc_tests_init(void)
 {
 	/*
@@ -560,6 +608,8 @@ static int __init kmalloc_tests_init(void)
 	ksize_unpoisons_memory();
 	copy_user_test();
 	use_after_scope_test();
+	kmem_cache_double_free();
+	kmem_cache_invalid_free();
 
 	kasan_restore_multi_shot(multishot);
 
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 578843fab5dc..3fb497d4fbf8 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -495,6 +495,12 @@ static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
 	s8 shadow_byte;
 	unsigned long rounded_up_size;
 
+	if (unlikely(nearest_obj(cache, virt_to_head_page(object), object) !=
+	    object)) {
+		kasan_report_invalid_free(object, ip);
+		return true;
+	}
+
 	/* RCU slabs could be legally used after free within the RCU period */
 	if (unlikely(cache->flags & SLAB_TYPESAFE_BY_RCU))
 		return false;
-- 
2.15.1.620.gb9897f4670-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
