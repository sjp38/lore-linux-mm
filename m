Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F37266B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 15:31:23 -0400 (EDT)
Date: Wed, 1 Apr 2009 21:31:35 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Detailed Stack Information Patch [1/3]
Message-ID: <20090401193135.GA12316@elte.hu>
References: <1238511505.364.61.camel@matrix>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1238511505.364.61.camel@matrix>
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Joerg Engel <joern@logfs.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>


* Stefani Seibold <stefani@seibold.net> wrote:

> diff -u -N -r linux-2.6.29.orig/fs/exec.c linux-2.6.29/fs/exec.c
> --- linux-2.6.29.orig/fs/exec.c	2009-03-24 00:12:14.000000000 +0100
> +++ linux-2.6.29/fs/exec.c	2009-03-31 16:02:55.000000000 +0200
> @@ -1336,6 +1336,10 @@
>  	if (retval < 0)
>  		goto out;
>  
> +#ifdef CONFIG_PROC_STACK
> +	current->stack_start = current->mm->start_stack;
> +#endif

Ok. The 1/3 patch, the whole "display where the stack is" thing is 
obviously useful and we know that.

Today we display this:

 earth4:~/tip> cat /proc/self/maps 
 00110000-00111000 r-xp 00110000 00:00 0          [vdso]
 0053e000-0055e000 r-xp 00000000 09:00 54591597   /lib/ld-2.9.so
 0055f000-00560000 r--p 00020000 09:00 54591597   /lib/ld-2.9.so
 00560000-00561000 rw-p 00021000 09:00 54591597   /lib/ld-2.9.so
 00563000-006d1000 r-xp 00000000 09:00 54591620   /lib/libc-2.9.so
 006d1000-006d3000 r--p 0016e000 09:00 54591620   /lib/libc-2.9.so
 006d3000-006d4000 rw-p 00170000 09:00 54591620   /lib/libc-2.9.so
 006d4000-006d7000 rw-p 006d4000 00:00 0 
 08048000-08054000 r-xp 00000000 09:00 27787363   /bin/cat
 08054000-08055000 rw-p 0000c000 09:00 27787363   /bin/cat
 09996000-099b7000 rw-p 09996000 00:00 0          [heap]
 b7db9000-b7fb9000 r--p 00000000 09:00 50364418   /usr/lib/locale/locale-archive
 b7fb9000-b7fbb000 rw-p b7fb9000 00:00 0 
 bffc7000-bffdc000 rw-p bffeb000 00:00 0          [stack]

I was the one who added the [stack], [heap] and [vdso] annotations a 
few years ago and user-space developers liked it very much.

Tools parsing these files wont break [they dont care about the final 
column] - so there's no ABI worries and we can certainly do more 
here and enhance it.

You extend the above output with (in essence):

> +#ifdef CONFIG_PROC_STACK
> +static inline void task_show_stack_usage(struct seq_file *m,
> +						struct task_struct *p)

It would be better to put this into a fresh, related feature that 
went upstream recently:

 spirit:~> cat /proc/self/stack
 [<ffffffff8101c333>] save_stack_trace_tsk+0x26/0x43
 [<ffffffff81129237>] proc_pid_stack+0x63/0xa1
 [<ffffffff8112a753>] proc_single_show+0x5c/0x79
 [<ffffffff810fb2d6>] seq_read+0x16f/0x34d
 [<ffffffff810e3eea>] vfs_read+0xab/0x108
 [<ffffffff810e4007>] sys_read+0x4a/0x6e
 [<ffffffff8101133a>] system_call_fastpath+0x16/0x1b
 [<ffffffffffffffff>] 0xffffffffffffffff

That displays the kernel stack data - and we could display 
information about the user-stack data as well.

This #ifdef:

> +#ifdef CONFIG_STACK_GROWSUP
> +	cur_stack = base_page-(p->stack_start >> PAGE_SHIFT);
> +#else
> +	cur_stack = (p->stack_start >> PAGE_SHIFT)-base_page;
> +#endif

Should be hidden in a task_user_stack() inline helper.

Another thing is:

> @@ -240,6 +240,18 @@
>  				} else if (vma->vm_start <= mm->start_stack &&
>  					   vma->vm_end >= mm->start_stack) {
>  					name = "[stack]";
> +#ifdef CONFIG_PROC_STACK
> +				} else {
> +					unsigned long stack_start;
> +
> +					stack_start =
> +						((struct proc_maps_private *)
> +						 m->private)->task->stack_start;
> +
> +					if (vma->vm_start <= stack_start && 
> +					    vma->vm_end >= stack_start)
> +						name="[thread stack]";
> +#endif

This too should be unconditional IMO (it's useful, and 
ultra-embedded systems worried about kernel .text size can turn off 
CONFIG_PROC_FS anyway), _and_ i think we could do even better.

How about extending /proc/X/maps with:

 b7db9000-b7fb9000 r--p 00000000 09:00 50364418   /usr/lib/locale/locale-archive
 b7fb9000-b7fbb000 rw-p b7fb9000 00:00 0 
 bffc7000-bffdc000 rw-p bffeb000 00:00 0          [stack, usage: 1391 kB]

This is deterministically parseable, and meaningful-at-a-glance. 
Similarly for 'thread stack'.

This way we dont need any new files in /proc - that just increases 
the per task memory overhead.

What do you think?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
