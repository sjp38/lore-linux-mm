Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DA5736B0047
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 17:21:18 -0400 (EDT)
Subject: Re: Detailed Stack Information Patch [1/3]
From: Stefani Seibold <stefani@seibold.net>
In-Reply-To: <20090401193135.GA12316@elte.hu>
References: <1238511505.364.61.camel@matrix>
	 <20090401193135.GA12316@elte.hu>
Content-Type: text/plain
Date: Thu, 02 Apr 2009 23:26:52 +0200
Message-Id: <1238707612.3882.25.camel@matrix>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Joerg Engel <joern@logfs.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

Am Mittwoch, den 01.04.2009, 21:31 +0200 schrieb Ingo Molnar:
> * Stefani Seibold <stefani@seibold.net> wrote:
> 
> > diff -u -N -r linux-2.6.29.orig/fs/exec.c linux-2.6.29/fs/exec.c
> > --- linux-2.6.29.orig/fs/exec.c	2009-03-24 00:12:14.000000000 +0100
> > +++ linux-2.6.29/fs/exec.c	2009-03-31 16:02:55.000000000 +0200
> > @@ -1336,6 +1336,10 @@
> >  	if (retval < 0)
> >  		goto out;
> >  
> > +#ifdef CONFIG_PROC_STACK
> > +	current->stack_start = current->mm->start_stack;
> > +#endif
> 
> Ok. The 1/3 patch, the whole "display where the stack is" thing is 
> obviously useful and we know that.
> 
> Today we display this:
> 
>  earth4:~/tip> cat /proc/self/maps 
>  00110000-00111000 r-xp 00110000 00:00 0          [vdso]
>  0053e000-0055e000 r-xp 00000000 09:00 54591597   /lib/ld-2.9.so
>  .
>  .
>  .
>  bffc7000-bffdc000 rw-p bffeb000 00:00 0          [stack]
> 
> I was the one who added the [stack], [heap] and [vdso] annotations a 
> few years ago and user-space developers liked it very much.
> 
> Tools parsing these files wont break [they dont care about the final 
> column] - so there's no ABI worries and we can certainly do more 
> here and enhance it.
> 
> You extend the above output with (in essence):
> 
> > +#ifdef CONFIG_PROC_STACK
> > +static inline void task_show_stack_usage(struct seq_file *m,
> > +						struct task_struct *p)
> 
> It would be better to put this into a fresh, related feature that 
> went upstream recently:
> 
>  spirit:~> cat /proc/self/stack
>  [<ffffffff8101c333>] save_stack_trace_tsk+0x26/0x43
>  .
>  .
>  .
> That displays the kernel stack data - and we could display 
> information about the user-stack data as well.
> 

/proc/self/stack is a good place for a more detailed information,
like the start address of the stack, the current usage and the highest
used address.

> This #ifdef:
> 
> > +#ifdef CONFIG_STACK_GROWSUP
> > +	cur_stack = base_page-(p->stack_start >> PAGE_SHIFT);
> > +#else
> > +	cur_stack = (p->stack_start >> PAGE_SHIFT)-base_page;
> > +#endif
> 
> Should be hidden in a task_user_stack() inline helper.
> 

Yes, this is more readable.

> Another thing is:
> 
> > @@ -240,6 +240,18 @@
> >  				} else if (vma->vm_start <= mm->start_stack &&
> >  					   vma->vm_end >= mm->start_stack) {
> >  					name = "[stack]";
> > +#ifdef CONFIG_PROC_STACK
> > +				} else {
> > +					unsigned long stack_start;
> > +
> > +					stack_start =
> > +						((struct proc_maps_private *)
> > +						 m->private)->task->stack_start;
> > +
> > +					if (vma->vm_start <= stack_start && 
> > +					    vma->vm_end >= stack_start)
> > +						name="[thread stack]";
> > +#endif
> 
> This too should be unconditional IMO (it's useful, and 
> ultra-embedded systems worried about kernel .text size can turn off 
> CONFIG_PROC_FS anyway), _and_ i think we could do even better.
> 

The CONFIG_PROC_STACK thing was only for test. I prefer it as an "always
on" feature.

> How about extending /proc/X/maps with:
> 
>  b7db9000-b7fb9000 r--p 00000000 09:00 50364418   /usr/lib/locale/locale-archive
>  b7fb9000-b7fbb000 rw-p b7fb9000 00:00 0 
>  bffc7000-bffdc000 rw-p bffeb000 00:00 0          [stack, usage: 1391 kB]
> 
> This is deterministically parseable, and meaningful-at-a-glance. 
> Similarly for 'thread stack'.
> 

Good idea. Should i write a new patch for this or will be this your job?

> This way we dont need any new files in /proc - that just increases 
> the per task memory overhead.
> 
> What do you think?
> 
> 	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
