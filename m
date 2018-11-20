Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5FBF6B1DF3
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 22:31:32 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 190-v6so527340pfd.7
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 19:31:32 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f21sor46540866pgm.40.2018.11.19.19.31.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 19:31:31 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v2] mm/slub: improve performance by skipping checked node in get_any_partial()
Date: Tue, 20 Nov 2018 11:31:19 +0800
Message-Id: <20181120033119.30013-1-richard.weiyang@gmail.com>
In-Reply-To: <20181108011204.9491-1-richard.weiyang@gmail.com>
References: <20181108011204.9491-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

1. Background

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

2. Room for Improvement

  When we look one step deeper in get_any_partial(), it tries to get a
  proper node by for_each_zone_zonelist(), which iterates on the
  node_zonelists.

  This behavior would introduce some redundant check on the same node.
  Because:

    * the local node is already checked in get_partial_node()
    * one node may have several zones on node_zonelists

3. Solution Proposed in Patch

  We could reduce these redundant check by record the last unsuccessful
  node and then skip it.

4. Tests & Result

  After some tests, the result shows this may improve the system a little,
  especially on a machine with only one node.

4.1 Test Description

  There are two cases for two system configurations.

  Test Cases:

    1. counter comparison
    2. kernel build test

  System Configuration:

    1. One node machine with 4G
    2. Four node machine with 8G

4.2 Result for Test 1

  Test 1: counter comparison

  This is a test with hacked kernel to record times function
  get_any_partial() is invoked and times the inner loop iterates. By
  comparing the ratio of two counters, we get to know how many inner
  loops we skipped.

  Here is a snip of the test patch.

  ---
  static void *get_any_partial() {

	get_partial_count++;

        do {
		for_each_zone_zonelist() {
			get_partial_try_count++;
		}
	} while();

	return NULL;
  }
  ---

  The result of (get_partial_count / get_partial_try_count):

   +----------+----------------+------------+-------------+
   |          |       Base     |    Patched |  Improvement|
   +----------+----------------+------------+-------------+
   |One Node  |       1:3      |    1:0     |      - 100% |
   +----------+----------------+------------+-------------+
   |Four Nodes|       1:5.8    |    1:2.5   |      -  56% |
   +----------+----------------+------------+-------------+

4.3 Result for Test 2

  Test 2: kernel build

   Command used:

   > time make -j8 bzImage

   Each version/system configuration combination has four round kernel
   build tests. Take the average result of real to compare.

   +----------+----------------+------------+-------------+
   |          |       Base     |   Patched  |  Improvement|
   +----------+----------------+------------+-------------+
   |One Node  |      4m41s     |   4m32s    |     - 4.47% |
   +----------+----------------+------------+-------------+
   |Four Nodes|      4m45s     |   4m39s    |     - 2.92% |
   +----------+----------------+------------+-------------+

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

---
v3:
  * replace nmask with except to reduce potential stack overflow and copy
    overhead
  * test this in two cases and two system configurations and list the result

v2:
  * rewrite the changelog and add a comment based on Andrew's comment

---
 mm/slub.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index e3629cd7aff1..3d93a07d86d9 100644
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
@@ -1911,6 +1911,9 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 			struct kmem_cache_node *n;
 
+			if (except == zone_to_nid(zone))
+				continue;
+
 			n = get_node(s, zone_to_nid(zone));
 
 			if (n && cpuset_zone_allowed(zone, flags) &&
@@ -1927,6 +1930,13 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 					return object;
 				}
 			}
+			/*
+			 * Fail to get object from this node, either because
+			 *   1. Fails in if check
+			 *   2. NULl object returns from get_partial_node()
+			 * Skip it next time.
+			 */
+			except = zone_to_nid(zone);
 		}
 	} while (read_mems_allowed_retry(cpuset_mems_cookie));
 #endif
@@ -1951,7 +1961,7 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
 	if (object || node != NUMA_NO_NODE)
 		return object;
 
-	return get_any_partial(s, flags, c);
+	return get_any_partial(s, flags, c, searchnode);
 }
 
 #ifdef CONFIG_PREEMPT
-- 
2.15.1
