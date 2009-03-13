Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 544D06B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 01:36:51 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n2D5ZWeF022576
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:35:32 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2D5anoG228974
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:36:49 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2D5am4S001598
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:36:49 -0600
Date: Thu, 12 Mar 2009 22:34:58 -0700
From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090313053458.GA28833@us.ibm.com>
References: <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz> <20090226155755.GA1456@x200.localdomain> <20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr> <20090312145311.GC12390@us.ibm.com> <1236891719.32630.14.camel@bahia> <20090312212124.GA25019@us.ibm.com> <604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mingo@elte.hu, mpm@selenic.com, Andrew Morton <akpm@linux-foundation.org>, xemul@openvz.org, torvalds@linux-foundation.org, tglx@linutronix.de, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

Ying Han [yinghan@google.com] wrote:
| Hi Serge:
| I made a patch based on Oren's tree recently which implement a new
| syscall clone_with_pid. I tested with checkpoint/restart process tree
| and it works as expected.

Yes, I think we had a version of clone() with pid a while ago.

But it would be easier to review if you break it up into smaller
patches. and remove the unnecessary diffs in this patch like...


| This patch has some hack in it which i made a copy of libc's clone and
| made modifications of passing one more argument(pid number). I will
| try to clean up the code and do more testing.
| 
| New syscall clone_with_pid
| Implement a new syscall which clone a thread with a preselected pid number.
| 
| clone_with_pid(child_func, child_stack + CHILD_STACK - 16,
| 			CLONE_WITH_PID|SIGCHLD, pid, NULL);
| 
| Signed-off-by: Ying Han <yinghan@google.com>
| 
| diff --git a/arch/x86/include/asm/syscalls.h b/arch/x86/include/asm/syscalls.h
| index 87803da..b5a1b03 100644
| --- a/arch/x86/include/asm/syscalls.h
| +++ b/arch/x86/include/asm/syscalls.h
| @@ -26,6 +26,7 @@ asmlinkage int sys_fork(struct pt_regs);
|  asmlinkage int sys_clone(struct pt_regs);
|  asmlinkage int sys_vfork(struct pt_regs);
|  asmlinkage int sys_execve(struct pt_regs);
| +asmlinkage int sys_clone_with_pid(struct pt_regs);
| 
|  /* kernel/signal_32.c */
|  asmlinkage int sys_sigsuspend(int, int, old_sigset_t);
| diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32
| index a5f9e09..f10ca0e 100644
| --- a/arch/x86/include/asm/unistd_32.h
| +++ b/arch/x86/include/asm/unistd_32.h
| @@ -340,6 +340,7 @@
|  #define __NR_inotify_init1	332
|  #define __NR_checkpoint		333
|  #define __NR_restart		334
| +#define __NR_clone_with_pid	335
| 
|  #ifdef __KERNEL__
| 
| diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
| index 0a1302f..88ae634 100644
| --- a/arch/x86/kernel/process_32.c
| +++ b/arch/x86/kernel/process_32.c
| @@ -8,7 +8,6 @@
|  /*
|   * This file handles the architecture-dependent parts of process handling..
|   */
| -

these

|  #include <stdarg.h>
| 
|  #include <linux/cpu.h>
| @@ -652,6 +651,28 @@ asmlinkage int sys_clone(struct pt_regs regs)
|  	return do_fork(clone_flags, newsp, &regs, 0, parent_tidptr, child_tidptr);
|  }
| 
| +/**
| + * sys_clone_with_pid - clone a thread with pre-select pid number.
| + */
| +asmlinkage int sys_clone_with_pid(struct pt_regs regs)
| +{
| +	unsigned long clone_flags;
| +	unsigned long newsp;
| +	int __user *parent_tidptr, *child_tidptr;
| +	pid_t pid_nr;
| +
| +	clone_flags = regs.bx;
| +	newsp = regs.cx;
| +	parent_tidptr = (int __user *)regs.dx;
| +	child_tidptr = (int __user *)regs.di;
| +	pid_nr = regs.bp;
| +
| +	if (!newsp)
| +		newsp = regs.sp;
| +	return do_fork(clone_flags, newsp, &regs, pid_nr, parent_tidptr,
| +			child_tidptr);
| +}
| +
|  /*
|   * This is trivial, and on the face of it looks like it
|   * could equally well be done in user mode.
| diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_tabl
| index 5543136..5191117 100644
| --- a/arch/x86/kernel/syscall_table_32.S
| +++ b/arch/x86/kernel/syscall_table_32.S
| @@ -334,3 +334,4 @@ ENTRY(sys_call_table)
|  	.long sys_inotify_init1
|  	.long sys_checkpoint
|  	.long sys_restart
| +	.long sys_clone_with_pid
| diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
| index 50bde9a..a4aee65 100644
| --- a/arch/x86/mm/checkpoint.c
| +++ b/arch/x86/mm/checkpoint.c
| @@ -7,7 +7,6 @@
|   *  License.  See the file COPYING in the main directory of the Linux
|   *  distribution for more details.
|   */
| -
|  #include <asm/desc.h>
|  #include <asm/i387.h>
| 
| diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
| index 64155de..b7de611 100644
| --- a/checkpoint/checkpoint.c
| +++ b/checkpoint/checkpoint.c
| @@ -8,6 +8,7 @@
|   *  distribution for more details.
|   */
| 
| +#define DEBUG
|  #include <linux/version.h>
|  #include <linux/sched.h>
|  #include <linux/ptrace.h>
| @@ -564,3 +565,4 @@ int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
|   out:
|  	return ret;
|  }
| +
| diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
| index e3097ac..a8c5ad5 100644
| --- a/checkpoint/ckpt_file.c
| +++ b/checkpoint/ckpt_file.c
| @@ -7,7 +7,7 @@
|   *  License.  See the file COPYING in the main directory of the Linux
|   *  distribution for more details.
|   */
| -
| +#define DEBUG
|  #include <linux/kernel.h>
|  #include <linux/sched.h>
|  #include <linux/file.h>
| diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
| index 4925ff2..ca5840b 100644
| --- a/checkpoint/ckpt_mem.c
| +++ b/checkpoint/ckpt_mem.c
| @@ -7,7 +7,7 @@
|   *  License.  See the file COPYING in the main directory of the Linux
|   *  distribution for more details.
|   */
| -
| +#define DEBUG
|  #include <linux/kernel.h>
|  #include <linux/sched.h>
|  #include <linux/slab.h>
| diff --git a/checkpoint/restart.c b/checkpoint/restart.c
| index 7ec4de4..30e43c2 100644
| --- a/checkpoint/restart.c
| +++ b/checkpoint/restart.c
| @@ -8,6 +8,7 @@
|   *  distribution for more details.
|   */
| 
| +#define DEBUG
|  #include <linux/version.h>
|  #include <linux/sched.h>
|  #include <linux/wait.h>
| @@ -242,7 +243,7 @@ static int cr_read_task_struct(struct cr_ctx *ctx)
|  		memcpy(t->comm, buf, min(hh->task_comm_len, TASK_COMM_LEN));
|  	}
|  	kfree(buf);
| -
| +	pr_debug("read task %s\n", t->comm);
|  	/* FIXME: restore remaining relevant task_struct fields */
|   out:
|  	cr_hbuf_put(ctx, sizeof(*hh));
| diff --git a/checkpoint/rstr_file.c b/checkpoint/rstr_file.c
| index f44b081..755e40e 100644
| --- a/checkpoint/rstr_file.c
| +++ b/checkpoint/rstr_file.c
| @@ -7,7 +7,7 @@
|   *  License.  See the file COPYING in the main directory of the Linux
|   *  distribution for more details.
|   */
| -
| +#define DEBUG
|  #include <linux/kernel.h>
|  #include <linux/sched.h>
|  #include <linux/fs.h>
| diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
| index 4d5ce1a..8330468 100644
| --- a/checkpoint/rstr_mem.c
| +++ b/checkpoint/rstr_mem.c
| @@ -7,7 +7,7 @@
|   *  License.  See the file COPYING in the main directory of the Linux
|   *  distribution for more details.
|   */
| -
| +#define DEBUG
|  #include <linux/kernel.h>
|  #include <linux/sched.h>
|  #include <linux/fcntl.h>
| diff --git a/checkpoint/sys.c b/checkpoint/sys.c
| index f26b0c6..d1a5394 100644
| --- a/checkpoint/sys.c
| +++ b/checkpoint/sys.c
| @@ -7,7 +7,7 @@
|   *  License.  See the file COPYING in the main directory of the Linux
|   *  distribution for more details.
|   */
| -
| +#define DEBUG
|  #include <linux/sched.h>
|  #include <linux/nsproxy.h>
|  #include <linux/kernel.h>
| @@ -263,7 +263,6 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned
|  		return PTR_ERR(ctx);
| 
|  	ret = do_checkpoint(ctx, pid);
| -
|  	if (!ret)
|  		ret = ctx->crid;
| 
| @@ -304,3 +303,4 @@ asmlinkage long sys_restart(int crid, int fd, unsigned lon
|  	cr_ctx_put(ctx);
|  	return ret;
|  }
| +
| diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
| index 217cf6e..bc2c202 100644
| --- a/include/linux/checkpoint.h
| +++ b/include/linux/checkpoint.h
| @@ -114,7 +114,6 @@ extern int cr_write_files(struct cr_ctx *ctx, struct task_
|  extern int do_restart(struct cr_ctx *ctx, pid_t pid);
|  extern int cr_read_mm(struct cr_ctx *ctx);
|  extern int cr_read_files(struct cr_ctx *ctx);
| -
|  #ifdef pr_fmt
|  #undef pr_fmt
|  #endif
| diff --git a/include/linux/pid.h b/include/linux/pid.h
| index d7e98ff..86e2f61 100644
| --- a/include/linux/pid.h
| +++ b/include/linux/pid.h
| @@ -119,7 +119,7 @@ extern struct pid *find_get_pid(int nr);
|  extern struct pid *find_ge_pid(int nr, struct pid_namespace *);
|  int next_pidmap(struct pid_namespace *pid_ns, int last);
| 
| -extern struct pid *alloc_pid(struct pid_namespace *ns);
| +extern struct pid *alloc_pid(struct pid_namespace *ns, pid_t pid_nr);
|  extern void free_pid(struct pid *pid);
| 
|  /*
| diff --git a/include/linux/sched.h b/include/linux/sched.h
| index 0150e90..7fb4e28 100644
| --- a/include/linux/sched.h
| +++ b/include/linux/sched.h
| @@ -28,6 +28,7 @@
|  #define CLONE_NEWPID		0x20000000	/* New pid namespace */
|  #define CLONE_NEWNET		0x40000000	/* New network namespace */
|  #define CLONE_IO		0x80000000	/* Clone io context */
| +#define CLONE_WITH_PID		0x00001000	/* Clone with pre-select PID */
| 
|  /*
|   * Scheduling policies
| diff --git a/kernel/exit.c b/kernel/exit.c
| index 2d8be7e..4baf651 100644
| --- a/kernel/exit.c
| +++ b/kernel/exit.c
| @@ -3,7 +3,7 @@
|   *
|   *  Copyright (C) 1991, 1992  Linus Torvalds
|   */
| -
| +#define DEBUG
|  #include <linux/mm.h>
|  #include <linux/slab.h>
|  #include <linux/interrupt.h>
| @@ -1676,6 +1676,7 @@ static long do_wait(enum pid_type type, struct pid *pid,
|  	DECLARE_WAITQUEUE(wait, current);
|  	struct task_struct *tsk;
|  	int retval;
| +	int level;

and this (level is not used).
| 
|  	trace_sched_process_wait(pid);
| 
| @@ -1708,7 +1709,6 @@ repeat:
|  			retval = tsk_result;
|  			goto end;
|  		}
| -
|  		if (options & __WNOTHREAD)
|  			break;
|  		tsk = next_thread(tsk);
| @@ -1817,7 +1817,6 @@ asmlinkage long sys_wait4(pid_t upid, int __user *stat_a
|  		type = PIDTYPE_PID;
|  		pid = find_get_pid(upid);
|  	}
| -
|  	ret = do_wait(type, pid, options | WEXITED, NULL, stat_addr, ru);
|  	put_pid(pid);
| 
| diff --git a/kernel/fork.c b/kernel/fork.c
| index 085ce56..262ae1e 100644
| --- a/kernel/fork.c
| +++ b/kernel/fork.c
| @@ -10,7 +10,7 @@
|   * Fork is rather simple, once you get the hang of it, but the memory
|   * management can be a bitch. See 'mm/memory.c': 'copy_page_range()'
|   */
| -
| +#define DEBUG
|  #include <linux/slab.h>
|  #include <linux/init.h>
|  #include <linux/unistd.h>
| @@ -959,10 +959,19 @@ static struct task_struct *copy_process(unsigned long cl
|  	int retval;
|  	struct task_struct *p;
|  	int cgroup_callbacks_done = 0;
| +	pid_t clone_pid = stack_size;
| 
|  	if ((clone_flags & (CLONE_NEWNS|CLONE_FS)) == (CLONE_NEWNS|CLONE_FS))
|  		return ERR_PTR(-EINVAL);
| 
| +	/* We only allow the clone_with_pid when a new pid namespace is
| +	 * created. FIXME: how to restrict it.

Not sure why CLONE_NEWPID is required to set pid_nr. In fact with CLONE_NEWPID,
by definition, pid_nr should be 1. Also, what happens if a container has
more than one process - where the second process has a pid_nr > 2 ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
