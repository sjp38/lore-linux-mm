Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 0D4B16B0070
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:21:20 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ro12so9747862pbb.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 02:21:20 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 7/7] mm: avoid taking rmap locks in move_ptes()
Date: Tue,  4 Sep 2012 02:20:57 -0700
Message-Id: <1346750457-12385-8-git-send-email-walken@google.com>
In-Reply-To: <1346750457-12385-1-git-send-email-walken@google.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org

During mremap(), the destination VMA is generally placed after the
original vma in rmap traversal order: in move_vma(), we always have
new_pgoff >= vma->vm_pgoff, and as a result new_vma->vm_pgoff >=
vma->vm_pgoff unless vma_merge() merged the new vma with an adjacent
one.

When the destination VMA is placed after the original in rmap
traversal order, we can avoid taking the rmap locks in move_ptes().

Essentially, this reintroduces the optimization that had been disabled
in "mm anon rmap: remove anon_vma_moveto_tail". The difference is that
we don't try to impose the rmap traversal order; instead we just rely
on things being in the desired order in the common case and fall back
to taking locks in the uncommon case. Also we skip the i_mmap_mutex in
addition to the anon_vma lock: in both cases, the vmas are traversed in
increasing vm_pgoff order with ties resolved in tree insertion order.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 fs/exec.c          |    2 +-
 include/linux/mm.h |    6 +++-
 mm/mmap.c          |    7 ++++-
 mm/mremap.c        |   57 +++++++++++++++++++++++++++++++++++----------------
 4 files changed, 49 insertions(+), 23 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index da27b91ff1e8..f7b4009ea327 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -613,7 +613,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
 	 * process cleanup to remove whatever mess we made.
 	 */
 	if (length != move_page_tables(vma, old_start,
-				       vma, new_start, length))
+				       vma, new_start, length, false))
 		return -ENOMEM;
 
 	lru_add_drain();
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1a2b1a44bd4e..c6a6b0b0f176 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1042,7 +1042,8 @@ vm_is_stack(struct task_struct *task, struct vm_area_struct *vma, int in_group);
 
 extern unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
-		unsigned long new_addr, unsigned long len);
+		unsigned long new_addr, unsigned long len,
+		bool need_rmap_locks);
 extern unsigned long do_mremap(unsigned long addr,
 			       unsigned long old_len, unsigned long new_len,
 			       unsigned long flags, unsigned long new_addr);
@@ -1391,7 +1392,8 @@ extern void __vma_link_rb(struct mm_struct *, struct vm_area_struct *,
 	struct rb_node **, struct rb_node *);
 extern void unlink_file_vma(struct vm_area_struct *);
 extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
-	unsigned long addr, unsigned long len, pgoff_t pgoff);
+	unsigned long addr, unsigned long len, pgoff_t pgoff,
+	bool *need_rmap_locks);
 extern void exit_mmap(struct mm_struct *);
 
 extern int mm_take_all_locks(struct mm_struct *mm);
diff --git a/mm/mmap.c b/mm/mmap.c
index 884bda4cd3ea..cc8c64077a42 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2397,7 +2397,8 @@ int insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
  * prior to moving page table entries, to effect an mremap move.
  */
 struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
-	unsigned long addr, unsigned long len, pgoff_t pgoff)
+	unsigned long addr, unsigned long len, pgoff_t pgoff,
+	bool *need_rmap_locks)
 {
 	struct vm_area_struct *vma = *vmap;
 	unsigned long vma_start = vma->vm_start;
@@ -2438,8 +2439,9 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			 * linear if there are no pages mapped yet.
 			 */
 			VM_BUG_ON(faulted_in_anon_vma);
-			*vmap = new_vma;
+			*vmap = vma = new_vma;
 		}
+		*need_rmap_locks = (new_vma->vm_pgoff <= vma->vm_pgoff);
 	} else {
 		new_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 		if (new_vma) {
@@ -2466,6 +2468,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
 			vma_link(mm, new_vma, prev, rb_link, rb_parent);
+			*need_rmap_locks = false;
 		}
 	}
 	return new_vma;
diff --git a/mm/mremap.c b/mm/mremap.c
index 95fb2e024ced..d18cdf09868c 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -71,26 +71,42 @@ static pmd_t *alloc_new_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
 static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		unsigned long old_addr, unsigned long old_end,
 		struct vm_area_struct *new_vma, pmd_t *new_pmd,
-		unsigned long new_addr)
+		unsigned long new_addr, bool need_rmap_locks)
 {
 	struct address_space *mapping = NULL;
-	struct anon_vma *anon_vma = vma->anon_vma;
+	struct anon_vma *anon_vma = NULL;
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *old_pte, *new_pte, pte;
 	spinlock_t *old_ptl, *new_ptl;
 
-	if (vma->vm_file) {
-		/*
-		 * Subtle point from Rajesh Venkatasubramanian: before
-		 * moving file-based ptes, we must lock truncate_pagecache
-		 * out, since it might clean the dst vma before the src vma,
-		 * and we propagate stale pages into the dst afterward.
-		 */
-		mapping = vma->vm_file->f_mapping;
-		mutex_lock(&mapping->i_mmap_mutex);
+	/*
+	 * When need_rmap_locks is true, we take the i_mmap_mutex and anon_vma
+	 * locks to ensure that rmap will always observe either the old or the
+	 * new ptes. This is the easiest way to avoid races with
+	 * truncate_pagecache(), page migration, etc...
+	 *
+	 * When need_rmap_locks is false, we use other ways to avoid
+	 * such races:
+	 *
+	 * - During exec() shift_arg_pages(), we use a specially tagged vma
+	 *   which rmap call sites look for using is_vma_temporary_stack().
+	 *
+	 * - During mremap(), new_vma is often known to be placed after vma
+	 *   in rmap traversal order. This ensures rmap will always observe
+	 *   either the old pte, or the new pte, or both (the page table locks
+	 *   serialize access to individual ptes, but only rmap traversal
+	 *   order guarantees that we won't miss both the old and new ptes).
+	 */
+	if (need_rmap_locks) {
+		if (vma->vm_file) {
+			mapping = vma->vm_file->f_mapping;
+			mutex_lock(&mapping->i_mmap_mutex);
+		}
+		if (vma->anon_vma) {
+			anon_vma = vma->anon_vma;
+			anon_vma_lock(anon_vma);
+		}
 	}
-	if (anon_vma)
-		anon_vma_lock(anon_vma);
 
 	/*
 	 * We don't have to worry about the ordering of src and dst
@@ -127,7 +143,8 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 
 unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
-		unsigned long new_addr, unsigned long len)
+		unsigned long new_addr, unsigned long len,
+		bool need_rmap_locks)
 {
 	unsigned long extent, next, old_end;
 	pmd_t *old_pmd, *new_pmd;
@@ -174,7 +191,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 		if (extent > LATENCY_LIMIT)
 			extent = LATENCY_LIMIT;
 		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
-				new_vma, new_pmd, new_addr);
+			  new_vma, new_pmd, new_addr, need_rmap_locks);
 		need_flush = true;
 	}
 	if (likely(need_flush))
@@ -198,6 +215,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	unsigned long hiwater_vm;
 	int split = 0;
 	int err;
+	bool need_rmap_locks;
 
 	/*
 	 * We'd prefer to avoid failure later on in do_munmap:
@@ -219,18 +237,21 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		return err;
 
 	new_pgoff = vma->vm_pgoff + ((old_addr - vma->vm_start) >> PAGE_SHIFT);
-	new_vma = copy_vma(&vma, new_addr, new_len, new_pgoff);
+	new_vma = copy_vma(&vma, new_addr, new_len, new_pgoff,
+			   &need_rmap_locks);
 	if (!new_vma)
 		return -ENOMEM;
 
-	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len);
+	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len,
+				     need_rmap_locks);
 	if (moved_len < old_len) {
 		/*
 		 * On error, move entries back from new area to old,
 		 * which will succeed since page tables still there,
 		 * and then proceed to unmap new area instead of old.
 		 */
-		move_page_tables(new_vma, new_addr, vma, old_addr, moved_len);
+		move_page_tables(new_vma, new_addr, vma, old_addr, moved_len,
+				 true);
 		vma = new_vma;
 		old_len = new_len;
 		old_addr = new_addr;
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
