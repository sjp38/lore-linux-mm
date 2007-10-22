Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9MAhpvv014638
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:51 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MAhshj1671422
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:54 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MAhcOl002893
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:38 +1000
Message-Id: <20071022104530.912224119@linux.vnet.ibm.com>>
References: <20071022104518.985992030@linux.vnet.ibm.com>>
Date: Mon, 22 Oct 2007 16:15:23 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: [PATCH/RFC 4/9] mm: RCU vma lookups
Content-Disposition: inline; filename=4_mm-rcu.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Alexis Bruemmer <alexisb@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

mostly lockless vma lookup using the new b+tree
pin the vma using an atomic refcount

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
---
 include/linux/init_task.h |    2 
 include/linux/mm.h        |    9 +
 kernel/fork.c             |    2 
 mm/mmap.c                 |  216 +++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 206 insertions(+), 23 deletions(-)

--- linux-2.6.23-rc9.orig/include/linux/init_task.h
+++ linux-2.6.23-rc9/include/linux/init_task.h
@@ -48,7 +48,7 @@
 #define INIT_MM(name) \
 {			 					\
 	.mm_vmas	= LIST_HEAD_INIT(name.mm_vmas),		\
-	.mm_btree	= BTREE_INIT(GFP_ATOMIC),		\
+	.mm_btree	= BTREE_INIT_FLUSH(GFP_ATOMIC, btree_rcu_flush), \
 	.pgd		= swapper_pg_dir, 			\
 	.mm_users	= ATOMIC_INIT(2), 			\
 	.mm_count	= ATOMIC_INIT(1), 			\
--- linux-2.6.23-rc9.orig/include/linux/mm.h
+++ linux-2.6.23-rc9/include/linux/mm.h
@@ -104,12 +104,14 @@ struct vm_area_struct {
 	void * vm_private_data;		/* was vm_pte (shared mem) */
 	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
 
+	struct rw_semaphore vm_sem;
 #ifndef CONFIG_MMU
 	atomic_t vm_usage;		/* refcount (VMAs shared if !MMU) */
 #endif
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+	struct rcu_head vm_rcu_head;
 };
 
 static inline struct vm_area_struct *
@@ -1078,6 +1080,8 @@ static inline void vma_nonlinear_insert(
 }
 
 /* mmap.c */
+extern void btree_rcu_flush(struct btree_freevec *);
+extern void free_vma(struct vm_area_struct *vma);
 extern int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin);
 extern void vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert);
@@ -1177,6 +1181,11 @@ extern struct vm_area_struct * find_vma(
 extern struct vm_area_struct * find_vma_prev(struct mm_struct * mm, unsigned long addr,
 					     struct vm_area_struct **pprev);
 
+extern struct vm_area_struct * __find_get_vma(struct mm_struct *mm, unsigned long addr, int *locked);
+extern struct vm_area_struct * find_get_vma(struct mm_struct *mm, unsigned long addr);
+extern void get_vma(struct vm_area_struct *vma);
+extern void put_vma(struct vm_area_struct *vma);
+
 /* Look up the first VMA which intersects the interval start_addr..end_addr-1,
    NULL if none.  Assume start_addr < end_addr. */
 static inline struct vm_area_struct * find_vma_intersection(struct mm_struct * mm, unsigned long start_addr, unsigned long end_addr)
--- linux-2.6.23-rc9.orig/kernel/fork.c
+++ linux-2.6.23-rc9/kernel/fork.c
@@ -327,7 +327,7 @@ static void free_mm(struct mm_struct *mm
 static struct mm_struct * mm_init(struct mm_struct * mm)
 {
 	INIT_LIST_HEAD(&mm->mm_vmas);
-	mm->mm_btree = BTREE_INIT(GFP_ATOMIC);
+	mm->mm_btree = BTREE_INIT_FLUSH(GFP_ATOMIC, btree_rcu_flush);
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
--- linux-2.6.23-rc9.orig/mm/mmap.c
+++ linux-2.6.23-rc9/mm/mmap.c
@@ -40,6 +40,18 @@ static void unmap_region(struct mm_struc
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
@@ -218,6 +230,28 @@ void unlink_file_vma(struct vm_area_stru
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
+static void lock_vma(struct vm_area_struct *vma)
+{
+	down_write(&vma->vm_sem);
+}
+
+static void unlock_vma(struct vm_area_struct *vma)
+{
+	up_write(&vma->vm_sem);
+}
+
 /*
  * Close a vm structure and free it, returning the next.
  */
@@ -230,7 +264,7 @@ static void remove_vma(struct vm_area_st
 	if (vma->vm_file)
 		fput(vma->vm_file);
 	mpol_free(vma_policy(vma));
-	kmem_cache_free(vm_area_cachep, vma);
+	free_vma(vma);
 	return;
 }
 
@@ -288,8 +322,15 @@ void validate_mm(struct mm_struct *mm)
 	int bug = 0;
 	int i = 0;
 	struct vm_area_struct *vma;
-	list_for_each_entry(vma, &mm->mm_vmas, vm_list)
+	unsigned long addr = 0UL;
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
+		if (addr > vma->vm_start) {
+			printk("vma list unordered: %lu %lu\n",
+					addr, vma->vm_start);
+		}
+		addr = vma->vm_start;
 		i++;
+	}
 	if (i != mm->map_count)
 		printk("map_count %d vm_next %d\n", mm->map_count, i), bug = 1;
 	BUG_ON(bug);
@@ -328,6 +369,7 @@ __vma_link_list(struct mm_struct *mm, st
 void __vma_link_btree(struct mm_struct *mm, struct vm_area_struct *vma)
 {
  	int err;
+	init_rwsem(&vma->vm_sem);
  	err = btree_insert(&mm->mm_btree, vma->vm_start, vma);
  	BUG_ON(err);
 }
@@ -421,8 +463,8 @@ __vma_unlink(struct mm_struct *mm, struc
 		BUG();
 	}
 
-	if (mm->mmap_cache == vma)
-		mm->mmap_cache = prev;
+	if (rcu_dereference(mm->mmap_cache) == vma)
+		rcu_assign_pointer(mm->mmap_cache, prev);
 }
 
 /*
@@ -438,6 +480,7 @@ void vma_adjust(struct vm_area_struct *v
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *next = vma_next(vma);
 	struct vm_area_struct *importer = NULL;
+	struct vm_area_struct *locked = NULL;
 	struct address_space *mapping = NULL;
 	struct prio_tree_root *root = NULL;
 	struct file *file = vma->vm_file;
@@ -448,6 +491,14 @@ void vma_adjust(struct vm_area_struct *v
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
@@ -475,6 +526,25 @@ again:			remove_next = 1 + (end > next->
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
 	btree_preload(&mm->mm_btree, GFP_KERNEL|__GFP_NOFAIL); // XXX error path
 
 	if (file) {
@@ -521,6 +591,23 @@ again:			remove_next = 1 + (end > next->
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
@@ -547,17 +634,11 @@ again:			remove_next = 1 + (end > next->
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
@@ -576,7 +657,7 @@ again:			remove_next = 1 + (end > next->
 			fput(file);
 		mm->map_count--;
 		mpol_free(vma_policy(next));
-		kmem_cache_free(vm_area_cachep, next);
+		free_vma(next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
 		 * we must remove another next too. It would clutter
@@ -588,6 +669,13 @@ again:			remove_next = 1 + (end > next->
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
 
@@ -1142,7 +1230,7 @@ munmap_back:
 			fput(file);
 		}
 		mpol_free(vma_policy(vma));
-		kmem_cache_free(vm_area_cachep, vma);
+		free_vma(vma);
 	}
 out:	
 	mm->total_vm += len >> PAGE_SHIFT;
@@ -1166,7 +1254,7 @@ unmap_and_free_vma:
 	unmap_region(mm, &vmas, vma, prev, vma->vm_start, vma->vm_end);
 	charged = 0;
 free_vma:
-	kmem_cache_free(vm_area_cachep, vma);
+	free_vma(vma);
 unacct_error:
 	if (charged)
 		vm_unacct_memory(charged);
@@ -1390,13 +1478,13 @@ struct vm_area_struct * find_vma(struct 
 	if (mm) {
 		/* Check the cache first. */
 		/* (Cache hit rate is typically around 35%.) */
-		vma = mm->mmap_cache;
+		vma = rcu_dereference(mm->mmap_cache);
 		if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
 			vma = btree_stab(&mm->mm_btree, addr);
 			if (!vma || addr >= vma->vm_end)
 				vma = __vma_next(&mm->mm_vmas, vma);
 			if (vma)
-				mm->mmap_cache = vma;
+				rcu_assign_pointer(mm->mmap_cache, vma);
 		}
 	}
 	return vma;
@@ -1404,6 +1492,90 @@ struct vm_area_struct * find_vma(struct 
 
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
+			vma = btree_stab_next(&mm->mm_btree, addr,
+					(void **)&next);
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
+struct vm_area_struct *
+__find_get_vma(struct mm_struct *mm, unsigned long addr, int *locked)
+{
+	struct vm_area_struct *vma;
+
+	if (!mm)
+		return NULL;
+
+	rcu_read_lock();
+	vma = find_vma_rcu(mm, addr);
+	if (!vma || !down_read_trylock(&vma->vm_sem))
+		goto slow;
+	rcu_read_unlock();
+	return vma;
+
+slow:
+	rcu_read_unlock();
+	down_read(&mm->mmap_sem);
+	vma = find_vma(mm, addr);
+	if (vma)
+		down_read(&vma->vm_sem);
+	*locked = 1;
+	return vma;
+}
+
+struct vm_area_struct *
+find_get_vma(struct mm_struct *mm, unsigned long addr)
+{
+	int locked = 0;
+	struct vm_area_struct *vma;
+
+	vma = __find_get_vma(mm, addr, &locked);
+	if (unlikely(locked))
+		up_read(&mm->mmap_sem);
+	return vma;
+}
+
+void get_vma(struct vm_area_struct *vma)
+{
+	if (likely(vma))
+		down_read(&vma->vm_sem);
+}
+
+void put_vma(struct vm_area_struct *vma)
+{
+	if (likely(vma))
+		up_read(&vma->vm_sem);
+}
+
 /* Same as find_vma, but also return a pointer to the previous VMA in *pprev. */
 struct vm_area_struct *
 find_vma_prev(struct mm_struct *mm, unsigned long addr,
@@ -1687,8 +1859,10 @@ detach_vmas_to_be_unmapped(struct mm_str
 
 	do {
 		struct vm_area_struct *next = vma_next(vma);
+		lock_vma(vma);
   		__vma_unlink(mm, vma, NULL);
 		mm->map_count--;
+		unlock_vma(vma);
 		list_add_tail(&vma->vm_list, vmas);
 		vma = next;
 	} while (vma && vma->vm_start < end);
@@ -1697,7 +1871,7 @@ detach_vmas_to_be_unmapped(struct mm_str
 	else
 		addr = vma ?  vma->vm_start : mm->mmap_base;
 	mm->unmap_area(mm, addr);
-	mm->mmap_cache = NULL;		/* Kill the cache. */
+	/* mm->mmap_cache = NULL;*/		/* Kill the cache. */
 }
 
 /*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
