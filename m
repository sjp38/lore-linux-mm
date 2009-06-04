Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 968546B004D
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 07:38:36 -0400 (EDT)
Date: Thu, 4 Jun 2009 04:37:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] procfs: provide stack information for threads
Message-Id: <20090604043750.e1031e01.akpm@linux-foundation.org>
In-Reply-To: <1244114628.31230.3.camel@wall-e>
References: <1238511505.364.61.camel@matrix>
	<20090401193135.GA12316@elte.hu>
	<1244114628.31230.3.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Joerg Engel <joern@logfs.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Thu, 04 Jun 2009 13:23:48 +0200 Stefani Seibold <stefani@seibold.net> wrote:

> Hi everybody,
> 
> This is the latest version of the formaly named "detailed stack info"
> patch which give you a better overview of the userland application stack
> usage, especially for embedded linux.
> 
> Currently you are only able to dump the main process/thread stack usage
> which is showed in /proc/pid/status by the "VmStk" Value. But you get no
> information about the consumed stack memory of the the threads.
> 
> There is an enhancement in the /proc/<pid>/{task/*,}/*maps and which
> marks the vm mapping where the thread stack pointer reside with "[thread
> stack xxxxxxxx]". xxxxxxxx is the start address of the stack.
> 
> Also there is a new entry "stack usage" in /proc/<pid>/{task/*,}/status
> which will you give the current stack usage in kb.
> 
> I also fixed stack base address in /proc/<pid>/task/*/stat to the base
> address of the associated thread stack and not the one of the main
> process. This makes more sense.
> 
> Changes since last posting:
> 
>  - Redesigned everything what was suggested by Andrew

You didn't account for some of my comments.  I'll repeat the ones which
I recall below.

>  - slime done

What's "slime"?

> +static inline unsigned long get_stack_usage_in_bytes(struct vm_area_struct *vma,
> +					struct task_struct *p)
> +{
> +	unsigned long	i;
> +	struct page	*page;
> +	unsigned long	stkpage;
> +
> +	stkpage = KSTK_ESP(p) & PAGE_MASK;
> +
> +#ifdef CONFIG_STACK_GROWSUP
> +	for (i = vma->vm_end; i-PAGE_SIZE > stkpage; i -= PAGE_SIZE) {
> +
> +		page = follow_page(vma, i-PAGE_SIZE, 0);
> +
> +		if (!IS_ERR(page) && page)

Shouldn't this be !page?

> +			break;
> +	}
> +	return i - (p->stack_start & PAGE_MASK);
> +#else
> +	for (i = vma->vm_start; i+PAGE_SIZE <= stkpage; i += PAGE_SIZE) {
> +
> +		page = follow_page(vma, i, 0);
> +
> +		if (!IS_ERR(page) && page)

Ditto

> +			break;
> +	}
> +	return (p->stack_start & PAGE_MASK) - i + PAGE_SIZE;
> +#endif
> +}
> +
> +static inline void task_show_stack_usage(struct seq_file *m,
> +						struct task_struct *p)
> +{
> +	struct vm_area_struct	*vma;
> +	struct mm_struct	*mm;
> +
> +	mm = get_task_mm(p);
> +
> +	if (mm) {
> +		vma = find_vma(mm, p->stack_start);
> +
> +		if (vma)
> +			seq_printf(m, "Stack usage:\t%lu kB\n",
> +				get_stack_usage_in_bytes(vma, p) >> 10);
> +
> +		mmput(mm);
> +	}
> +}
> +
>  int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
>  			struct pid *pid, struct task_struct *task)
>  {
> @@ -340,6 +389,7 @@
>  	task_show_regs(m, task);
>  #endif
>  	task_context_switch_counts(m, task);
> +	task_show_stack_usage(m, task);
>  	return 0;
>  }
>  
> @@ -481,7 +531,7 @@
>  		rsslim,
>  		mm ? mm->start_code : 0,
>  		mm ? mm->end_code : 0,
> -		(permitted && mm) ? mm->start_stack : 0,
> +		(permitted) ? task->stack_start : 0,
>  		esp,
>  		eip,
>  		/* The signal information here is obsolete.
> diff -u -N -r linux-2.6.30.orig/fs/proc/task_mmu.c linux-2.6.30/fs/proc/task_mmu.c
> --- linux-2.6.30.orig/fs/proc/task_mmu.c	2009-06-04 09:29:47.000000000 +0200
> +++ linux-2.6.30/fs/proc/task_mmu.c	2009-06-04 09:32:35.000000000 +0200
> @@ -242,6 +242,20 @@
>  				} else if (vma->vm_start <= mm->start_stack &&
>  					   vma->vm_end >= mm->start_stack) {
>  					name = "[stack]";
> +				} else {
> +					unsigned long stack_start;
> +
> +					stack_start =
> +						((struct proc_maps_private *)
> +						m->private)->task->stack_start;

I'd suggested a clearer/cleaner way of implementing this.

> +					if (vma->vm_start <= stack_start &&
> +					    vma->vm_end >= stack_start) {
> +						pad_len_spaces(m, len);
> +						seq_printf(m,
> +						 "[thread stack: %08lx]",
> +						 stack_start);
> +					}
>  				}
>  			} else {
>  				name = "[vdso]";
> diff -u -N -r linux-2.6.30.orig/include/linux/sched.h linux-2.6.30/include/linux/sched.h
> --- linux-2.6.30.orig/include/linux/sched.h	2009-06-04 09:29:47.000000000 +0200
> +++ linux-2.6.30/include/linux/sched.h	2009-06-04 09:32:35.000000000 +0200
> @@ -1429,6 +1429,7 @@
>  	/* state flags for use by tracers */
>  	unsigned long trace;
>  #endif
> +	unsigned long stack_start;
>  };
>  
>  /* Future-safe accessor for struct task_struct's cpus_allowed. */
> diff -u -N -r linux-2.6.30.orig/kernel/fork.c linux-2.6.30/kernel/fork.c
> --- linux-2.6.30.orig/kernel/fork.c	2009-06-04 09:29:47.000000000 +0200
> +++ linux-2.6.30/kernel/fork.c	2009-06-04 13:15:35.000000000 +0200
> @@ -1092,6 +1092,8 @@
>  	if (unlikely(current->ptrace))
>  		ptrace_fork(p, clone_flags);
>  
> +	p->stack_start = stack_start;

OK, that got simpler.

> Signed-off-by: Stefani Seibold <stefani@seibold.net>

This should be positioned at the end of the changelog, ahead of the
patch itself.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
