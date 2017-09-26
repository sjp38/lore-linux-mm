Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E95C6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:17:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y77so17708598pfd.2
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 03:17:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l3si5652667pld.337.2017.09.26.03.17.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 03:17:16 -0700 (PDT)
Date: Tue, 26 Sep 2017 12:17:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv2] mm: Account pud page tables
Message-ID: <20170926101715.xn2htnxasld5nfe7@dhcp22.suse.cz>
References: <20170925073913.22628-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925073913.22628-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Mon 25-09-17 10:39:13, Kirill A. Shutemov wrote:
> On machine with 5-level paging support a process can allocate
> significant amount of memory and stay unnoticed by oom-killer and
> memory cgroup. The trick is to allocate a lot of PUD page tables.
> We don't account PUD page tables, only PMD and PTE.
> 
> We already addressed the same issue for PMD page tables, see
> dc6c9a35b66b ("mm: account pmd page tables to the process").
> Introduction 5-level paging bring the same issue for PUD page tables.
> 
> The patch expands accounting to PUD level.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>

So just for the reference. You can assume my
Acked-by: Michal Hocko <mhocko@suse.com>

it seems that no arch has PUD_ORDER > 0 so the oom part works correctly.
As mentioned in other email I think we should actually simplify the
whole thing and use a single counter for all pte levels. This will
remove some code and make this whole thing less error prone.

> ---
>  Documentation/sysctl/vm.txt   |  8 ++++----
>  arch/powerpc/mm/hugetlbpage.c |  1 +
>  arch/sparc/mm/hugetlbpage.c   |  1 +
>  fs/proc/task_mmu.c            |  5 ++++-
>  include/linux/mm.h            | 34 ++++++++++++++++++++++++++++++++--
>  include/linux/mm_types.h      |  3 +++
>  kernel/fork.c                 |  4 ++++
>  mm/debug.c                    |  6 ++++--
>  mm/memory.c                   | 15 +++++++++------
>  mm/oom_kill.c                 |  8 +++++---
>  10 files changed, 67 insertions(+), 18 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 9baf66a9ef4e..2717b6f2d706 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -622,10 +622,10 @@ oom_dump_tasks
>  
>  Enables a system-wide task dump (excluding kernel threads) to be produced
>  when the kernel performs an OOM-killing and includes such information as
> -pid, uid, tgid, vm size, rss, nr_ptes, nr_pmds, swapents, oom_score_adj
> -score, and name.  This is helpful to determine why the OOM killer was
> -invoked, to identify the rogue task that caused it, and to determine why
> -the OOM killer chose the task it did to kill.
> +pid, uid, tgid, vm size, rss, nr_ptes, nr_pmds, nr_puds, swapents,
> +oom_score_adj score, and name.  This is helpful to determine why the OOM
> +killer was invoked, to identify the rogue task that caused it, and to
> +determine why the OOM killer chose the task it did to kill.
>  
>  If this is set to zero, this information is suppressed.  On very
>  large systems with thousands of tasks it may not be feasible to dump
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> index 1571a498a33f..a9b9083c5e49 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -433,6 +433,7 @@ static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
>  	pud = pud_offset(pgd, start);
>  	pgd_clear(pgd);
>  	pud_free_tlb(tlb, pud, start);
> +	mm_dec_nr_puds(tlb->mm);
>  }
>  
>  /*
> diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
> index bcd8cdbc377f..fd0d85808828 100644
> --- a/arch/sparc/mm/hugetlbpage.c
> +++ b/arch/sparc/mm/hugetlbpage.c
> @@ -471,6 +471,7 @@ static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
>  	pud = pud_offset(pgd, start);
>  	pgd_clear(pgd);
>  	pud_free_tlb(tlb, pud, start);
> +	mm_dec_nr_puds(tlb->mm);
>  }
>  
>  void hugetlb_free_pgd_range(struct mmu_gather *tlb,
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 5589b4bd4b85..0bf9e423aa99 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -25,7 +25,7 @@
>  
>  void task_mem(struct seq_file *m, struct mm_struct *mm)
>  {
> -	unsigned long text, lib, swap, ptes, pmds, anon, file, shmem;
> +	unsigned long text, lib, swap, ptes, pmds, puds, anon, file, shmem;
>  	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
>  
>  	anon = get_mm_counter(mm, MM_ANONPAGES);
> @@ -51,6 +51,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  	swap = get_mm_counter(mm, MM_SWAPENTS);
>  	ptes = PTRS_PER_PTE * sizeof(pte_t) * atomic_long_read(&mm->nr_ptes);
>  	pmds = PTRS_PER_PMD * sizeof(pmd_t) * mm_nr_pmds(mm);
> +	puds = PTRS_PER_PUD * sizeof(pmd_t) * mm_nr_puds(mm);
>  	seq_printf(m,
>  		"VmPeak:\t%8lu kB\n"
>  		"VmSize:\t%8lu kB\n"
> @@ -67,6 +68,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  		"VmLib:\t%8lu kB\n"
>  		"VmPTE:\t%8lu kB\n"
>  		"VmPMD:\t%8lu kB\n"
> +		"VmPUD:\t%8lu kB\n"
>  		"VmSwap:\t%8lu kB\n",
>  		hiwater_vm << (PAGE_SHIFT-10),
>  		total_vm << (PAGE_SHIFT-10),
> @@ -81,6 +83,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
>  		ptes >> 10,
>  		pmds >> 10,
> +		puds >> 10,
>  		swap << (PAGE_SHIFT-10));
>  	hugetlb_report_usage(m, mm);
>  }
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index f8c10d336e42..c5eb8c609599 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1604,8 +1604,38 @@ static inline int __pud_alloc(struct mm_struct *mm, p4d_t *p4d,
>  {
>  	return 0;
>  }
> +
> +static inline unsigned long mm_nr_puds(const struct mm_struct *mm)
> +{
> +	return 0;
> +}
> +
> +static inline void mm_nr_puds_init(struct mm_struct *mm) {}
> +static inline void mm_inc_nr_puds(struct mm_struct *mm) {}
> +static inline void mm_dec_nr_puds(struct mm_struct *mm) {}
> +
>  #else
>  int __pud_alloc(struct mm_struct *mm, p4d_t *p4d, unsigned long address);
> +
> +static inline void mm_nr_puds_init(struct mm_struct *mm)
> +{
> +	atomic_long_set(&mm->nr_puds, 0);
> +}
> +
> +static inline unsigned long mm_nr_puds(const struct mm_struct *mm)
> +{
> +	return atomic_long_read(&mm->nr_puds);
> +}
> +
> +static inline void mm_inc_nr_puds(struct mm_struct *mm)
> +{
> +	atomic_long_inc(&mm->nr_puds);
> +}
> +
> +static inline void mm_dec_nr_puds(struct mm_struct *mm)
> +{
> +	atomic_long_dec(&mm->nr_puds);
> +}
>  #endif
>  
>  #if defined(__PAGETABLE_PMD_FOLDED) || !defined(CONFIG_MMU)
> @@ -1617,7 +1647,7 @@ static inline int __pmd_alloc(struct mm_struct *mm, pud_t *pud,
>  
>  static inline void mm_nr_pmds_init(struct mm_struct *mm) {}
>  
> -static inline unsigned long mm_nr_pmds(struct mm_struct *mm)
> +static inline unsigned long mm_nr_pmds(const struct mm_struct *mm)
>  {
>  	return 0;
>  }
> @@ -1633,7 +1663,7 @@ static inline void mm_nr_pmds_init(struct mm_struct *mm)
>  	atomic_long_set(&mm->nr_pmds, 0);
>  }
>  
> -static inline unsigned long mm_nr_pmds(struct mm_struct *mm)
> +static inline unsigned long mm_nr_pmds(const struct mm_struct *mm)
>  {
>  	return atomic_long_read(&mm->nr_pmds);
>  }
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 46f4ecf5479a..6c8c2bb9e5a1 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -401,6 +401,9 @@ struct mm_struct {
>  	atomic_long_t nr_ptes;			/* PTE page table pages */
>  #if CONFIG_PGTABLE_LEVELS > 2
>  	atomic_long_t nr_pmds;			/* PMD page table pages */
> +#endif
> +#if CONFIG_PGTABLE_LEVELS > 3
> +	atomic_long_t nr_puds;			/* PUD page table pages */
>  #endif
>  	int map_count;				/* number of VMAs */
>  
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 10646182440f..5624918154db 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -815,6 +815,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
>  	mm->core_state = NULL;
>  	atomic_long_set(&mm->nr_ptes, 0);
>  	mm_nr_pmds_init(mm);
> +	mm_nr_puds_init(mm);
>  	mm->map_count = 0;
>  	mm->locked_vm = 0;
>  	mm->pinned_vm = 0;
> @@ -874,6 +875,9 @@ static void check_mm(struct mm_struct *mm)
>  	if (mm_nr_pmds(mm))
>  		pr_alert("BUG: non-zero nr_pmds on freeing mm: %ld\n",
>  				mm_nr_pmds(mm));
> +	if (mm_nr_puds(mm))
> +		pr_alert("BUG: non-zero nr_puds on freeing mm: %ld\n",
> +				mm_nr_puds(mm));
>  
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
>  	VM_BUG_ON_MM(mm->pmd_huge_pte, mm);
> diff --git a/mm/debug.c b/mm/debug.c
> index 5715448ab0b5..afccb2565269 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -104,7 +104,8 @@ void dump_mm(const struct mm_struct *mm)
>  		"get_unmapped_area %p\n"
>  #endif
>  		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
> -		"pgd %p mm_users %d mm_count %d nr_ptes %lu nr_pmds %lu map_count %d\n"
> +		"pgd %p mm_users %d mm_count %d\n"
> +		"nr_ptes %lu nr_pmds %lu nr_puds %lu map_count %d\n"
>  		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
>  		"pinned_vm %lx data_vm %lx exec_vm %lx stack_vm %lx\n"
>  		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
> @@ -135,7 +136,8 @@ void dump_mm(const struct mm_struct *mm)
>  		mm->pgd, atomic_read(&mm->mm_users),
>  		atomic_read(&mm->mm_count),
>  		atomic_long_read((atomic_long_t *)&mm->nr_ptes),
> -		mm_nr_pmds((struct mm_struct *)mm),
> +		mm_nr_pmds(mm),
> +		mm_nr_puds(mm),
>  		mm->map_count,
>  		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm, mm->locked_vm,
>  		mm->pinned_vm, mm->data_vm, mm->exec_vm, mm->stack_vm,
> diff --git a/mm/memory.c b/mm/memory.c
> index ec4e15494901..8f49fdafac56 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -506,6 +506,7 @@ static inline void free_pud_range(struct mmu_gather *tlb, p4d_t *p4d,
>  	pud = pud_offset(p4d, start);
>  	p4d_clear(p4d);
>  	pud_free_tlb(tlb, pud, start);
> +	mm_dec_nr_puds(tlb->mm);
>  }
>  
>  static inline void free_p4d_range(struct mmu_gather *tlb, pgd_t *pgd,
> @@ -4124,15 +4125,17 @@ int __pud_alloc(struct mm_struct *mm, p4d_t *p4d, unsigned long address)
>  
>  	spin_lock(&mm->page_table_lock);
>  #ifndef __ARCH_HAS_5LEVEL_HACK
> -	if (p4d_present(*p4d))		/* Another has populated it */
> -		pud_free(mm, new);
> -	else
> +	if (!p4d_present(*p4d)) {
> +		mm_inc_nr_puds(mm);
>  		p4d_populate(mm, p4d, new);
> -#else
> -	if (pgd_present(*p4d))		/* Another has populated it */
> +	} else	/* Another has populated it */
>  		pud_free(mm, new);
> -	else
> +#else
> +	if (!pgd_present(*pud)) {
> +		mm_inc_nr_puds(mm);
>  		pgd_populate(mm, p4d, new);
> +	} else	/* Another has populated it */
> +		pud_free(mm, new);
>  #endif /* __ARCH_HAS_5LEVEL_HACK */
>  	spin_unlock(&mm->page_table_lock);
>  	return 0;
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 99736e026712..4bee6968885d 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -200,7 +200,8 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  	 * task's rss, pagetable and swap space use.
>  	 */
>  	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
> -		atomic_long_read(&p->mm->nr_ptes) + mm_nr_pmds(p->mm);
> +		atomic_long_read(&p->mm->nr_ptes) + mm_nr_pmds(p->mm) +
> +		mm_nr_puds(p->mm);
>  	task_unlock(p);
>  
>  	/*
> @@ -376,7 +377,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  	struct task_struct *p;
>  	struct task_struct *task;
>  
> -	pr_info("[ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name\n");
> +	pr_info("[ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds nr_puds swapents oom_score_adj name\n");
>  	rcu_read_lock();
>  	for_each_process(p) {
>  		if (oom_unkillable_task(p, memcg, nodemask))
> @@ -392,11 +393,12 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  			continue;
>  		}
>  
> -		pr_info("[%5d] %5d %5d %8lu %8lu %7ld %7ld %8lu         %5hd %s\n",
> +		pr_info("[%5d] %5d %5d %8lu %8lu %7ld %7ld %7ld %8lu         %5hd %s\n",
>  			task->pid, from_kuid(&init_user_ns, task_uid(task)),
>  			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
>  			atomic_long_read(&task->mm->nr_ptes),
>  			mm_nr_pmds(task->mm),
> +			mm_nr_puds(task->mm),
>  			get_mm_counter(task->mm, MM_SWAPENTS),
>  			task->signal->oom_score_adj, task->comm);
>  		task_unlock(task);
> -- 
> 2.14.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
