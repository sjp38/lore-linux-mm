Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3A283293
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:53:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b19so4600425wmb.8
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 10:53:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t28si2844123wra.269.2017.06.16.10.53.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 10:53:02 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5GHnCkO055832
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:53:01 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b4g5dt0m6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:53:01 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Jun 2017 18:52:59 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v5 07/11] mm: RCU free VMAs
Date: Fri, 16 Jun 2017 19:52:31 +0200
In-Reply-To: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1497635555-25679-8-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

From: Peter Zijlstra <peterz@infradead.org>

Manage the VMAs with SRCU such that we can do a lockless VMA lookup.

We put the fput(vma->vm_file) in the SRCU callback, this keeps files
valid during speculative faults, this is possible due to the delayed
fput work by Al Viro -- do we need srcu_barrier() in unmount
someplace?

We guard the mm_rb tree with a seqlock (this could be a seqcount but
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

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

[Remove the warnings in description about the SRCU global lock which
 has been removed now]
[Rename vma_is_dead() to vma_has_changed()]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm_types.h |   2 +
 kernel/fork.c            |   1 +
 mm/init-mm.c             |   1 +
 mm/internal.h            |  20 ++++++++++
 mm/mmap.c                | 102 ++++++++++++++++++++++++++++++++++-------------
 5 files changed, 99 insertions(+), 27 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 8945743e4609..7da5e565046c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -343,6 +343,7 @@ struct vm_area_struct {
 #endif
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
 	seqcount_t vm_sequence;
+	struct rcu_head vm_rcu_head;
 };
 
 struct core_thread {
@@ -360,6 +361,7 @@ struct kioctx_table;
 struct mm_struct {
 	struct vm_area_struct *mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
+	seqlock_t mm_seq;
 	u32 vmacache_seqnum;                   /* per-thread vmacache */
 #ifdef CONFIG_MMU
 	unsigned long (*get_unmapped_area) (struct file *filp,
diff --git a/kernel/fork.c b/kernel/fork.c
index e53770d2bf95..e4d335bee820 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -793,6 +793,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm->mmap = NULL;
 	mm->mm_rb = RB_ROOT;
 	mm->vmacache_seqnum = 0;
+	seqlock_init(&mm->mm_seq);
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
diff --git a/mm/init-mm.c b/mm/init-mm.c
index 975e49f00f34..2b1fa061684f 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -16,6 +16,7 @@
 
 struct mm_struct init_mm = {
 	.mm_rb		= RB_ROOT,
+	.mm_seq		= __SEQLOCK_UNLOCKED(init_mm.mm_seq),
 	.pgd		= swapper_pg_dir,
 	.mm_users	= ATOMIC_INIT(2),
 	.mm_count	= ATOMIC_INIT(1),
diff --git a/mm/internal.h b/mm/internal.h
index 0e4f558412fb..3c6041d53310 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -40,6 +40,26 @@ void page_writeback_init(void);
 
 int do_swap_page(struct vm_fault *vmf);
 
+extern struct srcu_struct vma_srcu;
+
+extern struct vm_area_struct *find_vma_srcu(struct mm_struct *mm,
+					    unsigned long addr);
+
+static inline bool vma_has_changed(struct vm_area_struct *vma,
+				   unsigned int sequence)
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
 
diff --git a/mm/mmap.c b/mm/mmap.c
index b48bbe6a49c6..c4a1e1aecef3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -159,6 +159,23 @@ void unlink_file_vma(struct vm_area_struct *vma)
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
@@ -169,10 +186,8 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
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
 
@@ -396,26 +411,37 @@ static void vma_gap_update(struct vm_area_struct *vma)
 }
 
 static inline void vma_rb_insert(struct vm_area_struct *vma,
-				 struct rb_root *root)
+				 struct mm_struct *mm)
 {
+	struct rb_root *root = &mm->mm_rb;
+
 	/* All rb_subtree_gap values must be consistent prior to insertion */
 	validate_mm_rb(root, NULL);
 
 	rb_insert_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
 }
 
-static void __vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
+static void __vma_rb_erase(struct vm_area_struct *vma, struct mm_struct *mm)
 {
+	struct rb_root *root = &mm->mm_rb;
 	/*
 	 * Note rb_erase_augmented is a fairly large inline function,
 	 * so make sure we instantiate it only once with our desired
 	 * augmented rbtree callbacks.
 	 */
+	write_seqlock(&mm->mm_seq);
 	rb_erase_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
+	write_sequnlock(&mm->mm_seq); /* wmb */
+
+	/*
+	 * Ensure the removal is complete before clearing the node.
+	 * Matched by vma_has_changed()/handle_speculative_fault().
+	 */
+	RB_CLEAR_NODE(&vma->vm_rb);
 }
 
 static __always_inline void vma_rb_erase_ignore(struct vm_area_struct *vma,
-						struct rb_root *root,
+						struct mm_struct *mm,
 						struct vm_area_struct *ignore)
 {
 	/*
@@ -423,21 +449,21 @@ static __always_inline void vma_rb_erase_ignore(struct vm_area_struct *vma,
 	 * with the possible exception of the "next" vma being erased if
 	 * next->vm_start was reduced.
 	 */
-	validate_mm_rb(root, ignore);
+	validate_mm_rb(&mm->mm_rb, ignore);
 
-	__vma_rb_erase(vma, root);
+	__vma_rb_erase(vma, mm);
 }
 
 static __always_inline void vma_rb_erase(struct vm_area_struct *vma,
-					 struct rb_root *root)
+					 struct mm_struct *mm)
 {
 	/*
 	 * All rb_subtree_gap values must be consistent prior to erase,
 	 * with the possible exception of the vma being erased.
 	 */
-	validate_mm_rb(root, vma);
+	validate_mm_rb(&mm->mm_rb, vma);
 
-	__vma_rb_erase(vma, root);
+	__vma_rb_erase(vma, mm);
 }
 
 /*
@@ -554,10 +580,12 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
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
@@ -633,7 +661,7 @@ static __always_inline void __vma_unlink_common(struct mm_struct *mm,
 {
 	struct vm_area_struct *next;
 
-	vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
+	vma_rb_erase_ignore(vma, mm, ignore);
 	next = vma->vm_next;
 	if (has_prev)
 		prev->vm_next = next;
@@ -886,21 +914,19 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
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
-		write_seqcount_end(&next->vm_sequence);
+		free_vma(next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
 		 * we must remove another next too. It would clutter
 		 * up the code too much to do both in one go.
 		 */
+		write_seqcount_end(&next->vm_sequence);
 		if (remove_next != 3) {
 			/*
 			 * If "next" was removed and vma->vm_end was
@@ -2111,15 +2137,10 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 EXPORT_SYMBOL(get_unmapped_area);
 
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
-struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
+static struct vm_area_struct *__find_vma(struct mm_struct *mm, unsigned long addr)
 {
 	struct rb_node *rb_node;
-	struct vm_area_struct *vma;
-
-	/* Check the cache first. */
-	vma = vmacache_find(mm, addr);
-	if (likely(vma))
-		return vma;
+	struct vm_area_struct *vma = NULL;
 
 	rb_node = mm->mm_rb.rb_node;
 
@@ -2137,13 +2158,40 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
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
@@ -2498,7 +2546,7 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
 	vma->vm_prev = NULL;
 	do {
-		vma_rb_erase(vma, &mm->mm_rb);
+		vma_rb_erase(vma, mm);
 		mm->map_count--;
 		tail_vma = vma;
 		vma = vma->vm_next;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
