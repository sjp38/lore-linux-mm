Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5E86B007E
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:13:18 -0500 (EST)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 13 Nov 2009 16:18:23 -0500
Message-Id: <20091113211823.15074.1305.sendpatchset@localhost.localdomain>
In-Reply-To: <20091113211714.15074.29078.sendpatchset@localhost.localdomain>
References: <20091113211714.15074.29078.sendpatchset@localhost.localdomain>
Subject: [PATCH/RFC 6/6] numa: slab:  use numa_mem_id() for slab local memory node
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH] numa:  Slab handle memoryless nodes

Against:  2.6.32-rc5-mmotm-091101-1001

Example usage of generic "numa_mem_id()":

The mainline slab code, since ~ 2.6.19, does not handle memoryless
nodes well.  Specifically, the "fast path"--____cache_alloc()--will
never succeed as slab doesn't cache offnode object on the per cpu
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

N.B.:  incomplete.  slab will need to handle node and memory hotplug
that could change the value returned by numa_mem_id() for any given
node.  This will be addressed by a subsequent patch, if we decide to
go this route.

Performance impact on "hackbench 400 process 200"

2.6.32-rc5+mmotm-091101		no-patch	this-patch
no memoryless nodes [avg of 10]:  12.700	  12.856  ~1.2%
cpus all on memless nodes  [20]: 261.530	  27.700 ~10x speedup

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

---

 mm/slab.c |   27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

Index: linux-2.6.32-rc5-mmotm-091101-1001/mm/slab.c
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/mm/slab.c
+++ linux-2.6.32-rc5-mmotm-091101-1001/mm/slab.c
@@ -1064,7 +1064,7 @@ static inline int cache_free_alien(struc
 	struct array_cache *alien = NULL;
 	int node;
 
-	node = numa_node_id();
+	node = numa_mem_id();
 
 	/*
 	 * Make sure we are not freeing a object from another node to the array
@@ -1407,7 +1407,7 @@ void __init kmem_cache_init(void)
 	 * 6) Resize the head arrays of the kmalloc caches to their final sizes.
 	 */
 
-	node = numa_node_id();
+	node = numa_mem_id();
 
 	/* 1) create the cache_cache */
 	INIT_LIST_HEAD(&cache_chain);
@@ -2041,7 +2041,7 @@ static int __init_refok setup_cpu_cache(
 			}
 		}
 	}
-	cachep->nodelists[numa_node_id()]->next_reap =
+	cachep->nodelists[numa_mem_id()]->next_reap =
 			jiffies + REAPTIMEOUT_LIST3 +
 			((unsigned long)cachep) % REAPTIMEOUT_LIST3;
 
@@ -2372,7 +2372,7 @@ static void check_spinlock_acquired(stru
 {
 #ifdef CONFIG_SMP
 	check_irq_off();
-	assert_spin_locked(&cachep->nodelists[numa_node_id()]->list_lock);
+	assert_spin_locked(&cachep->nodelists[numa_mem_id()]->list_lock);
 #endif
 }
 
@@ -2399,7 +2399,7 @@ static void do_drain(void *arg)
 {
 	struct kmem_cache *cachep = arg;
 	struct array_cache *ac;
-	int node = numa_node_id();
+	int node = numa_mem_id();
 
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
@@ -2932,7 +2932,7 @@ static void *cache_alloc_refill(struct k
 
 retry:
 	check_irq_off();
-	node = numa_node_id();
+	node = numa_mem_id();
 	ac = cpu_cache_get(cachep);
 	batchcount = ac->batchcount;
 	if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
@@ -3128,7 +3128,7 @@ static void *alternate_node_alloc(struct
 
 	if (in_interrupt() || (flags & __GFP_THISNODE))
 		return NULL;
-	nid_alloc = nid_here = numa_node_id();
+	nid_alloc = nid_here = numa_mem_id();
 	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
 		nid_alloc = cpuset_mem_spread_node();
 	else if (current->mempolicy)
@@ -3297,6 +3297,7 @@ __cache_alloc_node(struct kmem_cache *ca
 {
 	unsigned long save_flags;
 	void *ptr;
+	int slab_node = numa_mem_id();
 
 	flags &= gfp_allowed_mask;
 
@@ -3309,7 +3310,7 @@ __cache_alloc_node(struct kmem_cache *ca
 	local_irq_save(save_flags);
 
 	if (unlikely(nodeid == -1))
-		nodeid = numa_node_id();
+		nodeid = slab_node;
 
 	if (unlikely(!cachep->nodelists[nodeid])) {
 		/* Node not bootstrapped yet */
@@ -3317,7 +3318,7 @@ __cache_alloc_node(struct kmem_cache *ca
 		goto out;
 	}
 
-	if (nodeid == numa_node_id()) {
+	if (nodeid == slab_node) {
 		/*
 		 * Use the locally cached objects if possible.
 		 * However ____cache_alloc does not allow fallback
@@ -3361,8 +3362,8 @@ __do_cache_alloc(struct kmem_cache *cach
 	 * We may just have run out of memory on the local node.
 	 * ____cache_alloc_node() knows how to locate memory on other nodes
 	 */
- 	if (!objp)
- 		objp = ____cache_alloc_node(cache, flags, numa_node_id());
+	if (!objp)
+		objp = ____cache_alloc_node(cache, flags, numa_mem_id());
 
   out:
 	return objp;
@@ -3459,7 +3460,7 @@ static void cache_flusharray(struct kmem
 {
 	int batchcount;
 	struct kmem_list3 *l3;
-	int node = numa_node_id();
+	int node = numa_mem_id();
 
 	batchcount = ac->batchcount;
 #if DEBUG
@@ -4034,7 +4035,7 @@ static void cache_reap(struct work_struc
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
