Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D39DE8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 17:41:10 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id i124so2773276pgc.2
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:41:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o127si9140416pfo.251.2018.12.20.14.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 14:41:09 -0800 (PST)
Date: Thu, 20 Dec 2018 14:41:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/slub: improve performance by skipping checked
 node in get_any_partial()
Message-Id: <20181220144107.9376344c2be687615ea9aa69@linux-foundation.org>
In-Reply-To: <20181120033119.30013-1-richard.weiyang@gmail.com>
References: <20181108011204.9491-1-richard.weiyang@gmail.com>
	<20181120033119.30013-1-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, mhocko@kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

Could someone please review this?

Thanks.

From: Wei Yang <richard.weiyang@gmail.com>
Subject: mm/slub.c: improve performance by skipping checked node in get_any_partial()

1. Background

  Current slub has three layers:

    * cpu_slab
    * percpu_partial
    * per node partial list

  Slub allocator tries to get an object from top to bottom.  When it
  can't get an object from the upper two layers, it will search the per
  node partial list.  The is done in get_partial().

  The abstraction of get_partial() look like this:

      get_partial()
          get_partial_node()
          get_any_partial()
              for_each_zone_zonelist()

  The idea behind this is: first try a local node, then try other nodes
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

[akpm@linux-foundation.org: rename variable, tweak comment]
Link: http://lkml.kernel.org/r/20181120033119.30013-1-richard.weiyang@gmail.com
Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/slub.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

--- a/mm/slub.c~mm-slub-improve-performance-by-skipping-checked-node-in-get_any_partial
+++ a/mm/slub.c
@@ -1877,7 +1877,7 @@ static void *get_partial_node(struct kme
  * Get a page from somewhere. Search in increasing NUMA distances.
  */
 static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
-		struct kmem_cache_cpu *c)
+		struct kmem_cache_cpu *c, int exclude_nid)
 {
 #ifdef CONFIG_NUMA
 	struct zonelist *zonelist;
@@ -1915,6 +1915,9 @@ static void *get_any_partial(struct kmem
 		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 			struct kmem_cache_node *n;
 
+			if (exclude_nid == zone_to_nid(zone))
+				continue;
+
 			n = get_node(s, zone_to_nid(zone));
 
 			if (n && cpuset_zone_allowed(zone, flags) &&
@@ -1931,6 +1934,14 @@ static void *get_any_partial(struct kmem
 					return object;
 				}
 			}
+			/*
+			 * Failed to get an object from this node, either
+			 * because
+			 *   1. Failure in the above if check
+			 *   2. NULL return from get_partial_node()
+			 * So skip this node next time.
+			 */
+			exclude_nid = zone_to_nid(zone);
 		}
 	} while (read_mems_allowed_retry(cpuset_mems_cookie));
 #endif
@@ -1955,7 +1966,7 @@ static void *get_partial(struct kmem_cac
 	if (object || node != NUMA_NO_NODE)
 		return object;
 
-	return get_any_partial(s, flags, c);
+	return get_any_partial(s, flags, c, searchnode);
 }
 
 #ifdef CONFIG_PREEMPT
_
