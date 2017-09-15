Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A82946B0253
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 03:07:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e199so2989348pfh.3
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 00:07:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p20si195349pgd.651.2017.09.15.00.07.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 00:07:36 -0700 (PDT)
Date: Fri, 15 Sep 2017 09:07:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + include-linux-sched-mmh-uninline-mmdrop_async-etc.patch added
 to -mm tree
Message-ID: <20170915070731.y5ddmgtzvjz5aot3@dhcp22.suse.cz>
References: <59bae45a.Fmr8uSXzjRP94/2V%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59bae45a.Fmr8uSXzjRP94/2V%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mingo@kernel.org, oleg@redhat.com, peterz@infradead.org, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Thu 14-09-17 13:19:38, Andrew Morton wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: include/linux/sched/mm.h: uninline mmdrop_async(), etc
> 
> mmdrop_async() is only used in fork.c.  Move that and its support
> functions into fork.c, uninline it all.

Is this really an improvement? Why do we want to discourage more code
paths to use mmdrop_async? It sounds like a useful api and it has been
removed only because it lost its own user in oom code. Now that we have
a user I would just keep it where it was before.

> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/linux/sched/mm.h |   24 -
>  kernel/fork.c            |  455 +++++++++++++++++++------------------
>  2 files changed, 241 insertions(+), 238 deletions(-)
> 
> diff -puN include/linux/sched/mm.h~include-linux-sched-mmh-uninline-mmdrop_async-etc include/linux/sched/mm.h
> --- a/include/linux/sched/mm.h~include-linux-sched-mmh-uninline-mmdrop_async-etc
> +++ a/include/linux/sched/mm.h
> @@ -10,7 +10,7 @@
>  /*
>   * Routines for handling mm_structs
>   */
> -extern struct mm_struct * mm_alloc(void);
> +extern struct mm_struct *mm_alloc(void);
>  
>  /**
>   * mmgrab() - Pin a &struct mm_struct.
> @@ -34,27 +34,7 @@ static inline void mmgrab(struct mm_stru
>  	atomic_inc(&mm->mm_count);
>  }
>  
> -/* mmdrop drops the mm and the page tables */
> -extern void __mmdrop(struct mm_struct *);
> -static inline void mmdrop(struct mm_struct *mm)
> -{
> -	if (unlikely(atomic_dec_and_test(&mm->mm_count)))
> -		__mmdrop(mm);
> -}
> -
> -static inline void mmdrop_async_fn(struct work_struct *work)
> -{
> -	struct mm_struct *mm = container_of(work, struct mm_struct, async_put_work);
> -	__mmdrop(mm);
> -}
> -
> -static inline void mmdrop_async(struct mm_struct *mm)
> -{
> -	if (unlikely(atomic_dec_and_test(&mm->mm_count))) {
> -		INIT_WORK(&mm->async_put_work, mmdrop_async_fn);
> -		schedule_work(&mm->async_put_work);
> -	}
> -}
> +extern void mmdrop(struct mm_struct *mm);
>  
>  /**
>   * mmget() - Pin the address space associated with a &struct mm_struct.
> diff -puN kernel/fork.c~include-linux-sched-mmh-uninline-mmdrop_async-etc kernel/fork.c
> --- a/kernel/fork.c~include-linux-sched-mmh-uninline-mmdrop_async-etc
> +++ a/kernel/fork.c
> @@ -77,6 +77,7 @@
>  #include <linux/blkdev.h>
>  #include <linux/fs_struct.h>
>  #include <linux/magic.h>
> +#include <linux/sched/mm.h>
>  #include <linux/perf_event.h>
>  #include <linux/posix-timers.h>
>  #include <linux/user-return-notifier.h>
> @@ -386,6 +387,244 @@ void free_task(struct task_struct *tsk)
>  }
>  EXPORT_SYMBOL(free_task);
>  
> +#ifdef CONFIG_MMU
> +static __latent_entropy int dup_mmap(struct mm_struct *mm,
> +					struct mm_struct *oldmm)
> +{
> +	struct vm_area_struct *mpnt, *tmp, *prev, **pprev;
> +	struct rb_node **rb_link, *rb_parent;
> +	int retval;
> +	unsigned long charge;
> +	LIST_HEAD(uf);
> +
> +	uprobe_start_dup_mmap();
> +	if (down_write_killable(&oldmm->mmap_sem)) {
> +		retval = -EINTR;
> +		goto fail_uprobe_end;
> +	}
> +	flush_cache_dup_mm(oldmm);
> +	uprobe_dup_mmap(oldmm, mm);
> +	/*
> +	 * Not linked in yet - no deadlock potential:
> +	 */
> +	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
> +
> +	/* No ordering required: file already has been exposed. */
> +	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
> +
> +	mm->total_vm = oldmm->total_vm;
> +	mm->data_vm = oldmm->data_vm;
> +	mm->exec_vm = oldmm->exec_vm;
> +	mm->stack_vm = oldmm->stack_vm;
> +
> +	rb_link = &mm->mm_rb.rb_node;
> +	rb_parent = NULL;
> +	pprev = &mm->mmap;
> +	retval = ksm_fork(mm, oldmm);
> +	if (retval)
> +		goto out;
> +	retval = khugepaged_fork(mm, oldmm);
> +	if (retval)
> +		goto out;
> +
> +	prev = NULL;
> +	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
> +		struct file *file;
> +
> +		if (mpnt->vm_flags & VM_DONTCOPY) {
> +			vm_stat_account(mm, mpnt->vm_flags, -vma_pages(mpnt));
> +			continue;
> +		}
> +		charge = 0;
> +		if (mpnt->vm_flags & VM_ACCOUNT) {
> +			unsigned long len = vma_pages(mpnt);
> +
> +			if (security_vm_enough_memory_mm(oldmm, len)) /* sic */
> +				goto fail_nomem;
> +			charge = len;
> +		}
> +		tmp = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
> +		if (!tmp)
> +			goto fail_nomem;
> +		*tmp = *mpnt;
> +		INIT_LIST_HEAD(&tmp->anon_vma_chain);
> +		retval = vma_dup_policy(mpnt, tmp);
> +		if (retval)
> +			goto fail_nomem_policy;
> +		tmp->vm_mm = mm;
> +		retval = dup_userfaultfd(tmp, &uf);
> +		if (retval)
> +			goto fail_nomem_anon_vma_fork;
> +		if (tmp->vm_flags & VM_WIPEONFORK) {
> +			/* VM_WIPEONFORK gets a clean slate in the child. */
> +			tmp->anon_vma = NULL;
> +			if (anon_vma_prepare(tmp))
> +				goto fail_nomem_anon_vma_fork;
> +		} else if (anon_vma_fork(tmp, mpnt))
> +			goto fail_nomem_anon_vma_fork;
> +		tmp->vm_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
> +		tmp->vm_next = tmp->vm_prev = NULL;
> +		file = tmp->vm_file;
> +		if (file) {
> +			struct inode *inode = file_inode(file);
> +			struct address_space *mapping = file->f_mapping;
> +
> +			get_file(file);
> +			if (tmp->vm_flags & VM_DENYWRITE)
> +				atomic_dec(&inode->i_writecount);
> +			i_mmap_lock_write(mapping);
> +			if (tmp->vm_flags & VM_SHARED)
> +				atomic_inc(&mapping->i_mmap_writable);
> +			flush_dcache_mmap_lock(mapping);
> +			/* insert tmp into the share list, just after mpnt */
> +			vma_interval_tree_insert_after(tmp, mpnt,
> +					&mapping->i_mmap);
> +			flush_dcache_mmap_unlock(mapping);
> +			i_mmap_unlock_write(mapping);
> +		}
> +
> +		/*
> +		 * Clear hugetlb-related page reserves for children. This only
> +		 * affects MAP_PRIVATE mappings. Faults generated by the child
> +		 * are not guaranteed to succeed, even if read-only
> +		 */
> +		if (is_vm_hugetlb_page(tmp))
> +			reset_vma_resv_huge_pages(tmp);
> +
> +		/*
> +		 * Link in the new vma and copy the page table entries.
> +		 */
> +		*pprev = tmp;
> +		pprev = &tmp->vm_next;
> +		tmp->vm_prev = prev;
> +		prev = tmp;
> +
> +		__vma_link_rb(mm, tmp, rb_link, rb_parent);
> +		rb_link = &tmp->vm_rb.rb_right;
> +		rb_parent = &tmp->vm_rb;
> +
> +		mm->map_count++;
> +		if (!(tmp->vm_flags & VM_WIPEONFORK))
> +			retval = copy_page_range(mm, oldmm, mpnt);
> +
> +		if (tmp->vm_ops && tmp->vm_ops->open)
> +			tmp->vm_ops->open(tmp);
> +
> +		if (retval)
> +			goto out;
> +	}
> +	/* a new mm has just been created */
> +	arch_dup_mmap(oldmm, mm);
> +	retval = 0;
> +out:
> +	up_write(&mm->mmap_sem);
> +	flush_tlb_mm(oldmm);
> +	up_write(&oldmm->mmap_sem);
> +	dup_userfaultfd_complete(&uf);
> +fail_uprobe_end:
> +	uprobe_end_dup_mmap();
> +	return retval;
> +fail_nomem_anon_vma_fork:
> +	mpol_put(vma_policy(tmp));
> +fail_nomem_policy:
> +	kmem_cache_free(vm_area_cachep, tmp);
> +fail_nomem:
> +	retval = -ENOMEM;
> +	vm_unacct_memory(charge);
> +	goto out;
> +}
> +
> +static inline int mm_alloc_pgd(struct mm_struct *mm)
> +{
> +	mm->pgd = pgd_alloc(mm);
> +	if (unlikely(!mm->pgd))
> +		return -ENOMEM;
> +	return 0;
> +}
> +
> +static inline void mm_free_pgd(struct mm_struct *mm)
> +{
> +	pgd_free(mm, mm->pgd);
> +}
> +#else
> +static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
> +{
> +	down_write(&oldmm->mmap_sem);
> +	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
> +	up_write(&oldmm->mmap_sem);
> +	return 0;
> +}
> +#define mm_alloc_pgd(mm)	(0)
> +#define mm_free_pgd(mm)
> +#endif /* CONFIG_MMU */
> +
> +static void check_mm(struct mm_struct *mm)
> +{
> +	int i;
> +
> +	for (i = 0; i < NR_MM_COUNTERS; i++) {
> +		long x = atomic_long_read(&mm->rss_stat.count[i]);
> +
> +		if (unlikely(x))
> +			printk(KERN_ALERT "BUG: Bad rss-counter state "
> +					  "mm:%p idx:%d val:%ld\n", mm, i, x);
> +	}
> +
> +	if (atomic_long_read(&mm->nr_ptes))
> +		pr_alert("BUG: non-zero nr_ptes on freeing mm: %ld\n",
> +				atomic_long_read(&mm->nr_ptes));
> +	if (mm_nr_pmds(mm))
> +		pr_alert("BUG: non-zero nr_pmds on freeing mm: %ld\n",
> +				mm_nr_pmds(mm));
> +
> +#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
> +	VM_BUG_ON_MM(mm->pmd_huge_pte, mm);
> +#endif
> +}
> +
> +#define allocate_mm()	(kmem_cache_alloc(mm_cachep, GFP_KERNEL))
> +#define free_mm(mm)	(kmem_cache_free(mm_cachep, (mm)))
> +
> +/*
> + * Called when the last reference to the mm
> + * is dropped: either by a lazy thread or by
> + * mmput. Free the page directory and the mm.
> + */
> +static void __mmdrop(struct mm_struct *mm)
> +{
> +	BUG_ON(mm == &init_mm);
> +	mm_free_pgd(mm);
> +	destroy_context(mm);
> +	hmm_mm_destroy(mm);
> +	mmu_notifier_mm_destroy(mm);
> +	check_mm(mm);
> +	put_user_ns(mm->user_ns);
> +	free_mm(mm);
> +}
> +
> +void mmdrop(struct mm_struct *mm)
> +{
> +	if (unlikely(atomic_dec_and_test(&mm->mm_count)))
> +		__mmdrop(mm);
> +}
> +EXPORT_SYMBOL_GPL(mmdrop);
> +
> +static void mmdrop_async_fn(struct work_struct *work)
> +{
> +	struct mm_struct *mm;
> +
> +	mm = container_of(work, struct mm_struct, async_put_work);
> +	__mmdrop(mm);
> +}
> +
> +static void mmdrop_async(struct mm_struct *mm)
> +{
> +	if (unlikely(atomic_dec_and_test(&mm->mm_count))) {
> +		INIT_WORK(&mm->async_put_work, mmdrop_async_fn);
> +		schedule_work(&mm->async_put_work);
> +	}
> +}
> +
>  static inline void free_signal_struct(struct signal_struct *sig)
>  {
>  	taskstats_tgid_free(sig);
> @@ -590,182 +829,8 @@ free_tsk:
>  	return NULL;
>  }
>  
> -#ifdef CONFIG_MMU
> -static __latent_entropy int dup_mmap(struct mm_struct *mm,
> -					struct mm_struct *oldmm)
> -{
> -	struct vm_area_struct *mpnt, *tmp, *prev, **pprev;
> -	struct rb_node **rb_link, *rb_parent;
> -	int retval;
> -	unsigned long charge;
> -	LIST_HEAD(uf);
> -
> -	uprobe_start_dup_mmap();
> -	if (down_write_killable(&oldmm->mmap_sem)) {
> -		retval = -EINTR;
> -		goto fail_uprobe_end;
> -	}
> -	flush_cache_dup_mm(oldmm);
> -	uprobe_dup_mmap(oldmm, mm);
> -	/*
> -	 * Not linked in yet - no deadlock potential:
> -	 */
> -	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
> -
> -	/* No ordering required: file already has been exposed. */
> -	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
> -
> -	mm->total_vm = oldmm->total_vm;
> -	mm->data_vm = oldmm->data_vm;
> -	mm->exec_vm = oldmm->exec_vm;
> -	mm->stack_vm = oldmm->stack_vm;
> -
> -	rb_link = &mm->mm_rb.rb_node;
> -	rb_parent = NULL;
> -	pprev = &mm->mmap;
> -	retval = ksm_fork(mm, oldmm);
> -	if (retval)
> -		goto out;
> -	retval = khugepaged_fork(mm, oldmm);
> -	if (retval)
> -		goto out;
> -
> -	prev = NULL;
> -	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
> -		struct file *file;
> -
> -		if (mpnt->vm_flags & VM_DONTCOPY) {
> -			vm_stat_account(mm, mpnt->vm_flags, -vma_pages(mpnt));
> -			continue;
> -		}
> -		charge = 0;
> -		if (mpnt->vm_flags & VM_ACCOUNT) {
> -			unsigned long len = vma_pages(mpnt);
> -
> -			if (security_vm_enough_memory_mm(oldmm, len)) /* sic */
> -				goto fail_nomem;
> -			charge = len;
> -		}
> -		tmp = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
> -		if (!tmp)
> -			goto fail_nomem;
> -		*tmp = *mpnt;
> -		INIT_LIST_HEAD(&tmp->anon_vma_chain);
> -		retval = vma_dup_policy(mpnt, tmp);
> -		if (retval)
> -			goto fail_nomem_policy;
> -		tmp->vm_mm = mm;
> -		retval = dup_userfaultfd(tmp, &uf);
> -		if (retval)
> -			goto fail_nomem_anon_vma_fork;
> -		if (tmp->vm_flags & VM_WIPEONFORK) {
> -			/* VM_WIPEONFORK gets a clean slate in the child. */
> -			tmp->anon_vma = NULL;
> -			if (anon_vma_prepare(tmp))
> -				goto fail_nomem_anon_vma_fork;
> -		} else if (anon_vma_fork(tmp, mpnt))
> -			goto fail_nomem_anon_vma_fork;
> -		tmp->vm_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
> -		tmp->vm_next = tmp->vm_prev = NULL;
> -		file = tmp->vm_file;
> -		if (file) {
> -			struct inode *inode = file_inode(file);
> -			struct address_space *mapping = file->f_mapping;
> -
> -			get_file(file);
> -			if (tmp->vm_flags & VM_DENYWRITE)
> -				atomic_dec(&inode->i_writecount);
> -			i_mmap_lock_write(mapping);
> -			if (tmp->vm_flags & VM_SHARED)
> -				atomic_inc(&mapping->i_mmap_writable);
> -			flush_dcache_mmap_lock(mapping);
> -			/* insert tmp into the share list, just after mpnt */
> -			vma_interval_tree_insert_after(tmp, mpnt,
> -					&mapping->i_mmap);
> -			flush_dcache_mmap_unlock(mapping);
> -			i_mmap_unlock_write(mapping);
> -		}
> -
> -		/*
> -		 * Clear hugetlb-related page reserves for children. This only
> -		 * affects MAP_PRIVATE mappings. Faults generated by the child
> -		 * are not guaranteed to succeed, even if read-only
> -		 */
> -		if (is_vm_hugetlb_page(tmp))
> -			reset_vma_resv_huge_pages(tmp);
> -
> -		/*
> -		 * Link in the new vma and copy the page table entries.
> -		 */
> -		*pprev = tmp;
> -		pprev = &tmp->vm_next;
> -		tmp->vm_prev = prev;
> -		prev = tmp;
> -
> -		__vma_link_rb(mm, tmp, rb_link, rb_parent);
> -		rb_link = &tmp->vm_rb.rb_right;
> -		rb_parent = &tmp->vm_rb;
> -
> -		mm->map_count++;
> -		if (!(tmp->vm_flags & VM_WIPEONFORK))
> -			retval = copy_page_range(mm, oldmm, mpnt);
> -
> -		if (tmp->vm_ops && tmp->vm_ops->open)
> -			tmp->vm_ops->open(tmp);
> -
> -		if (retval)
> -			goto out;
> -	}
> -	/* a new mm has just been created */
> -	arch_dup_mmap(oldmm, mm);
> -	retval = 0;
> -out:
> -	up_write(&mm->mmap_sem);
> -	flush_tlb_mm(oldmm);
> -	up_write(&oldmm->mmap_sem);
> -	dup_userfaultfd_complete(&uf);
> -fail_uprobe_end:
> -	uprobe_end_dup_mmap();
> -	return retval;
> -fail_nomem_anon_vma_fork:
> -	mpol_put(vma_policy(tmp));
> -fail_nomem_policy:
> -	kmem_cache_free(vm_area_cachep, tmp);
> -fail_nomem:
> -	retval = -ENOMEM;
> -	vm_unacct_memory(charge);
> -	goto out;
> -}
> -
> -static inline int mm_alloc_pgd(struct mm_struct *mm)
> -{
> -	mm->pgd = pgd_alloc(mm);
> -	if (unlikely(!mm->pgd))
> -		return -ENOMEM;
> -	return 0;
> -}
> -
> -static inline void mm_free_pgd(struct mm_struct *mm)
> -{
> -	pgd_free(mm, mm->pgd);
> -}
> -#else
> -static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
> -{
> -	down_write(&oldmm->mmap_sem);
> -	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
> -	up_write(&oldmm->mmap_sem);
> -	return 0;
> -}
> -#define mm_alloc_pgd(mm)	(0)
> -#define mm_free_pgd(mm)
> -#endif /* CONFIG_MMU */
> -
>  __cacheline_aligned_in_smp DEFINE_SPINLOCK(mmlist_lock);
>  
> -#define allocate_mm()	(kmem_cache_alloc(mm_cachep, GFP_KERNEL))
> -#define free_mm(mm)	(kmem_cache_free(mm_cachep, (mm)))
> -
>  static unsigned long default_dump_filter = MMF_DUMP_FILTER_DEFAULT;
>  
>  static int __init coredump_filter_setup(char *s)
> @@ -856,30 +921,6 @@ fail_nopgd:
>  	return NULL;
>  }
>  
> -static void check_mm(struct mm_struct *mm)
> -{
> -	int i;
> -
> -	for (i = 0; i < NR_MM_COUNTERS; i++) {
> -		long x = atomic_long_read(&mm->rss_stat.count[i]);
> -
> -		if (unlikely(x))
> -			printk(KERN_ALERT "BUG: Bad rss-counter state "
> -					  "mm:%p idx:%d val:%ld\n", mm, i, x);
> -	}
> -
> -	if (atomic_long_read(&mm->nr_ptes))
> -		pr_alert("BUG: non-zero nr_ptes on freeing mm: %ld\n",
> -				atomic_long_read(&mm->nr_ptes));
> -	if (mm_nr_pmds(mm))
> -		pr_alert("BUG: non-zero nr_pmds on freeing mm: %ld\n",
> -				mm_nr_pmds(mm));
> -
> -#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
> -	VM_BUG_ON_MM(mm->pmd_huge_pte, mm);
> -#endif
> -}
> -
>  /*
>   * Allocate and initialize an mm_struct.
>   */
> @@ -895,24 +936,6 @@ struct mm_struct *mm_alloc(void)
>  	return mm_init(mm, current, current_user_ns());
>  }
>  
> -/*
> - * Called when the last reference to the mm
> - * is dropped: either by a lazy thread or by
> - * mmput. Free the page directory and the mm.
> - */
> -void __mmdrop(struct mm_struct *mm)
> -{
> -	BUG_ON(mm == &init_mm);
> -	mm_free_pgd(mm);
> -	destroy_context(mm);
> -	hmm_mm_destroy(mm);
> -	mmu_notifier_mm_destroy(mm);
> -	check_mm(mm);
> -	put_user_ns(mm->user_ns);
> -	free_mm(mm);
> -}
> -EXPORT_SYMBOL_GPL(__mmdrop);
> -
>  static inline void __mmput(struct mm_struct *mm)
>  {
>  	VM_BUG_ON(atomic_read(&mm->mm_users));
> _
> 
> Patches currently in -mm which might be from akpm@linux-foundation.org are
> 
> i-need-old-gcc.patch
> drivers-media-cec-cec-adapc-fix-build-with-gcc-444.patch
> mm-oom_reaper-skip-mm-structs-with-mmu-notifiers-checkpatch-fixes.patch
> arm-arch-arm-include-asm-pageh-needs-personalityh.patch
> ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
> mm.patch
> include-linux-sched-mmh-uninline-mmdrop_async-etc.patch
> kernel-reboot-add-devm_register_reboot_notifier-fix.patch
> linux-next-git-rejects.patch
> kernel-forkc-export-kernel_thread-to-modules.patch
> slab-leaks3-default-y.patch
> 
> --
> To unsubscribe from this list: send the line "unsubscribe mm-commits" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
