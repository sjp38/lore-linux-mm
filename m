Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A8FCA6B0168
	for <linux-mm@kvack.org>; Sat, 13 Mar 2010 05:51:05 -0500 (EST)
Date: Sat, 13 Mar 2010 11:51:02 +0100
From: Christian Ehrhardt <lk@c--e.de>
Subject: [PATCH 2/2] rmap: Fix Bugzilla Bug #5493
Message-ID: <20100313105102.GC16643@lisa.in-ulm.de>
References: <20100313104546.GA16643@lisa.in-ulm.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100313104546.GA16643@lisa.in-ulm.de>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


Store the vmas associated with an anon_vma in a prio tree instead
of a list.

We must make sure that the prio tree is updated during vma_adjust. This
in turn requires a way to keep an anon_vma around even if its prio tree
is temporarily empty. The ksm_refcount is turned into a general anon_vma
refcount for this purpose.

Signed-off-by: Christian Ehrhardt <lk@c--e.de>

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index d25bd22..37c2710 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -8,6 +8,7 @@
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/spinlock.h>
+#include <linux/prio_tree.h>
 #include <linux/memcontrol.h>
 
 /*
@@ -20,24 +21,24 @@
  * directly to a vma: instead it points to an anon_vma, on whose list
  * the related vmas can be easily linked or unlinked.
  *
- * After unlinking the last vma on the list, we must garbage collect
- * the anon_vma object itself: we're guaranteed no page can be
- * pointing to this anon_vma once its vma list is empty.
+ * anon_vma objects are garbage collected after the last vma is removed.
+ * The refcount can be used to prevent this garbage collection. There is
+ * no need to hold the refcount while holding the anon_vma's lock.
+ * If the anon_vma' prio_tree is empty an the refcount is zero, we're
+ * guaranteed no page can be pointing to this anon_vma.
  */
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
-#ifdef CONFIG_KSM
-	atomic_t ksm_refcount;
-#endif
+	atomic_t refcount;
 	/*
-	 * NOTE: the LSB of the head.next is set by
+	 * NOTE: the LSB of the head.prio_tree_node is set by
 	 * mm_take_all_locks() _after_ taking the above lock. So the
 	 * head must only be read/written after taking the above lock
-	 * to be sure to see a valid next pointer. The LSB bit itself
-	 * is serialized by a system wide lock only visible to
+	 * to be sure to see a valid prio_tree_node pointer. The LSB bit
+	 * itself is serialized by a system wide lock only visible to
 	 * mm_take_all_locks() (mm_all_locks_mutex).
 	 */
-	struct list_head head;	/* Chain of private "related" vmas */
+	struct prio_tree_root head;
 };
 
 /*
@@ -57,30 +58,10 @@ struct anon_vma_chain {
 	struct vm_area_struct *vma;
 	struct anon_vma *anon_vma;
 	struct list_head same_vma;   /* locked by mmap_sem & page_table_lock */
-	struct list_head same_anon_vma;	/* locked by anon_vma->lock */
+	union vma_prio_tree_node same_anon_vma; /* locked by anon_vma->lock */
 };
 
 #ifdef CONFIG_MMU
-#ifdef CONFIG_KSM
-static inline void ksm_refcount_init(struct anon_vma *anon_vma)
-{
-	atomic_set(&anon_vma->ksm_refcount, 0);
-}
-
-static inline int ksm_refcount(struct anon_vma *anon_vma)
-{
-	return atomic_read(&anon_vma->ksm_refcount);
-}
-#else
-static inline void ksm_refcount_init(struct anon_vma *anon_vma)
-{
-}
-
-static inline int ksm_refcount(struct anon_vma *anon_vma)
-{
-	return 0;
-}
-#endif /* CONFIG_KSM */
 
 static inline struct anon_vma *page_anon_vma(struct page *page)
 {
@@ -123,6 +104,51 @@ static inline void anon_vma_merge(struct vm_area_struct *vma,
 }
 
 /*
+ * Remove the vma from all the anon prio trees it is in. This must be
+ * done before modifying the offset and/or size of the vma. The vmas will
+ * become invisible for rmap until anon_vma_resize_end is called.
+ */
+static inline void anon_vma_resize_begin(struct vm_area_struct *vma)
+{
+	struct anon_vma_chain *avc;
+
+	list_for_each_entry(avc, &vma->anon_vma_chain, same_vma) {
+		struct anon_vma *anon = avc->anon_vma;
+
+		/*
+		 * Get a refcount to make sure that the anon_vma does not
+		 * get freed.
+		 */
+		if (anon) {
+			spin_lock(&anon->lock);
+			atomic_inc(&anon->refcount);
+			vma_prio_tree_remove(&avc->same_anon_vma, &anon->head);
+			spin_unlock(&anon->lock);
+		}
+	}
+}
+
+/*
+ * Add the vma back to the trees after changing the vma's size.
+ */
+static inline void anon_vma_resize_end(struct vm_area_struct *vma)
+{
+	struct anon_vma_chain *avc;
+
+	list_for_each_entry(avc, &vma->anon_vma_chain, same_vma) {
+		struct anon_vma *anon = avc->anon_vma;
+
+		/* No need to check for zero refcount on a non-empty tree. */
+		if (anon) {
+			spin_lock(&anon->lock);
+			atomic_dec(&anon->refcount);
+			vma_prio_tree_insert(&avc->same_anon_vma, &anon->head);
+			spin_unlock(&anon->lock);
+		}
+	}
+}
+
+/*
  * rmap interfaces called when adding or removing pte of page
  */
 void page_move_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
diff --git a/lib/prio_tree.c b/lib/prio_tree.c
index ccfd850..1d48709 100644
--- a/lib/prio_tree.c
+++ b/lib/prio_tree.c
@@ -14,6 +14,7 @@
 #include <linux/init.h>
 #include <linux/mm.h>
 #include <linux/prio_tree.h>
+#include <linux/rmap.h>
 
 /*
  * A clever mix of heap and radix trees forms a radix priority search tree (PST)
@@ -53,14 +54,21 @@ static void get_index(const struct prio_tree_root *root,
     const struct prio_tree_node *node,
     unsigned long *radix, unsigned long *heap)
 {
-	if (root->raw) {
+	if (root->raw == 1) {
 		struct vm_area_struct *vma = prio_tree_entry(
 		    node, struct vm_area_struct, shared.prio_tree_node);
 
 		*radix = RADIX_INDEX(vma);
 		*heap = HEAP_INDEX(vma);
-	}
-	else {
+	} else if (root->raw == 2) {
+		struct vm_area_struct *vma;
+
+		vma  = prio_tree_entry(node, struct anon_vma_chain,
+		    same_anon_vma.prio_tree_node)->vma;
+
+		*radix = RADIX_INDEX(vma);
+		*heap = HEAP_INDEX(vma);
+	} else {
 		*radix = node->start;
 		*heap = node->last;
 	}
diff --git a/mm/ksm.c b/mm/ksm.c
index a93f1b7..b92bde3 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -318,15 +318,15 @@ static void hold_anon_vma(struct rmap_item *rmap_item,
 			  struct anon_vma *anon_vma)
 {
 	rmap_item->anon_vma = anon_vma;
-	atomic_inc(&anon_vma->ksm_refcount);
+	atomic_inc(&anon_vma->refcount);
 }
 
 static void drop_anon_vma(struct rmap_item *rmap_item)
 {
 	struct anon_vma *anon_vma = rmap_item->anon_vma;
 
-	if (atomic_dec_and_lock(&anon_vma->ksm_refcount, &anon_vma->lock)) {
-		int empty = list_empty(&anon_vma->head);
+	if (atomic_dec_and_lock(&anon_vma->refcount, &anon_vma->lock)) {
+		int empty = prio_tree_empty(&anon_vma->head);
 		spin_unlock(&anon_vma->lock);
 		if (empty)
 			anon_vma_free(anon_vma);
@@ -1562,12 +1562,17 @@ int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
 		return 0;
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
+		pgoff_t pgoff = rmap_item->address >> PAGE_SHIFT;
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
+		struct prio_tree_iter iter;
 
 		spin_lock(&anon_vma->lock);
-		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
+
+		vma_prio_tree_foreach(vmac, struct anon_vma_chain,
+				      same_anon_vma, &iter,
+				      &anon_vma->head, pgoff, pgoff) {
 			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
@@ -1615,12 +1620,16 @@ int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
 		return SWAP_FAIL;
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
+		pgoff_t pgoff = rmap_item->address >> PAGE_SHIFT;
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
+		struct prio_tree_iter iter;
 
 		spin_lock(&anon_vma->lock);
-		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
+		vma_prio_tree_foreach(vmac, struct anon_vma_chain,
+				      same_anon_vma, &iter,
+				      &anon_vma->head, pgoff, pgoff) {
 			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
@@ -1667,12 +1676,16 @@ int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
 		return ret;
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
+		pgoff_t pgoff = rmap_item->address >> PAGE_SHIFT;
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
+		struct prio_tree_iter iter;
 
 		spin_lock(&anon_vma->lock);
-		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
+		vma_prio_tree_foreach(vmac, struct anon_vma_chain,
+				      same_anon_vma, &iter,
+				      &anon_vma->head, pgoff, pgoff) {
 			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index f4188d9..9ebe34c 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -383,11 +383,14 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 	if (av == NULL)	/* Not actually mapped anymore */
 		goto out;
 	for_each_process (tsk) {
+		struct prio_tree_iter iter;
+		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 		struct anon_vma_chain *vmac;
 
 		if (!task_early_kill(tsk))
 			continue;
-		list_for_each_entry(vmac, &av->head, same_anon_vma) {
+		vma_prio_tree_foreach(vmac, struct anon_vma_chain,
+			      same_anon_vma, &iter, &av->head, pgoff, pgoff) {
 			vma = vmac->vma;
 			if (!page_mapped_in_vma(page, vma))
 				continue;
diff --git a/mm/mmap.c b/mm/mmap.c
index eb5ffd4..cbbd1ac 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -493,9 +493,9 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
 
 /*
  * We cannot adjust vm_start, vm_end, vm_pgoff fields of a vma that
- * is already present in an i_mmap tree without adjusting the tree.
- * The following helper function should be used when such adjustments
- * are necessary.  The "insert" vma (if any) is to be inserted
+ * is already present in an i_mmap and/or anon_vma tree without adjusting
+ * the tree(s). The following helper function should be used when such
+ * adjustments are necessary.  The "insert" vma (if any) is to be inserted
  * before we drop the necessary locks.
  */
 int vma_adjust(struct vm_area_struct *vma, unsigned long start,
@@ -541,9 +541,6 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
-	/*
-	 * When changing only vma->vm_end, we don't really need anon_vma lock.
-	 */
 	if (vma->anon_vma && (insert || importer || start != vma->vm_start))
 		anon_vma = vma->anon_vma;
 	if (anon_vma) {
@@ -593,12 +590,16 @@ again:			remove_next = 1 + (end > next->vm_end);
 			vma_prio_tree_remove(&next->shared, root);
 	}
 
+	anon_vma_resize_begin(vma);
 	vma->vm_start = start;
 	vma->vm_end = end;
 	vma->vm_pgoff = pgoff;
+	anon_vma_resize_end(vma);
 	if (adjust_next) {
+		anon_vma_resize_begin(next);
 		next->vm_start += adjust_next << PAGE_SHIFT;
 		next->vm_pgoff += adjust_next;
+		anon_vma_resize_end(next);
 	}
 
 	if (root) {
@@ -1656,6 +1657,8 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 	 */
 	if (unlikely(anon_vma_prepare(vma)))
 		return -ENOMEM;
+
+	anon_vma_resize_begin(vma);
 	anon_vma_lock(vma);
 
 	/*
@@ -1668,6 +1671,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 		address = PAGE_ALIGN(address+4);
 	else {
 		anon_vma_unlock(vma);
+		anon_vma_resize_end(vma);
 		return -ENOMEM;
 	}
 	error = 0;
@@ -1684,6 +1688,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 			vma->vm_end = address;
 	}
 	anon_vma_unlock(vma);
+	anon_vma_resize_end(vma);
 	return error;
 }
 #endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */
@@ -1708,6 +1713,7 @@ static int expand_downwards(struct vm_area_struct *vma,
 	if (error)
 		return error;
 
+	anon_vma_resize_begin(vma);
 	anon_vma_lock(vma);
 
 	/*
@@ -1730,6 +1736,7 @@ static int expand_downwards(struct vm_area_struct *vma,
 		}
 	}
 	anon_vma_unlock(vma);
+	anon_vma_resize_end(vma);
 	return error;
 }
 
@@ -2411,7 +2418,7 @@ static DEFINE_MUTEX(mm_all_locks_mutex);
 
 static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 {
-	if (!test_bit(0, (unsigned long *) &anon_vma->head.next)) {
+	if (!test_bit(0, (unsigned long *) &anon_vma->head.prio_tree_node)) {
 		/*
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
@@ -2427,7 +2434,7 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 		 * anon_vma->lock.
 		 */
 		if (__test_and_set_bit(0, (unsigned long *)
-				       &anon_vma->head.next))
+				       &anon_vma->head.prio_tree_node))
 			BUG();
 	}
 }
@@ -2468,8 +2475,8 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
  * A single task can't take more than one mm_take_all_locks() in a row
  * or it would deadlock.
  *
- * The LSB in anon_vma->head.next and the AS_MM_ALL_LOCKS bitflag in
- * mapping->flags avoid to take the same lock twice, if more than one
+ * The LSB in anon_vma->head.prio_tree_node and the AS_MM_ALL_LOCKS bitflag
+ * in mapping->flags avoid to take the same lock twice, if more than one
  * vma in this mm is backed by the same anon_vma or address_space.
  *
  * We can take all the locks in random order because the VM code
@@ -2518,7 +2525,7 @@ out_unlock:
 
 static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 {
-	if (test_bit(0, (unsigned long *) &anon_vma->head.next)) {
+	if (test_bit(0, (unsigned long *) &anon_vma->head.prio_tree_node)) {
 		/*
 		 * The LSB of head.next can't change to 0 from under
 		 * us because we hold the mm_all_locks_mutex.
@@ -2532,7 +2539,7 @@ static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 		 * anon_vma->lock.
 		 */
 		if (!__test_and_clear_bit(0, (unsigned long *)
-					  &anon_vma->head.next))
+					  &anon_vma->head.prio_tree_node))
 			BUG();
 		spin_unlock(&anon_vma->lock);
 	}
diff --git a/mm/rmap.c b/mm/rmap.c
index deaf691..e1de542 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -142,7 +142,8 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 			avc->anon_vma = anon_vma;
 			avc->vma = vma;
 			list_add(&avc->same_vma, &vma->anon_vma_chain);
-			list_add(&avc->same_anon_vma, &anon_vma->head);
+			vma_prio_tree_insert(&avc->same_anon_vma,
+						&anon_vma->head);
 			allocated = NULL;
 		}
 		spin_unlock(&mm->page_table_lock);
@@ -170,7 +171,7 @@ static void anon_vma_chain_link(struct vm_area_struct *vma,
 	list_add(&avc->same_vma, &vma->anon_vma_chain);
 
 	spin_lock(&anon_vma->lock);
-	list_add_tail(&avc->same_anon_vma, &anon_vma->head);
+	vma_prio_tree_insert(&avc->same_anon_vma, &anon_vma->head);
 	spin_unlock(&anon_vma->lock);
 }
 
@@ -245,10 +246,11 @@ static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
 		return;
 
 	spin_lock(&anon_vma->lock);
-	list_del(&anon_vma_chain->same_anon_vma);
+	vma_prio_tree_remove(&anon_vma_chain->same_anon_vma, &anon_vma->head);
 
 	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma);
+	empty = prio_tree_empty(&anon_vma->head)
+				&& !atomic_read(&anon_vma->refcount);
 	spin_unlock(&anon_vma->lock);
 
 	if (empty)
@@ -272,8 +274,8 @@ static void anon_vma_ctor(void *data)
 	struct anon_vma *anon_vma = data;
 
 	spin_lock_init(&anon_vma->lock);
-	ksm_refcount_init(anon_vma);
-	INIT_LIST_HEAD(&anon_vma->head);
+	atomic_set(&anon_vma->refcount, 0);
+	INIT_ANON_PRIO_TREE_ROOT(&anon_vma->head);
 }
 
 void __init anon_vma_init(void)
@@ -483,9 +485,11 @@ static int page_referenced_anon(struct page *page,
 				struct mem_cgroup *mem_cont,
 				unsigned long *vm_flags)
 {
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
 	struct anon_vma_chain *avc;
+	struct prio_tree_iter iter;
 	int referenced = 0;
 
 	anon_vma = page_lock_anon_vma(page);
@@ -493,7 +497,8 @@ static int page_referenced_anon(struct page *page,
 		return referenced;
 
 	mapcount = page_mapcount(page);
-	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+	vma_prio_tree_foreach(avc, struct anon_vma_chain, same_anon_vma,
+				&iter, &anon_vma->head, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
@@ -1134,15 +1139,18 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
  */
 static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 {
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct anon_vma *anon_vma;
 	struct anon_vma_chain *avc;
+	struct prio_tree_iter iter;
 	int ret = SWAP_AGAIN;
 
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
 		return ret;
 
-	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+	vma_prio_tree_foreach(avc, struct anon_vma_chain, same_anon_vma,
+				&iter, &anon_vma->head, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
@@ -1334,9 +1342,11 @@ int try_to_munlock(struct page *page)
 static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 		struct vm_area_struct *, unsigned long, void *), void *arg)
 {
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct anon_vma *anon_vma;
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
+	struct prio_tree_iter iter;
 
 	/*
 	 * Note: remove_migration_ptes() cannot use page_lock_anon_vma()
@@ -1350,7 +1360,8 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	if (!anon_vma)
 		return ret;
 	spin_lock(&anon_vma->lock);
-	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+	vma_prio_tree_foreach(avc, struct anon_vma_chain, same_anon_vma,
+				&iter, &anon_vma->head, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
