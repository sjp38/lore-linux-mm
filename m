Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 6ED988D0017
	for <linux-mm@kvack.org>; Fri, 11 May 2012 13:48:29 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 05/29] slab: rename gfpflags to allocflags
Date: Fri, 11 May 2012 14:44:07 -0300
Message-Id: <1336758272-24284-6-git-send-email-glommer@parallels.com>
In-Reply-To: <1336758272-24284-1-git-send-email-glommer@parallels.com>
References: <1336758272-24284-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

A consistent name with slub saves us an acessor function.
In both caches, this field represents the same thing. We would
like to use it from the mem_cgroup code.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
---
 include/linux/slab_def.h |    2 +-
 mm/slab.c                |   10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index fbd1117..d41effe 100644
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
index 91b9c13..8a851ed 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1798,7 +1798,7 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 	flags |= __GFP_COMP;
 #endif
 
-	flags |= cachep->gfpflags;
+	flags |= cachep->allocflags;
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		flags |= __GFP_RECLAIMABLE;
 
@@ -2509,9 +2509,9 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 	cachep->colour = left_over / cachep->colour_off;
 	cachep->slab_size = slab_size;
 	cachep->flags = flags;
-	cachep->gfpflags = 0;
+	cachep->allocflags = 0;
 	if (CONFIG_ZONE_DMA_FLAG && (flags & SLAB_CACHE_DMA))
-		cachep->gfpflags |= GFP_DMA;
+		cachep->allocflags |= GFP_DMA;
 	cachep->buffer_size = size;
 	cachep->reciprocal_buffer_size = reciprocal_value(size);
 
@@ -2858,9 +2858,9 @@ static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
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
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
