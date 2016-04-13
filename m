Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE4E828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 07:20:31 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id a140so95314674wma.0
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 04:20:31 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id 143si697834wma.114.2016.04.13.04.20.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 04:20:30 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id n3so71671077wmn.0
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 04:20:30 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v2 1/2] mm, kasan: don't call kasan_krealloc() from ksize().
Date: Wed, 13 Apr 2016 13:20:09 +0200
Message-Id: <2126fe9ca8c3a4698c0ad7aae652dce28e261182.1460545373.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, dvyukov@google.com, cl@linux.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Instead of calling kasan_krealloc(), which replaces the memory allocation
stack ID (if stack depot is used), just unpoison the whole memory chunk.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
v2: - splitted v1 into two patches
---
 mm/slab.c | 2 +-
 mm/slub.c | 5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 17e2848..de46319 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4324,7 +4324,7 @@ size_t ksize(const void *objp)
 	/* We assume that ksize callers could use the whole allocated area,
 	 * so we need to unpoison this area.
 	 */
-	kasan_krealloc(objp, size, GFP_NOWAIT);
+	kasan_unpoison_shadow(objp, size);
 
 	return size;
 }
diff --git a/mm/slub.c b/mm/slub.c
index 4dbb109e..62194e2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3635,8 +3635,9 @@ size_t ksize(const void *object)
 {
 	size_t size = __ksize(object);
 	/* We assume that ksize callers could use whole allocated area,
-	   so we need unpoison this area. */
-	kasan_krealloc(object, size, GFP_NOWAIT);
+	 * so we need to unpoison this area.
+	 */
+	kasan_unpoison_shadow(object, size);
 	return size;
 }
 EXPORT_SYMBOL(ksize);
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
