Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f44.google.com (mail-lf0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 53F356B0254
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 03:12:44 -0500 (EST)
Received: by lfdl133 with SMTP id l133so113453359lfd.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 00:12:43 -0800 (PST)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id o197si16483684lfe.248.2015.12.14.00.12.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 00:12:42 -0800 (PST)
Received: by lbblt2 with SMTP id lt2so102075646lbb.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 00:12:42 -0800 (PST)
Subject: [PATCH RFC] mm: rework virtual memory accounting
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Mon, 14 Dec 2015 11:12:38 +0300
Message-ID: <145008075795.15926.4661774822205839673.stgit@zurg>
In-Reply-To: <CALYGNiMTkhb1EeojxvarVOh2q4SGqtKuYU_gv4V+vQ1XocPZ8w@mail.gmail.com>
References: <CALYGNiMTkhb1EeojxvarVOh2q4SGqtKuYU_gv4V+vQ1XocPZ8w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Here several rated changes bundled together:
* keep vma counting if CONFIG_PROC_FS=n, will be used for limits
* replace mm->shared_vm with better defined mm->data_vm
* account anonymous executable areas as executable
* account file-backed growsdown/up areas as stack
* drop struct file* argument from vm_stat_account
* enforce RLIMIT_DATA for size of data areas

This way code looks cleaner: now code/stack/data
classification depends only on vm_flags state:

VM_EXEC & ~VM_WRITE -> code (VmExe + VmLib in proc)
VM_GROWSUP | VM_GROWSDOWN -> stack (VmStk)
VM_WRITE & ~VM_SHARED & !stack -> data (VmData)

The rest (VmSize - VmData - VmStk - VmExe - VmLib) could be called "shared",
but that might be strange beasts like readonly-private or VM_IO areas.

RLIMIT_AS limits whole address space "VmSize"
RLIMIT_STACK limits stack "VmStk" (but each vma individually)
RLIMIT_DATA now limits "VmData"

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 arch/ia64/kernel/perfmon.c |    3 +-
 fs/proc/task_mmu.c         |    7 ++---
 include/linux/mm.h         |   13 ++-------
 include/linux/mm_types.h   |    2 +
 kernel/fork.c              |    5 +--
 mm/debug.c                 |    4 +--
 mm/mmap.c                  |   63 ++++++++++++++++++++++----------------------
 mm/mprotect.c              |    8 ++++--
 mm/mremap.c                |    7 +++--
 9 files changed, 53 insertions(+), 59 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 60e02f7747ff..9cd607b06964 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2332,8 +2332,7 @@ pfm_smpl_buffer_alloc(struct task_struct *task, struct file *filp, pfm_context_t
 	 */
 	insert_vm_struct(mm, vma);
 
-	vm_stat_account(vma->vm_mm, vma->vm_flags, vma->vm_file,
-							vma_pages(vma));
+	vm_stat_account(vma->vm_mm, vma->vm_flags, vma_pages(vma));
 	up_write(&task->mm->mmap_sem);
 
 	/*
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 187b3b5f242e..58e73af17af9 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -22,7 +22,7 @@
 
 void task_mem(struct seq_file *m, struct mm_struct *mm)
 {
-	unsigned long data, text, lib, swap, ptes, pmds;
+	unsigned long text, lib, swap, ptes, pmds;
 	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
 
 	/*
@@ -39,7 +39,6 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	if (hiwater_rss < mm->hiwater_rss)
 		hiwater_rss = mm->hiwater_rss;
 
-	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
 	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
 	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
 	swap = get_mm_counter(mm, MM_SWAPENTS);
@@ -65,7 +64,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		mm->pinned_vm << (PAGE_SHIFT-10),
 		hiwater_rss << (PAGE_SHIFT-10),
 		total_rss << (PAGE_SHIFT-10),
-		data << (PAGE_SHIFT-10),
+		mm->data_vm << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
 		ptes >> 10,
 		pmds >> 10,
@@ -85,7 +84,7 @@ unsigned long task_statm(struct mm_struct *mm,
 	*shared = get_mm_counter(mm, MM_FILEPAGES);
 	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
 								>> PAGE_SHIFT;
-	*data = mm->total_vm - mm->shared_vm;
+	*data = mm->data_vm + mm->stack_vm;
 	*resident = *shared + get_mm_counter(mm, MM_ANONPAGES);
 	return mm->total_vm;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 00bad7793788..6816a48b6542 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1898,7 +1898,9 @@ extern void mm_drop_all_locks(struct mm_struct *mm);
 extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
 extern struct file *get_mm_exe_file(struct mm_struct *mm);
 
-extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
+extern bool may_expand_vm(struct mm_struct *, vm_flags_t, unsigned long npages);
+extern void vm_stat_account(struct mm_struct *, vm_flags_t, long npages);
+
 extern struct vm_area_struct *_install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags,
@@ -2116,15 +2118,6 @@ typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
 			       unsigned long size, pte_fn_t fn, void *data);
 
-#ifdef CONFIG_PROC_FS
-void vm_stat_account(struct mm_struct *, unsigned long, struct file *, long);
-#else
-static inline void vm_stat_account(struct mm_struct *mm,
-			unsigned long flags, struct file *file, long pages)
-{
-	mm->total_vm += pages;
-}
-#endif /* CONFIG_PROC_FS */
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 extern bool _debug_pagealloc_enabled;
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f8d1492a114f..fa114a255b11 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -426,7 +426,7 @@ struct mm_struct {
 	unsigned long total_vm;		/* Total pages mapped */
 	unsigned long locked_vm;	/* Pages that have PG_mlocked set */
 	unsigned long pinned_vm;	/* Refcount permanently increased */
-	unsigned long shared_vm;	/* Shared pages (files) */
+	unsigned long data_vm;		/* VM_WRITE & ~VM_SHARED/GROWSDOWN */
 	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
 	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
 	unsigned long def_flags;
diff --git a/kernel/fork.c b/kernel/fork.c
index fce002ee3ddf..1205601c2174 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -413,7 +413,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
 
 	mm->total_vm = oldmm->total_vm;
-	mm->shared_vm = oldmm->shared_vm;
+	mm->data_vm = oldmm->data_vm;
 	mm->exec_vm = oldmm->exec_vm;
 	mm->stack_vm = oldmm->stack_vm;
 
@@ -432,8 +432,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		struct file *file;
 
 		if (mpnt->vm_flags & VM_DONTCOPY) {
-			vm_stat_account(mm, mpnt->vm_flags, mpnt->vm_file,
-							-vma_pages(mpnt));
+			vm_stat_account(mm, mpnt->vm_flags, -vma_pages(mpnt));
 			continue;
 		}
 		charge = 0;
diff --git a/mm/debug.c b/mm/debug.c
index 668aa35191ca..5d2072ed8d5e 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -175,7 +175,7 @@ void dump_mm(const struct mm_struct *mm)
 		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
 		"pgd %p mm_users %d mm_count %d nr_ptes %lu nr_pmds %lu map_count %d\n"
 		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
-		"pinned_vm %lx shared_vm %lx exec_vm %lx stack_vm %lx\n"
+		"pinned_vm %lx data_vm %lx exec_vm %lx stack_vm %lx\n"
 		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
 		"start_brk %lx brk %lx start_stack %lx\n"
 		"arg_start %lx arg_end %lx env_start %lx env_end %lx\n"
@@ -209,7 +209,7 @@ void dump_mm(const struct mm_struct *mm)
 		mm_nr_pmds((struct mm_struct *)mm),
 		mm->map_count,
 		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm, mm->locked_vm,
-		mm->pinned_vm, mm->shared_vm, mm->exec_vm, mm->stack_vm,
+		mm->pinned_vm, mm->data_vm, mm->exec_vm, mm->stack_vm,
 		mm->start_code, mm->end_code, mm->start_data, mm->end_data,
 		mm->start_brk, mm->brk, mm->start_stack,
 		mm->arg_start, mm->arg_end, mm->env_start, mm->env_end,
diff --git a/mm/mmap.c b/mm/mmap.c
index 2ce04a649f6b..e38f9d4af9c8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1208,24 +1208,6 @@ none:
 	return NULL;
 }
 
-#ifdef CONFIG_PROC_FS
-void vm_stat_account(struct mm_struct *mm, unsigned long flags,
-						struct file *file, long pages)
-{
-	const unsigned long stack_flags
-		= VM_STACK_FLAGS & (VM_GROWSUP|VM_GROWSDOWN);
-
-	mm->total_vm += pages;
-
-	if (file) {
-		mm->shared_vm += pages;
-		if ((flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
-			mm->exec_vm += pages;
-	} else if (flags & stack_flags)
-		mm->stack_vm += pages;
-}
-#endif /* CONFIG_PROC_FS */
-
 /*
  * If a hint addr is less than mmap_min_addr change hint to be as
  * low as possible but still greater than mmap_min_addr
@@ -1544,7 +1526,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long charged = 0;
 
 	/* Check against address space limit. */
-	if (!may_expand_vm(mm, len >> PAGE_SHIFT)) {
+	if (!may_expand_vm(mm, vm_flags, len >> PAGE_SHIFT)) {
 		unsigned long nr_pages;
 
 		/*
@@ -1556,7 +1538,8 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 
 		nr_pages = count_vma_pages_range(mm, addr, addr + len);
 
-		if (!may_expand_vm(mm, (len >> PAGE_SHIFT) - nr_pages))
+		if (!may_expand_vm(mm, vm_flags,
+					(len >> PAGE_SHIFT) - nr_pages))
 			return -ENOMEM;
 	}
 
@@ -1655,7 +1638,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 out:
 	perf_event_mmap(vma);
 
-	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
+	vm_stat_account(mm, vm_flags, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		if (!((vm_flags & VM_SPECIAL) || is_vm_hugetlb_page(vma) ||
 					vma == get_gate_vma(current->mm)))
@@ -2102,7 +2085,7 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 	unsigned long new_start, actual_size;
 
 	/* address space limit tests */
-	if (!may_expand_vm(mm, grow))
+	if (!may_expand_vm(mm, vma->vm_flags, grow))
 		return -ENOMEM;
 
 	/* Stack limit test */
@@ -2199,8 +2182,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 				spin_lock(&mm->page_table_lock);
 				if (vma->vm_flags & VM_LOCKED)
 					mm->locked_vm += grow;
-				vm_stat_account(mm, vma->vm_flags,
-						vma->vm_file, grow);
+				vm_stat_account(mm, vma->vm_flags, grow);
 				anon_vma_interval_tree_pre_update_vma(vma);
 				vma->vm_end = address;
 				anon_vma_interval_tree_post_update_vma(vma);
@@ -2275,8 +2257,7 @@ int expand_downwards(struct vm_area_struct *vma,
 				spin_lock(&mm->page_table_lock);
 				if (vma->vm_flags & VM_LOCKED)
 					mm->locked_vm += grow;
-				vm_stat_account(mm, vma->vm_flags,
-						vma->vm_file, grow);
+				vm_stat_account(mm, vma->vm_flags, grow);
 				anon_vma_interval_tree_pre_update_vma(vma);
 				vma->vm_start = address;
 				vma->vm_pgoff -= grow;
@@ -2390,7 +2371,7 @@ static void remove_vma_list(struct mm_struct *mm, struct vm_area_struct *vma)
 
 		if (vma->vm_flags & VM_ACCOUNT)
 			nr_accounted += nrpages;
-		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
+		vm_stat_account(mm, vma->vm_flags, -nrpages);
 		vma = remove_vma(vma);
 	} while (vma);
 	vm_unacct_memory(nr_accounted);
@@ -2760,7 +2741,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 	}
 
 	/* Check against address space limits *after* clearing old maps... */
-	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
+	if (!may_expand_vm(mm, flags, len >> PAGE_SHIFT))
 		return -ENOMEM;
 
 	if (mm->map_count > sysctl_max_map_count)
@@ -2795,6 +2776,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 out:
 	perf_event_mmap(vma);
 	mm->total_vm += len >> PAGE_SHIFT;
+	mm->data_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED)
 		mm->locked_vm += (len >> PAGE_SHIFT);
 	vma->vm_flags |= VM_SOFTDIRTY;
@@ -2986,7 +2968,7 @@ out:
  * Return true if the calling process may expand its vm space by the passed
  * number of pages
  */
-int may_expand_vm(struct mm_struct *mm, unsigned long npages)
+bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
 {
 	unsigned long cur = mm->total_vm;	/* pages */
 	unsigned long lim;
@@ -2994,8 +2976,25 @@ int may_expand_vm(struct mm_struct *mm, unsigned long npages)
 	lim = rlimit(RLIMIT_AS) >> PAGE_SHIFT;
 
 	if (cur + npages > lim)
-		return 0;
-	return 1;
+		return false;
+
+	if ((flags & (VM_WRITE | VM_SHARED | (VM_STACK_FLAGS &
+				(VM_GROWSUP | VM_GROWSDOWN)))) == VM_WRITE)
+		return mm->data_vm + npages <= rlimit(RLIMIT_DATA);
+
+	return true;
+}
+
+void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, long npages)
+{
+	mm->total_vm += npages;
+
+	if ((flags & (VM_EXEC | VM_WRITE)) == VM_EXEC)
+		mm->exec_vm += npages;
+	else if (flags & (VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN)))
+		mm->stack_vm += npages;
+	else if ((flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
+		mm->data_vm += npages;
 }
 
 static int special_mapping_fault(struct vm_area_struct *vma,
@@ -3077,7 +3076,7 @@ static struct vm_area_struct *__install_special_mapping(
 	if (ret)
 		goto out;
 
-	mm->total_vm += len >> PAGE_SHIFT;
+	vm_stat_account(mm, vma->vm_flags, len >> PAGE_SHIFT);
 
 	perf_event_mmap(vma);
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index ef5be8eaab00..c764402c464f 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -278,6 +278,10 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 * even if read-only so there is no need to account for them here
 	 */
 	if (newflags & VM_WRITE) {
+		/* Check space limits when area turns into data. */
+		if (!may_expand_vm(mm, newflags, nrpages) &&
+				may_expand_vm(mm, oldflags, nrpages))
+			return -ENOMEM;
 		if (!(oldflags & (VM_ACCOUNT|VM_WRITE|VM_HUGETLB|
 						VM_SHARED|VM_NORESERVE))) {
 			charged = nrpages;
@@ -334,8 +338,8 @@ success:
 		populate_vma_page_range(vma, start, end, NULL);
 	}
 
-	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
-	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
+	vm_stat_account(mm, oldflags, -nrpages);
+	vm_stat_account(mm, newflags, nrpages);
 	perf_event_mmap(vma);
 	return 0;
 
diff --git a/mm/mremap.c b/mm/mremap.c
index c25bc6268e46..4fe3248426d1 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -317,7 +317,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	 * If this were a serious issue, we'd add a flag to do_munmap().
 	 */
 	hiwater_vm = mm->hiwater_vm;
-	vm_stat_account(mm, vma->vm_flags, vma->vm_file, new_len>>PAGE_SHIFT);
+	vm_stat_account(mm, vma->vm_flags, new_len >> PAGE_SHIFT);
 
 	if (do_munmap(mm, old_addr, old_len) < 0) {
 		/* OOM: unable to split vma, just get accounts right */
@@ -379,7 +379,8 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 			return ERR_PTR(-EAGAIN);
 	}
 
-	if (!may_expand_vm(mm, (new_len - old_len) >> PAGE_SHIFT))
+	if (!may_expand_vm(mm, vma->vm_flags,
+				(new_len - old_len) >> PAGE_SHIFT))
 		return ERR_PTR(-ENOMEM);
 
 	if (vma->vm_flags & VM_ACCOUNT) {
@@ -541,7 +542,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 				goto out;
 			}
 
-			vm_stat_account(mm, vma->vm_flags, vma->vm_file, pages);
+			vm_stat_account(mm, vma->vm_flags, pages);
 			if (vma->vm_flags & VM_LOCKED) {
 				mm->locked_vm += pages;
 				locked = true;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
