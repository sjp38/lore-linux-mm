Message-Id: <20070306014211.293824000@taijtu.programming.kicks-ass.net>
References: <20070306013815.951032000@taijtu.programming.kicks-ass.net>
Date: Tue, 06 Mar 2007 02:38:18 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 3/5] mm: RCUify vma lookup
Content-Disposition: inline; filename=mm-rcu.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@engr.sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

mostly lockless vma lookup using the new b+tree
pin the vma using an atomic refcount

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/init_task.h |    3 
 include/linux/mm.h        |    7 +
 include/linux/sched.h     |    2 
 kernel/fork.c             |    4 
 mm/mmap.c                 |  212 ++++++++++++++++++++++++++++++++++++++++------
 5 files changed, 199 insertions(+), 29 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -103,12 +103,14 @@ struct vm_area_struct {
 	void * vm_private_data;		/* was vm_pte (shared mem) */
 	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
 
+	atomic_t vm_count;
 #ifndef CONFIG_MMU
 	atomic_t vm_usage;		/* refcount (VMAs shared if !MMU) */
 #endif
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+	struct rcu_head vm_rcu_head;
 };
 
 static inline struct vm_area_struct *
@@ -1047,6 +1049,8 @@ static inline void vma_nonlinear_insert(
 }
 
 /* mmap.c */
+extern void btree_rcu_flush(struct btree_freevec *);
+extern void free_vma(struct vm_area_struct *vma);
 extern int __vm_enough_memory(long pages, int cap_sys_admin);
 extern void vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert);
@@ -1132,6 +1136,9 @@ extern struct vm_area_struct * find_vma(
 extern struct vm_area_struct * find_vma_prev(struct mm_struct * mm, unsigned long addr,
 					     struct vm_area_struct **pprev);
 
+extern struct vm_area_struct * find_get_vma(struct mm_struct *mm, unsigned long addr);
+extern void put_vma(struct vm_area_struct *vma);
+
 /* Look up the first VMA which intersects the interval start_addr..end_addr-1,
    NULL if none.  Assume start_addr < end_addr. */
 static inline struct vm_area_struct * find_vma_intersection(struct mm_struct * mm, unsigned long start_addr, unsigned long end_addr)
Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -54,6 +54,7 @@ struct sched_param {
 #include <linux/cpumask.h>
 #include <linux/errno.h>
 #include <linux/nodemask.h>
+#include <linux/rcupdate.h>
 
 #include <asm/system.h>
 #include <asm/semaphore.h>
@@ -311,6 +312,7 @@ struct mm_struct {
 	struct list_head mm_vmas;
 	struct btree_root mm_btree;
 	spinlock_t mm_btree_lock;
+	wait_queue_head_t mm_wq;
 	struct vm_area_struct * mmap_cache;	/* last find_vma result */
 	unsigned long (*get_unmapped_area) (struct file *filp,
 				unsigned long addr, unsigned long len,
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -39,6 +39,18 @@ static void unmap_region(struct mm_struc
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end);
 
+static void __btree_rcu_flush(struct rcu_head *head)
+{
+	struct btree_freevec *freevec =
+		container_of(head, struct btree_freevec, rcu_head);
+	btree_freevec_flush(freevec);
+}
+
+void btree_rcu_flush(struct btree_freevec *freevec)
+{
+	call_rcu(&freevec->rcu_head, __btree_rcu_flush);
+}
+
 /*
  * WARNING: the debugging will use recursive algorithms so never enable this
  * unless you know what you are doing.
@@ -217,6 +229,18 @@ void unlink_file_vma(struct vm_area_stru
 	}
 }
 
+static void __free_vma(struct rcu_head *head)
+{
+	struct vm_area_struct *vma =
+		container_of(head, struct vm_area_struct, vm_rcu_head);
+	kmem_cache_free(vm_area_cachep, vma);
+}
+
+void free_vma(struct vm_area_struct *vma)
+{
+	call_rcu(&vma->vm_rcu_head, __free_vma);
+}
+
 /*
  * Close a vm structure and free it, returning the next.
  */
@@ -229,7 +253,7 @@ static void remove_vma(struct vm_area_st
 		fput(vma->vm_file);
 	mpol_free(vma_policy(vma));
 	list_del(&vma->vm_list);
-	kmem_cache_free(vm_area_cachep, vma);
+	free_vma(vma);
 }
 
 asmlinkage unsigned long sys_brk(unsigned long brk)
@@ -312,6 +336,7 @@ __vma_link_list(struct mm_struct *mm, st
 void __vma_link_btree(struct mm_struct *mm, struct vm_area_struct *vma)
 {
 	int err;
+	atomic_set(&vma->vm_count, 1);
 	spin_lock(&mm->mm_btree_lock);
 	err = btree_insert(&mm->mm_btree, vma->vm_start, vma);
 	spin_unlock(&mm->mm_btree_lock);
@@ -388,6 +413,17 @@ __insert_vm_struct(struct mm_struct * mm
 	mm->map_count++;
 }
 
+static void lock_vma(struct vm_area_struct *vma)
+{
+	wait_event(vma->vm_mm->mm_wq, (atomic_cmpxchg(&vma->vm_count, 1, 0) == 1));
+}
+
+static void unlock_vma(struct vm_area_struct *vma)
+{
+	BUG_ON(atomic_read(&vma->vm_count));
+	atomic_set(&vma->vm_count, 1);
+}
+
 static inline void
 __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev)
@@ -395,11 +431,12 @@ __vma_unlink(struct mm_struct *mm, struc
 	struct vm_area_struct *vma_tmp;
 	list_del(&vma->vm_list);
 	spin_lock(&mm->mm_btree_lock);
+	BUG_ON(atomic_read(&vma->vm_count));
 	vma_tmp = btree_remove(&mm->mm_btree, vma->vm_start);
 	spin_unlock(&mm->mm_btree_lock);
 	BUG_ON(vma_tmp != vma);
-	if (mm->mmap_cache == vma)
-		mm->mmap_cache = prev;
+	if (rcu_dereference(mm->mmap_cache) == vma)
+		rcu_assign_pointer(mm->mmap_cache, prev);
 }
 
 /*
@@ -415,6 +452,7 @@ void vma_adjust(struct vm_area_struct *v
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *next = vma_next(vma);
 	struct vm_area_struct *importer = NULL;
+	struct vm_area_struct *locked = NULL;
 	struct address_space *mapping = NULL;
 	struct prio_tree_root *root = NULL;
 	struct file *file = vma->vm_file;
@@ -425,6 +463,14 @@ void vma_adjust(struct vm_area_struct *v
 	if (next && !insert) {
 		if (end >= next->vm_end) {
 			/*
+			 * We need to lock the vma to force the lockless
+			 * lookup into the slow path. Because there is a
+			 * hole between removing the next vma and updating
+			 * the current.
+			 */
+			lock_vma(vma);
+			locked = vma;
+			/*
 			 * vma expands, overlapping all the next, and
 			 * perhaps the one after too (mprotect case 6).
 			 */
@@ -452,6 +498,25 @@ again:			remove_next = 1 + (end > next->
 		}
 	}
 
+	if (insert) {
+		/*
+		 * In order to make the adjust + insert look atomic wrt. the
+		 * lockless lookups we need to force those into the slow path.
+		 */
+		if (insert->vm_start < start) {
+			/*
+			 * If the new vma is to be placed in front of the
+			 * current one, we must lock the previous.
+			 */
+			locked = vma_prev(vma);
+			if (!locked)
+				locked = vma;
+		} else
+			locked = vma;
+
+		lock_vma(locked);
+	}
+
 	btree_preload(&mm->mm_btree, GFP_KERNEL|__GFP_NOFAIL);
 
 	if (file) {
@@ -498,6 +563,23 @@ again:			remove_next = 1 + (end > next->
 		}
 	}
 
+	/*
+	 * Remove the next vma before updating the address of the current,
+	 * because it might end up having the address of next.
+	 */
+	if (remove_next) {
+		/*
+		 * vma_merge has merged next into vma, and needs
+		 * us to remove next before dropping the locks.
+		 */
+		lock_vma(next);
+		__vma_unlink(mm, next, vma);
+		if (file)
+			__remove_shared_vm_struct(next, file, mapping);
+		if (next->anon_vma)
+			__anon_vma_merge(vma, next);
+	}
+
 	if (root) {
 		flush_dcache_mmap_lock(mapping);
 		vma_prio_tree_remove(vma, root);
@@ -510,16 +592,14 @@ again:			remove_next = 1 + (end > next->
 	vma->vm_start = start;
 	vma->vm_end = end;
 	vma->vm_pgoff = pgoff;
-	spin_unlock(&mm->mm_btree_lock);
 
 	if (adjust_next) {
-		spin_lock(&mm->mm_btree_lock);
 		btree_update(&mm->mm_btree, next->vm_start,
 				next->vm_start + (adjust_next << PAGE_SHIFT));
 		next->vm_start += adjust_next << PAGE_SHIFT;
 		next->vm_pgoff += adjust_next;
-		spin_unlock(&mm->mm_btree_lock);
 	}
+	spin_unlock(&mm->mm_btree_lock);
 
 	if (root) {
 		if (adjust_next)
@@ -528,17 +608,11 @@ again:			remove_next = 1 + (end > next->
 		flush_dcache_mmap_unlock(mapping);
 	}
 
-	if (remove_next) {
-		/*
-		 * vma_merge has merged next into vma, and needs
-		 * us to remove next before dropping the locks.
-		 */
-		__vma_unlink(mm, next, vma);
-		if (file)
-			__remove_shared_vm_struct(next, file, mapping);
-		if (next->anon_vma)
-			__anon_vma_merge(vma, next);
-	} else if (insert) {
+	/*
+	 * Insert after updating the address of the current vma, because it
+	 * might end up having the previous address.
+	 */
+	if (insert) {
 		/*
 		 * split_vma has split insert from vma, and needs
 		 * us to insert it before dropping the locks
@@ -557,7 +631,7 @@ again:			remove_next = 1 + (end > next->
 			fput(file);
 		mm->map_count--;
 		mpol_free(vma_policy(next));
-		kmem_cache_free(vm_area_cachep, next);
+		free_vma(next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
 		 * we must remove another next too. It would clutter
@@ -569,6 +643,13 @@ again:			remove_next = 1 + (end > next->
 		}
 	}
 
+	if (locked) {
+		/*
+		 * unlock the vma, enabling lockless lookups.
+		 */
+		unlock_vma(locked);
+	}
+
 	validate_mm(mm);
 }
 
@@ -688,7 +769,7 @@ struct vm_area_struct *vma_merge(struct 
 	next = __vma_next(&mm->mm_vmas, prev);
 	area = next;
 	if (next && next->vm_end == end)		/* cases 6, 7, 8 */
-		next = __vma_next(&mm->mm_vmas, next);
+		next = vma_next(next);
 
 	/*
 	 * Can it merge with the predecessor?
@@ -1071,7 +1152,7 @@ munmap_back:
 			fput(file);
 		}
 		mpol_free(vma_policy(vma));
-		kmem_cache_free(vm_area_cachep, vma);
+		free_vma(vma);
 	}
 out:	
 	mm->total_vm += len >> PAGE_SHIFT;
@@ -1098,7 +1179,7 @@ unmap_and_free_vma:
 	unmap_region(mm, &mm->mm_vmas, vma, prev, vma->vm_start, vma->vm_end);
 	charged = 0;
 free_vma:
-	kmem_cache_free(vm_area_cachep, vma);
+	free_vma(vma);
 unacct_error:
 	if (charged)
 		vm_unacct_memory(charged);
@@ -1145,7 +1226,7 @@ arch_get_unmapped_area(struct file *filp
 	}
 
 full_search:
-	for (vma = find_vma(mm, addr); ; vma = __vma_next(&mm->mm_vmas, vma)) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
@@ -1329,22 +1410,21 @@ get_unmapped_area(struct file *file, uns
 EXPORT_SYMBOL(get_unmapped_area);
 
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
-struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr)
+struct vm_area_struct *find_vma(struct mm_struct * mm, unsigned long addr)
 {
 	struct vm_area_struct *vma = NULL;
 
 	if (mm) {
 		/* Check the cache first. */
 		/* (Cache hit rate is typically around 35%.) */
-		vma = mm->mmap_cache;
+		vma = rcu_dereference(mm->mmap_cache);
 		if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
 			vma = btree_stab(&mm->mm_btree, addr);
-			/* addr < vm_end */
 			if (!vma || addr >= vma->vm_end)
 				vma = __vma_next(&mm->mm_vmas, vma);
 
 			if (vma)
-				mm->mmap_cache = vma;
+				rcu_assign_pointer(mm->mmap_cache, vma);
 		}
 	}
 	return vma;
@@ -1352,6 +1432,82 @@ struct vm_area_struct * find_vma(struct 
 
 EXPORT_SYMBOL(find_vma);
 
+/*
+ * Differs only from the above in that it uses the slightly more expensive
+ * btree_stab_next() in order to avoid using the mm->mm_vmas list without
+ * locks.
+ */
+static
+struct vm_area_struct *find_vma_rcu(struct mm_struct * mm, unsigned long addr)
+{
+	struct vm_area_struct *vma = NULL, *next;
+
+	if (mm) {
+		/* Check the cache first. */
+		/* (Cache hit rate is typically around 35%.) */
+		vma = rcu_dereference(mm->mmap_cache);
+		if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
+			vma = btree_stab_next(&mm->mm_btree, addr, (void **)&next);
+			if (!vma || addr >= vma->vm_end)
+				vma = next;
+
+			if (vma)
+				rcu_assign_pointer(mm->mmap_cache, vma);
+		}
+	}
+	return vma;
+}
+
+/*
+ * Lockless lookup and pinning of vmas:
+ *
+ * In order to be able to do vma modifications and have them appear atomic
+ * we must sometimes still take the read lock. We do this when we fail to
+ * get a reference on the vma.
+ *
+ */
+struct vm_area_struct *find_get_vma(struct mm_struct *mm, unsigned long addr)
+{
+	struct vm_area_struct *vma;
+
+	if (!mm)
+		return NULL;
+
+	rcu_read_lock();
+	vma = find_vma_rcu(mm, addr);
+	if (!vma || !atomic_inc_not_zero(&vma->vm_count))
+		goto slow;
+	rcu_read_unlock();
+	return vma;
+
+slow:
+	rcu_read_unlock();
+	down_read(&mm->mmap_sem);
+	vma = find_vma(mm, addr);
+	if (vma && !atomic_inc_not_zero(&vma->vm_count))
+			BUG();
+	up_read(&mm->mmap_sem);
+	return vma;
+}
+
+void put_vma(struct vm_area_struct *vma)
+{
+	if (!vma)
+		return;
+
+	switch (atomic_dec_return(&vma->vm_count)) {
+		default:
+			break;
+
+		case 1:
+			wake_up_all(&vma->vm_mm->mm_wq);
+			break;
+
+		case 0:
+			BUG();
+	}
+}
+
 /* Same as find_vma, but also return a pointer to the previous VMA in *pprev. */
 struct vm_area_struct *
 find_vma_prev(struct mm_struct *mm, unsigned long addr,
@@ -1621,10 +1777,13 @@ detach_vmas_to_be_unmapped(struct mm_str
 {
 	unsigned long addr;
 
+	rcu_assign_pointer(mm->mmap_cache, NULL);	/* Kill the cache. */
 	do {
 		struct vm_area_struct *vma_tmp;
 		btree_preload(&mm->mm_btree, GFP_KERNEL|__GFP_NOFAIL);
+		lock_vma(vma);
 		spin_lock(&mm->mm_btree_lock);
+		BUG_ON(atomic_read(&vma->vm_count));
 		vma_tmp = btree_remove(&mm->mm_btree, vma->vm_start);
 		spin_unlock(&mm->mm_btree_lock);
 		if (vma_tmp != vma) {
@@ -1643,7 +1802,6 @@ detach_vmas_to_be_unmapped(struct mm_str
 	else
 		addr = vma ?  vma->vm_end : mm->mmap_base;
 	mm->unmap_area(mm, addr);
-	mm->mmap_cache = NULL;		/* Kill the cache. */
 }
 
 /*
Index: linux-2.6/include/linux/init_task.h
===================================================================
--- linux-2.6.orig/include/linux/init_task.h
+++ linux-2.6/include/linux/init_task.h
@@ -47,8 +47,9 @@
 #define INIT_MM(name) \
 {			 					\
 	.mm_vmas	= LIST_HEAD_INIT(name.mm_vmas),		\
-	.mm_btree	= BTREE_INIT(GFP_ATOMIC|__GFP_NOFAIL),	\
+	.mm_btree	= BTREE_INIT_FLUSH(GFP_ATOMIC|__GFP_NOFAIL, btree_rcu_flush), \
 	.mm_btree_lock	= __SPIN_LOCK_UNLOCKED(name.mm_btree_lock), \
+	.mm_wq		= __WAIT_QUEUE_HEAD_INITIALIZER(name.mm_wq), \
 	.pgd		= swapper_pg_dir, 			\
 	.mm_users	= ATOMIC_INIT(2), 			\
 	.mm_count	= ATOMIC_INIT(1), 			\
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -323,8 +323,10 @@ static void free_mm(struct mm_struct *mm
 static struct mm_struct * mm_init(struct mm_struct * mm)
 {
 	INIT_LIST_HEAD(&mm->mm_vmas);
-	mm->mm_btree = BTREE_INIT(GFP_ATOMIC|__GFP_NOFAIL);
+	mm->mm_btree =
+		BTREE_INIT_FLUSH(GFP_ATOMIC|__GFP_NOFAIL, btree_rcu_flush);
 	spin_lock_init(&mm->mm_btree_lock);
+	init_waitqueue_head(&mm->mm_wq);
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
