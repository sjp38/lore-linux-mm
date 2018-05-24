Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D9D376B000E
	for <linux-mm@kvack.org>; Thu, 24 May 2018 07:00:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e15-v6so920994wmh.6
        for <linux-mm@kvack.org>; Thu, 24 May 2018 04:00:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q27-v6si5453335edq.244.2018.05.24.04.00.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 04:00:23 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 2/5] mm, slab: allocate off-slab freelists as reclaimable when appropriate
Date: Thu, 24 May 2018 13:00:08 +0200
Message-Id: <20180524110011.1940-3-vbabka@suse.cz>
In-Reply-To: <20180524110011.1940-1-vbabka@suse.cz>
References: <20180524110011.1940-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>, Vlastimil Babka <vbabka@suse.cz>

In SLAB, OFF_SLAB caches allocate management structures (currently just the
freelist) from kmalloc caches when placement in a slab page together with
objects would lead to suboptimal memory usage. For SLAB_RECLAIM_ACCOUNT caches,
we can allocate the freelists from the newly introduced reclaimable kmalloc
caches, because shrinking the OFF_SLAB cache will in general result to freeing
of the freelists as well. This should improve accounting and anti-fragmentation
a bit.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/slab.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 8d7e1f06127b..4dd7d73a1972 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2142,8 +2142,13 @@ int __kmem_cache_create(struct kmem_cache *cachep, slab_flags_t flags)
 #endif
 
 	if (OFF_SLAB(cachep)) {
+		/*
+		 * If this cache is reclaimable, allocate also freelists from
+		 * a reclaimable kmalloc cache.
+		 */
 		cachep->freelist_cache =
-			kmalloc_slab(cachep->freelist_size, 0u);
+			kmalloc_slab(cachep->freelist_size,
+				     cachep->allocflags & __GFP_RECLAIMABLE);
 	}
 
 	err = setup_cpu_cache(cachep, gfp);
-- 
2.17.0
