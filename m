Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E48CF6B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 02:40:13 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAD7eARc001742
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Nov 2009 16:40:11 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FFAF45DE52
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:40:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BDB2145DE4E
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:40:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F7F71DB804E
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:40:09 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D97A41DB8045
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:40:07 +0900 (JST)
Date: Fri, 13 Nov 2009 16:37:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC MM 1/4]  mm accessor (updated)
Message-Id: <20091113163730.8c81d04e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cl@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph's mm_accessor patch. updated to some extent.

==
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [RFC MM] Accessors for mm locking

Scaling of MM locking has been a concern for a long time. With the arrival of
high thread counts in average business systems we may finally have to do
something about that.

This patch provides a series of accessors for mm locking so that the details
of mm locking (which is done today via mmap_sem) are hidden. This allows us
to try various implemenations of mm locking to solve the scaling issues.

Note that this patch is currently incomplete and just does enough to get my
kernels compiled on two platforms. If we agree on the naming etc
then I will complete this patch and do the accessor conversion for all of
the kernel.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 arch/x86/ia32/sys_ia32.c                       |    8 +--
 arch/x86/kernel/sys_i386_32.c                  |    4 -
 arch/x86/kernel/sys_x86_64.c                   |    4 -
 arch/x86/mm/fault.c                            |   14 ++---
 arch/x86/mm/gup.c                              |    4 -
 arch/x86/vdso/vdso32-setup.c                   |    4 -
 arch/x86/vdso/vma.c                            |    4 -
 drivers/gpu/drm/drm_bufs.c                     |    8 +--
 drivers/gpu/drm/i810/i810_dma.c                |    8 +--
 drivers/gpu/drm/i830/i830_dma.c                |    8 +--
 drivers/gpu/drm/i915/i915_gem.c                |   16 +++---
 drivers/gpu/drm/ttm/ttm_tt.c                   |    4 -
 drivers/gpu/drm/via/via_dmablit.c              |    4 -
 drivers/infiniband/core/umem.c                 |   14 ++---
 drivers/infiniband/hw/ipath/ipath_user_pages.c |   12 ++--
 drivers/infiniband/hw/ipath/ipath_user_sdma.c  |    4 -
 drivers/oprofile/buffer_sync.c                 |   10 ++--
 drivers/scsi/st.c                              |    4 -
 fs/aio.c                                       |   10 ++--
 fs/binfmt_elf.c                                |   24 ++++-----
 fs/exec.c                                      |   24 ++++-----
 fs/nfs/direct.c                                |    8 +--
 fs/proc/array.c                                |    4 -
 fs/proc/base.c                                 |    4 -
 fs/proc/task_mmu.c                             |   14 ++---
 include/linux/mm_types.h                       |   62 ++++++++++++++++++++++++-
 ipc/shm.c                                      |    8 +--
 kernel/acct.c                                  |    4 -
 kernel/auditsc.c                               |    4 -
 kernel/exit.c                                  |    8 +--
 kernel/fork.c                                  |   10 ++--
 kernel/trace/trace_output.c                    |    4 -
 mm/fremap.c                                    |   12 ++--
 mm/init-mm.c                                   |    2 
 mm/madvise.c                                   |   12 ++--
 mm/memory.c                                    |   15 +-----
 mm/mempolicy.c                                 |   28 +++++------
 mm/migrate.c                                   |    8 +--
 mm/mincore.c                                   |    4 -
 mm/mlock.c                                     |   26 +++++-----
 mm/mmap.c                                      |   20 ++++----
 mm/mmu_notifier.c                              |    4 -
 mm/mprotect.c                                  |    4 -
 mm/mremap.c                                    |    4 -
 mm/msync.c                                     |    8 +--
 mm/rmap.c                                      |   12 ++--
 mm/swapfile.c                                  |    6 +-
 mm/util.c                                      |    4 -
 48 files changed, 272 insertions(+), 219 deletions(-)

Index: mmotm-2.6.32-Nov2/arch/x86/mm/fault.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/arch/x86/mm/fault.c
+++ mmotm-2.6.32-Nov2/arch/x86/mm/fault.c
@@ -759,7 +759,7 @@ __bad_area(struct pt_regs *regs, unsigne
 	 * Something tried to access memory that isn't in our memory map..
 	 * Fix it, but check if it's kernel or user first..
 	 */
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 
 	__bad_area_nosemaphore(regs, error_code, address, si_code);
 }
@@ -786,7 +786,7 @@ out_of_memory(struct pt_regs *regs, unsi
 	 * We ran out of memory, call the OOM killer, and return the userspace
 	 * (which will retry the fault, or kill us if we got oom-killed):
 	 */
-	up_read(&current->mm->mmap_sem);
+	mm_reader_unlock(current->mm);
 
 	pagefault_out_of_memory();
 }
@@ -799,7 +799,7 @@ do_sigbus(struct pt_regs *regs, unsigned
 	struct mm_struct *mm = tsk->mm;
 	int code = BUS_ADRERR;
 
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 
 	/* Kernel mode? Handle exceptions or die: */
 	if (!(error_code & PF_USER))
@@ -965,7 +965,7 @@ do_page_fault(struct pt_regs *regs, unsi
 	 */
 	if (kmemcheck_active(regs))
 		kmemcheck_hide(regs);
-	prefetchw(&mm->mmap_sem);
+	mm_lock_prefetch(mm);
 
 	if (unlikely(kmmio_fault(regs, address)))
 		return;
@@ -1056,13 +1056,13 @@ do_page_fault(struct pt_regs *regs, unsi
 	 * validate the source. If this is invalid we can skip the address
 	 * space check, thus avoiding the deadlock:
 	 */
-	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
+	if (unlikely(!mm_reader_trylock(mm))) {
 		if ((error_code & PF_USER) == 0 &&
 		    !search_exception_tables(regs->ip)) {
 			bad_area_nosemaphore(regs, error_code, address);
 			return;
 		}
-		down_read(&mm->mmap_sem);
+		mm_reader_lock(mm);
 	} else {
 		/*
 		 * The above down_read_trylock() might have succeeded in
@@ -1136,5 +1136,5 @@ good_area:
 
 	check_v8086_mode(regs, address, tsk);
 
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 }
Index: mmotm-2.6.32-Nov2/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/mm_types.h
+++ mmotm-2.6.32-Nov2/include/linux/mm_types.h
@@ -215,7 +215,7 @@ struct mm_struct {
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
-	struct rw_semaphore mmap_sem;
+	struct rw_semaphore sem;
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
 
 	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
@@ -289,6 +289,66 @@ struct mm_struct {
 #endif
 };
 
+static inline void mm_reader_lock(struct mm_struct *mm)
+{
+	down_read(&mm->sem);
+}
+
+static inline void mm_reader_unlock(struct mm_struct *mm)
+{
+	up_read(&mm->sem);
+}
+
+static inline int mm_reader_trylock(struct mm_struct *mm)
+{
+	return down_read_trylock(&mm->sem);
+}
+
+static inline void mm_writer_lock(struct mm_struct *mm)
+{
+	down_write(&mm->sem);
+}
+
+static inline void mm_writer_unlock(struct mm_struct *mm)
+{
+	up_write(&mm->sem);
+}
+
+static inline int mm_writer_trylock(struct mm_struct *mm)
+{
+	return down_write_trylock(&mm->sem);
+}
+
+static inline int mm_locked(struct mm_struct *mm)
+{
+	return rwsem_is_locked(&mm->sem);
+}
+
+static inline void mm_writer_to_reader_lock(struct mm_struct *mm)
+{
+	downgrade_write(&mm->sem);
+}
+
+static inline void mm_writer_lock_nested(struct mm_struct *mm, int x)
+{
+	down_write_nested(&mm->sem, x);
+}
+
+static inline void mm_lock_init(struct mm_struct *mm)
+{
+	init_rwsem(&mm->sem);
+}
+
+static inline void mm_lock_prefetch(struct mm_struct *mm)
+{
+	prefetchw(&mm->sem);
+}
+
+static inline void mm_nest_lock(spinlock_t *s, struct mm_struct *mm)
+{
+	spin_lock_nest_lock(s, &mm->sem);
+}
+
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
 #define mm_cpumask(mm) (&(mm)->cpu_vm_mask)
 
Index: mmotm-2.6.32-Nov2/mm/memory.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/memory.c
+++ mmotm-2.6.32-Nov2/mm/memory.c
@@ -3278,7 +3278,7 @@ int access_process_vm(struct task_struct
 	if (!mm)
 		return 0;
 
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 	/* ignore errors, just check how much was successfully transferred */
 	while (len) {
 		int bytes, ret, offset;
@@ -3325,7 +3325,7 @@ int access_process_vm(struct task_struct
 		buf += bytes;
 		addr += bytes;
 	}
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 	mmput(mm);
 
 	return buf - old_buf;
@@ -3346,7 +3346,7 @@ void print_vma_addr(char *prefix, unsign
 	if (preempt_count())
 		return;
 
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 	vma = find_vma(mm, ip);
 	if (vma && vma->vm_file) {
 		struct file *f = vma->vm_file;
@@ -3366,7 +3366,7 @@ void print_vma_addr(char *prefix, unsign
 			free_page((unsigned long)buf);
 		}
 	}
-	up_read(&current->mm->mmap_sem);
+	mm_reader_unlock(mm);
 }
 
 #ifdef CONFIG_PROVE_LOCKING
@@ -3382,13 +3382,6 @@ void might_fault(void)
 		return;
 
 	might_sleep();
-	/*
-	 * it would be nicer only to annotate paths which are not under
-	 * pagefault_disable, however that requires a larger audit and
-	 * providing helpers like get_user_atomic.
-	 */
-	if (!in_atomic() && current->mm)
-		might_lock_read(&current->mm->mmap_sem);
 }
 EXPORT_SYMBOL(might_fault);
 #endif
Index: mmotm-2.6.32-Nov2/mm/migrate.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/migrate.c
+++ mmotm-2.6.32-Nov2/mm/migrate.c
@@ -829,7 +829,7 @@ static int do_move_page_to_node_array(st
 	struct page_to_node *pp;
 	LIST_HEAD(pagelist);
 
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 
 	/*
 	 * Build a list of pages to migrate
@@ -892,7 +892,7 @@ set_status:
 		err = migrate_pages(&pagelist, new_page_node,
 				(unsigned long)pm);
 
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 	return err;
 }
 
@@ -991,7 +991,7 @@ static void do_pages_stat_array(struct m
 {
 	unsigned long i;
 
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 
 	for (i = 0; i < nr_pages; i++) {
 		unsigned long addr = (unsigned long)(*pages);
@@ -1022,7 +1022,7 @@ set_status:
 		status++;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 }
 
 /*
Index: mmotm-2.6.32-Nov2/mm/mmap.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/mmap.c
+++ mmotm-2.6.32-Nov2/mm/mmap.c
@@ -249,7 +249,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	struct mm_struct *mm = current->mm;
 	unsigned long min_brk;
 
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 
 #ifdef CONFIG_COMPAT_BRK
 	min_brk = mm->end_code;
@@ -293,7 +293,7 @@ set_brk:
 	mm->brk = brk;
 out:
 	retval = mm->brk;
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 	return retval;
 }
 
@@ -1985,18 +1985,18 @@ SYSCALL_DEFINE2(munmap, unsigned long, a
 
 	profile_munmap(addr);
 
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 	ret = do_munmap(mm, addr, len);
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 	return ret;
 }
 
 static inline void verify_mm_writelocked(struct mm_struct *mm)
 {
 #ifdef CONFIG_DEBUG_VM
-	if (unlikely(down_read_trylock(&mm->mmap_sem))) {
+	if (unlikely(mm_reader_trylock(mm))) {
 		WARN_ON(1);
-		up_read(&mm->mmap_sem);
+		mm_reader_unlock(mm);
 	}
 #endif
 }
@@ -2353,7 +2353,7 @@ static void vm_lock_anon_vma(struct mm_s
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		spin_lock_nest_lock(&anon_vma->lock, &mm->mmap_sem);
+		mm_nest_lock(&anon_vma->lock, mm);
 		/*
 		 * We can safely modify head.next after taking the
 		 * anon_vma->lock. If some other vma in this mm shares
@@ -2383,7 +2383,7 @@ static void vm_lock_mapping(struct mm_st
 		 */
 		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
 			BUG();
-		spin_lock_nest_lock(&mapping->i_mmap_lock, &mm->mmap_sem);
+		mm_nest_lock(&mapping->i_mmap_lock, mm);
 	}
 }
 
@@ -2424,7 +2424,7 @@ int mm_take_all_locks(struct mm_struct *
 	struct vm_area_struct *vma;
 	int ret = -EINTR;
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	BUG_ON(mm_reader_trylock(mm));
 
 	mutex_lock(&mm_all_locks_mutex);
 
@@ -2495,7 +2495,7 @@ void mm_drop_all_locks(struct mm_struct 
 {
 	struct vm_area_struct *vma;
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	BUG_ON(mm_reader_trylock(mm));
 	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));
 
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
Index: mmotm-2.6.32-Nov2/mm/mmu_notifier.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/mmu_notifier.c
+++ mmotm-2.6.32-Nov2/mm/mmu_notifier.c
@@ -176,7 +176,7 @@ static int do_mmu_notifier_register(stru
 		goto out;
 
 	if (take_mmap_sem)
-		down_write(&mm->mmap_sem);
+		mm_writer_lock(mm);
 	ret = mm_take_all_locks(mm);
 	if (unlikely(ret))
 		goto out_cleanup;
@@ -204,7 +204,7 @@ static int do_mmu_notifier_register(stru
 	mm_drop_all_locks(mm);
 out_cleanup:
 	if (take_mmap_sem)
-		up_write(&mm->mmap_sem);
+		mm_writer_unlock(mm);
 	/* kfree() does nothing if mmu_notifier_mm is NULL */
 	kfree(mmu_notifier_mm);
 out:
Index: mmotm-2.6.32-Nov2/mm/mprotect.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/mprotect.c
+++ mmotm-2.6.32-Nov2/mm/mprotect.c
@@ -250,7 +250,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 
 	vm_flags = calc_vm_prot_bits(prot);
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 
 	vma = find_vma_prev(current->mm, start, &prev);
 	error = -ENOMEM;
@@ -315,6 +315,6 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 		}
 	}
 out:
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 	return error;
 }
Index: mmotm-2.6.32-Nov2/mm/mremap.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/mremap.c
+++ mmotm-2.6.32-Nov2/mm/mremap.c
@@ -440,8 +440,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, a
 {
 	unsigned long ret;
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 	return ret;
 }
Index: mmotm-2.6.32-Nov2/mm/msync.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/msync.c
+++ mmotm-2.6.32-Nov2/mm/msync.c
@@ -54,7 +54,7 @@ SYSCALL_DEFINE3(msync, unsigned long, st
 	 * If the interval [start,end) covers some unmapped address ranges,
 	 * just ignore them, but return -ENOMEM at the end.
 	 */
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 	vma = find_vma(mm, start);
 	for (;;) {
 		struct file *file;
@@ -81,12 +81,12 @@ SYSCALL_DEFINE3(msync, unsigned long, st
 		if ((flags & MS_SYNC) && file &&
 				(vma->vm_flags & VM_SHARED)) {
 			get_file(file);
-			up_read(&mm->mmap_sem);
+			mm_reader_unlock(mm);
 			error = vfs_fsync(file, file->f_path.dentry, 0);
 			fput(file);
 			if (error || start >= end)
 				goto out;
-			down_read(&mm->mmap_sem);
+			mm_reader_lock(mm);
 			vma = find_vma(mm, start);
 		} else {
 			if (start >= end) {
@@ -97,7 +97,7 @@ SYSCALL_DEFINE3(msync, unsigned long, st
 		}
 	}
 out_unlock:
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 out:
 	return error ? : unmapped_error;
 }
Index: mmotm-2.6.32-Nov2/mm/rmap.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/rmap.c
+++ mmotm-2.6.32-Nov2/mm/rmap.c
@@ -382,7 +382,7 @@ static int page_referenced_one(struct pa
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
 	if (mm != current->mm && has_swap_token(mm) &&
-			rwsem_is_locked(&mm->mmap_sem))
+			mm_locked(mm))
 		referenced++;
 
 out_unmap:
@@ -930,10 +930,10 @@ static int try_to_unmap_cluster(unsigned
 	 * if we can acquire the mmap_sem for read, and vma is VM_LOCKED,
 	 * keep the sem while scanning the cluster for mlocking pages.
 	 */
-	if (MLOCK_PAGES && down_read_trylock(&vma->vm_mm->mmap_sem)) {
+	if (MLOCK_PAGES && mm_reader_trylock(vma->vm_mm)) {
 		locked_vma = (vma->vm_flags & VM_LOCKED);
 		if (!locked_vma)
-			up_read(&vma->vm_mm->mmap_sem); /* don't need it */
+			mm_reader_unlock(vma->vm_mm); /* don't need it */
 	}
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
@@ -976,7 +976,7 @@ static int try_to_unmap_cluster(unsigned
 	}
 	pte_unmap_unlock(pte - 1, ptl);
 	if (locked_vma)
-		up_read(&vma->vm_mm->mmap_sem);
+		mm_reader_unlock(vma->vm_mm);
 	return ret;
 }
 
@@ -987,12 +987,12 @@ static int try_to_mlock_page(struct page
 {
 	int mlocked = 0;
 
-	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
+	if (mm_reader_trylock(vma->vm_mm)) {
 		if (vma->vm_flags & VM_LOCKED) {
 			mlock_vma_page(page);
 			mlocked++;	/* really mlocked the page */
 		}
-		up_read(&vma->vm_mm->mmap_sem);
+		mm_reader_unlock(vma->vm_mm);
 	}
 	return mlocked;
 }
Index: mmotm-2.6.32-Nov2/mm/swapfile.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/swapfile.c
+++ mmotm-2.6.32-Nov2/mm/swapfile.c
@@ -966,21 +966,21 @@ static int unuse_mm(struct mm_struct *mm
 	struct vm_area_struct *vma;
 	int ret = 0;
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_reader_trylock(mm)) {
 		/*
 		 * Activate page so shrink_inactive_list is unlikely to unmap
 		 * its ptes while lock is dropped, so swapoff can make progress.
 		 */
 		activate_page(page);
 		unlock_page(page);
-		down_read(&mm->mmap_sem);
+		mm_reader_lock(mm);
 		lock_page(page);
 	}
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->anon_vma && (ret = unuse_vma(vma, entry, page)))
 			break;
 	}
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 	return (ret < 0)? ret: 0;
 }
 
Index: mmotm-2.6.32-Nov2/mm/util.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/util.c
+++ mmotm-2.6.32-Nov2/mm/util.c
@@ -259,10 +259,10 @@ int __attribute__((weak)) get_user_pages
 	struct mm_struct *mm = current->mm;
 	int ret;
 
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 	ret = get_user_pages(current, mm, start, nr_pages,
 					write, 0, pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 
 	return ret;
 }
Index: mmotm-2.6.32-Nov2/mm/fremap.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/fremap.c
+++ mmotm-2.6.32-Nov2/mm/fremap.c
@@ -149,7 +149,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
 #endif
 
 	/* We need down_write() to change vma->vm_flags. */
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
  retry:
 	vma = find_vma(mm, start);
 
@@ -180,8 +180,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
 		}
 
 		if (!has_write_lock) {
-			up_read(&mm->mmap_sem);
-			down_write(&mm->mmap_sem);
+			mm_reader_unlock(mm);
+			mm_writer_lock(mm);
 			has_write_lock = 1;
 			goto retry;
 		}
@@ -237,7 +237,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
 			mlock_vma_pages_range(vma, start, start + size);
 		} else {
 			if (unlikely(has_write_lock)) {
-				downgrade_write(&mm->mmap_sem);
+				mm_writer_to_reader_lock(mm);
 				has_write_lock = 0;
 			}
 			make_pages_present(start, start+size);
@@ -252,9 +252,9 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
 
 out:
 	if (likely(!has_write_lock))
-		up_read(&mm->mmap_sem);
+		mm_reader_unlock(mm);
 	else
-		up_write(&mm->mmap_sem);
+		mm_writer_unlock(mm);
 
 	return err;
 }
Index: mmotm-2.6.32-Nov2/mm/init-mm.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/init-mm.c
+++ mmotm-2.6.32-Nov2/mm/init-mm.c
@@ -13,7 +13,7 @@ struct mm_struct init_mm = {
 	.pgd		= swapper_pg_dir,
 	.mm_users	= ATOMIC_INIT(2),
 	.mm_count	= ATOMIC_INIT(1),
-	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
+	.sem		= __RWSEM_INITIALIZER(init_mm.sem),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
 	.cpu_vm_mask	= CPU_MASK_ALL,
Index: mmotm-2.6.32-Nov2/arch/x86/kernel/sys_x86_64.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/arch/x86/kernel/sys_x86_64.c
+++ mmotm-2.6.32-Nov2/arch/x86/kernel/sys_x86_64.c
@@ -37,9 +37,9 @@ SYSCALL_DEFINE6(mmap, unsigned long, add
 		if (!file)
 			goto out;
 	}
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, off >> PAGE_SHIFT);
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 
 	if (file)
 		fput(file);
Index: mmotm-2.6.32-Nov2/arch/x86/mm/gup.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/arch/x86/mm/gup.c
+++ mmotm-2.6.32-Nov2/arch/x86/mm/gup.c
@@ -357,10 +357,10 @@ slow_irqon:
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		down_read(&mm->mmap_sem);
+		mm_reader_lock(mm);
 		ret = get_user_pages(current, mm, start,
 			(end - start) >> PAGE_SHIFT, write, 0, pages, NULL);
-		up_read(&mm->mmap_sem);
+		mm_reader_unlock(mm);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
Index: mmotm-2.6.32-Nov2/arch/x86/vdso/vma.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/arch/x86/vdso/vma.c
+++ mmotm-2.6.32-Nov2/arch/x86/vdso/vma.c
@@ -108,7 +108,7 @@ int arch_setup_additional_pages(struct l
 	if (!vdso_enabled)
 		return 0;
 
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 	addr = vdso_addr(mm->start_stack, vdso_size);
 	addr = get_unmapped_area(NULL, addr, vdso_size, 0, 0);
 	if (IS_ERR_VALUE(addr)) {
@@ -129,7 +129,7 @@ int arch_setup_additional_pages(struct l
 	}
 
 up_fail:
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 	return ret;
 }
 
Index: mmotm-2.6.32-Nov2/fs/exec.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/fs/exec.c
+++ mmotm-2.6.32-Nov2/fs/exec.c
@@ -233,7 +233,7 @@ static int __bprm_mm_init(struct linux_b
 	if (!vma)
 		return -ENOMEM;
 
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 	vma->vm_mm = mm;
 
 	/*
@@ -251,11 +251,11 @@ static int __bprm_mm_init(struct linux_b
 		goto err;
 
 	mm->stack_vm = mm->total_vm = 1;
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 	bprm->p = vma->vm_end - sizeof(void *);
 	return 0;
 err:
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 	bprm->vma = NULL;
 	kmem_cache_free(vm_area_cachep, vma);
 	return err;
@@ -600,7 +600,7 @@ int setup_arg_pages(struct linux_binprm 
 		bprm->loader -= stack_shift;
 	bprm->exec -= stack_shift;
 
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 	vm_flags = VM_STACK_FLAGS;
 
 	/*
@@ -624,7 +624,7 @@ int setup_arg_pages(struct linux_binprm 
 	if (stack_shift) {
 		ret = shift_arg_pages(vma, stack_shift);
 		if (ret) {
-			up_write(&mm->mmap_sem);
+			mm_writer_unlock(mm);
 			return ret;
 		}
 	}
@@ -639,7 +639,7 @@ int setup_arg_pages(struct linux_binprm 
 		ret = -EFAULT;
 
 out_unlock:
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 	return 0;
 }
 EXPORT_SYMBOL(setup_arg_pages);
@@ -713,9 +713,9 @@ static int exec_mmap(struct mm_struct *m
 		 * through with the exec.  We must hold mmap_sem around
 		 * checking core_state and changing tsk->mm.
 		 */
-		down_read(&old_mm->mmap_sem);
+		mm_reader_lock(old_mm);
 		if (unlikely(old_mm->core_state)) {
-			up_read(&old_mm->mmap_sem);
+			mm_reader_unlock(old_mm);
 			return -EINTR;
 		}
 	}
@@ -727,7 +727,7 @@ static int exec_mmap(struct mm_struct *m
 	task_unlock(tsk);
 	arch_pick_mmap_layout(mm);
 	if (old_mm) {
-		up_read(&old_mm->mmap_sem);
+		mm_reader_unlock(old_mm);
 		BUG_ON(active_mm != old_mm);
 		mm_update_next_owner(old_mm);
 		mmput(old_mm);
@@ -1635,7 +1635,7 @@ static int coredump_wait(int exit_code, 
 	core_state->dumper.task = tsk;
 	core_state->dumper.next = NULL;
 	core_waiters = zap_threads(tsk, mm, core_state, exit_code);
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 
 	if (unlikely(core_waiters < 0))
 		goto fail;
@@ -1780,12 +1780,12 @@ void do_coredump(long signr, int exit_co
 		goto fail;
 	}
 
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 	/*
 	 * If another thread got here first, or we are not dumpable, bail out.
 	 */
 	if (mm->core_state || !get_dumpable(mm)) {
-		up_write(&mm->mmap_sem);
+		mm_writer_unlock(mm);
 		put_cred(cred);
 		goto fail;
 	}
Index: mmotm-2.6.32-Nov2/ipc/shm.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/ipc/shm.c
+++ mmotm-2.6.32-Nov2/ipc/shm.c
@@ -902,7 +902,7 @@ long do_shmat(int shmid, char __user *sh
 	sfd->file = shp->shm_file;
 	sfd->vm_ops = NULL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 	if (addr && !(shmflg & SHM_REMAP)) {
 		err = -EINVAL;
 		if (find_vma_intersection(current->mm, addr, addr + size))
@@ -922,7 +922,7 @@ long do_shmat(int shmid, char __user *sh
 	if (IS_ERR_VALUE(user_addr))
 		err = (long)user_addr;
 invalid:
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 
 	fput(file);
 
@@ -982,7 +982,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, sh
 	if (addr & ~PAGE_MASK)
 		return retval;
 
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 
 	/*
 	 * This function tries to be smart and unmap shm segments that
@@ -1062,7 +1062,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, sh
 
 #endif
 
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 	return retval;
 }
 
Index: mmotm-2.6.32-Nov2/kernel/exit.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/kernel/exit.c
+++ mmotm-2.6.32-Nov2/kernel/exit.c
@@ -655,11 +655,11 @@ static void exit_mm(struct task_struct *
 	 * will increment ->nr_threads for each thread in the
 	 * group with ->mm != NULL.
 	 */
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 	core_state = mm->core_state;
 	if (core_state) {
 		struct core_thread self;
-		up_read(&mm->mmap_sem);
+		mm_reader_unlock(mm);
 
 		self.task = tsk;
 		self.next = xchg(&core_state->dumper.next, &self);
@@ -677,14 +677,14 @@ static void exit_mm(struct task_struct *
 			schedule();
 		}
 		__set_task_state(tsk, TASK_RUNNING);
-		down_read(&mm->mmap_sem);
+		mm_reader_lock(mm);
 	}
 	atomic_inc(&mm->mm_count);
 	BUG_ON(mm != tsk->active_mm);
 	/* more a memory barrier than a real lock */
 	task_lock(tsk);
 	tsk->mm = NULL;
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 	enter_lazy_tlb(mm, current);
 	/* We don't want this task to be frozen prematurely */
 	clear_freeze_flag(tsk);
Index: mmotm-2.6.32-Nov2/kernel/fork.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/kernel/fork.c
+++ mmotm-2.6.32-Nov2/kernel/fork.c
@@ -283,12 +283,12 @@ static int dup_mmap(struct mm_struct *mm
 	unsigned long charge;
 	struct mempolicy *pol;
 
-	down_write(&oldmm->mmap_sem);
+	mm_writer_lock(oldmm);
 	flush_cache_dup_mm(oldmm);
 	/*
 	 * Not linked in yet - no deadlock potential:
 	 */
-	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
+	mm_writer_lock_nested(mm, SINGLE_DEPTH_NESTING);
 
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
@@ -385,9 +385,9 @@ static int dup_mmap(struct mm_struct *mm
 	arch_dup_mmap(oldmm, mm);
 	retval = 0;
 out:
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 	flush_tlb_mm(oldmm);
-	up_write(&oldmm->mmap_sem);
+	mm_writer_unlock(oldmm);
 	return retval;
 fail_nomem_policy:
 	kmem_cache_free(vm_area_cachep, tmp);
@@ -446,7 +446,7 @@ static struct mm_struct * mm_init(struct
 {
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
-	init_rwsem(&mm->mmap_sem);
+	mm_lock_init(mm);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->flags = (current->mm) ?
 		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
Index: mmotm-2.6.32-Nov2/mm/madvise.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/madvise.c
+++ mmotm-2.6.32-Nov2/mm/madvise.c
@@ -212,9 +212,9 @@ static long madvise_remove(struct vm_are
 			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
 
 	/* vmtruncate_range needs to take i_mutex and i_alloc_sem */
-	up_read(&current->mm->mmap_sem);
+	mm_reader_unlock(current->mm);
 	error = vmtruncate_range(mapping->host, offset, endoff);
-	down_read(&current->mm->mmap_sem);
+	mm_reader_lock(current->mm);
 	return error;
 }
 
@@ -343,9 +343,9 @@ SYSCALL_DEFINE3(madvise, unsigned long, 
 
 	write = madvise_need_mmap_write(behavior);
 	if (write)
-		down_write(&current->mm->mmap_sem);
+		mm_writer_lock(current->mm);
 	else
-		down_read(&current->mm->mmap_sem);
+		mm_reader_lock(current->mm);
 
 	if (start & ~PAGE_MASK)
 		goto out;
@@ -408,9 +408,9 @@ SYSCALL_DEFINE3(madvise, unsigned long, 
 	}
 out:
 	if (write)
-		up_write(&current->mm->mmap_sem);
+		mm_writer_unlock(current->mm);
 	else
-		up_read(&current->mm->mmap_sem);
+		mm_reader_unlock(current->mm);
 
 	return error;
 }
Index: mmotm-2.6.32-Nov2/mm/mempolicy.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/mempolicy.c
+++ mmotm-2.6.32-Nov2/mm/mempolicy.c
@@ -364,10 +364,10 @@ void mpol_rebind_mm(struct mm_struct *mm
 {
 	struct vm_area_struct *vma;
 
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 	for (vma = mm->mmap; vma; vma = vma->vm_next)
 		mpol_rebind_policy(vma->vm_policy, new);
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 }
 
 static const struct mempolicy_operations mpol_ops[MPOL_MAX] = {
@@ -643,13 +643,13 @@ static long do_set_mempolicy(unsigned sh
 	 * with no 'mm'.
 	 */
 	if (mm)
-		down_write(&mm->mmap_sem);
+		mm_writer_lock(mm);
 	task_lock(current);
 	ret = mpol_set_nodemask(new, nodes, scratch);
 	if (ret) {
 		task_unlock(current);
 		if (mm)
-			up_write(&mm->mmap_sem);
+			mm_writer_unlock(mm);
 		mpol_put(new);
 		goto out;
 	}
@@ -661,7 +661,7 @@ static long do_set_mempolicy(unsigned sh
 		current->il_next = first_node(new->v.nodes);
 	task_unlock(current);
 	if (mm)
-		up_write(&mm->mmap_sem);
+		mm_writer_unlock(mm);
 
 	mpol_put(old);
 	ret = 0;
@@ -739,10 +739,10 @@ static long do_get_mempolicy(int *policy
 		 * vma/shared policy at addr is NULL.  We
 		 * want to return MPOL_DEFAULT in this case.
 		 */
-		down_read(&mm->mmap_sem);
+		mm_reader_lock(mm);
 		vma = find_vma_intersection(mm, addr, addr+1);
 		if (!vma) {
-			up_read(&mm->mmap_sem);
+			mm_reader_unlock(mm);
 			return -EFAULT;
 		}
 		if (vma->vm_ops && vma->vm_ops->get_policy)
@@ -779,7 +779,7 @@ static long do_get_mempolicy(int *policy
 	}
 
 	if (vma) {
-		up_read(&current->mm->mmap_sem);
+		mm_reader_unlock(current->mm);
 		vma = NULL;
 	}
 
@@ -793,7 +793,7 @@ static long do_get_mempolicy(int *policy
  out:
 	mpol_cond_put(pol);
 	if (vma)
-		up_read(&current->mm->mmap_sem);
+		mm_reader_unlock(current->mm);
 	return err;
 }
 
@@ -861,7 +861,7 @@ int do_migrate_pages(struct mm_struct *m
 	if (err)
 		return err;
 
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 
 	err = migrate_vmas(mm, from_nodes, to_nodes, flags);
 	if (err)
@@ -927,7 +927,7 @@ int do_migrate_pages(struct mm_struct *m
 			break;
 	}
 out:
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 	if (err < 0)
 		return err;
 	return busy;
@@ -1032,12 +1032,12 @@ static long do_mbind(unsigned long start
 	{
 		NODEMASK_SCRATCH(scratch);
 		if (scratch) {
-			down_write(&mm->mmap_sem);
+			mm_writer_lock(mm);
 			task_lock(current);
 			err = mpol_set_nodemask(new, nmask, scratch);
 			task_unlock(current);
 			if (err)
-				up_write(&mm->mmap_sem);
+				mm_writer_unlock(mm);
 		} else
 			err = -ENOMEM;
 		NODEMASK_SCRATCH_FREE(scratch);
@@ -1063,7 +1063,7 @@ static long do_mbind(unsigned long start
 	} else
 		putback_lru_pages(&pagelist);
 
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
  mpol_out:
 	mpol_put(new);
 	return err;
Index: mmotm-2.6.32-Nov2/mm/mincore.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/mincore.c
+++ mmotm-2.6.32-Nov2/mm/mincore.c
@@ -209,9 +209,9 @@ SYSCALL_DEFINE3(mincore, unsigned long, 
 		 * Do at most PAGE_SIZE entries per iteration, due to
 		 * the temporary buffer size.
 		 */
-		down_read(&current->mm->mmap_sem);
+		mm_reader_lock(current->mm);
 		retval = do_mincore(start, tmp, min(pages, PAGE_SIZE));
-		up_read(&current->mm->mmap_sem);
+		mm_reader_unlock(current->mm);
 
 		if (retval <= 0)
 			break;
Index: mmotm-2.6.32-Nov2/mm/mlock.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/mlock.c
+++ mmotm-2.6.32-Nov2/mm/mlock.c
@@ -164,7 +164,7 @@ static long __mlock_vma_pages_range(stru
 	VM_BUG_ON(end   & ~PAGE_MASK);
 	VM_BUG_ON(start < vma->vm_start);
 	VM_BUG_ON(end   > vma->vm_end);
-	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+	VM_BUG_ON(!mm_locked(mm));
 
 	gup_flags = FOLL_TOUCH | FOLL_GET;
 	if (vma->vm_flags & VM_WRITE)
@@ -483,7 +483,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, st
 
 	lru_add_drain_all();	/* flush pagevec */
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
 	start &= PAGE_MASK;
 
@@ -496,7 +496,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, st
 	/* check against resource limits */
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
 		error = do_mlock(start, len, 1);
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 	return error;
 }
 
@@ -504,11 +504,11 @@ SYSCALL_DEFINE2(munlock, unsigned long, 
 {
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
 	start &= PAGE_MASK;
 	ret = do_mlock(start, len, 0);
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 	return ret;
 }
 
@@ -551,7 +551,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 
 	lru_add_drain_all();	/* flush pagevec */
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 
 	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
 	lock_limit >>= PAGE_SHIFT;
@@ -560,7 +560,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
 	    capable(CAP_IPC_LOCK))
 		ret = do_mlockall(flags);
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 out:
 	return ret;
 }
@@ -569,9 +569,9 @@ SYSCALL_DEFINE0(munlockall)
 {
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 	ret = do_mlockall(0);
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 	return ret;
 }
 
@@ -619,7 +619,7 @@ int account_locked_memory(struct mm_stru
 
 	pgsz = PAGE_ALIGN(size) >> PAGE_SHIFT;
 
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 
 	lim = rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT;
 	vm   = mm->total_vm + pgsz;
@@ -636,7 +636,7 @@ int account_locked_memory(struct mm_stru
 
 	error = 0;
  out:
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 	return error;
 }
 
@@ -644,10 +644,10 @@ void refund_locked_memory(struct mm_stru
 {
 	unsigned long pgsz = PAGE_ALIGN(size) >> PAGE_SHIFT;
 
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 
 	mm->total_vm  -= pgsz;
 	mm->locked_vm -= pgsz;
 
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 }
Index: mmotm-2.6.32-Nov2/drivers/infiniband/core/umem.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/drivers/infiniband/core/umem.c
+++ mmotm-2.6.32-Nov2/drivers/infiniband/core/umem.c
@@ -133,7 +133,7 @@ struct ib_umem *ib_umem_get(struct ib_uc
 
 	npages = PAGE_ALIGN(size + umem->offset) >> PAGE_SHIFT;
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 
 	locked     = npages + current->mm->locked_vm;
 	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur >> PAGE_SHIFT;
@@ -207,7 +207,7 @@ out:
 	} else
 		current->mm->locked_vm = locked;
 
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 	if (vma_list)
 		free_page((unsigned long) vma_list);
 	free_page((unsigned long) page_list);
@@ -220,9 +220,9 @@ static void ib_umem_account(struct work_
 {
 	struct ib_umem *umem = container_of(work, struct ib_umem, work);
 
-	down_write(&umem->mm->mmap_sem);
+	mm_writer_lock(umem->mm);
 	umem->mm->locked_vm -= umem->diff;
-	up_write(&umem->mm->mmap_sem);
+	mm_writer_lock(umem->mm);
 	mmput(umem->mm);
 	kfree(umem);
 }
@@ -256,7 +256,7 @@ void ib_umem_release(struct ib_umem *ume
 	 * we defer the vm_locked accounting to the system workqueue.
 	 */
 	if (context->closing) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
+		if (!mm_writer_trylock(mm)) {
 			INIT_WORK(&umem->work, ib_umem_account);
 			umem->mm   = mm;
 			umem->diff = diff;
@@ -265,10 +265,10 @@ void ib_umem_release(struct ib_umem *ume
 			return;
 		}
 	} else
-		down_write(&mm->mmap_sem);
+		mm_writer_lock(mm);
 
 	current->mm->locked_vm -= diff;
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 	mmput(mm);
 	kfree(umem);
 }
Index: mmotm-2.6.32-Nov2/drivers/oprofile/buffer_sync.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/drivers/oprofile/buffer_sync.c
+++ mmotm-2.6.32-Nov2/drivers/oprofile/buffer_sync.c
@@ -87,11 +87,11 @@ munmap_notify(struct notifier_block *sel
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *mpnt;
 
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 
 	mpnt = find_vma(mm, addr);
 	if (mpnt && mpnt->vm_file && (mpnt->vm_flags & VM_EXEC)) {
-		up_read(&mm->mmap_sem);
+		mm_reader_unlock(mm);
 		/* To avoid latency problems, we only process the current CPU,
 		 * hoping that most samples for the task are on this CPU
 		 */
@@ -99,7 +99,7 @@ munmap_notify(struct notifier_block *sel
 		return 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 	return 0;
 }
 
@@ -410,7 +410,7 @@ static void release_mm(struct mm_struct 
 {
 	if (!mm)
 		return;
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 	mmput(mm);
 }
 
@@ -419,7 +419,7 @@ static struct mm_struct *take_tasks_mm(s
 {
 	struct mm_struct *mm = get_task_mm(task);
 	if (mm)
-		down_read(&mm->mmap_sem);
+		mm_reader_unlock(mm);
 	return mm;
 }
 
Index: mmotm-2.6.32-Nov2/fs/aio.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/fs/aio.c
+++ mmotm-2.6.32-Nov2/fs/aio.c
@@ -103,9 +103,9 @@ static void aio_free_ring(struct kioctx 
 		put_page(info->ring_pages[i]);
 
 	if (info->mmap_size) {
-		down_write(&ctx->mm->mmap_sem);
+		mm_writer_lock(ctx->mm);
 		do_munmap(ctx->mm, info->mmap_base, info->mmap_size);
-		up_write(&ctx->mm->mmap_sem);
+		mm_writer_unlock(ctx->mm);
 	}
 
 	if (info->ring_pages && info->ring_pages != info->internal_pages)
@@ -144,12 +144,12 @@ static int aio_setup_ring(struct kioctx 
 
 	info->mmap_size = nr_pages * PAGE_SIZE;
 	dprintk("attempting mmap of %lu bytes\n", info->mmap_size);
-	down_write(&ctx->mm->mmap_sem);
+	mm_writer_lock(&ctx->mm);
 	info->mmap_base = do_mmap(NULL, 0, info->mmap_size, 
 				  PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_PRIVATE,
 				  0);
 	if (IS_ERR((void *)info->mmap_base)) {
-		up_write(&ctx->mm->mmap_sem);
+		mm_writer_unlock(&ctx->mm);
 		info->mmap_size = 0;
 		aio_free_ring(ctx);
 		return -EAGAIN;
@@ -159,7 +159,7 @@ static int aio_setup_ring(struct kioctx 
 	info->nr_pages = get_user_pages(current, ctx->mm,
 					info->mmap_base, nr_pages, 
 					1, 0, info->ring_pages, NULL);
-	up_write(&ctx->mm->mmap_sem);
+	mm_writer_unlock(ctx->mm);
 
 	if (unlikely(info->nr_pages != nr_pages)) {
 		aio_free_ring(ctx);
Index: mmotm-2.6.32-Nov2/fs/binfmt_elf.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/fs/binfmt_elf.c
+++ mmotm-2.6.32-Nov2/fs/binfmt_elf.c
@@ -81,9 +81,9 @@ static int set_brk(unsigned long start, 
 	end = ELF_PAGEALIGN(end);
 	if (end > start) {
 		unsigned long addr;
-		down_write(&current->mm->mmap_sem);
+		mm_writer_lock(current->mm);
 		addr = do_brk(start, end - start);
-		up_write(&current->mm->mmap_sem);
+		mm_writer_unlock(current->mm);
 		if (BAD_ADDR(addr))
 			return addr;
 	}
@@ -332,7 +332,7 @@ static unsigned long elf_map(struct file
 	if (!size)
 		return addr;
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 	/*
 	* total_size is the size of the ELF (interpreter) image.
 	* The _first_ mmap needs to know the full size, otherwise
@@ -349,7 +349,7 @@ static unsigned long elf_map(struct file
 	} else
 		map_addr = do_mmap(filep, addr, size, prot, type, off);
 
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 	return(map_addr);
 }
 
@@ -517,9 +517,9 @@ static unsigned long load_elf_interp(str
 		elf_bss = ELF_PAGESTART(elf_bss + ELF_MIN_ALIGN - 1);
 
 		/* Map the last of the bss segment */
-		down_write(&current->mm->mmap_sem);
+		mm_writer_lock(current->mm);
 		error = do_brk(elf_bss, last_bss - elf_bss);
-		up_write(&current->mm->mmap_sem);
+		mm_writer_unlock(current->mm);
 		if (BAD_ADDR(error))
 			goto out_close;
 	}
@@ -978,10 +978,10 @@ static int load_elf_binary(struct linux_
 		   and some applications "depend" upon this behavior.
 		   Since we do not have the power to recompile these, we
 		   emulate the SVr4 behavior. Sigh. */
-		down_write(&current->mm->mmap_sem);
+		mm_writer_lock(current->mm);
 		error = do_mmap(NULL, 0, PAGE_SIZE, PROT_READ | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE, 0);
-		up_write(&current->mm->mmap_sem);
+		mm_writer_unlock(current->mm);
 	}
 
 #ifdef ELF_PLAT_INIT
@@ -1066,7 +1066,7 @@ static int load_elf_library(struct file 
 		eppnt++;
 
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 	error = do_mmap(file,
 			ELF_PAGESTART(eppnt->p_vaddr),
 			(eppnt->p_filesz +
@@ -1075,7 +1075,7 @@ static int load_elf_library(struct file 
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			(eppnt->p_offset -
 			 ELF_PAGEOFFSET(eppnt->p_vaddr)));
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 	if (error != ELF_PAGESTART(eppnt->p_vaddr))
 		goto out_free_ph;
 
@@ -1089,9 +1089,9 @@ static int load_elf_library(struct file 
 			    ELF_MIN_ALIGN - 1);
 	bss = eppnt->p_memsz + eppnt->p_vaddr;
 	if (bss > len) {
-		down_write(&current->mm->mmap_sem);
+		mm_writer_lock(current->mm);
 		do_brk(len, bss - len);
-		up_write(&current->mm->mmap_sem);
+		mm_writer_unlock(current->mm);
 	}
 	error = 0;
 
Index: mmotm-2.6.32-Nov2/fs/nfs/direct.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/fs/nfs/direct.c
+++ mmotm-2.6.32-Nov2/fs/nfs/direct.c
@@ -309,10 +309,10 @@ static ssize_t nfs_direct_read_schedule_
 		if (unlikely(!data))
 			break;
 
-		down_read(&current->mm->mmap_sem);
+		mm_reader_lock(current->mm);
 		result = get_user_pages(current, current->mm, user_addr,
 					data->npages, 1, 0, data->pagevec, NULL);
-		up_read(&current->mm->mmap_sem);
+		mm_reader_unlock(current->mm);
 		if (result < 0) {
 			nfs_readdata_free(data);
 			break;
@@ -730,10 +730,10 @@ static ssize_t nfs_direct_write_schedule
 		if (unlikely(!data))
 			break;
 
-		down_read(&current->mm->mmap_sem);
+		mm_reader_lock(current->mm);
 		result = get_user_pages(current, current->mm, user_addr,
 					data->npages, 0, 0, data->pagevec, NULL);
-		up_read(&current->mm->mmap_sem);
+		mm_reader_unlock(current->mm);
 		if (result < 0) {
 			nfs_writedata_free(data);
 			break;
Index: mmotm-2.6.32-Nov2/fs/proc/array.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/fs/proc/array.c
+++ mmotm-2.6.32-Nov2/fs/proc/array.c
@@ -397,13 +397,13 @@ static inline void task_show_stack_usage
 	struct mm_struct	*mm = get_task_mm(task);
 
 	if (mm) {
-		down_read(&mm->mmap_sem);
+		mm_reader_lock(mm);
 		vma = find_vma(mm, task->stack_start);
 		if (vma)
 			seq_printf(m, "Stack usage:\t%lu kB\n",
 				get_stack_usage_in_bytes(vma, task) >> 10);
 
-		up_read(&mm->mmap_sem);
+		mm_reader_unlock(mm);
 		mmput(mm);
 	}
 }
Index: mmotm-2.6.32-Nov2/fs/proc/base.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/fs/proc/base.c
+++ mmotm-2.6.32-Nov2/fs/proc/base.c
@@ -1372,11 +1372,11 @@ struct file *get_mm_exe_file(struct mm_s
 
 	/* We need mmap_sem to protect against races with removal of
 	 * VM_EXECUTABLE vmas */
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 	exe_file = mm->exe_file;
 	if (exe_file)
 		get_file(exe_file);
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 	return exe_file;
 }
 
Index: mmotm-2.6.32-Nov2/fs/proc/task_mmu.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/fs/proc/task_mmu.c
+++ mmotm-2.6.32-Nov2/fs/proc/task_mmu.c
@@ -85,7 +85,7 @@ static void vma_stop(struct proc_maps_pr
 {
 	if (vma && vma != priv->tail_vma) {
 		struct mm_struct *mm = vma->vm_mm;
-		up_read(&mm->mmap_sem);
+		mm_reader_unlock(mm);
 		mmput(mm);
 	}
 }
@@ -119,7 +119,7 @@ static void *m_start(struct seq_file *m,
 	mm = mm_for_maps(priv->task);
 	if (!mm)
 		return NULL;
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 
 	tail_vma = get_gate_vma(priv->task);
 	priv->tail_vma = tail_vma;
@@ -152,7 +152,7 @@ out:
 
 	/* End of vmas has been reached */
 	m->version = (tail_vma != NULL)? 0: -1UL;
-	up_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 	mmput(mm);
 	return tail_vma;
 }
@@ -515,7 +515,7 @@ static ssize_t clear_refs_write(struct f
 			.pmd_entry = clear_refs_pte_range,
 			.mm = mm,
 		};
-		down_read(&mm->mmap_sem);
+		mm_reader_lock(mm);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			clear_refs_walk.private = vma;
 			if (is_vm_hugetlb_page(vma))
@@ -537,7 +537,7 @@ static ssize_t clear_refs_write(struct f
 					&clear_refs_walk);
 		}
 		flush_tlb_mm(mm);
-		up_read(&mm->mmap_sem);
+		mm_reader_unlock(mm);
 		mmput(mm);
 	}
 	put_task_struct(task);
@@ -723,10 +723,10 @@ static ssize_t pagemap_read(struct file 
 	if (!pages)
 		goto out_mm;
 
-	down_read(&current->mm->mmap_sem);
+	mm_reader_lock(current->mm);
 	ret = get_user_pages(current, current->mm, uaddr, pagecount,
 			     1, 0, pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_reader_unlock(current->mm);
 
 	if (ret < 0)
 		goto out_free;
Index: mmotm-2.6.32-Nov2/kernel/trace/trace_output.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/kernel/trace/trace_output.c
+++ mmotm-2.6.32-Nov2/kernel/trace/trace_output.c
@@ -376,7 +376,7 @@ int seq_print_user_ip(struct trace_seq *
 	if (mm) {
 		const struct vm_area_struct *vma;
 
-		down_read(&mm->mmap_sem);
+		mm_reader_lock(mm);
 		vma = find_vma(mm, ip);
 		if (vma) {
 			file = vma->vm_file;
@@ -388,7 +388,7 @@ int seq_print_user_ip(struct trace_seq *
 				ret = trace_seq_printf(s, "[+0x%lx]",
 						       ip - vmstart);
 		}
-		up_read(&mm->mmap_sem);
+		mm_reader_unlock(mm);
 	}
 	if (ret && ((sym_flags & TRACE_ITER_SYM_ADDR) || !file))
 		ret = trace_seq_printf(s, " <" IP_FMT ">", ip);
Index: mmotm-2.6.32-Nov2/arch/x86/kernel/sys_i386_32.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/arch/x86/kernel/sys_i386_32.c
+++ mmotm-2.6.32-Nov2/arch/x86/kernel/sys_i386_32.c
@@ -39,9 +39,9 @@ asmlinkage long sys_mmap2(unsigned long 
 			goto out;
 	}
 
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 
 	if (file)
 		fput(file);
Index: mmotm-2.6.32-Nov2/arch/x86/vdso/vdso32-setup.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/arch/x86/vdso/vdso32-setup.c
+++ mmotm-2.6.32-Nov2/arch/x86/vdso/vdso32-setup.c
@@ -320,7 +320,7 @@ int arch_setup_additional_pages(struct l
 	if (vdso_enabled == VDSO_DISABLED)
 		return 0;
 
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 
 	/* Test compat mode once here, in case someone
 	   changes it via sysctl */
@@ -367,7 +367,7 @@ int arch_setup_additional_pages(struct l
 	if (ret)
 		current->mm->context.vdso = NULL;
 
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 
 	return ret;
 }
Index: mmotm-2.6.32-Nov2/kernel/acct.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/kernel/acct.c
+++ mmotm-2.6.32-Nov2/kernel/acct.c
@@ -608,13 +608,13 @@ void acct_collect(long exitcode, int gro
 
 	if (group_dead && current->mm) {
 		struct vm_area_struct *vma;
-		down_read(&current->mm->mmap_sem);
+		mm_reader_lock(current->mm);
 		vma = current->mm->mmap;
 		while (vma) {
 			vsize += vma->vm_end - vma->vm_start;
 			vma = vma->vm_next;
 		}
-		up_read(&current->mm->mmap_sem);
+		mm_reader_unlock(current->mm);
 	}
 
 	spin_lock_irq(&current->sighand->siglock);
Index: mmotm-2.6.32-Nov2/arch/x86/ia32/sys_ia32.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/arch/x86/ia32/sys_ia32.c
+++ mmotm-2.6.32-Nov2/arch/x86/ia32/sys_ia32.c
@@ -172,13 +172,13 @@ asmlinkage long sys32_mmap(struct mmap_a
 	}
 
 	mm = current->mm;
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 	retval = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags,
 			       a.offset>>PAGE_SHIFT);
 	if (file)
 		fput(file);
 
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 
 	return retval;
 }
@@ -554,9 +554,9 @@ asmlinkage long sys32_mmap2(unsigned lon
 			return -EBADF;
 	}
 
-	down_write(&mm->mmap_sem);
+	mm_writer_lock(mm);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&mm->mmap_sem);
+	mm_writer_unlock(mm);
 
 	if (file)
 		fput(file);
Index: mmotm-2.6.32-Nov2/kernel/auditsc.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/kernel/auditsc.c
+++ mmotm-2.6.32-Nov2/kernel/auditsc.c
@@ -960,7 +960,7 @@ static void audit_log_task_info(struct a
 	audit_log_untrustedstring(ab, name);
 
 	if (mm) {
-		down_read(&mm->mmap_sem);
+		mm_reader_lock(mm);
 		vma = mm->mmap;
 		while (vma) {
 			if ((vma->vm_flags & VM_EXECUTABLE) &&
@@ -971,7 +971,7 @@ static void audit_log_task_info(struct a
 			}
 			vma = vma->vm_next;
 		}
-		up_read(&mm->mmap_sem);
+		mm_reader_unlock(mm);
 	}
 	audit_log_task_context(ab);
 }
Index: mmotm-2.6.32-Nov2/drivers/gpu/drm/drm_bufs.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/drivers/gpu/drm/drm_bufs.c
+++ mmotm-2.6.32-Nov2/drivers/gpu/drm/drm_bufs.c
@@ -1574,18 +1574,18 @@ int drm_mapbufs(struct drm_device *dev, 
 				retcode = -EINVAL;
 				goto done;
 			}
-			down_write(&current->mm->mmap_sem);
+			mm_writer_lock(current->mm);
 			virtual = do_mmap(file_priv->filp, 0, map->size,
 					  PROT_READ | PROT_WRITE,
 					  MAP_SHARED,
 					  token);
-			up_write(&current->mm->mmap_sem);
+			mm_writer_unlock(current->mm);
 		} else {
-			down_write(&current->mm->mmap_sem);
+			mm_writer_lock(current->mm);
 			virtual = do_mmap(file_priv->filp, 0, dma->byte_count,
 					  PROT_READ | PROT_WRITE,
 					  MAP_SHARED, 0);
-			up_write(&current->mm->mmap_sem);
+			mm_writer_unlock(current->mm);
 		}
 		if (virtual > -1024UL) {
 			/* Real error */
Index: mmotm-2.6.32-Nov2/drivers/gpu/drm/i810/i810_dma.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/drivers/gpu/drm/i810/i810_dma.c
+++ mmotm-2.6.32-Nov2/drivers/gpu/drm/i810/i810_dma.c
@@ -131,7 +131,7 @@ static int i810_map_buffer(struct drm_bu
 	if (buf_priv->currently_mapped == I810_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 	old_fops = file_priv->filp->f_op;
 	file_priv->filp->f_op = &i810_buffer_fops;
 	dev_priv->mmap_buffer = buf;
@@ -146,7 +146,7 @@ static int i810_map_buffer(struct drm_bu
 		retcode = PTR_ERR(buf_priv->virtual);
 		buf_priv->virtual = NULL;
 	}
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 
 	return retcode;
 }
@@ -159,11 +159,11 @@ static int i810_unmap_buffer(struct drm_
 	if (buf_priv->currently_mapped != I810_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 	retcode = do_munmap(current->mm,
 			    (unsigned long)buf_priv->virtual,
 			    (size_t) buf->total);
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 
 	buf_priv->currently_mapped = I810_BUF_UNMAPPED;
 	buf_priv->virtual = NULL;
Index: mmotm-2.6.32-Nov2/drivers/gpu/drm/i830/i830_dma.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/drivers/gpu/drm/i830/i830_dma.c
+++ mmotm-2.6.32-Nov2/drivers/gpu/drm/i830/i830_dma.c
@@ -134,7 +134,7 @@ static int i830_map_buffer(struct drm_bu
 	if (buf_priv->currently_mapped == I830_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 	old_fops = file_priv->filp->f_op;
 	file_priv->filp->f_op = &i830_buffer_fops;
 	dev_priv->mmap_buffer = buf;
@@ -150,7 +150,7 @@ static int i830_map_buffer(struct drm_bu
 	} else {
 		buf_priv->virtual = (void __user *)virtual;
 	}
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 
 	return retcode;
 }
@@ -163,11 +163,11 @@ static int i830_unmap_buffer(struct drm_
 	if (buf_priv->currently_mapped != I830_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 	retcode = do_munmap(current->mm,
 			    (unsigned long)buf_priv->virtual,
 			    (size_t) buf->total);
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 
 	buf_priv->currently_mapped = I830_BUF_UNMAPPED;
 	buf_priv->virtual = NULL;
Index: mmotm-2.6.32-Nov2/drivers/gpu/drm/i915/i915_gem.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/drivers/gpu/drm/i915/i915_gem.c
+++ mmotm-2.6.32-Nov2/drivers/gpu/drm/i915/i915_gem.c
@@ -398,10 +398,10 @@ i915_gem_shmem_pread_slow(struct drm_dev
 	if (user_pages == NULL)
 		return -ENOMEM;
 
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 	pinned_pages = get_user_pages(current, mm, (uintptr_t)args->data_ptr,
 				      num_pages, 1, 0, user_pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 	if (pinned_pages < num_pages) {
 		ret = -EFAULT;
 		goto fail_put_user_pages;
@@ -698,10 +698,10 @@ i915_gem_gtt_pwrite_slow(struct drm_devi
 	if (user_pages == NULL)
 		return -ENOMEM;
 
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 	pinned_pages = get_user_pages(current, mm, (uintptr_t)args->data_ptr,
 				      num_pages, 0, 0, user_pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 	if (pinned_pages < num_pages) {
 		ret = -EFAULT;
 		goto out_unpin_pages;
@@ -873,10 +873,10 @@ i915_gem_shmem_pwrite_slow(struct drm_de
 	if (user_pages == NULL)
 		return -ENOMEM;
 
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 	pinned_pages = get_user_pages(current, mm, (uintptr_t)args->data_ptr,
 				      num_pages, 0, 0, user_pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 	if (pinned_pages < num_pages) {
 		ret = -EFAULT;
 		goto fail_put_user_pages;
@@ -1149,11 +1149,11 @@ i915_gem_mmap_ioctl(struct drm_device *d
 
 	offset = args->offset;
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 	addr = do_mmap(obj->filp, 0, args->size,
 		       PROT_READ | PROT_WRITE, MAP_SHARED,
 		       args->offset);
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 	mutex_lock(&dev->struct_mutex);
 	drm_gem_object_unreference(obj);
 	mutex_unlock(&dev->struct_mutex);
Index: mmotm-2.6.32-Nov2/drivers/gpu/drm/ttm/ttm_tt.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/drivers/gpu/drm/ttm/ttm_tt.c
+++ mmotm-2.6.32-Nov2/drivers/gpu/drm/ttm/ttm_tt.c
@@ -357,10 +357,10 @@ int ttm_tt_set_user(struct ttm_tt *ttm,
 	if (unlikely(ret != 0))
 		return ret;
 
-	down_read(&mm->mmap_sem);
+	mm_reader_lock(mm);
 	ret = get_user_pages(tsk, mm, start, num_pages,
 			     write, 0, ttm->pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_reader_unlock(mm);
 
 	if (ret != num_pages && write) {
 		ttm_tt_free_user_pages(ttm);
Index: mmotm-2.6.32-Nov2/drivers/gpu/drm/via/via_dmablit.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/drivers/gpu/drm/via/via_dmablit.c
+++ mmotm-2.6.32-Nov2/drivers/gpu/drm/via/via_dmablit.c
@@ -237,14 +237,14 @@ via_lock_all_dma_pages(drm_via_sg_info_t
 	if (NULL == (vsg->pages = vmalloc(sizeof(struct page *) * vsg->num_pages)))
 		return -ENOMEM;
 	memset(vsg->pages, 0, sizeof(struct page *) * vsg->num_pages);
-	down_read(&current->mm->mmap_sem);
+	mm_reader_lock(current->mm);
 	ret = get_user_pages(current, current->mm,
 			     (unsigned long)xfer->mem_addr,
 			     vsg->num_pages,
 			     (vsg->direction == DMA_FROM_DEVICE),
 			     0, vsg->pages, NULL);
 
-	up_read(&current->mm->mmap_sem);
+	mm_reader_unlock(current->mm);
 	if (ret != vsg->num_pages) {
 		if (ret < 0)
 			return ret;
Index: mmotm-2.6.32-Nov2/drivers/infiniband/hw/ipath/ipath_user_pages.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/drivers/infiniband/hw/ipath/ipath_user_pages.c
+++ mmotm-2.6.32-Nov2/drivers/infiniband/hw/ipath/ipath_user_pages.c
@@ -163,24 +163,24 @@ int ipath_get_user_pages(unsigned long s
 {
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 
 	ret = __get_user_pages(start_page, num_pages, p, NULL);
 
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 
 	return ret;
 }
 
 void ipath_release_user_pages(struct page **p, size_t num_pages)
 {
-	down_write(&current->mm->mmap_sem);
+	mm_writer_lock(current->mm);
 
 	__ipath_release_user_pages(p, num_pages, 1);
 
 	current->mm->locked_vm -= num_pages;
 
-	up_write(&current->mm->mmap_sem);
+	mm_writer_unlock(current->mm);
 }
 
 struct ipath_user_pages_work {
@@ -194,9 +194,9 @@ static void user_pages_account(struct wo
 	struct ipath_user_pages_work *work =
 		container_of(_work, struct ipath_user_pages_work, work);
 
-	down_write(&work->mm->mmap_sem);
+	mm_writer_lock(work->mm);
 	work->mm->locked_vm -= work->num_pages;
-	up_write(&work->mm->mmap_sem);
+	mm_writer_unlock(work->mm);
 	mmput(work->mm);
 	kfree(work);
 }
Index: mmotm-2.6.32-Nov2/drivers/infiniband/hw/ipath/ipath_user_sdma.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/drivers/infiniband/hw/ipath/ipath_user_sdma.c
+++ mmotm-2.6.32-Nov2/drivers/infiniband/hw/ipath/ipath_user_sdma.c
@@ -811,9 +811,9 @@ int ipath_user_sdma_writev(struct ipath_
 	while (dim) {
 		const int mxp = 8;
 
-		down_write(&current->mm->mmap_sem);
+		mm_writer_lock(current->mm);
 		ret = ipath_user_sdma_queue_pkts(dd, pq, &list, iov, dim, mxp);
-		up_write(&current->mm->mmap_sem);
+		mm_writer_unlock(current->mm);
 
 		if (ret <= 0)
 			goto done_unlock;
Index: mmotm-2.6.32-Nov2/drivers/scsi/st.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/drivers/scsi/st.c
+++ mmotm-2.6.32-Nov2/drivers/scsi/st.c
@@ -4553,7 +4553,7 @@ static int sgl_map_user_pages(struct st_
 		return -ENOMEM;
 
         /* Try to fault in all of the necessary pages */
-	down_read(&current->mm->mmap_sem);
+	mm_reader_lock(current->mm);
         /* rw==READ means read from drive, write into memory area */
 	res = get_user_pages(
 		current,
@@ -4564,7 +4564,7 @@ static int sgl_map_user_pages(struct st_
 		0, /* don't force */
 		pages,
 		NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_reader_unlock(current->mm);
 
 	/* Errors and no page mapped should return here */
 	if (res < nr_pages)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
