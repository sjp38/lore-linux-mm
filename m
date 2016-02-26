Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 71724828E6
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:02:07 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id e127so46388257pfe.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:07 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id c74si17602469pfj.65.2016.02.25.22.02.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:02:06 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id ho8so46723477pac.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:06 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 10/17] mm/slab: align cache size first before determination of OFF_SLAB candidate
Date: Fri, 26 Feb 2016 15:01:17 +0900
Message-Id: <1456466484-3442-11-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Finding suitable OFF_SLAB candidate is more related to aligned cache size
rather than original size.  Same reasoning can be applied to the debug
pagealloc candidate.  So, this patch moves up alignment fixup to proper
position.  From that point, size is aligned so we can remove some
alignment fixups.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index b3d91b0..d5dffc8 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2125,6 +2125,17 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
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
@@ -2135,8 +2146,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
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
@@ -2148,20 +2159,13 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
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
