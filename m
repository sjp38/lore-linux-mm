Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 24FCA6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:52:56 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id f51so2476113qge.8
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 11:52:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c36si3930300qgd.64.2014.06.19.11.52.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jun 2014 11:52:55 -0700 (PDT)
Date: Thu, 19 Jun 2014 20:15:43 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/3] fork/exec: cleanup mm initialization
Message-ID: <20140619181543.GA32548@redhat.com>
References: <fa98629155872c1b97ba4dcd00d509a1e467c1c3.1403168346.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa98629155872c1b97ba4dcd00d509a1e467c1c3.1403168346.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>, Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, rientjes@google.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/19, Vladimir Davydov wrote:
>
> mm initialization on fork/exec is spread all over the place, which makes
> the code look inconsistent.
>
> We have mm_init(), which is supposed to init/nullify mm's internals, but
> it doesn't init all the fields it should:
>
>  - on fork ->mmap,mm_rb,vmacache_seqnum,map_count,mm_cpumask,locked_vm
>    are zeroed in dup_mmap();
>
>  - on fork ->pmd_huge_pte is zeroed in dup_mm(), immediately before
>    calling mm_init();
>
>  - ->cpu_vm_mask_var ptr is initialized by mm_init_cpumask(), which is
>    called before mm_init() on both fork and exec;
>
>  - ->context is initialized by init_new_context(), which is called after
>    mm_init() on both fork and exec;
>
> Let's consolidate all the initializations in mm_init() to make the code
> look cleaner.

Yes, agreed. Afaics, the patch is fine (2 and 3 too).


This is off-topic, but why init_new_context() copies ldt even on exec?


> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
>  fs/exec.c                |    4 ----
>  include/linux/mm_types.h |    1 +
>  kernel/fork.c            |   47 ++++++++++++++++++++--------------------------
>  3 files changed, 21 insertions(+), 31 deletions(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index a3d33fe592d6..2ef2751f5a8d 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -368,10 +368,6 @@ static int bprm_mm_init(struct linux_binprm *bprm)
>  	if (!mm)
>  		goto err;
>  
> -	err = init_new_context(current, mm);
> -	if (err)
> -		goto err;
> -
>  	err = __bprm_mm_init(bprm);
>  	if (err)
>  		goto err;
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 96c5750e3110..21bff4be4379 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -461,6 +461,7 @@ static inline void mm_init_cpumask(struct mm_struct *mm)
>  #ifdef CONFIG_CPUMASK_OFFSTACK
>  	mm->cpu_vm_mask_var = &mm->cpumask_allocation;
>  #endif
> +	cpumask_clear(mm->cpu_vm_mask_var);
>  }
>  
>  /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
> diff --git a/kernel/fork.c b/kernel/fork.c
> index d2799d1fc952..01f0d0c56cb9 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -365,12 +365,6 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>  	 */
>  	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
>  
> -	mm->locked_vm = 0;
> -	mm->mmap = NULL;
> -	mm->vmacache_seqnum = 0;
> -	mm->map_count = 0;
> -	cpumask_clear(mm_cpumask(mm));
> -	mm->mm_rb = RB_ROOT;
>  	rb_link = &mm->mm_rb.rb_node;
>  	rb_parent = NULL;
>  	pprev = &mm->mmap;
> @@ -529,17 +523,27 @@ static void mm_init_aio(struct mm_struct *mm)
>  
>  static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
>  {
> +	mm->mmap = NULL;
> +	mm->mm_rb = RB_ROOT;
> +	mm->vmacache_seqnum = 0;
>  	atomic_set(&mm->mm_users, 1);
>  	atomic_set(&mm->mm_count, 1);
>  	init_rwsem(&mm->mmap_sem);
>  	INIT_LIST_HEAD(&mm->mmlist);
>  	mm->core_state = NULL;
>  	atomic_long_set(&mm->nr_ptes, 0);
> +	mm->map_count = 0;
> +	mm->locked_vm = 0;
>  	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
>  	spin_lock_init(&mm->page_table_lock);
> +	mm_init_cpumask(mm);
>  	mm_init_aio(mm);
>  	mm_init_owner(mm, p);
> +	mmu_notifier_mm_init(mm);
>  	clear_tlb_flush_pending(mm);
> +#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
> +	mm->pmd_huge_pte = NULL;
> +#endif
>  
>  	if (current->mm) {
>  		mm->flags = current->mm->flags & MMF_INIT_MASK;
> @@ -549,11 +553,17 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
>  		mm->def_flags = 0;
>  	}
>  
> -	if (likely(!mm_alloc_pgd(mm))) {
> -		mmu_notifier_mm_init(mm);
> -		return mm;
> -	}
> +	if (mm_alloc_pgd(mm))
> +		goto fail_nopgd;
> +
> +	if (init_new_context(p, mm))
> +		goto fail_nocontext;
>  
> +	return mm;
> +
> +fail_nocontext:
> +	mm_free_pgd(mm);
> +fail_nopgd:
>  	free_mm(mm);
>  	return NULL;
>  }
> @@ -587,7 +597,6 @@ struct mm_struct *mm_alloc(void)
>  		return NULL;
>  
>  	memset(mm, 0, sizeof(*mm));
> -	mm_init_cpumask(mm);
>  	return mm_init(mm, current);
>  }
>  
> @@ -819,17 +828,10 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
>  		goto fail_nomem;
>  
>  	memcpy(mm, oldmm, sizeof(*mm));
> -	mm_init_cpumask(mm);
>  
> -#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
> -	mm->pmd_huge_pte = NULL;
> -#endif
>  	if (!mm_init(mm, tsk))
>  		goto fail_nomem;
>  
> -	if (init_new_context(tsk, mm))
> -		goto fail_nocontext;
> -
>  	dup_mm_exe_file(oldmm, mm);
>  
>  	err = dup_mmap(mm, oldmm);
> @@ -851,15 +853,6 @@ free_pt:
>  
>  fail_nomem:
>  	return NULL;
> -
> -fail_nocontext:
> -	/*
> -	 * If init_new_context() failed, we cannot use mmput() to free the mm
> -	 * because it calls destroy_context()
> -	 */
> -	mm_free_pgd(mm);
> -	free_mm(mm);
> -	return NULL;
>  }
>  
>  static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
> -- 
> 1.7.10.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
