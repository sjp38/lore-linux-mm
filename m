Date: Thu, 10 Nov 2005 14:04:46 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [RFC] Make the slab allocator observe NUMA policies
Message-ID: <Pine.LNX.4.62.0511101401390.16481@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de, steiner@sgi.com, linux-mm@kvack.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

Currently the slab allocator simply allocates slabs from the current node
or from the node indicated in kmalloc_node().

This change came about with the NUMA slab allocator changes in 2.6.14.
Before 2.6.14 the slab allocator was obeying memory policies in the sense
that the pages were allocated in the policy context of the currently executing
process (which could allocate a page according to MPOL_INTERLEAVE for one
process and then use the free entries in that page for another process
that did not have this policy set).

The following patch adds NUMA memory policy support. This means that the
slab entries (and therefore also the pages containing them) will be allocated
according to memory policy.

This is in particular of importance during bootup when the default 
memory policy is set to MPOL_INTERLEAVE. For 2.6.13 and earlier this meant 
that the slab allocator got its pages from all nodes. 2.6.14 will 
allocate only from the boot node causing an unbalanced memory setup when 
bootup is complete.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-mm1/mm/slab.c
===================================================================
--- linux-2.6.14-mm1.orig/mm/slab.c	2005-11-10 13:00:11.000000000 -0800
+++ linux-2.6.14-mm1/mm/slab.c	2005-11-10 13:01:55.000000000 -0800
@@ -103,6 +103,7 @@
 #include	<linux/rcupdate.h>
 #include	<linux/string.h>
 #include	<linux/nodemask.h>
+#include	<linux/mempolicy.h>
 
 #include	<asm/uaccess.h>
 #include	<asm/cacheflush.h>
@@ -2526,11 +2527,22 @@ cache_alloc_debugcheck_after(kmem_cache_
 #define cache_alloc_debugcheck_after(a,b,objp,d) (objp)
 #endif
 
+static void *__cache_alloc_node(kmem_cache_t *, gfp_t, int);
+
 static inline void *____cache_alloc(kmem_cache_t *cachep, gfp_t flags)
 {
 	void* objp;
 	struct array_cache *ac;
 
+#ifdef CONFIG_NUMA
+	if (current->mempolicy) {
+		int nid = next_slab_node(current->mempolicy);
+
+		if (nid != numa_node_id())
+			return __cache_alloc_node(cachep, flags, nid);
+	}
+#endif
+
 	check_irq_off();
 	ac = ac_data(cachep);
 	if (likely(ac->avail)) {
Index: linux-2.6.14-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.14-mm1.orig/mm/mempolicy.c	2005-11-09 10:47:15.000000000 -0800
+++ linux-2.6.14-mm1/mm/mempolicy.c	2005-11-10 13:01:55.000000000 -0800
@@ -988,6 +988,31 @@ static unsigned interleave_nodes(struct 
 	return nid;
 }
 
+/*
+ * Depending on the memory policy provide a node from which to allocate the
+ * next slab entry.
+ */
+unsigned next_slab_node(struct mempolicy *policy)
+{
+	switch (policy->policy) {
+	case MPOL_INTERLEAVE:
+		return interleave_nodes(policy);
+
+	case MPOL_BIND:
+		/*
+		 * Follow bind policy behavior and start allocation at the
+		 * first node.
+		 */
+		return policy->v.zonelist->zones[0]->zone_pgdat->node_id;
+
+	case MPOL_PREFERRED:
+		return policy->v.preferred_node;
+
+	default:
+		return numa_node_id();
+	}
+}
+
 /* Do static interleaving for a VMA with known offset. */
 static unsigned offset_il_node(struct mempolicy *pol,
 		struct vm_area_struct *vma, unsigned long off)
Index: linux-2.6.14-mm1/include/linux/mempolicy.h
===================================================================
--- linux-2.6.14-mm1.orig/include/linux/mempolicy.h	2005-11-09 10:47:09.000000000 -0800
+++ linux-2.6.14-mm1/include/linux/mempolicy.h	2005-11-10 13:01:55.000000000 -0800
@@ -158,6 +158,7 @@ extern void numa_default_policy(void);
 extern void numa_policy_init(void);
 extern void numa_policy_rebind(const nodemask_t *old, const nodemask_t *new);
 extern struct mempolicy default_policy;
+extern unsigned next_slab_node(struct mempolicy *policy);
 
 int do_migrate_pages(struct mm_struct *mm,
 	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
