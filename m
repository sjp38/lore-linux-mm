Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 14C806B0069
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:21:17 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ro12so9747862pbb.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 02:21:16 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 4/7] mm anon rmap: replace same_anon_vma linked list with an interval tree.
Date: Tue,  4 Sep 2012 02:20:54 -0700
Message-Id: <1346750457-12385-5-git-send-email-walken@google.com>
In-Reply-To: <1346750457-12385-1-git-send-email-walken@google.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org

When a large VMA (anon or private file mapping) is first touched, which
will populate its anon_vma field, and then split into many regions through
the use of mprotect(), the original anon_vma ends up linking all of the
vmas on a linked list. This can cause rmap to become inefficient, as we
have to walk potentially thousands of irrelevent vmas before finding the
one a given anon page might fall into.

By replacing the same_anon_vma linked list with an interval tree
(where each avc's interval is determined by its vma's start and
last pgoffs), we can make rmap efficient for this use case again.

While the change is large, all of its pieces are fairly simple.

Most places that were walking the same_anon_vma list were looking for
a known pgoff, so they can just use the anon_vma_interval_tree_foreach()
interval tree iterator instead. The exception here is ksm, where the
page's index is not known. It would probably be possible to rework ksm
so that the index would be known, but for now I have decided to keep things
simple and just walk the entirety of the interval tree there.

When updating vma's that already have an anon_vma assigned, we must take
care to re-index the corresponding avc's on their interval tree. This is
done through the use of anon_vma_interval_tree_pre_update_vma() and
anon_vma_interval_tree_post_update_vma(), which remove the avc's from
their interval tree before the update and re-insert them after the update.
The anon_vma stays locked during the update, so there is no chance that
rmap would miss the vmas that are being updated.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/mm.h   |   14 ++++++++++++
 include/linux/rmap.h |   11 +++++----
 mm/huge_memory.c     |    5 ++-
 mm/interval_tree.c   |   14 ++++++++++++
 mm/ksm.c             |    9 +++++--
 mm/memory-failure.c  |    5 +++-
 mm/mmap.c            |   57 +++++++++++++++++++++++++++++++++++++++++++------
 mm/rmap.c            |   24 ++++++++++----------
 8 files changed, 109 insertions(+), 30 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 38af0048037f..19d63ec2cbbb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -20,6 +20,7 @@
 
 struct mempolicy;
 struct anon_vma;
+struct anon_vma_chain;
 struct file_ra_state;
 struct user_struct;
 struct writeback_control;
@@ -1358,6 +1359,19 @@ static inline void vma_nonlinear_insert(struct vm_area_struct *vma,
 	list_add_tail(&vma->shared.nonlinear, list);
 }
 
+void anon_vma_interval_tree_insert(struct anon_vma_chain *node,
+				   struct rb_root *root);
+void anon_vma_interval_tree_remove(struct anon_vma_chain *node,
+				   struct rb_root *root);
+struct anon_vma_chain *anon_vma_interval_tree_iter_first(
+	struct rb_root *root, unsigned long start, unsigned long last);
+struct anon_vma_chain *anon_vma_interval_tree_iter_next(
+	struct anon_vma_chain *node, unsigned long start, unsigned long last);
+
+#define anon_vma_interval_tree_foreach(avc, root, start, last)		 \
+	for (avc = anon_vma_interval_tree_iter_first(root, start, last); \
+	     avc; avc = anon_vma_interval_tree_iter_next(avc, start, last))
+
 /* mmap.c */
 extern int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin);
 extern int vma_adjust(struct vm_area_struct *vma, unsigned long start,
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 7f32cec57e67..dce44f7d3ed8 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -37,14 +37,14 @@ struct anon_vma {
 	atomic_t refcount;
 
 	/*
-	 * NOTE: the LSB of the head.next is set by
+	 * NOTE: the LSB of the rb_root.rb_node is set by
 	 * mm_take_all_locks() _after_ taking the above lock. So the
-	 * head must only be read/written after taking the above lock
+	 * rb_root must only be read/written after taking the above lock
 	 * to be sure to see a valid next pointer. The LSB bit itself
 	 * is serialized by a system wide lock only visible to
 	 * mm_take_all_locks() (mm_all_locks_mutex).
 	 */
-	struct list_head head;	/* Chain of private "related" vmas */
+	struct rb_root rb_root;	/* Interval tree of private "related" vmas */
 };
 
 /*
@@ -57,14 +57,15 @@ struct anon_vma {
  * with a VMA, or the VMAs associated with an anon_vma.
  * The "same_vma" list contains the anon_vma_chains linking
  * all the anon_vmas associated with this VMA.
- * The "same_anon_vma" list contains the anon_vma_chains
+ * The "rb" field indexes on an interval tree the anon_vma_chains
  * which link all the VMAs associated with this anon_vma.
  */
 struct anon_vma_chain {
 	struct vm_area_struct *vma;
 	struct anon_vma *anon_vma;
 	struct list_head same_vma;   /* locked by mmap_sem & page_table_lock */
-	struct list_head same_anon_vma;	/* locked by anon_vma->mutex */
+	struct rb_node rb;			/* locked by anon_vma->mutex */
+	unsigned long rb_subtree_last;
 };
 
 #ifdef CONFIG_MMU
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 57c4b9309015..fe119cb71b41 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1421,13 +1421,14 @@ static void __split_huge_page(struct page *page,
 			      struct anon_vma *anon_vma)
 {
 	int mapcount, mapcount2;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct anon_vma_chain *avc;
 
 	BUG_ON(!PageHead(page));
 	BUG_ON(PageTail(page));
 
 	mapcount = 0;
-	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long addr = vma_address(page, vma);
 		BUG_ON(is_vma_temporary_stack(vma));
@@ -1453,7 +1454,7 @@ static void __split_huge_page(struct page *page,
 	__split_huge_page_refcount(page);
 
 	mapcount2 = 0;
-	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long addr = vma_address(page, vma);
 		BUG_ON(is_vma_temporary_stack(vma));
diff --git a/mm/interval_tree.c b/mm/interval_tree.c
index 4ab7b9ec3a56..f7c72cd35e1d 100644
--- a/mm/interval_tree.c
+++ b/mm/interval_tree.c
@@ -8,6 +8,7 @@
 
 #include <linux/mm.h>
 #include <linux/fs.h>
+#include <linux/rmap.h>
 #include <linux/interval_tree_generic.h>
 
 static inline unsigned long vma_start_pgoff(struct vm_area_struct *v)
@@ -57,3 +58,16 @@ void vma_interval_tree_insert_after(struct vm_area_struct *node,
 	rb_insert_augmented(&node->shared.linear.rb, root,
 			    &vma_interval_tree_augment);
 }
+
+static inline unsigned long avc_start_pgoff(struct anon_vma_chain *avc)
+{
+	return vma_start_pgoff(avc->vma);
+}
+
+static inline unsigned long avc_last_pgoff(struct anon_vma_chain *avc)
+{
+	return vma_last_pgoff(avc->vma);
+}
+
+INTERVAL_TREE_DEFINE(struct anon_vma_chain, rb, unsigned long, rb_subtree_last,
+		     avc_start_pgoff, avc_last_pgoff,, anon_vma_interval_tree)
diff --git a/mm/ksm.c b/mm/ksm.c
index 47c885368890..4b7cda74c2b2 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1614,7 +1614,8 @@ again:
 		struct vm_area_struct *vma;
 
 		anon_vma_lock(anon_vma);
-		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
+		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
+					       0, ULONG_MAX) {
 			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
@@ -1667,7 +1668,8 @@ again:
 		struct vm_area_struct *vma;
 
 		anon_vma_lock(anon_vma);
-		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
+		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
+					       0, ULONG_MAX) {
 			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
@@ -1719,7 +1721,8 @@ again:
 		struct vm_area_struct *vma;
 
 		anon_vma_lock(anon_vma);
-		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
+		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
+					       0, ULONG_MAX) {
 			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 65d5e8d43633..c1b6841c13b6 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -400,18 +400,21 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
 	struct anon_vma *av;
+	pgoff_t pgoff;
 
 	av = page_lock_anon_vma(page);
 	if (av == NULL)	/* Not actually mapped anymore */
 		return;
 
+	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	read_lock(&tasklist_lock);
 	for_each_process (tsk) {
 		struct anon_vma_chain *vmac;
 
 		if (!task_early_kill(tsk))
 			continue;
-		list_for_each_entry(vmac, &av->head, same_anon_vma) {
+		anon_vma_interval_tree_foreach(vmac, &av->rb_root,
+					       pgoff, pgoff) {
 			vma = vmac->vma;
 			if (!page_mapped_in_vma(page, vma))
 				continue;
diff --git a/mm/mmap.c b/mm/mmap.c
index ea647255d763..1a6afdb5194a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -356,6 +356,38 @@ void validate_mm(struct mm_struct *mm)
 #define validate_mm(mm) do { } while (0)
 #endif
 
+/*
+ * vma has some anon_vma assigned, and is already inserted on that
+ * anon_vma's interval trees.
+ *
+ * Before updating the vma's vm_start / vm_end / vm_pgoff fields, the
+ * vma must be removed from the anon_vma's interval trees using
+ * anon_vma_interval_tree_pre_update_vma().
+ *
+ * After the update, the vma will be reinserted using
+ * anon_vma_interval_tree_post_update_vma().
+ *
+ * The entire update must be protected by exclusive mmap_sem and by
+ * the root anon_vma's mutex.
+ */
+static inline void
+anon_vma_interval_tree_pre_update_vma(struct vm_area_struct *vma)
+{
+	struct anon_vma_chain *avc;
+
+	list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
+		anon_vma_interval_tree_remove(avc, &avc->anon_vma->rb_root);
+}
+
+static inline void
+anon_vma_interval_tree_post_update_vma(struct vm_area_struct *vma)
+{
+	struct anon_vma_chain *avc;
+
+	list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
+		anon_vma_interval_tree_insert(avc, &avc->anon_vma->rb_root);
+}
+
 static struct vm_area_struct *
 find_vma_prepare(struct mm_struct *mm, unsigned long addr,
 		struct vm_area_struct **pprev, struct rb_node ***rb_link,
@@ -577,6 +609,9 @@ again:			remove_next = 1 + (end > next->vm_end);
 		VM_BUG_ON(adjust_next && next->anon_vma &&
 			  anon_vma != next->anon_vma);
 		anon_vma_lock(anon_vma);
+		anon_vma_interval_tree_pre_update_vma(vma);
+		if (adjust_next)
+			anon_vma_interval_tree_pre_update_vma(next);
 	}
 
 	if (root) {
@@ -618,8 +653,12 @@ again:			remove_next = 1 + (end > next->vm_end);
 		__insert_vm_struct(mm, insert);
 	}
 
-	if (anon_vma)
+	if (anon_vma) {
+		anon_vma_interval_tree_post_update_vma(vma);
+		if (adjust_next)
+			anon_vma_interval_tree_post_update_vma(next);
 		anon_vma_unlock(anon_vma);
+	}
 	if (mapping)
 		mutex_unlock(&mapping->i_mmap_mutex);
 
@@ -1757,7 +1796,9 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 		if (vma->vm_pgoff + (size >> PAGE_SHIFT) >= vma->vm_pgoff) {
 			error = acct_stack_growth(vma, size, grow);
 			if (!error) {
+				anon_vma_interval_tree_pre_update_vma(vma);
 				vma->vm_end = address;
+				anon_vma_interval_tree_post_update_vma(vma);
 				perf_event_mmap(vma);
 			}
 		}
@@ -1807,8 +1848,10 @@ int expand_downwards(struct vm_area_struct *vma,
 		if (grow <= vma->vm_pgoff) {
 			error = acct_stack_growth(vma, size, grow);
 			if (!error) {
+				anon_vma_interval_tree_pre_update_vma(vma);
 				vma->vm_start = address;
 				vma->vm_pgoff -= grow;
+				anon_vma_interval_tree_post_update_vma(vma);
 				perf_event_mmap(vma);
 			}
 		}
@@ -2541,7 +2584,7 @@ static DEFINE_MUTEX(mm_all_locks_mutex);
 
 static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 {
-	if (!test_bit(0, (unsigned long *) &anon_vma->root->head.next)) {
+	if (!test_bit(0, (unsigned long *) &anon_vma->root->rb_root.rb_node)) {
 		/*
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
@@ -2557,7 +2600,7 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 		 * anon_vma->root->mutex.
 		 */
 		if (__test_and_set_bit(0, (unsigned long *)
-				       &anon_vma->root->head.next))
+				       &anon_vma->root->rb_root.rb_node))
 			BUG();
 	}
 }
@@ -2598,7 +2641,7 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
  * A single task can't take more than one mm_take_all_locks() in a row
  * or it would deadlock.
  *
- * The LSB in anon_vma->head.next and the AS_MM_ALL_LOCKS bitflag in
+ * The LSB in anon_vma->rb_root.rb_node and the AS_MM_ALL_LOCKS bitflag in
  * mapping->flags avoid to take the same lock twice, if more than one
  * vma in this mm is backed by the same anon_vma or address_space.
  *
@@ -2645,13 +2688,13 @@ out_unlock:
 
 static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 {
-	if (test_bit(0, (unsigned long *) &anon_vma->root->head.next)) {
+	if (test_bit(0, (unsigned long *) &anon_vma->root->rb_root.rb_node)) {
 		/*
 		 * The LSB of head.next can't change to 0 from under
 		 * us because we hold the mm_all_locks_mutex.
 		 *
 		 * We must however clear the bitflag before unlocking
-		 * the vma so the users using the anon_vma->head will
+		 * the vma so the users using the anon_vma->rb_root will
 		 * never see our bitflag.
 		 *
 		 * No need of atomic instructions here, head.next
@@ -2659,7 +2702,7 @@ static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 		 * anon_vma->root->mutex.
 		 */
 		if (!__test_and_clear_bit(0, (unsigned long *)
-					  &anon_vma->root->head.next))
+					  &anon_vma->root->rb_root.rb_node))
 			BUG();
 		anon_vma_unlock(anon_vma);
 	}
diff --git a/mm/rmap.c b/mm/rmap.c
index 8cbd62fde0f1..9c61bf387fd1 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -127,12 +127,7 @@ static void anon_vma_chain_link(struct vm_area_struct *vma,
 	avc->vma = vma;
 	avc->anon_vma = anon_vma;
 	list_add(&avc->same_vma, &vma->anon_vma_chain);
-
-	/*
-	 * It's critical to add new vmas to the tail of the anon_vma,
-	 * see comment in huge_memory.c:__split_huge_page().
-	 */
-	list_add_tail(&avc->same_anon_vma, &anon_vma->head);
+	anon_vma_interval_tree_insert(avc, &anon_vma->rb_root);
 }
 
 /**
@@ -336,13 +331,13 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
 		struct anon_vma *anon_vma = avc->anon_vma;
 
 		root = lock_anon_vma_root(root, anon_vma);
-		list_del(&avc->same_anon_vma);
+		anon_vma_interval_tree_remove(avc, &anon_vma->rb_root);
 
 		/*
 		 * Leave empty anon_vmas on the list - we'll need
 		 * to free them outside the lock.
 		 */
-		if (list_empty(&anon_vma->head))
+		if (RB_EMPTY_ROOT(&anon_vma->rb_root))
 			continue;
 
 		list_del(&avc->same_vma);
@@ -371,7 +366,7 @@ static void anon_vma_ctor(void *data)
 
 	mutex_init(&anon_vma->mutex);
 	atomic_set(&anon_vma->refcount, 0);
-	INIT_LIST_HEAD(&anon_vma->head);
+	anon_vma->rb_root = RB_ROOT;
 }
 
 void __init anon_vma_init(void)
@@ -724,6 +719,7 @@ static int page_referenced_anon(struct page *page,
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
+	pgoff_t pgoff;
 	struct anon_vma_chain *avc;
 	int referenced = 0;
 
@@ -732,7 +728,8 @@ static int page_referenced_anon(struct page *page,
 		return referenced;
 
 	mapcount = page_mapcount(page);
-	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
@@ -1445,6 +1442,7 @@ bool is_vma_temporary_stack(struct vm_area_struct *vma)
 static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 {
 	struct anon_vma *anon_vma;
+	pgoff_t pgoff;
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
@@ -1452,7 +1450,8 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 	if (!anon_vma)
 		return ret;
 
-	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address;
 
@@ -1668,6 +1667,7 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 		struct vm_area_struct *, unsigned long, void *), void *arg)
 {
 	struct anon_vma *anon_vma;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
@@ -1681,7 +1681,7 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	if (!anon_vma)
 		return ret;
 	anon_vma_lock(anon_vma);
-	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
