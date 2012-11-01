Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 0E66A6B0062
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 11:48:47 -0400 (EDT)
Date: Thu, 1 Nov 2012 15:48:42 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 28/31] sched, numa, mm: Implement constant, per task
 Working Set Sampling (WSS) rate
Message-ID: <20121101154842.GD3888@suse.de>
References: <20121025121617.617683848@chello.nl>
 <20121025124834.592333415@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121025124834.592333415@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 25, 2012 at 02:16:45PM +0200, Peter Zijlstra wrote:
> Previously, to probe the working set of a task, we'd use
> a very simple and crude method: mark all of its address
> space PROT_NONE.
> 
> That method has various (obvious) disadvantages:
> 
>  - it samples the working set at dissimilar rates,
>    giving some tasks a sampling quality advantage
>    over others.
> 
>  - creates performance problems for tasks with very
>    large working sets
> 
>  - over-samples processes with large address spaces but
>    which only very rarely execute
> 
> Improve that method by keeping a rotating offset into the
> address space that marks the current position of the scan,
> and advance it by a constant rate (in a CPU cycles execution
> proportional manner). If the offset reaches the last mapped
> address of the mm then it then it starts over at the first
> address.
> 
> The per-task nature of the working set sampling functionality
> in this tree allows such constant rate, per task,
> execution-weight proportional sampling of the working set,
> with an adaptive sampling interval/frequency that goes from
> once per 100 msecs up to just once per 1.6 seconds.
> The current sampling volume is 256 MB per interval.
> 
> As tasks mature and converge their working set, so does the
> sampling rate slow down to just a trickle, 256 MB per 1.6
> seconds of CPU time executed.
> 
> This, beyond being adaptive, also rate-limits rarely
> executing systems and does not over-sample on overloaded
> systems.
> 
> [ In AutoNUMA speak, this patch deals with the effective sampling
>   rate of the 'hinting page fault'. AutoNUMA's scanning is
>   currently rate-limited, but it is also fundamentally
>   single-threaded, executing in the knuma_scand kernel thread,
>   so the limit in AutoNUMA is global and does not scale up with
>   the number of CPUs, nor does it scan tasks in an execution
>   proportional manner.
> 
>   So the idea of rate-limiting the scanning was first implemented
>   in the AutoNUMA tree via a global rate limit. This patch goes
>   beyond that by implementing an execution rate proportional
>   working set sampling rate that is not implemented via a single
>   global scanning daemon. ]
> 
> [ Dan Carpenter pointed out a possible NULL pointer dereference in the
>   first version of this patch. ]
> 
> Based-on-idea-by: Andrea Arcangeli <aarcange@redhat.com>
> Bug-Found-By: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> [ Wrote changelog and fixed bug. ]
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>  include/linux/mm_types.h |    1 +
>  include/linux/sched.h    |    1 +
>  kernel/sched/fair.c      |   43 ++++++++++++++++++++++++++++++-------------
>  kernel/sysctl.c          |    7 +++++++
>  4 files changed, 39 insertions(+), 13 deletions(-)
> 
> Index: tip/include/linux/mm_types.h
> ===================================================================
> --- tip.orig/include/linux/mm_types.h
> +++ tip/include/linux/mm_types.h
> @@ -405,6 +405,7 @@ struct mm_struct {
>  #endif
>  #ifdef CONFIG_SCHED_NUMA
>  	unsigned long numa_next_scan;
> +	unsigned long numa_scan_offset;
>  	int numa_scan_seq;
>  #endif
>  	struct uprobes_state uprobes_state;
> Index: tip/include/linux/sched.h
> ===================================================================
> --- tip.orig/include/linux/sched.h
> +++ tip/include/linux/sched.h
> @@ -2022,6 +2022,7 @@ extern enum sched_tunable_scaling sysctl
>  
>  extern unsigned int sysctl_sched_numa_scan_period_min;
>  extern unsigned int sysctl_sched_numa_scan_period_max;
> +extern unsigned int sysctl_sched_numa_scan_size;
>  extern unsigned int sysctl_sched_numa_settle_count;
>  
>  #ifdef CONFIG_SCHED_DEBUG
> Index: tip/kernel/sched/fair.c
> ===================================================================
> --- tip.orig/kernel/sched/fair.c
> +++ tip/kernel/sched/fair.c
> @@ -829,8 +829,9 @@ static void account_numa_dequeue(struct
>  /*
>   * numa task sample period in ms: 5s
>   */
> -unsigned int sysctl_sched_numa_scan_period_min = 5000;
> -unsigned int sysctl_sched_numa_scan_period_max = 5000*16;
> +unsigned int sysctl_sched_numa_scan_period_min = 100;
> +unsigned int sysctl_sched_numa_scan_period_max = 100*16;
> +unsigned int sysctl_sched_numa_scan_size = 256;   /* MB */
>  
>  /*
>   * Wait for the 2-sample stuff to settle before migrating again
> @@ -904,6 +905,9 @@ void task_numa_work(struct callback_head
>  	unsigned long migrate, next_scan, now = jiffies;
>  	struct task_struct *p = current;
>  	struct mm_struct *mm = p->mm;
> +	struct vm_area_struct *vma;
> +	unsigned long offset, end;
> +	long length;
>  
>  	WARN_ON_ONCE(p != container_of(work, struct task_struct, numa_work));
>  
> @@ -930,18 +934,31 @@ void task_numa_work(struct callback_head
>  	if (cmpxchg(&mm->numa_next_scan, migrate, next_scan) != migrate)
>  		return;
>  
> -	ACCESS_ONCE(mm->numa_scan_seq)++;
> -	{
> -		struct vm_area_struct *vma;
> -
> -		down_write(&mm->mmap_sem);
> -		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> -			if (!vma_migratable(vma))
> -				continue;
> -			change_protection(vma, vma->vm_start, vma->vm_end, vma_prot_none(vma), 0);
> -		}
> -		up_write(&mm->mmap_sem);
> +	offset = mm->numa_scan_offset;
> +	length = sysctl_sched_numa_scan_size;
> +	length <<= 20;
> +
> +	down_write(&mm->mmap_sem);

I should have spotted this during the last patch but we have to take
mmap_sem for write?!? Why? Parallel mmap and fault performance is
potentially mutilated by this depending on how often this task_numa_work
thing is running.

> +	vma = find_vma(mm, offset);

and a find_vma every scan restart. That sucks too.

Cache the vma as well as the offset. Compare vma->mm under mmap_sem held
for read and that the offset still matches. Will that avoid the expense
of the lookup?

> +	if (!vma) {
> +		ACCESS_ONCE(mm->numa_scan_seq)++;
> +		offset = 0;
> +		vma = mm->mmap;
> +	}
> +	for (; vma && length > 0; vma = vma->vm_next) {
> +		if (!vma_migratable(vma))
> +			continue;
> +
> +		offset = max(offset, vma->vm_start);
> +		end = min(ALIGN(offset + length, HPAGE_SIZE), vma->vm_end);
> +		length -= end - offset;
> +
> +		change_prot_none(vma, offset, end);
> +
> +		offset = end;
>  	}
> +	mm->numa_scan_offset = offset;
> +	up_write(&mm->mmap_sem);
>  }
>  
>  /*
> Index: tip/kernel/sysctl.c
> ===================================================================
> --- tip.orig/kernel/sysctl.c
> +++ tip/kernel/sysctl.c
> @@ -367,6 +367,13 @@ static struct ctl_table kern_table[] = {
>  		.proc_handler	= proc_dointvec,
>  	},
>  	{
> +		.procname	= "sched_numa_scan_size_mb",
> +		.data		= &sysctl_sched_numa_scan_size,
> +		.maxlen		= sizeof(unsigned int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +	{

If some muppet writes 0 into this, it effectively disables scanning. I
guess who cares, but maybe a minimum value of a a hugepage size would
make some sort of sense.

>  		.procname	= "sched_numa_settle_count",
>  		.data		= &sysctl_sched_numa_settle_count,
>  		.maxlen		= sizeof(unsigned int),
> 
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
