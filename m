Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 35CDC6B0261
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 11:31:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so21146786wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 08:31:32 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id z1si13678123wjc.124.2016.07.28.08.31.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 08:31:30 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id q128so256745548wma.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 08:31:29 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v8 2/3] mm, kasan: align free_meta_offset on sizeof(void*)
Date: Thu, 28 Jul 2016 17:31:18 +0200
Message-Id: <1469719879-11761-3-git-send-email-glider@google.com>
In-Reply-To: <1469719879-11761-1-git-send-email-glider@google.com>
References: <1469719879-11761-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com, kcc@google.com, aryabinin@virtuozzo.com, adech.fo@gmail.com, cl@linux.com, akpm@linux-foundation.org, rostedt@goodmis.org, js1304@gmail.com, iamjoonsoo.kim@lge.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When free_meta_offset is not zero, it is usually aligned on 4 bytes,
because the size of preceding kasan_alloc_meta is aligned on 4 bytes.
As a result, accesses to kasan_free_meta fields may be misaligned.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
 mm/kasan/kasan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 6845f92..0379551 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -390,7 +390,8 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 	/* Add free meta. */
 	if (cache->flags & SLAB_DESTROY_BY_RCU || cache->ctor ||
 	    cache->object_size < sizeof(struct kasan_free_meta)) {
-		cache->kasan_info.free_meta_offset = *size;
+		cache->kasan_info.free_meta_offset =
+			ALIGN(*size, sizeof(void *));
 		*size += sizeof(struct kasan_free_meta);
 	}
 	redzone_adjust = optimal_redzone(cache->object_size) -
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
