Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C73A6B026B
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 06:08:28 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l85so17979086qkh.19
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 03:08:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q65si6184787qkb.189.2017.10.09.03.08.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 03:08:27 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v99A3bmj073738
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 06:08:26 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dg3jd0xhr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Oct 2017 06:08:25 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 9 Oct 2017 11:08:22 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v4 06/20] mm: RCU free VMAs
Date: Mon,  9 Oct 2017 12:07:38 +0200
In-Reply-To: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1507543672-25821-7-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

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
[Rename vma_is_dead() to vma_has_changed() and move its adding to the next
 patch]
[Postpone call to mpol_put() as the policy can be used during the
 speculative path]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

mm/spf: Fix policy free
---
 include/linux/mm_types.h |   2 +
 kernel/fork.c            |   1 +
 mm/init-mm.c             |   1 +
 mm/internal.h            |   5 +++
 mm/mmap.c                | 103 ++++++++++++++++++++++++++++++++++-------------
 5 files changed, 84 insertions(+), 28 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 6736feb8cb28..84830c26092f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -349,6 +349,7 @@ struct vm_area_struct {
 #ifdef __HAVE_ARCH_CALL_SPF
 	seqcount_t vm_sequence;
 #endif
+	struct rcu_head vm_rcu_head;
 } __randomize_layout;
 
 struct core_thread {
@@ -366,6 +367,7 @@ struct kioctx_table;
 struct mm_struct {
 	struct vm_area_struct *mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
+	seqlock_t mm_seq;
 	u32 vmacache_seqnum;                   /* per-thread vmacache */
 #ifdef CONFIG_MMU
 	unsigned long (*get_unmapped_area) (struct file *filp,
diff --git a/kernel/fork.c b/kernel/fork.c
index 778fbe83829b..792788384be1 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -900,6 +900,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
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
index 1df011f62480..aced97623bff 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -40,6 +40,11 @@ void page_writeback_init(void);
 
 int do_swap_page(struct vm_fault *vmf);
 
+extern struct srcu_struct vma_srcu;
+
+extern struct vm_area_struct *find_vma_srcu(struct mm_struct *mm,
+					    unsigned long addr);
+
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 83ac0b69b32d..79152d094403 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -160,6 +160,24 @@ void unlink_file_vma(struct vm_area_struct *vma)
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
+	mpol_put(vma_policy(vma));
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
@@ -170,10 +188,7 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	might_sleep();
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
-	if (vma->vm_file)
-		fput(vma->vm_file);
-	mpol_put(vma_policy(vma));
-	kmem_cache_free(vm_area_cachep, vma);
+	free_vma(vma);
 	return next;
 }
 
@@ -411,26 +426,37 @@ static void vma_gap_update(struct vm_area_struct *vma)
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
@@ -438,21 +464,21 @@ static __always_inline void vma_rb_erase_ignore(struct vm_area_struct *vma,
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
@@ -571,10 +597,12 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
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
@@ -650,7 +678,7 @@ static __always_inline void __vma_unlink_common(struct mm_struct *mm,
 {
 	struct vm_area_struct *next;
 
-	vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
+	vma_rb_erase_ignore(vma, mm, ignore);
 	next = vma->vm_next;
 	if (has_prev)
 		prev->vm_next = next;
@@ -923,15 +951,12 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
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
-		mpol_put(vma_policy(next));
-		kmem_cache_free(vm_area_cachep, next);
+		free_vma(next);
 		vm_raw_write_end(next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
@@ -2151,15 +2176,10 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
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
 
@@ -2177,13 +2197,40 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
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
@@ -2551,7 +2598,7 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
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
