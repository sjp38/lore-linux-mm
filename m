Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8B176B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 06:44:32 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id j12so66618607lbo.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 03:44:32 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id fj5si49773952wjb.227.2016.05.31.03.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 03:44:31 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id n129so124485097wmn.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 03:44:31 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH] mm, kasan: introduce a special shadow value for allocator metadata
Date: Tue, 31 May 2016 12:44:26 +0200
Message-Id: <1464691466-59010-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Add a special shadow value to distinguish accesses to KASAN-specific
allocator metadata.

Unlike AddressSanitizer in the userspace, KASAN lets the kernel proceed
after a memory error. However a write to the kmalloc metadata may cause
memory corruptions that will make the tool itself unreliable and induce
crashes later on. Warning about such corruptions will ease the
debugging.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
 mm/kasan/kasan.c  | 15 +++++++++++++++
 mm/kasan/kasan.h  |  1 +
 mm/kasan/report.c |  3 +++
 3 files changed, 19 insertions(+)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 18b6a2b..c590366 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -518,6 +518,19 @@ void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
 		return;
 
 	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
+#ifdef CONFIG_SLAB
+	if (cache->flags & SLAB_KASAN) {
+		struct kasan_alloc_meta *alloc_info =
+			get_alloc_info(cache, object);
+		struct kasan_free_meta *free_info =
+			get_free_info(cache, object);
+		kasan_poison_shadow(alloc_info,
+			sizeof(struct kasan_alloc_meta), KASAN_KMALLOC_META);
+		kasan_poison_shadow(free_info,
+			sizeof(struct kasan_free_meta), KASAN_KMALLOC_META);
+	}
+#endif
+
 }
 
 bool kasan_slab_free(struct kmem_cache *cache, void *object)
@@ -584,6 +597,8 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 		alloc_info->state = KASAN_STATE_ALLOC;
 		alloc_info->alloc_size = size;
 		set_track(&alloc_info->track, flags);
+		kasan_poison_shadow(alloc_info,
+			sizeof(struct kasan_alloc_meta), KASAN_KMALLOC_META);
 	}
 #endif
 }
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index fb87923..1a0d82d 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -12,6 +12,7 @@
 #define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
 #define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
 #define KASAN_GLOBAL_REDZONE    0xFA  /* redzone for global variable */
+#define KASAN_KMALLOC_META      0xF9  /* redzone for kmalloc metadata */
 
 /*
  * Stack redzone shadow values
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index b3c122d..b6d3753 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -90,6 +90,9 @@ static void print_error_description(struct kasan_access_info *info)
 	case KASAN_KMALLOC_FREE:
 		bug_type = "use-after-free";
 		break;
+	case KASAN_KMALLOC_META:
+		bug_type = "touching kmalloc metadata";
+		break;
 	}
 
 	pr_err("BUG: KASAN: %s in %pS at addr %p\n",
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
