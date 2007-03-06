Message-Id: <20070306014211.202631000@taijtu.programming.kicks-ass.net>
References: <20070306013815.951032000@taijtu.programming.kicks-ass.net>
Date: Tue, 06 Mar 2007 02:38:17 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 2/5] mm: use B+tree for vmas
Content-Disposition: inline; filename=mm.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@engr.sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Replace the mm_rb tree with the new B+tree. Also replace the vma list
with a proper list_head.

TODO:
 - See if I can split out the vma list change.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 Makefile                            |    2 
 arch/alpha/kernel/osf_sys.c         |    2 
 arch/arm/mm/mmap.c                  |    2 
 arch/frv/mm/elf-fdpic.c             |    4 
 arch/i386/mm/hugetlbpage.c          |    2 
 arch/ia64/kernel/sys_ia64.c         |    2 
 arch/ia64/mm/hugetlbpage.c          |    2 
 arch/mips/kernel/irixelf.c          |   20 +-
 arch/mips/kernel/syscall.c          |    2 
 arch/parisc/kernel/sys_parisc.c     |    4 
 arch/powerpc/mm/hugetlbpage.c       |    2 
 arch/powerpc/mm/tlb_32.c            |    2 
 arch/ppc/mm/tlb.c                   |    2 
 arch/sh/kernel/sys_sh.c             |    2 
 arch/sh/mm/cache-sh4.c              |    2 
 arch/sh64/kernel/sys_sh64.c         |    2 
 arch/sparc/kernel/sys_sparc.c       |    2 
 arch/sparc64/kernel/binfmt_aout32.c |    2 
 arch/sparc64/kernel/sys_sparc.c     |    2 
 arch/sparc64/mm/hugetlbpage.c       |    2 
 arch/x86_64/ia32/ia32_aout.c        |    2 
 arch/x86_64/kernel/sys_x86_64.c     |    2 
 drivers/char/mem.c                  |    4 
 drivers/oprofile/buffer_sync.c      |    4 
 fs/binfmt_aout.c                    |    2 
 fs/binfmt_elf.c                     |    6 
 fs/binfmt_elf_fdpic.c               |    4 
 fs/hugetlbfs/inode.c                |    2 
 fs/proc/task_mmu.c                  |   17 -
 include/linux/init_task.h           |    4 
 include/linux/mm.h                  |   56 ++++-
 include/linux/sched.h               |    7 
 init/main.c                         |    2 
 ipc/shm.c                           |    4 
 kernel/acct.c                       |    5 
 kernel/auditsc.c                    |    4 
 kernel/fork.c                       |   74 +++----
 mm/madvise.c                        |    8 
 mm/memory.c                         |   24 +-
 mm/mempolicy.c                      |   10 -
 mm/migrate.c                        |    2 
 mm/mlock.c                          |    4 
 mm/mmap.c                           |  341 ++++++++++++++----------------------
 mm/mprotect.c                       |    2 
 mm/mremap.c                         |    7 
 mm/msync.c                          |    2 
 mm/swapfile.c                       |    2 
 47 files changed, 314 insertions(+), 349 deletions(-)

Index: linux-2.6/arch/i386/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/i386/mm/hugetlbpage.c
+++ linux-2.6/arch/i386/mm/hugetlbpage.c
@@ -242,7 +242,7 @@ static unsigned long hugetlb_get_unmappe
 full_search:
 	addr = ALIGN(start_addr, HPAGE_SIZE);
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
Index: linux-2.6/arch/x86_64/kernel/sys_x86_64.c
===================================================================
--- linux-2.6.orig/arch/x86_64/kernel/sys_x86_64.c
+++ linux-2.6/arch/x86_64/kernel/sys_x86_64.c
@@ -116,7 +116,7 @@ arch_get_unmapped_area(struct file *filp
 	start_addr = addr;
 
 full_search:
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (end - len < addr) {
 			/*
Index: linux-2.6/drivers/char/mem.c
===================================================================
--- linux-2.6.orig/drivers/char/mem.c
+++ linux-2.6/drivers/char/mem.c
@@ -634,7 +634,7 @@ static inline size_t read_zero_pagealign
 	down_read(&mm->mmap_sem);
 
 	/* For private mappings, just map in zero pages. */
-	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); vma; vma = __vma_next(&mm->mm_vmas, vma)) {
 		unsigned long count;
 
 		if (vma->vm_start > addr || (vma->vm_flags & VM_WRITE) == 0)
@@ -645,7 +645,7 @@ static inline size_t read_zero_pagealign
 		if (count > size)
 			count = size;
 
-		zap_page_range(vma, addr, count, NULL);
+		zap_page_range(&mm->mm_vmas, vma, addr, count, NULL);
         	if (zeromap_page_range(vma, addr, count, PAGE_COPY))
 			break;
 
Index: linux-2.6/drivers/oprofile/buffer_sync.c
===================================================================
--- linux-2.6.orig/drivers/oprofile/buffer_sync.c
+++ linux-2.6/drivers/oprofile/buffer_sync.c
@@ -215,7 +215,7 @@ static unsigned long get_exec_dcookie(st
 	if (!mm)
 		goto out;
  
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (!vma->vm_file)
 			continue;
 		if (!(vma->vm_flags & VM_EXECUTABLE))
@@ -240,7 +240,7 @@ static unsigned long lookup_dcookie(stru
 	unsigned long cookie = NO_COOKIE;
 	struct vm_area_struct * vma;
 
-	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); vma; vma = vma_next(vma)) {
  
 		if (addr < vma->vm_start || addr >= vma->vm_end)
 			continue;
Index: linux-2.6/fs/binfmt_elf.c
===================================================================
--- linux-2.6.orig/fs/binfmt_elf.c
+++ linux-2.6/fs/binfmt_elf.c
@@ -779,7 +779,7 @@ static int load_elf_binary(struct linux_
 	current->mm->start_data = 0;
 	current->mm->end_data = 0;
 	current->mm->end_code = 0;
-	current->mm->mmap = NULL;
+	INIT_LIST_HEAD(&current->mm->mm_vmas);
 	current->flags &= ~PF_FORKNOEXEC;
 	current->mm->def_flags = def_flags;
 
@@ -1440,7 +1440,7 @@ static int elf_dump_thread_status(long s
 static struct vm_area_struct *first_vma(struct task_struct *tsk,
 					struct vm_area_struct *gate_vma)
 {
-	struct vm_area_struct *ret = tsk->mm->mmap;
+	struct vm_area_struct *ret = __vma_next(&tsk->mm->mm_vmas, NULL);
 
 	if (ret)
 		return ret;
@@ -1455,7 +1455,7 @@ static struct vm_area_struct *next_vma(s
 {
 	struct vm_area_struct *ret;
 
-	ret = this_vma->vm_next;
+	ret = vma_next(this_vma);
 	if (ret)
 		return ret;
 	if (this_vma == gate_vma)
Index: linux-2.6/fs/binfmt_elf_fdpic.c
===================================================================
--- linux-2.6.orig/fs/binfmt_elf_fdpic.c
+++ linux-2.6/fs/binfmt_elf_fdpic.c
@@ -1455,7 +1455,7 @@ static int elf_fdpic_dump_segments(struc
 {
 	struct vm_area_struct *vma;
 
-	for (vma = current->mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		unsigned long addr;
 
 		if (!maydump(vma))
@@ -1704,7 +1704,7 @@ static int elf_fdpic_core_dump(long sign
 	/* write program headers for segments dump */
 	for (
 #ifdef CONFIG_MMU
-		vma = current->mm->mmap; vma; vma = vma->vm_next
+		vma = __vma_next(&current->mm->mm_vmas, NULL); vma; vma_next(vma)
 #else
 			vml = current->mm->context.vmlist; vml; vml = vml->next
 #endif
Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c
+++ linux-2.6/fs/hugetlbfs/inode.c
@@ -131,7 +131,7 @@ hugetlb_get_unmapped_area(struct file *f
 full_search:
 	addr = ALIGN(start_addr, HPAGE_SIZE);
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
Index: linux-2.6/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.orig/fs/proc/task_mmu.c
+++ linux-2.6/fs/proc/task_mmu.c
@@ -86,12 +86,9 @@ int proc_exe_link(struct inode *inode, s
 		goto out;
 	down_read(&mm->mmap_sem);
 
-	vma = mm->mmap;
-	while (vma) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 		if ((vma->vm_flags & VM_EXECUTABLE) && vma->vm_file)
 			break;
-		vma = vma->vm_next;
-	}
 
 	if (vma) {
 		*mnt = mntget(vma->vm_file->f_path.mnt);
@@ -334,7 +331,7 @@ static void *m_start(struct seq_file *m,
 
 	/* Start with last addr hint */
 	if (last_addr && (vma = find_vma(mm, last_addr))) {
-		vma = vma->vm_next;
+		vma = vma_next(vma);
 		goto out;
 	}
 
@@ -344,9 +341,9 @@ static void *m_start(struct seq_file *m,
 	 */
 	vma = NULL;
 	if ((unsigned long)l < mm->map_count) {
-		vma = mm->mmap;
+		vma = __vma_next(&mm->mm_vmas, NULL);
 		while (l-- && vma)
-			vma = vma->vm_next;
+			vma = vma_next(vma);
 		goto out;
 	}
 
@@ -376,12 +373,12 @@ static void vma_stop(struct proc_maps_pr
 static void *m_next(struct seq_file *m, void *v, loff_t *pos)
 {
 	struct proc_maps_private *priv = m->private;
-	struct vm_area_struct *vma = v;
+	struct vm_area_struct *vma = v, *next;
 	struct vm_area_struct *tail_vma = priv->tail_vma;
 
 	(*pos)++;
-	if (vma && (vma != tail_vma) && vma->vm_next)
-		return vma->vm_next;
+	if (vma && (vma != tail_vma) && (next = vma_next(vma)))
+		return next;
 	vma_stop(priv, vma);
 	return (vma != tail_vma)? tail_vma: NULL;
 }
Index: linux-2.6/include/linux/init_task.h
===================================================================
--- linux-2.6.orig/include/linux/init_task.h
+++ linux-2.6/include/linux/init_task.h
@@ -46,7 +46,9 @@
 
 #define INIT_MM(name) \
 {			 					\
-	.mm_rb		= RB_ROOT,				\
+	.mm_vmas	= LIST_HEAD_INIT(name.mm_vmas),		\
+	.mm_btree	= BTREE_INIT(GFP_ATOMIC|__GFP_NOFAIL),	\
+	.mm_btree_lock	= __SPIN_LOCK_UNLOCKED(name.mm_btree_lock), \
 	.pgd		= swapper_pg_dir, 			\
 	.mm_users	= ATOMIC_INIT(2), 			\
 	.mm_count	= ATOMIC_INIT(1), 			\
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -10,7 +10,7 @@
 #include <linux/gfp.h>
 #include <linux/list.h>
 #include <linux/mmzone.h>
-#include <linux/rbtree.h>
+#include <linux/btree.h>
 #include <linux/prio_tree.h>
 #include <linux/fs.h>
 #include <linux/mutex.h>
@@ -62,14 +62,11 @@ struct vm_area_struct {
 	unsigned long vm_start;		/* Our start address within vm_mm. */
 	unsigned long vm_end;		/* The first byte after our end address
 					   within vm_mm. */
-
-	/* linked list of VM areas per task, sorted by address */
-	struct vm_area_struct *vm_next;
-
 	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
 	unsigned long vm_flags;		/* Flags, listed below. */
 
-	struct rb_node vm_rb;
+	/* linked list of VM areas per task, sorted by address */
+	struct list_head vm_list;
 
 	/*
 	 * For areas with an address space and backing store,
@@ -114,6 +111,42 @@ struct vm_area_struct {
 #endif
 };
 
+static inline struct vm_area_struct *
+__vma_next(struct list_head *head, struct vm_area_struct *vma)
+{
+	if (unlikely(!vma))
+		vma = container_of(head, struct vm_area_struct, vm_list);
+
+	if (vma->vm_list.next == head)
+		return NULL;
+
+	return list_entry(vma->vm_list.next, struct vm_area_struct, vm_list);
+}
+
+static inline struct vm_area_struct *
+vma_next(struct vm_area_struct *vma)
+{
+	return __vma_next(&vma->vm_mm->mm_vmas, vma);
+}
+
+static inline struct vm_area_struct *
+__vma_prev(struct list_head *head, struct vm_area_struct *vma)
+{
+	if (unlikely(!vma))
+		vma = container_of(head, struct vm_area_struct, vm_list);
+
+	if (vma->vm_list.prev == head)
+		return NULL;
+
+	return list_entry(vma->vm_list.prev, struct vm_area_struct, vm_list);
+}
+
+static inline struct vm_area_struct *
+vma_prev(struct vm_area_struct *vma)
+{
+	return __vma_prev(&vma->vm_mm->mm_vmas, vma);
+}
+
 extern struct kmem_cache *vm_area_cachep;
 
 /*
@@ -724,15 +757,17 @@ struct zap_details {
 };
 
 struct page *vm_normal_page(struct vm_area_struct *, unsigned long, pte_t);
-unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
+unsigned long zap_page_range(struct list_head *vmas,
+		struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
-unsigned long unmap_vmas(struct mmu_gather **tlb,
+unsigned long unmap_vmas(struct mmu_gather **tlb, struct list_head *vmas,
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
 void free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *start_vma,
+void free_pgtables(struct mmu_gather **tlb, struct list_head *vmas,
+	       	struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
@@ -1023,8 +1058,7 @@ extern struct anon_vma *find_mergeable_a
 extern int split_vma(struct mm_struct *,
 	struct vm_area_struct *, unsigned long addr, int new_below);
 extern int insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
-extern void __vma_link_rb(struct mm_struct *, struct vm_area_struct *,
-	struct rb_node **, struct rb_node *);
+extern void __vma_link_btree(struct mm_struct *, struct vm_area_struct *);
 extern void unlink_file_vma(struct vm_area_struct *);
 extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
 	unsigned long addr, unsigned long len, pgoff_t pgoff);
Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -49,7 +49,7 @@ struct sched_param {
 #include <linux/types.h>
 #include <linux/timex.h>
 #include <linux/jiffies.h>
-#include <linux/rbtree.h>
+#include <linux/btree.h>
 #include <linux/thread_info.h>
 #include <linux/cpumask.h>
 #include <linux/errno.h>
@@ -308,8 +308,9 @@ typedef unsigned long mm_counter_t;
 } while (0)
 
 struct mm_struct {
-	struct vm_area_struct * mmap;		/* list of VMAs */
-	struct rb_root mm_rb;
+	struct list_head mm_vmas;
+	struct btree_root mm_btree;
+	spinlock_t mm_btree_lock;
 	struct vm_area_struct * mmap_cache;	/* last find_vma result */
 	unsigned long (*get_unmapped_area) (struct file *filp,
 				unsigned long addr, unsigned long len,
Index: linux-2.6/init/main.c
===================================================================
--- linux-2.6.orig/init/main.c
+++ linux-2.6/init/main.c
@@ -52,6 +52,7 @@
 #include <linux/lockdep.h>
 #include <linux/pid_namespace.h>
 #include <linux/device.h>
+#include <linux/btree.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -581,6 +582,7 @@ asmlinkage void __init start_kernel(void
 	cpuset_init_early();
 	mem_init();
 	kmem_cache_init();
+	btree_init();
 	setup_per_cpu_pageset();
 	numa_policy_init();
 	if (late_time_init)
Index: linux-2.6/ipc/shm.c
===================================================================
--- linux-2.6.orig/ipc/shm.c
+++ linux-2.6/ipc/shm.c
@@ -937,7 +937,7 @@ asmlinkage long sys_shmdt(char __user *s
 	vma = find_vma(mm, addr);
 
 	while (vma) {
-		next = vma->vm_next;
+		next = vma_next(vma);
 
 		/*
 		 * Check if the starting address would match, i.e. it's
@@ -970,7 +970,7 @@ asmlinkage long sys_shmdt(char __user *s
 	 */
 	size = PAGE_ALIGN(size);
 	while (vma && (loff_t)(vma->vm_end - addr) <= size) {
-		next = vma->vm_next;
+		next = vma_next(vma);
 
 		/* finding a matching vma now does not alter retval */
 		if ((vma->vm_ops == &shm_vm_ops || is_vm_hugetlb_page(vma)) &&
Index: linux-2.6/kernel/acct.c
===================================================================
--- linux-2.6.orig/kernel/acct.c
+++ linux-2.6/kernel/acct.c
@@ -540,11 +540,8 @@ void acct_collect(long exitcode, int gro
 	if (group_dead && current->mm) {
 		struct vm_area_struct *vma;
 		down_read(&current->mm->mmap_sem);
-		vma = current->mm->mmap;
-		while (vma) {
+		list_for_each_entry(vma, &current->mm->mm_vmas, vm_list)
 			vsize += vma->vm_end - vma->vm_start;
-			vma = vma->vm_next;
-		}
 		up_read(&current->mm->mmap_sem);
 	}
 
Index: linux-2.6/kernel/auditsc.c
===================================================================
--- linux-2.6.orig/kernel/auditsc.c
+++ linux-2.6/kernel/auditsc.c
@@ -776,8 +776,7 @@ static void audit_log_task_info(struct a
 
 	if (mm) {
 		down_read(&mm->mmap_sem);
-		vma = mm->mmap;
-		while (vma) {
+		list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 			if ((vma->vm_flags & VM_EXECUTABLE) &&
 			    vma->vm_file) {
 				audit_log_d_path(ab, "exe=",
@@ -785,7 +784,6 @@ static void audit_log_task_info(struct a
 						 vma->vm_file->f_path.mnt);
 				break;
 			}
-			vma = vma->vm_next;
 		}
 		up_read(&mm->mmap_sem);
 	}
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -196,8 +196,7 @@ static struct task_struct *dup_task_stru
 #ifdef CONFIG_MMU
 static inline int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 {
-	struct vm_area_struct *mpnt, *tmp, **pprev;
-	struct rb_node **rb_link, *rb_parent;
+	struct vm_area_struct *vma, *vma_new;
 	int retval;
 	unsigned long charge;
 	struct mempolicy *pol;
@@ -210,59 +209,53 @@ static inline int dup_mmap(struct mm_str
 	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
 
 	mm->locked_vm = 0;
-	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
 	mm->free_area_cache = oldmm->mmap_base;
 	mm->cached_hole_size = ~0UL;
 	mm->map_count = 0;
 	cpus_clear(mm->cpu_vm_mask);
-	mm->mm_rb = RB_ROOT;
-	rb_link = &mm->mm_rb.rb_node;
-	rb_parent = NULL;
-	pprev = &mm->mmap;
 
-	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
+	list_for_each_entry(vma, &oldmm->mm_vmas, vm_list) {
 		struct file *file;
 
-		if (mpnt->vm_flags & VM_DONTCOPY) {
-			long pages = vma_pages(mpnt);
+		if (vma->vm_flags & VM_DONTCOPY) {
+			long pages = vma_pages(vma);
 			mm->total_vm -= pages;
-			vm_stat_account(mm, mpnt->vm_flags, mpnt->vm_file,
+			vm_stat_account(mm, vma->vm_flags, vma->vm_file,
 								-pages);
 			continue;
 		}
 		charge = 0;
-		if (mpnt->vm_flags & VM_ACCOUNT) {
-			unsigned int len = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
+		if (vma->vm_flags & VM_ACCOUNT) {
+			unsigned int len = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
 			if (security_vm_enough_memory(len))
 				goto fail_nomem;
 			charge = len;
 		}
-		tmp = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
-		if (!tmp)
+		vma_new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
+		if (!vma_new)
 			goto fail_nomem;
-		*tmp = *mpnt;
-		pol = mpol_copy(vma_policy(mpnt));
+		*vma_new = *vma;
+		pol = mpol_copy(vma_policy(vma));
 		retval = PTR_ERR(pol);
 		if (IS_ERR(pol))
 			goto fail_nomem_policy;
-		vma_set_policy(tmp, pol);
-		tmp->vm_flags &= ~VM_LOCKED;
-		tmp->vm_mm = mm;
-		tmp->vm_next = NULL;
-		anon_vma_link(tmp);
-		file = tmp->vm_file;
+		vma_set_policy(vma_new, pol);
+		vma_new->vm_flags &= ~VM_LOCKED;
+		vma_new->vm_mm = mm;
+		anon_vma_link(vma_new);
+		file = vma_new->vm_file;
 		if (file) {
 			struct inode *inode = file->f_path.dentry->d_inode;
 			get_file(file);
-			if (tmp->vm_flags & VM_DENYWRITE)
+			if (vma_new->vm_flags & VM_DENYWRITE)
 				atomic_dec(&inode->i_writecount);
       
-			/* insert tmp into the share list, just after mpnt */
+			/* insert vma_new into the share list, just after vma */
 			spin_lock(&file->f_mapping->i_mmap_lock);
-			tmp->vm_truncate_count = mpnt->vm_truncate_count;
+			vma_new->vm_truncate_count = vma->vm_truncate_count;
 			flush_dcache_mmap_lock(file->f_mapping);
-			vma_prio_tree_add(tmp, mpnt);
+			vma_prio_tree_add(vma_new, vma);
 			flush_dcache_mmap_unlock(file->f_mapping);
 			spin_unlock(&file->f_mapping->i_mmap_lock);
 		}
@@ -270,18 +263,15 @@ static inline int dup_mmap(struct mm_str
 		/*
 		 * Link in the new vma and copy the page table entries.
 		 */
-		*pprev = tmp;
-		pprev = &tmp->vm_next;
-
-		__vma_link_rb(mm, tmp, rb_link, rb_parent);
-		rb_link = &tmp->vm_rb.rb_right;
-		rb_parent = &tmp->vm_rb;
+		list_add_tail(&vma_new->vm_list, &mm->mm_vmas);
+		btree_preload(&mm->mm_btree, GFP_KERNEL|__GFP_NOFAIL);
+		__vma_link_btree(mm, vma_new);
 
 		mm->map_count++;
-		retval = copy_page_range(mm, oldmm, mpnt);
+		retval = copy_page_range(mm, oldmm, vma);
 
-		if (tmp->vm_ops && tmp->vm_ops->open)
-			tmp->vm_ops->open(tmp);
+		if (vma_new->vm_ops && vma_new->vm_ops->open)
+			vma_new->vm_ops->open(vma_new);
 
 		if (retval)
 			goto out;
@@ -293,7 +283,7 @@ out:
 	up_write(&oldmm->mmap_sem);
 	return retval;
 fail_nomem_policy:
-	kmem_cache_free(vm_area_cachep, tmp);
+	kmem_cache_free(vm_area_cachep, vma_new);
 fail_nomem:
 	retval = -ENOMEM;
 	vm_unacct_memory(charge);
@@ -321,12 +311,20 @@ static inline void mm_free_pgd(struct mm
  __cacheline_aligned_in_smp DEFINE_SPINLOCK(mmlist_lock);
 
 #define allocate_mm()	(kmem_cache_alloc(mm_cachep, GFP_KERNEL))
-#define free_mm(mm)	(kmem_cache_free(mm_cachep, (mm)))
+
+static void free_mm(struct mm_struct *mm)
+{
+	btree_root_destroy(&mm->mm_btree);
+	kmem_cache_free(mm_cachep, mm);
+}
 
 #include <linux/init_task.h>
 
 static struct mm_struct * mm_init(struct mm_struct * mm)
 {
+	INIT_LIST_HEAD(&mm->mm_vmas);
+	mm->mm_btree = BTREE_INIT(GFP_ATOMIC|__GFP_NOFAIL);
+	spin_lock_init(&mm->mm_btree_lock);
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
Index: linux-2.6/mm/madvise.c
===================================================================
--- linux-2.6.orig/mm/madvise.c
+++ linux-2.6/mm/madvise.c
@@ -141,9 +141,11 @@ static long madvise_dontneed(struct vm_a
 			.nonlinear_vma = vma,
 			.last_index = ULONG_MAX,
 		};
-		zap_page_range(vma, start, end - start, &details);
+		zap_page_range(&vma->vm_mm->mm_vmas, vma,
+				start, end - start, &details);
 	} else
-		zap_page_range(vma, start, end - start, NULL);
+		zap_page_range(&vma->vm_mm->mm_vmas, vma,
+				start, end - start, NULL);
 	return 0;
 }
 
@@ -317,7 +319,7 @@ asmlinkage long sys_madvise(unsigned lon
 		error = unmapped_error;
 		if (start >= end)
 			goto out;
-		vma = prev->vm_next;
+		vma = vma_next(prev);
 	}
 out:
 	up_write(&current->mm->mmap_sem);
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -266,11 +266,12 @@ void free_pgd_range(struct mmu_gather **
 		flush_tlb_pgtables((*tlb)->mm, start, end);
 }
 
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
+void free_pgtables(struct mmu_gather **tlb, struct list_head *vmas,
+		struct vm_area_struct *vma,
 		unsigned long floor, unsigned long ceiling)
 {
 	while (vma) {
-		struct vm_area_struct *next = vma->vm_next;
+		struct vm_area_struct *next = __vma_next(vmas, vma);
 		unsigned long addr = vma->vm_start;
 
 		/*
@@ -289,7 +290,7 @@ void free_pgtables(struct mmu_gather **t
 			while (next && next->vm_start <= vma->vm_end + PMD_SIZE
 			       && !is_vm_hugetlb_page(next)) {
 				vma = next;
-				next = vma->vm_next;
+				next = __vma_next(vmas, vma);
 				anon_vma_unlink(vma);
 				unlink_file_vma(vma);
 			}
@@ -808,7 +809,7 @@ static unsigned long unmap_page_range(st
  * ensure that any thus-far unmapped pages are flushed before unmap_vmas()
  * drops the lock and schedules.
  */
-unsigned long unmap_vmas(struct mmu_gather **tlbp,
+unsigned long unmap_vmas(struct mmu_gather **tlbp, struct list_head *vmas,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *details)
@@ -820,7 +821,7 @@ unsigned long unmap_vmas(struct mmu_gath
 	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
 	int fullmm = (*tlbp)->fullmm;
 
-	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
+	for (; vma && vma->vm_start < end_addr; vma = __vma_next(vmas, vma)) {
 		unsigned long end;
 
 		start = max(vma->vm_start, start_addr);
@@ -880,7 +881,8 @@ out:
  * @size: number of bytes to zap
  * @details: details of nonlinear truncation or shared cache invalidation
  */
-unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
+unsigned long zap_page_range(struct list_head *vmas,
+		struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *details)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -891,7 +893,7 @@ unsigned long zap_page_range(struct vm_a
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
+	end = unmap_vmas(&tlb, vmas, vma, address, end, &nr_accounted, details);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
 	return end;
@@ -1697,7 +1699,7 @@ again:
 		}
 	}
 
-	restart_addr = zap_page_range(vma, start_addr,
+	restart_addr = zap_page_range(&vma->vm_mm->mm_vmas, vma, start_addr,
 					end_addr - start_addr, details);
 	need_break = need_resched() ||
 			need_lockbreak(details->i_mmap_lock);
@@ -1932,7 +1934,7 @@ int vmtruncate_range(struct inode *inode
 void swapin_readahead(swp_entry_t entry, unsigned long addr,struct vm_area_struct *vma)
 {
 #ifdef CONFIG_NUMA
-	struct vm_area_struct *next_vma = vma ? vma->vm_next : NULL;
+	struct vm_area_struct *next_vma = vma ? vma_next(vma) : NULL;
 #endif
 	int i, num;
 	struct page *new_page;
@@ -1959,14 +1961,14 @@ void swapin_readahead(swp_entry_t entry,
 		if (vma) {
 			if (addr >= vma->vm_end) {
 				vma = next_vma;
-				next_vma = vma ? vma->vm_next : NULL;
+				next_vma = vma ? vma_next(vma) : NULL;
 			}
 			if (vma && addr < vma->vm_start)
 				vma = NULL;
 		} else {
 			if (next_vma && addr >= next_vma->vm_start) {
 				vma = next_vma;
-				next_vma = vma->vm_next;
+				next_vma = vma_next(vma);
 			}
 		}
 #endif
Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c
+++ linux-2.6/mm/mempolicy.c
@@ -348,9 +348,9 @@ check_range(struct mm_struct *mm, unsign
 	if (!first)
 		return ERR_PTR(-EFAULT);
 	prev = NULL;
-	for (vma = first; vma && vma->vm_start < end; vma = vma->vm_next) {
+	for (vma = first; vma && vma->vm_start < end; vma = vma_next(vma)) {
 		if (!(flags & MPOL_MF_DISCONTIG_OK)) {
-			if (!vma->vm_next && vma->vm_end < end)
+			if (!vma_next(vma) && vma->vm_end < end)
 				return ERR_PTR(-EFAULT);
 			if (prev && prev->vm_end < vma->vm_start)
 				return ERR_PTR(-EFAULT);
@@ -407,7 +407,7 @@ static int mbind_range(struct vm_area_st
 
 	err = 0;
 	for (; vma && vma->vm_start < end; vma = next) {
-		next = vma->vm_next;
+		next = vma_next(vma);
 		if (vma->vm_start < start)
 			err = split_vma(vma->vm_mm, vma, start, 1);
 		if (!err && vma->vm_end > end)
@@ -614,7 +614,7 @@ int migrate_to_node(struct mm_struct *mm
 	nodes_clear(nmask);
 	node_set(source, nmask);
 
-	check_range(mm, mm->mmap->vm_start, TASK_SIZE, &nmask,
+	check_range(mm, __vma_next(&mm->mm_vmas, NULL)->vm_start, TASK_SIZE, &nmask,
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
 	if (!list_empty(&pagelist))
@@ -1702,7 +1702,7 @@ void mpol_rebind_mm(struct mm_struct *mm
 	struct vm_area_struct *vma;
 
 	down_write(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 		mpol_rebind_policy(vma->vm_policy, new);
 	up_write(&mm->mmap_sem);
 }
Index: linux-2.6/mm/mlock.c
===================================================================
--- linux-2.6.orig/mm/mlock.c
+++ linux-2.6/mm/mlock.c
@@ -112,7 +112,7 @@ static int do_mlock(unsigned long start,
 		if (nstart >= end)
 			break;
 
-		vma = prev->vm_next;
+		vma = vma_next(prev);
 		if (!vma || vma->vm_start != nstart) {
 			error = -ENOMEM;
 			break;
@@ -170,7 +170,7 @@ static int do_mlockall(int flags)
 	if (flags == MCL_FUTURE)
 		goto out;
 
-	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		unsigned int newflags;
 
 		newflags = vma->vm_flags | VM_LOCKED;
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -4,6 +4,7 @@
  * Written by obz.
  *
  * Address space accounting code	<alan@redhat.com>
+ * Btree - Peter Zijlstra <pzijlstr@redhat.com>
  */
 
 #include <linux/slab.h>
@@ -34,7 +35,7 @@
 #define arch_mmap_check(addr, len, flags)	(0)
 #endif
 
-static void unmap_region(struct mm_struct *mm,
+static void unmap_region(struct mm_struct *mm, struct list_head *vmas,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end);
 
@@ -219,18 +220,16 @@ void unlink_file_vma(struct vm_area_stru
 /*
  * Close a vm structure and free it, returning the next.
  */
-static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
+static void remove_vma(struct vm_area_struct *vma)
 {
-	struct vm_area_struct *next = vma->vm_next;
-
 	might_sleep();
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file)
 		fput(vma->vm_file);
 	mpol_free(vma_policy(vma));
+	list_del(&vma->vm_list);
 	kmem_cache_free(vm_area_cachep, vma);
-	return next;
 }
 
 asmlinkage unsigned long sys_brk(unsigned long brk)
@@ -281,113 +280,42 @@ out:
 	return retval;
 }
 
-#ifdef DEBUG_MM_RB
-static int browse_rb(struct rb_root *root)
-{
-	int i = 0, j;
-	struct rb_node *nd, *pn = NULL;
-	unsigned long prev = 0, pend = 0;
-
-	for (nd = rb_first(root); nd; nd = rb_next(nd)) {
-		struct vm_area_struct *vma;
-		vma = rb_entry(nd, struct vm_area_struct, vm_rb);
-		if (vma->vm_start < prev)
-			printk("vm_start %lx prev %lx\n", vma->vm_start, prev), i = -1;
-		if (vma->vm_start < pend)
-			printk("vm_start %lx pend %lx\n", vma->vm_start, pend);
-		if (vma->vm_start > vma->vm_end)
-			printk("vm_end %lx < vm_start %lx\n", vma->vm_end, vma->vm_start);
-		i++;
-		pn = nd;
-	}
-	j = 0;
-	for (nd = pn; nd; nd = rb_prev(nd)) {
-		j++;
-	}
-	if (i != j)
-		printk("backwards %d, forwards %d\n", j, i), i = 0;
-	return i;
-}
-
-void validate_mm(struct mm_struct *mm)
-{
-	int bug = 0;
-	int i = 0;
-	struct vm_area_struct *tmp = mm->mmap;
-	while (tmp) {
-		tmp = tmp->vm_next;
-		i++;
-	}
-	if (i != mm->map_count)
-		printk("map_count %d vm_next %d\n", mm->map_count, i), bug = 1;
-	i = browse_rb(&mm->mm_rb);
-	if (i != mm->map_count)
-		printk("map_count %d rb %d\n", mm->map_count, i), bug = 1;
-	BUG_ON(bug);
-}
-#else
 #define validate_mm(mm) do { } while (0)
-#endif
 
 static struct vm_area_struct *
 find_vma_prepare(struct mm_struct *mm, unsigned long addr,
-		struct vm_area_struct **pprev, struct rb_node ***rb_link,
-		struct rb_node ** rb_parent)
+		struct vm_area_struct **pprev)
 {
-	struct vm_area_struct * vma;
-	struct rb_node ** __rb_link, * __rb_parent, * rb_prev;
-
-	__rb_link = &mm->mm_rb.rb_node;
-	rb_prev = __rb_parent = NULL;
-	vma = NULL;
-
-	while (*__rb_link) {
-		struct vm_area_struct *vma_tmp;
-
-		__rb_parent = *__rb_link;
-		vma_tmp = rb_entry(__rb_parent, struct vm_area_struct, vm_rb);
-
-		if (vma_tmp->vm_end > addr) {
-			vma = vma_tmp;
-			if (vma_tmp->vm_start <= addr)
-				return vma;
-			__rb_link = &__rb_parent->rb_left;
-		} else {
-			rb_prev = __rb_parent;
-			__rb_link = &__rb_parent->rb_right;
-		}
-	}
-
-	*pprev = NULL;
-	if (rb_prev)
-		*pprev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
-	*rb_link = __rb_link;
-	*rb_parent = __rb_parent;
+	struct vm_area_struct *vma, *prev = NULL;
+	vma = btree_stab(&mm->mm_btree, addr);
+	if (!vma || addr >= vma->vm_end)
+		vma = __vma_next(&mm->mm_vmas, vma);
+	if (!(vma && addr < vma->vm_end))
+		prev = __vma_prev(&mm->mm_vmas, vma);
+	*pprev = prev;
 	return vma;
 }
 
 static inline void
 __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
-		struct vm_area_struct *prev, struct rb_node *rb_parent)
+		struct vm_area_struct *prev)
 {
-	if (prev) {
-		vma->vm_next = prev->vm_next;
-		prev->vm_next = vma;
-	} else {
-		mm->mmap = vma;
-		if (rb_parent)
-			vma->vm_next = rb_entry(rb_parent,
-					struct vm_area_struct, vm_rb);
-		else
-			vma->vm_next = NULL;
-	}
+	if (!prev)
+		prev = btree_stab(&mm->mm_btree, vma->vm_start);
+
+	if (prev)
+		list_add(&vma->vm_list, &prev->vm_list);
+	else
+		list_add(&vma->vm_list, &mm->mm_vmas);
 }
 
-void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
-		struct rb_node **rb_link, struct rb_node *rb_parent)
+void __vma_link_btree(struct mm_struct *mm, struct vm_area_struct *vma)
 {
-	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
-	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
+	int err;
+	spin_lock(&mm->mm_btree_lock);
+	err = btree_insert(&mm->mm_btree, vma->vm_start, vma);
+	spin_unlock(&mm->mm_btree_lock);
+	BUG_ON(err);
 }
 
 static inline void __vma_link_file(struct vm_area_struct *vma)
@@ -414,20 +342,20 @@ static inline void __vma_link_file(struc
 
 static void
 __vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
-	struct vm_area_struct *prev, struct rb_node **rb_link,
-	struct rb_node *rb_parent)
+	struct vm_area_struct *prev)
 {
-	__vma_link_list(mm, vma, prev, rb_parent);
-	__vma_link_rb(mm, vma, rb_link, rb_parent);
+	__vma_link_list(mm, vma, prev);
+	__vma_link_btree(mm, vma);
 	__anon_vma_link(vma);
 }
 
 static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
-			struct vm_area_struct *prev, struct rb_node **rb_link,
-			struct rb_node *rb_parent)
+			struct vm_area_struct *prev)
 {
 	struct address_space *mapping = NULL;
 
+	btree_preload(&mm->mm_btree, GFP_KERNEL|__GFP_NOFAIL);
+
 	if (vma->vm_file)
 		mapping = vma->vm_file->f_mapping;
 
@@ -437,7 +365,7 @@ static void vma_link(struct mm_struct *m
 	}
 	anon_vma_lock(vma);
 
-	__vma_link(mm, vma, prev, rb_link, rb_parent);
+	__vma_link(mm, vma, prev);
 	__vma_link_file(vma);
 
 	anon_vma_unlock(vma);
@@ -456,12 +384,7 @@ static void vma_link(struct mm_struct *m
 static void
 __insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
 {
-	struct vm_area_struct * __vma, * prev;
-	struct rb_node ** rb_link, * rb_parent;
-
-	__vma = find_vma_prepare(mm, vma->vm_start,&prev, &rb_link, &rb_parent);
-	BUG_ON(__vma && __vma->vm_start < vma->vm_end);
-	__vma_link(mm, vma, prev, rb_link, rb_parent);
+	__vma_link(mm, vma, NULL);
 	mm->map_count++;
 }
 
@@ -469,8 +392,12 @@ static inline void
 __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev)
 {
-	prev->vm_next = vma->vm_next;
-	rb_erase(&vma->vm_rb, &mm->mm_rb);
+	struct vm_area_struct *vma_tmp;
+	list_del(&vma->vm_list);
+	spin_lock(&mm->mm_btree_lock);
+	vma_tmp = btree_remove(&mm->mm_btree, vma->vm_start);
+	spin_unlock(&mm->mm_btree_lock);
+	BUG_ON(vma_tmp != vma);
 	if (mm->mmap_cache == vma)
 		mm->mmap_cache = prev;
 }
@@ -486,7 +413,7 @@ void vma_adjust(struct vm_area_struct *v
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct vm_area_struct *next = vma->vm_next;
+	struct vm_area_struct *next = vma_next(vma);
 	struct vm_area_struct *importer = NULL;
 	struct address_space *mapping = NULL;
 	struct prio_tree_root *root = NULL;
@@ -525,6 +452,8 @@ again:			remove_next = 1 + (end > next->
 		}
 	}
 
+	btree_preload(&mm->mm_btree, GFP_KERNEL|__GFP_NOFAIL);
+
 	if (file) {
 		mapping = file->f_mapping;
 		if (!(vma->vm_flags & VM_NONLINEAR))
@@ -576,12 +505,20 @@ again:			remove_next = 1 + (end > next->
 			vma_prio_tree_remove(next, root);
 	}
 
+	spin_lock(&mm->mm_btree_lock);
+	btree_update(&mm->mm_btree, vma->vm_start, start);
 	vma->vm_start = start;
 	vma->vm_end = end;
 	vma->vm_pgoff = pgoff;
+	spin_unlock(&mm->mm_btree_lock);
+
 	if (adjust_next) {
+		spin_lock(&mm->mm_btree_lock);
+		btree_update(&mm->mm_btree, next->vm_start,
+				next->vm_start + (adjust_next << PAGE_SHIFT));
 		next->vm_start += adjust_next << PAGE_SHIFT;
 		next->vm_pgoff += adjust_next;
+		spin_unlock(&mm->mm_btree_lock);
 	}
 
 	if (root) {
@@ -627,7 +564,7 @@ again:			remove_next = 1 + (end > next->
 		 * up the code too much to do both in one go.
 		 */
 		if (remove_next == 2) {
-			next = vma->vm_next;
+			next = vma_next(vma);
 			goto again;
 		}
 	}
@@ -748,13 +685,10 @@ struct vm_area_struct *vma_merge(struct 
 	if (vm_flags & VM_SPECIAL)
 		return NULL;
 
-	if (prev)
-		next = prev->vm_next;
-	else
-		next = mm->mmap;
+	next = __vma_next(&mm->mm_vmas, prev);
 	area = next;
 	if (next && next->vm_end == end)		/* cases 6, 7, 8 */
-		next = next->vm_next;
+		next = __vma_next(&mm->mm_vmas, next);
 
 	/*
 	 * Can it merge with the predecessor?
@@ -813,7 +747,7 @@ struct anon_vma *find_mergeable_anon_vma
 	struct vm_area_struct *near;
 	unsigned long vm_flags;
 
-	near = vma->vm_next;
+	near = vma_next(vma);
 	if (!near)
 		goto try_prev;
 
@@ -896,7 +830,6 @@ unsigned long do_mmap_pgoff(struct file 
 	unsigned int vm_flags;
 	int correct_wcount = 0;
 	int error;
-	struct rb_node ** rb_link, * rb_parent;
 	int accountable = 1;
 	unsigned long charged = 0, reqprot = prot;
 
@@ -1027,7 +960,7 @@ unsigned long do_mmap_pgoff(struct file 
 	/* Clear old maps */
 	error = -ENOMEM;
 munmap_back:
-	vma = find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
+	vma = find_vma_prepare(mm, addr, &prev);
 	if (vma && vma->vm_start < addr + len) {
 		if (do_munmap(mm, addr, len))
 			return -ENOMEM;
@@ -1128,7 +1061,7 @@ munmap_back:
 	if (!file || !vma_merge(mm, prev, addr, vma->vm_end,
 			vma->vm_flags, NULL, file, pgoff, vma_policy(vma))) {
 		file = vma->vm_file;
-		vma_link(mm, vma, prev, rb_link, rb_parent);
+		vma_link(mm, vma, prev);
 		if (correct_wcount)
 			atomic_inc(&inode->i_writecount);
 	} else {
@@ -1162,7 +1095,7 @@ unmap_and_free_vma:
 	fput(file);
 
 	/* Undo any partial mapping done by a device driver. */
-	unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);
+	unmap_region(mm, &mm->mm_vmas, vma, prev, vma->vm_start, vma->vm_end);
 	charged = 0;
 free_vma:
 	kmem_cache_free(vm_area_cachep, vma);
@@ -1212,7 +1145,7 @@ arch_get_unmapped_area(struct file *filp
 	}
 
 full_search:
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = __vma_next(&mm->mm_vmas, vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
@@ -1405,25 +1338,11 @@ struct vm_area_struct * find_vma(struct 
 		/* (Cache hit rate is typically around 35%.) */
 		vma = mm->mmap_cache;
 		if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
-			struct rb_node * rb_node;
-
-			rb_node = mm->mm_rb.rb_node;
-			vma = NULL;
-
-			while (rb_node) {
-				struct vm_area_struct * vma_tmp;
+			vma = btree_stab(&mm->mm_btree, addr);
+			/* addr < vm_end */
+			if (!vma || addr >= vma->vm_end)
+				vma = __vma_next(&mm->mm_vmas, vma);
 
-				vma_tmp = rb_entry(rb_node,
-						struct vm_area_struct, vm_rb);
-
-				if (vma_tmp->vm_end > addr) {
-					vma = vma_tmp;
-					if (vma_tmp->vm_start <= addr)
-						break;
-					rb_node = rb_node->rb_left;
-				} else
-					rb_node = rb_node->rb_right;
-			}
 			if (vma)
 				mm->mmap_cache = vma;
 		}
@@ -1438,34 +1357,10 @@ struct vm_area_struct *
 find_vma_prev(struct mm_struct *mm, unsigned long addr,
 			struct vm_area_struct **pprev)
 {
-	struct vm_area_struct *vma = NULL, *prev = NULL;
-	struct rb_node * rb_node;
-	if (!mm)
-		goto out;
-
-	/* Guard against addr being lower than the first VMA */
-	vma = mm->mmap;
-
-	/* Go through the RB tree quickly. */
-	rb_node = mm->mm_rb.rb_node;
-
-	while (rb_node) {
-		struct vm_area_struct *vma_tmp;
-		vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
-
-		if (addr < vma_tmp->vm_end) {
-			rb_node = rb_node->rb_left;
-		} else {
-			prev = vma_tmp;
-			if (!prev->vm_next || (addr < prev->vm_next->vm_end))
-				break;
-			rb_node = rb_node->rb_right;
-		}
-	}
-
-out:
-	*pprev = prev;
-	return prev ? prev->vm_next : vma;
+	struct vm_area_struct *vma;
+	vma = find_vma(mm, addr);
+	*pprev = __vma_prev(&mm->mm_vmas, vma);
+	return vma;
 }
 
 /*
@@ -1621,8 +1516,22 @@ int expand_stack(struct vm_area_struct *
 
 		error = acct_stack_growth(vma, size, grow);
 		if (!error) {
+			struct mm_struct *mm = vma->vm_mm;
+			/*
+			 * This is the whole reason for mm_btree_lock; here we
+			 * do not hold the write lock.
+			 *
+			 * It does two things, it serializes modifications to
+			 * the btree and keeps vma->vm_start in sync with the
+			 * value its indexed on in the btree. Hence the
+			 * assignment is done under the lock. Without this the
+			 * various btree_remove calls might not find the vma.
+			 */
+			spin_lock(&mm->mm_btree_lock);
+			btree_update(&mm->mm_btree, vma->vm_start, address);
 			vma->vm_start = address;
 			vma->vm_pgoff -= grow;
+			spin_unlock(&mm->mm_btree_lock);
 		}
 	}
 	anon_vma_unlock(vma);
@@ -1659,18 +1568,21 @@ find_extend_vma(struct mm_struct * mm, u
  *
  * Called with the mm semaphore held.
  */
-static void remove_vma_list(struct mm_struct *mm, struct vm_area_struct *vma)
+static void remove_vma_list(struct mm_struct *mm, struct list_head *vmas,
+		struct vm_area_struct *vma)
 {
 	/* Update high watermark before we lower total_vm */
 	update_hiwater_vm(mm);
 	do {
+		struct vm_area_struct *next = __vma_next(vmas, vma);
 		long nrpages = vma_pages(vma);
 
 		mm->total_vm -= nrpages;
 		if (vma->vm_flags & VM_LOCKED)
 			mm->locked_vm -= nrpages;
 		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
-		vma = remove_vma(vma);
+		remove_vma(vma);
+		vma = next;
 	} while (vma);
 	validate_mm(mm);
 }
@@ -1680,21 +1592,22 @@ static void remove_vma_list(struct mm_st
  *
  * Called with the mm semaphore held.
  */
-static void unmap_region(struct mm_struct *mm,
+static void unmap_region(struct mm_struct *mm, struct list_head *vmas,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end)
 {
-	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
+	struct vm_area_struct *next = __vma_next(vmas, prev);
 	struct mmu_gather *tlb;
 	unsigned long nr_accounted = 0;
 
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
+	unmap_vmas(&tlb, vmas, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
-				 next? next->vm_start: 0);
+	free_pgtables(&tlb, vmas, vma,
+			prev? prev->vm_end: FIRST_USER_ADDRESS,
+			next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
 }
 
@@ -1704,21 +1617,27 @@ static void unmap_region(struct mm_struc
  */
 static void
 detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
-	struct vm_area_struct *prev, unsigned long end)
+	struct vm_area_struct *prev, unsigned long end, struct list_head *vmas)
 {
-	struct vm_area_struct **insertion_point;
-	struct vm_area_struct *tail_vma = NULL;
 	unsigned long addr;
 
-	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
 	do {
-		rb_erase(&vma->vm_rb, &mm->mm_rb);
+		struct vm_area_struct *vma_tmp;
+		btree_preload(&mm->mm_btree, GFP_KERNEL|__GFP_NOFAIL);
+		spin_lock(&mm->mm_btree_lock);
+		vma_tmp = btree_remove(&mm->mm_btree, vma->vm_start);
+		spin_unlock(&mm->mm_btree_lock);
+		if (vma_tmp != vma) {
+			printk(KERN_DEBUG "btree_remove(%lu): %p\n", vma->vm_start, vma);
+			printk(KERN_DEBUG "btree_remove returned: %p\n", vma_tmp);
+			btree_print(&mm->mm_btree);
+			BUG();
+		}
+		vma_tmp = __vma_next(&mm->mm_vmas, vma);
+		list_move_tail(&vma->vm_list, vmas);
 		mm->map_count--;
-		tail_vma = vma;
-		vma = vma->vm_next;
+		vma = vma_tmp;
 	} while (vma && vma->vm_start < end);
-	*insertion_point = vma;
-	tail_vma->vm_next = NULL;
 	if (mm->unmap_area == arch_unmap_area)
 		addr = prev ? prev->vm_start : mm->mmap_base;
 	else
@@ -1788,6 +1707,7 @@ int do_munmap(struct mm_struct *mm, unsi
 {
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
+	LIST_HEAD(vmas);
 
 	if ((start & ~PAGE_MASK) || start > TASK_SIZE || len > TASK_SIZE-start)
 		return -EINVAL;
@@ -1827,16 +1747,16 @@ int do_munmap(struct mm_struct *mm, unsi
 		if (error)
 			return error;
 	}
-	vma = prev? prev->vm_next: mm->mmap;
+	vma = __vma_next(&mm->mm_vmas, prev);
 
 	/*
 	 * Remove the vma's, and unmap the actual pages
 	 */
-	detach_vmas_to_be_unmapped(mm, vma, prev, end);
-	unmap_region(mm, vma, prev, start, end);
+	detach_vmas_to_be_unmapped(mm, vma, prev, end, &vmas);
+	unmap_region(mm, &vmas, vma, prev, start, end);
 
 	/* Fix up all other VM information */
-	remove_vma_list(mm, vma);
+	remove_vma_list(mm, &vmas, vma);
 
 	return 0;
 }
@@ -1876,7 +1796,6 @@ unsigned long do_brk(unsigned long addr,
 	struct mm_struct * mm = current->mm;
 	struct vm_area_struct * vma, * prev;
 	unsigned long flags;
-	struct rb_node ** rb_link, * rb_parent;
 	pgoff_t pgoff = addr >> PAGE_SHIFT;
 	int error;
 
@@ -1919,7 +1838,7 @@ unsigned long do_brk(unsigned long addr,
 	 * Clear old maps.  this also does some error checking for us
 	 */
  munmap_back:
-	vma = find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
+	vma = find_vma_prepare(mm, addr, &prev);
 	if (vma && vma->vm_start < addr + len) {
 		if (do_munmap(mm, addr, len))
 			return -ENOMEM;
@@ -1957,7 +1876,7 @@ unsigned long do_brk(unsigned long addr,
 	vma->vm_flags = flags;
 	vma->vm_page_prot = protection_map[flags &
 				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)];
-	vma_link(mm, vma, prev, rb_link, rb_parent);
+	vma_link(mm, vma, prev);
 out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
@@ -1969,30 +1888,42 @@ out:
 
 EXPORT_SYMBOL(do_brk);
 
+static void vma_list_print(struct list_head *head)
+{
+	struct vm_area_struct *vma;
+	printk(KERN_DEBUG "vma list\n");
+	list_for_each_entry(vma, head, vm_list)
+		printk(KERN_DEBUG"  vma: %p start: %lx end %lx\n",
+				vma, vma->vm_start, vma->vm_end);
+}
+
 /* Release all mmaps. */
 void exit_mmap(struct mm_struct *mm)
 {
 	struct mmu_gather *tlb;
-	struct vm_area_struct *vma = mm->mmap;
+	LIST_HEAD(vmas);
+	struct vm_area_struct *vma = __vma_next(&mm->mm_vmas, NULL);
+	struct vm_area_struct *next;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
 
 	lru_add_drain();
 	flush_cache_mm(mm);
+	detach_vmas_to_be_unmapped(mm, vma, NULL, -1, &vmas);
 	tlb = tlb_gather_mmu(mm, 1);
 	/* Don't update_hiwater_rss(mm) here, do_exit already did */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
+	end = unmap_vmas(&tlb, &vmas, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
+	free_pgtables(&tlb, &vmas, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
 	 * with preemption enabled, without holding any MM locks.
 	 */
-	while (vma)
-		vma = remove_vma(vma);
+	list_for_each_entry_safe(vma, next, &vmas, vm_list)
+		remove_vma(vma);
 
 	BUG_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
 }
@@ -2004,7 +1935,6 @@ void exit_mmap(struct mm_struct *mm)
 int insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
 {
 	struct vm_area_struct * __vma, * prev;
-	struct rb_node ** rb_link, * rb_parent;
 
 	/*
 	 * The vm_pgoff of a purely anonymous vma should be irrelevant
@@ -2022,13 +1952,13 @@ int insert_vm_struct(struct mm_struct * 
 		BUG_ON(vma->anon_vma);
 		vma->vm_pgoff = vma->vm_start >> PAGE_SHIFT;
 	}
-	__vma = find_vma_prepare(mm,vma->vm_start,&prev,&rb_link,&rb_parent);
+	__vma = find_vma_prepare(mm, vma->vm_start, &prev);
 	if (__vma && __vma->vm_start < vma->vm_end)
 		return -ENOMEM;
 	if ((vma->vm_flags & VM_ACCOUNT) &&
 	     security_vm_enough_memory(vma_pages(vma)))
 		return -ENOMEM;
-	vma_link(mm, vma, prev, rb_link, rb_parent);
+	vma_link(mm, vma, prev);
 	return 0;
 }
 
@@ -2043,7 +1973,6 @@ struct vm_area_struct *copy_vma(struct v
 	unsigned long vma_start = vma->vm_start;
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *new_vma, *prev;
-	struct rb_node **rb_link, *rb_parent;
 	struct mempolicy *pol;
 
 	/*
@@ -2053,7 +1982,7 @@ struct vm_area_struct *copy_vma(struct v
 	if (!vma->vm_file && !vma->anon_vma)
 		pgoff = addr >> PAGE_SHIFT;
 
-	find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
+	find_vma_prepare(mm, addr, &prev);
 	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
 			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
 	if (new_vma) {
@@ -2080,7 +2009,7 @@ struct vm_area_struct *copy_vma(struct v
 				get_file(new_vma->vm_file);
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
-			vma_link(mm, new_vma, prev, rb_link, rb_parent);
+			vma_link(mm, new_vma, prev);
 		}
 	}
 	return new_vma;
Index: linux-2.6/mm/mprotect.c
===================================================================
--- linux-2.6.orig/mm/mprotect.c
+++ linux-2.6/mm/mprotect.c
@@ -302,7 +302,7 @@ sys_mprotect(unsigned long start, size_t
 		if (nstart >= end)
 			goto out;
 
-		vma = prev->vm_next;
+		vma = vma_next(prev);
 		if (!vma || vma->vm_start != nstart) {
 			error = -ENOMEM;
 			goto out;
Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c
+++ linux-2.6/mm/mremap.c
@@ -226,7 +226,7 @@ static unsigned long move_vma(struct vm_
 	if (excess) {
 		vma->vm_flags |= VM_ACCOUNT;
 		if (split)
-			vma->vm_next->vm_flags |= VM_ACCOUNT;
+			vma_next(vma)->vm_flags |= VM_ACCOUNT;
 	}
 
 	if (vm_flags & VM_LOCKED) {
@@ -356,8 +356,9 @@ unsigned long do_mremap(unsigned long ad
 	    !((flags & MREMAP_FIXED) && (addr != new_addr)) &&
 	    (old_len != new_len || !(flags & MREMAP_MAYMOVE))) {
 		unsigned long max_addr = TASK_SIZE;
-		if (vma->vm_next)
-			max_addr = vma->vm_next->vm_start;
+		struct vm_area_struct *next = vma_next(vma);
+		if (next)
+			max_addr = next->vm_start;
 		/* can we just expand the current mapping? */
 		if (max_addr - addr >= new_len) {
 			int pages = (new_len - old_len) >> PAGE_SHIFT;
Index: linux-2.6/mm/msync.c
===================================================================
--- linux-2.6.orig/mm/msync.c
+++ linux-2.6/mm/msync.c
@@ -92,7 +92,7 @@ asmlinkage long sys_msync(unsigned long 
 				error = 0;
 				goto out_unlock;
 			}
-			vma = vma->vm_next;
+			vma = __vma_next(&mm->mm_vmas, vma);
 		}
 	}
 out_unlock:
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c
+++ linux-2.6/mm/swapfile.c
@@ -626,7 +626,7 @@ static int unuse_mm(struct mm_struct *mm
 		down_read(&mm->mmap_sem);
 		lock_page(page);
 	}
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (vma->anon_vma && unuse_vma(vma, entry, page))
 			break;
 	}
Index: linux-2.6/Makefile
===================================================================
--- linux-2.6.orig/Makefile
+++ linux-2.6/Makefile
@@ -1,7 +1,7 @@
 VERSION = 2
 PATCHLEVEL = 6
 SUBLEVEL = 20
-EXTRAVERSION =
+EXTRAVERSION =-btree
 NAME = Homicidal Dwarf Hamster
 
 # *DOCUMENTATION*
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -993,7 +993,7 @@ int migrate_vmas(struct mm_struct *mm, c
  	struct vm_area_struct *vma;
  	int err = 0;
 
- 	for(vma = mm->mmap; vma->vm_next && !err; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
  		if (vma->vm_ops && vma->vm_ops->migrate) {
  			err = vma->vm_ops->migrate(vma, to, from, flags);
  			if (err)
Index: linux-2.6/arch/alpha/kernel/osf_sys.c
===================================================================
--- linux-2.6.orig/arch/alpha/kernel/osf_sys.c
+++ linux-2.6/arch/alpha/kernel/osf_sys.c
@@ -1247,7 +1247,7 @@ arch_get_unmapped_area_1(unsigned long a
 		if (!vma || addr + len <= vma->vm_start)
 			return addr;
 		addr = vma->vm_end;
-		vma = vma->vm_next;
+		vma = vma_next(vma);
 	}
 }
 
Index: linux-2.6/arch/arm/mm/mmap.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/mmap.c
+++ linux-2.6/arch/arm/mm/mmap.c
@@ -85,7 +85,7 @@ full_search:
 	else
 		addr = PAGE_ALIGN(addr);
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
Index: linux-2.6/arch/frv/mm/elf-fdpic.c
===================================================================
--- linux-2.6.orig/arch/frv/mm/elf-fdpic.c
+++ linux-2.6/arch/frv/mm/elf-fdpic.c
@@ -81,7 +81,7 @@ unsigned long arch_get_unmapped_area(str
 
 		if (addr <= limit) {
 			vma = find_vma(current->mm, PAGE_SIZE);
-			for (; vma; vma = vma->vm_next) {
+			for (; vma; vma = vma_next(vma)) {
 				if (addr > limit)
 					break;
 				if (addr + len <= vma->vm_start)
@@ -96,7 +96,7 @@ unsigned long arch_get_unmapped_area(str
 	limit = TASK_SIZE - len;
 	if (addr <= limit) {
 		vma = find_vma(current->mm, addr);
-		for (; vma; vma = vma->vm_next) {
+		for (; vma; vma = vma_next(vma)) {
 			if (addr > limit)
 				break;
 			if (addr + len <= vma->vm_start)
Index: linux-2.6/arch/ia64/kernel/sys_ia64.c
===================================================================
--- linux-2.6.orig/arch/ia64/kernel/sys_ia64.c
+++ linux-2.6/arch/ia64/kernel/sys_ia64.c
@@ -52,7 +52,7 @@ arch_get_unmapped_area (struct file *fil
   full_search:
 	start_addr = addr = (addr + align_mask) & ~align_mask;
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr || RGN_MAP_LIMIT - len < REGION_OFFSET(addr)) {
 			if (start_addr != TASK_UNMAPPED_BASE) {
Index: linux-2.6/arch/ia64/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/ia64/mm/hugetlbpage.c
+++ linux-2.6/arch/ia64/mm/hugetlbpage.c
@@ -153,7 +153,7 @@ unsigned long hugetlb_get_unmapped_area(
 		addr = HPAGE_REGION_BASE;
 	else
 		addr = ALIGN(addr, HPAGE_SIZE);
-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+	for (vmm = find_vma(current->mm, addr); ; vmm = vma_next(vma)) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
 		if (REGION_OFFSET(addr) + len > RGN_MAP_LIMIT)
 			return -ENOMEM;
Index: linux-2.6/arch/mips/kernel/irixelf.c
===================================================================
--- linux-2.6.orig/arch/mips/kernel/irixelf.c
+++ linux-2.6/arch/mips/kernel/irixelf.c
@@ -686,7 +686,7 @@ static int load_irix_binary(struct linux
 	/* OK, This is the point of no return */
 	current->mm->end_data = 0;
 	current->mm->end_code = 0;
-	current->mm->mmap = NULL;
+	INIT_LIST_HEAD(&current->mm->mm_vmas);
 	current->flags &= ~PF_FORKNOEXEC;
 	elf_entry = (unsigned int) elf_ex.e_entry;
 
@@ -1080,7 +1080,7 @@ static int irix_core_dump(long signr, st
 	/* Count what's needed to dump, up to the limit of coredump size. */
 	segs = 0;
 	size = 0;
-	for (vma = current->mm->mmap; vma != NULL; vma = vma->vm_next) {
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		if (maydump(vma))
 		{
 			int sz = vma->vm_end-vma->vm_start;
@@ -1241,12 +1241,13 @@ static int irix_core_dump(long signr, st
 	dataoff = offset = roundup(offset, PAGE_SIZE);
 
 	/* Write program headers for segments dump. */
-	for(vma = current->mm->mmap, i = 0;
-		i < segs && vma != NULL; vma = vma->vm_next) {
+	i = 0
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		struct elf_phdr phdr;
 		size_t sz;
 
-		i++;
+		if (i++ == segs)
+			break;
 
 		sz = vma->vm_end - vma->vm_start;
 
@@ -1275,15 +1276,16 @@ static int irix_core_dump(long signr, st
 
 	DUMP_SEEK(dataoff);
 
-	for(i = 0, vma = current->mm->mmap;
-	    i < segs && vma != NULL;
-	    vma = vma->vm_next) {
+	i = 0
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		unsigned long addr = vma->vm_start;
 		unsigned long len = vma->vm_end - vma->vm_start;
 
 		if (!maydump(vma))
 			continue;
-		i++;
+
+		if (i++ == segs)
+			break;
 #ifdef DEBUG
 		printk("elf_core_dump: writing %08lx %lx\n", addr, len);
 #endif
Index: linux-2.6/arch/mips/kernel/syscall.c
===================================================================
--- linux-2.6.orig/arch/mips/kernel/syscall.c
+++ linux-2.6/arch/mips/kernel/syscall.c
@@ -104,7 +104,7 @@ unsigned long arch_get_unmapped_area(str
 	else
 		addr = PAGE_ALIGN(addr);
 
-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+	for (vmm = find_vma(current->mm, addr); ; vmm = vma_next(vmm)) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
 		if (task_size - len < addr)
 			return -ENOMEM;
Index: linux-2.6/arch/parisc/kernel/sys_parisc.c
===================================================================
--- linux-2.6.orig/arch/parisc/kernel/sys_parisc.c
+++ linux-2.6/arch/parisc/kernel/sys_parisc.c
@@ -53,7 +53,7 @@ static unsigned long get_unshared_area(u
 
 	addr = PAGE_ALIGN(addr);
 
-	for (vma = find_vma(current->mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(current->mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr)
 			return -ENOMEM;
@@ -89,7 +89,7 @@ static unsigned long get_shared_area(str
 
 	addr = DCACHE_ALIGN(addr - offset) + offset;
 
-	for (vma = find_vma(current->mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(current->mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr)
 			return -ENOMEM;
Index: linux-2.6/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/hugetlbpage.c
+++ linux-2.6/arch/powerpc/mm/hugetlbpage.c
@@ -608,7 +608,7 @@ full_search:
 		if (addr + mm->cached_hole_size < vma->vm_start)
 		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = vma->vm_end;
-		vma = vma->vm_next;
+		vma = vma_next(vma);
 	}
 
 	/* Make sure we didn't miss any holes */
Index: linux-2.6/arch/powerpc/mm/tlb_32.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/tlb_32.c
+++ linux-2.6/arch/powerpc/mm/tlb_32.c
@@ -154,7 +154,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 	 * unmap_region or exit_mmap, but not from vmtruncate on SMP -
 	 * but it seems dup_mmap is the only SMP case which gets here.
 	 */
-	for (mp = mm->mmap; mp != NULL; mp = mp->vm_next)
+	list_for_each_entry(mp, &mm->mm_vmas, vm_list)
 		flush_range(mp->vm_mm, mp->vm_start, mp->vm_end);
 	FINISH_FLUSH;
 }
Index: linux-2.6/arch/ppc/mm/tlb.c
===================================================================
--- linux-2.6.orig/arch/ppc/mm/tlb.c
+++ linux-2.6/arch/ppc/mm/tlb.c
@@ -148,7 +148,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 		return;
 	}
 
-	for (mp = mm->mmap; mp != NULL; mp = mp->vm_next)
+	list_for_each_entry(mp, &mm->mm_vmas, vm_list)
 		flush_range(mp->vm_mm, mp->vm_start, mp->vm_end);
 	FINISH_FLUSH;
 }
Index: linux-2.6/arch/sh/kernel/sys_sh.c
===================================================================
--- linux-2.6.orig/arch/sh/kernel/sys_sh.c
+++ linux-2.6/arch/sh/kernel/sys_sh.c
@@ -108,7 +108,7 @@ full_search:
 	else
 		addr = PAGE_ALIGN(mm->free_area_cache);
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (unlikely(TASK_SIZE - len < addr)) {
 			/*
Index: linux-2.6/arch/sh/mm/cache-sh4.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/cache-sh4.c
+++ linux-2.6/arch/sh/mm/cache-sh4.c
@@ -395,7 +395,7 @@ void flush_cache_mm(struct mm_struct *mm
 		 * In this case there are reasonably sized ranges to flush,
 		 * iterate through the VMA list and take care of any aliases.
 		 */
-		for (vma = mm->mmap; vma; vma = vma->vm_next)
+		list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 			__flush_cache_mm(mm, vma->vm_start, vma->vm_end);
 	}
 
Index: linux-2.6/arch/sh64/kernel/sys_sh64.c
===================================================================
--- linux-2.6.orig/arch/sh64/kernel/sys_sh64.c
+++ linux-2.6/arch/sh64/kernel/sys_sh64.c
@@ -120,7 +120,7 @@ unsigned long arch_get_unmapped_area(str
 	else
 		addr = COLOUR_ALIGN(addr);
 
-	for (vma = find_vma(current->mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(current->mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr)
 			return -ENOMEM;
Index: linux-2.6/arch/sparc/kernel/sys_sparc.c
===================================================================
--- linux-2.6.orig/arch/sparc/kernel/sys_sparc.c
+++ linux-2.6/arch/sparc/kernel/sys_sparc.c
@@ -64,7 +64,7 @@ unsigned long arch_get_unmapped_area(str
 	else
 		addr = PAGE_ALIGN(addr);
 
-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+	for (vmm = find_vma(current->mm, addr); ; vmm = vma_next(vmm)) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
 		if (ARCH_SUN4C_SUN4 && addr < 0xe0000000 && 0x20000000 - len < addr) {
 			addr = PAGE_OFFSET;
Index: linux-2.6/arch/sparc64/kernel/binfmt_aout32.c
===================================================================
--- linux-2.6.orig/arch/sparc64/kernel/binfmt_aout32.c
+++ linux-2.6/arch/sparc64/kernel/binfmt_aout32.c
@@ -242,7 +242,7 @@ static int load_aout32_binary(struct lin
 	current->mm->free_area_cache = current->mm->mmap_base;
 	current->mm->cached_hole_size = 0;
 
-	current->mm->mmap = NULL;
+	LIST_HEAD_INIT(&current->mm->mm_vmas);
 	compute_creds(bprm);
  	current->flags &= ~PF_FORKNOEXEC;
 	if (N_MAGIC(ex) == NMAGIC) {
Index: linux-2.6/arch/sparc64/kernel/sys_sparc.c
===================================================================
--- linux-2.6.orig/arch/sparc64/kernel/sys_sparc.c
+++ linux-2.6/arch/sparc64/kernel/sys_sparc.c
@@ -167,7 +167,7 @@ full_search:
 	else
 		addr = PAGE_ALIGN(addr);
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (addr < VA_EXCLUDE_START &&
 		    (addr + len) >= VA_EXCLUDE_START) {
Index: linux-2.6/arch/sparc64/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/sparc64/mm/hugetlbpage.c
+++ linux-2.6/arch/sparc64/mm/hugetlbpage.c
@@ -55,7 +55,7 @@ static unsigned long hugetlb_get_unmappe
 full_search:
 	addr = ALIGN(addr, HPAGE_SIZE);
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (addr < VA_EXCLUDE_START &&
 		    (addr + len) >= VA_EXCLUDE_START) {
Index: linux-2.6/arch/x86_64/ia32/ia32_aout.c
===================================================================
--- linux-2.6.orig/arch/x86_64/ia32/ia32_aout.c
+++ linux-2.6/arch/x86_64/ia32/ia32_aout.c
@@ -311,7 +311,7 @@ static int load_aout_binary(struct linux
 	current->mm->free_area_cache = TASK_UNMAPPED_BASE;
 	current->mm->cached_hole_size = 0;
 
-	current->mm->mmap = NULL;
+	INIT_LIST_HEAD(&current->mm->mm_vmas);
 	compute_creds(bprm);
  	current->flags &= ~PF_FORKNOEXEC;
 
Index: linux-2.6/fs/binfmt_aout.c
===================================================================
--- linux-2.6.orig/fs/binfmt_aout.c
+++ linux-2.6/fs/binfmt_aout.c
@@ -323,7 +323,7 @@ static int load_aout_binary(struct linux
 	current->mm->free_area_cache = current->mm->mmap_base;
 	current->mm->cached_hole_size = 0;
 
-	current->mm->mmap = NULL;
+	INIT_LIST_HEAD(&current->mm->mm_vmas);
 	compute_creds(bprm);
  	current->flags &= ~PF_FORKNOEXEC;
 #ifdef __sparc__

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
