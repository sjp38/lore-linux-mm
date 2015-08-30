Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 90E3E6B0255
	for <linux-mm@kvack.org>; Sun, 30 Aug 2015 15:02:34 -0400 (EDT)
Received: by padhy3 with SMTP id hy3so9689768pad.0
        for <linux-mm@kvack.org>; Sun, 30 Aug 2015 12:02:34 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id s5si20531232pdd.226.2015.08.30.12.02.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Aug 2015 12:02:33 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 1/2] mm/slab: skip memcg reclaim only if in atomic context
Date: Sun, 30 Aug 2015 22:02:17 +0300
Message-ID: <b34f641e1ba70aeb8754188a2dfa6c2d641e4cdc.1440960578.git.vdavydov@parallels.com>
In-Reply-To: <cover.1440960578.git.vdavydov@parallels.com>
References: <cover.1440960578.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

SLAB's implementation of kmem_cache_alloc() works as follows:
 1. First, it tries to allocate from the preferred NUMA node without
    issuing reclaim.
 2. If step 1 fails, it tries all nodes in the order of preference,
    again without invoking reclaimer
 3. Only if steps 1 and 2 fails, it falls back on allocation from any
    allowed node with reclaim enabled.

Before commit 4167e9b2cf10f ("mm: remove GFP_THISNODE"), GFP_THISNODE
combination, which equaled __GFP_THISNODE|__GFP_NOWARN|__GFP_NORETRY on
NUMA enabled builds, was used in order to avoid reclaim during steps 1
and 2. If __alloc_pages_slowpath() saw this combination in gfp flags, it
aborted immediately even if __GFP_WAIT flag was set. So there was no
need in clearing __GFP_WAIT flag while performing steps 1 and 2 and
hence we could invoke memcg reclaim when allocating a slab page if the
context allowed.

Commit 4167e9b2cf10f zapped GFP_THISNODE combination. Instead of OR-ing
the gfp mask with GFP_THISNODE, gfp_exact_node() helper should now be
used. The latter sets __GFP_THISNODE and __GFP_NOWARN flags and clears
__GFP_WAIT on the current gfp mask. As a result, it effectively
prohibits invoking memcg reclaim on steps 1 and 2. This breaks
memcg/memory.high logic when kmem accounting is enabled. The memory.high
threshold is supposed to work as a soft limit, i.e. it does not fail an
allocation on breaching it, but it still forces the caller to invoke
direct reclaim to compensate for the excess. Without __GFP_WAIT flag
direct reclaim is impossible so the caller will go on without being
pushed back to the threshold.

To fix this issue, we get rid of gfp_exact_node() helper and move gfp
flags filtering to kmem_getpages() after memcg_charge_slab() is called.

To understand the patch, note that:
 - In fallback_alloc() the only effect of using gfp_exact_node() is
   preventing recursion fallback_alloc() -> ____cache_alloc_node() ->
   fallback_alloc().
 - Aside from fallback_alloc(), gfp_exact_node() is only used along with
   cache_grow(). Moreover, the only place where cache_grow() is used
   without it is fallback_alloc(), which, in contrast to other
   cache_grow() users, preallocates a page and passes it to cache_grow()
   so that the latter does not need to invoke kmem_getpages() by itself.

Reported-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slab.c | 32 +++++++++++---------------------
 1 file changed, 11 insertions(+), 21 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d890750ec31e..9ee809d2ed8b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -857,11 +857,6 @@ static inline void *____cache_alloc_node(struct kmem_cache *cachep,
 	return NULL;
 }
 
-static inline gfp_t gfp_exact_node(gfp_t flags)
-{
-	return flags;
-}
-
 #else	/* CONFIG_NUMA */
 
 static void *____cache_alloc_node(struct kmem_cache *, gfp_t, int);
@@ -1028,15 +1023,6 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 
 	return __cache_free_alien(cachep, objp, node, page_node);
 }
-
-/*
- * Construct gfp mask to allocate from a specific node but do not invoke reclaim
- * or warn about failures.
- */
-static inline gfp_t gfp_exact_node(gfp_t flags)
-{
-	return (flags | __GFP_THISNODE | __GFP_NOWARN) & ~__GFP_WAIT;
-}
 #endif
 
 /*
@@ -1583,7 +1569,7 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
  * would be relatively rare and ignorable.
  */
 static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
-								int nodeid)
+				  int nodeid, bool fallback)
 {
 	struct page *page;
 	int nr_pages;
@@ -1595,6 +1581,9 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	if (memcg_charge_slab(cachep, flags, cachep->gfporder))
 		return NULL;
 
+	if (!fallback)
+		flags = (flags | __GFP_THISNODE | __GFP_NOWARN) & ~__GFP_WAIT;
+
 	page = __alloc_pages_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
 	if (!page) {
 		memcg_uncharge_slab(cachep, cachep->gfporder);
@@ -2641,7 +2630,8 @@ static int cache_grow(struct kmem_cache *cachep,
 	 * 'nodeid'.
 	 */
 	if (!page)
-		page = kmem_getpages(cachep, local_flags, nodeid);
+		page = kmem_getpages(cachep, local_flags, nodeid,
+				     !IS_ENABLED(CONFIG_NUMA));
 	if (!page)
 		goto failed;
 
@@ -2840,7 +2830,7 @@ alloc_done:
 	if (unlikely(!ac->avail)) {
 		int x;
 force_grow:
-		x = cache_grow(cachep, gfp_exact_node(flags), node, NULL);
+		x = cache_grow(cachep, flags, node, NULL);
 
 		/* cache_grow can reenable interrupts, then ac could change. */
 		ac = cpu_cache_get(cachep);
@@ -3034,7 +3024,7 @@ retry:
 			get_node(cache, nid) &&
 			get_node(cache, nid)->free_objects) {
 				obj = ____cache_alloc_node(cache,
-					gfp_exact_node(flags), nid);
+					flags | __GFP_THISNODE, nid);
 				if (obj)
 					break;
 		}
@@ -3052,7 +3042,7 @@ retry:
 		if (local_flags & __GFP_WAIT)
 			local_irq_enable();
 		kmem_flagcheck(cache, flags);
-		page = kmem_getpages(cache, local_flags, numa_mem_id());
+		page = kmem_getpages(cache, local_flags, numa_mem_id(), true);
 		if (local_flags & __GFP_WAIT)
 			local_irq_disable();
 		if (page) {
@@ -3062,7 +3052,7 @@ retry:
 			nid = page_to_nid(page);
 			if (cache_grow(cache, flags, nid, page)) {
 				obj = ____cache_alloc_node(cache,
-					gfp_exact_node(flags), nid);
+					flags | __GFP_THISNODE, nid);
 				if (!obj)
 					/*
 					 * Another processor may allocate the
@@ -3133,7 +3123,7 @@ retry:
 
 must_grow:
 	spin_unlock(&n->list_lock);
-	x = cache_grow(cachep, gfp_exact_node(flags), nodeid, NULL);
+	x = cache_grow(cachep, flags, nodeid, NULL);
 	if (x)
 		goto retry;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
