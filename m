Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 331F38308B
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:24:54 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id e65so93819950pfe.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:54 -0800 (PST)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id hh1si6923255pac.44.2016.01.13.21.24.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:24:53 -0800 (PST)
Received: by mail-pa0-x243.google.com with SMTP id yy13so27882256pab.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:53 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 08/16] mm/slab: remove object status buffer for DEBUG_SLAB_LEAK
Date: Thu, 14 Jan 2016 14:24:21 +0900
Message-Id: <1452749069-15334-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now, we don't use object status buffer in any setup. Remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 34 ++--------------------------------
 1 file changed, 2 insertions(+), 32 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9a64d8f..02bdb91 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -380,22 +380,8 @@ static void **dbg_userword(struct kmem_cache *cachep, void *objp)
 
 #endif
 
-#define OBJECT_FREE (0)
-#define OBJECT_ACTIVE (1)
-
 #ifdef CONFIG_DEBUG_SLAB_LEAK
 
-static void set_obj_status(struct page *page, int idx, int val)
-{
-	int freelist_size;
-	char *status;
-	struct kmem_cache *cachep = page->slab_cache;
-
-	freelist_size = cachep->num * sizeof(freelist_idx_t);
-	status = (char *)page->freelist + freelist_size;
-	status[idx] = val;
-}
-
 static inline bool is_store_user_clean(struct kmem_cache *cachep)
 {
 	return atomic_read(&cachep->store_user_clean) == 1;
@@ -413,7 +399,6 @@ static inline void set_store_user_dirty(struct kmem_cache *cachep)
 }
 
 #else
-static inline void set_obj_status(struct page *page, int idx, int val) {}
 static inline void set_store_user_dirty(struct kmem_cache *cachep) {}
 
 #endif
@@ -476,9 +461,6 @@ static size_t calculate_freelist_size(int nr_objs, size_t align)
 	size_t freelist_size;
 
 	freelist_size = nr_objs * sizeof(freelist_idx_t);
-	if (IS_ENABLED(CONFIG_DEBUG_SLAB_LEAK))
-		freelist_size += nr_objs * sizeof(char);
-
 	if (align)
 		freelist_size = ALIGN(freelist_size, align);
 
@@ -491,10 +473,7 @@ static int calculate_nr_objs(size_t slab_size, size_t buffer_size,
 	int nr_objs;
 	size_t remained_size;
 	size_t freelist_size;
-	int extra_space = 0;
 
-	if (IS_ENABLED(CONFIG_DEBUG_SLAB_LEAK))
-		extra_space = sizeof(char);
 	/*
 	 * Ignore padding for the initial guess. The padding
 	 * is at most @align-1 bytes, and @buffer_size is at
@@ -503,7 +482,7 @@ static int calculate_nr_objs(size_t slab_size, size_t buffer_size,
 	 * into the memory allocation when taking the padding
 	 * into account.
 	 */
-	nr_objs = slab_size / (buffer_size + idx_size + extra_space);
+	nr_objs = slab_size / (buffer_size + idx_size);
 
 	/*
 	 * This calculated number will be either the right
@@ -1961,16 +1940,13 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 			break;
 
 		if (flags & CFLGS_OFF_SLAB) {
-			size_t freelist_size_per_obj = sizeof(freelist_idx_t);
 			/*
 			 * Max number of objs-per-slab for caches which
 			 * use off-slab slabs. Needed to avoid a possible
 			 * looping condition in cache_grow().
 			 */
-			if (IS_ENABLED(CONFIG_DEBUG_SLAB_LEAK))
-				freelist_size_per_obj += sizeof(char);
 			offslab_limit = size;
-			offslab_limit /= freelist_size_per_obj;
+			offslab_limit /= sizeof(freelist_idx_t);
 
  			if (num > offslab_limit)
 				break;
@@ -2533,7 +2509,6 @@ static void cache_init_objs(struct kmem_cache *cachep,
 		if (cachep->ctor)
 			cachep->ctor(objp);
 #endif
-		set_obj_status(page, i, OBJECT_FREE);
 		set_free_obj(page, i, i);
 	}
 }
@@ -2745,7 +2720,6 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 	BUG_ON(objnr >= cachep->num);
 	BUG_ON(objp != index_to_obj(cachep, page, objnr));
 
-	set_obj_status(page, objnr, OBJECT_FREE);
 	if (cachep->flags & SLAB_POISON) {
 		poison_obj(cachep, objp, POISON_FREE);
 		slab_kernel_map(cachep, objp, 0, caller);
@@ -2878,8 +2852,6 @@ static inline void cache_alloc_debugcheck_before(struct kmem_cache *cachep,
 static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 				gfp_t flags, void *objp, unsigned long caller)
 {
-	struct page *page;
-
 	if (!objp)
 		return objp;
 	if (cachep->flags & SLAB_POISON) {
@@ -2904,8 +2876,6 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		*dbg_redzone2(cachep, objp) = RED_ACTIVE;
 	}
 
-	page = virt_to_head_page(objp);
-	set_obj_status(page, obj_to_index(cachep, page, objp), OBJECT_ACTIVE);
 	objp += obj_offset(cachep);
 	if (cachep->ctor && cachep->flags & SLAB_POISON)
 		cachep->ctor(objp);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
