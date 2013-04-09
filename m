Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 3A9DC6B0036
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 21:20:49 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 3/3] mm, slab: count freed pages via rcu as this task's reclaimed_slab
Date: Tue,  9 Apr 2013 10:21:18 +0900
Message-Id: <1365470478-645-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1365470478-645-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1365470478-645-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

Currently, freed pages via rcu is not counted for reclaimed_slab, because
it is freed in rcu context, not current task context. But, this free is
initiated by this task, so counting this into this task's reclaimed_slab
is meaningful to decide whether we continue reclaim, or not.
So change code to count these pages for this task's reclaimed_slab.

Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 856e4a1..4d94bcb 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1934,8 +1934,6 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
 	}
 
 	memcg_release_pages(cachep, cachep->gfporder);
-	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab += nr_freed;
 	free_memcg_kmem_pages((unsigned long)addr, cachep->gfporder);
 }
 
@@ -2165,6 +2163,7 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep, struct slab *slab
  */
 static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
 {
+	unsigned long nr_freed = (1 << cachep->gfporder);
 	void *addr = slabp->s_mem - slabp->colouroff;
 
 	slab_destroy_debugcheck(cachep, slabp);
@@ -2180,6 +2179,9 @@ static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
 		if (OFF_SLAB(cachep))
 			kmem_cache_free(cachep->slabp_cache, slabp);
 	}
+
+	if (current->reclaim_state)
+		current->reclaim_state->reclaimed_slab += nr_freed;
 }
 
 /**
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
