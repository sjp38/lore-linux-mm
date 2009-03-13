Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E22FD6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:13:04 -0400 (EDT)
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate5.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n2DHBtVT140596
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 17:11:55 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2DHBtgg3100910
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 17:11:55 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2DHBs7K009441
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 17:11:55 GMT
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
 do?
From: Greg Kurz <gkurz@fr.ibm.com>
In-Reply-To: <49BA7B60.60607@free.fr>
References: <1234467035.3243.538.camel@calx>
	 <1234475483.30155.194.camel@nimitz>
	 <20090212141014.2cd3d54d.akpm@linux-foundation.org>
	 <1234479845.30155.220.camel@nimitz>
	 <20090226155755.GA1456@x200.localdomain>
	 <20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr>
	 <20090312145311.GC12390@us.ibm.com> <1236891719.32630.14.camel@bahia>
	 <20090312212124.GA25019@us.ibm.com>
	 <604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>
	 <49BA7B60.60607@free.fr>
Content-Type: text/plain
Date: Fri, 13 Mar 2009 18:11:55 +0100
Message-Id: <1236964315.5193.10.camel@bahia>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Cedric Le Goater <legoater@free.fr>
Cc: Ying Han <yinghan@google.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mpm@selenic.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, tglx@linutronix.de, viro@zeniv.linux.org.uk, hpa@zytor.com, mingo@elte.hu, torvalds@linux-foundation.org, Alexey Dobriyan <adobriyan@gmail.com>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-03-13 at 16:27 +0100, Cedric Le Goater wrote:
> Ying Han wrote:
> > Hi Serge:
> > I made a patch based on Oren's tree recently which implement a new
> > syscall clone_with_pid. I tested with checkpoint/restart process tree
> > and it works as expected.
> > This patch has some hack in it which i made a copy of libc's clone and
> > made modifications of passing one more argument(pid number). I will
> > try to clean up the code and do more testing.
> 
> ok. 2 patches would also be interesting. one for the syscall and one
> for the kernel support (which might be acceptable)
> 
> > New syscall clone_with_pid
> > Implement a new syscall which clone a thread with a preselected pid number.
> 
> yes this definitely needed to restart a task/thread. we maintain an ugly 
> hack which stores a pid in the current task that will be used by the next 
> clone() call. 
> 

That's probably better as you say... but damned, sys_clone() is arch
dependant so much files to patch. :)

> > clone_with_pid(child_func, child_stack + CHILD_STACK - 16,
> > 			CLONE_WITH_PID|SIGCHLD, pid, NULL);
> 
> since you're introducing a new syscall, I don't see why you need a 
> CLONE_WITH_PID flag ?
> 
> (FYI, attached is my old attempt of clone_with_pid but that's too old)
> 
> [ ... ]
> 
> > +#define DEBUG
> >  #include <linux/slab.h>
> >  #include <linux/init.h>
> >  #include <linux/unistd.h>
> > @@ -959,10 +959,19 @@ static struct task_struct *copy_process(unsigned long cl
> >  	int retval;
> >  	struct task_struct *p;
> >  	int cgroup_callbacks_done = 0;
> > +	pid_t clone_pid = stack_size;
> > 
> >  	if ((clone_flags & (CLONE_NEWNS|CLONE_FS)) == (CLONE_NEWNS|CLONE_FS))
> >  		return ERR_PTR(-EINVAL);
> > 
> > +	/* We only allow the clone_with_pid when a new pid namespace is
> > +	 * created. FIXME: how to restrict it.
> > +	 */
> > +	if ((clone_flags & CLONE_NEWPID) && (clone_flags & CLONE_WITH_PID))
> > +		return ERR_PTR(-EINVAL);
> > +	if ((clone_flags & CLONE_WITH_PID) && (clone_pid <= 1))
> > +		return ERR_PTR(-EINVAL);
> 
> I would let alloc_pid() handle the error.
> 
> >  	/*
> >  	 * Thread groups must share signals as well, and detached threads
> >  	 * can only be started up within the thread group.
> > @@ -1135,7 +1144,10 @@ static struct task_struct *copy_process(unsigned long c
> > 
> >  	if (pid != &init_struct_pid) {
> >  		retval = -ENOMEM;
> > -		pid = alloc_pid(task_active_pid_ns(p));
> > +		if (clone_flags & CLONE_WITH_PID)
> > +			pid = alloc_pid(task_active_pid_ns(p), clone_pid);
> > +		else
> > +			pid = alloc_pid(task_active_pid_ns(p), 0);
> 
> this is overkill IMO.
> 
> [ ... ]
> 
> > -static int alloc_pidmap(struct pid_namespace *pid_ns)
> > +static int alloc_pidmap(struct pid_namespace *pid_ns, pid_t pid_nr)
> >  {
> >  	int i, offset, max_scan, pid, last = pid_ns->last_pid;
> >  	struct pidmap *map;
> > 
> > -	pid = last + 1;
> > +	if (pid_nr)
> > +		pid = pid_nr;
> > +	else
> > +		pid = last + 1;
> >
> >  	if (pid >= pid_max)
> >  		pid = RESERVED_PIDS;
> >  	offset = pid & BITS_PER_PAGE_MASK;
> > @@ -153,9 +156,12 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
> >  			do {
> >  				if (!test_and_set_bit(offset, map->page)) {
> >  					atomic_dec(&map->nr_free);
> > -					pid_ns->last_pid = pid;
> > +					if (!pid_nr)
> > +						pid_ns->last_pid = pid;
> >  					return pid;
> >  				}
> > +				if (pid_nr)
> > +					return -1;
> >  				offset = find_next_offset(map, offset);
> >  				pid = mk_pid(pid_ns, map, offset);
> >  			/*
> > @@ -239,21 +245,25 @@ void free_pid(struct pid *pid)
> >  	call_rcu(&pid->rcu, delayed_put_pid);
> >  }
> > 
> > -struct pid *alloc_pid(struct pid_namespace *ns)
> > +struct pid *alloc_pid(struct pid_namespace *ns, pid_t pid_nr)
> >  {
> >  	struct pid *pid;
> >  	enum pid_type type;
> >  	int i, nr;
> >  	struct pid_namespace *tmp;
> >  	struct upid *upid;
> > +	int level = ns->level;
> > +
> > +	if (pid_nr >= pid_max)
> > +		return NULL;
> 
> let alloc_pidmap() handle it ? 
> 
> > 
> >  	pid = kmem_cache_alloc(ns->pid_cachep, GFP_KERNEL);
> >  	if (!pid)
> >  		goto out;
> > 
> > -	tmp = ns;
> > -	for (i = ns->level; i >= 0; i--) {
> > -		nr = alloc_pidmap(tmp);
> > +	tmp = ns->parent;
> > +	for (i = level-1; i >= 0; i--) {
> > +		nr = alloc_pidmap(tmp, 0);
> >  		if (nr < 0)
> >  			goto out_free;
> > 
> > @@ -262,6 +272,14 @@ struct pid *alloc_pid(struct pid_namespace *ns)
> >  		tmp = tmp->parent;
> >  	}
> > 
> > +	nr = alloc_pidmap(ns, pid_nr);
> > +	if (nr < 0)
> > +		goto out_free;
> > +	pid->numbers[level].nr = nr;
> > +	pid->numbers[level].ns = ns;
> > +	if (nr == pid_nr)
> > +		pr_debug("nr == pid_nr == %d\n", nr);
> > +
> >  	get_pid_ns(ns);
> >  	pid->level = ns->level;
> >  	atomic_set(&pid->count, 1);
> > 
> > 
> > 
> > 
> > 
> > 
> > 
> > 
> > On Thu, Mar 12, 2009 at 2:21 PM, Serge E. Hallyn <serue@us.ibm.com> wrote:
> >> Quoting Greg Kurz (gkurz@fr.ibm.com):
> >>> On Thu, 2009-03-12 at 09:53 -0500, Serge E. Hallyn wrote:
> >>>> Or are you suggesting that you'll do a dummy clone of (5594,2) so that
> >>>> the next clone(CLONE_NEWPID) will be expected to be (5594,3,1)?
> >>>>
> >>> Of course not
> >> Ok - someone *did* argue that at some point I think...
> >>
> >>> but one should be able to tell clone() to pick a specific
> >>> pid.
> >> Can you explain exactly how?  I must be missing something clever.
> >>
> >> -serge
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> plain text document attachment (clone_with_pid.patch)
> Subject: [RFC] forkpid() syscall
> 
> From: Cedric Le Goater <clg@fr.ibm.com>
> 
> let's the user specify a pid to fork and return EBUSY if the pid is
> not available.
> 
> this patch includes a alloc_pid*() cleanup on the way errors are 
> returned that could be pushed to mainline independently.
> 
> usage :
> 
>     #include <sys/syscall.h>
> 
>     #define __NR_forkpid 	324
> 
>     static inline int forkpid(int pid)
>     {
> 	  return syscall(__NR_forkpid, pid);
>     }
>     
> caveats : 
> 	fork oriented, should also cover clone
> 	i386 only
> 	does not cover 64 bits clone flags
> 
> 
> Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
> ---
>  arch/i386/kernel/process.c       |   15 +++++++++++----
>  arch/i386/kernel/syscall_table.S |    1 +
>  include/asm-i386/unistd.h        |    3 ++-
>  include/linux/pid.h              |    2 +-
>  include/linux/sched.h            |    2 +-
>  kernel/fork.c                    |    9 +++++----
>  kernel/pid.c                     |   28 +++++++++++++++-------------
>  7 files changed, 36 insertions(+), 24 deletions(-)
> 
> Index: 2.6.22/kernel/pid.c
> ===================================================================
> --- 2.6.22.orig/kernel/pid.c
> +++ 2.6.22/kernel/pid.c
> @@ -96,12 +96,12 @@ static fastcall void free_pidmap(struct 
>  	atomic_inc(&map->nr_free);
>  }
> 
> -static int alloc_pidmap(struct pid_namespace *pid_ns)
> +static int alloc_pidmap(struct pid_namespace *pid_ns, pid_t upid)
>  {
>  	int i, offset, max_scan, pid, last = pid_ns->last_pid;
>  	struct pidmap *map;
> 
> -	pid = last + 1;
> +	pid = upid ? upid : last + 1;
>  	if (pid >= pid_max)
>  		pid = RESERVED_PIDS;
>  	offset = pid & BITS_PER_PAGE_MASK;
> @@ -130,6 +130,8 @@ static int alloc_pidmap(struct pid_names
>  					pid_ns->last_pid = pid;
>  					return pid;
>  				}
> +				if (upid)
> +					return -EBUSY;
>  				offset = find_next_offset(map, offset);
>  				pid = mk_pid(pid_ns, map, offset);
>  			/*
> @@ -153,7 +155,7 @@ static int alloc_pidmap(struct pid_names
>  		}
>  		pid = mk_pid(pid_ns, map, offset);
>  	}
> -	return -1;
> +	return -EAGAIN;
>  }
> 
>  static int next_pidmap(struct pid_namespace *pid_ns, int last)
> @@ -203,19 +205,24 @@ fastcall void free_pid(struct pid *pid)
>  	call_rcu(&pid->rcu, delayed_put_pid);
>  }
> 
> -struct pid *alloc_pid(void)
> +struct pid *alloc_pid(pid_t upid)
>  {
>  	struct pid *pid;
>  	enum pid_type type;
>  	int nr = -1;
> 
>  	pid = kmem_cache_alloc(pid_cachep, GFP_KERNEL);
> -	if (!pid)
> +	if (!pid) {
> +		pid = ERR_PTR(-ENOMEM);
>  		goto out;
> +	}
> 
> -	nr = alloc_pidmap(current->nsproxy->pid_ns);
> -	if (nr < 0)
> -		goto out_free;
> +	nr = alloc_pidmap(current->nsproxy->pid_ns, upid);
> +	if (nr < 0) {
> +		kmem_cache_free(pid_cachep, pid);
> +		pid = ERR_PTR(nr);
> +		goto out;
> +	}
> 
>  	atomic_set(&pid->count, 1);
>  	pid->nr = nr;
> @@ -228,11 +235,6 @@ struct pid *alloc_pid(void)
> 
>  out:
>  	return pid;
> -
> -out_free:
> -	kmem_cache_free(pid_cachep, pid);
> -	pid = NULL;
> -	goto out;
>  }
> 
>  struct pid * fastcall find_pid(int nr)
> Index: 2.6.22/arch/i386/kernel/process.c
> ===================================================================
> --- 2.6.22.orig/arch/i386/kernel/process.c
> +++ 2.6.22/arch/i386/kernel/process.c
> @@ -355,7 +355,7 @@ int kernel_thread(int (*fn)(void *), voi
>  	regs.eflags = X86_EFLAGS_IF | X86_EFLAGS_SF | X86_EFLAGS_PF | 0x2;
> 
>  	/* Ok, create the new process.. */
> -	return do_fork(flags | CLONE_VM | CLONE_UNTRACED, 0, &regs, 0, NULL, NULL);
> +	return do_fork(flags | CLONE_VM | CLONE_UNTRACED, 0, &regs, 0, NULL, NULL, 0);
>  }
>  EXPORT_SYMBOL(kernel_thread);
> 
> @@ -722,9 +722,16 @@ struct task_struct fastcall * __switch_t
>  	return prev_p;
>  }
> 
> +asmlinkage int sys_forkpid(struct pt_regs regs)
> +{
> +	pid_t pid = regs.ebx;
> +
> +	return do_fork(SIGCHLD, regs.esp, &regs, 0, NULL, NULL, pid);
> +}
> +
>  asmlinkage int sys_fork(struct pt_regs regs)
>  {
> -	return do_fork(SIGCHLD, regs.esp, &regs, 0, NULL, NULL);
> +	return do_fork(SIGCHLD, regs.esp, &regs, 0, NULL, NULL, 0);
>  }
> 
>  asmlinkage int sys_clone(struct pt_regs regs)
> @@ -739,7 +746,7 @@ asmlinkage int sys_clone(struct pt_regs 
>  	child_tidptr = (int __user *)regs.edi;
>  	if (!newsp)
>  		newsp = regs.esp;
> -	return do_fork(clone_flags, newsp, &regs, 0, parent_tidptr, child_tidptr);
> +	return do_fork(clone_flags, newsp, &regs, 0, parent_tidptr, child_tidptr, 0);
>  }
> 
>  /*
> @@ -754,7 +761,7 @@ asmlinkage int sys_clone(struct pt_regs 
>   */
>  asmlinkage int sys_vfork(struct pt_regs regs)
>  {
> -	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, regs.esp, &regs, 0, NULL, NULL);
> +	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, regs.esp, &regs, 0, NULL, NULL, 0);
>  }
> 
>  /*
> Index: 2.6.22/arch/i386/kernel/syscall_table.S
> ===================================================================
> --- 2.6.22.orig/arch/i386/kernel/syscall_table.S
> +++ 2.6.22/arch/i386/kernel/syscall_table.S
> @@ -323,3 +323,4 @@ ENTRY(sys_call_table)
>  	.long sys_signalfd
>  	.long sys_timerfd
>  	.long sys_eventfd
> +	.long sys_forkpid
> Index: 2.6.22/include/asm-i386/unistd.h
> ===================================================================
> --- 2.6.22.orig/include/asm-i386/unistd.h
> +++ 2.6.22/include/asm-i386/unistd.h
> @@ -329,10 +329,11 @@
>  #define __NR_signalfd		321
>  #define __NR_timerfd		322
>  #define __NR_eventfd		323
> +#define __NR_forkpid		324
> 
>  #ifdef __KERNEL__
> 
> -#define NR_syscalls 324
> +#define NR_syscalls 325
> 
>  #define __ARCH_WANT_IPC_PARSE_VERSION
>  #define __ARCH_WANT_OLD_READDIR
> Index: 2.6.22/kernel/fork.c
> ===================================================================
> --- 2.6.22.orig/kernel/fork.c
> +++ 2.6.22/kernel/fork.c
> @@ -1358,15 +1358,16 @@ long do_fork(unsigned long clone_flags,
>  	      struct pt_regs *regs,
>  	      unsigned long stack_size,
>  	      int __user *parent_tidptr,
> -	      int __user *child_tidptr)
> +	      int __user *child_tidptr,
> +	      pid_t upid)
>  {
>  	struct task_struct *p;
>  	int trace = 0;
> -	struct pid *pid = alloc_pid();
> +	struct pid *pid = alloc_pid(upid);
>  	long nr;
> 
> -	if (!pid)
> -		return -EAGAIN;
> +	if (IS_ERR(pid))
> +		return PTR_ERR(pid);
>  	nr = pid->nr;
>  	if (unlikely(current->ptrace)) {
>  		trace = fork_traceflag (clone_flags);
> Index: 2.6.22/include/linux/sched.h
> ===================================================================
> --- 2.6.22.orig/include/linux/sched.h
> +++ 2.6.22/include/linux/sched.h
> @@ -1433,7 +1433,7 @@ extern int allow_signal(int);
>  extern int disallow_signal(int);
> 
>  extern int do_execve(char *, char __user * __user *, char __user * __user *, struct pt_regs *);
> -extern long do_fork(unsigned long, unsigned long, struct pt_regs *, unsigned long, int __user *, int __user *);
> +extern long do_fork(unsigned long, unsigned long, struct pt_regs *, unsigned long, int __user *, int __user *, pid_t);
>  struct task_struct *fork_idle(int);
> 
>  extern void set_task_comm(struct task_struct *tsk, char *from);
> Index: 2.6.22/include/linux/pid.h
> ===================================================================
> --- 2.6.22.orig/include/linux/pid.h
> +++ 2.6.22/include/linux/pid.h
> @@ -95,7 +95,7 @@ extern struct pid *FASTCALL(find_pid(int
>  extern struct pid *find_get_pid(int nr);
>  extern struct pid *find_ge_pid(int nr);
> 
> -extern struct pid *alloc_pid(void);
> +extern struct pid *alloc_pid(pid_t upid);
>  extern void FASTCALL(free_pid(struct pid *pid));
> 
>  static inline pid_t pid_nr(struct pid *pid)
-- 
Gregory Kurz                                     gkurz@fr.ibm.com
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
