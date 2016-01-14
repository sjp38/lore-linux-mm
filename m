Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 880288308B
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:25:00 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id q63so96348254pfb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:25:00 -0800 (PST)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id f7si6870445pfd.188.2016.01.13.21.24.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:24:59 -0800 (PST)
Received: by mail-pa0-x241.google.com with SMTP id gi1so35229571pac.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:59 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 10/16] mm/slab: align cache size first before determination of OFF_SLAB candidate
Date: Thu, 14 Jan 2016 14:24:23 +0900
Message-Id: <1452749069-15334-11-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Finding suitable OFF_SLAB candidate is more related to aligned cache size
rather than original size. Same reasoning can be applied to
the debug pagealloc candidate. So, this patch moves up alignment fixup
to proper position.

>From that point, size is aligned so we can remove some alignment fixups.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index fe17acc..3a319f5 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2126,6 +2126,17 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		else
 			size += BYTES_PER_WORD;
 	}
+#endif
+
+	size = ALIGN(size, cachep->align);
+	/*
+	 * We should restrict the number of objects in a slab to implement
+	 * byte sized index. Refer comment on SLAB_OBJ_MIN_SIZE definition.
+	 */
+	if (FREELIST_BYTE_INDEX && size < SLAB_OBJ_MIN_SIZE)
+		size = ALIGN(SLAB_OBJ_MIN_SIZE, cachep->align);
+
+#if DEBUG
 	/*
 	 * To activate debug pagealloc, off-slab management is necessary
 	 * requirement. In early phase of initialization, small sized slab
@@ -2136,8 +2147,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	if (debug_pagealloc_enabled() && (flags & SLAB_POISON) &&
 		!slab_early_init && size >= kmalloc_size(INDEX_NODE) &&
 		size >= 256 && cachep->object_size > cache_line_size() &&
-		ALIGN(size, cachep->align) < PAGE_SIZE) {
-		cachep->obj_offset += PAGE_SIZE - ALIGN(size, cachep->align);
+		size < PAGE_SIZE) {
+		cachep->obj_offset += PAGE_SIZE - size;
 		size = PAGE_SIZE;
 	}
 #endif
@@ -2149,20 +2160,13 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	 * SLAB_NOLEAKTRACE to avoid recursive calls into kmemleak)
 	 */
 	if (size >= OFF_SLAB_MIN_SIZE && !slab_early_init &&
-	    !(flags & SLAB_NOLEAKTRACE))
+	    !(flags & SLAB_NOLEAKTRACE)) {
 		/*
 		 * Size is large, assume best to place the slab management obj
 		 * off-slab (should allow better packing of objs).
 		 */
 		flags |= CFLGS_OFF_SLAB;
-
-	size = ALIGN(size, cachep->align);
-	/*
-	 * We should restrict the number of objects in a slab to implement
-	 * byte sized index. Refer comment on SLAB_OBJ_MIN_SIZE definition.
-	 */
-	if (FREELIST_BYTE_INDEX && size < SLAB_OBJ_MIN_SIZE)
-		size = ALIGN(SLAB_OBJ_MIN_SIZE, cachep->align);
+	}
 
 	left_over = calculate_slab_order(cachep, size, flags);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
