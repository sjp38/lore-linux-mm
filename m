Date: Wed, 27 Apr 2005 11:10:10 -0400
From: Martin Hicks <mort@sgi.com>
Subject: [PATCH/RFC 4/4] VM: automatic reclaim through mempolicy
Message-ID: <20050427151010.GV8018@localhost>
References: <20050427145734.GL8018@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050427145734.GL8018@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linux-MM <linux-mm@kvack.org>
Cc: Ray Bryant <raybry@sgi.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>

This implements a set of flags that modify the behavior
of the the mempolicies to allow reclaiming of preferred 
memory (as definited by the mempolicy) before spilling
onto remote nodes.  It also adds a new mempolicy
"localreclaim" which is just the default mempolicy with
non-zero reclaim flags.

The change required adding a "flags" argument to sys_set_mempolicy()
to give hints about what kind of memory you're willing to sacrifice.

A patch for numactl-0.6.4 to support these new flags is at
http://www.bork.org/~mort/sgi/localreclaim/numactl-localreclaim.patch
This patch breaks compatibility, but I just needed something to
test with.  I did update the numactl's usage message with the
new bits.  Essentially just add "--localreclaim=[umUM]" to get
the allocator to use localreclaim.

I'm sure that better tuning of the rate-limiting code in
vmscan.c::reclaim_clean_pages() could help performance further,
but at this stage I was fairly happy to keep the system time
at a reasonable level.  The obvious difficulty with this patch
is to ensure that it doesn't scan the LRU lists to death, looking
for those non-existant clean pages.

Here are some kernbench runs that show that things don't get out of
control under heavy VM pressure.  I think kernbench's "Maximal" run
is a fairly stressful test for this code because it allocates all
of the memory out of the system and still must do disk IO during
the compiles.

I haven't yet had time to do a run in a situation where I think the
patches will make a real difference.  I'm going to do some runs
with a big HPC app this week.

The test machine was a 4-way 8GB Altix.  The "minimal" (make -j3) and
"optimal" (make -j16) results are uninteresting.  All three runs
show almost exactly the same results because we never actually invoke
any of this new code.  There is no VM pressure.

		Wall	User	System	%CPU	Ctx Sw	Sleeps
		-----	----	------	----	------	------
2.6.12-rc2-mm2	1296	1375	387	160	252333	388268
noreclaim	1111	1370	319	195	216259	318279
reclaim=um	1251	1373	312	160	223148	371875

This is just the average of two runs.  There seems to be large
variance in the first two, but the reclaim=um run is quite
consistent.

2.6.12-rc2-mm2 is kernbench run on a pristine tree.
noreclaim is with the patches, but no use of numactl.
reclaim=um is kernbench invoked with:

./numactl --localreclaim=um ../kernbench-0.3.0/kernbench



Signed-off-by: Marting Hicks <mort@sgi.com>
---


 include/linux/gfp.h       |    3 +
 include/linux/mempolicy.h |   33 ++++++++++++++---
 mm/mempolicy.c            |   68 ++++++++++++++++++++++++++---------
 mm/page_alloc.c           |   87 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 168 insertions(+), 23 deletions(-)

Index: linux-2.6.12-rc2.wk/mm/mempolicy.c
===================================================================
--- linux-2.6.12-rc2.wk.orig/mm/mempolicy.c	2005-04-27 06:27:38.000000000 -0700
+++ linux-2.6.12-rc2.wk/mm/mempolicy.c	2005-04-27 07:09:09.000000000 -0700
@@ -19,7 +19,7 @@
  *                is used.
  * bind           Only allocate memory on a specific set of nodes,
  *                no fallback.
- * preferred       Try a specific node first before normal fallback.
+ * preferred      Try a specific node first before normal fallback.
  *                As a special case node -1 here means do the allocation
  *                on the local CPU. This is normally identical to default,
  *                but useful to set in a VMA when you have a non default
@@ -27,6 +27,9 @@
  * default        Allocate on the local node first, or when on a VMA
  *                use the process policy. This is what Linux always did
  *		  in a NUMA aware kernel and still does by, ahem, default.
+ * localreclaim   This is a special case of default.  The allocator
+ *                will try very hard to get a local allocation.  It
+ *                invokes page cache cleaners and slab cleaners.
  *
  * The process policy is applied for most non interrupt memory allocations
  * in that process' context. Interrupts ignore the policies and always
@@ -113,6 +116,7 @@ static int mpol_check_policy(int mode, u
 
 	switch (mode) {
 	case MPOL_DEFAULT:
+	case MPOL_LOCALRECLAIM:
 		if (!empty)
 			return -EINVAL;
 		break;
@@ -205,13 +209,19 @@ static struct zonelist *bind_zonelist(un
 }
 
 /* Create a new policy */
-static struct mempolicy *mpol_new(int mode, unsigned long *nodes)
+static struct mempolicy *mpol_new(int mode, unsigned long *nodes,
+				  unsigned int flags)
 {
 	struct mempolicy *policy;
+	int mpol_flags = mpol_to_reclaim_flags(flags);
 
 	PDprintk("setting mode %d nodes[0] %lx\n", mode, nodes[0]);
-	if (mode == MPOL_DEFAULT)
-		return NULL;
+	if (mode == MPOL_DEFAULT) {
+		if (!flags)
+			return NULL;
+		else
+			mode = MPOL_LOCALRECLAIM;
+	}
 	policy = kmem_cache_alloc(policy_cache, GFP_KERNEL);
 	if (!policy)
 		return ERR_PTR(-ENOMEM);
@@ -234,6 +244,7 @@ static struct mempolicy *mpol_new(int mo
 		break;
 	}
 	policy->policy = mode;
+	policy->flags = mpol_flags;
 	return policy;
 }
 
@@ -384,7 +395,7 @@ asmlinkage long sys_mbind(unsigned long 
 	if (err)
 		return err;
 
-	new = mpol_new(mode, nodes);
+	new = mpol_new(mode, nodes, flags);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 
@@ -403,7 +414,7 @@ asmlinkage long sys_mbind(unsigned long 
 
 /* Set the process memory policy */
 asmlinkage long sys_set_mempolicy(int mode, unsigned long __user *nmask,
-				   unsigned long maxnode)
+				  unsigned long maxnode, int flags)
 {
 	int err;
 	struct mempolicy *new;
@@ -411,10 +422,12 @@ asmlinkage long sys_set_mempolicy(int mo
 
 	if (mode > MPOL_MAX)
 		return -EINVAL;
+	if (flags & MPOL_FLAG_MASK)
+		return -EINVAL;
 	err = get_nodes(nodes, nmask, maxnode, mode);
 	if (err)
 		return err;
-	new = mpol_new(mode, nodes);
+	new = mpol_new(mode, nodes, flags);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 	mpol_free(current->mempolicy);
@@ -436,6 +449,7 @@ static void get_zonemask(struct mempolic
 			__set_bit(p->v.zonelist->zones[i]->zone_pgdat->node_id, nodes);
 		break;
 	case MPOL_DEFAULT:
+	case MPOL_LOCALRECLAIM:
 		break;
 	case MPOL_INTERLEAVE:
 		bitmap_copy(nodes, p->v.nodes, MAX_NUMNODES);
@@ -600,7 +614,7 @@ asmlinkage long compat_sys_set_mempolicy
 	if (err)
 		return -EFAULT;
 
-	return sys_set_mempolicy(mode, nm, nr_bits+1);
+	return sys_set_mempolicy(mode, nm, nr_bits+1, 0);
 }
 
 asmlinkage long compat_sys_mbind(compat_ulong_t start, compat_ulong_t len,
@@ -666,6 +680,7 @@ static struct zonelist *zonelist_policy(
 				return policy->v.zonelist;
 		/*FALL THROUGH*/
 	case MPOL_INTERLEAVE: /* should not happen */
+	case MPOL_LOCALRECLAIM:
 	case MPOL_DEFAULT:
 		nd = numa_node_id();
 		break;
@@ -712,14 +727,17 @@ static unsigned offset_il_node(struct me
 
 /* Allocate a page in interleaved policy.
    Own path because it needs to do special accounting. */
-static struct page *alloc_page_interleave(unsigned int __nocast gfp, unsigned order, unsigned nid)
+static struct page *alloc_page_interleave(unsigned int __nocast gfp, unsigned order, unsigned nid, int flags)
 {
 	struct zonelist *zl;
 	struct page *page;
 
 	BUG_ON(!node_online(nid));
 	zl = NODE_DATA(nid)->node_zonelists + (gfp & GFP_ZONEMASK);
-	page = __alloc_pages(gfp, order, zl);
+	if (flags)
+		page = __alloc_pages_localreclaim(gfp, order, zl, flags);
+	else
+		page = __alloc_pages(gfp, order, zl);
 	if (page && page_zone(page) == zl->zones[0]) {
 		zl->zones[0]->pageset[get_cpu()].interleave_hit++;
 		put_cpu();
@@ -769,8 +787,12 @@ alloc_page_vma(unsigned int __nocast gfp
 			/* fall back to process interleaving */
 			nid = interleave_nodes(pol);
 		}
-		return alloc_page_interleave(gfp, 0, nid);
+		return alloc_page_interleave(gfp, 0, nid, pol->flags);
 	}
+
+	if (pol->flags)
+		return __alloc_pages_localreclaim(gfp, 0,
+				zonelist_policy(gfp, pol), pol->flags);
 	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
 }
 
@@ -802,7 +824,11 @@ struct page *alloc_pages_current(unsigne
 	if (!pol || in_interrupt())
 		pol = &default_policy;
 	if (pol->policy == MPOL_INTERLEAVE)
-		return alloc_page_interleave(gfp, order, interleave_nodes(pol));
+		return alloc_page_interleave(gfp, order, interleave_nodes(pol),
+					     pol->flags);
+	if (pol->flags)
+		return __alloc_pages_localreclaim(gfp, order,
+				zonelist_policy(gfp, pol), pol->flags);
 	return __alloc_pages(gfp, order, zonelist_policy(gfp, pol));
 }
 EXPORT_SYMBOL(alloc_pages_current);
@@ -831,23 +857,29 @@ struct mempolicy *__mpol_copy(struct mem
 /* Slow path of a mempolicy comparison */
 int __mpol_equal(struct mempolicy *a, struct mempolicy *b)
 {
+	int flags;
+
 	if (!a || !b)
 		return 0;
 	if (a->policy != b->policy)
 		return 0;
+	flags = a->flags == b->flags;
 	switch (a->policy) {
 	case MPOL_DEFAULT:
 		return 1;
+	case MPOL_LOCALRECLAIM:
+		return a->flags == b->flags;
 	case MPOL_INTERLEAVE:
-		return bitmap_equal(a->v.nodes, b->v.nodes, MAX_NUMNODES);
+		return flags && bitmap_equal(a->v.nodes, b->v.nodes,
+					     MAX_NUMNODES);
 	case MPOL_PREFERRED:
-		return a->v.preferred_node == b->v.preferred_node;
+		return flags && a->v.preferred_node == b->v.preferred_node;
 	case MPOL_BIND: {
 		int i;
 		for (i = 0; a->v.zonelist->zones[i]; i++)
 			if (a->v.zonelist->zones[i] != b->v.zonelist->zones[i])
 				return 0;
-		return b->v.zonelist->zones[i] == NULL;
+		return flags && b->v.zonelist->zones[i] == NULL;
 	}
 	default:
 		BUG();
@@ -878,6 +910,7 @@ int mpol_first_node(struct vm_area_struc
 
 	switch (pol->policy) {
 	case MPOL_DEFAULT:
+	case MPOL_LOCALRECLAIM:
 		return numa_node_id();
 	case MPOL_BIND:
 		return pol->v.zonelist->zones[0]->zone_pgdat->node_id;
@@ -900,6 +933,7 @@ int mpol_node_valid(int nid, struct vm_a
 	case MPOL_PREFERRED:
 	case MPOL_DEFAULT:
 	case MPOL_INTERLEAVE:
+	case MPOL_LOCALRECLAIM:
 		return 1;
 	case MPOL_BIND: {
 		struct zone **z;
@@ -1126,7 +1160,7 @@ void __init numa_policy_init(void)
 	   the data structures allocated at system boot end up in node zero. */
 
 	if (sys_set_mempolicy(MPOL_INTERLEAVE, nodes_addr(node_online_map),
-							MAX_NUMNODES) < 0)
+					MAX_NUMNODES, 0) < 0)
 		printk("numa_policy_init: interleaving failed\n");
 }
 
@@ -1134,5 +1168,5 @@ void __init numa_policy_init(void)
  * Assumes fs == KERNEL_DS */
 void numa_default_policy(void)
 {
-	sys_set_mempolicy(MPOL_DEFAULT, NULL, 0);
+	sys_set_mempolicy(MPOL_DEFAULT, NULL, 0, 0);
 }
Index: linux-2.6.12-rc2.wk/include/linux/gfp.h
===================================================================
--- linux-2.6.12-rc2.wk.orig/include/linux/gfp.h	2005-04-27 06:27:38.000000000 -0700
+++ linux-2.6.12-rc2.wk/include/linux/gfp.h	2005-04-27 07:09:09.000000000 -0700
@@ -81,6 +81,9 @@ static inline void arch_free_page(struct
 
 extern struct page *
 FASTCALL(__alloc_pages(unsigned int, unsigned int, struct zonelist *));
+extern struct page *
+FASTCALL(__alloc_pages_localreclaim(unsigned int, unsigned int,
+				    struct zonelist *, int));
 
 static inline struct page *alloc_pages_node(int nid, unsigned int __nocast gfp_mask,
 						unsigned int order)
Index: linux-2.6.12-rc2.wk/mm/page_alloc.c
===================================================================
--- linux-2.6.12-rc2.wk.orig/mm/page_alloc.c	2005-04-27 06:56:57.000000000 -0700
+++ linux-2.6.12-rc2.wk/mm/page_alloc.c	2005-04-27 07:09:09.000000000 -0700
@@ -958,6 +958,93 @@ got_pg:
 
 EXPORT_SYMBOL(__alloc_pages);
 
+#ifdef CONFIG_NUMA
+
+/*
+ * A function that tries to allocate memory from the local
+ * node by trying really hard, including trying to free up
+ * easily-freed memory from the page cache and (perhaps in the
+ * future) the slab
+ */
+struct page * fastcall
+__alloc_pages_localreclaim(unsigned int gfp_mask, unsigned int order,
+			   struct zonelist *zonelist, int flags)
+{
+	struct zone **zones, *z;
+	struct page *page = NULL;
+	int classzone_idx;
+	int i;
+
+	/*
+	 * Never try local reclaim with GFP_ATOMIC and friends, because
+	 * this path might sleep.
+	 */
+	if (!(gfp_mask & __GFP_WAIT))
+		return __alloc_pages(gfp_mask, order, zonelist);
+
+	zones = zonelist->zones;
+	if (unlikely(zones[0] == NULL))
+		return NULL;
+
+	classzone_idx = zone_idx(zones[0]);
+
+	/*
+	 * Go through the zonelist once, looking for a local zone
+	 * with enough free memory.
+	 */
+	for (i = 0; (z = zones[i]) != NULL; i++) {
+		if (NODE_DATA(numa_node_id()) != z->zone_pgdat)
+			continue;
+		if (!cpuset_zone_allowed(z))
+			continue;
+
+		if (zone_watermark_ok(z, order, z->pages_low,
+				      classzone_idx, 0, 0)) {
+			page = buffered_rmqueue(z, order, gfp_mask);
+			if (page)
+				goto got_pg;
+		}
+	}
+
+	/* Go through again trying to free memory from the zone */
+	for (i = 0; (z = zones[i]) != NULL; i++) {
+		if (NODE_DATA(numa_node_id()) != z->zone_pgdat)
+			continue;
+		if (!cpuset_zone_allowed(z))
+			continue;
+
+		while (reclaim_clean_pages(z, 1<<order, flags)) {
+		       if (zone_watermark_ok(z, order, z->pages_low,
+					     classzone_idx, 0, 0)) {
+			       page = buffered_rmqueue(z, order, gfp_mask);
+			       if (page)
+				       goto got_pg;
+		       }
+		}
+	}
+
+	/* Didn't get a local page - invoke the normal allocator */
+	return __alloc_pages(gfp_mask, order, zonelist);
+ got_pg:
+
+#ifdef CONFIG_PAGE_OWNER /* huga... */
+ 	{
+	unsigned long address, bp;
+#ifdef X86_64
+	asm ("movq %%rbp, %0" : "=r" (bp) : );
+#else
+        asm ("movl %%ebp, %0" : "=r" (bp) : );
+#endif
+        page->order = (int) order;
+        __stack_trace(page, &address, bp);
+	}
+#endif /* CONFIG_PAGE_OWNER */
+	zone_statistics(zonelist, z);
+	return page;
+}
+
+#endif /* CONFIG_NUMA */
+
 /*
  * Common helper functions.
  */
Index: linux-2.6.12-rc2.wk/include/linux/mempolicy.h
===================================================================
--- linux-2.6.12-rc2.wk.orig/include/linux/mempolicy.h	2005-04-27 06:27:38.000000000 -0700
+++ linux-2.6.12-rc2.wk/include/linux/mempolicy.h	2005-04-27 07:09:09.000000000 -0700
@@ -2,6 +2,7 @@
 #define _LINUX_MEMPOLICY_H 1
 
 #include <linux/errno.h>
+#include <linux/swap.h>
 
 /*
  * NUMA memory policies for Linux.
@@ -9,19 +10,38 @@
  */
 
 /* Policies */
-#define MPOL_DEFAULT	0
-#define MPOL_PREFERRED	1
-#define MPOL_BIND	2
-#define MPOL_INTERLEAVE	3
+#define MPOL_DEFAULT		0
+#define MPOL_PREFERRED		1
+#define MPOL_BIND		2
+#define MPOL_INTERLEAVE		3
+#define MPOL_LOCALRECLAIM	4
 
-#define MPOL_MAX MPOL_INTERLEAVE
+#define MPOL_MAX MPOL_LOCALRECLAIM
 
 /* Flags for get_mem_policy */
 #define MPOL_F_NODE	(1<<0)	/* return next IL mode instead of node mask */
 #define MPOL_F_ADDR	(1<<1)	/* look up vma using address */
 
 /* Flags for mbind */
-#define MPOL_MF_STRICT	(1<<0)	/* Verify existing pages in the mapping */
+#define MPOL_MF_STRICT	(1<<2)	/* Verify existing pages in the mapping */
+
+/* Flags for set_mempolicy */
+#define mpol_reclaim_shift(x)	((x)<<3)
+#define MPOL_LR_UNMAPPED	mpol_reclaim_shift(RECLAIM_UNMAPPED)
+#define MPOL_LR_MAPPED		mpol_reclaim_shift(RECLAIM_MAPPED)
+#define MPOL_LR_ACTIVE_UNMAPPED	mpol_reclaim_shift(RECLAIM_ACTIVE_UNMAPPED)
+#define MPOL_LR_ACTIVE_MAPPED	mpol_reclaim_shift(RECLAIM_ACTIVE_MAPPED)
+#define MPOL_LR_SLAB		mpol_reclaim_shift(RECLAIM_SLAB)
+
+#define MPOL_LR_FLAGS	(MPOL_LR_UNMAPPED | MPOL_LR_MAPPED | \
+			 MPOL_LR_ACTIVE_MAPPED | MPOL_LR_ACTIVE_UNMAPPED | \
+			 MPOL_LR_SLAB)
+#define MPOL_LR_MASK	~MPOL_LR_FLAGS
+#define MPOL_FLAGS	(MPOL_F_NODE | MPOL_F_ADDR | MPOL_MF_STRICT | \
+			 MPOL_LR_FLAGS)
+#define MPOL_FLAG_MASK	~MPOL_FLAGS
+#define mpol_to_reclaim_flags(flags)	((flags & MPOL_LR_FLAGS) >> 3)
+
 
 #ifdef __KERNEL__
 
@@ -60,6 +80,7 @@ struct vm_area_struct;
 struct mempolicy {
 	atomic_t refcnt;
 	short policy; 	/* See MPOL_* above */
+	int flags;
 	union {
 		struct zonelist  *zonelist;	/* bind */
 		short 		 preferred_node; /* preferred */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
