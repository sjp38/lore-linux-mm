Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 45E2E6B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 15:44:04 -0500 (EST)
Date: Thu, 14 Jan 2010 15:42:08 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [RFC PATCH -mm] change anon_vma linking to fix multi-process server
 scalability issue
Message-ID: <20100114154208.7deb0689@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, lwoodman@redhat.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nhorman@redhat.com, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

The old anon_vma code can lead to scalability issues with heavily
forking workloads.  Specifically, each anon_vma will be shared
between the parent process and all its child processes.

In a workload with 1000 child processes and a VMA with 1000 anonymous
pages per process that get COWed, this leads to a system with a million
anonymous pages in the same anon_vma, each of which is mapped in just
one of the 1000 processes.  However, the current rmap code needs to
walk them all, leading to O(N) scanning complexity for each page.

This can result in systems where one CPU is walking the page tables
of 1000 processes in page_referenced_one, while all other CPUs are
stuck on the anon_vma lock.  This leads to catastrophic failure for
a benchmark like AIM7, where the total number of processes can reach
in the tens of thousands.  Real workloads are still a factor 10 less
process intensive than AIM7, but they are catching up.

This patch changes the way anon_vmas and VMAs are linked, which
allows us to associate multiple anon_vmas with a VMA.  At fork
time, each child process gets its own anon_vmas, in which its
COWed pages will be instantiated.  The parents' anon_vma is also
linked to the VMA, because non-COWed pages could be present in
any of the children.

This reduces rmap scanning complexity to O(1) for the pages of
the 1000 child processes, with O(N) complexity for at most 1/N
pages in the system.  This reduces the average scanning cost in
heavily forking workloads from O(N) to 2.

The only real complexity in this patch stems from the fact that
linking a VMA to anon_vmas now involves memory allocations. This
means vma_adjust can fail, if it needs to attach a VMA to anon_vma
structures. This in turn means error handling needs to be added
to the calling functions.

A second source of complexity is that, because there can be
multiple anon_vmas, the anon_vma linking in vma_adjust can
no longer be done under "the" anon_vma lock.  To prevent the
rmap code from walking up an incomplete VMA, this patch
introduces the VM_LOCK_RMAP VMA flag.  This bit flag uses
the same slot as the NOMMU VM_MAPPED_COPY, with an ifdef
in mm.h to make sure it is impossible to compile a kernel
that needs both symbolic values for the same bitflag.

Signed-off-by: Rik van Riel <riel@redhat.com>

--- 
Note: this version of the patch still contains a bug that causes
early userspace to segfault.  I am mailing this patch out to get
early feedback and because this could be the kind of bug that I
stare myself blind on for 3 days, but somebody else spots in 5
minutes.

diff --git a/arch/ia64/ia32/binfmt_elf32.c b/arch/ia64/ia32/binfmt_elf32.c
index c69552b..d5acd08 100644
--- a/arch/ia64/ia32/binfmt_elf32.c
+++ b/arch/ia64/ia32/binfmt_elf32.c
@@ -89,6 +89,7 @@ ia64_elf32_init (struct pt_regs *regs)
 	 */
 	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (vma) {
+		LIST_HEAD_INIT(&vma->anon_vma_chain);
 		vma->vm_mm = current->mm;
 		vma->vm_start = IA32_GDT_OFFSET;
 		vma->vm_end = vma->vm_start + PAGE_SIZE;
@@ -114,6 +115,7 @@ ia64_elf32_init (struct pt_regs *regs)
 	 */
 	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (vma) {
+		LIST_HEAD_INIT(&vma->anon_vma_chain);
 		vma->vm_mm = current->mm;
 		vma->vm_start = IA32_GATE_OFFSET;
 		vma->vm_end = vma->vm_start + PAGE_SIZE;
@@ -138,6 +140,7 @@ ia64_elf32_init (struct pt_regs *regs)
 	 */
 	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (vma) {
+		LIST_HEAD_INIT(&vma->anon_vma_chain);
 		vma->vm_mm = current->mm;
 		vma->vm_start = IA32_LDT_OFFSET;
 		vma->vm_end = vma->vm_start + PAGE_ALIGN(IA32_LDT_ENTRIES*IA32_LDT_ENTRY_SIZE);
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index a97f838..9e74dbb 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2314,6 +2314,7 @@ pfm_smpl_buffer_alloc(struct task_struct *task, struct file *filp, pfm_context_t
 		DPRINT(("Cannot allocate vma\n"));
 		goto error_kmem;
 	}
+	LIST_HEAD_INIT(&vma->anon_vma_chain);
 
 	/*
 	 * partially initialize the vma for the sampling buffer
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 7c0d481..c8bc02a 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -118,6 +118,7 @@ ia64_init_addr_space (void)
 	 */
 	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (vma) {
+		LIST_HEAD_INIT(&vma->anon_vma_chain);
 		vma->vm_mm = current->mm;
 		vma->vm_start = current->thread.rbs_bot & PAGE_MASK;
 		vma->vm_end = vma->vm_start + PAGE_SIZE;
@@ -136,6 +137,7 @@ ia64_init_addr_space (void)
 	if (!(current->personality & MMAP_PAGE_ZERO)) {
 		vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 		if (vma) {
+			LIST_HEAD_INIT(&vma->anon_vma_chain);
 			vma->vm_mm = current->mm;
 			vma->vm_end = PAGE_SIZE;
 			vma->vm_page_prot = __pgprot(pgprot_val(PAGE_READONLY) | _PAGE_MA_NAT);
diff --git a/fs/exec.c b/fs/exec.c
index 271c557..7f4b84a 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -246,6 +246,7 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	vma->vm_start = vma->vm_end - PAGE_SIZE;
 	vma->vm_flags = VM_STACK_FLAGS;
 	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
+	INIT_LIST_HEAD(&vma->anon_vma_chain);
 	err = insert_vm_struct(mm, vma);
 	if (err)
 		goto err;
@@ -516,7 +517,8 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
 	/*
 	 * cover the whole range: [new_start, old_end)
 	 */
-	vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL);
+	if (vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL))
+		return -ENOMEM;
 
 	/*
 	 * move the page tables downwards, on failure we rely on
@@ -549,7 +551,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
 	/*
 	 * shrink the vma to just the new range.
 	 */
-	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
+	BUG_ON(vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL));
 
 	return 0;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index be7f851..93bbb70 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -96,7 +96,11 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
 #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
+#ifdef CONFIG_MMU
+#define VM_LOCK_RMAP	0x01000000	/* Do not follow this rmap (mmu mmap) */
+#else
 #define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
+#endif
 #define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
 #define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */
 
@@ -1108,7 +1112,7 @@ static inline void vma_nonlinear_insert(struct vm_area_struct *vma,
 
 /* mmap.c */
 extern int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin);
-extern void vma_adjust(struct vm_area_struct *vma, unsigned long start,
+extern int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert);
 extern struct vm_area_struct *vma_merge(struct mm_struct *,
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 84a524a..44cfb13 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -167,7 +167,7 @@ struct vm_area_struct {
 	 * can only be in the i_mmap tree.  An anonymous MAP_PRIVATE, stack
 	 * or brk vma (with NULL file) can only be in an anon_vma list.
 	 */
-	struct list_head anon_vma_node;	/* Serialized by anon_vma->lock */
+	struct list_head anon_vma_chain; /* Serialized by anon_vma->lock */
 	struct anon_vma *anon_vma;	/* Serialized by page_table_lock */
 
 	/* Function pointers to deal with this struct. */
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index b019ae6..0d1903a 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -37,7 +37,27 @@ struct anon_vma {
 	 * is serialized by a system wide lock only visible to
 	 * mm_take_all_locks() (mm_all_locks_mutex).
 	 */
-	struct list_head head;	/* List of private "related" vmas */
+	struct list_head head;	/* Chain of private "related" vmas */
+};
+
+/*
+ * The copy-on-write semantics of fork mean that an anon_vma
+ * can become associated with multiple processes. Furthermore,
+ * each child process will have its own anon_vma, where new
+ * pages for that process are instantiated.
+ *
+ * This structure allows us to find the anon_vmas associated
+ * with a VMA, or the VMAs associated with an anon_vma.
+ * The "same_vma" list contains the anon_vma_chains linking
+ * all the anon_vmas associated with this VMA.
+ * The "same_anon_vma" list contains the anon_vma_chains
+ * which link all the VMAs associated with this anon_vma.
+ */
+struct anon_vma_chain {
+	struct vm_area_struct *vma;
+	struct anon_vma *anon_vma;
+	struct list_head same_vma;	/* locked by mmap_sem & friends */
+	struct list_head same_anon_vma;	/* locked by anon_vma->lock */
 };
 
 #ifdef CONFIG_MMU
@@ -89,12 +109,19 @@ static inline void anon_vma_unlock(struct vm_area_struct *vma)
  */
 void anon_vma_init(void);	/* create anon_vma_cachep */
 int  anon_vma_prepare(struct vm_area_struct *);
-void __anon_vma_merge(struct vm_area_struct *, struct vm_area_struct *);
-void anon_vma_unlink(struct vm_area_struct *);
-void anon_vma_link(struct vm_area_struct *);
+void unlink_anon_vmas(struct vm_area_struct *);
+int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
+int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
 void __anon_vma_link(struct vm_area_struct *);
 void anon_vma_free(struct anon_vma *);
 
+static inline void anon_vma_merge(struct vm_area_struct *vma,
+				  struct vm_area_struct *next)
+{
+	BUG_ON(vma->anon_vma != next->anon_vma);
+	unlink_anon_vmas(next);
+}
+
 /*
  * rmap interfaces called when adding or removing pte of page
  */
diff --git a/kernel/fork.c b/kernel/fork.c
index 404e6ca..e58f905 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -328,15 +328,17 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		if (!tmp)
 			goto fail_nomem;
 		*tmp = *mpnt;
+		INIT_LIST_HEAD(&tmp->anon_vma_chain);
 		pol = mpol_dup(vma_policy(mpnt));
 		retval = PTR_ERR(pol);
 		if (IS_ERR(pol))
 			goto fail_nomem_policy;
 		vma_set_policy(tmp, pol);
+		if (anon_vma_fork(tmp, mpnt))
+			goto fail_nomem_anon_vma_fork;
 		tmp->vm_flags &= ~VM_LOCKED;
 		tmp->vm_mm = mm;
 		tmp->vm_next = NULL;
-		anon_vma_link(tmp);
 		file = tmp->vm_file;
 		if (file) {
 			struct inode *inode = file->f_path.dentry->d_inode;
@@ -391,6 +393,7 @@ out:
 	flush_tlb_mm(oldmm);
 	up_write(&oldmm->mmap_sem);
 	return retval;
+fail_nomem_anon_vma_fork:
 fail_nomem_policy:
 	kmem_cache_free(vm_area_cachep, tmp);
 fail_nomem:
diff --git a/mm/ksm.c b/mm/ksm.c
index 56a0da1..a93f1b7 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1563,10 +1563,12 @@ int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
+		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
 		spin_lock(&anon_vma->lock);
-		list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
+			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
 				continue;
@@ -1614,10 +1616,12 @@ int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
+		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
 		spin_lock(&anon_vma->lock);
-		list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
+			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
 				continue;
@@ -1664,10 +1668,12 @@ int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
+		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
 		spin_lock(&anon_vma->lock);
-		list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
+			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
 				continue;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 2c08089..b6d77ec 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -363,6 +363,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 			      struct to_kill **tkc)
 {
 	struct vm_area_struct *vma;
+	struct anon_vma_chain *vmac;
 	struct task_struct *tsk;
 	struct anon_vma *av;
 
@@ -373,7 +374,8 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 	for_each_process (tsk) {
 		if (!task_early_kill(tsk))
 			continue;
-		list_for_each_entry (vma, &av->head, anon_vma_node) {
+		list_for_each_entry (vmac, &av->head, same_anon_vma) {
+			vma = vmac->vma;
 			if (!page_mapped_in_vma(page, vma))
 				continue;
 			if (vma->vm_mm == tsk->mm)
diff --git a/mm/memory.c b/mm/memory.c
index 09e4b1b..6a0f36e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -300,7 +300,7 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 * Hide vma from rmap and truncate_pagecache before freeing
 		 * pgtables
 		 */
-		anon_vma_unlink(vma);
+		unlink_anon_vmas(vma);
 		unlink_file_vma(vma);
 
 		if (is_vm_hugetlb_page(vma)) {
@@ -314,7 +314,7 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			       && !is_vm_hugetlb_page(next)) {
 				vma = next;
 				next = vma->vm_next;
-				anon_vma_unlink(vma);
+				unlink_anon_vmas(vma);
 				unlink_file_vma(vma);
 			}
 			free_pgd_range(tlb, addr, vma->vm_end,
diff --git a/mm/mmap.c b/mm/mmap.c
index 64e0b04..b7b3d30 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -437,7 +437,6 @@ __vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	__vma_link_list(mm, vma, prev, rb_parent);
 	__vma_link_rb(mm, vma, rb_link, rb_parent);
-	__anon_vma_link(vma);
 }
 
 static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -499,7 +498,7 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
  * are necessary.  The "insert" vma (if any) is to be inserted
  * before we drop the necessary locks.
  */
-void vma_adjust(struct vm_area_struct *vma, unsigned long start,
+int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -542,6 +541,29 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
+	/*
+	 * When changing only vma->vm_end, we don't really need
+	 * anon_vma lock.
+	 */
+	if (vma->anon_vma && (insert || importer || start != vma->vm_start))
+		anon_vma = vma->anon_vma;
+	if (anon_vma) {
+		/*
+		 * Easily overlooked: when mprotect shifts the boundary,
+		 * make sure the expanding vma has anon_vma set if the
+		 * shrinking vma had, to cover any anon pages imported.
+		 */
+		if (importer && !importer->anon_vma) {
+			/* Block reverse map lookups until things are set up. */
+			importer->vm_flags |= VM_LOCK_RMAP;
+			if (anon_vma_clone(importer, vma)) {
+				importer->vm_flags &= ~VM_LOCK_RMAP;
+				return -ENOMEM;
+			}
+			importer->anon_vma = anon_vma;
+		}
+	}
+
 	if (file) {
 		mapping = file->f_mapping;
 		if (!(vma->vm_flags & VM_NONLINEAR))
@@ -567,25 +589,6 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
-	/*
-	 * When changing only vma->vm_end, we don't really need
-	 * anon_vma lock.
-	 */
-	if (vma->anon_vma && (insert || importer || start != vma->vm_start))
-		anon_vma = vma->anon_vma;
-	if (anon_vma) {
-		spin_lock(&anon_vma->lock);
-		/*
-		 * Easily overlooked: when mprotect shifts the boundary,
-		 * make sure the expanding vma has anon_vma set if the
-		 * shrinking vma had, to cover any anon pages imported.
-		 */
-		if (importer && !importer->anon_vma) {
-			importer->anon_vma = anon_vma;
-			__anon_vma_link(importer);
-		}
-	}
-
 	if (root) {
 		flush_dcache_mmap_lock(mapping);
 		vma_prio_tree_remove(vma, root);
@@ -616,8 +619,11 @@ again:			remove_next = 1 + (end > next->vm_end);
 		__vma_unlink(mm, next, vma);
 		if (file)
 			__remove_shared_vm_struct(next, file, mapping);
-		if (next->anon_vma)
-			__anon_vma_merge(vma, next);
+		/*
+		 * This VMA is now dead, no need for rmap to follow it.
+		 * Call anon_vma_merge below, outside of i_mmap_lock.
+		 */
+		next->vm_flags |= VM_LOCK_RMAP;
 	} else if (insert) {
 		/*
 		 * split_vma has split insert from vma, and needs
@@ -627,17 +633,25 @@ again:			remove_next = 1 + (end > next->vm_end);
 		__insert_vm_struct(mm, insert);
 	}
 
-	if (anon_vma)
-		spin_unlock(&anon_vma->lock);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 
+	/*
+	 * The current VMA has been set up. It is now safe for the
+	 * rmap code to get from the pages to the ptes.
+	 */
+	if (anon_vma && importer)
+		importer->vm_flags &= ~VM_LOCK_RMAP;
+
 	if (remove_next) {
 		if (file) {
 			fput(file);
 			if (next->vm_flags & VM_EXECUTABLE)
 				removed_exe_file_vma(mm);
 		}
+		/* Protected by mmap_sem and VM_LOCK_RMAP. */
+		if (next->anon_vma)
+			anon_vma_merge(vma, next);
 		mm->map_count--;
 		mpol_put(vma_policy(next));
 		kmem_cache_free(vm_area_cachep, next);
@@ -653,6 +667,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 	}
 
 	validate_mm(mm);
+
+	return 0;
 }
 
 /*
@@ -759,6 +775,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 {
 	pgoff_t pglen = (end - addr) >> PAGE_SHIFT;
 	struct vm_area_struct *area, *next;
+	int err;
 
 	/*
 	 * We later require that vma->vm_flags == vm_flags,
@@ -792,11 +809,13 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 				is_mergeable_anon_vma(prev->anon_vma,
 						      next->anon_vma)) {
 							/* cases 1, 6 */
-			vma_adjust(prev, prev->vm_start,
+			err = vma_adjust(prev, prev->vm_start,
 				next->vm_end, prev->vm_pgoff, NULL);
 		} else					/* cases 2, 5, 7 */
-			vma_adjust(prev, prev->vm_start,
+			err = vma_adjust(prev, prev->vm_start,
 				end, prev->vm_pgoff, NULL);
+		if (err)
+			return NULL;
 		return prev;
 	}
 
@@ -808,11 +827,13 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			can_vma_merge_before(next, vm_flags,
 					anon_vma, file, pgoff+pglen)) {
 		if (prev && addr < prev->vm_end)	/* case 4 */
-			vma_adjust(prev, prev->vm_start,
+			err = vma_adjust(prev, prev->vm_start,
 				addr, prev->vm_pgoff, NULL);
 		else					/* cases 3, 8 */
-			vma_adjust(area, addr, next->vm_end,
+			err = vma_adjust(area, addr, next->vm_end,
 				next->vm_pgoff - pglen, NULL);
+		if (err)
+			return NULL;
 		return area;
 	}
 
@@ -1187,6 +1208,7 @@ munmap_back:
 	vma->vm_flags = vm_flags;
 	vma->vm_page_prot = vm_get_page_prot(vm_flags);
 	vma->vm_pgoff = pgoff;
+	INIT_LIST_HEAD(&vma->anon_vma_chain);
 
 	if (file) {
 		error = -EINVAL;
@@ -1847,6 +1869,7 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 {
 	struct mempolicy *pol;
 	struct vm_area_struct *new;
+	int err = -ENOMEM;
 
 	if (is_vm_hugetlb_page(vma) && (addr &
 					~(huge_page_mask(hstate_vma(vma)))))
@@ -1854,11 +1877,15 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 
 	new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (!new)
-		return -ENOMEM;
+		goto out_err;
 
 	/* most fields are the same, copy all, and then fixup */
 	*new = *vma;
 
+	INIT_LIST_HEAD(&new->anon_vma_chain);
+	if (anon_vma_clone(new, vma))
+		goto out_err;
+
 	if (new_below)
 		new->vm_end = addr;
 	else {
@@ -1868,8 +1895,8 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 
 	pol = mpol_dup(vma_policy(vma));
 	if (IS_ERR(pol)) {
-		kmem_cache_free(vm_area_cachep, new);
-		return PTR_ERR(pol);
+		err = PTR_ERR(pol);
+		goto out_free_vma;
 	}
 	vma_set_policy(new, pol);
 
@@ -1883,12 +1910,27 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 		new->vm_ops->open(new);
 
 	if (new_below)
-		vma_adjust(vma, addr, vma->vm_end, vma->vm_pgoff +
+		err = vma_adjust(vma, addr, vma->vm_end, vma->vm_pgoff +
 			((addr - new->vm_start) >> PAGE_SHIFT), new);
 	else
-		vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff, new);
+		err = vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff, new);
 
-	return 0;
+	/* Success. */
+	if (!err)
+		return 0;
+
+	/* Clean everything up if vma_adjust failed. */
+	new->vm_ops->close(new);
+	if (new->vm_file) {
+		if (vma->vm_flags & VM_EXECUTABLE)
+			added_exe_file_vma(mm);
+		fput(new->vm_file);
+	}
+	mpol_put(pol);
+ out_free_vma:
+	kmem_cache_free(vm_area_cachep, new);
+ out_err:
+	return err;
 }
 
 /*
@@ -2105,6 +2147,7 @@ unsigned long do_brk(unsigned long addr, unsigned long len)
 		return -ENOMEM;
 	}
 
+	INIT_LIST_HEAD(&vma->anon_vma_chain);
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
@@ -2241,10 +2284,11 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		if (new_vma) {
 			*new_vma = *vma;
 			pol = mpol_dup(vma_policy(vma));
-			if (IS_ERR(pol)) {
-				kmem_cache_free(vm_area_cachep, new_vma);
-				return NULL;
-			}
+			if (IS_ERR(pol))
+				goto out_free_vma;
+			INIT_LIST_HEAD(&vma->anon_vma_chain);
+			if (anon_vma_clone(new_vma, vma))
+				goto out_free_mempol;
 			vma_set_policy(new_vma, pol);
 			new_vma->vm_start = addr;
 			new_vma->vm_end = addr + len;
@@ -2260,6 +2304,12 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		}
 	}
 	return new_vma;
+
+ out_free_mempol:
+	mpol_put(pol);
+ out_free_vma:
+	kmem_cache_free(vm_area_cachep, new_vma);
+	return NULL;
 }
 
 /*
@@ -2337,6 +2387,7 @@ int install_special_mapping(struct mm_struct *mm,
 	if (unlikely(vma == NULL))
 		return -ENOMEM;
 
+	INIT_LIST_HEAD(&vma->anon_vma_chain);
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
@@ -2437,6 +2488,7 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
 int mm_take_all_locks(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
+	struct anon_vma_chain *avc;
 	int ret = -EINTR;
 
 	BUG_ON(down_read_trylock(&mm->mmap_sem));
@@ -2454,7 +2506,8 @@ int mm_take_all_locks(struct mm_struct *mm)
 		if (signal_pending(current))
 			goto out_unlock;
 		if (vma->anon_vma)
-			vm_lock_anon_vma(mm, vma->anon_vma);
+			list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
+				vm_lock_anon_vma(mm, avc->anon_vma);
 	}
 
 	ret = 0;
@@ -2509,13 +2562,15 @@ static void vm_unlock_mapping(struct address_space *mapping)
 void mm_drop_all_locks(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
+	struct anon_vma_chain *avc;
 
 	BUG_ON(down_read_trylock(&mm->mmap_sem));
 	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));
 
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->anon_vma)
-			vm_unlock_anon_vma(vma->anon_vma);
+			list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
+				vm_unlock_anon_vma(avc->anon_vma);
 		if (vma->vm_file && vma->vm_file->f_mapping)
 			vm_unlock_mapping(vma->vm_file->f_mapping);
 	}
diff --git a/mm/mremap.c b/mm/mremap.c
index 8f88547..8dbc8a5 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -389,8 +389,11 @@ unsigned long do_mremap(unsigned long addr,
 		if (max_addr - addr >= new_len) {
 			int pages = (new_len - old_len) >> PAGE_SHIFT;
 
-			vma_adjust(vma, vma->vm_start,
-				addr + new_len, vma->vm_pgoff, NULL);
+			if (vma_adjust(vma, vma->vm_start, addr + new_len,
+				       vma->vm_pgoff, NULL)) {
+				ret = -ENOMEM;
+				goto out;
+			}
 
 			mm->total_vm += pages;
 			vm_stat_account(mm, vma->vm_flags, vma->vm_file, pages);
diff --git a/mm/nommu.c b/mm/nommu.c
index 1544a65..9db704f 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1209,7 +1209,7 @@ unsigned long do_mmap_pgoff(struct file *file,
 	region->vm_flags = vm_flags;
 	region->vm_pgoff = pgoff;
 
-	INIT_LIST_HEAD(&vma->anon_vma_node);
+	INIT_LIST_HEAD(&vma->anon_vma_chain);
 	vma->vm_flags = vm_flags;
 	vma->vm_pgoff = pgoff;
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 278cd27..d6f8c64 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -62,6 +62,7 @@
 #include "internal.h"
 
 static struct kmem_cache *anon_vma_cachep;
+static struct kmem_cache *anon_vma_chain_cachep;
 
 static inline struct anon_vma *anon_vma_alloc(void)
 {
@@ -73,6 +74,16 @@ void anon_vma_free(struct anon_vma *anon_vma)
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
 
+static inline struct anon_vma_chain *anon_vma_chain_alloc(void)
+{
+	return kmem_cache_alloc(anon_vma_chain_cachep, GFP_KERNEL);
+}
+
+void anon_vma_chain_free(struct anon_vma_chain *anon_vma_chain)
+{
+	kmem_cache_free(anon_vma_chain_cachep, anon_vma_chain);
+}
+
 /**
  * anon_vma_prepare - attach an anon_vma to a memory region
  * @vma: the memory region in question
@@ -103,18 +114,23 @@ void anon_vma_free(struct anon_vma *anon_vma)
 int anon_vma_prepare(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
+	struct anon_vma_chain *avc;
 
 	might_sleep();
 	if (unlikely(!anon_vma)) {
 		struct mm_struct *mm = vma->vm_mm;
 		struct anon_vma *allocated;
 
+		avc = anon_vma_chain_alloc();
+		if (!avc)
+			goto out_enomem;
+
 		anon_vma = find_mergeable_anon_vma(vma);
 		allocated = NULL;
 		if (!anon_vma) {
 			anon_vma = anon_vma_alloc();
 			if (unlikely(!anon_vma))
-				return -ENOMEM;
+				goto out_enomem_free_avc;
 			allocated = anon_vma;
 		}
 		spin_lock(&anon_vma->lock);
@@ -123,53 +139,113 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
 			vma->anon_vma = anon_vma;
-			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+			avc->anon_vma = anon_vma;
+			avc->vma = vma;
+			list_add(&avc->same_vma, &vma->anon_vma_chain);
+			list_add(&avc->same_anon_vma, &anon_vma->head);
 			allocated = NULL;
 		}
 		spin_unlock(&mm->page_table_lock);
 
 		spin_unlock(&anon_vma->lock);
-		if (unlikely(allocated))
+		if (unlikely(allocated)) {
 			anon_vma_free(allocated);
+			anon_vma_chain_free(avc);
+		}
 	}
 	return 0;
+
+ out_enomem_free_avc:
+	anon_vma_chain_free(avc);
+ out_enomem:
+	return -ENOMEM;
 }
 
-void __anon_vma_merge(struct vm_area_struct *vma, struct vm_area_struct *next)
+static void anon_vma_chain_link(struct vm_area_struct *vma,
+				struct anon_vma_chain *avc,
+				struct anon_vma *anon_vma)
 {
-	BUG_ON(vma->anon_vma != next->anon_vma);
-	list_del(&next->anon_vma_node);
+	avc->vma = vma;
+	avc->anon_vma = anon_vma;
+	list_add(&avc->same_vma, &vma->anon_vma_chain);
+
+	spin_lock(&anon_vma->lock);
+	list_add_tail(&avc->same_anon_vma, &anon_vma->head);
+	spin_unlock(&anon_vma->lock);
 }
 
-void __anon_vma_link(struct vm_area_struct *vma)
+/*
+ * Attach the anon_vmas from src to dst.
+ * Returns 0 on success, -ENOMEM on failure.
+ */
+int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
 {
-	struct anon_vma *anon_vma = vma->anon_vma;
+	struct anon_vma_chain *avc, *pavc;
+
+	list_for_each_entry(pavc, &src->anon_vma_chain, same_vma) {
+		avc = anon_vma_chain_alloc();
+		if (!avc)
+			goto enomem_failure;
+		anon_vma_chain_link(dst, avc, src->anon_vma);
+	}
+	return 0;
 
-	if (anon_vma)
-		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+ enomem_failure:
+	unlink_anon_vmas(dst);
+	return -ENOMEM;
 }
 
-void anon_vma_link(struct vm_area_struct *vma)
+/*
+ * Attach vma to its own anon_vma, as well as to the anon_vmas that
+ * the corresponding VMA in the parent process is attached to.
+ * Returns 0 on success, non-zero on failure.
+ */
+int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 {
-	struct anon_vma *anon_vma = vma->anon_vma;
+	struct anon_vma_chain *avc;
+	struct anon_vma *anon_vma;
 
-	if (anon_vma) {
-		spin_lock(&anon_vma->lock);
-		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
-		spin_unlock(&anon_vma->lock);
-	}
+	/* Don't bother if the parent process has no anon_vma here. */
+	if (!pvma->anon_vma)
+		return 0;
+
+	/*
+	 * First, attach the new VMA to the parent VMA's anon_vmas,
+	 * so rmap can find non-COWed pages in child processes.
+	 */
+	if (anon_vma_clone(vma, pvma))
+		return -ENOMEM;
+
+	/* Then add our own anon_vma. */
+	anon_vma = anon_vma_alloc();
+	if (!anon_vma)
+		goto out_error;
+	avc = anon_vma_chain_alloc();
+	if (!avc)
+		goto out_error_free_anon_vma;
+	anon_vma_chain_link(vma, avc, anon_vma);
+	/* Mark this anon_vma as the one where our new (COWed) pages go. */
+	vma->anon_vma = anon_vma;
+
+	return 0;
+
+ out_error_free_anon_vma:
+	anon_vma_free(anon_vma);
+ out_error:
+	return -ENOMEM;
 }
 
-void anon_vma_unlink(struct vm_area_struct *vma)
+static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
 {
-	struct anon_vma *anon_vma = vma->anon_vma;
+	struct anon_vma *anon_vma = anon_vma_chain->anon_vma;
 	int empty;
 
+	/* If anon_vma_fork fails, we can get an empty anon_vma_chain. */
 	if (!anon_vma)
 		return;
 
 	spin_lock(&anon_vma->lock);
-	list_del(&vma->anon_vma_node);
+	list_del(&anon_vma_chain->same_anon_vma);
 
 	/* We must garbage collect the anon_vma if it's empty */
 	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma);
@@ -179,6 +255,18 @@ void anon_vma_unlink(struct vm_area_struct *vma)
 		anon_vma_free(anon_vma);
 }
 
+void unlink_anon_vmas(struct vm_area_struct *vma)
+{
+	struct anon_vma_chain *avc, *next;
+
+	/* Unlink each anon_vma chained to the VMA. */
+	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) {
+		anon_vma_unlink(avc);
+		list_del(&avc->same_vma);
+		anon_vma_chain_free(avc);
+	}
+}
+
 static void anon_vma_ctor(void *data)
 {
 	struct anon_vma *anon_vma = data;
@@ -188,10 +276,21 @@ static void anon_vma_ctor(void *data)
 	INIT_LIST_HEAD(&anon_vma->head);
 }
 
+static void anon_vma_chain_ctor(void *data)
+{
+	struct anon_vma_chain *anon_vma_chain = data;
+
+	INIT_LIST_HEAD(&anon_vma_chain->same_vma);
+	INIT_LIST_HEAD(&anon_vma_chain->same_anon_vma);
+}
+
 void __init anon_vma_init(void)
 {
 	anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct anon_vma),
 			0, SLAB_DESTROY_BY_RCU|SLAB_PANIC, anon_vma_ctor);
+	anon_vma_chain_cachep = kmem_cache_create("anon_vma_chain",
+			sizeof(struct anon_vma_chain), 0,
+			SLAB_DESTROY_BY_RCU|SLAB_PANIC, anon_vma_chain_ctor);
 }
 
 /*
@@ -240,6 +339,14 @@ vma_address(struct page *page, struct vm_area_struct *vma)
 		/* page should be within @vma mapping range */
 		return -EFAULT;
 	}
+	if (unlikely(vma->vm_flags & VM_LOCK_RMAP))
+		/*
+		 * This VMA is being unlinked or not yet linked into the
+		 * VMA tree.  Do not try to follow this rmap.  This race
+		 * condition can result in page_referenced ignoring a
+		 * reference or try_to_unmap failing to unmap a page.
+		 */
+		return -EFAULT;
 	return address;
 }
 
@@ -396,7 +503,7 @@ static int page_referenced_anon(struct page *page,
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
-	struct vm_area_struct *vma;
+	struct anon_vma_chain *avc;
 	int referenced = 0;
 
 	anon_vma = page_lock_anon_vma(page);
@@ -404,7 +511,8 @@ static int page_referenced_anon(struct page *page,
 		return referenced;
 
 	mapcount = page_mapcount(page);
-	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
@@ -1024,14 +1132,15 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 {
 	struct anon_vma *anon_vma;
-	struct vm_area_struct *vma;
+	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
 		return ret;
 
-	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
@@ -1222,7 +1331,7 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 		struct vm_area_struct *, unsigned long, void *), void *arg)
 {
 	struct anon_vma *anon_vma;
-	struct vm_area_struct *vma;
+	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
 	/*
@@ -1237,7 +1346,8 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	if (!anon_vma)
 		return ret;
 	spin_lock(&anon_vma->lock);
-	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
