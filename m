Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91A7F6B0069
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 04:50:54 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id o80so3915352lfg.20
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 01:50:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e125si962376wmd.61.2017.10.06.01.50.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Oct 2017 01:50:52 -0700 (PDT)
Date: Fri, 6 Oct 2017 10:50:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv2 2/2] mm: Consolidate page table accounting
Message-ID: <20171006085051.stg7ytwjwdmdk4yg@dhcp22.suse.cz>
References: <20171005101442.49555-1-kirill.shutemov@linux.intel.com>
 <20171005101442.49555-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171005101442.49555-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

[CC linux-api because this is a user visible change]

On Thu 05-10-17 13:14:42, Kirill A. Shutemov wrote:
> Currently, we account page tables separately for each page table level,
> but that's redundant -- we only make use of total memory allocated to
> page tables for oom_badness calculation. We also provide the information
> to userspace, but it has dubious value there too.

I completely agree! The VmPMD has been added just in case wihtout any
specific use in mind.
 
> This patch switches page table accounting to single counter.
> 
> mm->pgtables_bytes is now used to account all page table levels. We use
> bytes, because page table size for different levels of page table tree
> may be different.
> 
> The change has user-visible effect: we don't have VmPMD and VmPUD
> reported in /proc/[pid]/status. Not sure if anybody uses them.
> (As alternative, we can always report 0 kB for them.

I would go with removing the value rather than faking it. If somebody
really depends on it then we will have to revert this.

> OOM-killer report is also slightly changed: we now report pgtables_bytes
> instead of nr_ptes, nr_pmd, nr_puds.

This will actually make the parsing easier because the script doesn't
have to care about different page table sizes which we didn't handle in
oom_badness properly as well.

> The benefit is that we now calculate oom_badness() more correctly for
> machines which have different size of page tables depending on level
> or where page tables are less than a page in size.

Not only that. Another benefit is that we reduce the number of counters
and the API maintenance.

The only downside can be debugability because we do not know which page
table level could leak. But I do not remember many bugs that would be
caught by separate counters so I wouldn't lose sleep over this.
 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks for doing this! One less item on my todo list ;)

> ---
>  Documentation/filesystems/proc.txt |  1 -
>  Documentation/sysctl/vm.txt        |  8 +++---
>  fs/proc/task_mmu.c                 | 11 ++------
>  include/linux/mm.h                 | 58 ++++++++------------------------------
>  include/linux/mm_types.h           |  8 +-----
>  kernel/fork.c                      | 16 +++--------
>  mm/debug.c                         |  7 ++---
>  mm/oom_kill.c                      | 14 ++++-----
>  8 files changed, 31 insertions(+), 92 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index adba21b5ada7..ec571b9bb18a 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -250,7 +250,6 @@ Table 1-2: Contents of the status files (as of 4.8)
>   VmExe                       size of text segment
>   VmLib                       size of shared library code
>   VmPTE                       size of page table entries
> - VmPMD                       size of second level page tables
>   VmSwap                      amount of swap used by anonymous private data
>                               (shmem swap usage is not included)
>   HugetlbPages                size of hugetlb memory portions
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 2717b6f2d706..2db0596d12f4 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -622,10 +622,10 @@ oom_dump_tasks
>  
>  Enables a system-wide task dump (excluding kernel threads) to be produced
>  when the kernel performs an OOM-killing and includes such information as
> -pid, uid, tgid, vm size, rss, nr_ptes, nr_pmds, nr_puds, swapents,
> -oom_score_adj score, and name.  This is helpful to determine why the OOM
> -killer was invoked, to identify the rogue task that caused it, and to
> -determine why the OOM killer chose the task it did to kill.
> +pid, uid, tgid, vm size, rss, pgtables_bytes, swapents, oom_score_adj
> +score, and name.  This is helpful to determine why the OOM killer was
> +invoked, to identify the rogue task that caused it, and to determine why
> +the OOM killer chose the task it did to kill.
>  
>  If this is set to zero, this information is suppressed.  On very
>  large systems with thousands of tasks it may not be feasible to dump
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 84c262d5197a..c9c81373225d 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -25,7 +25,7 @@
>  
>  void task_mem(struct seq_file *m, struct mm_struct *mm)
>  {
> -	unsigned long text, lib, swap, ptes, pmds, puds, anon, file, shmem;
> +	unsigned long text, lib, swap, anon, file, shmem;
>  	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
>  
>  	anon = get_mm_counter(mm, MM_ANONPAGES);
> @@ -49,9 +49,6 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
>  	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
>  	swap = get_mm_counter(mm, MM_SWAPENTS);
> -	ptes = PTRS_PER_PTE * sizeof(pte_t) * mm_nr_ptes(mm);
> -	pmds = PTRS_PER_PMD * sizeof(pmd_t) * mm_nr_pmds(mm);
> -	puds = PTRS_PER_PUD * sizeof(pud_t) * mm_nr_puds(mm);
>  	seq_printf(m,
>  		"VmPeak:\t%8lu kB\n"
>  		"VmSize:\t%8lu kB\n"
> @@ -67,8 +64,6 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  		"VmExe:\t%8lu kB\n"
>  		"VmLib:\t%8lu kB\n"
>  		"VmPTE:\t%8lu kB\n"
> -		"VmPMD:\t%8lu kB\n"
> -		"VmPUD:\t%8lu kB\n"
>  		"VmSwap:\t%8lu kB\n",
>  		hiwater_vm << (PAGE_SHIFT-10),
>  		total_vm << (PAGE_SHIFT-10),
> @@ -81,9 +76,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  		shmem << (PAGE_SHIFT-10),
>  		mm->data_vm << (PAGE_SHIFT-10),
>  		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
> -		ptes >> 10,
> -		pmds >> 10,
> -		puds >> 10,
> +		mm_pgtables_bytes(mm) >> 10,
>  		swap << (PAGE_SHIFT-10));
>  	hugetlb_report_usage(m, mm);
>  }
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index e185dcdc5183..a7e50c464021 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1604,37 +1604,20 @@ static inline int __pud_alloc(struct mm_struct *mm, p4d_t *p4d,
>  {
>  	return 0;
>  }
> -
> -static inline unsigned long mm_nr_puds(const struct mm_struct *mm)
> -{
> -	return 0;
> -}
> -
> -static inline void mm_nr_puds_init(struct mm_struct *mm) {}
>  static inline void mm_inc_nr_puds(struct mm_struct *mm) {}
>  static inline void mm_dec_nr_puds(struct mm_struct *mm) {}
>  
>  #else
>  int __pud_alloc(struct mm_struct *mm, p4d_t *p4d, unsigned long address);
>  
> -static inline void mm_nr_puds_init(struct mm_struct *mm)
> -{
> -	atomic_long_set(&mm->nr_puds, 0);
> -}
> -
> -static inline unsigned long mm_nr_puds(const struct mm_struct *mm)
> -{
> -	return atomic_long_read(&mm->nr_puds);
> -}
> -
>  static inline void mm_inc_nr_puds(struct mm_struct *mm)
>  {
> -	atomic_long_inc(&mm->nr_puds);
> +	atomic_long_add(PTRS_PER_PUD * sizeof(pud_t), &mm->pgtables_bytes);
>  }
>  
>  static inline void mm_dec_nr_puds(struct mm_struct *mm)
>  {
> -	atomic_long_dec(&mm->nr_puds);
> +	atomic_long_sub(PTRS_PER_PUD * sizeof(pud_t), &mm->pgtables_bytes);
>  }
>  #endif
>  
> @@ -1645,64 +1628,47 @@ static inline int __pmd_alloc(struct mm_struct *mm, pud_t *pud,
>  	return 0;
>  }
>  
> -static inline void mm_nr_pmds_init(struct mm_struct *mm) {}
> -
> -static inline unsigned long mm_nr_pmds(const struct mm_struct *mm)
> -{
> -	return 0;
> -}
> -
>  static inline void mm_inc_nr_pmds(struct mm_struct *mm) {}
>  static inline void mm_dec_nr_pmds(struct mm_struct *mm) {}
>  
>  #else
>  int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
>  
> -static inline void mm_nr_pmds_init(struct mm_struct *mm)
> -{
> -	atomic_long_set(&mm->nr_pmds, 0);
> -}
> -
> -static inline unsigned long mm_nr_pmds(const struct mm_struct *mm)
> -{
> -	return atomic_long_read(&mm->nr_pmds);
> -}
> -
>  static inline void mm_inc_nr_pmds(struct mm_struct *mm)
>  {
> -	atomic_long_inc(&mm->nr_pmds);
> +	atomic_long_add(PTRS_PER_PMD * sizeof(pmd_t), &mm->pgtables_bytes);
>  }
>  
>  static inline void mm_dec_nr_pmds(struct mm_struct *mm)
>  {
> -	atomic_long_dec(&mm->nr_pmds);
> +	atomic_long_sub(PTRS_PER_PMD * sizeof(pmd_t), &mm->pgtables_bytes);
>  }
>  #endif
>  
>  #ifdef CONFIG_MMU
> -static inline void mm_nr_ptes_init(struct mm_struct *mm)
> +static inline void mm_pgtables_bytes_init(struct mm_struct *mm)
>  {
> -	atomic_long_set(&mm->nr_ptes, 0);
> +	atomic_long_set(&mm->pgtables_bytes, 0);
>  }
>  
> -static inline unsigned long mm_nr_ptes(const struct mm_struct *mm)
> +static inline unsigned long mm_pgtables_bytes(const struct mm_struct *mm)
>  {
> -	return atomic_long_read(&mm->nr_ptes);
> +	return atomic_long_read(&mm->pgtables_bytes);
>  }
>  
>  static inline void mm_inc_nr_ptes(struct mm_struct *mm)
>  {
> -	atomic_long_inc(&mm->nr_ptes);
> +	atomic_long_add(PTRS_PER_PTE * sizeof(pte_t), &mm->pgtables_bytes);
>  }
>  
>  static inline void mm_dec_nr_ptes(struct mm_struct *mm)
>  {
> -	atomic_long_dec(&mm->nr_ptes);
> +	atomic_long_sub(PTRS_PER_PTE * sizeof(pte_t), &mm->pgtables_bytes);
>  }
>  #else
> -static inline void mm_nr_ptes_init(struct mm_struct *mm) {}
>  
> -static inline unsigned long mm_nr_ptes(const struct mm_struct *mm)
> +static inline void mm_pgtables_bytes_init(struct mm_struct *mm) {}
> +static inline unsigned long mm_pgtables_bytes(struct mm_struct *mm)
>  {
>  	return 0;
>  }
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 95d0eefe1f4a..aadd23377fbb 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -399,13 +399,7 @@ struct mm_struct {
>  	atomic_t mm_count;
>  
>  #ifdef CONFIG_MMU
> -	atomic_long_t nr_ptes;			/* PTE page table pages */
> -#endif
> -#if CONFIG_PGTABLE_LEVELS > 2
> -	atomic_long_t nr_pmds;			/* PMD page table pages */
> -#endif
> -#if CONFIG_PGTABLE_LEVELS > 3
> -	atomic_long_t nr_puds;			/* PUD page table pages */
> +	atomic_long_t pgtables_bytes;		/* PTE page table pages */
>  #endif
>  	int map_count;				/* number of VMAs */
>  
> diff --git a/kernel/fork.c b/kernel/fork.c
> index d466181902cf..ad849ccdad9e 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -813,9 +813,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
>  	init_rwsem(&mm->mmap_sem);
>  	INIT_LIST_HEAD(&mm->mmlist);
>  	mm->core_state = NULL;
> -	mm_nr_ptes_init(mm);
> -	mm_nr_pmds_init(mm);
> -	mm_nr_puds_init(mm);
> +	mm_pgtables_bytes_init(mm);
>  	mm->map_count = 0;
>  	mm->locked_vm = 0;
>  	mm->pinned_vm = 0;
> @@ -869,15 +867,9 @@ static void check_mm(struct mm_struct *mm)
>  					  "mm:%p idx:%d val:%ld\n", mm, i, x);
>  	}
>  
> -	if (mm_nr_ptes(mm))
> -		pr_alert("BUG: non-zero nr_ptes on freeing mm: %ld\n",
> -				mm_nr_ptes(mm));
> -	if (mm_nr_pmds(mm))
> -		pr_alert("BUG: non-zero nr_pmds on freeing mm: %ld\n",
> -				mm_nr_pmds(mm));
> -	if (mm_nr_puds(mm))
> -		pr_alert("BUG: non-zero nr_puds on freeing mm: %ld\n",
> -				mm_nr_puds(mm));
> +	if (mm_pgtables_bytes(mm))
> +		pr_alert("BUG: non-zero pgtables_bytes on freeing mm: %ld\n",
> +				mm_pgtables_bytes(mm));
>  
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
>  	VM_BUG_ON_MM(mm->pmd_huge_pte, mm);
> diff --git a/mm/debug.c b/mm/debug.c
> index 177326818d24..299248a7fe0d 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -104,8 +104,7 @@ void dump_mm(const struct mm_struct *mm)
>  		"get_unmapped_area %p\n"
>  #endif
>  		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
> -		"pgd %p mm_users %d mm_count %d\n"
> -		"nr_ptes %lu nr_pmds %lu nr_puds %lu map_count %d\n"
> +		"pgd %p mm_users %d mm_count %d pgtables_bytes %lu map_count %d\n"
>  		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
>  		"pinned_vm %lx data_vm %lx exec_vm %lx stack_vm %lx\n"
>  		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
> @@ -135,9 +134,7 @@ void dump_mm(const struct mm_struct *mm)
>  		mm->mmap_base, mm->mmap_legacy_base, mm->highest_vm_end,
>  		mm->pgd, atomic_read(&mm->mm_users),
>  		atomic_read(&mm->mm_count),
> -		mm_nr_ptes(mm),
> -		mm_nr_pmds(mm),
> -		mm_nr_puds(mm),
> +		mm_pgtables_bytes(mm),
>  		mm->map_count,
>  		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm, mm->locked_vm,
>  		mm->pinned_vm, mm->data_vm, mm->exec_vm, mm->stack_vm,
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 851a0eec2624..a48280e64be6 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -200,7 +200,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  	 * task's rss, pagetable and swap space use.
>  	 */
>  	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
> -		mm_nr_ptes(p->mm) + mm_nr_pmds(p->mm) + mm_nr_puds(p->mm);
> +		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
>  	task_unlock(p);
>  
>  	/*
> @@ -368,15 +368,15 @@ static void select_bad_process(struct oom_control *oc)
>   * Dumps the current memory state of all eligible tasks.  Tasks not in the same
>   * memcg, not in the same cpuset, or bound to a disjoint set of mempolicy nodes
>   * are not shown.
> - * State information includes task's pid, uid, tgid, vm size, rss, nr_ptes,
> - * swapents, oom_score_adj value, and name.
> + * State information includes task's pid, uid, tgid, vm size, rss,
> + * pgtables_bytes, swapents, oom_score_adj value, and name.
>   */
>  static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  {
>  	struct task_struct *p;
>  	struct task_struct *task;
>  
> -	pr_info("[ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds nr_puds swapents oom_score_adj name\n");
> +	pr_info("[ pid ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
>  	rcu_read_lock();
>  	for_each_process(p) {
>  		if (oom_unkillable_task(p, memcg, nodemask))
> @@ -392,12 +392,10 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  			continue;
>  		}
>  
> -		pr_info("[%5d] %5d %5d %8lu %8lu %7ld %7ld %7ld %8lu         %5hd %s\n",
> +		pr_info("[%5d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
>  			task->pid, from_kuid(&init_user_ns, task_uid(task)),
>  			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
> -			mm_nr_ptes(task->mm),
> -			mm_nr_pmds(task->mm),
> -			mm_nr_puds(task->mm),
> +			mm_pgtables_bytes(task->mm),
>  			get_mm_counter(task->mm, MM_SWAPENTS),
>  			task->signal->oom_score_adj, task->comm);
>  		task_unlock(task);
> -- 
> 2.14.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
