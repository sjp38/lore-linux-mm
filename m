From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 25 Jun 2007 15:53:27 -0400
Message-Id: <20070625195327.21210.92146.sendpatchset@localhost>
In-Reply-To: <20070625195224.21210.89898.sendpatchset@localhost>
References: <20070625195224.21210.89898.sendpatchset@localhost>
Subject: [PATCH/RFC 9/11] Shared Policy: mapped file policy persistence model
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Shared Mapped File Policy 9/11 define mapped file policy persistence model

Against 2.6.22-rc4-mm2

Mapped file policy applies to a memory mapped file mmap()ed with the
MAP_SHARED flag.  Therefore, retain the shared policy until the last
shared mapping is removed.

Shmem segments [including SHM_HUGETLB segments] look like shared
mapped files to the shared policy infrastructure.  The policy
persistence model for shmem segments is that once a shared policy
is applied, it remains as long as the segment exists.  To retain this
model, define a shared policy persistence flag--SPOL_F_PERSIST--and
set this flag when allocating a shared policy for a shmem segment.  

Free any shmem persistent shared policy when the segment is deleted
in the common inode cleanup path.  Current behavior.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 fs/hugetlbfs/inode.c          |    1 
 fs/inode.c                    |    9 ++++++
 include/linux/shared_policy.h |   11 +++++--
 mm/mempolicy.c                |   63 ++++++++++++++++++++++++++++++++----------
 mm/mmap.c                     |   13 ++++++++
 mm/shmem.c                    |    5 ---
 6 files changed, 80 insertions(+), 22 deletions(-)

Index: Linux/fs/hugetlbfs/inode.c
===================================================================
--- Linux.orig/fs/hugetlbfs/inode.c	2007-06-25 14:53:17.000000000 -0400
+++ Linux/fs/hugetlbfs/inode.c	2007-06-25 15:03:48.000000000 -0400
@@ -547,7 +547,6 @@ static struct inode *hugetlbfs_alloc_ino
 static void hugetlbfs_destroy_inode(struct inode *inode)
 {
 	hugetlbfs_inc_free_inodes(HUGETLBFS_SB(inode->i_sb));
-	mpol_free_shared_policy(inode->i_mapping);
 	kmem_cache_free(hugetlbfs_inode_cachep, HUGETLBFS_I(inode));
 }
 
Index: Linux/fs/inode.c
===================================================================
--- Linux.orig/fs/inode.c	2007-06-25 14:53:17.000000000 -0400
+++ Linux/fs/inode.c	2007-06-25 15:03:48.000000000 -0400
@@ -22,6 +22,7 @@
 #include <linux/bootmem.h>
 #include <linux/inotify.h>
 #include <linux/mount.h>
+#include <linux/shared_policy.h>
 
 /*
  * This is needed for the following functions:
@@ -173,6 +174,14 @@ void destroy_inode(struct inode *inode) 
 {
 	BUG_ON(inode_has_buffers(inode));
 	security_inode_free(inode);
+
+	/*
+	 * free any shared policy
+	 */
+	if ((inode->i_mode & S_IFMT) == S_IFREG) {
+		mpol_free_shared_policy(inode->i_mapping);
+	}
+
 	if (inode->i_sb->s_op->destroy_inode)
 		inode->i_sb->s_op->destroy_inode(inode);
 	else
Index: Linux/mm/shmem.c
===================================================================
--- Linux.orig/mm/shmem.c	2007-06-25 14:53:17.000000000 -0400
+++ Linux/mm/shmem.c	2007-06-25 15:03:48.000000000 -0400
@@ -1294,6 +1294,7 @@ int shmem_set_policy(struct vm_area_stru
 		sp = mpol_shared_policy_new(mapping, MPOL_DEFAULT, NULL);
 		if (IS_ERR(sp))
 			return PTR_ERR(sp);
+		sp->sp_flags |= SPOL_F_PERSIST;
 	}
 	return mpol_set_shared_policy(sp, pgoff, sz, new);
 }
@@ -2303,10 +2304,6 @@ static struct inode *shmem_alloc_inode(s
 
 static void shmem_destroy_inode(struct inode *inode)
 {
-	if ((inode->i_mode & S_IFMT) == S_IFREG) {
-		/* only struct inode is valid if it's an inline symlink */
-		mpol_free_shared_policy(inode->i_mapping);
-	}
 	shmem_acl_destroy_inode(inode);
 	kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
 }
Index: Linux/mm/mmap.c
===================================================================
--- Linux.orig/mm/mmap.c	2007-06-25 14:53:17.000000000 -0400
+++ Linux/mm/mmap.c	2007-06-25 15:07:07.000000000 -0400
@@ -188,11 +188,24 @@ EXPORT_SYMBOL(__vm_enough_memory);
 static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 		struct file *file, struct address_space *mapping)
 {
+
 	if (vma->vm_flags & VM_DENYWRITE)
 		atomic_inc(&file->f_path.dentry->d_inode->i_writecount);
 	if (vma->vm_flags & VM_SHARED)
 		mapping->i_mmap_writable--;
 
+	if (!mapping->i_mmap_writable) {
+		/*
+		 * shared mmap()ed file policy persistence model:
+		 * remove policy when removing last shared mapping,
+		 * unless marked as persistent--e.g., shmem
+		 */
+		struct shared_policy *sp = mapping_shared_policy(mapping);
+		if (sp && !(sp->sp_flags & SPOL_F_PERSIST)) {
+			mpol_free_shared_policy(mapping);
+		}
+	}
+
 	flush_dcache_mmap_lock(mapping);
 	if (unlikely(vma->vm_flags & VM_NONLINEAR))
 		list_del_init(&vma->shared.vm_set.list);
Index: Linux/include/linux/shared_policy.h
===================================================================
--- Linux.orig/include/linux/shared_policy.h	2007-06-25 14:53:17.000000000 -0400
+++ Linux/include/linux/shared_policy.h	2007-06-25 15:03:48.000000000 -0400
@@ -3,6 +3,7 @@
 
 #include <linux/fs.h>
 #include <linux/rbtree.h>
+#include <linux/rcupdate.h>
 
 /*
  * Tree of shared policies for a shared memory regions and memory
@@ -24,11 +25,15 @@ struct sp_node {
 };
 
 struct shared_policy {
-	struct rb_root root;
-	spinlock_t     lock;		/* protects rb tree */
-	int            nr_sp_nodes;	/* for numa_maps */
+	struct rb_root  root;
+	spinlock_t      lock;		/* protects rb tree, nr_sp_nodes */
+	int             nr_sp_nodes;	/* for numa_maps */
+	int             sp_flags;	/* persistence, ... */
+	struct rcu_head sp_rcu;		/* deferred reclaim */
 };
 
+#define SPOL_F_PERSIST	0x01		/* for shmem use */
+
 extern struct shared_policy *mpol_shared_policy_new(struct address_space *,
 							int, nodemask_t *);
 extern int mpol_set_shared_policy(struct shared_policy *, pgoff_t,
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-06-25 15:03:39.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-06-25 15:03:48.000000000 -0400
@@ -1155,11 +1155,14 @@ static struct mempolicy * get_vma_policy
 struct mempolicy *get_file_policy(struct task_struct *task,
 		struct address_space *x, pgoff_t pgoff)
 {
-	struct shared_policy *sp = x->spolicy;
+	struct shared_policy *sp;
 	struct mempolicy *pol = task->mempolicy;
 
+	rcu_read_lock();
+	sp = rcu_dereference(x->spolicy);
 	if (sp)
 		pol = mpol_shared_policy_lookup(sp, pgoff);
+	rcu_read_unlock();
 	if (!pol)
 		pol = &default_policy;
 	return pol;
@@ -1601,6 +1604,9 @@ restart:
 
 /*
  * allocate and initialize a shared policy struct
+ * Locking:  mapping->spolicy stabilized by current->mm->mmap_sem.
+ * Can't remove last shared mapping while we hold the sem; can't
+ * remove inode/shared policy while inode is mmap()ed shared.
  */
 struct shared_policy *mpol_shared_policy_new(struct address_space *mapping,
 				int policy, nodemask_t *policy_nodes)
@@ -1634,7 +1640,7 @@ struct shared_policy *mpol_shared_policy
 	spin_lock(&mapping->i_mmap_lock);
 	spx = mapping->spolicy;
 	if (!spx)
-		mapping->spolicy = sp;
+		rcu_assign_pointer(mapping->spolicy, sp);
 	else {
 		kmem_cache_free(sp_cache, sp);
 		sp = spx;
@@ -1643,6 +1649,12 @@ struct shared_policy *mpol_shared_policy
 	return sp;
 }
 
+/*
+ * set/replace shared policy on specified address range
+ * Locking:  mapping->spolicy stabilized by current->mm->mmap_sem.
+ * Can't remove last shared mapping while we hold the sem; can't
+ * remove inode/shared policy while inode is mmap()ed shared.
+ */
 int mpol_set_shared_policy(struct shared_policy *sp,
 			pgoff_t pgoff, unsigned long sz,
 			struct mempolicy *npol)
@@ -1668,31 +1680,54 @@ int mpol_set_shared_policy(struct shared
 
 /*
  * Free a backing policy store on inode delete.
+ * Locking:  only free shared policy on inode deletion [shmem] or
+ * removal of last shared mmap()ing.  Can only delete inode when no
+ * more references.  Removal of last shared mmap()ing protected by
+ * mmap_sem [and mapping->i_mmap_lock].  Still a potential race with
+ * shared policy lookups from page cache on behalf of file descriptor
+ * access to pages.  Use deferred RCU to protect readers [in get_file_policy()]
+ * from shared policy free on removal of last shared mmap()ing.
  */
-void mpol_free_shared_policy(struct address_space *mapping)
+static void __mpol_free_shared_policy(struct rcu_head *rhp)
 {
-	struct shared_policy *sp = mapping->spolicy;
-	struct sp_node *n;
+	struct shared_policy *sp =container_of(rhp, struct shared_policy,
+						sp_rcu);
 	struct rb_node *next;
-
-	if (!sp)
-		return;
-
-	mapping->spolicy = NULL;
-
-	spin_lock(&sp->lock);
+	/*
+	 * Now, we can safely tear down the shared policy tree
+	 */
 	next = rb_first(&sp->root);
 	while (next) {
-		n = rb_entry(next, struct sp_node, nd);
+		struct sp_node *n = rb_entry(next, struct sp_node, nd);
 		next = rb_next(&n->nd);
 		rb_erase(&n->nd, &sp->root);
 		mpol_free(n->policy);
 		kmem_cache_free(sn_cache, n);
 	}
-	spin_unlock(&sp->lock);
 	kmem_cache_free(sp_cache, sp);
 }
 
+void mpol_free_shared_policy(struct address_space *mapping)
+{
+	struct shared_policy *sp = mapping->spolicy;
+
+	if (!sp)
+		return;
+
+	rcu_assign_pointer(mapping->spolicy, NULL);
+
+	/*
+	 * Presence of 'PERSIST flag means we're freeing the
+	 * shared policy in the inode destruction path.  No
+	 * need for RCU synchronization.
+	 */
+	if (sp->sp_flags & SPOL_F_PERSIST)
+		__mpol_free_shared_policy(&sp->sp_rcu);
+	else
+		call_rcu(&sp->sp_rcu, __mpol_free_shared_policy);
+
+}
+
 int mpol_parse_options(char *value, int *policy, nodemask_t *policy_nodes)
 {
 	char *nodelist = strchr(value, ':');

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
