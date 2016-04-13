Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id CD3C8828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 07:20:44 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id n3so71681341wmn.0
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 04:20:44 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id o3si27174966wjd.55.2016.04.13.04.20.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 04:20:43 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id n3so71680762wmn.0
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 04:20:43 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v2 2/2] mm, kasan: add a ksize() test
Date: Wed, 13 Apr 2016 13:20:10 +0200
Message-Id: <562d43518232cf7d26297ee004255a083b084071.1460545373.git.glider@google.com>
In-Reply-To: <2126fe9ca8c3a4698c0ad7aae652dce28e261182.1460545373.git.glider@google.com>
References: <2126fe9ca8c3a4698c0ad7aae652dce28e261182.1460545373.git.glider@google.com>
In-Reply-To: <2126fe9ca8c3a4698c0ad7aae652dce28e261182.1460545373.git.glider@google.com>
References: <2126fe9ca8c3a4698c0ad7aae652dce28e261182.1460545373.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, dvyukov@google.com, cl@linux.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Add a test that makes sure ksize() unpoisons the whole chunk.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
v2: - splitted v1 into two patches
---
 lib/test_kasan.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

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
 
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
