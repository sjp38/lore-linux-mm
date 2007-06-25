From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 25 Jun 2007 15:52:45 -0400
Message-Id: <20070625195245.21210.33595.sendpatchset@localhost>
In-Reply-To: <20070625195224.21210.89898.sendpatchset@localhost>
References: <20070625195224.21210.89898.sendpatchset@localhost>
Subject: [PATCH/RFC 3/11] Shared Policy: let vma policy ops handle sub-vma policies
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Shared Policy Infrstructure 3/11 let vma policy ops handle sub-vma policies

Against 2.6.22-rc4-mm2

Shared policies can handle subranges of an object, so no need to
split the vma for these mappings. So, modify mbind_range() and
policy_vma() to call the set_policy vma op, if one exists, for
shared mappings.  Similarly, modify get_vma_policy() to call the
get_policy(), if one exists, only for shared mappings.  This will
simplify the fix to numa_maps to properly handle display of 
shared policies from different tasks.

We don't want private mappings mucking with the shared policy of
the mapped file, if any, so use vma policy for private mappings.
We'll still split vmas for private mappings.  

	Could use rb_tree for vma subrange policies as well, but
	not in this series.

Also, we can't use the same policy ops for nonlinear mappings because
we don't have a 1-to-1 correspondence between pgoff and vma relative
address.  So, continue to split vmas for non-linear mappings.

	At some point, one could provide policy vm_ops support
	for non-linear mappings if one had a use for this.  Might
	get a bit messy...

As a result, this patch enforces a defined semantic for set|get_policy()
ops:  they only get called for linear, shared mappings, and in that
case we don't split the vma.  Only shmem currently has set|get_policy()
ops, and this seems an appropriate semantic for shared objects.

Now, since the vma start and end addresses no longer specify the
range to which a new policy applies, need to add start,end address
args to the vma policy ops.  The set_policy op/handler just calls into
mpol_set_shared_policy() to do the real work, so we could just pass
the start and end address, along with the vma, down to that function.
However, to eliminate the need for the pseudo-vma on the stack when
initializing the shared policy for an inode with non-default "superblock
policy", we change the interface to mpol_set_shared_policy() to take a
page offset and size in pages.  We compute the page offset and size in
the shmem set_policy handler from the vma and the address range. 

Note:  Added helper function "vma_addr_to_pgoff()" for readability.
This is similar to [linear_]page_index() but takes a shift argument
so that it can be used for calculating page indices for interleaving
for both base pages and huge pages.  Perhaps this can be merged with
other similar functions?

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mm.h            |   21 +++++++++--
 include/linux/shared_policy.h |    7 +--
 ipc/shm.c                     |    5 +-
 mm/mempolicy.c                |   74 +++++++++++++++++++++++++++++-------------
 mm/shmem.c                    |    9 +++--
 5 files changed, 81 insertions(+), 35 deletions(-)

Index: Linux/include/linux/mm.h
===================================================================
--- Linux.orig/include/linux/mm.h	2007-06-22 13:07:48.000000000 -0400
+++ Linux/include/linux/mm.h	2007-06-22 13:10:35.000000000 -0400
@@ -234,11 +234,14 @@ struct vm_operations_struct {
 	struct page *(*nopage)(struct vm_area_struct *area,
 			unsigned long address, int *type);
 
-	/* notification that a previously read-only page is about to become
-	 * writable, if an error is returned it will cause a SIGBUS */
+	/*
+	 * notification that a previously read-only page is about to become
+	 * writable, if an error is returned it will cause a SIGBUS
+	 */
 	int (*page_mkwrite)(struct vm_area_struct *vma, struct page *page);
 #ifdef CONFIG_NUMA
-	int (*set_policy)(struct vm_area_struct *vma, struct mempolicy *new);
+	int (*set_policy)(struct vm_area_struct *vma, unsigned long start,
+				unsigned long end, struct mempolicy *new);
 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
 					unsigned long addr);
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
@@ -703,7 +706,8 @@ static inline int page_mapped(struct pag
 extern void show_free_areas(void);
 
 #ifdef CONFIG_SHMEM
-int shmem_set_policy(struct vm_area_struct *vma, struct mempolicy *new);
+int shmem_set_policy(struct vm_area_struct *, unsigned long, unsigned long,
+			 struct mempolicy *);
 struct mempolicy *shmem_get_policy(struct vm_area_struct *vma,
 					unsigned long addr);
 int shmem_lock(struct file *file, int lock, struct user_struct *user);
@@ -1051,6 +1055,15 @@ extern void si_meminfo_node(struct sysin
 
 #ifdef CONFIG_NUMA
 extern void setup_per_cpu_pageset(void);
+
+/*
+ * Address to offset for shared mapping policy lookup.
+ */
+static inline pgoff_t vma_addr_to_pgoff(struct vm_area_struct *vma,
+		unsigned long addr, int shift)
+{
+	return ((addr - vma->vm_start) >> shift) + vma->vm_pgoff;
+}
 #else
 static inline void setup_per_cpu_pageset(void) {}
 #endif
Index: Linux/include/linux/shared_policy.h
===================================================================
--- Linux.orig/include/linux/shared_policy.h	2007-06-22 13:10:34.000000000 -0400
+++ Linux/include/linux/shared_policy.h	2007-06-22 13:10:35.000000000 -0400
@@ -30,9 +30,8 @@ struct shared_policy {
 
 extern struct shared_policy *mpol_shared_policy_new(struct address_space *,
 							int, nodemask_t *);
-extern int mpol_set_shared_policy(struct shared_policy *,
-				struct vm_area_struct *,
-				struct mempolicy *);
+extern int mpol_set_shared_policy(struct shared_policy *, pgoff_t,
+				unsigned long, struct mempolicy *);
 extern void mpol_free_shared_policy(struct address_space *);
 extern struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *,
 					    unsigned long);
@@ -42,7 +41,7 @@ extern struct mempolicy *mpol_shared_pol
 struct shared_policy {};
 
 static inline int mpol_set_shared_policy(struct shared_policy *info,
-					struct vm_area_struct *vma,
+					pgoff_t pgoff, unsigned long sz,
 					struct mempolicy *new)
 {
 	return -EINVAL;
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-06-22 13:10:34.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-06-22 13:10:35.000000000 -0400
@@ -374,20 +374,28 @@ check_range(struct mm_struct *mm, unsign
 	return first;
 }
 
-/* Apply policy to a single VMA */
-static int policy_vma(struct vm_area_struct *vma, struct mempolicy *new)
+/*
+ * Apply policy to a single VMA, or a subrange thereof
+ */
+static int policy_vma(struct vm_area_struct *vma, unsigned long start,
+			unsigned long end, struct mempolicy *new)
 {
 	int err = 0;
-	struct mempolicy *old = vma->vm_policy;
 
 	PDprintk("vma %lx-%lx/%lx vm_ops %p vm_file %p set_policy %p\n",
-		 vma->vm_start, vma->vm_end, vma->vm_pgoff,
+		 start, end, vma_addr_to_pgoff(vma, start, PAGE_SHIFT),
 		 vma->vm_ops, vma->vm_file,
 		 vma->vm_ops ? vma->vm_ops->set_policy : NULL);
 
-	if (vma->vm_ops && vma->vm_ops->set_policy)
-		err = vma->vm_ops->set_policy(vma, new);
-	if (!err) {
+	/*
+	 * set_policy op, if exists, is responsible for policy
+	 * reference counts.
+	 */
+	if ((vma->vm_flags & (VM_SHARED|VM_NONLINEAR)) == VM_SHARED &&
+		vma->vm_ops && vma->vm_ops->set_policy)
+		err = vma->vm_ops->set_policy(vma, start, end, new);
+	else {
+		struct mempolicy *old = vma->vm_policy;
 		mpol_get(new);
 		vma->vm_policy = new;
 		mpol_free(old);
@@ -404,13 +412,30 @@ static int mbind_range(struct vm_area_st
 
 	err = 0;
 	for (; vma && vma->vm_start < end; vma = next) {
+		unsigned long eend = min(end, vma->vm_end);
 		next = vma->vm_next;
+		if ((vma->vm_flags & (VM_SHARED|VM_NONLINEAR)) == VM_SHARED &&
+			vma->vm_ops && vma->vm_ops->set_policy) {
+			/*
+			 * set_policy op handles policies on sub-range
+			 * of vma for linear, shared mappings
+			 */
+			err = policy_vma(vma, start, eend, new);
+			if (err)
+				break;
+			continue;
+		}
+
+		/*
+		 * for private mappings and shared mappings of objects without
+		 * a set_policy vma op, split the vma and use vma policy
+		 */
 		if (vma->vm_start < start)
 			err = split_vma(vma->vm_mm, vma, start, 1);
 		if (!err && vma->vm_end > end)
-			err = split_vma(vma->vm_mm, vma, end, 0);
+			err = split_vma(vma->vm_mm, vma, eend, 0);
 		if (!err)
-			err = policy_vma(vma, new);
+			err = policy_vma(vma, start, eend, new);
 		if (err)
 			break;
 	}
@@ -538,7 +563,11 @@ long do_get_mempolicy(int *policy, nodem
 			up_read(&mm->mmap_sem);
 			return -EFAULT;
 		}
-		if (vma->vm_ops && vma->vm_ops->get_policy)
+		/*
+		 * use get_policy op, if any, for linear, shared mappings
+		 */
+		if ((vma->vm_flags & (VM_SHARED|VM_NONLINEAR)) == VM_SHARED &&
+			vma->vm_ops && vma->vm_ops->get_policy)
 			pol = vma->vm_ops->get_policy(vma, addr);
 		else
 			pol = vma->vm_policy;
@@ -1080,7 +1109,11 @@ static struct mempolicy * get_vma_policy
 	struct mempolicy *pol = task->mempolicy;
 
 	if (vma) {
-		if (vma->vm_ops && vma->vm_ops->get_policy)
+		/*
+		 * use get_policy op, if any, for shared mappings
+		 */
+		if ((vma->vm_flags & (VM_SHARED|VM_NONLINEAR)) == VM_SHARED &&
+			vma->vm_ops && vma->vm_ops->get_policy)
 			pol = vma->vm_ops->get_policy(vma, addr);
 		else if (vma->vm_policy &&
 				vma->vm_policy->policy != MPOL_DEFAULT)
@@ -1549,13 +1582,10 @@ struct shared_policy *mpol_shared_policy
 		/* Falls back to MPOL_DEFAULT on any error */
 		newpol = mpol_new(policy, policy_nodes);
 		if (!IS_ERR(newpol)) {
-			/* Create pseudo-vma that contains just the policy */
-			struct vm_area_struct pvma;
-
-			memset(&pvma, 0, sizeof(struct vm_area_struct));
 			/* Policy covers entire file */
-			pvma.vm_end = TASK_SIZE;
-			mpol_set_shared_policy(sp, &pvma, newpol);
+			mpol_set_shared_policy(sp,
+						0UL, TASK_SIZE >> PAGE_SHIFT,
+						newpol);
 			mpol_free(newpol);
 		}
 	}
@@ -1576,23 +1606,23 @@ struct shared_policy *mpol_shared_policy
 }
 
 int mpol_set_shared_policy(struct shared_policy *sp,
-			struct vm_area_struct *vma, struct mempolicy *npol)
+			pgoff_t pgoff, unsigned long sz,
+			struct mempolicy *npol)
 {
 	int err;
 	struct sp_node *new = NULL;
-	unsigned long sz = vma_pages(vma);
 
 	PDprintk("set_shared_policy %lx sz %lu %d %lx\n",
-		 vma->vm_pgoff,
+		 pgoff,
 		 sz, npol? npol->policy : -1,
 		npol ? nodes_addr(npol->v.nodes)[0] : -1);
 
 	if (npol) {
-		new = sp_alloc(vma->vm_pgoff, vma->vm_pgoff + sz, npol);
+		new = sp_alloc(pgoff, pgoff + sz, npol);
 		if (!new)
 			return -ENOMEM;
 	}
-	err = shared_policy_replace(sp, vma->vm_pgoff, vma->vm_pgoff+sz, new);
+	err = shared_policy_replace(sp, pgoff, pgoff+sz, new);
 	if (err && new)
 		kmem_cache_free(sn_cache, new);
 	return err;
Index: Linux/mm/shmem.c
===================================================================
--- Linux.orig/mm/shmem.c	2007-06-22 13:10:34.000000000 -0400
+++ Linux/mm/shmem.c	2007-06-22 13:10:35.000000000 -0400
@@ -1282,17 +1282,20 @@ static struct page *shmem_fault(struct v
 }
 
 #ifdef CONFIG_NUMA
-int shmem_set_policy(struct vm_area_struct *vma, struct mempolicy *new)
+int shmem_set_policy(struct vm_area_struct *vma, unsigned long start,
+			unsigned long end, struct mempolicy *new)
 {
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	struct shared_policy *sp = mapping_shared_policy(mapping);
+	unsigned long sz = (end - start) >> PAGE_SHIFT;
+	pgoff_t pgoff = vma_addr_to_pgoff(vma, start, PAGE_SHIFT);
 
 	if (!sp) {
 		sp = mpol_shared_policy_new(mapping, MPOL_DEFAULT, NULL);
 		if (IS_ERR(sp))
 			return PTR_ERR(sp);
 	}
-	return mpol_set_shared_policy(sp, vma, new);
+	return mpol_set_shared_policy(sp, pgoff, sz, new);
 }
 
 struct mempolicy *
@@ -1304,7 +1307,7 @@ shmem_get_policy(struct vm_area_struct *
 
 	if (!sp)
 		return NULL;	/* == default policy */
-	idx = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+ 	idx = vma_addr_to_pgoff(vma, addr, PAGE_SHIFT);
 	return mpol_shared_policy_lookup(sp, idx);
 }
 #endif
Index: Linux/ipc/shm.c
===================================================================
--- Linux.orig/ipc/shm.c	2007-06-22 13:07:48.000000000 -0400
+++ Linux/ipc/shm.c	2007-06-22 13:10:35.000000000 -0400
@@ -236,13 +236,14 @@ static struct page *shm_fault(struct vm_
 }
 
 #ifdef CONFIG_NUMA
-int shm_set_policy(struct vm_area_struct *vma, struct mempolicy *new)
+int shm_set_policy(struct vm_area_struct *vma, unsigned long start,
+			unsigned long end, struct mempolicy *new)
 {
 	struct file *file = vma->vm_file;
 	struct shm_file_data *sfd = shm_file_data(file);
 	int err = 0;
 	if (sfd->vm_ops->set_policy)
-		err = sfd->vm_ops->set_policy(vma, new);
+		err = sfd->vm_ops->set_policy(vma, start, end, new);
 	return err;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
