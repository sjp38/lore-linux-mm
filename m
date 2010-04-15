Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 574D7600373
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:31:05 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 15 Apr 2010 13:30:30 -0400
Message-Id: <20100415173030.8801.84836.sendpatchset@localhost.localdomain>
In-Reply-To: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
Subject: [PATCH 6/8] numa: slab:  use numa_mem_id() for slab local memory node
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi@domain.invalid, Kleen@domain.invalid, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Against:  2.6.34-rc3-mmotm-100405-1609

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
the same node that "local" mempolicy-based allocations would use.
This lets slab cache these "local" allocations and avoid
fallback/refill on every allocation.

N.B.:  Slab will need to handle node and memory hotplug events that
could change the value returned by numa_mem_id() for any given
node if recent changes to address memory hotplug don't already
address this.  E.g., flush all per cpu slab queues before rebuilding
the zonelists while the "machine" is held in the stopped state.

Performance impact on "hackbench 400 process 200"

2.6.34-rc3-mmotm-100405-1609		no-patch	this-patch
ia64 no memoryless nodes [avg of 10]:     11.713       11.637  ~0.65 diff
ia64 cpus all on memless nodes  [10]:    228.259       26.484  ~8.6x speedup

The slowdown of the patched kernel from ~12 sec to ~28 seconds when
configured with memoryless nodes is the result of all cpus allocating
from a single node's mm pagepool.  The cache lines of the single node
are distributed/interleaved over the memory of the real physical nodes,
but the zone lock, list heads, ... of the single node with memory still
each live in a single cache line that is accessed from all processors.

x86_64 [8x6 AMD] [avg of 40]:		2.883	   2.845

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

---

V4:	no change to code.  rebased patch and updated test results
	in description.


 mm/slab.c |   43 ++++++++++++++++++++++---------------------
 1 files changed, 22 insertions(+), 21 deletions(-)

Index: linux-2.6.34-rc3-mmotm-100405-1609/mm/slab.c
===================================================================
--- linux-2.6.34-rc3-mmotm-100405-1609.orig/mm/slab.c	2010-04-07 10:04:02.000000000 -0400
+++ linux-2.6.34-rc3-mmotm-100405-1609/mm/slab.c	2010-04-07 10:11:34.000000000 -0400
@@ -844,7 +844,7 @@ static void init_reap_node(int cpu)
 {
 	int node;
 
-	node = next_node(cpu_to_node(cpu), node_online_map);
+	node = next_node(cpu_to_mem(cpu), node_online_map);
 	if (node == MAX_NUMNODES)
 		node = first_node(node_online_map);
 
@@ -1073,7 +1073,7 @@ static inline int cache_free_alien(struc
 	struct array_cache *alien = NULL;
 	int node;
 
-	node = numa_node_id();
+	node = numa_mem_id();
 
 	/*
 	 * Make sure we are not freeing a object from another node to the array
@@ -1106,7 +1106,7 @@ static void __cpuinit cpuup_canceled(lon
 {
 	struct kmem_cache *cachep;
 	struct kmem_list3 *l3 = NULL;
-	int node = cpu_to_node(cpu);
+	int node = cpu_to_mem(cpu);
 	const struct cpumask *mask = cpumask_of_node(node);
 
 	list_for_each_entry(cachep, &cache_chain, next) {
@@ -1171,7 +1171,7 @@ static int __cpuinit cpuup_prepare(long
 {
 	struct kmem_cache *cachep;
 	struct kmem_list3 *l3 = NULL;
-	int node = cpu_to_node(cpu);
+	int node = cpu_to_mem(cpu);
 	const int memsize = sizeof(struct kmem_list3);
 
 	/*
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
@@ -3209,7 +3209,7 @@ retry:
 		if (local_flags & __GFP_WAIT)
 			local_irq_enable();
 		kmem_flagcheck(cache, flags);
-		obj = kmem_getpages(cache, local_flags, numa_node_id());
+		obj = kmem_getpages(cache, local_flags, numa_mem_id());
 		if (local_flags & __GFP_WAIT)
 			local_irq_disable();
 		if (obj) {
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
@@ -3923,7 +3924,7 @@ static int do_tune_cpucache(struct kmem_
 		return -ENOMEM;
 
 	for_each_online_cpu(i) {
-		new->new[i] = alloc_arraycache(cpu_to_node(i), limit,
+		new->new[i] = alloc_arraycache(cpu_to_mem(i), limit,
 						batchcount, gfp);
 		if (!new->new[i]) {
 			for (i--; i >= 0; i--)
@@ -3945,9 +3946,9 @@ static int do_tune_cpucache(struct kmem_
 		struct array_cache *ccold = new->new[i];
 		if (!ccold)
 			continue;
-		spin_lock_irq(&cachep->nodelists[cpu_to_node(i)]->list_lock);
-		free_block(cachep, ccold->entry, ccold->avail, cpu_to_node(i));
-		spin_unlock_irq(&cachep->nodelists[cpu_to_node(i)]->list_lock);
+		spin_lock_irq(&cachep->nodelists[cpu_to_mem(i)]->list_lock);
+		free_block(cachep, ccold->entry, ccold->avail, cpu_to_mem(i));
+		spin_unlock_irq(&cachep->nodelists[cpu_to_mem(i)]->list_lock);
 		kfree(ccold);
 	}
 	kfree(new);
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
