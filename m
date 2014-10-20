Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id A06EA6B006C
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 18:41:52 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so9116wgg.25
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 15:41:52 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id ub8si12036559wjc.108.2014.10.20.15.41.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 15:41:49 -0700 (PDT)
Message-Id: <20141020222841.419869904@infradead.org>
Date: Mon, 20 Oct 2014 23:56:37 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 4/6] SRCU free VMAs
References: <20141020215633.717315139@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-mm-srcu-vma.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

Manage the VMAs with SRCU such that we can do a lockless VMA lookup.

We put the fput(vma->vm_file) in the SRCU callback, this keeps files
valid during speculative faults, this is possible due to the delayed
fput work by Al Viro -- do we need srcu_barrier() in unmount
someplace?

We guard the mm_rb tree with a seqlock (XXX could be a seqcount but
we'd have to disable preemption around the write side in order to make
the retry loop in __read_seqcount_begin() work) such that we can know
if the rb tree walk was correct. We cannot trust the restult of a
lockless tree walk in the face of concurrent tree rotations; although
we can trust on the termination of such walks -- tree rotations
guarantee the end result is a tree again after all.

Furthermore, we rely on the WMB implied by the
write_seqlock/count_begin() to separate the VMA initialization and the
publishing stores, analogous to the RELEASE in rcu_assign_pointer().
We also rely on the RMB from read_seqretry() to separate the vma load
from further loads like the smp_read_barrier_depends() in regular
RCU.

We must not touch the vmacache while doing SRCU lookups as that is not
properly serialized against changes. We update gap information after
publishing the VMA, but A) we don't use that and B) the seqlock
read side would fix that anyhow.

We clear vma->vm_rb for nodes removed from the vma tree such that we
can easily detect such 'dead' nodes, we rely on the WMB from
write_sequnlock() to separate the tree removal and clearing the node.

Provide find_vma_srcu() which wraps the required magic.

XXX: mmap()/munmap() heavy workloads might suffer from the global lock
in call_srcu() -- this is fixable with a 'better' SRCU implementation.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/linux/mm_types.h |    3 +
 kernel/fork.c            |    1 
 mm/init-mm.c             |    1 
 mm/internal.h            |   18 +++++++++
 mm/mmap.c                |   88 ++++++++++++++++++++++++++++++++++++-----------
 5 files changed, 91 insertions(+), 20 deletions(-)

--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -14,6 +14,7 @@
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
 #include <linux/seqlock.h>
+#include <linux/srcu.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -310,6 +311,7 @@ struct vm_area_struct {
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
 	seqcount_t vm_sequence;
+	struct rcu_head vm_rcu_head;
 };
 
 struct core_thread {
@@ -347,6 +349,7 @@ struct kioctx_table;
 struct mm_struct {
 	struct vm_area_struct *mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
+	seqlock_t mm_seq;
 	u32 vmacache_seqnum;                   /* per-thread vmacache */
 #ifdef CONFIG_MMU
 	unsigned long (*get_unmapped_area) (struct file *filp,
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -553,6 +553,7 @@ static struct mm_struct *mm_init(struct
 	mm->mmap = NULL;
 	mm->mm_rb = RB_ROOT;
 	mm->vmacache_seqnum = 0;
+	seqlock_init(&mm->mm_seq);
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -15,6 +15,7 @@
 
 struct mm_struct init_mm = {
 	.mm_rb		= RB_ROOT,
+	.mm_seq		= __SEQLOCK_UNLOCKED(init_mm.mm_seq),
 	.pgd		= swapper_pg_dir,
 	.mm_users	= ATOMIC_INIT(2),
 	.mm_count	= ATOMIC_INIT(1),
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -14,6 +14,24 @@
 #include <linux/fs.h>
 #include <linux/mm.h>
 
+extern struct srcu_struct vma_srcu;
+
+extern struct vm_area_struct *find_vma_srcu(struct mm_struct *mm, unsigned long addr);
+
+static inline bool vma_is_dead(struct vm_area_struct *vma, unsigned int sequence)
+{
+	int ret = RB_EMPTY_NODE(&vma->vm_rb);
+	unsigned seq = ACCESS_ONCE(vma->vm_sequence.sequence);
+
+	/*
+	 * Matches both the wmb in write_seqlock_{begin,end}() and
+	 * the wmb in vma_rb_erase().
+	 */
+	smp_rmb();
+
+	return ret || seq != sequence;
+}
+
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -247,6 +247,23 @@ void unlink_file_vma(struct vm_area_stru
 	}
 }
 
+DEFINE_SRCU(vma_srcu);
+
+static void __free_vma(struct rcu_head *head)
+{
+	struct vm_area_struct *vma =
+		container_of(head, struct vm_area_struct, vm_rcu_head);
+
+	if (vma->vm_file)
+		fput(vma->vm_file);
+	kmem_cache_free(vm_area_cachep, vma);
+}
+
+static void free_vma(struct vm_area_struct *vma)
+{
+	call_srcu(&vma_srcu, &vma->vm_rcu_head, __free_vma);
+}
+
 /*
  * Close a vm structure and free it, returning the next.
  */
@@ -257,10 +274,8 @@ static struct vm_area_struct *remove_vma
 	might_sleep();
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
-	if (vma->vm_file)
-		fput(vma->vm_file);
 	mpol_put(vma_policy(vma));
-	kmem_cache_free(vm_area_cachep, vma);
+	free_vma(vma);
 	return next;
 }
 
@@ -468,17 +483,19 @@ static void vma_gap_update(struct vm_are
 	vma_gap_callbacks_propagate(&vma->vm_rb, NULL);
 }
 
-static inline void vma_rb_insert(struct vm_area_struct *vma,
-				 struct rb_root *root)
+static inline void vma_rb_insert(struct vm_area_struct *vma, struct mm_struct *mm)
 {
+	struct rb_root *root = &mm->mm_rb;
+
 	/* All rb_subtree_gap values must be consistent prior to insertion */
 	validate_mm_rb(root, NULL);
 
 	rb_insert_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
 }
 
-static void vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
+static void vma_rb_erase(struct vm_area_struct *vma, struct mm_struct *mm)
 {
+	struct rb_root *root = &mm->mm_rb;
 	/*
 	 * All rb_subtree_gap values must be consistent prior to erase,
 	 * with the possible exception of the vma being erased.
@@ -490,7 +507,15 @@ static void vma_rb_erase(struct vm_area_
 	 * so make sure we instantiate it only once with our desired
 	 * augmented rbtree callbacks.
 	 */
+	write_seqlock(&mm->mm_seq);
 	rb_erase_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
+	write_sequnlock(&mm->mm_seq); /* wmb */
+
+	/*
+	 * Ensure the removal is complete before clearing the node.
+	 * Matched by vma_is_dead()/handle_speculative_fault().
+	 */
+	RB_CLEAR_NODE(&vma->vm_rb);
 }
 
 /*
@@ -607,10 +632,12 @@ void __vma_link_rb(struct mm_struct *mm,
 	 * immediately update the gap to the correct value. Finally we
 	 * rebalance the rbtree after all augmented values have been set.
 	 */
+	write_seqlock(&mm->mm_seq);
 	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
 	vma->rb_subtree_gap = 0;
 	vma_gap_update(vma);
-	vma_rb_insert(vma, &mm->mm_rb);
+	vma_rb_insert(vma, mm);
+	write_sequnlock(&mm->mm_seq);
 }
 
 static void __vma_link_file(struct vm_area_struct *vma)
@@ -687,7 +714,7 @@ __vma_unlink(struct mm_struct *mm, struc
 {
 	struct vm_area_struct *next;
 
-	vma_rb_erase(vma, &mm->mm_rb);
+	vma_rb_erase(vma, mm);
 	prev->vm_next = next = vma->vm_next;
 	if (next)
 		next->vm_prev = prev;
@@ -872,15 +899,13 @@ again:			remove_next = 1 + (end > next->
 	}
 
 	if (remove_next) {
-		if (file) {
+		if (file)
 			uprobe_munmap(next, next->vm_start, next->vm_end);
-			fput(file);
-		}
 		if (next->anon_vma)
 			anon_vma_merge(vma, next);
 		mm->map_count--;
 		mpol_put(vma_policy(next));
-		kmem_cache_free(vm_area_cachep, next);
+		free_vma(next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
 		 * we must remove another next too. It would clutter
@@ -2027,16 +2052,11 @@ get_unmapped_area(struct file *file, uns
 EXPORT_SYMBOL(get_unmapped_area);
 
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
-struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
+static struct vm_area_struct *__find_vma(struct mm_struct *mm, unsigned long addr)
 {
 	struct rb_node *rb_node;
 	struct vm_area_struct *vma;
 
-	/* Check the cache first. */
-	vma = vmacache_find(mm, addr);
-	if (likely(vma))
-		return vma;
-
 	rb_node = mm->mm_rb.rb_node;
 	vma = NULL;
 
@@ -2054,13 +2074,41 @@ struct vm_area_struct *find_vma(struct m
 			rb_node = rb_node->rb_right;
 	}
 
+	return vma;
+}
+
+struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
+{
+	struct vm_area_struct *vma;
+
+	/* Check the cache first. */
+	vma = vmacache_find(mm, addr);
+	if (likely(vma))
+		return vma;
+
+	vma = __find_vma(mm, addr);
 	if (vma)
 		vmacache_update(addr, vma);
+
 	return vma;
 }
-
 EXPORT_SYMBOL(find_vma);
 
+struct vm_area_struct *find_vma_srcu(struct mm_struct *mm, unsigned long addr)
+{
+	struct vm_area_struct *vma;
+	unsigned int seq;
+
+	WARN_ON_ONCE(!srcu_read_lock_held(&vma_srcu));
+
+	do {
+		seq = read_seqbegin(&mm->mm_seq);
+		vma = __find_vma(mm, addr);
+	} while (read_seqretry(&mm->mm_seq, seq));
+
+	return vma;
+}
+
 /*
  * Same as find_vma, but also return a pointer to the previous VMA in *pprev.
  */
@@ -2415,7 +2463,7 @@ detach_vmas_to_be_unmapped(struct mm_str
 	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
 	vma->vm_prev = NULL;
 	do {
-		vma_rb_erase(vma, &mm->mm_rb);
+		vma_rb_erase(vma, mm);
 		mm->map_count--;
 		tail_vma = vma;
 		vma = vma->vm_next;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
