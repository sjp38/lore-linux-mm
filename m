Date: Wed, 12 Oct 2005 14:32:10 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Implement sys_* do_* layering in the memory policy layer.
Message-ID: <Pine.LNX.4.62.0510121429240.10617@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

- Do a separation between do_xxx and sys_xxx functions. sys_xxx functions
  take variable sized bitmaps from user space as arguments. do_xxx functions
  take fixed sized nodemask_t as arguments and may be used from inside the
  kernel. Doing so simplifies the initialization code. There is no
  fs = kernel_ds assumption anymore.

- Split up get_nodes into get_nodes (which gets the node list) and
  contextualize_policy which restricts the nodes to those accessible
  to the task and updates cpusets.

- Add comments explaining limitations of bind policy

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
The patch applies on top of Andi's bitmap to nodemask conversion patch.

mempolicy.c |  271 
+++++++++++++++++++++++++++++++++++-------------------------
 1 files changed, 159 insertions(+), 112 deletions(-)

Index: linux-2.6.14-rc4/mm/mempolicy.c
===================================================================
--- linux-2.6.14-rc4.orig/mm/mempolicy.c	2005-10-11 10:24:54.000000000 -0700
+++ linux-2.6.14-rc4/mm/mempolicy.c	2005-10-12 14:21:21.000000000 -0700
@@ -2,6 +2,7 @@
  * Simple NUMA memory policy for the Linux kernel.
  *
  * Copyright 2003,2004 Andi Kleen, SuSE Labs.
+ * (C) Copyright 2005 Christoph Lameter, Silicon Graphics, Inc.
  * Subject to the GNU Public License, version 2.
  *
  * NUMA policy allows the user to give hints in which node(s) memory should
@@ -17,13 +18,19 @@
  *                offset into the backing object or offset into the mapping
  *                for anonymous memory. For process policy an process counter
  *                is used.
+ *
  * bind           Only allocate memory on a specific set of nodes,
  *                no fallback.
+ *                FIXME: memory is allocated starting with the first node
+ *                to the last. It would be better if bind would truly restrict
+ *                the allocation to memory nodes instead
+ *
  * preferred       Try a specific node first before normal fallback.
  *                As a special case node -1 here means do the allocation
  *                on the local CPU. This is normally identical to default,
  *                but useful to set in a VMA when you have a non default
  *                process policy.
+ *
  * default        Allocate on the local node first, or when on a VMA
  *                use the process policy. This is what Linux always did
  *		  in a NUMA aware kernel and still does by, ahem, default.
@@ -113,56 +120,6 @@ static int mpol_check_policy(int mode, n
 	}
 	return nodes_subset(*nodes, node_online_map) ? 0 : -EINVAL;
 }
-
-/* Copy a node mask from user space. */
-static int get_nodes(nodemask_t *nodes, unsigned long __user *nmask,
-		     unsigned long maxnode, int mode)
-{
-	unsigned long k;
-	unsigned long nlongs;
-	unsigned long endmask;
-
-	--maxnode;
-	nodes_clear(*nodes);
-	if (maxnode == 0 || !nmask)
-		return 0;
-
-	nlongs = BITS_TO_LONGS(maxnode);
-	if ((maxnode % BITS_PER_LONG) == 0)
-		endmask = ~0UL;
-	else
-		endmask = (1UL << (maxnode % BITS_PER_LONG)) - 1;
-
-	/* When the user specified more nodes than supported just check
-	   if the non supported part is all zero. */
-	if (nlongs > BITS_TO_LONGS(MAX_NUMNODES)) {
-		if (nlongs > PAGE_SIZE/sizeof(long))
-			return -EINVAL;
-		for (k = BITS_TO_LONGS(MAX_NUMNODES); k < nlongs; k++) {
-			unsigned long t;
-			if (get_user(t, nmask + k))
-				return -EFAULT;
-			if (k == nlongs - 1) {
-				if (t & endmask)
-					return -EINVAL;
-			} else if (t)
-				return -EINVAL;
-		}
-		nlongs = BITS_TO_LONGS(MAX_NUMNODES);
-		endmask = ~0UL;
-	}
-
-	if (copy_from_user(nodes_addr(*nodes), nmask, nlongs*sizeof(unsigned long)))
-		return -EFAULT;
-	nodes_addr(*nodes)[nlongs-1] &= endmask;
-	/* Update current mems_allowed */
-	cpuset_update_current_mems_allowed();
-	/* Ignore nodes not set in current->mems_allowed */
-	/* AK: shouldn't this error out instead? */
-	cpuset_restrict_to_mems_allowed(nodes_addr(*nodes));
-	return mpol_check_policy(mode, nodes);
-}
-
 /* Generate a custom zonelist for the BIND policy. */
 static struct zonelist *bind_zonelist(nodemask_t *nodes)
 {
@@ -379,17 +336,25 @@ static int mbind_range(struct vm_area_st
 	return err;
 }
 
-/* Change policy for a memory range */
-asmlinkage long sys_mbind(unsigned long start, unsigned long len,
-			  unsigned long mode,
-			  unsigned long __user *nmask, unsigned long maxnode,
-			  unsigned flags)
+static int contextualize_policy(int mode, nodemask_t *nodes)
+{
+	if (!nodes)
+		return 0;
+
+	/* Update current mems_allowed */
+	cpuset_update_current_mems_allowed();
+	/* Ignore nodes not set in current->mems_allowed */
+		cpuset_restrict_to_mems_allowed(nodes->bits);
+	return mpol_check_policy(mode, nodes);
+}
+
+long do_mbind(unsigned long start, unsigned long len,
+		unsigned long mode, nodemask_t *nmask, unsigned long flags)
 {
 	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
 	struct mempolicy *new;
 	unsigned long end;
-	nodemask_t nodes;
 	int err;
 
 	if ((flags & ~(unsigned long)(MPOL_MF_STRICT)) || mode > MPOL_MAX)
@@ -404,12 +369,9 @@ asmlinkage long sys_mbind(unsigned long 
 		return -EINVAL;
 	if (end == start)
 		return 0;
-
-	err = get_nodes(&nodes, nmask, maxnode, mode);
-	if (err)
-		return err;
-
-	new = mpol_new(mode, &nodes);
+	if (contextualize_policy(mode, nmask))
+		return -EINVAL;
+	new = mpol_new(mode, nmask);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 
@@ -417,7 +379,7 @@ asmlinkage long sys_mbind(unsigned long 
 			mode,nodes_addr(nodes)[0]);
 
 	down_write(&mm->mmap_sem);
-	vma = check_range(mm, start, end, &nodes, flags);
+	vma = check_range(mm, start, end, nmask, flags);
 	err = PTR_ERR(vma);
 	if (!IS_ERR(vma))
 		err = mbind_range(vma, start, end, new);
@@ -427,19 +389,13 @@ asmlinkage long sys_mbind(unsigned long 
 }
 
 /* Set the process memory policy */
-asmlinkage long sys_set_mempolicy(int mode, unsigned long __user *nmask,
-				   unsigned long maxnode)
+long do_set_mempolicy(int mode, nodemask_t *nodes)
 {
-	int err;
 	struct mempolicy *new;
-	nodemask_t nodes;
 
-	if (mode < 0 || mode > MPOL_MAX)
+	if (contextualize_policy(mode, nodes))
 		return -EINVAL;
-	err = get_nodes(&nodes, nmask, maxnode, mode);
-	if (err)
-		return err;
-	new = mpol_new(mode, &nodes);
+	new = mpol_new(mode, nodes);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 	mpol_free(current->mempolicy);
@@ -490,38 +446,17 @@ static int lookup_node(struct mm_struct 
 	return err;
 }
 
-/* Copy a kernel node mask to user space */
-static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
-			      nodemask_t *nodes)
-{
-	unsigned long copy = ALIGN(maxnode-1, 64) / 8;
-	const int nbytes = BITS_TO_LONGS(MAX_NUMNODES) * sizeof(long);
-
-	if (copy > nbytes) {
-		if (copy > PAGE_SIZE)
-			return -EINVAL;
-		if (clear_user((char __user *)mask + nbytes, copy - nbytes))
-			return -EFAULT;
-		copy = nbytes;
-	}
-	return copy_to_user(mask, nodes_addr(*nodes), copy) ? -EFAULT : 0;
-}
-
 /* Retrieve NUMA policy */
-asmlinkage long sys_get_mempolicy(int __user *policy,
-				  unsigned long __user *nmask,
-				  unsigned long maxnode,
-				  unsigned long addr, unsigned long flags)
+long do_get_mempolicy(int *policy, nodemask_t *nmask,
+			unsigned long addr, unsigned long flags)
 {
-	int err, pval;
+	int err;
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma = NULL;
 	struct mempolicy *pol = current->mempolicy;
 
 	if (flags & ~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR))
 		return -EINVAL;
-	if (nmask != NULL && maxnode < MAX_NUMNODES)
-		return -EINVAL;
 	if (flags & MPOL_F_ADDR) {
 		down_read(&mm->mmap_sem);
 		vma = find_vma_intersection(mm, addr, addr+1);
@@ -544,31 +479,25 @@ asmlinkage long sys_get_mempolicy(int __
 			err = lookup_node(mm, addr);
 			if (err < 0)
 				goto out;
-			pval = err;
+			*policy = err;
 		} else if (pol == current->mempolicy &&
 				pol->policy == MPOL_INTERLEAVE) {
-			pval = current->il_next;
+			*policy = current->il_next;
 		} else {
 			err = -EINVAL;
 			goto out;
 		}
 	} else
-		pval = pol->policy;
+		*policy = pol->policy;
 
 	if (vma) {
 		up_read(&current->mm->mmap_sem);
 		vma = NULL;
 	}
 
-	if (policy && put_user(pval, policy))
-		return -EFAULT;
-
 	err = 0;
-	if (nmask) {
-		nodemask_t nodes;
-		get_zonemask(pol, &nodes);
-		err = copy_nodes_to_user(nmask, maxnode, &nodes);
-	}
+	if (nmask)
+		get_zonemask(pol, nmask);
 
  out:
 	if (vma)
@@ -576,6 +505,126 @@ asmlinkage long sys_get_mempolicy(int __
 	return err;
 }
 
+/*
+ * User space interface with variable sized bitmaps for nodelists.
+ */
+
+/* Copy a node mask from user space. */
+static int get_nodes(nodemask_t *nodes, unsigned long __user *nmask,
+		     unsigned long maxnode)
+{
+	unsigned long k;
+	unsigned long nlongs;
+	unsigned long endmask;
+
+	--maxnode;
+	nodes_clear(*nodes);
+	if (maxnode == 0 || !nmask)
+		return 0;
+
+	nlongs = BITS_TO_LONGS(maxnode);
+	if ((maxnode % BITS_PER_LONG) == 0)
+		endmask = ~0UL;
+	else
+		endmask = (1UL << (maxnode % BITS_PER_LONG)) - 1;
+
+	/* When the user specified more nodes than supported just check
+	   if the non supported part is all zero. */
+	if (nlongs > BITS_TO_LONGS(MAX_NUMNODES)) {
+		if (nlongs > PAGE_SIZE/sizeof(long))
+			return -EINVAL;
+		for (k = BITS_TO_LONGS(MAX_NUMNODES); k < nlongs; k++) {
+			unsigned long t;
+			if (get_user(t, nmask + k))
+				return -EFAULT;
+			if (k == nlongs - 1) {
+				if (t & endmask)
+					return -EINVAL;
+			} else if (t)
+				return -EINVAL;
+		}
+		nlongs = BITS_TO_LONGS(MAX_NUMNODES);
+		endmask = ~0UL;
+	}
+
+	if (copy_from_user(nodes_addr(*nodes), nmask, nlongs*sizeof(unsigned long)))
+		return -EFAULT;
+	nodes_addr(*nodes)[nlongs-1] &= endmask;
+	return 0;
+}
+
+/* Copy a kernel node mask to user space */
+static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
+			      nodemask_t *nodes)
+{
+	unsigned long copy = ALIGN(maxnode-1, 64) / 8;
+	const int nbytes = BITS_TO_LONGS(MAX_NUMNODES) * sizeof(long);
+
+	if (copy > nbytes) {
+		if (copy > PAGE_SIZE)
+			return -EINVAL;
+		if (clear_user((char __user *)mask + nbytes, copy - nbytes))
+			return -EFAULT;
+		copy = nbytes;
+	}
+	return copy_to_user(mask, nodes_addr(*nodes), copy) ? -EFAULT : 0;
+}
+
+asmlinkage long sys_mbind(unsigned long start, unsigned long len,
+			unsigned long mode,
+			unsigned long __user *nmask, unsigned long maxnode,
+			unsigned flags)
+{
+	nodemask_t nodes;
+	int err;
+
+	err = get_nodes(&nodes, nmask, maxnode);
+	if (err)
+		return err;
+	return do_mbind(start, len, mode, &nodes, flags);
+}
+
+/* Set the process memory policy */
+asmlinkage long sys_set_mempolicy(int mode, unsigned long __user *nmask,
+		unsigned long maxnode)
+{
+	int err;
+	nodemask_t nodes;
+
+	if (mode < 0 || mode > MPOL_MAX)
+		return -EINVAL;
+	err = get_nodes(&nodes, nmask, maxnode);
+	if (err)
+		return err;
+	return do_set_mempolicy(mode, &nodes);
+}
+
+/* Retrieve NUMA policy */
+asmlinkage long sys_get_mempolicy(int __user *policy,
+				unsigned long __user *nmask,
+				unsigned long maxnode,
+				unsigned long addr, unsigned long flags)
+{
+	int err, pval;
+	nodemask_t nodes;
+
+	if (nmask != NULL && maxnode < MAX_NUMNODES)
+		return -EINVAL;
+
+	err = do_get_mempolicy(&pval, &nodes, addr, flags);
+
+	if (err)
+		return err;
+
+	if (policy && put_user(pval, policy))
+        	return -EFAULT;
+
+	if (nmask)
+		err = copy_nodes_to_user(nmask, maxnode, &nodes);
+
+	return err;
+}
+
 #ifdef CONFIG_COMPAT
 
 asmlinkage long compat_sys_get_mempolicy(int __user *policy,
@@ -1150,14 +1199,12 @@ void __init numa_policy_init(void)
 	/* Set interleaving policy for system init. This way not all
 	   the data structures allocated at system boot end up in node zero. */
 
-	if (sys_set_mempolicy(MPOL_INTERLEAVE, nodes_addr(node_online_map),
-							MAX_NUMNODES) < 0)
+	if (do_set_mempolicy(MPOL_INTERLEAVE, &node_online_map))
 		printk("numa_policy_init: interleaving failed\n");
 }
 
-/* Reset policy of current process to default.
- * Assumes fs == KERNEL_DS */
+/* Reset policy of current process to default */
 void numa_default_policy(void)
 {
-	sys_set_mempolicy(MPOL_DEFAULT, NULL, 0);
+	do_set_mempolicy(MPOL_DEFAULT, NULL);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
