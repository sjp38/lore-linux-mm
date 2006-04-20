Subject: [PATCH/RFC] Page Cache Policy V0.0 2/5 move shared policy to inode
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Thu, 20 Apr 2006 16:46:17 -0400
Message-Id: <1145565977.10092.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Page Cache Policy V0.0 2/5 move shared policy to inode

This patch starts the process of generalizing the shmem shared
[mem]policy infrastructure for use with generic mmap()ed files.

1) add a struct shared_policy pointer to the generic inode
   structure--actually to the address_space in i_data.
   We'll locate this via vma->vm_file->f_mapping->spolicy.

2) create a shared_policy.h header in anticipation of not
   needing all of mempolicy.h in some places that we'll
   use shared policies. 
TODO:  may not turn out to be the case.  but might be nice
       to have shared policy stuff in a separate header?

3) add [byte] start, end args to set_policy vma operation in
   anticipation of allowing multiple policies per vma for
   file/shmem mappings.  Get file/shmem policies in terms
   of start,end instead of entire vma.

4) modify mbind_range() to allow set_policy() vma ops, if
   any, to handle policies on subranges of vma.  I.e., don't
   split the vma at this level if mapping has set_policy()
   vma op set_policy() op could choose to do that.  But,
   don't need to for generic "shared policies".

   N.B. this breaks any assumptions about one policy per
   vma.

TODO:  fix up display of numamaps for vma with multiple
policy ranges.

5) modify shmem, the only existing user of shared policy
   infrastructure, to work with changes above.  At this
   point, just use the shared_policy embedded in the shmem
   inode info struct.  A later patch will dynamically
   allocate the struct when needed.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.17-rc1-mm2/include/linux/fs.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/fs.h	2006-04-20 12:04:21.000000000 -0400
+++ linux-2.6.17-rc1-mm2/include/linux/fs.h	2006-04-20 12:05:51.000000000 -0400
@@ -391,6 +391,9 @@ struct address_space {
 	struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
 	struct backing_dev_info *backing_dev_info; /* device readahead, etc */
+//TODO:  #ifdef CONFIG_NUMA ???
+	struct shared_policy	*spolicy;
+
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
Index: linux-2.6.17-rc1-mm2/include/linux/mempolicy.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/mempolicy.h	2006-04-20 12:04:21.000000000 -0400
+++ linux-2.6.17-rc1-mm2/include/linux/mempolicy.h	2006-04-20 13:05:27.000000000 -0400
@@ -31,11 +31,11 @@
 #include <linux/config.h>
 #include <linux/mmzone.h>
 #include <linux/slab.h>
-#include <linux/rbtree.h>
 #include <linux/spinlock.h>
 #include <linux/nodemask.h>
 
 struct vm_area_struct;
+#include <linux/shared_policy.h>
 
 #ifdef CONFIG_NUMA
 
@@ -113,34 +113,6 @@ static inline int mpol_equal(struct memp
 
 #define mpol_set_vma_default(vma) ((vma)->vm_policy = NULL)
 
-/*
- * Tree of shared policies for a shared memory region.
- * Maintain the policies in a pseudo mm that contains vmas. The vmas
- * carry the policy. As a special twist the pseudo mm is indexed in pages, not
- * bytes, so that we can work with shared memory segments bigger than
- * unsigned long.
- */
-
-struct sp_node {
-	struct rb_node nd;
-	unsigned long start, end;
-	struct mempolicy *policy;
-};
-
-struct shared_policy {
-	struct rb_root root;
-	spinlock_t lock;
-};
-
-void mpol_shared_policy_init(struct shared_policy *info, int policy,
-				nodemask_t *nodes);
-int mpol_set_shared_policy(struct shared_policy *info,
-				struct vm_area_struct *vma,
-				struct mempolicy *new);
-void mpol_free_shared_policy(struct shared_policy *p);
-struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
-					    unsigned long idx);
-
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
 extern void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *new);
@@ -200,30 +172,6 @@ static inline struct mempolicy *mpol_cop
 	return NULL;
 }
 
-struct shared_policy {};
-
-static inline int mpol_set_shared_policy(struct shared_policy *info,
-					struct vm_area_struct *vma,
-					struct mempolicy *new)
-{
-	return -EINVAL;
-}
-
-static inline void mpol_shared_policy_init(struct shared_policy *info,
-					int policy, nodemask_t *nodes)
-{
-}
-
-static inline void mpol_free_shared_policy(struct shared_policy *p)
-{
-}
-
-static inline struct mempolicy *
-mpol_shared_policy_lookup(struct shared_policy *sp, unsigned long idx)
-{
-	return NULL;
-}
-
 #define vma_policy(vma) NULL
 #define vma_set_policy(vma, pol) do {} while(0)
 
Index: linux-2.6.17-rc1-mm2/include/linux/shared_policy.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17-rc1-mm2/include/linux/shared_policy.h	2006-04-20 14:13:48.000000000 -0400
@@ -0,0 +1,65 @@
+#ifndef _LINUX_SHARED_POLICY_H
+#define _LINUX_SHARED_POLICY_H 1
+
+#include <linux/rbtree.h>
+
+/*
+ * Tree of shared policies for a shared memory regions and memory
+ * mapped files.
+TODO:  wean the low level shared policies from the notion of vmas.
+       just use inode, offset, length
+ * Maintain the policies in a pseudo mm that contains vmas. The vmas
+ * carry the policy. As a special twist the pseudo mm is indexed in pages, not
+ * bytes, so that we can work with shared memory segments bigger than
+ * unsigned long.
+ */
+
+#ifdef CONFIG_NUMA
+
+struct sp_node {
+	struct rb_node nd;
+	unsigned long start, end;
+	struct mempolicy *policy;
+};
+
+struct shared_policy {
+	struct rb_root root;
+	spinlock_t lock;
+};
+
+void mpol_shared_policy_init(struct shared_policy *, int, nodemask_t *);
+int mpol_set_shared_policy(struct shared_policy *,
+				struct vm_area_struct *,
+				unsigned long, unsigned long,
+				struct mempolicy *);
+void mpol_free_shared_policy(struct shared_policy *);
+struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *,
+					    unsigned long);
+
+#else /* !NUMA */
+
+struct shared_policy {};
+
+static inline int mpol_set_shared_policy(struct shared_policy *info,
+					struct vm_area_struct *vma,
+					struct mempolicy *new)
+{
+	return -EINVAL;
+}
+static inline void mpol_shared_policy_init(struct shared_policy *info,
+					int policy, nodemask_t *nodes)
+{
+}
+
+static inline void mpol_free_shared_policy(struct shared_policy *p)
+{
+}
+
+static inline struct mempolicy *
+mpol_shared_policy_lookup(struct shared_policy *sp, unsigned long idx)
+{
+	return NULL;
+}
+#endif
+
+#endif /* _LINUX_SHARED_POLICY_H */
Index: linux-2.6.17-rc1-mm2/include/linux/mm.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/mm.h	2006-04-20 12:04:21.000000000 -0400
+++ linux-2.6.17-rc1-mm2/include/linux/mm.h	2006-04-20 14:18:46.000000000 -0400
@@ -201,9 +201,10 @@ struct vm_operations_struct {
 	struct page * (*nopage)(struct vm_area_struct * area, unsigned long address, int *type);
 	int (*populate)(struct vm_area_struct * area, unsigned long address, unsigned long len, pgprot_t prot, unsigned long pgoff, int nonblock);
 #ifdef CONFIG_NUMA
-	int (*set_policy)(struct vm_area_struct *vma, struct mempolicy *new);
-	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
-					unsigned long addr);
+	int (*set_policy)(struct vm_area_struct *, unsigned long,
+				unsigned long, struct mempolicy *);
+	struct mempolicy *(*get_policy)(struct vm_area_struct *,
+					unsigned long);
 #endif
 };
 
@@ -648,7 +649,8 @@ extern void show_free_areas(void);
 #ifdef CONFIG_SHMEM
 struct page *shmem_nopage(struct vm_area_struct *vma,
 			unsigned long address, int *type);
-int shmem_set_policy(struct vm_area_struct *vma, struct mempolicy *new);
+int shmem_set_policy(struct vm_area_struct *, unsigned long, unsigned long,
+			 struct mempolicy *);
 struct mempolicy *shmem_get_policy(struct vm_area_struct *vma,
 					unsigned long addr);
 int shmem_lock(struct file *file, int lock, struct user_struct *user);
@@ -1051,6 +1053,12 @@ static inline unsigned long vma_pages(st
 	return (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
 }
 
+static inline pgoff_t vma_addr_to_pgoff(struct vm_area_struct *vma,
+		unsigned long addr, int shift)
+{
+	return ((addr - vma->vm_start) >> shift) + vma->vm_pgoff;
+}
+
 struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
 struct page *vmalloc_to_page(void *addr);
 unsigned long vmalloc_to_pfn(void *addr);
Index: linux-2.6.17-rc1-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/mempolicy.c	2006-04-20 12:05:35.000000000 -0400
+++ linux-2.6.17-rc1-mm2/mm/mempolicy.c	2006-04-20 14:13:48.000000000 -0400
@@ -368,20 +368,28 @@ check_range(struct mm_struct *mm, unsign
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
+		 start, end,
+		 vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT),
 		 vma->vm_ops, vma->vm_file,
 		 vma->vm_ops ? vma->vm_ops->set_policy : NULL);
 
+	/*
+	 * set_policy op, if exists, is responsible for policy
+	 * reference counts.
+	 */
 	if (vma->vm_ops && vma->vm_ops->set_policy)
-		err = vma->vm_ops->set_policy(vma, new);
-	if (!err) {
+		err = vma->vm_ops->set_policy(vma, start, end, new);
+	else {
+		struct mempolicy *old = vma->vm_policy;
 		mpol_get(new);
 		vma->vm_policy = new;
 		mpol_free(old);
@@ -398,13 +406,24 @@ static int mbind_range(struct vm_area_st
 
 	err = 0;
 	for (; vma && vma->vm_start < end; vma = next) {
+		unsigned long eend = min(end, vma->vm_end);
 		next = vma->vm_next;
+		if (vma->vm_ops && vma->vm_ops->set_policy) {
+			/*
+			 * set_policy op handles policies on
+			 * sub-range of vma
+			 */
+			err = policy_vma(vma, start, eend, new);
+			if (err)
+				break;
+			continue;
+		}
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
@@ -1410,7 +1429,7 @@ mpol_shared_policy_lookup(struct shared_
 	struct mempolicy *pol = NULL;
 	struct sp_node *sn;
 
-	if (!sp->root.rb_node)
+	if (!sp || !sp->root.rb_node)
 		return NULL;
 	spin_lock(&sp->lock);
 	sn = sp_lookup(sp, idx, idx+1);
@@ -1492,11 +1511,12 @@ restart:
 	return 0;
 }
 
-void mpol_shared_policy_init(struct shared_policy *info, int policy,
+void mpol_shared_policy_init(struct shared_policy *sp, int policy,
 				nodemask_t *policy_nodes)
 {
-	info->root = RB_ROOT;
-	spin_lock_init(&info->lock);
+
+	sp->root = RB_ROOT;
+	spin_lock_init(&sp->lock);
 
 	if (policy != MPOL_DEFAULT) {
 		struct mempolicy *newpol;
@@ -1510,53 +1530,58 @@ void mpol_shared_policy_init(struct shar
 			memset(&pvma, 0, sizeof(struct vm_area_struct));
 			/* Policy covers entire file */
 			pvma.vm_end = TASK_SIZE;
-			mpol_set_shared_policy(info, &pvma, newpol);
+			mpol_set_shared_policy(sp, &pvma, 0UL, pvma.vm_end,
+						newpol);
 			mpol_free(newpol);
 		}
 	}
 }
 
-int mpol_set_shared_policy(struct shared_policy *info,
-			struct vm_area_struct *vma, struct mempolicy *npol)
+int mpol_set_shared_policy(struct shared_policy *sp,
+			struct vm_area_struct *vma,
+			unsigned long start, unsigned long end,
+			struct mempolicy *npol)
 {
 	int err;
 	struct sp_node *new = NULL;
-	unsigned long sz = vma_pages(vma);
+	unsigned long sz = (end - start) >> PAGE_SHIFT;
+	pgoff_t pgoff = vma->vm_pgoff;
+	pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
 
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
-	err = shared_policy_replace(info, vma->vm_pgoff, vma->vm_pgoff+sz, new);
+	err = shared_policy_replace(sp, pgoff, pgoff+sz, new);
 	if (err && new)
 		kmem_cache_free(sn_cache, new);
 	return err;
 }
 
 /* Free a backing policy store on inode delete. */
-void mpol_free_shared_policy(struct shared_policy *p)
+void mpol_free_shared_policy(struct shared_policy *sp)
 {
 	struct sp_node *n;
 	struct rb_node *next;
 
-	if (!p->root.rb_node)
+	if (!sp->root.rb_node)
 		return;
-	spin_lock(&p->lock);
-	next = rb_first(&p->root);
+	spin_lock(&sp->lock);
+	next = rb_first(&sp->root);
 	while (next) {
 		n = rb_entry(next, struct sp_node, nd);
 		next = rb_next(&n->nd);
-		rb_erase(&n->nd, &p->root);
+		rb_erase(&n->nd, &sp->root);
 		mpol_free(n->policy);
 		kmem_cache_free(sn_cache, n);
 	}
-	spin_unlock(&p->lock);
+	spin_unlock(&sp->lock);
 }
 
 /* assumes fs == KERNEL_DS */
Index: linux-2.6.17-rc1-mm2/mm/shmem.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/shmem.c	2006-04-20 12:04:21.000000000 -0400
+++ linux-2.6.17-rc1-mm2/mm/shmem.c	2006-04-20 14:18:12.000000000 -0400
@@ -922,7 +922,7 @@ out:
 	return err;
 }
 
-static struct page *shmem_swapin_async(struct shared_policy *p,
+static struct page *shmem_swapin_async(struct shared_policy *sp,
 				       swp_entry_t entry, unsigned long idx)
 {
 	struct page *page;
@@ -932,41 +932,40 @@ static struct page *shmem_swapin_async(s
 	memset(&pvma, 0, sizeof(struct vm_area_struct));
 	pvma.vm_end = PAGE_SIZE;
 	pvma.vm_pgoff = idx;
-	pvma.vm_policy = mpol_shared_policy_lookup(p, idx);
+	pvma.vm_policy = mpol_shared_policy_lookup(sp, idx);
 	page = read_swap_cache_async(entry, &pvma, 0);
 	mpol_free(pvma.vm_policy);
 	return page;
 }
 
-struct page *shmem_swapin(struct shmem_inode_info *info, swp_entry_t entry,
-			  unsigned long idx)
+struct page *shmem_swapin(struct shared_policy *sp,
+				swp_entry_t entry, unsigned long idx)
 {
-	struct shared_policy *p = &info->policy;
 	int i, num;
 	struct page *page;
 	unsigned long offset;
 
 	num = valid_swaphandles(entry, &offset);
 	for (i = 0; i < num; offset++, i++) {
-		page = shmem_swapin_async(p,
+		page = shmem_swapin_async(sp,
 				swp_entry(swp_type(entry), offset), idx);
 		if (!page)
 			break;
 		page_cache_release(page);
 	}
 	lru_add_drain();	/* Push any new pages onto the LRU now */
-	return shmem_swapin_async(p, entry, idx);
+	return shmem_swapin_async(sp, entry, idx);
 }
 
 static struct page *
-shmem_alloc_page(gfp_t gfp, struct shmem_inode_info *info,
+shmem_alloc_page(gfp_t gfp, struct shared_policy *sp,
 		 unsigned long idx)
 {
 	struct vm_area_struct pvma;
 	struct page *page;
 
 	memset(&pvma, 0, sizeof(struct vm_area_struct));
-	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
+	pvma.vm_policy = mpol_shared_policy_lookup(sp, idx);
 	pvma.vm_pgoff = idx;
 	pvma.vm_end = PAGE_SIZE;
 	page = alloc_page_vma(gfp | __GFP_ZERO, &pvma, 0);
@@ -980,14 +979,14 @@ static inline int shmem_parse_mpol(char 
 }
 
 static inline struct page *
-shmem_swapin(struct shmem_inode_info *info,swp_entry_t entry,unsigned long idx)
+shmem_swapin(void *sp,swp_entry_t entry,unsigned long idx)
 {
 	swapin_readahead(entry, 0, NULL);
 	return read_swap_cache_async(entry, NULL, 0);
 }
 
 static inline struct page *
-shmem_alloc_page(gfp_t gfp,struct shmem_inode_info *info, unsigned long idx)
+shmem_alloc_page(gfp_t gfp,void *sp, unsigned long idx)
 {
 	return alloc_page(gfp | __GFP_ZERO);
 }
@@ -1052,7 +1051,7 @@ repeat:
 				inc_page_state(pgmajfault);
 				*type = VM_FAULT_MAJOR;
 			}
-			swappage = shmem_swapin(info, swap, idx);
+			swappage = shmem_swapin(mapping->spolicy, swap, idx);
 			if (!swappage) {
 				spin_lock(&info->lock);
 				entry = shmem_swp_alloc(info, idx, sgp);
@@ -1173,7 +1172,7 @@ repeat:
 		if (!filepage) {
 			spin_unlock(&info->lock);
 			filepage = shmem_alloc_page(mapping_gfp_mask(mapping),
-						    info,
+						    mapping->spolicy,
 						    idx);
 			if (!filepage) {
 				shmem_unacct_blocks(info->flags, 1);
@@ -1292,20 +1291,18 @@ static int shmem_populate(struct vm_area
 }
 
 #ifdef CONFIG_NUMA
-int shmem_set_policy(struct vm_area_struct *vma, struct mempolicy *new)
+int shmem_set_policy(struct vm_area_struct *vma, unsigned long start,
+			unsigned long end, struct mempolicy *new)
 {
-	struct inode *i = vma->vm_file->f_dentry->d_inode;
-	return mpol_set_shared_policy(&SHMEM_I(i)->policy, vma, new);
+	return mpol_set_shared_policy(vma->vm_file->f_mapping->spolicy,
+					 vma, start, end, new);
 }
 
 struct mempolicy *
 shmem_get_policy(struct vm_area_struct *vma, unsigned long addr)
 {
-	struct inode *i = vma->vm_file->f_dentry->d_inode;
-	unsigned long idx;
-
-	idx = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-	return mpol_shared_policy_lookup(&SHMEM_I(i)->policy, idx);
+	return mpol_shared_policy_lookup(vma->vm_file->f_mapping->spolicy,
+		 vma_addr_to_pgoff(vma, addr, PAGE_SHIFT));
 }
 #endif
 
@@ -1377,8 +1374,9 @@ shmem_get_inode(struct super_block *sb, 
 		case S_IFREG:
 			inode->i_op = &shmem_inode_operations;
 			inode->i_fop = &shmem_file_operations;
-			mpol_shared_policy_init(&info->policy, sbinfo->policy,
-							&sbinfo->policy_nodes);
+			inode->i_mapping->spolicy = &info->policy;
+			mpol_shared_policy_init(inode->i_mapping->spolicy,
+					 sbinfo->policy, &sbinfo->policy_nodes);
 			break;
 		case S_IFDIR:
 			inode->i_nlink++;
@@ -1392,8 +1390,9 @@ shmem_get_inode(struct super_block *sb, 
 			 * Must not load anything in the rbtree,
 			 * mpol_free_shared_policy will not be called.
 			 */
-			mpol_shared_policy_init(&info->policy, MPOL_DEFAULT,
-						NULL);
+			inode->i_mapping->spolicy = &info->policy;
+			mpol_shared_policy_init(inode->i_mapping->spolicy,
+					 MPOL_DEFAULT, NULL);
 			break;
 		}
 	} else if (sbinfo->max_inodes) {
@@ -2136,7 +2135,7 @@ static void shmem_destroy_inode(struct i
 {
 	if ((inode->i_mode & S_IFMT) == S_IFREG) {
 		/* only struct inode is valid if it's an inline symlink */
-		mpol_free_shared_policy(&SHMEM_I(inode)->policy);
+		mpol_free_shared_policy(inode->i_mapping->spolicy);
 	}
 	kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
