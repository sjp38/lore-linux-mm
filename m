Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B28146B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 00:29:41 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n2D4TY2W016757
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 21:29:34 -0700
Received: from rv-out-0506.google.com (rvbf6.prod.google.com [10.140.82.6])
	by zps37.corp.google.com with ESMTP id n2D4TAEf024381
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 21:29:33 -0700
Received: by rv-out-0506.google.com with SMTP id f6so2326027rvb.19
        for <linux-mm@kvack.org>; Thu, 12 Mar 2009 21:29:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090312212124.GA25019@us.ibm.com>
References: <1234467035.3243.538.camel@calx>
	 <1234475483.30155.194.camel@nimitz>
	 <20090212141014.2cd3d54d.akpm@linux-foundation.org>
	 <1234479845.30155.220.camel@nimitz>
	 <20090226155755.GA1456@x200.localdomain>
	 <20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr>
	 <20090312145311.GC12390@us.ibm.com> <1236891719.32630.14.camel@bahia>
	 <20090312212124.GA25019@us.ibm.com>
Date: Thu, 12 Mar 2009 21:29:32 -0700
Message-ID: <604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Greg Kurz <gkurz@fr.ibm.com>, Cedric Le Goater <legoater@free.fr>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mpm@selenic.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, tglx@linutronix.de, viro@zeniv.linux.org.uk, hpa@zytor.com, mingo@elte.hu, torvalds@linux-foundation.org, Alexey Dobriyan <adobriyan@gmail.com>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Hi Serge:
I made a patch based on Oren's tree recently which implement a new
syscall clone_with_pid. I tested with checkpoint/restart process tree
and it works as expected.
This patch has some hack in it which i made a copy of libc's clone and
made modifications of passing one more argument(pid number). I will
try to clean up the code and do more testing.

New syscall clone_with_pid
Implement a new syscall which clone a thread with a preselected pid number.

clone_with_pid(child_func, child_stack + CHILD_STACK - 16,
			CLONE_WITH_PID|SIGCHLD, pid, NULL);

Signed-off-by: Ying Han <yinghan@google.com>

diff --git a/arch/x86/include/asm/syscalls.h b/arch/x86/include/asm/syscall=
s.h
index 87803da..b5a1b03 100644
--- a/arch/x86/include/asm/syscalls.h
+++ b/arch/x86/include/asm/syscalls.h
@@ -26,6 +26,7 @@ asmlinkage int sys_fork(struct pt_regs);
 asmlinkage int sys_clone(struct pt_regs);
 asmlinkage int sys_vfork(struct pt_regs);
 asmlinkage int sys_execve(struct pt_regs);
+asmlinkage int sys_clone_with_pid(struct pt_regs);

 /* kernel/signal_32.c */
 asmlinkage int sys_sigsuspend(int, int, old_sigset_t);
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd=
_32
index a5f9e09..f10ca0e 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -340,6 +340,7 @@
 #define __NR_inotify_init1	332
 #define __NR_checkpoint		333
 #define __NR_restart		334
+#define __NR_clone_with_pid	335

 #ifdef __KERNEL__

diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index 0a1302f..88ae634 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -8,7 +8,6 @@
 /*
  * This file handles the architecture-dependent parts of process handling.=
.
  */
-
 #include <stdarg.h>

 #include <linux/cpu.h>
@@ -652,6 +651,28 @@ asmlinkage int sys_clone(struct pt_regs regs)
 	return do_fork(clone_flags, newsp, &regs, 0, parent_tidptr, child_tidptr)=
;
 }

+/**
+ * sys_clone_with_pid - clone a thread with pre-select pid number.
+ */
+asmlinkage int sys_clone_with_pid(struct pt_regs regs)
+{
+	unsigned long clone_flags;
+	unsigned long newsp;
+	int __user *parent_tidptr, *child_tidptr;
+	pid_t pid_nr;
+
+	clone_flags =3D regs.bx;
+	newsp =3D regs.cx;
+	parent_tidptr =3D (int __user *)regs.dx;
+	child_tidptr =3D (int __user *)regs.di;
+	pid_nr =3D regs.bp;
+
+	if (!newsp)
+		newsp =3D regs.sp;
+	return do_fork(clone_flags, newsp, &regs, pid_nr, parent_tidptr,
+			child_tidptr);
+}
+
 /*
  * This is trivial, and on the face of it looks like it
  * could equally well be done in user mode.
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_t=
abl
index 5543136..5191117 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -334,3 +334,4 @@ ENTRY(sys_call_table)
 	.long sys_inotify_init1
 	.long sys_checkpoint
 	.long sys_restart
+	.long sys_clone_with_pid
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 50bde9a..a4aee65 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -7,7 +7,6 @@
  *  License.  See the file COPYING in the main directory of the Linux
  *  distribution for more details.
  */
-
 #include <asm/desc.h>
 #include <asm/i387.h>

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 64155de..b7de611 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -8,6 +8,7 @@
  *  distribution for more details.
  */

+#define DEBUG
 #include <linux/version.h>
 #include <linux/sched.h>
 #include <linux/ptrace.h>
@@ -564,3 +565,4 @@ int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
  out:
 	return ret;
 }
+
diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
index e3097ac..a8c5ad5 100644
--- a/checkpoint/ckpt_file.c
+++ b/checkpoint/ckpt_file.c
@@ -7,7 +7,7 @@
  *  License.  See the file COPYING in the main directory of the Linux
  *  distribution for more details.
  */
-
+#define DEBUG
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/file.h>
diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
index 4925ff2..ca5840b 100644
--- a/checkpoint/ckpt_mem.c
+++ b/checkpoint/ckpt_mem.c
@@ -7,7 +7,7 @@
  *  License.  See the file COPYING in the main directory of the Linux
  *  distribution for more details.
  */
-
+#define DEBUG
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 7ec4de4..30e43c2 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -8,6 +8,7 @@
  *  distribution for more details.
  */

+#define DEBUG
 #include <linux/version.h>
 #include <linux/sched.h>
 #include <linux/wait.h>
@@ -242,7 +243,7 @@ static int cr_read_task_struct(struct cr_ctx *ctx)
 		memcpy(t->comm, buf, min(hh->task_comm_len, TASK_COMM_LEN));
 	}
 	kfree(buf);
-
+	pr_debug("read task %s\n", t->comm);
 	/* FIXME: restore remaining relevant task_struct fields */
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
diff --git a/checkpoint/rstr_file.c b/checkpoint/rstr_file.c
index f44b081..755e40e 100644
--- a/checkpoint/rstr_file.c
+++ b/checkpoint/rstr_file.c
@@ -7,7 +7,7 @@
  *  License.  See the file COPYING in the main directory of the Linux
  *  distribution for more details.
  */
-
+#define DEBUG
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/fs.h>
diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
index 4d5ce1a..8330468 100644
--- a/checkpoint/rstr_mem.c
+++ b/checkpoint/rstr_mem.c
@@ -7,7 +7,7 @@
  *  License.  See the file COPYING in the main directory of the Linux
  *  distribution for more details.
  */
-
+#define DEBUG
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/fcntl.h>
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index f26b0c6..d1a5394 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -7,7 +7,7 @@
  *  License.  See the file COPYING in the main directory of the Linux
  *  distribution for more details.
  */
-
+#define DEBUG
 #include <linux/sched.h>
 #include <linux/nsproxy.h>
 #include <linux/kernel.h>
@@ -263,7 +263,6 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsig=
ned
 		return PTR_ERR(ctx);

 	ret =3D do_checkpoint(ctx, pid);
-
 	if (!ret)
 		ret =3D ctx->crid;

@@ -304,3 +303,4 @@ asmlinkage long sys_restart(int crid, int fd, unsigned =
lon
 	cr_ctx_put(ctx);
 	return ret;
 }
+
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 217cf6e..bc2c202 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -114,7 +114,6 @@ extern int cr_write_files(struct cr_ctx *ctx, struct ta=
sk_
 extern int do_restart(struct cr_ctx *ctx, pid_t pid);
 extern int cr_read_mm(struct cr_ctx *ctx);
 extern int cr_read_files(struct cr_ctx *ctx);
-
 #ifdef pr_fmt
 #undef pr_fmt
 #endif
diff --git a/include/linux/pid.h b/include/linux/pid.h
index d7e98ff..86e2f61 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -119,7 +119,7 @@ extern struct pid *find_get_pid(int nr);
 extern struct pid *find_ge_pid(int nr, struct pid_namespace *);
 int next_pidmap(struct pid_namespace *pid_ns, int last);

-extern struct pid *alloc_pid(struct pid_namespace *ns);
+extern struct pid *alloc_pid(struct pid_namespace *ns, pid_t pid_nr);
 extern void free_pid(struct pid *pid);

 /*
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0150e90..7fb4e28 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -28,6 +28,7 @@
 #define CLONE_NEWPID		0x20000000	/* New pid namespace */
 #define CLONE_NEWNET		0x40000000	/* New network namespace */
 #define CLONE_IO		0x80000000	/* Clone io context */
+#define CLONE_WITH_PID		0x00001000	/* Clone with pre-select PID */

 /*
  * Scheduling policies
diff --git a/kernel/exit.c b/kernel/exit.c
index 2d8be7e..4baf651 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -3,7 +3,7 @@
  *
  *  Copyright (C) 1991, 1992  Linus Torvalds
  */
-
+#define DEBUG
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
@@ -1676,6 +1676,7 @@ static long do_wait(enum pid_type type, struct pid *p=
id,
 	DECLARE_WAITQUEUE(wait, current);
 	struct task_struct *tsk;
 	int retval;
+	int level;

 	trace_sched_process_wait(pid);

@@ -1708,7 +1709,6 @@ repeat:
 			retval =3D tsk_result;
 			goto end;
 		}
-
 		if (options & __WNOTHREAD)
 			break;
 		tsk =3D next_thread(tsk);
@@ -1817,7 +1817,6 @@ asmlinkage long sys_wait4(pid_t upid, int __user *sta=
t_a
 		type =3D PIDTYPE_PID;
 		pid =3D find_get_pid(upid);
 	}
-
 	ret =3D do_wait(type, pid, options | WEXITED, NULL, stat_addr, ru);
 	put_pid(pid);

diff --git a/kernel/fork.c b/kernel/fork.c
index 085ce56..262ae1e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -10,7 +10,7 @@
  * Fork is rather simple, once you get the hang of it, but the memory
  * management can be a bitch. See 'mm/memory.c': 'copy_page_range()'
  */
-
+#define DEBUG
 #include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/unistd.h>
@@ -959,10 +959,19 @@ static struct task_struct *copy_process(unsigned long=
 cl
 	int retval;
 	struct task_struct *p;
 	int cgroup_callbacks_done =3D 0;
+	pid_t clone_pid =3D stack_size;

 	if ((clone_flags & (CLONE_NEWNS|CLONE_FS)) =3D=3D (CLONE_NEWNS|CLONE_FS))
 		return ERR_PTR(-EINVAL);

+	/* We only allow the clone_with_pid when a new pid namespace is
+	 * created. FIXME: how to restrict it.
+	 */
+	if ((clone_flags & CLONE_NEWPID) && (clone_flags & CLONE_WITH_PID))
+		return ERR_PTR(-EINVAL);
+	if ((clone_flags & CLONE_WITH_PID) && (clone_pid <=3D 1))
+		return ERR_PTR(-EINVAL);
+
 	/*
 	 * Thread groups must share signals as well, and detached threads
 	 * can only be started up within the thread group.
@@ -1135,7 +1144,10 @@ static struct task_struct *copy_process(unsigned lon=
g c

 	if (pid !=3D &init_struct_pid) {
 		retval =3D -ENOMEM;
-		pid =3D alloc_pid(task_active_pid_ns(p));
+		if (clone_flags & CLONE_WITH_PID)
+			pid =3D alloc_pid(task_active_pid_ns(p), clone_pid);
+		else
+			pid =3D alloc_pid(task_active_pid_ns(p), 0);
 		if (!pid)
 			goto bad_fork_cleanup_io;

@@ -1162,6 +1174,8 @@ static struct task_struct *copy_process(unsigned long=
 cl
 	 * Clear TID on mm_release()?
 	 */
 	p->clear_child_tid =3D (clone_flags & CLONE_CHILD_CLEARTID) ? child_tidpt=
r: NU
+
+
 #ifdef CONFIG_FUTEX
 	p->robust_list =3D NULL;
 #ifdef CONFIG_COMPAT
diff --git a/kernel/pid.c b/kernel/pid.c
index 064e76a..0facf05 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -25,7 +25,7 @@
  *     Many thanks to Oleg Nesterov for comments and help
  *
  */
-
+#define DEBUG
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/slab.h>
@@ -122,12 +122,15 @@ static void free_pidmap(struct upid *upid)
 	atomic_inc(&map->nr_free);
 }

-static int alloc_pidmap(struct pid_namespace *pid_ns)
+static int alloc_pidmap(struct pid_namespace *pid_ns, pid_t pid_nr)
 {
 	int i, offset, max_scan, pid, last =3D pid_ns->last_pid;
 	struct pidmap *map;

-	pid =3D last + 1;
+	if (pid_nr)
+		pid =3D pid_nr;
+	else
+		pid =3D last + 1;
 	if (pid >=3D pid_max)
 		pid =3D RESERVED_PIDS;
 	offset =3D pid & BITS_PER_PAGE_MASK;
@@ -153,9 +156,12 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 			do {
 				if (!test_and_set_bit(offset, map->page)) {
 					atomic_dec(&map->nr_free);
-					pid_ns->last_pid =3D pid;
+					if (!pid_nr)
+						pid_ns->last_pid =3D pid;
 					return pid;
 				}
+				if (pid_nr)
+					return -1;
 				offset =3D find_next_offset(map, offset);
 				pid =3D mk_pid(pid_ns, map, offset);
 			/*
@@ -239,21 +245,25 @@ void free_pid(struct pid *pid)
 	call_rcu(&pid->rcu, delayed_put_pid);
 }

-struct pid *alloc_pid(struct pid_namespace *ns)
+struct pid *alloc_pid(struct pid_namespace *ns, pid_t pid_nr)
 {
 	struct pid *pid;
 	enum pid_type type;
 	int i, nr;
 	struct pid_namespace *tmp;
 	struct upid *upid;
+	int level =3D ns->level;
+
+	if (pid_nr >=3D pid_max)
+		return NULL;

 	pid =3D kmem_cache_alloc(ns->pid_cachep, GFP_KERNEL);
 	if (!pid)
 		goto out;

-	tmp =3D ns;
-	for (i =3D ns->level; i >=3D 0; i--) {
-		nr =3D alloc_pidmap(tmp);
+	tmp =3D ns->parent;
+	for (i =3D level-1; i >=3D 0; i--) {
+		nr =3D alloc_pidmap(tmp, 0);
 		if (nr < 0)
 			goto out_free;

@@ -262,6 +272,14 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 		tmp =3D tmp->parent;
 	}

+	nr =3D alloc_pidmap(ns, pid_nr);
+	if (nr < 0)
+		goto out_free;
+	pid->numbers[level].nr =3D nr;
+	pid->numbers[level].ns =3D ns;
+	if (nr =3D=3D pid_nr)
+		pr_debug("nr =3D=3D pid_nr =3D=3D %d\n", nr);
+
 	get_pid_ns(ns);
 	pid->level =3D ns->level;
 	atomic_set(&pid->count, 1);








On Thu, Mar 12, 2009 at 2:21 PM, Serge E. Hallyn <serue@us.ibm.com> wrote:
>
> Quoting Greg Kurz (gkurz@fr.ibm.com):
> > On Thu, 2009-03-12 at 09:53 -0500, Serge E. Hallyn wrote:
> > > Or are you suggesting that you'll do a dummy clone of (5594,2) so tha=
t
> > > the next clone(CLONE_NEWPID) will be expected to be (5594,3,1)?
> > >
> >
> > Of course not
>
> Ok - someone *did* argue that at some point I think...
>
> > but one should be able to tell clone() to pick a specific
> > pid.
>
> Can you explain exactly how? =A0I must be missing something clever.
>
> -serge
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
