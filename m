Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 541626B0007
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 04:12:50 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e89so1867093pfb.17
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:12:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y23sor7542595pga.35.2018.11.13.01.12.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 01:12:49 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v2] mm/slub: skip node in case there is no slab to acquire
Date: Tue, 13 Nov 2018 17:12:40 +0800
Message-Id: <20181113091240.23308-1-richard.weiyang@gmail.com>
In-Reply-To: <20181108011204.9491-1-richard.weiyang@gmail.com>
References: <20181108011204.9491-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

Current slub has three layers:

  * cpu_slab
  * percpu_partial
  * per node partial list

Slub allocator tries to get an object from top to bottom. When it can't
get an object from the upper two layers, it will search the per node
partial list. The is done in get_partial().

The abstraction of get_partial() may looks like this:

    get_partial()
        get_partial_node()
        get_any_partial()
            for_each_zone_zonelist()

The idea behind this is: it first try a local node, then try other nodes
if caller doesn't specify a node.

When we look one step deeper in get_any_partial(), it tries to get a
proper node by for_each_zone_zonelist(), which iterates on the
node_zonelists.

This behavior would introduce some redundant check on the same node.
Because:

  * the local node is already checked in get_partial_node()
  * one node may have several zones on node_zonelists

We could reduce these redundant check by providing a nodemask during
node_zonelists iteration.

  * clear the local node which is already checked in get_partial_node()
  * clear a node if we can't get an object from it.

This patch replaces for_each_zone_zonelist() with
for_each_zone_zonelist_nodemask() to skip the node which fails to acquire
an object.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
v2: rewrite the changelog and add a comment based on Andrew's comment
---
 mm/slub.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index e3629cd7aff1..e3db5cd52507 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1873,7 +1873,7 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
  * Get a page from somewhere. Search in increasing NUMA distances.
  */
 static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
-		struct kmem_cache_cpu *c)
+		struct kmem_cache_cpu *c, int except)
 {
 #ifdef CONFIG_NUMA
 	struct zonelist *zonelist;
@@ -1882,6 +1882,9 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *object;
 	unsigned int cpuset_mems_cookie;
+	nodemask_t nmask = node_states[N_MEMORY];
+
+	node_clear(except, nmask);
 
 	/*
 	 * The defrag ratio allows a configuration of the tradeoffs between
@@ -1908,7 +1911,8 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 	do {
 		cpuset_mems_cookie = read_mems_allowed_begin();
 		zonelist = node_zonelist(mempolicy_slab_node(), flags);
-		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+		for_each_zone_zonelist_nodemask(zone, z, zonelist,
+						high_zoneidx, &nmask) {
 			struct kmem_cache_node *n;
 
 			n = get_node(s, zone_to_nid(zone));
@@ -1926,6 +1930,11 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 					 */
 					return object;
 				}
+				/*
+				 * Fail to get object from this node,
+				 * clear this to skip this node
+				 */
+				node_clear(zone_to_nid(zone), nmask);
 			}
 		}
 	} while (read_mems_allowed_retry(cpuset_mems_cookie));
@@ -1951,7 +1960,7 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
 	if (object || node != NUMA_NO_NODE)
 		return object;
 
-	return get_any_partial(s, flags, c);
+	return get_any_partial(s, flags, c, searchnode);
 }
 
 #ifdef CONFIG_PREEMPT
-- 
2.15.1
