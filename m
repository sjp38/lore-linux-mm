Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9MAjVJc032321
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:45:31 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MAhxHW761898
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:59 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MAhgAp003080
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:43 +1000
Message-Id: <20071022104530.754766340@linux.vnet.ibm.com>>
References: <20071022104518.985992030@linux.vnet.ibm.com>>
Date: Mon, 22 Oct 2007 16:15:22 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: [PATCH/RFC 3/9] mm: use the B+tree for vma lookups
Content-Disposition: inline; filename=3_mm-btree.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Alexis Bruemmer <alexisb@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

---
 include/linux/init_task.h |    2 
 include/linux/mm.h        |    5 -
 include/linux/sched.h     |    4 
 kernel/fork.c             |   17 +--
 mm/mmap.c                 |  230 +++++++++++++++-------------------------------
 5 files changed, 92 insertions(+), 166 deletions(-)

--- linux-2.6.23-rc6.orig/include/linux/init_task.h
+++ linux-2.6.23-rc6/include/linux/init_task.h
@@ -48,7 +48,7 @@
 #define INIT_MM(name) \
 {			 					\
 	.mm_vmas	= LIST_HEAD_INIT(name.mm_vmas),		\
-	.mm_rb		= RB_ROOT,				\
+	.mm_btree	= BTREE_INIT(GFP_ATOMIC),		\
 	.pgd		= swapper_pg_dir, 			\
 	.mm_users	= ATOMIC_INIT(2), 			\
 	.mm_count	= ATOMIC_INIT(1), 			\
--- linux-2.6.23-rc6.orig/include/linux/mm.h
+++ linux-2.6.23-rc6/include/linux/mm.h
@@ -69,8 +69,6 @@ struct vm_area_struct {
 	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
 	unsigned long vm_flags;		/* Flags, listed below. */
 
-	struct rb_node vm_rb;
-
 	/*
 	 * For areas with an address space and backing store,
 	 * linkage into the address_space->i_mmap prio tree, or
@@ -1091,8 +1089,7 @@ extern struct anon_vma *find_mergeable_a
 extern int split_vma(struct mm_struct *,
 	struct vm_area_struct *, unsigned long addr, int new_below);
 extern int insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
-extern void __vma_link_rb(struct mm_struct *, struct vm_area_struct *,
-	struct rb_node **, struct rb_node *);
+extern void __vma_link_btree(struct mm_struct *, struct vm_area_struct *);
 extern void unlink_file_vma(struct vm_area_struct *);
 extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
 	unsigned long addr, unsigned long len, pgoff_t pgoff);
--- linux-2.6.23-rc6.orig/include/linux/sched.h
+++ linux-2.6.23-rc6/include/linux/sched.h
@@ -52,7 +52,7 @@ struct sched_param {
 #include <linux/types.h>
 #include <linux/timex.h>
 #include <linux/jiffies.h>
-#include <linux/rbtree.h>
+#include <linux/btree.h>
 #include <linux/thread_info.h>
 #include <linux/cpumask.h>
 #include <linux/errno.h>
@@ -368,7 +368,7 @@ extern int get_dumpable(struct mm_struct
 
 struct mm_struct {
 	struct list_head mm_vmas;
-	struct rb_root mm_rb;
+	struct btree_root mm_btree;
 	struct vm_area_struct * mmap_cache;	/* last find_vma result */
 	unsigned long (*get_unmapped_area) (struct file *filp,
 				unsigned long addr, unsigned long len,
--- linux-2.6.23-rc6.orig/kernel/fork.c
+++ linux-2.6.23-rc6/kernel/fork.c
@@ -198,7 +198,6 @@ static struct task_struct *dup_task_stru
 static inline int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 {
 	struct vm_area_struct *mpnt, *tmp;
-	struct rb_node **rb_link, *rb_parent;
 	int retval;
 	unsigned long charge;
 	struct mempolicy *pol;
@@ -216,9 +215,6 @@ static inline int dup_mmap(struct mm_str
 	mm->cached_hole_size = ~0UL;
 	mm->map_count = 0;
 	cpus_clear(mm->cpu_vm_mask);
-	mm->mm_rb = RB_ROOT;
-	rb_link = &mm->mm_rb.rb_node;
-	rb_parent = NULL;
 
 	list_for_each_entry(mpnt, &oldmm->mm_vmas, vm_list) {
 		struct file *file;
@@ -270,9 +266,8 @@ static inline int dup_mmap(struct mm_str
 		 */
 
 		list_add_tail(&tmp->vm_list, &mm->mm_vmas);
-		__vma_link_rb(mm, tmp, rb_link, rb_parent);
-		rb_link = &tmp->vm_rb.rb_right;
-		rb_parent = &tmp->vm_rb;
+		btree_preload(&mm->mm_btree, GFP_KERNEL|__GFP_NOFAIL); // XXX create error path
+		__vma_link_btree(mm, tmp);
 
 		mm->map_count++;
 		retval = copy_page_range(mm, oldmm, mpnt);
@@ -320,13 +315,19 @@ static inline void mm_free_pgd(struct mm
  __cacheline_aligned_in_smp DEFINE_SPINLOCK(mmlist_lock);
 
 #define allocate_mm()	(kmem_cache_alloc(mm_cachep, GFP_KERNEL))
-#define free_mm(mm)	(kmem_cache_free(mm_cachep, (mm)))
+
+static void free_mm(struct mm_struct *mm)
+{
+	btree_root_destroy(&mm->mm_btree);
+	kmem_cache_free(mm_cachep, mm);
+}
 
 #include <linux/init_task.h>
 
 static struct mm_struct * mm_init(struct mm_struct * mm)
 {
 	INIT_LIST_HEAD(&mm->mm_vmas);
+	mm->mm_btree = BTREE_INIT(GFP_ATOMIC);
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
--- linux-2.6.23-rc6.orig/mm/mmap.c
+++ linux-2.6.23-rc6/mm/mmap.c
@@ -4,6 +4,7 @@
  * Written by obz.
  *
  * Address space accounting code	<alan@redhat.com>
+ * Btree adaption			<pzijlstr@redhat.com>
  */
 
 #include <linux/slab.h>
@@ -283,35 +284,6 @@ out:
 }
 
 #ifdef DEBUG_MM_RB
-static int browse_rb(struct rb_root *root)
-{
-	int i = 0, j;
-	struct rb_node *nd, *pn = NULL;
-	unsigned long prev = 0, pend = 0;
-
-	for (nd = rb_first(root); nd; nd = rb_next(nd)) {
-		struct vm_area_struct *vma;
-		vma = rb_entry(nd, struct vm_area_struct, vm_rb);
-		if (vma->vm_start < prev)
-			printk("vm_start %lx prev %lx\n", vma->vm_start, prev), i = -1;
-		if (vma->vm_start < pend)
-			printk("vm_start %lx pend %lx\n", vma->vm_start, pend);
-		if (vma->vm_start > vma->vm_end)
-			printk("vm_end %lx < vm_start %lx\n", vma->vm_end, vma->vm_start);
-		i++;
-		pn = nd;
-		prev = vma->vm_start;
-		pend = vma->vm_end;
-	}
-	j = 0;
-	for (nd = pn; nd; nd = rb_prev(nd)) {
-		j++;
-	}
-	if (i != j)
-		printk("backwards %d, forwards %d\n", j, i), i = 0;
-	return i;
-}
-
 void validate_mm(struct mm_struct *mm)
 {
 	int bug = 0;
@@ -321,9 +293,6 @@ void validate_mm(struct mm_struct *mm)
 		i++;
 	if (i != mm->map_count)
 		printk("map_count %d vm_next %d\n", mm->map_count, i), bug = 1;
-	i = browse_rb(&mm->mm_rb);
-	if (i != mm->map_count)
-		printk("map_count %d rb %d\n", mm->map_count, i), bug = 1;
 	BUG_ON(bug);
 }
 #else
@@ -332,62 +301,36 @@ void validate_mm(struct mm_struct *mm)
 
 static struct vm_area_struct *
 find_vma_prepare(struct mm_struct *mm, unsigned long addr,
-		struct vm_area_struct **pprev, struct rb_node ***rb_link,
-		struct rb_node ** rb_parent)
+ 		struct vm_area_struct **pprev)
 {
-	struct vm_area_struct * vma;
-	struct rb_node ** __rb_link, * __rb_parent, * rb_prev;
-
-	__rb_link = &mm->mm_rb.rb_node;
-	rb_prev = __rb_parent = NULL;
-	vma = NULL;
-
-	while (*__rb_link) {
-		struct vm_area_struct *vma_tmp;
-
-		__rb_parent = *__rb_link;
-		vma_tmp = rb_entry(__rb_parent, struct vm_area_struct, vm_rb);
-
-		if (vma_tmp->vm_end > addr) {
-			vma = vma_tmp;
-			if (vma_tmp->vm_start <= addr)
-				return vma;
-			__rb_link = &__rb_parent->rb_left;
-		} else {
-			rb_prev = __rb_parent;
-			__rb_link = &__rb_parent->rb_right;
-		}
-	}
-
-	*pprev = NULL;
-	if (rb_prev)
-		*pprev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
-	*rb_link = __rb_link;
-	*rb_parent = __rb_parent;
+ 	struct vm_area_struct *vma, *prev = NULL;
+ 	vma = btree_stab(&mm->mm_btree, addr);
+ 	if (!vma || addr >= vma->vm_end)
+ 		vma = __vma_next(&mm->mm_vmas, vma);
+ 	if (!(vma && addr < vma->vm_end))
+ 		prev = __vma_prev(&mm->mm_vmas, vma);
+ 	*pprev = prev;
 	return vma;
 }
 
 static inline void
 __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
-		struct vm_area_struct *prev, struct rb_node *rb_parent)
+ 		struct vm_area_struct *prev)
 {
-	if (prev) {
+ 	if (!prev)
+ 		prev = btree_stab(&mm->mm_btree, vma->vm_start);
+
+ 	if (prev)
 		list_add(&vma->vm_list, &prev->vm_list);
-	} else {
-		if (rb_parent) {
-			struct vm_area_struct *next = rb_entry(rb_parent,
-					struct vm_area_struct, vm_rb);
-			list_add_tail(&vma->vm_list, &next->vm_list);
-		} else
-			list_add(&vma->vm_list, &mm->mm_vmas);
-	}
+ 	else
+ 		list_add(&vma->vm_list, &mm->mm_vmas);
 }
 
-void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
-		struct rb_node **rb_link, struct rb_node *rb_parent)
+void __vma_link_btree(struct mm_struct *mm, struct vm_area_struct *vma)
 {
-	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
-	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
+ 	int err;
+ 	err = btree_insert(&mm->mm_btree, vma->vm_start, vma);
+ 	BUG_ON(err);
 }
 
 static inline void __vma_link_file(struct vm_area_struct *vma)
@@ -414,20 +357,20 @@ static inline void __vma_link_file(struc
 
 static void
 __vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
-	struct vm_area_struct *prev, struct rb_node **rb_link,
-	struct rb_node *rb_parent)
+	struct vm_area_struct *prev)
 {
-	__vma_link_list(mm, vma, prev, rb_parent);
-	__vma_link_rb(mm, vma, rb_link, rb_parent);
+	__vma_link_list(mm, vma, prev);
+	__vma_link_btree(mm, vma);
 	__anon_vma_link(vma);
 }
 
 static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
-			struct vm_area_struct *prev, struct rb_node **rb_link,
-			struct rb_node *rb_parent)
+			struct vm_area_struct *prev)
 {
 	struct address_space *mapping = NULL;
 
+	btree_preload(&mm->mm_btree, GFP_KERNEL|__GFP_NOFAIL); // XXX create error path
+
 	if (vma->vm_file)
 		mapping = vma->vm_file->f_mapping;
 
@@ -437,7 +380,7 @@ static void vma_link(struct mm_struct *m
 	}
 	anon_vma_lock(vma);
 
-	__vma_link(mm, vma, prev, rb_link, rb_parent);
+	__vma_link(mm, vma, prev);
 	__vma_link_file(vma);
 
 	anon_vma_unlock(vma);
@@ -456,12 +399,7 @@ static void vma_link(struct mm_struct *m
 static void
 __insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
 {
-	struct vm_area_struct * __vma, * prev;
-	struct rb_node ** rb_link, * rb_parent;
-
-	__vma = find_vma_prepare(mm, vma->vm_start,&prev, &rb_link, &rb_parent);
-	BUG_ON(__vma && __vma->vm_start < vma->vm_end);
-	__vma_link(mm, vma, prev, rb_link, rb_parent);
+	__vma_link(mm, vma, NULL);
 	mm->map_count++;
 }
 
@@ -469,8 +407,21 @@ static inline void
 __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev)
 {
+	struct vm_area_struct *vma_tmp;
+
 	list_del(&vma->vm_list);
-	rb_erase(&vma->vm_rb, &mm->mm_rb);
+
+	vma_tmp = btree_remove(&mm->mm_btree, vma->vm_start);
+	if (vma_tmp != vma) {
+#ifdef CONFIG_DEBUG_VM
+		printk(KERN_DEBUG
+			"btree_remove(%lu) returned %p instead of %p\n"
+			,vma->vm_start, vma_tmp, vma);
+		btree_print(&mm->mm_btree);
+#endif
+		BUG();
+	}
+
 	if (mm->mmap_cache == vma)
 		mm->mmap_cache = prev;
 }
@@ -525,6 +476,8 @@ again:			remove_next = 1 + (end > next->
 		}
 	}
 
+	btree_preload(&mm->mm_btree, GFP_KERNEL|__GFP_NOFAIL); // XXX error path
+
 	if (file) {
 		mapping = file->f_mapping;
 		if (!(vma->vm_flags & VM_NONLINEAR))
@@ -576,10 +529,14 @@ again:			remove_next = 1 + (end > next->
 			vma_prio_tree_remove(next, root);
 	}
 
+	btree_update(&mm->mm_btree, vma->vm_start, start);
 	vma->vm_start = start;
 	vma->vm_end = end;
 	vma->vm_pgoff = pgoff;
+
 	if (adjust_next) {
+		btree_update(&mm->mm_btree, next->vm_start,
+				next->vm_start + (adjust_next << PAGE_SHIFT));
 		next->vm_start += adjust_next << PAGE_SHIFT;
 		next->vm_pgoff += adjust_next;
 	}
@@ -1075,7 +1032,7 @@ unsigned long mmap_region(struct file *f
 	/* Clear old maps */
 	error = -ENOMEM;
 munmap_back:
-	vma = find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
+	vma = find_vma_prepare(mm, addr, &prev);
 	if (vma && vma->vm_start < addr + len) {
 		if (do_munmap(mm, addr, len))
 			return -ENOMEM;
@@ -1176,7 +1133,7 @@ munmap_back:
 	if (!file || !vma_merge(mm, prev, addr, vma->vm_end,
 			vma->vm_flags, NULL, file, pgoff, vma_policy(vma))) {
 		file = vma->vm_file;
-		vma_link(mm, vma, prev, rb_link, rb_parent);
+		vma_link(mm, vma, prev);
 		if (correct_wcount)
 			atomic_inc(&inode->i_writecount);
 	} else {
@@ -1436,25 +1393,9 @@ struct vm_area_struct * find_vma(struct 
 		/* (Cache hit rate is typically around 35%.) */
 		vma = mm->mmap_cache;
 		if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
-			struct rb_node * rb_node;
-
-			rb_node = mm->mm_rb.rb_node;
-			vma = NULL;
-
-			while (rb_node) {
-				struct vm_area_struct * vma_tmp;
-
-				vma_tmp = rb_entry(rb_node,
-						struct vm_area_struct, vm_rb);
-
-				if (vma_tmp->vm_end > addr) {
-					vma = vma_tmp;
-					if (vma_tmp->vm_start <= addr)
-						break;
-					rb_node = rb_node->rb_left;
-				} else
-					rb_node = rb_node->rb_right;
-			}
+			vma = btree_stab(&mm->mm_btree, addr);
+			if (!vma || addr >= vma->vm_end)
+				vma = __vma_next(&mm->mm_vmas, vma);
 			if (vma)
 				mm->mmap_cache = vma;
 		}
@@ -1469,32 +1410,11 @@ struct vm_area_struct *
 find_vma_prev(struct mm_struct *mm, unsigned long addr,
 			struct vm_area_struct **pprev)
 {
-	struct vm_area_struct *prev = NULL, *next;
-	struct rb_node * rb_node;
-	if (!mm)
-		goto out;
-
-	/* Go through the RB tree quickly. */
-	rb_node = mm->mm_rb.rb_node;
-
-	while (rb_node) {
-		struct vm_area_struct *vma_tmp;
-		vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
-
-		if (addr < vma_tmp->vm_end) {
-			rb_node = rb_node->rb_left;
-		} else {
-			prev = vma_tmp;
-			next = __vma_next(&mm->mm_vmas, prev);
-			if (!next || (addr < next->vm_end))
-				break;
-			rb_node = rb_node->rb_right;
-		}
-	}
+	struct vm_area_struct *vma;
 
-out:
-	*pprev = prev;
-	return __vma_next(&mm->mm_vmas, prev);
+	vma = find_vma(mm, addr);
+	*pprev = __vma_prev(&mm->mm_vmas, vma);
+	return vma;
 }
 
 /*
@@ -1633,6 +1553,17 @@ static inline int expand_downwards(struc
 
 		error = acct_stack_growth(vma, size, grow);
 		if (!error) {
+			/*
+			 * This is safe even under the read lock, anon_vma_lock
+			 * guards against concurrent expand_stack calls and the
+			 * read lock keeps other structural changes to the
+			 * btree away.
+			 *
+			 * btree_update is carfully constructed to shift the
+			 * space partitioning within the btree in a safe manner.
+			 */
+			btree_update(&vma->vm_mm->mm_btree,
+					vma->vm_start, address);
 			vma->vm_start = address;
 			vma->vm_pgoff -= grow;
 		}
@@ -1757,9 +1688,9 @@ detach_vmas_to_be_unmapped(struct mm_str
 
 	do {
 		struct vm_area_struct *next = vma_next(vma);
-		rb_erase(&vma->vm_rb, &mm->mm_rb);
+  		__vma_unlink(mm, vma, NULL);
 		mm->map_count--;
-		list_move_tail(&vma->vm_list, vmas);
+		list_add_tail(&vma->vm_list, vmas);
 		vma = next;
 	} while (vma && vma->vm_start < end);
 	if (mm->unmap_area == arch_unmap_area)
@@ -1917,10 +1848,9 @@ static inline void verify_mm_writelocked
  */
 unsigned long do_brk(unsigned long addr, unsigned long len)
 {
-	struct mm_struct * mm = current->mm;
-	struct vm_area_struct * vma, * prev;
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma, *prev;
 	unsigned long flags;
-	struct rb_node ** rb_link, * rb_parent;
 	pgoff_t pgoff = addr >> PAGE_SHIFT;
 	int error;
 
@@ -1963,7 +1893,7 @@ unsigned long do_brk(unsigned long addr,
 	 * Clear old maps.  this also does some error checking for us
 	 */
  munmap_back:
-	vma = find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
+	vma = find_vma_prepare(mm, addr, &prev);
 	if (vma && vma->vm_start < addr + len) {
 		if (do_munmap(mm, addr, len))
 			return -ENOMEM;
@@ -2001,7 +1931,7 @@ unsigned long do_brk(unsigned long addr,
 	vma->vm_flags = flags;
 	vma->vm_page_prot = protection_map[flags &
 				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)];
-	vma_link(mm, vma, prev, rb_link, rb_parent);
+	vma_link(mm, vma, prev);
 out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
@@ -2053,8 +1983,7 @@ void exit_mmap(struct mm_struct *mm)
  */
 int insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
 {
-	struct vm_area_struct * __vma, * prev;
-	struct rb_node ** rb_link, * rb_parent;
+	struct vm_area_struct *__vma, *prev;
 
 	/*
 	 * The vm_pgoff of a purely anonymous vma should be irrelevant
@@ -2072,13 +2001,13 @@ int insert_vm_struct(struct mm_struct * 
 		BUG_ON(vma->anon_vma);
 		vma->vm_pgoff = vma->vm_start >> PAGE_SHIFT;
 	}
-	__vma = find_vma_prepare(mm,vma->vm_start,&prev,&rb_link,&rb_parent);
+	__vma = find_vma_prepare(mm,vma->vm_start,&prev);
 	if (__vma && __vma->vm_start < vma->vm_end)
 		return -ENOMEM;
 	if ((vma->vm_flags & VM_ACCOUNT) &&
 	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
 		return -ENOMEM;
-	vma_link(mm, vma, prev, rb_link, rb_parent);
+	vma_link(mm, vma, prev);
 	return 0;
 }
 
@@ -2093,7 +2022,6 @@ struct vm_area_struct *copy_vma(struct v
 	unsigned long vma_start = vma->vm_start;
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *new_vma, *prev;
-	struct rb_node **rb_link, *rb_parent;
 	struct mempolicy *pol;
 
 	/*
@@ -2103,7 +2031,7 @@ struct vm_area_struct *copy_vma(struct v
 	if (!vma->vm_file && !vma->anon_vma)
 		pgoff = addr >> PAGE_SHIFT;
 
-	find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
+	find_vma_prepare(mm, addr, &prev);
 	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
 			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
 	if (new_vma) {
@@ -2130,7 +2058,7 @@ struct vm_area_struct *copy_vma(struct v
 				get_file(new_vma->vm_file);
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
-			vma_link(mm, new_vma, prev, rb_link, rb_parent);
+			vma_link(mm, new_vma, prev);
 		}
 	}
 	return new_vma;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
