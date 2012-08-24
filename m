Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id E84A86B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 14:01:21 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so4259939pbb.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 11:01:21 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] slub: consider pfmemalloc_match() in get_partial_node()
Date: Sat, 25 Aug 2012 03:00:02 +0900
Message-Id: <1345831202-4225-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

There is no consideration for pfmemalloc_match() in get_partial(). If we don't
consider that, we can't restrict access to PFMEMALLOC page mostly.

We may encounter following scenario.

Assume there is a request from normal allocation
and there is no objects in per cpu cache and no node partial slab.

In this case, slab_alloc go into slow-path and
new_slab_objects() is invoked. It may return PFMEMALLOC page.
Current user is not allowed to access PFMEMALLOC page,
deactivate_slab() is called (commit 5091b74a95d447e34530e713a8971450a45498b3),
then return object from PFMEMALLOC page.

Next time, when we meet another request from normal allocation,
slab_alloc() go into slow-path and re-go new_slab_objects().
In new_slab_objects(), we invoke get_partial() and we get a partial slab
which we have been deactivated just before, that is, PFMEMALLOC page.
We extract one object from it and re-deactivate.

"deactivate -> re-get in get_partial -> re-deactivate" occures repeatedly.

As a result, we can't restrict access to PFMEMALLOC page and
moreover, it introduce much performance degration to normal allocation
because of deactivation frequently.

Now, we need to consider pfmemalloc_match() in get_partial_node()
It prevent "deactivate -> re-get in get_partial".
Instead, new_slab() is called. It may return !PFMEMALLOC page,
so above situation will be suspended sometime.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Neil Brown <neilb@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Mike Christie <michaelc@cs.wisc.edu>
Cc: Eric B Munson <emunson@mgebm.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
This patch based on Pekka's slab/next tree with my two patches.

[PATCH 1/2] slub: rename cpu_partial to max_cpu_object
https://lkml.org/lkml/2012/8/24/293

[PATCH 2/2] slub: correct the calculation of the number of cpu objects in get_partial_node
https://lkml.org/lkml/2012/8/24/290

diff --git a/mm/slub.c b/mm/slub.c
index c96e0e4..a21da3a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1529,12 +1529,13 @@ static inline void *acquire_slab(struct kmem_cache *s,
 }
 
 static int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain);
+static inline bool pfmemalloc_match(struct page *page, gfp_t gfpflags);
 
 /*
  * Try to allocate a partial slab from a specific node.
  */
-static void *get_partial_node(struct kmem_cache *s,
-		struct kmem_cache_node *n, struct kmem_cache_cpu *c)
+static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
+				struct kmem_cache_cpu *c, gfp_t flags)
 {
 	struct page *page, *page2;
 	void *object = NULL;
@@ -1551,8 +1552,12 @@ static void *get_partial_node(struct kmem_cache *s,
 
 	spin_lock(&n->list_lock);
 	list_for_each_entry_safe(page, page2, &n->partial, lru) {
-		void *t = acquire_slab(s, n, page, object == NULL);
+		void *t;
 
+		if (!pfmemalloc_match(page, flags))
+			continue;
+
+		t = acquire_slab(s, n, page, object == NULL);
 		if (!t)
 			break;
 
@@ -1620,7 +1625,7 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 
 			if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
 					n->nr_partial > s->min_partial) {
-				object = get_partial_node(s, n, c);
+				object = get_partial_node(s, n, c, flags);
 				if (object) {
 					/*
 					 * Return the object even if
@@ -1649,7 +1654,7 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
 	void *object;
 	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
 
-	object = get_partial_node(s, get_node(s, searchnode), c);
+	object = get_partial_node(s, get_node(s, searchnode), c, flags);
 	if (object || node != NUMA_NO_NODE)
 		return object;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
