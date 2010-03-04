Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 787196B00A6
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 12:00:17 -0500 (EST)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 04 Mar 2010 12:08:30 -0500
Message-Id: <20100304170830.10606.70559.sendpatchset@localhost.localdomain>
In-Reply-To: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
References: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
Subject: [PATCH/RFC 7/8] numa: slab:  use numa_mem_id() for slab local memory node
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH] numa:  Slab handle memoryless nodes

Against:  2.6.33-mmotm-100302-1838

Example usage of generic "numa_mem_id()":

The mainline slab code, since ~ 2.6.19, does not handle memoryless
nodes well.  Specifically, the "fast path"--____cache_alloc()--will
never succeed as slab doesn't cache offnode objects on the per cpu
queues, and for memoryless nodes, all memory will be "off node"
relative to numa_node_id().  This adds significant overhead to all
kmem cache allocations, incurring a significant regression relative
to earlier kernels [from before slab.c was reorganized].

This patch uses the generic topology function "numa_mem_id()" to
return the "effective local memory node" for the calling context.
This is the first node in the local node's generic fallback zonelist--
i.e., the same node that "local" mempolicy-based allocations would
use.  This lets slab cache these "local" allocations and avoid
fallback/refill on every allocation.

N.B.:  Slab will need to handle node and memory hotplug events that
could change the value returned by numa_mem_id() for any given
node.  E.g., flush all per cpu slab queues before rebuilding the
zonelists.  Andi Kleen and David Rientjes are currently working on
patch series to improve slab support for memory hotplug.  When that
effort settles down, and if there is general agreement on this
approach, I'll prepare another patch to address possible change in
"local memory node", if still necessary.

Performance impact on "hackbench 400 process 200"

2.6.33+mmotm-100302-1838	       no-patch  this-patch [series]
ia64 no memoryless nodes [avg of 10]: 	 11.853	   11.739 (secs)
ia64 cpus all on memless nodes  [10]: 	264.909	   27.938 ~10x speedup

The slowdown of the patched kernel from ~12 sec to ~28 seconds when
configured with memoryless nodes is the result of all cpus allocating
from a single node's mm pagepool.  The cache lines of the single node
are distributed/interleaved over the memory of the real physical nodes,
but the zone locks of the single node with memory still each live in a
single cache line that is accessed from all processors.

x86_64 [8x6 AMD] [avg of 10]:	   	  3.322	    3.148

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/slab.c |   27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

Index: linux-2.6.33-mmotm-100302-1838/mm/slab.c
===================================================================
--- linux-2.6.33-mmotm-100302-1838.orig/mm/slab.c
+++ linux-2.6.33-mmotm-100302-1838/mm/slab.c
@@ -1073,7 +1073,7 @@ static inline int cache_free_alien(struc
 	struct array_cache *alien = NULL;
 	int node;
 
-	node = numa_node_id();
+	node = numa_mem_id();
 
 	/*
 	 * Make sure we are not freeing a object from another node to the array
@@ -1418,7 +1418,7 @@ void __init kmem_cache_init(void)
 	 * 6) Resize the head arrays of the kmalloc caches to their final sizes.
 	 */
 
-	node = numa_node_id();
+	node = numa_mem_id();
 
 	/* 1) create the cache_cache */
 	INIT_LIST_HEAD(&cache_chain);
@@ -2052,7 +2052,7 @@ static int __init_refok setup_cpu_cache(
 			}
 		}
 	}
-	cachep->nodelists[numa_node_id()]->next_reap =
+	cachep->nodelists[numa_mem_id()]->next_reap =
 			jiffies + REAPTIMEOUT_LIST3 +
 			((unsigned long)cachep) % REAPTIMEOUT_LIST3;
 
@@ -2383,7 +2383,7 @@ static void check_spinlock_acquired(stru
 {
 #ifdef CONFIG_SMP
 	check_irq_off();
-	assert_spin_locked(&cachep->nodelists[numa_node_id()]->list_lock);
+	assert_spin_locked(&cachep->nodelists[numa_mem_id()]->list_lock);
 #endif
 }
 
@@ -2410,7 +2410,7 @@ static void do_drain(void *arg)
 {
 	struct kmem_cache *cachep = arg;
 	struct array_cache *ac;
-	int node = numa_node_id();
+	int node = numa_mem_id();
 
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
@@ -2943,7 +2943,7 @@ static void *cache_alloc_refill(struct k
 
 retry:
 	check_irq_off();
-	node = numa_node_id();
+	node = numa_mem_id();
 	ac = cpu_cache_get(cachep);
 	batchcount = ac->batchcount;
 	if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
@@ -3147,7 +3147,7 @@ static void *alternate_node_alloc(struct
 
 	if (in_interrupt() || (flags & __GFP_THISNODE))
 		return NULL;
-	nid_alloc = nid_here = numa_node_id();
+	nid_alloc = nid_here = numa_mem_id();
 	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
 		nid_alloc = cpuset_mem_spread_node();
 	else if (current->mempolicy)
@@ -3316,6 +3316,7 @@ __cache_alloc_node(struct kmem_cache *ca
 {
 	unsigned long save_flags;
 	void *ptr;
+	int slab_node = numa_mem_id();
 
 	flags &= gfp_allowed_mask;
 
@@ -3328,7 +3329,7 @@ __cache_alloc_node(struct kmem_cache *ca
 	local_irq_save(save_flags);
 
 	if (nodeid == -1)
-		nodeid = numa_node_id();
+		nodeid = slab_node;
 
 	if (unlikely(!cachep->nodelists[nodeid])) {
 		/* Node not bootstrapped yet */
@@ -3336,7 +3337,7 @@ __cache_alloc_node(struct kmem_cache *ca
 		goto out;
 	}
 
-	if (nodeid == numa_node_id()) {
+	if (nodeid == slab_node) {
 		/*
 		 * Use the locally cached objects if possible.
 		 * However ____cache_alloc does not allow fallback
@@ -3380,8 +3381,8 @@ __do_cache_alloc(struct kmem_cache *cach
 	 * We may just have run out of memory on the local node.
 	 * ____cache_alloc_node() knows how to locate memory on other nodes
 	 */
- 	if (!objp)
- 		objp = ____cache_alloc_node(cache, flags, numa_node_id());
+	if (!objp)
+		objp = ____cache_alloc_node(cache, flags, numa_mem_id());
 
   out:
 	return objp;
@@ -3478,7 +3479,7 @@ static void cache_flusharray(struct kmem
 {
 	int batchcount;
 	struct kmem_list3 *l3;
-	int node = numa_node_id();
+	int node = numa_mem_id();
 
 	batchcount = ac->batchcount;
 #if DEBUG
@@ -4053,7 +4054,7 @@ static void cache_reap(struct work_struc
 {
 	struct kmem_cache *searchp;
 	struct kmem_list3 *l3;
-	int node = numa_node_id();
+	int node = numa_mem_id();
 	struct delayed_work *work = to_delayed_work(w);
 
 	if (!mutex_trylock(&cache_chain_mutex))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
