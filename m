Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 9B1276B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 06:32:05 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v4 01/25] slab: rename gfpflags to allocflags
Date: Mon, 18 Jun 2012 14:27:54 +0400
Message-Id: <1340015298-14133-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1340015298-14133-1-git-send-email-glommer@parallels.com>
References: <1340015298-14133-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pekka Enberg <penberg@kernel.org>, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>

A consistent name with slub saves us an acessor function.
In both caches, this field represents the same thing. We would
like to use it from the mem_cgroup code.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Acked-by: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
---
 include/linux/slab_def.h |    2 +-
 mm/slab.c                |   10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 1d93f27..0c634fa 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -39,7 +39,7 @@ struct kmem_cache {
 	unsigned int gfporder;
 
 	/* force GFP flags, e.g. GFP_DMA */
-	gfp_t gfpflags;
+	gfp_t allocflags;
 
 	size_t colour;			/* cache colouring range */
 	unsigned int colour_off;	/* colour offset */
diff --git a/mm/slab.c b/mm/slab.c
index 2476ad4..020605f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1746,7 +1746,7 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 	flags |= __GFP_COMP;
 #endif
 
-	flags |= cachep->gfpflags;
+	flags |= cachep->allocflags;
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		flags |= __GFP_RECLAIMABLE;
 
@@ -2338,9 +2338,9 @@ int __kmem_cache_create(struct kmem_cache *cachep)
 	cachep->colour = left_over / cachep->colour_off;
 	cachep->slab_size = slab_size;
 	cachep->flags = flags;
-	cachep->gfpflags = 0;
+	cachep->allocflags = 0;
 	if (CONFIG_ZONE_DMA_FLAG && (flags & SLAB_CACHE_DMA))
-		cachep->gfpflags |= GFP_DMA;
+		cachep->allocflags |= GFP_DMA;
 	cachep->size = size;
 	cachep->reciprocal_buffer_size = reciprocal_value(size);
 
@@ -2653,9 +2653,9 @@ static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
 {
 	if (CONFIG_ZONE_DMA_FLAG) {
 		if (flags & GFP_DMA)
-			BUG_ON(!(cachep->gfpflags & GFP_DMA));
+			BUG_ON(!(cachep->allocflags & GFP_DMA));
 		else
-			BUG_ON(cachep->gfpflags & GFP_DMA);
+			BUG_ON(cachep->allocflags & GFP_DMA);
 	}
 }
 
-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
