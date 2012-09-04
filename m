Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 2F59C6B006C
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 13:24:46 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/4] slub: consider pfmemalloc_match() in get_partial_node()
Date: Tue,  4 Sep 2012 18:24:38 +0100
Message-Id: <1346779479-1097-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1346779479-1097-1-git-send-email-mgorman@suse.de>
References: <1346779479-1097-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Chuck Lever <chuck.lever@oracle.com>, Joonsoo Kim <js1304@gmail.com>, Pekka@suse.de, "Enberg <penberg"@kernel.org, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>

From: Joonsoo Kim <js1304@gmail.com>

The function get_partial() is currently not checking pfmemalloc_match()
meaning that it is possible for pfmemalloc pages to leak to non-pfmemalloc
users. This is a problem in the following situation.  Assume that there is
a request from normal allocation and there are no objects in the per-cpu
cache and no node-partial slab.

In this case, slab_alloc enters the slow path and new_slab_objects()
is called which may return a PFMEMALLOC page. As the current user is not
allowed to access PFMEMALLOC page, deactivate_slab() is called ([5091b74a:
mm: slub: optimise the SLUB fast path to avoid pfmemalloc checks]) and
returns an object from PFMEMALLOC page.

Next time, when we get another request from normal allocation, slab_alloc()
enters the slow-path and calls new_slab_objects().  In new_slab_objects(),
we call get_partial() and get a partial slab which was just deactivated
but is a pfmemalloc page. We extract one object from it and re-deactivate.

"deactivate -> re-get in get_partial -> re-deactivate" occures repeatedly.

As a result, access to PFMEMALLOC page is not properly restricted and it
can cause a performance degradation due to frequent deactivation.
deactivation frequently.

This patch changes get_partial_node() to take pfmemalloc_match() into
account and prevents the "deactivate -> re-get in get_partial() scenario.
Instead, new_slab() is called.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/slub.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8f78e25..2fdd96f9e9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1524,12 +1524,13 @@ static inline void *acquire_slab(struct kmem_cache *s,
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
@@ -1545,9 +1546,13 @@ static void *get_partial_node(struct kmem_cache *s,
 
 	spin_lock(&n->list_lock);
 	list_for_each_entry_safe(page, page2, &n->partial, lru) {
-		void *t = acquire_slab(s, n, page, object == NULL);
+		void *t;
 		int available;
 
+		if (!pfmemalloc_match(page, flags))
+			continue;
+
+		t = acquire_slab(s, n, page, object == NULL);
 		if (!t)
 			break;
 
@@ -1614,7 +1619,7 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 
 			if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
 					n->nr_partial > s->min_partial) {
-				object = get_partial_node(s, n, c);
+				object = get_partial_node(s, n, c, flags);
 				if (object) {
 					/*
 					 * Return the object even if
@@ -1643,7 +1648,7 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
 	void *object;
 	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
 
-	object = get_partial_node(s, get_node(s, searchnode), c);
+	object = get_partial_node(s, get_node(s, searchnode), c, flags);
 	if (object || node != NUMA_NO_NODE)
 		return object;
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
