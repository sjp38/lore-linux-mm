Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 800ED6B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 07:44:44 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id s5so18911924wra.3
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 04:44:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g192sor4519360wmd.32.2017.12.27.04.44.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Dec 2017 04:44:43 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 4/5] kasan: unify code between kasan_slab_free() and kasan_poison_kfree()
Date: Wed, 27 Dec 2017 13:44:35 +0100
Message-Id: <385493d863acf60408be219a021c3c8e27daa96f.1514378558.git.dvyukov@google.com>
In-Reply-To: <cover.1514378558.git.dvyukov@google.com>
References: <cover.1514378558.git.dvyukov@google.com>
In-Reply-To: <cover.1514378558.git.dvyukov@google.com>
References: <cover.1514378558.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>

Both of these functions deal with freeing of slab objects.
However, kasan_poison_kfree() mishandles SLAB_TYPESAFE_BY_RCU
(must also not poison such objects) and does not detect double-frees.

Unify code between these functions.
This solves both of the problems and allows to add more common code
(e.g. detection of invalid frees).

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: kasan-dev@googlegroups.com
---
 mm/kasan/kasan.c | 28 ++++++++++++----------------
 1 file changed, 12 insertions(+), 16 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 77c103748728..578843fab5dc 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -489,21 +489,11 @@ void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 	kasan_kmalloc(cache, object, cache->object_size, flags);
 }
 
-static void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
-{
-	unsigned long size = cache->object_size;
-	unsigned long rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
-
-	/* RCU slabs could be legally used after free within the RCU period */
-	if (unlikely(cache->flags & SLAB_TYPESAFE_BY_RCU))
-		return;
-
-	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
-}
-
-bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
+static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
+			      unsigned long ip, bool quarantine)
 {
 	s8 shadow_byte;
+	unsigned long rounded_up_size;
 
 	/* RCU slabs could be legally used after free within the RCU period */
 	if (unlikely(cache->flags & SLAB_TYPESAFE_BY_RCU))
@@ -515,9 +505,10 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
 		return true;
 	}
 
-	kasan_poison_slab_free(cache, object);
+	rounded_up_size = round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE);
+	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
 
-	if (unlikely(!(cache->flags & SLAB_KASAN)))
+	if (!quarantine || unlikely(!(cache->flags & SLAB_KASAN)))
 		return false;
 
 	set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT);
@@ -525,6 +516,11 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
 	return true;
 }
 
+bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
+{
+	return __kasan_slab_free(cache, object, ip, true);
+}
+
 void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 		   gfp_t flags)
 {
@@ -602,7 +598,7 @@ void kasan_poison_kfree(void *ptr, unsigned long ip)
 		kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
 				KASAN_FREE_PAGE);
 	} else {
-		kasan_poison_slab_free(page->slab_cache, ptr);
+		__kasan_slab_free(page->slab_cache, ptr, ip, false);
 	}
 }
 
-- 
2.15.1.620.gb9897f4670-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
