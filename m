Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5A46B0260
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 11:31:30 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so18967450lfw.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 08:31:30 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id q197si14173563wmb.145.2016.07.28.08.31.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 08:31:28 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id o80so113731487wme.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 08:31:28 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v8 1/3] mm, kasan: account for object redzone in SLUB's nearest_obj()
Date: Thu, 28 Jul 2016 17:31:17 +0200
Message-Id: <1469719879-11761-2-git-send-email-glider@google.com>
In-Reply-To: <1469719879-11761-1-git-send-email-glider@google.com>
References: <1469719879-11761-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com, kcc@google.com, aryabinin@virtuozzo.com, adech.fo@gmail.com, cl@linux.com, akpm@linux-foundation.org, rostedt@goodmis.org, js1304@gmail.com, iamjoonsoo.kim@lge.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When looking up the nearest SLUB object for a given address, correctly
calculate its offset if SLAB_RED_ZONE is enabled for that cache.

Previously, when KASAN had detected an error on an object from a cache
with SLAB_RED_ZONE set, the actual start address of the object was
miscalculated, which led to random stacks having been reported.

Fixes: 7ed2f9e663854db ("mm, kasan: SLAB support")
Signed-off-by: Alexander Potapenko <glider@google.com>
---
v8: - Updated the patch description
---
 include/linux/slub_def.h | 10 ++++++----
 mm/slub.c                |  2 +-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 5624c1f..cf501cf 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -119,15 +119,17 @@ static inline void sysfs_slab_remove(struct kmem_cache *s)
 void object_err(struct kmem_cache *s, struct page *page,
 		u8 *object, char *reason);
 
+void *fixup_red_left(struct kmem_cache *s, void *p);
+
 static inline void *nearest_obj(struct kmem_cache *cache, struct page *page,
 				void *x) {
 	void *object = x - (x - page_address(page)) % cache->size;
 	void *last_object = page_address(page) +
 		(page->objects - 1) * cache->size;
-	if (unlikely(object > last_object))
-		return last_object;
-	else
-		return object;
+	void *result = (unlikely(object > last_object)) ? last_object : object;
+
+	result = fixup_red_left(cache, result);
+	return result;
 }
 
 #endif /* _LINUX_SLUB_DEF_H */
diff --git a/mm/slub.c b/mm/slub.c
index f9da871..1cdde1a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -124,7 +124,7 @@ static inline int kmem_cache_debug(struct kmem_cache *s)
 #endif
 }
 
-static inline void *fixup_red_left(struct kmem_cache *s, void *p)
+inline void *fixup_red_left(struct kmem_cache *s, void *p)
 {
 	if (kmem_cache_debug(s) && s->flags & SLAB_RED_ZONE)
 		p += s->red_left_pad;
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
