Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 351B86B0008
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 21:01:38 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 202so2936186pgb.13
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:01:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n9-v6sor493287plk.134.2018.02.22.18.01.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Feb 2018 18:01:36 -0800 (PST)
Date: Fri, 23 Feb 2018 11:01:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] Synchronize task mm counters on demand
Message-ID: <20180223020130.GA115990@rodete-desktop-imager.corp.google.com>
References: <20180222020633.GC27147@rodete-desktop-imager.corp.google.com>
 <20180222024620.47691-1-dancol@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180222024620.47691-1-dancol@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

Hi Daniel,

On Wed, Feb 21, 2018 at 06:46:20PM -0800, Daniel Colascione wrote:
> When SPLIT_RSS_COUNTING is in use (which it is on SMP systems,
> generally speaking), we buffer certain changes to mm-wide counters
> through counters local to the current struct task, flushing them to
> the mm after seeing 64 page faults, as well as on task exit and
> exec. This scheme can leave a large amount of memory unaccounted-for
> in process memory counters, especially for processes with many threads
> (each of which gets 64 "free" faults), and it produces an
> inconsistency with the same memory counters scanned VMA-by-VMA using
> smaps. This inconsistency can persist for an arbitrarily long time,
> since there is no way to force a task to flush its counters to its mm.
> 
> This patch flushes counters on get_mm_counter. This way, readers
> always have an up-to-date view of the counters for a particular
> task. It adds a spinlock-acquire to the add_mm_counter_fast path, but
> this spinlock should almost always be uncontended.
> 
> Signed-off-by: Daniel Colascione <dancol@google.com>
> ---
>  fs/proc/task_mmu.c            |  2 +-
>  include/linux/mm.h            | 16 ++++++++-
>  include/linux/mm_types_task.h | 13 +++++--
>  kernel/fork.c                 |  1 +
>  mm/memory.c                   | 64 ++++++++++++++++++++++-------------
>  5 files changed, 67 insertions(+), 29 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index ec6d2983a5cb..ac9e86452ca4 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -852,7 +852,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  			   mss->private_hugetlb >> 10,
>  			   mss->swap >> 10,
>  			   (unsigned long)(mss->swap_pss >> (10 + PSS_SHIFT)),
> -			   (unsigned long)(mss->pss >> (10 + PSS_SHIFT)));
> +			   (unsigned long)(mss->pss_locked >> (10 + PSS_SHIFT)));

It seems you mixed with other patch.

>  
>  	if (!rollup_mode) {
>  		arch_show_smap(m, vma);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ad06d42adb1a..f8129afebbdd 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1507,14 +1507,28 @@ extern int mprotect_fixup(struct vm_area_struct *vma,
>   */
>  int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  			  struct page **pages);
> +
> +#ifdef SPLIT_RSS_COUNTING
> +/* Flush all task-buffered MM counters to the mm */
> +void sync_mm_rss_all_users(struct mm_struct *mm);

Really heavy functioin iterates all of processes and threads.

> +#endif
> +
>  /*
>   * per-process(per-mm_struct) statistics.
>   */
>  static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
>  {
> -	long val = atomic_long_read(&mm->rss_stat.count[member]);
> +	long val;
>  
>  #ifdef SPLIT_RSS_COUNTING
> +	if (atomic_xchg(&mm->rss_stat.dirty, 0))
> +		sync_mm_rss_all_users(mm);

So, if we dirty _a_ page, should we iterate all of processes and threads?
Even, get_mm_counter would be used places without requiring accurate
numbers. I think you can sync stats on place you really need to rather
than adding this.

I'd like to see all_threads_sync_mm_rss(mm_struct mm_struct *mm) which iterates
just current's thread group(unless others are against) suggested by peterz.
And then let's put it on places where you really need(e.g., fs/proc/task_mmu.c
somewhere).
Otherwise, if you want to make all of path where get that rss accurate,
I don't think iterating current's thread group is a good solution because
getting rss is used for many places. We don't need to make them trouble.

Thanks.

> +#endif
> +
> +	val = atomic_long_read(&mm->rss_stat.count[member]);
> +
> +#ifdef SPLIT_RSS_COUNTING
> +
>  	/*
>  	 * counter is updated in asynchronous manner and may go to minus.
>  	 * But it's never be expected number for users.
> diff --git a/include/linux/mm_types_task.h b/include/linux/mm_types_task.h
> index 5fe87687664c..7e027b2b3ef6 100644
> --- a/include/linux/mm_types_task.h
> +++ b/include/linux/mm_types_task.h
> @@ -12,6 +12,7 @@
>  #include <linux/threads.h>
>  #include <linux/atomic.h>
>  #include <linux/cpumask.h>
> +#include <linux/spinlock.h>
>  
>  #include <asm/page.h>
>  
> @@ -46,14 +47,20 @@ enum {
>  
>  #if USE_SPLIT_PTE_PTLOCKS && defined(CONFIG_MMU)
>  #define SPLIT_RSS_COUNTING
> -/* per-thread cached information, */
> +/* per-thread cached information */
>  struct task_rss_stat {
> -	int events;	/* for synchronization threshold */
> -	int count[NR_MM_COUNTERS];
> +	spinlock_t lock;
> +	bool marked_mm_dirty;
> +	long count[NR_MM_COUNTERS];
>  };
>  #endif /* USE_SPLIT_PTE_PTLOCKS */
>  
>  struct mm_rss_stat {
> +#ifdef SPLIT_RSS_COUNTING
> +	/* When true, indicates that we need to flush task counters to
> +	 * the mm structure.  */
> +	atomic_t dirty;
> +#endif
>  	atomic_long_t count[NR_MM_COUNTERS];
>  };
>  
> diff --git a/kernel/fork.c b/kernel/fork.c
> index be8aa5b98666..d7a5daa7d7d0 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1710,6 +1710,7 @@ static __latent_entropy struct task_struct *copy_process(
>  
>  #if defined(SPLIT_RSS_COUNTING)
>  	memset(&p->rss_stat, 0, sizeof(p->rss_stat));
> +	spin_lock_init(&p->rss_stat.lock);
>  #endif
>  
>  	p->default_timer_slack_ns = current->timer_slack_ns;
> diff --git a/mm/memory.c b/mm/memory.c
> index 5fcfc24904d1..a31d28a61ebe 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -44,6 +44,7 @@
>  #include <linux/sched/coredump.h>
>  #include <linux/sched/numa_balancing.h>
>  #include <linux/sched/task.h>
> +#include <linux/sched/signal.h>
>  #include <linux/hugetlb.h>
>  #include <linux/mman.h>
>  #include <linux/swap.h>
> @@ -141,49 +142,67 @@ core_initcall(init_zero_pfn);
>  
>  #if defined(SPLIT_RSS_COUNTING)
>  
> -void sync_mm_rss(struct mm_struct *mm)
> +static void sync_mm_rss_task(struct task_struct *task, struct mm_struct *mm)
>  {
>  	int i;
> +	if (unlikely(task->mm != mm))
> +		return;
> +	spin_lock(&task->rss_stat.lock);
> +	if (task->rss_stat.marked_mm_dirty) {
> +		task->rss_stat.marked_mm_dirty = false;
> +		for (i = 0; i < NR_MM_COUNTERS; ++i) {
> +			add_mm_counter(mm, i, task->rss_stat.count[i]);
> +			task->rss_stat.count[i] = 0;
> +		}
> +	}
> +	spin_unlock(&task->rss_stat.lock);
> +}
>  
> -	for (i = 0; i < NR_MM_COUNTERS; i++) {
> -		if (current->rss_stat.count[i]) {
> -			add_mm_counter(mm, i, current->rss_stat.count[i]);
> -			current->rss_stat.count[i] = 0;
> +void sync_mm_rss(struct mm_struct *mm)
> +{
> +	sync_mm_rss_task(current, mm);
> +}
> +
> +void sync_mm_rss_all_users(struct mm_struct *mm)
> +{
> +	struct task_struct *p, *t;
> +	rcu_read_lock();
> +	for_each_process(p) {
> +		if (p->mm != mm)
> +			continue;
> +		for_each_thread(p, t) {
> +			task_lock(t);  /* Stop t->mm changing */
> +			sync_mm_rss_task(t, mm);
> +			task_unlock(t);
>  		}
>  	}
> -	current->rss_stat.events = 0;
> +	rcu_read_unlock();
>  }
>  
>  static void add_mm_counter_fast(struct mm_struct *mm, int member, int val)
>  {
>  	struct task_struct *task = current;
>  
> -	if (likely(task->mm == mm))
> +	if (likely(task->mm == mm)) {
> +		spin_lock(&task->rss_stat.lock);
>  		task->rss_stat.count[member] += val;
> -	else
> +		if (!task->rss_stat.marked_mm_dirty) {
> +			task->rss_stat.marked_mm_dirty = true;
> +			atomic_set(&mm->rss_stat.dirty, 1);
> +		}
> +		spin_unlock(&task->rss_stat.lock);
> +	} else {
>  		add_mm_counter(mm, member, val);
> +	}
>  }
>  #define inc_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member, 1)
>  #define dec_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member, -1)
>  
> -/* sync counter once per 64 page faults */
> -#define TASK_RSS_EVENTS_THRESH	(64)
> -static void check_sync_rss_stat(struct task_struct *task)
> -{
> -	if (unlikely(task != current))
> -		return;
> -	if (unlikely(task->rss_stat.events++ > TASK_RSS_EVENTS_THRESH))
> -		sync_mm_rss(task->mm);
> -}
>  #else /* SPLIT_RSS_COUNTING */
>  
>  #define inc_mm_counter_fast(mm, member) inc_mm_counter(mm, member)
>  #define dec_mm_counter_fast(mm, member) dec_mm_counter(mm, member)
>  
> -static void check_sync_rss_stat(struct task_struct *task)
> -{
> -}
> -
>  #endif /* SPLIT_RSS_COUNTING */
>  
>  #ifdef HAVE_GENERIC_MMU_GATHER
> @@ -4119,9 +4138,6 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>  	count_vm_event(PGFAULT);
>  	count_memcg_event_mm(vma->vm_mm, PGFAULT);
>  
> -	/* do counter updates before entering really critical section. */
> -	check_sync_rss_stat(current);
> -
>  	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
>  					    flags & FAULT_FLAG_INSTRUCTION,
>  					    flags & FAULT_FLAG_REMOTE))
> -- 
> 2.16.1.291.g4437f3f132-goog
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
