Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD955831F8
	for <linux-mm@kvack.org>; Fri, 19 May 2017 17:01:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n75so64175339pfh.0
        for <linux-mm@kvack.org>; Fri, 19 May 2017 14:01:20 -0700 (PDT)
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com. [209.85.192.171])
        by mx.google.com with ESMTPS id q190si9214745pfb.137.2017.05.19.14.01.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 14:01:19 -0700 (PDT)
Received: by mail-pf0-f171.google.com with SMTP id n23so44944483pfb.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 14:01:19 -0700 (PDT)
From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH 1/3] mm/slub: Only define kmalloc_large_node_hook() for NUMA systems
Date: Fri, 19 May 2017 14:00:34 -0700
Message-Id: <20170519210036.146880-2-mka@chromium.org>
In-Reply-To: <20170519210036.146880-1-mka@chromium.org>
References: <20170519210036.146880-1-mka@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>

The function is only used when CONFIG_NUMA=y. Placing it in an #ifdef
block fixes the following warning when building with clang:

mm/slub.c:1246:20: error: unused function 'kmalloc_large_node_hook'
    [-Werror,-Wunused-function]

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 mm/slub.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 57e5156f02be..66e1046435b7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1313,11 +1313,14 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
  * Hooks for other subsystems that check memory allocations. In a typical
  * production configuration these hooks all should produce no code at all.
  */
+
+#ifdef CONFIG_NUMA
 static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
 {
 	kmemleak_alloc(ptr, size, 1, flags);
 	kasan_kmalloc_large(ptr, size, flags);
 }
+#endif
 
 static inline void kfree_hook(const void *x)
 {
-- 
2.13.0.303.g4ebf302169-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
