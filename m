Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A1A5F6B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 13:08:18 -0400 (EDT)
Subject: [PATCH/RFC] slab:  handle memoryless nodes efficiently
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Thu, 29 Oct 2009 13:08:14 -0400
Message-Id: <1256836094.16599.67.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>



Mainline slab code, since ~2.6.19 [first noted in SLES11 2.6.27+]
does not handle memoryless nodes well.  Specifically, the "fast path"--
____cache_alloc()--will never succeed, but will be called twice:
once speculatively [expected to succeed] and once in the fallback
path.  Furthermore, it appears that slab will never cache allocations
for remote nodes, even when the remote node is the "local" node as
far as memory policy is concerned.   This adds significant overhead
to all kmem cache allocations, incurring a significant regression
relative to earlier kernels [from before slab.c was reorganized].

This regression was discussed more in the thread re:  Mel Gorman's
"slqb: Treat pages freed on a memoryless node as local node":

	http://marc.info/?l=linux-mm&m=125364419720601&w=4

The effects of the regression are quite noticable with hackbench
on HP ia64 platforms that support hardware interleaving of memory,
resulting in all physical nodes appearing as memoryless and all
memory appearing in a cpu-less pseudo-node.  This is the "0%CLM"
[Cell Local Memory] line below.

Measurements for "hackbench 400 process 200":

 2.6.23-rc5 rx8640 [ia64 4 node x 4 socket x dual core = 64 'cpus']

 		no patch	with patch
   0%CLM Time:	284.158		  28.048         improvement ~10x

 100%CLM Time:	 12.869		  12.111         ~= [no memoryless nodes]

Currently, x64_64 will not see this issue because it assigns cpus on
memoryless nodes to some other node with memory [without regard to
"distance, I might add].  I measured the patch on x86_64 [on a platform
with no memoryless nodes] to check the overhead there.

 2.6.23-rc5  x86_64:  8 socket x quad core "Shanghai"

		no patch	with patch
		  4.420		   4.370	<= both avg of 40runs

So, this patch appears to solve the regression with memoryless nodes
on the HP ia64 platform and seems to have no performance regression
on the ia64 platform configured with all local memory [no memoryless
nodes].  Also, no performance regression according to hackbench on the
x86_64 that doesn't "need" the patch.  

Interestingly, the patched kernel seems to produce better times on
my two test platforms w/o memoryless nodes than the unpatched kernel.
I thought that this might be due to run-to-run variation and that 
I might have captured a particularly good patched run and a bad 
unpatched run.  But, the average of 40 runs on the x86_64 also shows
the patched kernel slightly better.  Could still be a fluke, I suppose.

This patch attempts to alleviate the regression by modifying slab.c
to treat the first fallback node in a memoryless node's general
zonelist as the "slab local node" -- i.e., the local node for the
purpose of slab allocations.

The new function numa_slab_nid(gfp_t) replaces all calls to
numa_node_id() in slab.c.  numa_slab_id() will simply return
numa_node_id() for nodes with memory, but will return the first
node in the local node's zonelist selected by the gfp flags.

When I first tried this patch with the SLES11 kernel [2.6.27+] where
we first noticed this regression, we saw a few % regression in
hackbench times on the system configured with no memoryless nodes
for the patched kernel vs unpatched.  At Nick Piggin's suggestion,
I tried caching the "slab node id" for memoryless nodes in the
kmem_cache structure to avoid accessing the node_states[] and
zonelist.  I chose to use the list3 link for the memoryless node as
the cache, as they aren't really used for memoryless nodes.  This
worked on SLES11 and reduced the overhead somewhat.  However,
due to changes in the mainline slab code since then [possibly in
the alien cache handling, or Novell changes to the alien cache
handling in SLES11], the "caching" version of the patch does not work
on mainline kernels.  That is, the caching version of the patch does
not fix the regression in mainline.  Thus, I've dropped back to
the non-caching version that works on mainline and doesn't seem to
have noticable overhead there--at least for the hackbench test.

However, I wonder about the interaction with the alien caches and
cache reaping and whether I might be missing something with this patch.
It can certainly use more test on more platforms.  Thus the "RFC" state.


Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/slab.c |   51 +++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 39 insertions(+), 12 deletions(-)

Index: linux-2.6.32-rc5/mm/slab.c
===================================================================
--- linux-2.6.32-rc5.orig/mm/slab.c
+++ linux-2.6.32-rc5/mm/slab.c
@@ -932,6 +932,11 @@ static int transfer_objects(struct array
 #define drain_alien_cache(cachep, alien) do { } while (0)
 #define reap_alien(cachep, l3) do { } while (0)
 
+static int numa_slab_nid(gfp_t flags)
+{
+	return 0;
+}
+
 static inline struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
 {
 	return (struct array_cache **)BAD_ALIEN_MAGIC;
@@ -963,6 +968,27 @@ static inline void *____cache_alloc_node
 static void *____cache_alloc_node(struct kmem_cache *, gfp_t, int);
 static void *alternate_node_alloc(struct kmem_cache *, gfp_t);
 
+/*
+ * "Local" node for slab is first node in zonelist with memory.
+ * For nodes with memory this will be the actual local node.
+ */
+static int numa_slab_nid(gfp_t flags)
+{
+	struct zonelist *zonelist;
+	struct zone *zone;
+	enum zone_type highest_zoneidx = gfp_zone(flags);
+	int node = numa_node_id();
+
+	if (likely(node_state(node, N_HIGH_MEMORY)))
+		return node;
+
+	zonelist = &NODE_DATA(node)->node_zonelists[0];
+	(void)first_zones_zonelist(zonelist, highest_zoneidx,
+						NULL,
+						&zone);
+	return zone->node;
+}
+
 static struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
 {
 	struct array_cache **ac_ptr;
@@ -1064,7 +1090,7 @@ static inline int cache_free_alien(struc
 	struct array_cache *alien = NULL;
 	int node;
 
-	node = numa_node_id();
+	node = numa_slab_nid(GFP_KERNEL);
 
 	/*
 	 * Make sure we are not freeing a object from another node to the array
@@ -1407,7 +1433,7 @@ void __init kmem_cache_init(void)
 	 * 6) Resize the head arrays of the kmalloc caches to their final sizes.
 	 */
 
-	node = numa_node_id();
+	node = numa_slab_nid(GFP_KERNEL);
 
 	/* 1) create the cache_cache */
 	INIT_LIST_HEAD(&cache_chain);
@@ -2041,7 +2067,7 @@ static int __init_refok setup_cpu_cache(
 			}
 		}
 	}
-	cachep->nodelists[numa_node_id()]->next_reap =
+	cachep->nodelists[numa_slab_nid(GFP_KERNEL)]->next_reap =
 			jiffies + REAPTIMEOUT_LIST3 +
 			((unsigned long)cachep) % REAPTIMEOUT_LIST3;
 
@@ -2370,7 +2396,7 @@ static void check_spinlock_acquired(stru
 {
 #ifdef CONFIG_SMP
 	check_irq_off();
-	assert_spin_locked(&cachep->nodelists[numa_node_id()]->list_lock);
+	assert_spin_locked(&cachep->nodelists[numa_slab_nid(GFP_KERNEL)]->list_lock);
 #endif
 }
 
@@ -2397,7 +2423,7 @@ static void do_drain(void *arg)
 {
 	struct kmem_cache *cachep = arg;
 	struct array_cache *ac;
-	int node = numa_node_id();
+	int node = numa_slab_nid(GFP_KERNEL);
 
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
@@ -2930,7 +2956,7 @@ static void *cache_alloc_refill(struct k
 
 retry:
 	check_irq_off();
-	node = numa_node_id();
+	node = numa_slab_nid(flags);
 	ac = cpu_cache_get(cachep);
 	batchcount = ac->batchcount;
 	if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
@@ -3126,7 +3152,7 @@ static void *alternate_node_alloc(struct
 
 	if (in_interrupt() || (flags & __GFP_THISNODE))
 		return NULL;
-	nid_alloc = nid_here = numa_node_id();
+	nid_alloc = nid_here = numa_slab_nid(flags);
 	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
 		nid_alloc = cpuset_mem_spread_node();
 	else if (current->mempolicy)
@@ -3295,6 +3321,7 @@ __cache_alloc_node(struct kmem_cache *ca
 {
 	unsigned long save_flags;
 	void *ptr;
+	int slab_node = numa_slab_nid(flags);
 
 	flags &= gfp_allowed_mask;
 
@@ -3307,7 +3334,7 @@ __cache_alloc_node(struct kmem_cache *ca
 	local_irq_save(save_flags);
 
 	if (unlikely(nodeid == -1))
-		nodeid = numa_node_id();
+		nodeid = slab_node;
 
 	if (unlikely(!cachep->nodelists[nodeid])) {
 		/* Node not bootstrapped yet */
@@ -3315,7 +3342,7 @@ __cache_alloc_node(struct kmem_cache *ca
 		goto out;
 	}
 
-	if (nodeid == numa_node_id()) {
+	if (nodeid == slab_node) {
 		/*
 		 * Use the locally cached objects if possible.
 		 * However ____cache_alloc does not allow fallback
@@ -3360,7 +3387,7 @@ __do_cache_alloc(struct kmem_cache *cach
 	 * ____cache_alloc_node() knows how to locate memory on other nodes
 	 */
  	if (!objp)
- 		objp = ____cache_alloc_node(cache, flags, numa_node_id());
+ 		objp = ____cache_alloc_node(cache, flags, numa_slab_nid(flags));
 
   out:
 	return objp;
@@ -3457,7 +3484,7 @@ static void cache_flusharray(struct kmem
 {
 	int batchcount;
 	struct kmem_list3 *l3;
-	int node = numa_node_id();
+	int node = numa_slab_nid(GFP_KERNEL);
 
 	batchcount = ac->batchcount;
 #if DEBUG
@@ -4032,7 +4059,7 @@ static void cache_reap(struct work_struc
 {
 	struct kmem_cache *searchp;
 	struct kmem_list3 *l3;
-	int node = numa_node_id();
+	int node = numa_slab_nid(GFP_KERNEL);
 	struct delayed_work *work = to_delayed_work(w);
 
 	if (!mutex_trylock(&cache_chain_mutex))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
