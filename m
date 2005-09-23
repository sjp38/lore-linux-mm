Date: Fri, 23 Sep 2005 11:10:33 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Use node macros for memory policies
Message-ID: <Pine.LNX.4.62.0509231109001.22542@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de, akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Use node macros for memory policies

1. Use node macros throughout instead of bitmaps

3. Blank fixes and clarifying comments.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-rc2/include/linux/mempolicy.h
===================================================================
--- linux-2.6.14-rc2.orig/include/linux/mempolicy.h	2005-09-19 20:00:41.000000000 -0700
+++ linux-2.6.14-rc2/include/linux/mempolicy.h	2005-09-23 11:08:38.000000000 -0700
@@ -27,7 +27,7 @@
 
 #include <linux/config.h>
 #include <linux/mmzone.h>
-#include <linux/bitmap.h>
+#include <linux/nodemask.h>
 #include <linux/slab.h>
 #include <linux/rbtree.h>
 #include <linux/spinlock.h>
@@ -63,7 +63,7 @@ struct mempolicy {
 	union {
 		struct zonelist  *zonelist;	/* bind */
 		short 		 preferred_node; /* preferred */
-		DECLARE_BITMAP(nodes, MAX_NUMNODES); /* interleave */
+		nodemask_t nodes;		 /* interleave */
 		/* undefined for default */
 	} v;
 };
Index: linux-2.6.14-rc2/mm/mempolicy.c
===================================================================
--- linux-2.6.14-rc2.orig/mm/mempolicy.c	2005-09-19 20:00:41.000000000 -0700
+++ linux-2.6.14-rc2/mm/mempolicy.c	2005-09-23 11:08:38.000000000 -0700
@@ -2,6 +2,7 @@
  * Simple NUMA memory policy for the Linux kernel.
  *
  * Copyright 2003,2004 Andi Kleen, SuSE Labs.
+ * (C) Copyright 2005 Christoph Lameter, Silicon Graphics, Inc.
  * Subject to the GNU Public License, version 2.
  *
  * NUMA policy allows the user to give hints in which node(s) memory should
@@ -17,13 +18,18 @@
  *                offset into the backing object or offset into the mapping
  *                for anonymous memory. For process policy an process counter
  *                is used.
+ *
  * bind           Only allocate memory on a specific set of nodes,
  *                no fallback.
- * preferred       Try a specific node first before normal fallback.
+ *	           FIXME: Memory is allocated starting from the lowest node.
+ *			 It would be better to use the nearest node instead.
+ *
+ * preferred      Try a specific node first before normal fallback.
  *                As a special case node -1 here means do the allocation
  *                on the local CPU. This is normally identical to default,
  *                but useful to set in a VMA when you have a non default
  *                process policy.
+ *
  * default        Allocate on the local node first, or when on a VMA
  *                use the process policy. This is what Linux always did
  *		  in a NUMA aware kernel and still does by, ahem, default.
@@ -94,22 +100,22 @@ struct mempolicy default_policy = {
 };
 
 /* Check if all specified nodes are online */
-static int nodes_online(unsigned long *nodes)
+static int nodes_online(nodemask_t *nodes)
 {
-	DECLARE_BITMAP(online2, MAX_NUMNODES);
+	nodemask_t online2;
 
-	bitmap_copy(online2, nodes_addr(node_online_map), MAX_NUMNODES);
-	if (bitmap_empty(online2, MAX_NUMNODES))
-		set_bit(0, online2);
-	if (!bitmap_subset(nodes, online2, MAX_NUMNODES))
+	online2 = node_online_map;
+	if (nodes_empty(online2))
+		node_set(0, online2);
+	if (!nodes_subset(*nodes, online2))
 		return -EINVAL;
 	return 0;
 }
 
 /* Do sanity checking on a policy */
-static int mpol_check_policy(int mode, unsigned long *nodes)
+static int mpol_check_policy(int mode, nodemask_t *nodes)
 {
-	int empty = bitmap_empty(nodes, MAX_NUMNODES);
+	int empty = nodes_empty(*nodes);
 
 	switch (mode) {
 	case MPOL_DEFAULT:
@@ -128,7 +134,7 @@ static int mpol_check_policy(int mode, u
 }
 
 /* Copy a node mask from user space. */
-static int get_nodes(unsigned long *nodes, unsigned long __user *nmask,
+static int get_nodes(nodemask_t *nodes, unsigned long __user *nmask,
 		     unsigned long maxnode, int mode)
 {
 	unsigned long k;
@@ -136,7 +142,7 @@ static int get_nodes(unsigned long *node
 	unsigned long endmask;
 
 	--maxnode;
-	bitmap_zero(nodes, MAX_NUMNODES);
+	nodes_clear(*nodes);
 	if (maxnode == 0 || !nmask)
 		return 0;
 
@@ -167,7 +173,7 @@ static int get_nodes(unsigned long *node
 
 	if (copy_from_user(nodes, nmask, nlongs*sizeof(unsigned long)))
 		return -EFAULT;
-	nodes[nlongs-1] &= endmask;
+	nodes_addr(*nodes)[nlongs - 1] &= endmask;
 	/* Update current mems_allowed */
 	cpuset_update_current_mems_allowed();
 	/* Ignore nodes not set in current->mems_allowed */
@@ -176,21 +182,21 @@ static int get_nodes(unsigned long *node
 }
 
 /* Generate a custom zonelist for the BIND policy. */
-static struct zonelist *bind_zonelist(unsigned long *nodes)
+static struct zonelist *bind_zonelist(nodemask_t *nodes)
 {
 	struct zonelist *zl;
 	int num, max, nd;
 
-	max = 1 + MAX_NR_ZONES * bitmap_weight(nodes, MAX_NUMNODES);
+	max = 1 + MAX_NR_ZONES * nodes_weight(*nodes);
 	zl = kmalloc(sizeof(void *) * max, GFP_KERNEL);
 	if (!zl)
 		return NULL;
 	num = 0;
-	for (nd = find_first_bit(nodes, MAX_NUMNODES);
+	for (nd = first_node(*nodes);
 	     nd < MAX_NUMNODES;
-	     nd = find_next_bit(nodes, MAX_NUMNODES, 1+nd)) {
+	     nd = next_node(1 + nd, *nodes)) {
 		int k;
-		for (k = MAX_NR_ZONES-1; k >= 0; k--) {
+		for (k = MAX_NR_ZONES - 1; k >= 0; k--) {
 			struct zone *z = &NODE_DATA(nd)->node_zones[k];
 			if (!z->present_pages)
 				continue;
@@ -205,11 +211,11 @@ static struct zonelist *bind_zonelist(un
 }
 
 /* Create a new policy */
-static struct mempolicy *mpol_new(int mode, unsigned long *nodes)
+static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
 {
 	struct mempolicy *policy;
 
-	PDprintk("setting mode %d nodes[0] %lx\n", mode, nodes[0]);
+	PDprintk("setting mode %d nodes[0] %lx\n", mode, nodes.bits[0]);
 	if (mode == MPOL_DEFAULT)
 		return NULL;
 	policy = kmem_cache_alloc(policy_cache, GFP_KERNEL);
@@ -218,10 +224,10 @@ static struct mempolicy *mpol_new(int mo
 	atomic_set(&policy->refcnt, 1);
 	switch (mode) {
 	case MPOL_INTERLEAVE:
-		bitmap_copy(policy->v.nodes, nodes, MAX_NUMNODES);
+		policy->v.nodes = *nodes;
 		break;
 	case MPOL_PREFERRED:
-		policy->v.preferred_node = find_first_bit(nodes, MAX_NUMNODES);
+		policy->v.preferred_node = first_node(*nodes);
 		if (policy->v.preferred_node >= MAX_NUMNODES)
 			policy->v.preferred_node = -1;
 		break;
@@ -239,7 +245,7 @@ static struct mempolicy *mpol_new(int mo
 
 /* Ensure all existing pages follow the policy. */
 static int check_pte_range(struct mm_struct *mm, pmd_t *pmd,
-		unsigned long addr, unsigned long end, unsigned long *nodes)
+		unsigned long addr, unsigned long end, nodemask_t *nodes)
 {
 	pte_t *orig_pte;
 	pte_t *pte;
@@ -256,7 +262,7 @@ static int check_pte_range(struct mm_str
 		if (!pfn_valid(pfn))
 			continue;
 		nid = pfn_to_nid(pfn);
-		if (!test_bit(nid, nodes))
+		if (!node_isset(nid, *nodes))
 			break;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	pte_unmap(orig_pte);
@@ -265,7 +271,7 @@ static int check_pte_range(struct mm_str
 }
 
 static inline int check_pmd_range(struct mm_struct *mm, pud_t *pud,
-		unsigned long addr, unsigned long end, unsigned long *nodes)
+		unsigned long addr, unsigned long end, nodemask_t *nodes)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -282,7 +288,7 @@ static inline int check_pmd_range(struct
 }
 
 static inline int check_pud_range(struct mm_struct *mm, pgd_t *pgd,
-		unsigned long addr, unsigned long end, unsigned long *nodes)
+		unsigned long addr, unsigned long end, nodemask_t *nodes)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -299,7 +305,7 @@ static inline int check_pud_range(struct
 }
 
 static inline int check_pgd_range(struct mm_struct *mm,
-		unsigned long addr, unsigned long end, unsigned long *nodes)
+		unsigned long addr, unsigned long end, nodemask_t *nodes)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -318,7 +324,7 @@ static inline int check_pgd_range(struct
 /* Step 1: check the range */
 static struct vm_area_struct *
 check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
-	    unsigned long *nodes, unsigned long flags)
+	    nodemask_t *nodes, unsigned long flags)
 {
 	int err;
 	struct vm_area_struct *first, *vma, *prev;
@@ -403,7 +409,7 @@ asmlinkage long sys_mbind(unsigned long 
 	struct mm_struct *mm = current->mm;
 	struct mempolicy *new;
 	unsigned long end;
-	DECLARE_BITMAP(nodes, MAX_NUMNODES);
+	nodemask_t nodes;
 	int err;
 
 	if ((flags & ~(unsigned long)(MPOL_MF_STRICT)) || mode > MPOL_MAX)
@@ -419,11 +425,11 @@ asmlinkage long sys_mbind(unsigned long 
 	if (end == start)
 		return 0;
 
-	err = get_nodes(nodes, nmask, maxnode, mode);
+	err = get_nodes(&nodes, nmask, maxnode, mode);
 	if (err)
 		return err;
 
-	new = mpol_new(mode, nodes);
+	new = mpol_new(mode, &nodes);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 
@@ -431,7 +437,7 @@ asmlinkage long sys_mbind(unsigned long 
 			mode,nodes[0]);
 
 	down_write(&mm->mmap_sem);
-	vma = check_range(mm, start, end, nodes, flags);
+	vma = check_range(mm, start, end, &nodes, flags);
 	err = PTR_ERR(vma);
 	if (!IS_ERR(vma))
 		err = mbind_range(vma, start, end, new);
@@ -446,45 +452,47 @@ asmlinkage long sys_set_mempolicy(int mo
 {
 	int err;
 	struct mempolicy *new;
-	DECLARE_BITMAP(nodes, MAX_NUMNODES);
+	nodemask_t nodes;
 
 	if (mode < 0 || mode > MPOL_MAX)
 		return -EINVAL;
-	err = get_nodes(nodes, nmask, maxnode, mode);
+	err = get_nodes(&nodes, nmask, maxnode, mode);
 	if (err)
 		return err;
-	new = mpol_new(mode, nodes);
+	new = mpol_new(mode, &nodes);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 	mpol_free(current->mempolicy);
 	current->mempolicy = new;
 	if (new && new->policy == MPOL_INTERLEAVE)
-		current->il_next = find_first_bit(new->v.nodes, MAX_NUMNODES);
+		current->il_next = first_node(new->v.nodes);
 	return 0;
 }
 
 /* Fill a zone bitmap for a policy */
-static void get_zonemask(struct mempolicy *p, unsigned long *nodes)
+static void get_zonemask(struct mempolicy *p, nodemask_t *nodes)
 {
 	int i;
 
-	bitmap_zero(nodes, MAX_NUMNODES);
+	nodes_clear(*nodes);
 	switch (p->policy) {
 	case MPOL_BIND:
 		for (i = 0; p->v.zonelist->zones[i]; i++)
-			__set_bit(p->v.zonelist->zones[i]->zone_pgdat->node_id, nodes);
+			/* No need to have atomic set operations here */
+			__set_bit(p->v.zonelist->zones[i]->zone_pgdat->node_id, nodes->bits);
 		break;
 	case MPOL_DEFAULT:
 		break;
 	case MPOL_INTERLEAVE:
-		bitmap_copy(nodes, p->v.nodes, MAX_NUMNODES);
+		*nodes = p->v.nodes;
 		break;
 	case MPOL_PREFERRED:
 		/* or use current node instead of online map? */
 		if (p->v.preferred_node < 0)
-			bitmap_copy(nodes, nodes_addr(node_online_map), MAX_NUMNODES);
+			*nodes = node_online_map;
 		else
-			__set_bit(p->v.preferred_node, nodes);
+			/* No need for an atomic set operation here */
+			__set_bit(p->v.preferred_node, nodes->bits);
 		break;
 	default:
 		BUG();
@@ -506,9 +514,9 @@ static int lookup_node(struct mm_struct 
 
 /* Copy a kernel node mask to user space */
 static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
-			      void *nodes, unsigned nbytes)
+			      nodemask_t *nodes, unsigned nbytes)
 {
-	unsigned long copy = ALIGN(maxnode-1, 64) / 8;
+	unsigned long copy = ALIGN(maxnode - 1, 64) / 8;
 
 	if (copy > nbytes) {
 		if (copy > PAGE_SIZE)
@@ -537,7 +545,7 @@ asmlinkage long sys_get_mempolicy(int __
 		return -EINVAL;
 	if (flags & MPOL_F_ADDR) {
 		down_read(&mm->mmap_sem);
-		vma = find_vma_intersection(mm, addr, addr+1);
+		vma = find_vma_intersection(mm, addr, addr + 1);
 		if (!vma) {
 			up_read(&mm->mmap_sem);
 			return -EFAULT;
@@ -578,9 +586,9 @@ asmlinkage long sys_get_mempolicy(int __
 
 	err = 0;
 	if (nmask) {
-		DECLARE_BITMAP(nodes, MAX_NUMNODES);
-		get_zonemask(pol, nodes);
-		err = copy_nodes_to_user(nmask, maxnode, nodes, sizeof(nodes));
+		nodemask_t nodes;
+		get_zonemask(pol, &nodes);
+		err = copy_nodes_to_user(nmask, maxnode, &nodes, sizeof(nodes));
 	}
 
  out:
@@ -590,7 +598,10 @@ asmlinkage long sys_get_mempolicy(int __
 }
 
 #ifdef CONFIG_COMPAT
-
+/*
+ * We need to fall back here on bitmap functions since there is no
+ * support for compat nodemaps in the kernel.
+ */
 asmlinkage long compat_sys_get_mempolicy(int __user *policy,
 				     compat_ulong_t __user *nmask,
 				     compat_ulong_t maxnode,
@@ -599,21 +610,21 @@ asmlinkage long compat_sys_get_mempolicy
 	long err;
 	unsigned long __user *nm = NULL;
 	unsigned long nr_bits, alloc_size;
-	DECLARE_BITMAP(bm, MAX_NUMNODES);
+	nodemask_t bm;
 
-	nr_bits = min_t(unsigned long, maxnode-1, MAX_NUMNODES);
+	nr_bits = min_t(unsigned long, maxnode - 1, MAX_NUMNODES);
 	alloc_size = ALIGN(nr_bits, BITS_PER_LONG) / 8;
 
 	if (nmask)
 		nm = compat_alloc_user_space(alloc_size);
 
-	err = sys_get_mempolicy(policy, nm, nr_bits+1, addr, flags);
+	err = sys_get_mempolicy(policy, nm, nr_bits + 1, addr, flags);
 
 	if (!err && nmask) {
-		err = copy_from_user(bm, nm, alloc_size);
+		err = copy_from_user(&bm, nm, alloc_size);
 		/* ensure entire bitmap is zeroed */
-		err |= clear_user(nmask, ALIGN(maxnode-1, 8) / 8);
-		err |= compat_put_bitmap(nmask, bm, nr_bits);
+		err |= clear_user(nmask, ALIGN(maxnode - 1, 8) / 8);
+		err |= compat_put_bitmap(nmask, nodes_addr(bm), nr_bits);
 	}
 
 	return err;
@@ -625,21 +636,21 @@ asmlinkage long compat_sys_set_mempolicy
 	long err = 0;
 	unsigned long __user *nm = NULL;
 	unsigned long nr_bits, alloc_size;
-	DECLARE_BITMAP(bm, MAX_NUMNODES);
+	nodemask_t bm;
 
-	nr_bits = min_t(unsigned long, maxnode-1, MAX_NUMNODES);
+	nr_bits = min_t(unsigned long, maxnode - 1, MAX_NUMNODES);
 	alloc_size = ALIGN(nr_bits, BITS_PER_LONG) / 8;
 
 	if (nmask) {
-		err = compat_get_bitmap(bm, nmask, nr_bits);
+		err = compat_get_bitmap(nodes_addr(bm), nmask, nr_bits);
 		nm = compat_alloc_user_space(alloc_size);
-		err |= copy_to_user(nm, bm, alloc_size);
+		err |= copy_to_user(nm, &bm, alloc_size);
 	}
 
 	if (err)
 		return -EFAULT;
 
-	return sys_set_mempolicy(mode, nm, nr_bits+1);
+	return sys_set_mempolicy(mode, nm, nr_bits + 1);
 }
 
 asmlinkage long compat_sys_mbind(compat_ulong_t start, compat_ulong_t len,
@@ -649,26 +660,29 @@ asmlinkage long compat_sys_mbind(compat_
 	long err = 0;
 	unsigned long __user *nm = NULL;
 	unsigned long nr_bits, alloc_size;
-	DECLARE_BITMAP(bm, MAX_NUMNODES);
+	nodemask_t bm;
 
-	nr_bits = min_t(unsigned long, maxnode-1, MAX_NUMNODES);
+	nr_bits = min_t(unsigned long, maxnode - 1, MAX_NUMNODES);
 	alloc_size = ALIGN(nr_bits, BITS_PER_LONG) / 8;
 
 	if (nmask) {
-		err = compat_get_bitmap(bm, nmask, nr_bits);
+		err = compat_get_bitmap(nodes_addr(bm), nmask, nr_bits);
 		nm = compat_alloc_user_space(alloc_size);
-		err |= copy_to_user(nm, bm, alloc_size);
+		err |= copy_to_user(nm, &bm, alloc_size);
 	}
 
 	if (err)
 		return -EFAULT;
 
-	return sys_mbind(start, len, mode, nm, nr_bits+1, flags);
+	return sys_mbind(start, len, mode, nm, nr_bits + 1, flags);
 }
 
 #endif
 
-/* Return effective policy for a VMA */
+/*
+ * Return effective policy for a VMA
+ * Need to have mmap_sem held in order to access vma->policy
+ */
 struct mempolicy *
 get_vma_policy(struct task_struct *task, struct vm_area_struct *vma, unsigned long addr)
 {
@@ -723,9 +737,9 @@ static unsigned interleave_nodes(struct 
 
 	nid = me->il_next;
 	BUG_ON(nid >= MAX_NUMNODES);
-	next = find_next_bit(policy->v.nodes, MAX_NUMNODES, 1+nid);
+	next = next_node(1 + nid, policy->v.nodes);
 	if (next >= MAX_NUMNODES)
-		next = find_first_bit(policy->v.nodes, MAX_NUMNODES);
+		next = first_node(policy->v.nodes);
 	me->il_next = next;
 	return nid;
 }
@@ -734,18 +748,18 @@ static unsigned interleave_nodes(struct 
 static unsigned offset_il_node(struct mempolicy *pol,
 		struct vm_area_struct *vma, unsigned long off)
 {
-	unsigned nnodes = bitmap_weight(pol->v.nodes, MAX_NUMNODES);
+	unsigned nnodes = nodes_weight(pol->v.nodes);
 	unsigned target = (unsigned)off % nnodes;
 	int c;
 	int nid = -1;
 
 	c = 0;
 	do {
-		nid = find_next_bit(pol->v.nodes, MAX_NUMNODES, nid+1);
+		nid = next_node(nid + 1, pol->v.nodes);
 		c++;
 	} while (c <= target);
 	BUG_ON(nid >= MAX_NUMNODES);
-	BUG_ON(!test_bit(nid, pol->v.nodes));
+	BUG_ON(!node_isset(nid, pol->v.nodes));
 	return nid;
 }
 
@@ -878,7 +892,7 @@ int __mpol_equal(struct mempolicy *a, st
 	case MPOL_DEFAULT:
 		return 1;
 	case MPOL_INTERLEAVE:
-		return bitmap_equal(a->v.nodes, b->v.nodes, MAX_NUMNODES);
+		return nodes_equal(a->v.nodes, b->v.nodes);
 	case MPOL_PREFERRED:
 		return a->v.preferred_node == b->v.preferred_node;
 	case MPOL_BIND: {
@@ -1028,7 +1042,7 @@ mpol_shared_policy_lookup(struct shared_
 	if (!sp->root.rb_node)
 		return NULL;
 	spin_lock(&sp->lock);
-	sn = sp_lookup(sp, idx, idx+1);
+	sn = sp_lookup(sp, idx, idx + 1);
 	if (sn) {
 		mpol_get(sn->policy);
 		pol = sn->policy;
Index: linux-2.6.14-rc2/kernel/cpuset.c
===================================================================
--- linux-2.6.14-rc2.orig/kernel/cpuset.c	2005-09-19 20:00:41.000000000 -0700
+++ linux-2.6.14-rc2/kernel/cpuset.c	2005-09-23 11:08:38.000000000 -0700
@@ -1603,10 +1603,9 @@ void cpuset_update_current_mems_allowed(
  * cpuset_restrict_to_mems_allowed - limit nodes to current mems_allowed
  * @nodes: pointer to a node bitmap that is and-ed with mems_allowed
  */
-void cpuset_restrict_to_mems_allowed(unsigned long *nodes)
+void cpuset_restrict_to_mems_allowed(nodemask_t *nodes)
 {
-	bitmap_and(nodes, nodes, nodes_addr(current->mems_allowed),
-							MAX_NUMNODES);
+	nodes_and(*nodes, *nodes, current->mems_allowed);
 }
 
 /**
Index: linux-2.6.14-rc2/include/linux/cpuset.h
===================================================================
--- linux-2.6.14-rc2.orig/include/linux/cpuset.h	2005-09-19 20:00:41.000000000 -0700
+++ linux-2.6.14-rc2/include/linux/cpuset.h	2005-09-23 11:08:38.000000000 -0700
@@ -21,7 +21,7 @@ extern void cpuset_exit(struct task_stru
 extern cpumask_t cpuset_cpus_allowed(const struct task_struct *p);
 void cpuset_init_current_mems_allowed(void);
 void cpuset_update_current_mems_allowed(void);
-void cpuset_restrict_to_mems_allowed(unsigned long *nodes);
+void cpuset_restrict_to_mems_allowed(nodemask_t *nodes);
 int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl);
 extern int cpuset_zone_allowed(struct zone *z, unsigned int __nocast gfp_mask);
 extern int cpuset_excl_nodes_overlap(const struct task_struct *p);
@@ -42,7 +42,7 @@ static inline cpumask_t cpuset_cpus_allo
 
 static inline void cpuset_init_current_mems_allowed(void) {}
 static inline void cpuset_update_current_mems_allowed(void) {}
-static inline void cpuset_restrict_to_mems_allowed(unsigned long *nodes) {}
+static inline void cpuset_restrict_to_mems_allowed(nodemask_t *nodes) {}
 
 static inline int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
