Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D33A68308B
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:25:06 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id cy9so370760555pac.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:25:06 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id f17si6879880pfd.163.2016.01.13.21.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:25:06 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id 65so6929416pfd.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:25:06 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 12/16] mm/slab: do not change cache size if debug pagealloc isn't possible
Date: Thu, 14 Jan 2016 14:24:25 +0900
Message-Id: <1452749069-15334-13-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We can fail to setup off slab in some conditions. Even in this case,
debug pagealloc increases cache size to PAGE_SIZE in advance and
it is waste because debug pagealloc cannot work for it when it isn't
the off slab. To improve this situation, this patch checks first
that this cache with increased size is suitable for off slab.
It actually increases cache size when it is suitable for off-slab,
so possible waste is removed.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 7a253a9..b0f6eda 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2207,10 +2207,17 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	 */
 	if (debug_pagealloc_enabled() && (flags & SLAB_POISON) &&
 		!slab_early_init && size >= kmalloc_size(INDEX_NODE) &&
-		size >= 256 && cachep->object_size > cache_line_size() &&
-		size < PAGE_SIZE) {
-		cachep->obj_offset += PAGE_SIZE - size;
-		size = PAGE_SIZE;
+		size >= 256 && cachep->object_size > cache_line_size()) {
+		if (size < PAGE_SIZE || size % PAGE_SIZE == 0) {
+			size_t tmp_size = ALIGN(size, PAGE_SIZE);
+
+			if (set_off_slab_cache(cachep, tmp_size, flags)) {
+				flags |= CFLGS_OFF_SLAB;
+				cachep->obj_offset += tmp_size - size;
+				size = tmp_size;
+				goto done;
+			}
+		}
 	}
 #endif
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
