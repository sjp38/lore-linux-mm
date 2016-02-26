Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id CD881828E1
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:01:49 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id fl4so45435470pad.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:49 -0800 (PST)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id vz3si2071996pab.93.2016.02.25.22.01.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:01:49 -0800 (PST)
Received: by mail-pf0-x22a.google.com with SMTP id q63so46292307pfb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:49 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 05/17] mm/slab: use more appropriate condition check for debug_pagealloc
Date: Fri, 26 Feb 2016 15:01:12 +0900
Message-Id: <1456466484-3442-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

debug_pagealloc debugging is related to SLAB_POISON flag rather than
FORCED_DEBUG option, although FORCED_DEBUG option will enable SLAB_POISON.
Fix it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 4807cf4..8bca9be 100644
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
