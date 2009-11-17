Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 084FB6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 01:40:22 -0500 (EST)
Subject: Re: [RFC MM] Accessors for mm locking
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 17 Nov 2009 14:42:38 +0800
Message-Id: <1258440158.11321.27.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-11-05 at 14:19 -0500, Christoph Lameter wrote:
> From: Christoph Lameter <cl@linux-foundation.org>
> Subject: [RFC MM] Accessors for mm locking
> 
> Scaling of MM locking has been a concern for a long time. With the arrival of
> high thread counts in average business systems we may finally have to do
> something about that.
> 
> This patch provides a series of accessors for mm locking so that the details
> of mm locking (which is done today via mmap_sem) are hidden. This allows us
> to try various implemenations of mm locking to solve the scaling issues.
> 
> Note that this patch is currently incomplete and just does enough to get my
> kernels compiled on two platforms. If we agree on the naming etc
> then I will complete this patch and do the accessor conversion for all of
> the kernel.
When I tried to test the patches against tj/percpu.git, compilation failed.
Many files around DRM and ia32 are not changed. I fixed it or worked around the
compilation errors.

Then, new kernel hanged when I ran 'make oldconfig'. After reviewing the patch,
I found many places where you just miss lock and unlock. Comments inlined below.


> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> ---
>  arch/x86/kernel/sys_i386_32.c  |    4 +-
>  arch/x86/kernel/sys_x86_64.c   |    4 +-
>  arch/x86/mm/fault.c            |   14 ++++-----
>  arch/x86/mm/gup.c              |    4 +-
>  arch/x86/vdso/vdso32-setup.c   |    4 +-
>  arch/x86/vdso/vma.c            |    4 +-
>  drivers/infiniband/core/umem.c |   14 ++++-----
>  drivers/oprofile/buffer_sync.c |   10 +++---
>  fs/aio.c                       |   10 +++---
>  fs/binfmt_elf.c                |   24 +++++++--------
>  fs/exec.c                      |   24 +++++++--------
>  fs/nfs/direct.c                |    8 ++---
>  fs/proc/array.c                |    4 +-
>  fs/proc/base.c                 |    4 +-
>  fs/proc/task_mmu.c             |   14 ++++-----
>  include/linux/mm_types.h       |   62 ++++++++++++++++++++++++++++++++++++++++-
>  ipc/shm.c                      |    8 ++---
>  kernel/exit.c                  |    8 ++---
>  kernel/fork.c                  |   10 +++---
>  kernel/trace/trace_output.c    |    4 +-
>  mm/fremap.c                    |   12 +++----
>  mm/init-mm.c                   |    2 -
>  mm/madvise.c                   |   12 +++----
>  mm/memory.c                    |    8 ++---
>  mm/mempolicy.c                 |   28 +++++++++---------
>  mm/migrate.c                   |    8 ++---
>  mm/mincore.c                   |    4 +-
>  mm/mlock.c                     |   26 ++++++++---------
>  mm/mmap.c                      |   20 ++++++-------
>  mm/mmu_notifier.c              |    4 +-
>  mm/mprotect.c                  |    4 +-
>  mm/mremap.c                    |    4 +-
>  mm/msync.c                     |    8 ++---
>  mm/rmap.c                      |   12 +++----
>  mm/swapfile.c                  |    6 +--
>  mm/util.c                      |    4 +-
>  36 files changed, 230 insertions(+), 170 deletions(-)
> 
> Index: linux-2.6/arch/x86/mm/fault.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/mm/fault.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/arch/x86/mm/fault.c	2009-11-05 13:02:41.000000000 -0600
> @@ -758,7 +758,7 @@ __bad_area(struct pt_regs *regs, unsigne
>  	 * Something tried to access memory that isn't in our memory map..
>  	 * Fix it, but check if it's kernel or user first..
>  	 */
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);
> 
>  	__bad_area_nosemaphore(regs, error_code, address, si_code);
>  }
> @@ -785,7 +785,7 @@ out_of_memory(struct pt_regs *regs, unsi
>  	 * We ran out of memory, call the OOM killer, and return the userspace
>  	 * (which will retry the fault, or kill us if we got oom-killed):
>  	 */
> -	up_read(&current->mm->mmap_sem);
> +	mm_reader_unlock(current->mm);
> 
>  	pagefault_out_of_memory();
>  }
> @@ -798,7 +798,7 @@ do_sigbus(struct pt_regs *regs, unsigned
>  	struct mm_struct *mm = tsk->mm;
>  	int code = BUS_ADRERR;
> 
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);
> 
>  	/* Kernel mode? Handle exceptions or die: */
>  	if (!(error_code & PF_USER))
> @@ -964,7 +964,7 @@ do_page_fault(struct pt_regs *regs, unsi
>  	 */
>  	if (kmemcheck_active(regs))
>  		kmemcheck_hide(regs);
> -	prefetchw(&mm->mmap_sem);
> +	mm_lock_prefetch(mm);
> 
>  	if (unlikely(kmmio_fault(regs, address)))
>  		return;
> @@ -1055,13 +1055,13 @@ do_page_fault(struct pt_regs *regs, unsi
>  	 * validate the source. If this is invalid we can skip the address
>  	 * space check, thus avoiding the deadlock:
>  	 */
> -	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
> +	if (unlikely(!mm_reader_trylock(mm))) {
>  		if ((error_code & PF_USER) == 0 &&
>  		    !search_exception_tables(regs->ip)) {
>  			bad_area_nosemaphore(regs, error_code, address);
>  			return;
>  		}
> -		down_read(&mm->mmap_sem);
> +		mm_reader_lock(mm);
>  	} else {
>  		/*
>  		 * The above down_read_trylock() might have succeeded in
> @@ -1135,5 +1135,5 @@ good_area:
> 
>  	check_v8086_mode(regs, address, tsk);
> 
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);
>  }
> Index: linux-2.6/include/linux/mm_types.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm_types.h	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/include/linux/mm_types.h	2009-11-05 13:03:11.000000000 -0600
> @@ -214,7 +214,7 @@ struct mm_struct {
>  	atomic_t mm_users;			/* How many users with user space? */
>  	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
>  	int map_count;				/* number of VMAs */
> -	struct rw_semaphore mmap_sem;
> +	struct rw_semaphore sem;
>  	spinlock_t page_table_lock;		/* Protects page tables and some counters */
> 
>  	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
> @@ -285,6 +285,66 @@ struct mm_struct {
>  #endif
>  };
> 
> +static inline void mm_reader_lock(struct mm_struct *mm)
> +{
> +	down_read(&mm->sem);
> +}
> +
> +static inline void mm_reader_unlock(struct mm_struct *mm)
> +{
> +	up_read(&mm->sem);
> +}
> +
> +static inline int mm_reader_trylock(struct mm_struct *mm)
> +{
> +	return down_read_trylock(&mm->sem);
> +}
> +
> +static inline void mm_writer_lock(struct mm_struct *mm)
> +{
> +	down_write(&mm->sem);
> +}
> +
> +static inline void mm_writer_unlock(struct mm_struct *mm)
> +{
> +	up_write(&mm->sem);
> +}
> +
> +static inline int mm_writer_trylock(struct mm_struct *mm)
> +{
> +	return down_write_trylock(&mm->sem);
> +}
> +
> +static inline int mm_locked(struct mm_struct *mm)
> +{
> +	return rwsem_is_locked(&mm->sem);
> +}
> +
> +static inline void mm_writer_to_reader_lock(struct mm_struct *mm)
> +{
> +	downgrade_write(&mm->sem);
> +}
> +
> +static inline void mm_writer_lock_nested(struct mm_struct *mm, int x)
> +{
> +	down_write_nested(&mm->sem, x);
> +}
> +
> +static inline void mm_lock_init(struct mm_struct *mm)
> +{
> +	init_rwsem(&mm->sem);
> +}
> +
> +static inline void mm_lock_prefetch(struct mm_struct *mm)
> +{
> +	prefetchw(&mm->sem);
> +}
> +
> +static inline void mm_nest_lock(spinlock_t *s, struct mm_struct *mm)
> +{
> +	spin_lock_nest_lock(s, &mm->sem);
> +}
> +
>  /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
>  #define mm_cpumask(mm) (&(mm)->cpu_vm_mask)
> 
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/memory.c	2009-11-05 13:02:41.000000000 -0600
> @@ -3252,7 +3252,7 @@ int access_process_vm(struct task_struct
>  	if (!mm)
>  		return 0;
> 
> -	down_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
>  	/* ignore errors, just check how much was successfully transferred */
>  	while (len) {
>  		int bytes, ret, offset;
> @@ -3299,7 +3299,7 @@ int access_process_vm(struct task_struct
>  		buf += bytes;
>  		addr += bytes;
>  	}
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);
>  	mmput(mm);
> 
>  	return buf - old_buf;
> @@ -3320,7 +3320,7 @@ void print_vma_addr(char *prefix, unsign
>  	if (preempt_count())
>  		return;
> 
> -	down_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
>  	vma = find_vma(mm, ip);
>  	if (vma && vma->vm_file) {
>  		struct file *f = vma->vm_file;
> @@ -3340,7 +3340,7 @@ void print_vma_addr(char *prefix, unsign
>  			free_page((unsigned long)buf);
>  		}
>  	}
> -	up_read(&current->mm->mmap_sem);
> +	mm_reader_unlock(mm);
>  }
> 
>  #ifdef CONFIG_PROVE_LOCKING
> Index: linux-2.6/mm/migrate.c
> ===================================================================
> --- linux-2.6.orig/mm/migrate.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/migrate.c	2009-11-05 13:02:41.000000000 -0600
> @@ -836,7 +836,7 @@ static int do_move_page_to_node_array(st
>  	struct page_to_node *pp;
>  	LIST_HEAD(pagelist);
> 
> -	down_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
> 
>  	/*
>  	 * Build a list of pages to migrate
> @@ -896,7 +896,7 @@ set_status:
>  		err = migrate_pages(&pagelist, new_page_node,
>  				(unsigned long)pm);
> 
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);
>  	return err;
>  }
> 
> @@ -995,7 +995,7 @@ static void do_pages_stat_array(struct m
>  {
>  	unsigned long i;
> 
> -	down_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
> 
>  	for (i = 0; i < nr_pages; i++) {
>  		unsigned long addr = (unsigned long)(*pages);
> @@ -1026,7 +1026,7 @@ set_status:
>  		status++;
>  	}
> 
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);
>  }
> 
>  /*
> Index: linux-2.6/mm/mmap.c
> ===================================================================
> --- linux-2.6.orig/mm/mmap.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/mmap.c	2009-11-05 13:02:41.000000000 -0600
> @@ -250,7 +250,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
>  	struct mm_struct *mm = current->mm;
>  	unsigned long min_brk;
> 
> -	down_write(&mm->mmap_sem);
> +	mm_writer_lock(mm);
> 
>  #ifdef CONFIG_COMPAT_BRK
>  	min_brk = mm->end_code;
> @@ -294,7 +294,7 @@ set_brk:
>  	mm->brk = brk;
>  out:
>  	retval = mm->brk;
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
>  	return retval;
>  }
> 
> @@ -1969,18 +1969,18 @@ SYSCALL_DEFINE2(munmap, unsigned long, a
> 
>  	profile_munmap(addr);
> 
> -	down_write(&mm->mmap_sem);
> +	mm_writer_lock(mm);
>  	ret = do_munmap(mm, addr, len);
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
>  	return ret;
>  }
> 
>  static inline void verify_mm_writelocked(struct mm_struct *mm)
>  {
>  #ifdef CONFIG_DEBUG_VM
> -	if (unlikely(down_read_trylock(&mm->mmap_sem))) {
> +	if (unlikely(mm_reader_trylock(mm))) {
>  		WARN_ON(1);
> -		up_read(&mm->mmap_sem);
> +		mm_reader_unlock(mm);
>  	}
>  #endif
>  }
> @@ -2337,7 +2337,7 @@ static void vm_lock_anon_vma(struct mm_s
>  		 * The LSB of head.next can't change from under us
>  		 * because we hold the mm_all_locks_mutex.
>  		 */
> -		spin_lock_nest_lock(&anon_vma->lock, &mm->mmap_sem);
> +		mm_nest_lock(&anon_vma->lock, mm);
>  		/*
>  		 * We can safely modify head.next after taking the
>  		 * anon_vma->lock. If some other vma in this mm shares
> @@ -2367,7 +2367,7 @@ static void vm_lock_mapping(struct mm_st
>  		 */
>  		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
>  			BUG();
> -		spin_lock_nest_lock(&mapping->i_mmap_lock, &mm->mmap_sem);
> +		mm_nest_lock(&mapping->i_mmap_lock, mm);
>  	}
>  }
> 
> @@ -2408,7 +2408,7 @@ int mm_take_all_locks(struct mm_struct *
>  	struct vm_area_struct *vma;
>  	int ret = -EINTR;
> 
> -	BUG_ON(down_read_trylock(&mm->mmap_sem));
> +	BUG_ON(mm_reader_trylock(mm));
> 
>  	mutex_lock(&mm_all_locks_mutex);
> 
> @@ -2479,7 +2479,7 @@ void mm_drop_all_locks(struct mm_struct
>  {
>  	struct vm_area_struct *vma;
> 
> -	BUG_ON(down_read_trylock(&mm->mmap_sem));
> +	BUG_ON(mm_reader_trylock(mm));
>  	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));
> 
>  	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> Index: linux-2.6/mm/mmu_notifier.c
> ===================================================================
> --- linux-2.6.orig/mm/mmu_notifier.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/mmu_notifier.c	2009-11-05 13:02:41.000000000 -0600
> @@ -176,7 +176,7 @@ static int do_mmu_notifier_register(stru
>  		goto out;
> 
>  	if (take_mmap_sem)
> -		down_write(&mm->mmap_sem);
> +		mm_writer_lock(mm);
>  	ret = mm_take_all_locks(mm);
>  	if (unlikely(ret))
>  		goto out_cleanup;
> @@ -204,7 +204,7 @@ static int do_mmu_notifier_register(stru
>  	mm_drop_all_locks(mm);
>  out_cleanup:
>  	if (take_mmap_sem)
> -		up_write(&mm->mmap_sem);
> +		mm_writer_unlock(mm);
>  	/* kfree() does nothing if mmu_notifier_mm is NULL */
>  	kfree(mmu_notifier_mm);
>  out:
> Index: linux-2.6/mm/mprotect.c
> ===================================================================
> --- linux-2.6.orig/mm/mprotect.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/mprotect.c	2009-11-05 13:02:41.000000000 -0600
> @@ -250,7 +250,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
> 
>  	vm_flags = calc_vm_prot_bits(prot);
> 
> -	down_write(&current->mm->mmap_sem);
> +	mm_writer_lock(current->mm);
> 
>  	vma = find_vma_prev(current->mm, start, &prev);
>  	error = -ENOMEM;
> @@ -315,6 +315,6 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
>  		}
>  	}
>  out:
> -	up_write(&current->mm->mmap_sem);
> +	mm_writer_unlock(current->mm);
>  	return error;
>  }
> Index: linux-2.6/mm/mremap.c
> ===================================================================
> --- linux-2.6.orig/mm/mremap.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/mremap.c	2009-11-05 13:02:41.000000000 -0600
> @@ -440,8 +440,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, a
>  {
>  	unsigned long ret;
> 
> -	down_write(&current->mm->mmap_sem);
> +	mm_writer_lock(current->mm);
>  	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
> -	up_write(&current->mm->mmap_sem);
> +	mm_writer_unlock(current->mm);
>  	return ret;
>  }
> Index: linux-2.6/mm/msync.c
> ===================================================================
> --- linux-2.6.orig/mm/msync.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/msync.c	2009-11-05 13:02:41.000000000 -0600
> @@ -54,7 +54,7 @@ SYSCALL_DEFINE3(msync, unsigned long, st
>  	 * If the interval [start,end) covers some unmapped address ranges,
>  	 * just ignore them, but return -ENOMEM at the end.
>  	 */
> -	down_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
>  	vma = find_vma(mm, start);
>  	for (;;) {
>  		struct file *file;
> @@ -81,12 +81,12 @@ SYSCALL_DEFINE3(msync, unsigned long, st
>  		if ((flags & MS_SYNC) && file &&
>  				(vma->vm_flags & VM_SHARED)) {
>  			get_file(file);
> -			up_read(&mm->mmap_sem);
> +			mm_reader_unlock(mm);
>  			error = vfs_fsync(file, file->f_path.dentry, 0);
>  			fput(file);
>  			if (error || start >= end)
>  				goto out;
> -			down_read(&mm->mmap_sem);
> +			mm_reader_lock(mm);
>  			vma = find_vma(mm, start);
>  		} else {
>  			if (start >= end) {
> @@ -97,7 +97,7 @@ SYSCALL_DEFINE3(msync, unsigned long, st
>  		}
>  	}
>  out_unlock:
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);
>  out:
>  	return error ? : unmapped_error;
>  }
> Index: linux-2.6/mm/rmap.c
> ===================================================================
> --- linux-2.6.orig/mm/rmap.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/rmap.c	2009-11-05 13:02:41.000000000 -0600
> @@ -382,7 +382,7 @@ static int page_referenced_one(struct pa
>  	/* Pretend the page is referenced if the task has the
>  	   swap token and is in the middle of a page fault. */
>  	if (mm != current->mm && has_swap_token(mm) &&
> -			rwsem_is_locked(&mm->mmap_sem))
> +			mm_locked(mm))
>  		referenced++;
> 
>  out_unmap:
> @@ -926,10 +926,10 @@ static int try_to_unmap_cluster(unsigned
>  	 * if we can acquire the mmap_sem for read, and vma is VM_LOCKED,
>  	 * keep the sem while scanning the cluster for mlocking pages.
>  	 */
> -	if (MLOCK_PAGES && down_read_trylock(&vma->vm_mm->mmap_sem)) {
> +	if (MLOCK_PAGES && mm_reader_trylock(vma->vm_mm)) {
>  		locked_vma = (vma->vm_flags & VM_LOCKED);
>  		if (!locked_vma)
> -			up_read(&vma->vm_mm->mmap_sem); /* don't need it */
> +			mm_reader_lock(vma->vm_mm); /* don't need it */
>  	}
> 
>  	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
> @@ -972,7 +972,7 @@ static int try_to_unmap_cluster(unsigned
>  	}
>  	pte_unmap_unlock(pte - 1, ptl);
>  	if (locked_vma)
> -		up_read(&vma->vm_mm->mmap_sem);
> +		mm_reader_unlock(vma->vm_mm);
>  	return ret;
>  }
> 
> @@ -983,12 +983,12 @@ static int try_to_mlock_page(struct page
>  {
>  	int mlocked = 0;
> 
> -	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
> +	if (mm_reader_trylock(vma->vm_mm)) {
>  		if (vma->vm_flags & VM_LOCKED) {
>  			mlock_vma_page(page);
>  			mlocked++;	/* really mlocked the page */
>  		}
> -		up_read(&vma->vm_mm->mmap_sem);
> +		mm_reader_lock(vma->vm_mm);
>  	}
>  	return mlocked;
>  }
> Index: linux-2.6/mm/swapfile.c
> ===================================================================
> --- linux-2.6.orig/mm/swapfile.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/swapfile.c	2009-11-05 13:02:41.000000000 -0600
> @@ -961,21 +961,21 @@ static int unuse_mm(struct mm_struct *mm
>  	struct vm_area_struct *vma;
>  	int ret = 0;
> 
> -	if (!down_read_trylock(&mm->mmap_sem)) {
> +	if (!mm_reader_trylock(mm)) {
>  		/*
>  		 * Activate page so shrink_inactive_list is unlikely to unmap
>  		 * its ptes while lock is dropped, so swapoff can make progress.
>  		 */
>  		activate_page(page);
>  		unlock_page(page);
> -		down_read(&mm->mmap_sem);
> +		mm_reader_lock(mm);
>  		lock_page(page);
>  	}
>  	for (vma = mm->mmap; vma; vma = vma->vm_next) {
>  		if (vma->anon_vma && (ret = unuse_vma(vma, entry, page)))
>  			break;
>  	}
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);
>  	return (ret < 0)? ret: 0;
>  }
> 
> Index: linux-2.6/mm/util.c
> ===================================================================
> --- linux-2.6.orig/mm/util.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/util.c	2009-11-05 13:02:41.000000000 -0600
> @@ -259,10 +259,10 @@ int __attribute__((weak)) get_user_pages
>  	struct mm_struct *mm = current->mm;
>  	int ret;
> 
> -	down_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
>  	ret = get_user_pages(current, mm, start, nr_pages,
>  					write, 0, pages, NULL);
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);
> 
>  	return ret;
>  }
> Index: linux-2.6/mm/fremap.c
> ===================================================================
> --- linux-2.6.orig/mm/fremap.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/fremap.c	2009-11-05 13:02:41.000000000 -0600
> @@ -149,7 +149,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
>  #endif
> 
>  	/* We need down_write() to change vma->vm_flags. */
> -	down_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
>   retry:
>  	vma = find_vma(mm, start);
> 
> @@ -180,8 +180,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
>  		}
> 
>  		if (!has_write_lock) {
> -			up_read(&mm->mmap_sem);
> -			down_write(&mm->mmap_sem);
> +			mm_reader_unlock(mm);
> +			mm_writer_lock(mm);
>  			has_write_lock = 1;
>  			goto retry;
>  		}
> @@ -237,7 +237,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
>  			mlock_vma_pages_range(vma, start, start + size);
>  		} else {
>  			if (unlikely(has_write_lock)) {
> -				downgrade_write(&mm->mmap_sem);
> +				mm_writer_to_reader_lock(mm);
>  				has_write_lock = 0;
>  			}
>  			make_pages_present(start, start+size);
> @@ -252,9 +252,9 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
> 
>  out:
>  	if (likely(!has_write_lock))
> -		up_read(&mm->mmap_sem);
> +		mm_reader_unlock(mm);
>  	else
> -		up_write(&mm->mmap_sem);
> +		mm_writer_unlock(mm);
> 
>  	return err;
>  }
> Index: linux-2.6/mm/init-mm.c
> ===================================================================
> --- linux-2.6.orig/mm/init-mm.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/init-mm.c	2009-11-05 13:02:54.000000000 -0600
> @@ -15,7 +15,7 @@ struct mm_struct init_mm = {
>  	.pgd		= swapper_pg_dir,
>  	.mm_users	= ATOMIC_INIT(2),
>  	.mm_count	= ATOMIC_INIT(1),
> -	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
> +	.sem		= __RWSEM_INITIALIZER(init_mm.sem),
>  	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
>  	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
>  	.cpu_vm_mask	= CPU_MASK_ALL,
> Index: linux-2.6/arch/x86/kernel/sys_x86_64.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/kernel/sys_x86_64.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/arch/x86/kernel/sys_x86_64.c	2009-11-05 13:02:41.000000000 -0600
> @@ -37,9 +37,9 @@ SYSCALL_DEFINE6(mmap, unsigned long, add
>  		if (!file)
>  			goto out;
>  	}
> -	down_write(&current->mm->mmap_sem);
> +	mm_writer_lock(current->mm);
>  	error = do_mmap_pgoff(file, addr, len, prot, flags, off >> PAGE_SHIFT);
> -	up_write(&current->mm->mmap_sem);
> +	mm_writer_unlock(current->mm);
> 
>  	if (file)
>  		fput(file);
> Index: linux-2.6/arch/x86/mm/gup.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/mm/gup.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/arch/x86/mm/gup.c	2009-11-05 13:02:41.000000000 -0600
> @@ -357,10 +357,10 @@ slow_irqon:
>  		start += nr << PAGE_SHIFT;
>  		pages += nr;
> 
> -		down_read(&mm->mmap_sem);
> +		mm_reader_lock(mm);
>  		ret = get_user_pages(current, mm, start,
>  			(end - start) >> PAGE_SHIFT, write, 0, pages, NULL);
> -		up_read(&mm->mmap_sem);
> +		mm_reader_unlock(mm);
> 
>  		/* Have to be a bit careful with return values */
>  		if (nr > 0) {
> Index: linux-2.6/arch/x86/vdso/vma.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/vdso/vma.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/arch/x86/vdso/vma.c	2009-11-05 13:02:41.000000000 -0600
> @@ -108,7 +108,7 @@ int arch_setup_additional_pages(struct l
>  	if (!vdso_enabled)
>  		return 0;
> 
> -	down_write(&mm->mmap_sem);
> +	mm_writer_lock(mm);
>  	addr = vdso_addr(mm->start_stack, vdso_size);
>  	addr = get_unmapped_area(NULL, addr, vdso_size, 0, 0);
>  	if (IS_ERR_VALUE(addr)) {
> @@ -129,7 +129,7 @@ int arch_setup_additional_pages(struct l
>  	}
> 
>  up_fail:
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
>  	return ret;
>  }
> 
> Index: linux-2.6/fs/exec.c
> ===================================================================
> --- linux-2.6.orig/fs/exec.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/fs/exec.c	2009-11-05 13:02:41.000000000 -0600
> @@ -234,7 +234,7 @@ static int __bprm_mm_init(struct linux_b
>  	if (!vma)
>  		return -ENOMEM;
> 
> -	down_write(&mm->mmap_sem);
> +	mm_writer_lock(mm);
>  	vma->vm_mm = mm;
> 
>  	/*
> @@ -252,11 +252,11 @@ static int __bprm_mm_init(struct linux_b
>  		goto err;
> 
>  	mm->stack_vm = mm->total_vm = 1;
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
>  	bprm->p = vma->vm_end - sizeof(void *);
>  	return 0;
>  err:
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
>  	bprm->vma = NULL;
>  	kmem_cache_free(vm_area_cachep, vma);
>  	return err;
> @@ -601,7 +601,7 @@ int setup_arg_pages(struct linux_binprm
>  		bprm->loader -= stack_shift;
>  	bprm->exec -= stack_shift;
> 
> -	down_write(&mm->mmap_sem);
> +	mm_writer_lock(mm);
>  	vm_flags = VM_STACK_FLAGS;
> 
>  	/*
> @@ -625,7 +625,7 @@ int setup_arg_pages(struct linux_binprm
>  	if (stack_shift) {
>  		ret = shift_arg_pages(vma, stack_shift);
>  		if (ret) {
> -			up_write(&mm->mmap_sem);
> +			mm_writer_lock(mm);
Here we use mm_writer_unlock.


>  			return ret;
>  		}
>  	}
> @@ -640,7 +640,7 @@ int setup_arg_pages(struct linux_binprm
>  		ret = -EFAULT;
> 
>  out_unlock:
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
>  	return 0;
>  }
>  EXPORT_SYMBOL(setup_arg_pages);
> @@ -714,9 +714,9 @@ static int exec_mmap(struct mm_struct *m
>  		 * through with the exec.  We must hold mmap_sem around
>  		 * checking core_state and changing tsk->mm.
>  		 */
> -		down_read(&old_mm->mmap_sem);
> +		mm_reader_lock(old_mm);
>  		if (unlikely(old_mm->core_state)) {
> -			up_read(&old_mm->mmap_sem);
> +			mm_reader_unlock(old_mm);
>  			return -EINTR;
>  		}
>  	}
> @@ -728,7 +728,7 @@ static int exec_mmap(struct mm_struct *m
>  	task_unlock(tsk);
>  	arch_pick_mmap_layout(mm);
>  	if (old_mm) {
> -		up_read(&old_mm->mmap_sem);
> +		mm_reader_lock(old_mm);
Here we need use mm_reader_unlock.


>  		BUG_ON(active_mm != old_mm);
>  		mm_update_next_owner(old_mm);
>  		mmput(old_mm);
> @@ -1637,7 +1637,7 @@ static int coredump_wait(int exit_code,
>  	core_state->dumper.task = tsk;
>  	core_state->dumper.next = NULL;
>  	core_waiters = zap_threads(tsk, mm, core_state, exit_code);
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
> 
>  	if (unlikely(core_waiters < 0))
>  		goto fail;
> @@ -1782,12 +1782,12 @@ void do_coredump(long signr, int exit_co
>  		goto fail;
>  	}
> 
> -	down_write(&mm->mmap_sem);
> +	mm_writer_lock(mm);
>  	/*
>  	 * If another thread got here first, or we are not dumpable, bail out.
>  	 */
>  	if (mm->core_state || !get_dumpable(mm)) {
> -		up_write(&mm->mmap_sem);
> +		mm_writer_unlock(mm);
>  		put_cred(cred);
>  		goto fail;
>  	}
> Index: linux-2.6/ipc/shm.c
> ===================================================================
> --- linux-2.6.orig/ipc/shm.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/ipc/shm.c	2009-11-05 13:02:41.000000000 -0600
> @@ -901,7 +901,7 @@ long do_shmat(int shmid, char __user *sh
>  	sfd->file = shp->shm_file;
>  	sfd->vm_ops = NULL;
> 
> -	down_write(&current->mm->mmap_sem);
> +	mm_writer_lock(current->mm);
>  	if (addr && !(shmflg & SHM_REMAP)) {
>  		err = -EINVAL;
>  		if (find_vma_intersection(current->mm, addr, addr + size))
> @@ -921,7 +921,7 @@ long do_shmat(int shmid, char __user *sh
>  	if (IS_ERR_VALUE(user_addr))
>  		err = (long)user_addr;
>  invalid:
> -	up_write(&current->mm->mmap_sem);
> +	mm_writer_unlock(current->mm);
> 
>  	fput(file);
> 
> @@ -981,7 +981,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, sh
>  	if (addr & ~PAGE_MASK)
>  		return retval;
> 
> -	down_write(&mm->mmap_sem);
> +	mm_writer_lock(mm);
> 
>  	/*
>  	 * This function tries to be smart and unmap shm segments that
> @@ -1061,7 +1061,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, sh
> 
>  #endif
> 
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
>  	return retval;
>  }
> 
> Index: linux-2.6/kernel/exit.c
> ===================================================================
> --- linux-2.6.orig/kernel/exit.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/kernel/exit.c	2009-11-05 13:02:41.000000000 -0600
> @@ -655,11 +655,11 @@ static void exit_mm(struct task_struct *
>  	 * will increment ->nr_threads for each thread in the
>  	 * group with ->mm != NULL.
>  	 */
> -	down_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
>  	core_state = mm->core_state;
>  	if (core_state) {
>  		struct core_thread self;
> -		up_read(&mm->mmap_sem);
> +		mm_reader_unlock(mm);
> 
>  		self.task = tsk;
>  		self.next = xchg(&core_state->dumper.next, &self);
> @@ -677,14 +677,14 @@ static void exit_mm(struct task_struct *
>  			schedule();
>  		}
>  		__set_task_state(tsk, TASK_RUNNING);
> -		down_read(&mm->mmap_sem);
> +		mm_reader_lock(mm);
>  	}
>  	atomic_inc(&mm->mm_count);
>  	BUG_ON(mm != tsk->active_mm);
>  	/* more a memory barrier than a real lock */
>  	task_lock(tsk);
>  	tsk->mm = NULL;
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);
>  	enter_lazy_tlb(mm, current);
>  	/* We don't want this task to be frozen prematurely */
>  	clear_freeze_flag(tsk);
> Index: linux-2.6/kernel/fork.c
> ===================================================================
> --- linux-2.6.orig/kernel/fork.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/kernel/fork.c	2009-11-05 13:02:41.000000000 -0600
> @@ -283,12 +283,12 @@ static int dup_mmap(struct mm_struct *mm
>  	unsigned long charge;
>  	struct mempolicy *pol;
> 
> -	down_write(&oldmm->mmap_sem);
> +	mm_writer_lock(oldmm);
>  	flush_cache_dup_mm(oldmm);
>  	/*
>  	 * Not linked in yet - no deadlock potential:
>  	 */
> -	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
> +	mm_writer_lock_nested(mm, SINGLE_DEPTH_NESTING);
> 
>  	mm->locked_vm = 0;
>  	mm->mmap = NULL;
> @@ -385,9 +385,9 @@ static int dup_mmap(struct mm_struct *mm
>  	arch_dup_mmap(oldmm, mm);
>  	retval = 0;
>  out:
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
>  	flush_tlb_mm(oldmm);
> -	up_write(&oldmm->mmap_sem);
> +	mm_writer_unlock(oldmm);
>  	return retval;
>  fail_nomem_policy:
>  	kmem_cache_free(vm_area_cachep, tmp);
> @@ -446,7 +446,7 @@ static struct mm_struct * mm_init(struct
>  {
>  	atomic_set(&mm->mm_users, 1);
>  	atomic_set(&mm->mm_count, 1);
> -	init_rwsem(&mm->mmap_sem);
> +	mm_lock_init(mm);
>  	INIT_LIST_HEAD(&mm->mmlist);
>  	mm->flags = (current->mm) ?
>  		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
> Index: linux-2.6/mm/madvise.c
> ===================================================================
> --- linux-2.6.orig/mm/madvise.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/madvise.c	2009-11-05 13:02:41.000000000 -0600
> @@ -212,9 +212,9 @@ static long madvise_remove(struct vm_are
>  			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> 
>  	/* vmtruncate_range needs to take i_mutex and i_alloc_sem */
> -	up_read(&current->mm->mmap_sem);
> +	mm_reader_unlock(current->mm);
>  	error = vmtruncate_range(mapping->host, offset, endoff);
> -	down_read(&current->mm->mmap_sem);
> +	mm_reader_lock(current->mm);
>  	return error;
>  }
> 
> @@ -343,9 +343,9 @@ SYSCALL_DEFINE3(madvise, unsigned long,
> 
>  	write = madvise_need_mmap_write(behavior);
>  	if (write)
> -		down_write(&current->mm->mmap_sem);
> +		mm_writer_lock(current->mm);
>  	else
> -		down_read(&current->mm->mmap_sem);
> +		mm_reader_lock(current->mm);
> 
>  	if (start & ~PAGE_MASK)
>  		goto out;
> @@ -408,9 +408,9 @@ SYSCALL_DEFINE3(madvise, unsigned long,
>  	}
>  out:
>  	if (write)
> -		up_write(&current->mm->mmap_sem);
> +		mm_writer_unlock(current->mm);
>  	else
> -		up_read(&current->mm->mmap_sem);
> +		mm_writer_unlock(current->mm);
> 
>  	return error;
>  }
> Index: linux-2.6/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.orig/mm/mempolicy.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/mempolicy.c	2009-11-05 13:02:41.000000000 -0600
> @@ -363,10 +363,10 @@ void mpol_rebind_mm(struct mm_struct *mm
>  {
>  	struct vm_area_struct *vma;
> 
> -	down_write(&mm->mmap_sem);
> +	mm_writer_lock(mm);
>  	for (vma = mm->mmap; vma; vma = vma->vm_next)
>  		mpol_rebind_policy(vma->vm_policy, new);
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
>  }
> 
>  static const struct mempolicy_operations mpol_ops[MPOL_MAX] = {
> @@ -642,13 +642,13 @@ static long do_set_mempolicy(unsigned sh
>  	 * with no 'mm'.
>  	 */
>  	if (mm)
> -		down_write(&mm->mmap_sem);
> +		mm_writer_lock(mm);
>  	task_lock(current);
>  	ret = mpol_set_nodemask(new, nodes, scratch);
>  	if (ret) {
>  		task_unlock(current);
>  		if (mm)
> -			up_write(&mm->mmap_sem);
> +			mm_writer_unlock(mm);
>  		mpol_put(new);
>  		goto out;
>  	}
> @@ -660,7 +660,7 @@ static long do_set_mempolicy(unsigned sh
>  		current->il_next = first_node(new->v.nodes);
>  	task_unlock(current);
>  	if (mm)
> -		up_write(&mm->mmap_sem);
> +		mm_writer_unlock(mm);
> 
>  	mpol_put(old);
>  	ret = 0;
> @@ -738,10 +738,10 @@ static long do_get_mempolicy(int *policy
>  		 * vma/shared policy at addr is NULL.  We
>  		 * want to return MPOL_DEFAULT in this case.
>  		 */
> -		down_read(&mm->mmap_sem);
> +		mm_reader_lock(mm);
>  		vma = find_vma_intersection(mm, addr, addr+1);
>  		if (!vma) {
> -			up_read(&mm->mmap_sem);
> +			mm_reader_unlock(mm);
>  			return -EFAULT;
>  		}
>  		if (vma->vm_ops && vma->vm_ops->get_policy)
> @@ -778,7 +778,7 @@ static long do_get_mempolicy(int *policy
>  	}
> 
>  	if (vma) {
> -		up_read(&current->mm->mmap_sem);
> +		mm_reader_unlock(current->mm);
>  		vma = NULL;
>  	}
> 
> @@ -792,7 +792,7 @@ static long do_get_mempolicy(int *policy
>   out:
>  	mpol_cond_put(pol);
>  	if (vma)
> -		up_read(&current->mm->mmap_sem);
> +		mm_reader_unlock(current->mm);
>  	return err;
>  }
> 
> @@ -858,7 +858,7 @@ int do_migrate_pages(struct mm_struct *m
>  	if (err)
>  		return err;
> 
> -	down_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
> 
>  	err = migrate_vmas(mm, from_nodes, to_nodes, flags);
>  	if (err)
> @@ -924,7 +924,7 @@ int do_migrate_pages(struct mm_struct *m
>  			break;
>  	}
>  out:
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);
>  	if (err < 0)
>  		return err;
>  	return busy;
> @@ -1029,12 +1029,12 @@ static long do_mbind(unsigned long start
>  	{
>  		NODEMASK_SCRATCH(scratch);
>  		if (scratch) {
> -			down_write(&mm->mmap_sem);
> +			mm_writer_lock(mm);
>  			task_lock(current);
>  			err = mpol_set_nodemask(new, nmask, scratch);
>  			task_unlock(current);
>  			if (err)
> -				up_write(&mm->mmap_sem);
> +				mm_writer_unlock(mm);
>  		} else
>  			err = -ENOMEM;
>  		NODEMASK_SCRATCH_FREE(scratch);
> @@ -1060,7 +1060,7 @@ static long do_mbind(unsigned long start
>  	} else
>  		putback_lru_pages(&pagelist);
> 
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
>   mpol_out:
>  	mpol_put(new);
>  	return err;
> Index: linux-2.6/mm/mincore.c
> ===================================================================
> --- linux-2.6.orig/mm/mincore.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/mincore.c	2009-11-05 13:02:41.000000000 -0600
> @@ -209,9 +209,9 @@ SYSCALL_DEFINE3(mincore, unsigned long,
>  		 * Do at most PAGE_SIZE entries per iteration, due to
>  		 * the temporary buffer size.
>  		 */
> -		down_read(&current->mm->mmap_sem);
> +		mm_reader_lock(current->mm);
>  		retval = do_mincore(start, tmp, min(pages, PAGE_SIZE));
> -		up_read(&current->mm->mmap_sem);
> +		mm_reader_unlock(current->mm);
> 
>  		if (retval <= 0)
>  			break;
> Index: linux-2.6/mm/mlock.c
> ===================================================================
> --- linux-2.6.orig/mm/mlock.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/mm/mlock.c	2009-11-05 13:02:41.000000000 -0600
> @@ -164,7 +164,7 @@ static long __mlock_vma_pages_range(stru
>  	VM_BUG_ON(end   & ~PAGE_MASK);
>  	VM_BUG_ON(start < vma->vm_start);
>  	VM_BUG_ON(end   > vma->vm_end);
> -	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
> +	VM_BUG_ON(!mm_locked(mm));
> 
>  	gup_flags = FOLL_TOUCH | FOLL_GET;
>  	if (vma->vm_flags & VM_WRITE)
> @@ -483,7 +483,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, st
> 
>  	lru_add_drain_all();	/* flush pagevec */
> 
> -	down_write(&current->mm->mmap_sem);
> +	mm_writer_lock(current->mm);
>  	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
>  	start &= PAGE_MASK;
> 
> @@ -496,7 +496,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, st
>  	/* check against resource limits */
>  	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
>  		error = do_mlock(start, len, 1);
> -	up_write(&current->mm->mmap_sem);
> +	mm_writer_unlock(current->mm);
>  	return error;
>  }
> 
> @@ -504,11 +504,11 @@ SYSCALL_DEFINE2(munlock, unsigned long,
>  {
>  	int ret;
> 
> -	down_write(&current->mm->mmap_sem);
> +	mm_writer_lock(current->mm);
>  	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
>  	start &= PAGE_MASK;
>  	ret = do_mlock(start, len, 0);
> -	up_write(&current->mm->mmap_sem);
> +	mm_writer_unlock(current->mm);
>  	return ret;
>  }
> 
> @@ -551,7 +551,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
> 
>  	lru_add_drain_all();	/* flush pagevec */
> 
> -	down_write(&current->mm->mmap_sem);
> +	mm_writer_lock(current->mm);
> 
>  	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
>  	lock_limit >>= PAGE_SHIFT;
> @@ -560,7 +560,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
>  	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
>  	    capable(CAP_IPC_LOCK))
>  		ret = do_mlockall(flags);
> -	up_write(&current->mm->mmap_sem);
> +	mm_writer_unlock(current->mm);
>  out:
>  	return ret;
>  }
> @@ -569,9 +569,9 @@ SYSCALL_DEFINE0(munlockall)
>  {
>  	int ret;
> 
> -	down_write(&current->mm->mmap_sem);
> +	mm_writer_lock(current->mm);
>  	ret = do_mlockall(0);
> -	up_write(&current->mm->mmap_sem);
> +	mm_writer_unlock(current->mm);
>  	return ret;
>  }
> 
> @@ -619,7 +619,7 @@ int account_locked_memory(struct mm_stru
> 
>  	pgsz = PAGE_ALIGN(size) >> PAGE_SHIFT;
> 
> -	down_write(&mm->mmap_sem);
> +	mm_writer_lock(mm);
> 
>  	lim = rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT;
>  	vm   = mm->total_vm + pgsz;
> @@ -636,7 +636,7 @@ int account_locked_memory(struct mm_stru
> 
>  	error = 0;
>   out:
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
>  	return error;
>  }
> 
> @@ -644,10 +644,10 @@ void refund_locked_memory(struct mm_stru
>  {
>  	unsigned long pgsz = PAGE_ALIGN(size) >> PAGE_SHIFT;
> 
> -	down_write(&mm->mmap_sem);
> +	mm_writer_lock(mm);
> 
>  	mm->total_vm  -= pgsz;
>  	mm->locked_vm -= pgsz;
> 
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
>  }
> Index: linux-2.6/drivers/infiniband/core/umem.c
> ===================================================================
> --- linux-2.6.orig/drivers/infiniband/core/umem.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/drivers/infiniband/core/umem.c	2009-11-05 13:02:41.000000000 -0600
> @@ -133,7 +133,7 @@ struct ib_umem *ib_umem_get(struct ib_uc
> 
>  	npages = PAGE_ALIGN(size + umem->offset) >> PAGE_SHIFT;
> 
> -	down_write(&current->mm->mmap_sem);
> +	mm_writer_lock(current->mm);
> 
>  	locked     = npages + current->mm->locked_vm;
>  	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur >> PAGE_SHIFT;
> @@ -207,7 +207,7 @@ out:
>  	} else
>  		current->mm->locked_vm = locked;
> 
> -	up_write(&current->mm->mmap_sem);
> +	mm_writer_unlock(current->mm);
>  	if (vma_list)
>  		free_page((unsigned long) vma_list);
>  	free_page((unsigned long) page_list);
> @@ -220,9 +220,9 @@ static void ib_umem_account(struct work_
>  {
>  	struct ib_umem *umem = container_of(work, struct ib_umem, work);
> 
> -	down_write(&umem->mm->mmap_sem);
> +	mm_writer_lock(umem->mm);
>  	umem->mm->locked_vm -= umem->diff;
> -	up_write(&umem->mm->mmap_sem);
> +	mm_writer_lock(umem->mm);
>  	mmput(umem->mm);
>  	kfree(umem);
>  }
> @@ -256,7 +256,7 @@ void ib_umem_release(struct ib_umem *ume
>  	 * we defer the vm_locked accounting to the system workqueue.
>  	 */
>  	if (context->closing) {
> -		if (!down_write_trylock(&mm->mmap_sem)) {
> +		if (!mm_writer_trylock(mm)) {
>  			INIT_WORK(&umem->work, ib_umem_account);
>  			umem->mm   = mm;
>  			umem->diff = diff;
> @@ -265,10 +265,10 @@ void ib_umem_release(struct ib_umem *ume
>  			return;
>  		}
>  	} else
> -		down_write(&mm->mmap_sem);
> +		mm_writer_lock(mm);
> 
>  	current->mm->locked_vm -= diff;
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
>  	mmput(mm);
>  	kfree(umem);
>  }
> Index: linux-2.6/drivers/oprofile/buffer_sync.c
> ===================================================================
> --- linux-2.6.orig/drivers/oprofile/buffer_sync.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/drivers/oprofile/buffer_sync.c	2009-11-05 13:02:41.000000000 -0600
> @@ -87,11 +87,11 @@ munmap_notify(struct notifier_block *sel
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *mpnt;
> 
> -	down_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
> 
>  	mpnt = find_vma(mm, addr);
>  	if (mpnt && mpnt->vm_file && (mpnt->vm_flags & VM_EXEC)) {
> -		up_read(&mm->mmap_sem);
> +		mm_reader_unlock(mm);
>  		/* To avoid latency problems, we only process the current CPU,
>  		 * hoping that most samples for the task are on this CPU
>  		 */
> @@ -99,7 +99,7 @@ munmap_notify(struct notifier_block *sel
>  		return 0;
>  	}
> 
> -	up_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
Here we need use mm_reader_unlock.



>  	return 0;
>  }
> 
> @@ -410,7 +410,7 @@ static void release_mm(struct mm_struct
>  {
>  	if (!mm)
>  		return;
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);
>  	mmput(mm);
>  }
> 
> @@ -419,7 +419,7 @@ static struct mm_struct *take_tasks_mm(s
>  {
>  	struct mm_struct *mm = get_task_mm(task);
>  	if (mm)
> -		down_read(&mm->mmap_sem);
> +		mm_reader_unlock(mm);
Here we need use mm_reader_lock.



>  	return mm;
>  }
> 
> Index: linux-2.6/fs/aio.c
> ===================================================================
> --- linux-2.6.orig/fs/aio.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/fs/aio.c	2009-11-05 13:02:41.000000000 -0600
> @@ -89,9 +89,9 @@ static void aio_free_ring(struct kioctx
>  		put_page(info->ring_pages[i]);
> 
>  	if (info->mmap_size) {
> -		down_write(&ctx->mm->mmap_sem);
> +		mm_writer_lock(ctx->mm);
>  		do_munmap(ctx->mm, info->mmap_base, info->mmap_size);
> -		up_write(&ctx->mm->mmap_sem);
> +		mm_writer_unlock(ctx->mm);
>  	}
> 
>  	if (info->ring_pages && info->ring_pages != info->internal_pages)
> @@ -130,12 +130,12 @@ static int aio_setup_ring(struct kioctx
> 
>  	info->mmap_size = nr_pages * PAGE_SIZE;
>  	dprintk("attempting mmap of %lu bytes\n", info->mmap_size);
> -	down_write(&ctx->mm->mmap_sem);
> +	mm_writer_lock(ctx->mm);
>  	info->mmap_base = do_mmap(NULL, 0, info->mmap_size,
>  				  PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_PRIVATE,
>  				  0);
>  	if (IS_ERR((void *)info->mmap_base)) {
> -		up_write(&ctx->mm->mmap_sem);
> +		mm_writer_unlock(ctx->mm);
>  		info->mmap_size = 0;
>  		aio_free_ring(ctx);
>  		return -EAGAIN;
> @@ -145,7 +145,7 @@ static int aio_setup_ring(struct kioctx
>  	info->nr_pages = get_user_pages(current, ctx->mm,
>  					info->mmap_base, nr_pages,
>  					1, 0, info->ring_pages, NULL);
> -	up_write(&ctx->mm->mmap_sem);
> +	mm_writer_unlock(ctx->mm);
> 
>  	if (unlikely(info->nr_pages != nr_pages)) {
>  		aio_free_ring(ctx);
> Index: linux-2.6/fs/binfmt_elf.c
> ===================================================================
> --- linux-2.6.orig/fs/binfmt_elf.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/fs/binfmt_elf.c	2009-11-05 13:02:41.000000000 -0600
> @@ -81,9 +81,9 @@ static int set_brk(unsigned long start,
>  	end = ELF_PAGEALIGN(end);
>  	if (end > start) {
>  		unsigned long addr;
> -		down_write(&current->mm->mmap_sem);
> +		mm_writer_lock(current->mm);
>  		addr = do_brk(start, end - start);
> -		up_write(&current->mm->mmap_sem);
> +		mm_writer_unlock(current->mm);
>  		if (BAD_ADDR(addr))
>  			return addr;
>  	}
> @@ -332,7 +332,7 @@ static unsigned long elf_map(struct file
>  	if (!size)
>  		return addr;
> 
> -	down_write(&current->mm->mmap_sem);
> +	mm_writer_lock(current->mm);
>  	/*
>  	* total_size is the size of the ELF (interpreter) image.
>  	* The _first_ mmap needs to know the full size, otherwise
> @@ -349,7 +349,7 @@ static unsigned long elf_map(struct file
>  	} else
>  		map_addr = do_mmap(filep, addr, size, prot, type, off);
> 
> -	up_write(&current->mm->mmap_sem);
> +	mm_writer_unlock(current->mm);
>  	return(map_addr);
>  }
> 
> @@ -517,9 +517,9 @@ static unsigned long load_elf_interp(str
>  		elf_bss = ELF_PAGESTART(elf_bss + ELF_MIN_ALIGN - 1);
> 
>  		/* Map the last of the bss segment */
> -		down_write(&current->mm->mmap_sem);
> +		mm_writer_lock(current->mm);
>  		error = do_brk(elf_bss, last_bss - elf_bss);
> -		up_write(&current->mm->mmap_sem);
> +		mm_writer_unlock(current->mm);
>  		if (BAD_ADDR(error))
>  			goto out_close;
>  	}
> @@ -978,10 +978,10 @@ static int load_elf_binary(struct linux_
>  		   and some applications "depend" upon this behavior.
>  		   Since we do not have the power to recompile these, we
>  		   emulate the SVr4 behavior. Sigh. */
> -		down_write(&current->mm->mmap_sem);
> +		mm_writer_lock(current->mm);
>  		error = do_mmap(NULL, 0, PAGE_SIZE, PROT_READ | PROT_EXEC,
>  				MAP_FIXED | MAP_PRIVATE, 0);
> -		up_write(&current->mm->mmap_sem);
> +		mm_writer_unlock(current->mm);
>  	}
> 
>  #ifdef ELF_PLAT_INIT
> @@ -1066,7 +1066,7 @@ static int load_elf_library(struct file
>  		eppnt++;
> 
>  	/* Now use mmap to map the library into memory. */
> -	down_write(&current->mm->mmap_sem);
> +	mm_writer_lock(current->mm);
>  	error = do_mmap(file,
>  			ELF_PAGESTART(eppnt->p_vaddr),
>  			(eppnt->p_filesz +
> @@ -1075,7 +1075,7 @@ static int load_elf_library(struct file
>  			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
>  			(eppnt->p_offset -
>  			 ELF_PAGEOFFSET(eppnt->p_vaddr)));
> -	up_write(&current->mm->mmap_sem);
> +	mm_writer_unlock(current->mm);
>  	if (error != ELF_PAGESTART(eppnt->p_vaddr))
>  		goto out_free_ph;
> 
> @@ -1089,9 +1089,9 @@ static int load_elf_library(struct file
>  			    ELF_MIN_ALIGN - 1);
>  	bss = eppnt->p_memsz + eppnt->p_vaddr;
>  	if (bss > len) {
> -		down_write(&current->mm->mmap_sem);
> +		mm_writer_lock(current->mm);
>  		do_brk(len, bss - len);
> -		up_write(&current->mm->mmap_sem);
> +		mm_writer_unlock(current->mm);
>  	}
>  	error = 0;
> 
> Index: linux-2.6/fs/nfs/direct.c
> ===================================================================
> --- linux-2.6.orig/fs/nfs/direct.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/fs/nfs/direct.c	2009-11-05 13:02:41.000000000 -0600
> @@ -309,10 +309,10 @@ static ssize_t nfs_direct_read_schedule_
>  		if (unlikely(!data))
>  			break;
> 
> -		down_read(&current->mm->mmap_sem);
> +		mm_reader_lock(current->mm);
>  		result = get_user_pages(current, current->mm, user_addr,
>  					data->npages, 1, 0, data->pagevec, NULL);
> -		up_read(&current->mm->mmap_sem);
> +		mm_reader_unlock(current->mm);
>  		if (result < 0) {
>  			nfs_readdata_free(data);
>  			break;
> @@ -730,10 +730,10 @@ static ssize_t nfs_direct_write_schedule
>  		if (unlikely(!data))
>  			break;
> 
> -		down_read(&current->mm->mmap_sem);
> +		mm_reader_lock(current->mm);
>  		result = get_user_pages(current, current->mm, user_addr,
>  					data->npages, 0, 0, data->pagevec, NULL);
> -		up_read(&current->mm->mmap_sem);
> +		mm_reader_unlock(current->mm);
>  		if (result < 0) {
>  			nfs_writedata_free(data);
>  			break;
> Index: linux-2.6/fs/proc/array.c
> ===================================================================
> --- linux-2.6.orig/fs/proc/array.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/fs/proc/array.c	2009-11-05 13:02:41.000000000 -0600
> @@ -394,13 +394,13 @@ static inline void task_show_stack_usage
>  	struct mm_struct	*mm = get_task_mm(task);
> 
>  	if (mm) {
> -		down_read(&mm->mmap_sem);
> +		mm_reader_lock(mm);
>  		vma = find_vma(mm, task->stack_start);
>  		if (vma)
>  			seq_printf(m, "Stack usage:\t%lu kB\n",
>  				get_stack_usage_in_bytes(vma, task) >> 10);
> 
> -		up_read(&mm->mmap_sem);
> +		mm_reader_unlock(mm);
>  		mmput(mm);
>  	}
>  }
> Index: linux-2.6/fs/proc/base.c
> ===================================================================
> --- linux-2.6.orig/fs/proc/base.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/fs/proc/base.c	2009-11-05 13:02:41.000000000 -0600
> @@ -1301,11 +1301,11 @@ struct file *get_mm_exe_file(struct mm_s
> 
>  	/* We need mmap_sem to protect against races with removal of
>  	 * VM_EXECUTABLE vmas */
> -	down_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
>  	exe_file = mm->exe_file;
>  	if (exe_file)
>  		get_file(exe_file);
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);
>  	return exe_file;
>  }
> 
> Index: linux-2.6/fs/proc/task_mmu.c
> ===================================================================
> --- linux-2.6.orig/fs/proc/task_mmu.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/fs/proc/task_mmu.c	2009-11-05 13:02:41.000000000 -0600
> @@ -95,7 +95,7 @@ static void vma_stop(struct proc_maps_pr
>  {
>  	if (vma && vma != priv->tail_vma) {
>  		struct mm_struct *mm = vma->vm_mm;
> -		up_read(&mm->mmap_sem);
> +		mm_reader_unlock(mm);
>  		mmput(mm);
>  	}
>  }
> @@ -129,7 +129,7 @@ static void *m_start(struct seq_file *m,
>  	mm = mm_for_maps(priv->task);
>  	if (!mm)
>  		return NULL;
> -	down_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
> 
>  	tail_vma = get_gate_vma(priv->task);
>  	priv->tail_vma = tail_vma;
> @@ -162,7 +162,7 @@ out:
> 
>  	/* End of vmas has been reached */
>  	m->version = (tail_vma != NULL)? 0: -1UL;
> -	up_read(&mm->mmap_sem);
> +	mm_reader_lock(mm);
>  	mmput(mm);
>  	return tail_vma;
>  }
> @@ -525,7 +525,7 @@ static ssize_t clear_refs_write(struct f
>  			.pmd_entry = clear_refs_pte_range,
>  			.mm = mm,
>  		};
> -		down_read(&mm->mmap_sem);
> +		mm_reader_lock(mm);
>  		for (vma = mm->mmap; vma; vma = vma->vm_next) {
>  			clear_refs_walk.private = vma;
>  			if (is_vm_hugetlb_page(vma))
> @@ -547,7 +547,7 @@ static ssize_t clear_refs_write(struct f
>  					&clear_refs_walk);
>  		}
>  		flush_tlb_mm(mm);
> -		up_read(&mm->mmap_sem);
> +		mm_reader_unlock(mm);
>  		mmput(mm);
>  	}
>  	put_task_struct(task);
> @@ -733,10 +733,10 @@ static ssize_t pagemap_read(struct file
>  	if (!pages)
>  		goto out_mm;
> 
> -	down_read(&current->mm->mmap_sem);
> +	mm_reader_lock(current->mm);
>  	ret = get_user_pages(current, current->mm, uaddr, pagecount,
>  			     1, 0, pages, NULL);
> -	up_read(&current->mm->mmap_sem);
> +	mm_reader_unlock(current->mm);
> 
>  	if (ret < 0)
>  		goto out_free;
> Index: linux-2.6/kernel/trace/trace_output.c
> ===================================================================
> --- linux-2.6.orig/kernel/trace/trace_output.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/kernel/trace/trace_output.c	2009-11-05 13:02:41.000000000 -0600
> @@ -376,7 +376,7 @@ int seq_print_user_ip(struct trace_seq *
>  	if (mm) {
>  		const struct vm_area_struct *vma;
> 
> -		down_read(&mm->mmap_sem);
> +		mm_reader_lock(mm);
>  		vma = find_vma(mm, ip);
>  		if (vma) {
>  			file = vma->vm_file;
> @@ -388,7 +388,7 @@ int seq_print_user_ip(struct trace_seq *
>  				ret = trace_seq_printf(s, "[+0x%lx]",
>  						       ip - vmstart);
>  		}
> -		up_read(&mm->mmap_sem);
> +		mm_reader_unlock(mm);
>  	}
>  	if (ret && ((sym_flags & TRACE_ITER_SYM_ADDR) || !file))
>  		ret = trace_seq_printf(s, " <" IP_FMT ">", ip);
> Index: linux-2.6/arch/x86/kernel/sys_i386_32.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/kernel/sys_i386_32.c	2009-11-05 13:02:34.000000000 -0600
> +++ linux-2.6/arch/x86/kernel/sys_i386_32.c	2009-11-05 13:02:48.000000000 -0600
> @@ -39,9 +39,9 @@ asmlinkage long sys_mmap2(unsigned long
>  			goto out;
>  	}
> 
> -	down_write(&mm->mmap_sem);
> +	mm_writer_lock(mm);
>  	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
> 
>  	if (file)
>  		fput(file);
> Index: linux-2.6/arch/x86/vdso/vdso32-setup.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/vdso/vdso32-setup.c	2009-11-05 13:02:34.000000000 -0600
> +++ linux-2.6/arch/x86/vdso/vdso32-setup.c	2009-11-05 13:02:48.000000000 -0600
> @@ -320,7 +320,7 @@ int arch_setup_additional_pages(struct l
>  	if (vdso_enabled == VDSO_DISABLED)
>  		return 0;
> 
> -	down_write(&mm->mmap_sem);
> +	mm_writer_lock(mm);
> 
>  	/* Test compat mode once here, in case someone
>  	   changes it via sysctl */
> @@ -367,7 +367,7 @@ int arch_setup_additional_pages(struct l
>  	if (ret)
>  		current->mm->context.vdso = NULL;
> 
> -	up_write(&mm->mmap_sem);
> +	mm_writer_unlock(mm);
> 
>  	return ret;
>  }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
