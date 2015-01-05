Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E37F96B0070
	for <linux-mm@kvack.org>; Sun,  4 Jan 2015 20:37:42 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so27478277pab.6
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 17:37:42 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id gn10si76674755pbc.136.2015.01.04.17.37.39
        for <linux-mm@kvack.org>;
        Sun, 04 Jan 2015 17:37:41 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/6] mm/slab: remove kmemleak_erase() call
Date: Mon,  5 Jan 2015 10:37:27 +0900
Message-Id: <1420421851-3281-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

We already call kmemleak_no_scan() in initialization step of array cache,
so kmemleak doesn't scan array cache. Therefore, we don't need to call
kmemleak_erase() here.

And, this call is the last caller of kmemleak_erase(), so remove
kmemleak_erase() definition completely.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/kmemleak.h |    8 --------
 mm/slab.c                |   12 ------------
 2 files changed, 20 deletions(-)

diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
index e705467..8470733 100644
--- a/include/linux/kmemleak.h
+++ b/include/linux/kmemleak.h
@@ -52,11 +52,6 @@ static inline void kmemleak_free_recursive(const void *ptr, unsigned long flags)
 		kmemleak_free(ptr);
 }
 
-static inline void kmemleak_erase(void **ptr)
-{
-	*ptr = NULL;
-}
-
 #else
 
 static inline void kmemleak_init(void)
@@ -98,9 +93,6 @@ static inline void kmemleak_ignore(const void *ptr)
 static inline void kmemleak_scan_area(const void *ptr, size_t size, gfp_t gfp)
 {
 }
-static inline void kmemleak_erase(void **ptr)
-{
-}
 static inline void kmemleak_no_scan(const void *ptr)
 {
 }
diff --git a/mm/slab.c b/mm/slab.c
index 1150c8b..9aa58fc 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2942,20 +2942,8 @@ static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 
 	STATS_INC_ALLOCMISS(cachep);
 	objp = cache_alloc_refill(cachep, flags, force_refill);
-	/*
-	 * the 'ac' may be updated by cache_alloc_refill(),
-	 * and kmemleak_erase() requires its correct value.
-	 */
-	ac = cpu_cache_get(cachep);
 
 out:
-	/*
-	 * To avoid a false negative, if an object that is in one of the
-	 * per-CPU caches is leaked, we need to make sure kmemleak doesn't
-	 * treat the array pointers as a reference to the object.
-	 */
-	if (objp)
-		kmemleak_erase(&ac->entry[ac->avail]);
 	return objp;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
