Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 544676B025F
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 12:49:56 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w207so192196801oiw.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:49:56 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10094.outbound.protection.outlook.com. [40.107.1.94])
        by mx.google.com with ESMTPS id v27si10196435iov.11.2016.07.15.09.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Jul 2016 09:49:55 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH]  mm-kasan-switch-slub-to-stackdepot-enable-memory-quarantine-for-slub-fix
Date: Fri, 15 Jul 2016 19:50:23 +0300
Message-ID: <1468601423-28676-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: glider@google.com, dvyukov@google.com, iamjoonsoo.kim@lge.com, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

- Remove CONFIG_SLAB ifdefs. The code works just fine with both allocators.
- Reset metada offsets if metadata doesn't fit. Otherwise kasan_metadata_size()
will give us the wrong results.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/kasan/kasan.c | 17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index d92a7a2..b6f99e8 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -372,9 +372,7 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 			unsigned long *flags)
 {
 	int redzone_adjust;
-#ifdef CONFIG_SLAB
 	int orig_size = *size;
-#endif
 
 	/* Add alloc meta. */
 	cache->kasan_info.alloc_meta_offset = *size;
@@ -392,25 +390,20 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 	if (redzone_adjust > 0)
 		*size += redzone_adjust;
 
-#ifdef CONFIG_SLAB
-	*size = min(KMALLOC_MAX_SIZE,
-		    max(*size,
-			cache->object_size +
-			optimal_redzone(cache->object_size)));
+	*size = min(KMALLOC_MAX_SIZE, max(*size, cache->object_size +
+					optimal_redzone(cache->object_size)));
+
 	/*
 	 * If the metadata doesn't fit, don't enable KASAN at all.
 	 */
 	if (*size <= cache->kasan_info.alloc_meta_offset ||
 			*size <= cache->kasan_info.free_meta_offset) {
+		cache->kasan_info.alloc_meta_offset = 0;
+		cache->kasan_info.free_meta_offset = 0;
 		*size = orig_size;
 		return;
 	}
-#else
-	*size = max(*size,
-			cache->object_size +
-			optimal_redzone(cache->object_size));
 
-#endif
 	*flags |= SLAB_KASAN;
 }
 
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
