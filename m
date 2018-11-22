Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C13E6B2919
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 22:06:00 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id o23so12892139pll.0
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 19:06:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l61si12297006plb.6.2018.11.21.19.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 19:05:59 -0800 (PST)
Date: Wed, 21 Nov 2018 19:05:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/slub: improve performance by skipping checked
 node in get_any_partial()
Message-Id: <20181121190555.c010ac50e7eaa141549a63e5@linux-foundation.org>
In-Reply-To: <20181120033119.30013-1-richard.weiyang@gmail.com>
References: <20181108011204.9491-1-richard.weiyang@gmail.com>
	<20181120033119.30013-1-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, mhocko@kernel.org, linux-mm@kvack.org

On Tue, 20 Nov 2018 11:31:19 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:

> 1. Background
> 
>   Current slub has three layers:
> 
>     * cpu_slab
>     * percpu_partial
>     * per node partial list
> 
>   Slub allocator tries to get an object from top to bottom. When it can't
>   get an object from the upper two layers, it will search the per node
>   partial list. The is done in get_partial().
> 
>   The abstraction of get_partial() may looks like this:
> 
>       get_partial()
>           get_partial_node()
>           get_any_partial()
>               for_each_zone_zonelist()
> 
>   The idea behind this is: it first try a local node, then try other nodes
>   if caller doesn't specify a node.
> 
> 2. Room for Improvement
> 
>   When we look one step deeper in get_any_partial(), it tries to get a
>   proper node by for_each_zone_zonelist(), which iterates on the
>   node_zonelists.
> 
>   This behavior would introduce some redundant check on the same node.
>   Because:
> 
>     * the local node is already checked in get_partial_node()
>     * one node may have several zones on node_zonelists
> 
> 3. Solution Proposed in Patch
> 
>   We could reduce these redundant check by record the last unsuccessful
>   node and then skip it.
> 
> 4. Tests & Result
> 
>   After some tests, the result shows this may improve the system a little,
>   especially on a machine with only one node.
> 
> 4.1 Test Description
> 
>   There are two cases for two system configurations.
> 
>   Test Cases:
> 
>     1. counter comparison
>     2. kernel build test
> 
>   System Configuration:
> 
>     1. One node machine with 4G
>     2. Four node machine with 8G
> 
> 4.2 Result for Test 1
> 
>   Test 1: counter comparison
> 
>   This is a test with hacked kernel to record times function
>   get_any_partial() is invoked and times the inner loop iterates. By
>   comparing the ratio of two counters, we get to know how many inner
>   loops we skipped.
> 
>   Here is a snip of the test patch.
> 
>   ---
>   static void *get_any_partial() {
> 
> 	get_partial_count++;
> 
>         do {
> 		for_each_zone_zonelist() {
> 			get_partial_try_count++;
> 		}
> 	} while();
> 
> 	return NULL;
>   }
>   ---
> 
>   The result of (get_partial_count / get_partial_try_count):
> 
>    +----------+----------------+------------+-------------+
>    |          |       Base     |    Patched |  Improvement|
>    +----------+----------------+------------+-------------+
>    |One Node  |       1:3      |    1:0     |      - 100% |
>    +----------+----------------+------------+-------------+
>    |Four Nodes|       1:5.8    |    1:2.5   |      -  56% |
>    +----------+----------------+------------+-------------+
> 
> 4.3 Result for Test 2
> 
>   Test 2: kernel build
> 
>    Command used:
> 
>    > time make -j8 bzImage
> 
>    Each version/system configuration combination has four round kernel
>    build tests. Take the average result of real to compare.
> 
>    +----------+----------------+------------+-------------+
>    |          |       Base     |   Patched  |  Improvement|
>    +----------+----------------+------------+-------------+
>    |One Node  |      4m41s     |   4m32s    |     - 4.47% |
>    +----------+----------------+------------+-------------+
>    |Four Nodes|      4m45s     |   4m39s    |     - 2.92% |
>    +----------+----------------+------------+-------------+
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> 

Looks good to me, but I'll await input from the slab maintainers before
proceeding any further.

I didn't like the variable name much, and the comment could be
improved.  Please review:


--- a/mm/slub.c~mm-slub-improve-performance-by-skipping-checked-node-in-get_any_partial-fix
+++ a/mm/slub.c
@@ -1873,7 +1873,7 @@ static void *get_partial_node(struct kme
  * Get a page from somewhere. Search in increasing NUMA distances.
  */
 static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
-		struct kmem_cache_cpu *c, int except)
+		struct kmem_cache_cpu *c, int exclude_nid)
 {
 #ifdef CONFIG_NUMA
 	struct zonelist *zonelist;
@@ -1911,7 +1911,7 @@ static void *get_any_partial(struct kmem
 		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 			struct kmem_cache_node *n;
 
-			if (except == zone_to_nid(zone))
+			if (exclude_nid == zone_to_nid(zone))
 				continue;
 
 			n = get_node(s, zone_to_nid(zone));
@@ -1931,12 +1931,13 @@ static void *get_any_partial(struct kmem
 				}
 			}
 			/*
-			 * Fail to get object from this node, either because
-			 *   1. Fails in if check
-			 *   2. NULl object returns from get_partial_node()
-			 * Skip it next time.
+			 * Failed to get an object from this node, either 
+			 * because
+			 *   1. Failure in the above if check
+			 *   2. NULL return from get_partial_node()
+			 * So skip this node next time.
 			 */
-			except = zone_to_nid(zone);
+			exclude_nid = zone_to_nid(zone);
 		}
 	} while (read_mems_allowed_retry(cpuset_mems_cookie));
 #endif
_
