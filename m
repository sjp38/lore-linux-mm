Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9BA6B025A
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:25:21 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p63so39771459wmp.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:25:21 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id p137si25351645wmb.0.2016.01.27.10.25.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 10:25:20 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id n5so41728930wmn.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:25:20 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v1 1/8] kasan: Change the behavior of kmalloc_large_oob_right test
Date: Wed, 27 Jan 2016 19:25:06 +0100
Message-Id: <35b553cafcd5b77838aeaf5548b457dfa09e30cf.1453918525.git.glider@google.com>
In-Reply-To: <cover.1453918525.git.glider@google.com>
References: <cover.1453918525.git.glider@google.com>
In-Reply-To: <cover.1453918525.git.glider@google.com>
References: <cover.1453918525.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

depending on which allocator (SLAB or SLUB) is being used

Signed-off-by: Alexander Potapenko <glider@google.com>
---
 lib/test_kasan.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index c32f3b0..66dd92f 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -68,7 +68,22 @@ static noinline void __init kmalloc_node_oob_right(void)
 static noinline void __init kmalloc_large_oob_right(void)
 {
 	char *ptr;
-	size_t size = KMALLOC_MAX_CACHE_SIZE + 10;
+	size_t size;
+
+	if (KMALLOC_MAX_CACHE_SIZE == KMALLOC_MAX_SIZE) {
+		/*
+		 * We're using the SLAB allocator. Allocate a chunk that fits
+		 * into a slab.
+		 */
+		size = KMALLOC_MAX_CACHE_SIZE - 256;
+	} else {
+		/*
+		 * KMALLOC_MAX_SIZE > KMALLOC_MAX_CACHE_SIZE.
+		 * We're using the SLUB allocator. Allocate a chunk that does
+		 * not fit into a slab to trigger the page allocator.
+		 */
+		size = KMALLOC_MAX_CACHE_SIZE + 10;
+	}
 
 	pr_info("kmalloc large allocation: out-of-bounds to right\n");
 	ptr = kmalloc(size, GFP_KERNEL);
-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
