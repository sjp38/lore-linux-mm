Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id BE3956B025F
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 14:13:01 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so16126930lfw.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:13:01 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id 78si4895307wmq.114.2016.07.12.11.13.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 11:13:00 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id f65so502197wmi.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:13:00 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v7 1/2] mm, kasan: account for object redzone in SLUB's nearest_obj()
Date: Tue, 12 Jul 2016 20:12:44 +0200
Message-Id: <1468347165-41906-2-git-send-email-glider@google.com>
In-Reply-To: <1468347165-41906-1-git-send-email-glider@google.com>
References: <1468347165-41906-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When looking up the nearest SLUB object for a given address, correctly
calculate its offset if SLAB_RED_ZONE is enabled for that cache.

Fixes: 7ed2f9e663854db ("mm, kasan: SLAB support")
Signed-off-by: Alexander Potapenko <glider@google.com>
---
 include/linux/slub_def.h | 10 ++++++----
 mm/slub.c                |  2 +-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d1faa01..b71b258 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -114,15 +114,17 @@ static inline void sysfs_slab_remove(struct kmem_cache *s)
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
index 825ff45..27cbef9 100644
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
