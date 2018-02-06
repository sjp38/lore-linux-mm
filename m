Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 011606B025F
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 11:51:00 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id d131so1508048qkc.16
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 08:50:59 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o72si1260262qke.441.2018.02.06.08.50.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 08:50:58 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w16Gn3fx135626
	for <linux-mm@kvack.org>; Tue, 6 Feb 2018 11:50:58 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fyce3ma2e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Feb 2018 11:50:57 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 6 Feb 2018 16:50:55 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v7 17/24] mm: Protect mm_rb tree with a rwlock
Date: Tue,  6 Feb 2018 17:50:03 +0100
In-Reply-To: <1517935810-31177-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1517935810-31177-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1517935810-31177-18-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

This change is inspired by the Peter's proposal patch [1] which was
protecting the VMA using SRCU. Unfortunately, SRCU is not scaling well in
that particular case, and it is introducing major performance degradation
due to excessive scheduling operations.

To allow access to the mm_rb tree without grabbing the mmap_sem, this patch
is protecting it access using a rwlock.  As the mm_rb tree is a O(log n)
search it is safe to protect it using such a lock.  The VMA cache is not
protected by the new rwlock and it should not be used without holding the
mmap_sem.

To allow the picked VMA structure to be used once the rwlock is released, a
use count is added to the VMA structure. When the VMA is allocated it is
set to 1.  Each time the VMA is picked with the rwlock held its use count
is incremented. Each time the VMA is released it is decremented. When the
use count hits zero, this means that the VMA is no more used and should be
freed.

This patch is preparing for 2 kind of VMA access :
 - as usual, under the control of the mmap_sem,
 - without holding the mmap_sem for the speculative page fault handler.

Access done under the control the mmap_sem doesn't require to grab the
rwlock to protect read access to the mm_rb tree, but access in write must
be done under the protection of the rwlock too. This affects inserting and
removing of elements in the RB tree.

The patch is introducing 2 new functions:
 - vma_get() to find a VMA based on an address by holding the new rwlock.
 - vma_put() to release the VMA when its no more used.
These services are designed to be used when access are made to the RB tree
without holding the mmap_sem.

When a VMA is removed from the RB tree, its vma->vm_rb field is cleared and
we rely on the WMB done when releasing the rwlock to serialize the write
with the RMB done in a later patch to check for the VMA's validity.

When free_vma is called, the file associated with the VMA is closed
immediately, but the policy and the file structure remained in used until
the VMA's use count reach 0, which may happens later when exiting an
in progress speculative page fault.

[1] https://patchwork.kernel.org/patch/5108281/

Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm_types.h |   4 ++
 kernel/fork.c            |   3 ++
 mm/init-mm.c             |   3 ++
 mm/internal.h            |   6 +++
 mm/mmap.c                | 122 ++++++++++++++++++++++++++++++++++-------------
 5 files changed, 106 insertions(+), 32 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 34fde7111e88..28c763ea1036 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -335,6 +335,7 @@ struct vm_area_struct {
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
 #ifdef CONFIG_SPECULATIVE_PAGE_FAULT
 	seqcount_t vm_sequence;
+	atomic_t vm_ref_count;		/* see vma_get(), vma_put() */
 #endif
 } __randomize_layout;
 
@@ -353,6 +354,9 @@ struct kioctx_table;
 struct mm_struct {
 	struct vm_area_struct *mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	rwlock_t mm_rb_lock;
+#endif
 	u32 vmacache_seqnum;                   /* per-thread vmacache */
 #ifdef CONFIG_MMU
 	unsigned long (*get_unmapped_area) (struct file *filp,
diff --git a/kernel/fork.c b/kernel/fork.c
index 0914307d4f3b..22eb30807d0c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -898,6 +898,9 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm->mmap = NULL;
 	mm->mm_rb = RB_ROOT;
 	mm->vmacache_seqnum = 0;
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	rwlock_init(&mm->mm_rb_lock);
+#endif
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
diff --git a/mm/init-mm.c b/mm/init-mm.c
index f94d5d15ebc0..e71ac37a98c4 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -17,6 +17,9 @@
 
 struct mm_struct init_mm = {
 	.mm_rb		= RB_ROOT,
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	.mm_rb_lock	= __RW_LOCK_UNLOCKED(init_mm.mm_rb_lock),
+#endif
 	.pgd		= swapper_pg_dir,
 	.mm_users	= ATOMIC_INIT(2),
 	.mm_count	= ATOMIC_INIT(1),
diff --git a/mm/internal.h b/mm/internal.h
index 62d8c34e63d5..fb2667b20f0a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -40,6 +40,12 @@ void page_writeback_init(void);
 
 int do_swap_page(struct vm_fault *vmf);
 
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+extern struct vm_area_struct *get_vma(struct mm_struct *mm,
+				      unsigned long addr);
+extern void put_vma(struct vm_area_struct *vma);
+#endif
+
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 13c799710a8a..220ba8cb65fc 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -160,6 +160,27 @@ void unlink_file_vma(struct vm_area_struct *vma)
 	}
 }
 
+static void __free_vma(struct vm_area_struct *vma)
+{
+	if (vma->vm_file)
+		fput(vma->vm_file);
+	mpol_put(vma_policy(vma));
+	kmem_cache_free(vm_area_cachep, vma);
+}
+
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+void put_vma(struct vm_area_struct *vma)
+{
+	if (atomic_dec_and_test(&vma->vm_ref_count))
+		__free_vma(vma);
+}
+#else
+static inline void put_vma(struct vm_area_struct *vma)
+{
+	return __free_vma(vma);
+}
+#endif
+
 /*
  * Close a vm structure and free it, returning the next.
  */
@@ -170,10 +191,7 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	might_sleep();
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
-	if (vma->vm_file)
-		fput(vma->vm_file);
-	mpol_put(vma_policy(vma));
-	kmem_cache_free(vm_area_cachep, vma);
+	put_vma(vma);
 	return next;
 }
 
@@ -393,6 +411,14 @@ static void validate_mm(struct mm_struct *mm)
 #define validate_mm(mm) do { } while (0)
 #endif
 
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+#define mm_rb_write_lock(mm)	write_lock(&(mm)->mm_rb_lock)
+#define mm_rb_write_unlock(mm)	write_unlock(&(mm)->mm_rb_lock)
+#else
+#define mm_rb_write_lock(mm)	do { } while (0)
+#define mm_rb_write_unlock(mm)	do { } while (0)
+#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
+
 RB_DECLARE_CALLBACKS(static, vma_gap_callbacks, struct vm_area_struct, vm_rb,
 		     unsigned long, rb_subtree_gap, vma_compute_subtree_gap)
 
@@ -411,26 +437,37 @@ static void vma_gap_update(struct vm_area_struct *vma)
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
+	mm_rb_write_lock(mm);
 	rb_erase_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
+	mm_rb_write_unlock(mm); /* wmb */
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
@@ -438,21 +475,21 @@ static __always_inline void vma_rb_erase_ignore(struct vm_area_struct *vma,
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
@@ -558,10 +595,6 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 	else
 		mm->highest_vm_end = vm_end_gap(vma);
 
-#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
-	seqcount_init(&vma->vm_sequence);
-#endif
-
 	/*
 	 * vma->vm_prev wasn't known when we followed the rbtree to find the
 	 * correct insertion point for that vma. As a result, we could not
@@ -571,10 +604,15 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * immediately update the gap to the correct value. Finally we
 	 * rebalance the rbtree after all augmented values have been set.
 	 */
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	atomic_set(&vma->vm_ref_count, 1);
+#endif
+	mm_rb_write_lock(mm);
 	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
 	vma->rb_subtree_gap = 0;
 	vma_gap_update(vma);
-	vma_rb_insert(vma, &mm->mm_rb);
+	vma_rb_insert(vma, mm);
+	mm_rb_write_unlock(mm);
 }
 
 static void __vma_link_file(struct vm_area_struct *vma)
@@ -650,7 +688,7 @@ static __always_inline void __vma_unlink_common(struct mm_struct *mm,
 {
 	struct vm_area_struct *next;
 
-	vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
+	vma_rb_erase_ignore(vma, mm, ignore);
 	next = vma->vm_next;
 	if (has_prev)
 		prev->vm_next = next;
@@ -923,16 +961,13 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
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
 		vm_raw_write_end(next);
-		kmem_cache_free(vm_area_cachep, next);
+		put_vma(next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
 		 * we must remove another next too. It would clutter
@@ -2182,15 +2217,11 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 EXPORT_SYMBOL(get_unmapped_area);
 
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
-struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
+static struct vm_area_struct *__find_vma(struct mm_struct *mm,
+					 unsigned long addr)
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
 
@@ -2208,13 +2239,40 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
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
 
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+struct vm_area_struct *get_vma(struct mm_struct *mm, unsigned long addr)
+{
+	struct vm_area_struct *vma = NULL;
+
+	read_lock(&mm->mm_rb_lock);
+	vma = __find_vma(mm, addr);
+	if (vma)
+		atomic_inc(&vma->vm_ref_count);
+	read_unlock(&mm->mm_rb_lock);
+
+	return vma;
+}
+#endif
+
 /*
  * Same as find_vma, but also return a pointer to the previous VMA in *pprev.
  */
@@ -2582,7 +2640,7 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
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
