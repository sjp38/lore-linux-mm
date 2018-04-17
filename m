Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B65C6B002C
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:44 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t24so12525534qtn.21
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:34:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x75si12132727qkx.274.2018.04.17.07.34.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:34:42 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3HEXiMc009062
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:41 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hdjjc8x1k-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:41 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 15:34:38 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v10 17/25] mm: protect mm_rb tree with a rwlock
Date: Tue, 17 Apr 2018 16:33:23 +0200
In-Reply-To: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523975611-15978-18-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

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
 include/linux/mm.h       |   1 +
 include/linux/mm_types.h |   4 ++
 kernel/fork.c            |   3 ++
 mm/init-mm.c             |   3 ++
 mm/internal.h            |   6 +++
 mm/mmap.c                | 115 +++++++++++++++++++++++++++++++++++------------
 6 files changed, 104 insertions(+), 28 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f967bf84094f..e2c24ea58d94 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1272,6 +1272,7 @@ static inline void INIT_VMA(struct vm_area_struct *vma)
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 #ifdef CONFIG_SPECULATIVE_PAGE_FAULT
 	seqcount_init(&vma->vm_sequence);
+	atomic_set(&vma->vm_ref_count, 1);
 #endif
 }
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index db5e9d630e7a..faf3844dd815 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -337,6 +337,7 @@ struct vm_area_struct {
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
 #ifdef CONFIG_SPECULATIVE_PAGE_FAULT
 	seqcount_t vm_sequence;
+	atomic_t vm_ref_count;		/* see vma_get(), vma_put() */
 #endif
 } __randomize_layout;
 
@@ -355,6 +356,9 @@ struct kioctx_table;
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
index d937e5945f77..9f8d235a3df8 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -891,6 +891,9 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
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
index 5601f1ef8bb9..a82950960f2e 100644
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
@@ -567,10 +604,12 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * immediately update the gap to the correct value. Finally we
 	 * rebalance the rbtree after all augmented values have been set.
 	 */
+	mm_rb_write_lock(mm);
 	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
 	vma->rb_subtree_gap = 0;
 	vma_gap_update(vma);
-	vma_rb_insert(vma, &mm->mm_rb);
+	vma_rb_insert(vma, mm);
+	mm_rb_write_unlock(mm);
 }
 
 static void __vma_link_file(struct vm_area_struct *vma)
@@ -646,7 +685,7 @@ static __always_inline void __vma_unlink_common(struct mm_struct *mm,
 {
 	struct vm_area_struct *next;
 
-	vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
+	vma_rb_erase_ignore(vma, mm, ignore);
 	next = vma->vm_next;
 	if (has_prev)
 		prev->vm_next = next;
@@ -923,16 +962,13 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
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
@@ -2190,15 +2226,11 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
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
 
@@ -2216,13 +2248,40 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
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
@@ -2590,7 +2649,7 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
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
