Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BBA0A6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 02:19:51 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id n2D6Jjb5011866
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 06:19:46 GMT
Received: from qyk17 (qyk17.prod.google.com [10.241.83.145])
	by wpaz13.hot.corp.google.com with ESMTP id n2D6Jhq0017649
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:19:44 -0700
Received: by qyk17 with SMTP id 17so32754qyk.10
        for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:19:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090313053458.GA28833@us.ibm.com>
References: <1234475483.30155.194.camel@nimitz>
	 <1234479845.30155.220.camel@nimitz>
	 <20090226155755.GA1456@x200.localdomain>
	 <20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr>
	 <20090312145311.GC12390@us.ibm.com> <1236891719.32630.14.camel@bahia>
	 <20090312212124.GA25019@us.ibm.com>
	 <604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>
	 <20090313053458.GA28833@us.ibm.com>
Date: Thu, 12 Mar 2009 23:19:43 -0700
Message-ID: <604427e00903122319y4d98ffc3ub62547960181a2bf@mail.gmail.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mingo@elte.hu, mpm@selenic.com, Andrew Morton <akpm@linux-foundation.org>, xemul@openvz.org, torvalds@linux-foundation.org, tglx@linutronix.de, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

Thank you Sukadev for your comments. I will try to clean up my patch
and repost it.

--Ying

On Thu, Mar 12, 2009 at 10:34 PM, Sukadev Bhattiprolu
<sukadev@linux.vnet.ibm.com> wrote:
> Ying Han [yinghan@google.com] wrote:
> | Hi Serge:
> | I made a patch based on Oren's tree recently which implement a new
> | syscall clone_with_pid. I tested with checkpoint/restart process tree
> | and it works as expected.
>
> Yes, I think we had a version of clone() with pid a while ago.
>
> But it would be easier to review if you break it up into smaller
> patches. and remove the unnecessary diffs in this patch like...
>
>
> | This patch has some hack in it which i made a copy of libc's clone and
> | made modifications of passing one more argument(pid number). I will
> | try to clean up the code and do more testing.
> |
> | New syscall clone_with_pid
> | Implement a new syscall which clone a thread with a preselected pid num=
ber.
> |
> | clone_with_pid(child_func, child_stack + CHILD_STACK - 16,
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CLONE_WITH_PID|SIGCHLD, pid=
, NULL);
> |
> | Signed-off-by: Ying Han <yinghan@google.com>
> |
> | diff --git a/arch/x86/include/asm/syscalls.h b/arch/x86/include/asm/sys=
calls.h
> | index 87803da..b5a1b03 100644
> | --- a/arch/x86/include/asm/syscalls.h
> | +++ b/arch/x86/include/asm/syscalls.h
> | @@ -26,6 +26,7 @@ asmlinkage int sys_fork(struct pt_regs);
> | =A0asmlinkage int sys_clone(struct pt_regs);
> | =A0asmlinkage int sys_vfork(struct pt_regs);
> | =A0asmlinkage int sys_execve(struct pt_regs);
> | +asmlinkage int sys_clone_with_pid(struct pt_regs);
> |
> | =A0/* kernel/signal_32.c */
> | =A0asmlinkage int sys_sigsuspend(int, int, old_sigset_t);
> | diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/un=
istd_32
> | index a5f9e09..f10ca0e 100644
> | --- a/arch/x86/include/asm/unistd_32.h
> | +++ b/arch/x86/include/asm/unistd_32.h
> | @@ -340,6 +340,7 @@
> | =A0#define __NR_inotify_init1 =A0 332
> | =A0#define __NR_checkpoint =A0 =A0 =A0 =A0 =A0 =A0 =A0333
> | =A0#define __NR_restart =A0 =A0 =A0 =A0 334
> | +#define __NR_clone_with_pid =A0335
> |
> | =A0#ifdef __KERNEL__
> |
> | diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.=
c
> | index 0a1302f..88ae634 100644
> | --- a/arch/x86/kernel/process_32.c
> | +++ b/arch/x86/kernel/process_32.c
> | @@ -8,7 +8,6 @@
> | =A0/*
> | =A0 * This file handles the architecture-dependent parts of process han=
dling..
> | =A0 */
> | -
>
> these
>
> | =A0#include <stdarg.h>
> |
> | =A0#include <linux/cpu.h>
> | @@ -652,6 +651,28 @@ asmlinkage int sys_clone(struct pt_regs regs)
> | =A0 =A0 =A0 return do_fork(clone_flags, newsp, &regs, 0, parent_tidptr,=
 child_tidptr);
> | =A0}
> |
> | +/**
> | + * sys_clone_with_pid - clone a thread with pre-select pid number.
> | + */
> | +asmlinkage int sys_clone_with_pid(struct pt_regs regs)
> | +{
> | + =A0 =A0 unsigned long clone_flags;
> | + =A0 =A0 unsigned long newsp;
> | + =A0 =A0 int __user *parent_tidptr, *child_tidptr;
> | + =A0 =A0 pid_t pid_nr;
> | +
> | + =A0 =A0 clone_flags =3D regs.bx;
> | + =A0 =A0 newsp =3D regs.cx;
> | + =A0 =A0 parent_tidptr =3D (int __user *)regs.dx;
> | + =A0 =A0 child_tidptr =3D (int __user *)regs.di;
> | + =A0 =A0 pid_nr =3D regs.bp;
> | +
> | + =A0 =A0 if (!newsp)
> | + =A0 =A0 =A0 =A0 =A0 =A0 newsp =3D regs.sp;
> | + =A0 =A0 return do_fork(clone_flags, newsp, &regs, pid_nr, parent_tidp=
tr,
> | + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 child_tidptr);
> | +}
> | +
> | =A0/*
> | =A0 * This is trivial, and on the face of it looks like it
> | =A0 * could equally well be done in user mode.
> | diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/sysca=
ll_tabl
> | index 5543136..5191117 100644
> | --- a/arch/x86/kernel/syscall_table_32.S
> | +++ b/arch/x86/kernel/syscall_table_32.S
> | @@ -334,3 +334,4 @@ ENTRY(sys_call_table)
> | =A0 =A0 =A0 .long sys_inotify_init1
> | =A0 =A0 =A0 .long sys_checkpoint
> | =A0 =A0 =A0 .long sys_restart
> | + =A0 =A0 .long sys_clone_with_pid
> | diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
> | index 50bde9a..a4aee65 100644
> | --- a/arch/x86/mm/checkpoint.c
> | +++ b/arch/x86/mm/checkpoint.c
> | @@ -7,7 +7,6 @@
> | =A0 * =A0License. =A0See the file COPYING in the main directory of the =
Linux
> | =A0 * =A0distribution for more details.
> | =A0 */
> | -
> | =A0#include <asm/desc.h>
> | =A0#include <asm/i387.h>
> |
> | diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> | index 64155de..b7de611 100644
> | --- a/checkpoint/checkpoint.c
> | +++ b/checkpoint/checkpoint.c
> | @@ -8,6 +8,7 @@
> | =A0 * =A0distribution for more details.
> | =A0 */
> |
> | +#define DEBUG
> | =A0#include <linux/version.h>
> | =A0#include <linux/sched.h>
> | =A0#include <linux/ptrace.h>
> | @@ -564,3 +565,4 @@ int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
> | =A0 out:
> | =A0 =A0 =A0 return ret;
> | =A0}
> | +
> | diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
> | index e3097ac..a8c5ad5 100644
> | --- a/checkpoint/ckpt_file.c
> | +++ b/checkpoint/ckpt_file.c
> | @@ -7,7 +7,7 @@
> | =A0 * =A0License. =A0See the file COPYING in the main directory of the =
Linux
> | =A0 * =A0distribution for more details.
> | =A0 */
> | -
> | +#define DEBUG
> | =A0#include <linux/kernel.h>
> | =A0#include <linux/sched.h>
> | =A0#include <linux/file.h>
> | diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
> | index 4925ff2..ca5840b 100644
> | --- a/checkpoint/ckpt_mem.c
> | +++ b/checkpoint/ckpt_mem.c
> | @@ -7,7 +7,7 @@
> | =A0 * =A0License. =A0See the file COPYING in the main directory of the =
Linux
> | =A0 * =A0distribution for more details.
> | =A0 */
> | -
> | +#define DEBUG
> | =A0#include <linux/kernel.h>
> | =A0#include <linux/sched.h>
> | =A0#include <linux/slab.h>
> | diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> | index 7ec4de4..30e43c2 100644
> | --- a/checkpoint/restart.c
> | +++ b/checkpoint/restart.c
> | @@ -8,6 +8,7 @@
> | =A0 * =A0distribution for more details.
> | =A0 */
> |
> | +#define DEBUG
> | =A0#include <linux/version.h>
> | =A0#include <linux/sched.h>
> | =A0#include <linux/wait.h>
> | @@ -242,7 +243,7 @@ static int cr_read_task_struct(struct cr_ctx *ctx)
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(t->comm, buf, min(hh->task_comm_len,=
 TASK_COMM_LEN));
> | =A0 =A0 =A0 }
> | =A0 =A0 =A0 kfree(buf);
> | -
> | + =A0 =A0 pr_debug("read task %s\n", t->comm);
> | =A0 =A0 =A0 /* FIXME: restore remaining relevant task_struct fields */
> | =A0 out:
> | =A0 =A0 =A0 cr_hbuf_put(ctx, sizeof(*hh));
> | diff --git a/checkpoint/rstr_file.c b/checkpoint/rstr_file.c
> | index f44b081..755e40e 100644
> | --- a/checkpoint/rstr_file.c
> | +++ b/checkpoint/rstr_file.c
> | @@ -7,7 +7,7 @@
> | =A0 * =A0License. =A0See the file COPYING in the main directory of the =
Linux
> | =A0 * =A0distribution for more details.
> | =A0 */
> | -
> | +#define DEBUG
> | =A0#include <linux/kernel.h>
> | =A0#include <linux/sched.h>
> | =A0#include <linux/fs.h>
> | diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
> | index 4d5ce1a..8330468 100644
> | --- a/checkpoint/rstr_mem.c
> | +++ b/checkpoint/rstr_mem.c
> | @@ -7,7 +7,7 @@
> | =A0 * =A0License. =A0See the file COPYING in the main directory of the =
Linux
> | =A0 * =A0distribution for more details.
> | =A0 */
> | -
> | +#define DEBUG
> | =A0#include <linux/kernel.h>
> | =A0#include <linux/sched.h>
> | =A0#include <linux/fcntl.h>
> | diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> | index f26b0c6..d1a5394 100644
> | --- a/checkpoint/sys.c
> | +++ b/checkpoint/sys.c
> | @@ -7,7 +7,7 @@
> | =A0 * =A0License. =A0See the file COPYING in the main directory of the =
Linux
> | =A0 * =A0distribution for more details.
> | =A0 */
> | -
> | +#define DEBUG
> | =A0#include <linux/sched.h>
> | =A0#include <linux/nsproxy.h>
> | =A0#include <linux/kernel.h>
> | @@ -263,7 +263,6 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, u=
nsigned
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(ctx);
> |
> | =A0 =A0 =A0 ret =3D do_checkpoint(ctx, pid);
> | -
> | =A0 =A0 =A0 if (!ret)
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D ctx->crid;
> |
> | @@ -304,3 +303,4 @@ asmlinkage long sys_restart(int crid, int fd, unsig=
ned lon
> | =A0 =A0 =A0 cr_ctx_put(ctx);
> | =A0 =A0 =A0 return ret;
> | =A0}
> | +
> | diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> | index 217cf6e..bc2c202 100644
> | --- a/include/linux/checkpoint.h
> | +++ b/include/linux/checkpoint.h
> | @@ -114,7 +114,6 @@ extern int cr_write_files(struct cr_ctx *ctx, struc=
t task_
> | =A0extern int do_restart(struct cr_ctx *ctx, pid_t pid);
> | =A0extern int cr_read_mm(struct cr_ctx *ctx);
> | =A0extern int cr_read_files(struct cr_ctx *ctx);
> | -
> | =A0#ifdef pr_fmt
> | =A0#undef pr_fmt
> | =A0#endif
> | diff --git a/include/linux/pid.h b/include/linux/pid.h
> | index d7e98ff..86e2f61 100644
> | --- a/include/linux/pid.h
> | +++ b/include/linux/pid.h
> | @@ -119,7 +119,7 @@ extern struct pid *find_get_pid(int nr);
> | =A0extern struct pid *find_ge_pid(int nr, struct pid_namespace *);
> | =A0int next_pidmap(struct pid_namespace *pid_ns, int last);
> |
> | -extern struct pid *alloc_pid(struct pid_namespace *ns);
> | +extern struct pid *alloc_pid(struct pid_namespace *ns, pid_t pid_nr);
> | =A0extern void free_pid(struct pid *pid);
> |
> | =A0/*
> | diff --git a/include/linux/sched.h b/include/linux/sched.h
> | index 0150e90..7fb4e28 100644
> | --- a/include/linux/sched.h
> | +++ b/include/linux/sched.h
> | @@ -28,6 +28,7 @@
> | =A0#define CLONE_NEWPID =A0 =A0 =A0 =A0 0x20000000 =A0 =A0 =A0/* New pi=
d namespace */
> | =A0#define CLONE_NEWNET =A0 =A0 =A0 =A0 0x40000000 =A0 =A0 =A0/* New ne=
twork namespace */
> | =A0#define CLONE_IO =A0 =A0 =A0 =A0 =A0 =A0 0x80000000 =A0 =A0 =A0/* Cl=
one io context */
> | +#define CLONE_WITH_PID =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x00001000 =A0 =A0 =
=A0/* Clone with pre-select PID */
> |
> | =A0/*
> | =A0 * Scheduling policies
> | diff --git a/kernel/exit.c b/kernel/exit.c
> | index 2d8be7e..4baf651 100644
> | --- a/kernel/exit.c
> | +++ b/kernel/exit.c
> | @@ -3,7 +3,7 @@
> | =A0 *
> | =A0 * =A0Copyright (C) 1991, 1992 =A0Linus Torvalds
> | =A0 */
> | -
> | +#define DEBUG
> | =A0#include <linux/mm.h>
> | =A0#include <linux/slab.h>
> | =A0#include <linux/interrupt.h>
> | @@ -1676,6 +1676,7 @@ static long do_wait(enum pid_type type, struct pi=
d *pid,
> | =A0 =A0 =A0 DECLARE_WAITQUEUE(wait, current);
> | =A0 =A0 =A0 struct task_struct *tsk;
> | =A0 =A0 =A0 int retval;
> | + =A0 =A0 int level;
>
> and this (level is not used).
> |
> | =A0 =A0 =A0 trace_sched_process_wait(pid);
> |
> | @@ -1708,7 +1709,6 @@ repeat:
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D tsk_result;
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto end;
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> | -
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (options & __WNOTHREAD)
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk =3D next_thread(tsk);
> | @@ -1817,7 +1817,6 @@ asmlinkage long sys_wait4(pid_t upid, int __user =
*stat_a
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 type =3D PIDTYPE_PID;
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 pid =3D find_get_pid(upid);
> | =A0 =A0 =A0 }
> | -
> | =A0 =A0 =A0 ret =3D do_wait(type, pid, options | WEXITED, NULL, stat_ad=
dr, ru);
> | =A0 =A0 =A0 put_pid(pid);
> |
> | diff --git a/kernel/fork.c b/kernel/fork.c
> | index 085ce56..262ae1e 100644
> | --- a/kernel/fork.c
> | +++ b/kernel/fork.c
> | @@ -10,7 +10,7 @@
> | =A0 * Fork is rather simple, once you get the hang of it, but the memor=
y
> | =A0 * management can be a bitch. See 'mm/memory.c': 'copy_page_range()'
> | =A0 */
> | -
> | +#define DEBUG
> | =A0#include <linux/slab.h>
> | =A0#include <linux/init.h>
> | =A0#include <linux/unistd.h>
> | @@ -959,10 +959,19 @@ static struct task_struct *copy_process(unsigned =
long cl
> | =A0 =A0 =A0 int retval;
> | =A0 =A0 =A0 struct task_struct *p;
> | =A0 =A0 =A0 int cgroup_callbacks_done =3D 0;
> | + =A0 =A0 pid_t clone_pid =3D stack_size;
> |
> | =A0 =A0 =A0 if ((clone_flags & (CLONE_NEWNS|CLONE_FS)) =3D=3D (CLONE_NE=
WNS|CLONE_FS))
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EINVAL);
> |
> | + =A0 =A0 /* We only allow the clone_with_pid when a new pid namespace =
is
> | + =A0 =A0 =A0* created. FIXME: how to restrict it.
>
> Not sure why CLONE_NEWPID is required to set pid_nr. In fact with CLONE_N=
EWPID,
> by definition, pid_nr should be 1. Also, what happens if a container has
> more than one process - where the second process has a pid_nr > 2 ?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
