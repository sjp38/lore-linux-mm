Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 135AD828E2
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:24:44 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id e65so93817743pfe.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:44 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id iu1si6918796pac.43.2016.01.13.21.24.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:24:43 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id 65so6923273pff.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:43 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 05/16] mm/slab: use more appropriate condition check for debug_pagealloc
Date: Thu, 14 Jan 2016 14:24:18 +0900
Message-Id: <1452749069-15334-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

debug_pagealloc debugging is related to SLAB_POISON flag rather than
FORCED_DEBUG option, although FORCED_DEBUG option will enable SLAB_POISON.
Fix it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 4b55516..1fcc338 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2169,7 +2169,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		else
 			size += BYTES_PER_WORD;
 	}
-#if FORCED_DEBUG && defined(CONFIG_DEBUG_PAGEALLOC)
 	/*
 	 * To activate debug pagealloc, off-slab management is necessary
 	 * requirement. In early phase of initialization, small sized slab
@@ -2177,7 +2176,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	 * to check size >= 256. It guarantees that all necessary small
 	 * sized slab is initialized in current slab initialization sequence.
 	 */
-	if (debug_pagealloc_enabled() &&
+	if (debug_pagealloc_enabled() && (flags & SLAB_POISON) &&
 		!slab_early_init && size >= kmalloc_size(INDEX_NODE) &&
 		size >= 256 && cachep->object_size > cache_line_size() &&
 		ALIGN(size, cachep->align) < PAGE_SIZE) {
@@ -2185,7 +2184,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		size = PAGE_SIZE;
 	}
 #endif
-#endif
 
 	/*
 	 * Determine if the slab management is 'on' or 'off' slab.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
