Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 0DBF26B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 21:20:46 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/3] mm, slub: count freed pages via rcu as this task's reclaimed_slab
Date: Tue,  9 Apr 2013 10:21:17 +0900
Message-Id: <1365470478-645-2-git-send-email-iamjoonsoo.kim@lge.com>
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

diff --git a/mm/slub.c b/mm/slub.c
index 4aec537..16fd2d5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1409,8 +1409,6 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 
 	memcg_release_pages(s, order);
 	page_mapcount_reset(page);
-	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab += pages;
 	__free_memcg_kmem_pages(page, order);
 }
 
@@ -1431,6 +1429,8 @@ static void rcu_free_slab(struct rcu_head *h)
 
 static void free_slab(struct kmem_cache *s, struct page *page)
 {
+	int pages = 1 << compound_order(page);
+
 	if (unlikely(s->flags & SLAB_DESTROY_BY_RCU)) {
 		struct rcu_head *head;
 
@@ -1450,6 +1450,9 @@ static void free_slab(struct kmem_cache *s, struct page *page)
 		call_rcu(head, rcu_free_slab);
 	} else
 		__free_slab(s, page);
+
+	if (current->reclaim_state)
+		current->reclaim_state->reclaimed_slab += pages;
 }
 
 static void discard_slab(struct kmem_cache *s, struct page *page)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
