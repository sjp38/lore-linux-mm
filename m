Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 82EFB6B004F
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 17:24:34 -0400 (EDT)
Date: Thu, 4 Jun 2009 14:23:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] procfs: provide stack information for threads
Message-Id: <20090604142358.95af81d5.akpm@linux-foundation.org>
In-Reply-To: <1244146873.20012.6.camel@wall-e>
References: <1238511505.364.61.camel@matrix>
	<20090401193135.GA12316@elte.hu>
	<1244146873.20012.6.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 04 Jun 2009 22:21:13 +0200
Stefani Seibold <stefani@seibold.net> wrote:

> This is the newest version of the formaly named "detailed stack info"
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
>  - Code cleanup suggested by Andrew
> 
> The patch is against 2.6.30-rc7 and tested with on intel and ppc
> architectures.

OK, we're getting there.

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
> +			break;
> +	}
> +	return i - (p->stack_start & PAGE_MASK);
> +#else
> +	for (i = vma->vm_start; i+PAGE_SIZE <= stkpage; i += PAGE_SIZE) {
> +
> +		page = follow_page(vma, i, 0);
> +
> +		if (!IS_ERR(page) && page)
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

Both follow_page() and find_vma() require locking: down_read(mmap_sem)
or down_write(mmap_sem).  down_read() is appropriate here.

> +				} else {
> +					unsigned long stack_start;
> +					struct proc_maps_private *pmp;
> +
> +					pmp = m->private;
> +					stack_start = pmp->task->stack_start;
> +
> +					if (vma->vm_start <= stack_start &&
> +					    vma->vm_end >= stack_start) {
> +						pad_len_spaces(m, len);
> +						seq_printf(m,
> +						 "[thread stack: %08lx]",
> +						 stack_start);
> +					}

You're making changes to the user interface but it's not terribly clear
what they look like.  Please include sample output from the affected
procfs files so that we can review the proposed changes.

Please update the userspace documentation to reflect the changes. 
Documentation/filesystems/proc.txt documents VmStk, so probably that is
the appropriate place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
