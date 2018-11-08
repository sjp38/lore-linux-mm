Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB366B057E
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 20:12:17 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id i19-v6so14812101pfi.21
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 17:12:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z20-v6sor2965088pgf.81.2018.11.07.17.12.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Nov 2018 17:12:15 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/slub: skip node in case there is no slab to acquire
Date: Thu,  8 Nov 2018 09:12:04 +0800
Message-Id: <20181108011204.9491-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

for_each_zone_zonelist() iterates the zonelist one by one, which means
it will iterate on zones on the same node. While get_partial_node()
checks available slab on node base instead of zone.

This patch skip a node in case get_partial_node() fails to acquire slab
on that node.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index e3629cd7aff1..97a480b5dfb9 100644
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
@@ -1926,6 +1930,7 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 					 */
 					return object;
 				}
+				node_clear(zone_to_nid(zone), nmask);
 			}
 		}
 	} while (read_mems_allowed_retry(cpuset_mems_cookie));
@@ -1951,7 +1956,7 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
 	if (object || node != NUMA_NO_NODE)
 		return object;
 
-	return get_any_partial(s, flags, c);
+	return get_any_partial(s, flags, c, searchnode);
 }
 
 #ifdef CONFIG_PREEMPT
-- 
2.15.1
