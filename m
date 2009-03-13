Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BA22D6B0047
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:37:22 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n2DHYjKL012443
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 11:34:45 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2DHbLlD199834
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 11:37:21 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2DHbJCK015670
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 11:37:20 -0600
Date: Fri, 13 Mar 2009 12:37:19 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090313173719.GA12179@us.ibm.com>
References: <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz> <20090226155755.GA1456@x200.localdomain> <20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr> <20090312145311.GC12390@us.ibm.com> <1236891719.32630.14.camel@bahia> <20090312212124.GA25019@us.ibm.com> <604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Greg Kurz <gkurz@fr.ibm.com>, Cedric Le Goater <legoater@free.fr>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mpm@selenic.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, tglx@linutronix.de, viro@zeniv.linux.org.uk, hpa@zytor.com, mingo@elte.hu, torvalds@linux-foundation.org, Alexey Dobriyan <adobriyan@gmail.com>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Quoting Ying Han (yinghan@google.com):
> Hi Serge:
> I made a patch based on Oren's tree recently which implement a new
> syscall clone_with_pid. I tested with checkpoint/restart process tree
> and it works as expected.
> This patch has some hack in it which i made a copy of libc's clone and
> made modifications of passing one more argument(pid number). I will
> try to clean up the code and do more testing.
> 
> New syscall clone_with_pid
> Implement a new syscall which clone a thread with a preselected pid number.
> 
> clone_with_pid(child_func, child_stack + CHILD_STACK - 16,
> 			CLONE_WITH_PID|SIGCHLD, pid, NULL);
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> 
> diff --git a/arch/x86/include/asm/syscalls.h b/arch/x86/include/asm/syscalls.h
> index 87803da..b5a1b03 100644
> --- a/arch/x86/include/asm/syscalls.h
> +++ b/arch/x86/include/asm/syscalls.h
> @@ -26,6 +26,7 @@ asmlinkage int sys_fork(struct pt_regs);
>  asmlinkage int sys_clone(struct pt_regs);
>  asmlinkage int sys_vfork(struct pt_regs);
>  asmlinkage int sys_execve(struct pt_regs);
> +asmlinkage int sys_clone_with_pid(struct pt_regs);
> 
>  /* kernel/signal_32.c */
>  asmlinkage int sys_sigsuspend(int, int, old_sigset_t);
> diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32
> index a5f9e09..f10ca0e 100644
> --- a/arch/x86/include/asm/unistd_32.h
> +++ b/arch/x86/include/asm/unistd_32.h
> @@ -340,6 +340,7 @@
>  #define __NR_inotify_init1	332
>  #define __NR_checkpoint		333
>  #define __NR_restart		334
> +#define __NR_clone_with_pid	335
> 
>  #ifdef __KERNEL__
> 
> diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
> index 0a1302f..88ae634 100644
> --- a/arch/x86/kernel/process_32.c
> +++ b/arch/x86/kernel/process_32.c
> @@ -8,7 +8,6 @@
>  /*
>   * This file handles the architecture-dependent parts of process handling..
>   */
> -
>  #include <stdarg.h>
> 
>  #include <linux/cpu.h>
> @@ -652,6 +651,28 @@ asmlinkage int sys_clone(struct pt_regs regs)
>  	return do_fork(clone_flags, newsp, &regs, 0, parent_tidptr, child_tidptr);
>  }
> 
> +/**
> + * sys_clone_with_pid - clone a thread with pre-select pid number.
> + */
> +asmlinkage int sys_clone_with_pid(struct pt_regs regs)
> +{
> +	unsigned long clone_flags;
> +	unsigned long newsp;
> +	int __user *parent_tidptr, *child_tidptr;
> +	pid_t pid_nr;
> +
> +	clone_flags = regs.bx;
> +	newsp = regs.cx;
> +	parent_tidptr = (int __user *)regs.dx;
> +	child_tidptr = (int __user *)regs.di;
> +	pid_nr = regs.bp;

Hi,

Thanks for looking at this.  I appreciate the patch.  Two comments
however.

As I was saying in another email, i think that so long as we are going
with a new syscall, we should make sure that it suffices for nested
pid namespaces.  So send in an array of pids and its lengths, then
use an algorithm like Alexey's to fill in the sent-in pids if possible.

> +	if (!newsp)
> +		newsp = regs.sp;
> +	return do_fork(clone_flags, newsp, &regs, pid_nr, parent_tidptr,
> +			child_tidptr);
> +}
> +
>  /*
>   * This is trivial, and on the face of it looks like it
>   * could equally well be done in user mode.

> diff --git a/kernel/fork.c b/kernel/fork.c
> index 085ce56..262ae1e 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -10,7 +10,7 @@
>   * Fork is rather simple, once you get the hang of it, but the memory
>   * management can be a bitch. See 'mm/memory.c': 'copy_page_range()'
>   */
> -
> +#define DEBUG
>  #include <linux/slab.h>
>  #include <linux/init.h>
>  #include <linux/unistd.h>
> @@ -959,10 +959,19 @@ static struct task_struct *copy_process(unsigned long cl
>  	int retval;
>  	struct task_struct *p;
>  	int cgroup_callbacks_done = 0;
> +	pid_t clone_pid = stack_size;

Note that some architectures (i.e. ia64) actually use the stack_size
sent to copy_thread, so you at least need to zero out stack_size here.

And I suspect there are cases where a stack_size is actually sent in,
so this doesn't seem legitimate, but I haven't tracked down the callers.
If you tell me you think there should be no case where a real stack_size
is sent in, well, I'll feel better if you prove it by breaking the patch
up so that:

1. you remove the stack_size argument from copy_process.  Test such a
kernel on some architectures (boot+ltp, for instance).

2. add a chosen_pid argument to copy_process.

Then we can be sure noone is using the field.

thanks,
-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
