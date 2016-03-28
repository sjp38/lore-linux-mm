Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id BF14C6B026A
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 01:27:37 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id n5so128686211pfn.2
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 22:27:37 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id 73si12745595pfp.195.2016.03.27.22.27.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Mar 2016 22:27:37 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id x3so128949844pfb.1
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 22:27:36 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 08/11] mm/slab: make cache_grow() handle the page allocated on arbitrary node
Date: Mon, 28 Mar 2016 14:26:58 +0900
Message-Id: <1459142821-20303-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, cache_grow() assumes that allocated page's nodeid would be
same with parameter nodeid which is used for allocation request. If
we discard this assumption, we can handle fallback_alloc() case
gracefully. So, this patch makes cache_grow() handle the page allocated
on arbitrary node and clean-up relevant code.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 60 +++++++++++++++++++++---------------------------------------
 1 file changed, 21 insertions(+), 39 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 52fc5e3..ce8ed65 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2518,13 +2518,14 @@ static void slab_map_pages(struct kmem_cache *cache, struct page *page,
  * Grow (by 1) the number of slabs within a cache.  This is called by
  * kmem_cache_alloc() when there are no active objs left in a cache.
  */
-static int cache_grow(struct kmem_cache *cachep,
-		gfp_t flags, int nodeid, struct page *page)
+static int cache_grow(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
 	void *freelist;
 	size_t offset;
 	gfp_t local_flags;
+	int page_node;
 	struct kmem_cache_node *n;
+	struct page *page;
 
 	/*
 	 * Be lazy and only check for valid flags here,  keeping it out of the
@@ -2552,12 +2553,12 @@ static int cache_grow(struct kmem_cache *cachep,
 	 * Get mem for the objs.  Attempt to allocate a physical page from
 	 * 'nodeid'.
 	 */
-	if (!page)
-		page = kmem_getpages(cachep, local_flags, nodeid);
+	page = kmem_getpages(cachep, local_flags, nodeid);
 	if (!page)
 		goto failed;
 
-	n = get_node(cachep, nodeid);
+	page_node = page_to_nid(page);
+	n = get_node(cachep, page_node);
 
 	/* Get colour for the slab, and cal the next value. */
 	n->colour_next++;
@@ -2572,7 +2573,7 @@ static int cache_grow(struct kmem_cache *cachep,
 
 	/* Get slab management. */
 	freelist = alloc_slabmgmt(cachep, page, offset,
-			local_flags & ~GFP_CONSTRAINT_MASK, nodeid);
+			local_flags & ~GFP_CONSTRAINT_MASK, page_node);
 	if (OFF_SLAB(cachep) && !freelist)
 		goto opps1;
 
@@ -2591,13 +2592,13 @@ static int cache_grow(struct kmem_cache *cachep,
 	STATS_INC_GROWN(cachep);
 	n->free_objects += cachep->num;
 	spin_unlock(&n->list_lock);
-	return 1;
+	return page_node;
 opps1:
 	kmem_freepages(cachep, page);
 failed:
 	if (gfpflags_allow_blocking(local_flags))
 		local_irq_disable();
-	return 0;
+	return -1;
 }
 
 #if DEBUG
@@ -2878,14 +2879,14 @@ alloc_done:
 				return obj;
 		}
 
-		x = cache_grow(cachep, gfp_exact_node(flags), node, NULL);
+		x = cache_grow(cachep, gfp_exact_node(flags), node);
 
 		/* cache_grow can reenable interrupts, then ac could change. */
 		ac = cpu_cache_get(cachep);
 		node = numa_mem_id();
 
 		/* no objects in sight? abort */
-		if (!x && ac->avail == 0)
+		if (x < 0 && ac->avail == 0)
 			return NULL;
 
 		if (!ac->avail)		/* objects refilled by interrupt? */
@@ -3014,7 +3015,6 @@ static void *alternate_node_alloc(struct kmem_cache *cachep, gfp_t flags)
 static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 {
 	struct zonelist *zonelist;
-	gfp_t local_flags;
 	struct zoneref *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
@@ -3025,8 +3025,6 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	if (flags & __GFP_THISNODE)
 		return NULL;
 
-	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
-
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 	zonelist = node_zonelist(mempolicy_slab_node(), flags);
@@ -3056,33 +3054,17 @@ retry:
 		 * We may trigger various forms of reclaim on the allowed
 		 * set and go into memory reserves if necessary.
 		 */
-		struct page *page;
+		nid = cache_grow(cache, flags, numa_mem_id());
+		if (nid >= 0) {
+			obj = ____cache_alloc_node(cache,
+				gfp_exact_node(flags), nid);
 
-		if (gfpflags_allow_blocking(local_flags))
-			local_irq_enable();
-		kmem_flagcheck(cache, flags);
-		page = kmem_getpages(cache, local_flags, numa_mem_id());
-		if (gfpflags_allow_blocking(local_flags))
-			local_irq_disable();
-		if (page) {
 			/*
-			 * Insert into the appropriate per node queues
+			 * Another processor may allocate the objects in
+			 * the slab since we are not holding any locks.
 			 */
-			nid = page_to_nid(page);
-			if (cache_grow(cache, flags, nid, page)) {
-				obj = ____cache_alloc_node(cache,
-					gfp_exact_node(flags), nid);
-				if (!obj)
-					/*
-					 * Another processor may allocate the
-					 * objects in the slab since we are
-					 * not holding any locks.
-					 */
-					goto retry;
-			} else {
-				/* cache_grow already freed obj */
-				obj = NULL;
-			}
+			if (!obj)
+				goto retry;
 		}
 	}
 
@@ -3133,8 +3115,8 @@ retry:
 
 must_grow:
 	spin_unlock(&n->list_lock);
-	x = cache_grow(cachep, gfp_exact_node(flags), nodeid, NULL);
-	if (x)
+	x = cache_grow(cachep, gfp_exact_node(flags), nodeid);
+	if (x >= 0)
 		goto retry;
 
 	return fallback_alloc(cachep, flags);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
