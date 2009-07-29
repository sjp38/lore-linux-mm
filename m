Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 18D6B6B004F
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 20:42:11 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n6T0fvOr022438
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 20:41:57 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6T0gEAM250250
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 20:42:14 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6T0gDLN020362
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 20:42:14 -0400
Date: Tue, 28 Jul 2009 17:44:55 -0700
From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC v17][PATCH 17/60] pids 7/7: Define clone_with_pids syscall
Message-ID: <20090729004455.GA22406@us.ibm.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com> <1248256822-23416-18-git-send-email-orenl@librato.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1248256822-23416-18-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@librato.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, yinghan@google.com, mikew@google.com, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>
List-ID: <linux-mm.kvack.org>

Ccing Oleg Nesterov, Eric Biederman, Mike Waychinson, Ying Han

Note that this is a variant of an earlier clone_with_pids() interface, sent
in Mar 2009 (http://lkml.org/lkml/2009/3/13/359).  Linus' major objection 
was about security, as unprivileged tasks could read /var/run data and try
to run with cached pids.

This variant addresses that concern by requiring CAP_SYS_ADMIN to specify
pids.  This makes sense since CAP_SYS_ADMIN is required to create a new
pid namespace anyway.

Sukadev

Oren Laadan [orenl@librato.com] wrote:
| From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
| 
| Container restart requires that a task have the same pid it had when it was
| checkpointed. When containers are nested the tasks within the containers
| exist in multiple pid namespaces and hence have multiple pids to specify
| during restart.
| 
| clone_with_pids(), intended for use during restart, is the same as clone(),
| except that it takes a 'target_pid_set' paramter. This parameter lets caller
| choose specific pid numbers for the child process, in the process's active
| and ancestor pid namespaces. (Descendant pid namespaces in general don't
| matter since processes don't have pids in them anyway, but see comments
| in copy_target_pids() regarding CLONE_NEWPID).
| 
| Unlike clone(), clone_with_pids() needs CAP_SYS_ADMIN, at least for now, to
| prevent unprivileged processes from misusing this interface.
| 
| Call clone_with_pids as follows:
| 
| 	pid_t pids[] = { 0, 77, 99 };
| 	struct target_pid_set pid_set;
| 
| 	pid_set.num_pids = sizeof(pids) / sizeof(int);
| 	pid_set.target_pids = &pids;
| 
| 	syscall(__NR_clone_with_pids, flags, stack, NULL, NULL, NULL, &pid_set);
| 
| If a target-pid is 0, the kernel continues to assign a pid for the process in
| that namespace. In the above example, pids[0] is 0, meaning the kernel will
| assign next available pid to the process in init_pid_ns. But kernel will assign
| pid 77 in the child pid namespace 1 and pid 99 in pid namespace 2. If either
| 77 or 99 are taken, the system call fails with -EBUSY.
| 
| If 'pid_set.num_pids' exceeds the current nesting level of pid namespaces,
| the system call fails with -EINVAL.
| 
| Its mostly an exploratory patch seeking feedback on the interface.
| 
| NOTE:
| 	Compared to clone(), clone_with_pids() needs to pass in two more
| 	pieces of information:
| 
| 		- number of pids in the set
| 		- user buffer containing the list of pids.
| 
| 	But since clone() already takes 5 parameters, use a 'struct
| 	target_pid_set'.
| 
| TODO:
| 	- Gently tested.
| 	- May need additional sanity checks in do_fork_with_pids().
| 
| Changelog[v3]:
| 	- (Oren Laadan) Allow CLONE_NEWPID flag (by allocating an extra pid
| 	  in the target_pids[] list and setting it 0. See copy_target_pids()).
| 	- (Oren Laadan) Specified target pids should apply only to youngest
| 	  pid-namespaces (see copy_target_pids())
| 	- (Matt Helsley) Update patch description.
| 
| Changelog[v2]:
| 	- Remove unnecessary printk and add a note to callers of
| 	  copy_target_pids() to free target_pids.
| 	- (Serge Hallyn) Mention CAP_SYS_ADMIN restriction in patch description.
| 	- (Oren Laadan) Add checks for 'num_pids < 0' (return -EINVAL) and
| 	  'num_pids == 0' (fall back to normal clone()).
| 	- Move arch-independent code (sanity checks and copy-in of target-pids)
| 	  into kernel/fork.c and simplify sys_clone_with_pids()
| 
| Changelog[v1]:
| 	- Fixed some compile errors (had fixed these errors earlier in my
| 	  git tree but had not refreshed patches before emailing them)
| 
| Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
| ---
|  arch/x86/include/asm/syscalls.h    |    2 +
|  arch/x86/include/asm/unistd_32.h   |    1 +
|  arch/x86/kernel/entry_32.S         |    1 +
|  arch/x86/kernel/process_32.c       |   21 +++++++
|  arch/x86/kernel/syscall_table_32.S |    1 +
|  kernel/fork.c                      |  108 +++++++++++++++++++++++++++++++++++-
|  6 files changed, 133 insertions(+), 1 deletions(-)
| 
| diff --git a/arch/x86/include/asm/syscalls.h b/arch/x86/include/asm/syscalls.h
| index 372b76e..df3c4a8 100644
| --- a/arch/x86/include/asm/syscalls.h
| +++ b/arch/x86/include/asm/syscalls.h
| @@ -40,6 +40,8 @@ long sys_iopl(struct pt_regs *);
| 
|  /* kernel/process_32.c */
|  int sys_clone(struct pt_regs *);
| +int sys_clone_with_pids(struct pt_regs *);
| +int sys_vfork(struct pt_regs *);
|  int sys_execve(struct pt_regs *);
| 
|  /* kernel/signal.c */
| diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
| index 732a307..f65b750 100644
| --- a/arch/x86/include/asm/unistd_32.h
| +++ b/arch/x86/include/asm/unistd_32.h
| @@ -342,6 +342,7 @@
|  #define __NR_pwritev		334
|  #define __NR_rt_tgsigqueueinfo	335
|  #define __NR_perf_counter_open	336
| +#define __NR_clone_with_pids	337
| 
|  #ifdef __KERNEL__
| 
| diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
| index c097e7d..c7bd1f6 100644
| --- a/arch/x86/kernel/entry_32.S
| +++ b/arch/x86/kernel/entry_32.S
| @@ -718,6 +718,7 @@ ptregs_##name: \
|  PTREGSCALL(iopl)
|  PTREGSCALL(fork)
|  PTREGSCALL(clone)
| +PTREGSCALL(clone_with_pids)
|  PTREGSCALL(vfork)
|  PTREGSCALL(execve)
|  PTREGSCALL(sigaltstack)
| diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
| index 59f4524..9965c06 100644
| --- a/arch/x86/kernel/process_32.c
| +++ b/arch/x86/kernel/process_32.c
| @@ -443,6 +443,27 @@ int sys_clone(struct pt_regs *regs)
|  	return do_fork(clone_flags, newsp, regs, 0, parent_tidptr, child_tidptr);
|  }
| 
| +int sys_clone_with_pids(struct pt_regs *regs)
| +{
| +	unsigned long clone_flags;
| +	unsigned long newsp;
| +	int __user *parent_tidptr;
| +	int __user *child_tidptr;
| +	void __user *upid_setp;
| +
| +	clone_flags = regs->bx;
| +	newsp = regs->cx;
| +	parent_tidptr = (int __user *)regs->dx;
| +	child_tidptr = (int __user *)regs->di;
| +	upid_setp = (void __user *)regs->bp;
| +
| +	if (!newsp)
| +		newsp = regs->sp;
| +
| +	return do_fork_with_pids(clone_flags, newsp, regs, 0, parent_tidptr,
| +			child_tidptr, upid_setp);
| +}
| +
|  /*
|   * sys_execve() executes a new program.
|   */
| diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
| index d51321d..879e5ec 100644
| --- a/arch/x86/kernel/syscall_table_32.S
| +++ b/arch/x86/kernel/syscall_table_32.S
| @@ -336,3 +336,4 @@ ENTRY(sys_call_table)
|  	.long sys_pwritev
|  	.long sys_rt_tgsigqueueinfo	/* 335 */
|  	.long sys_perf_counter_open
| +	.long ptregs_clone_with_pids
| diff --git a/kernel/fork.c b/kernel/fork.c
| index 64d53d9..29c66f0 100644
| --- a/kernel/fork.c
| +++ b/kernel/fork.c
| @@ -1336,6 +1336,97 @@ struct task_struct * __cpuinit fork_idle(int cpu)
|  }
| 
|  /*
| + * If user specified any 'target-pids' in @upid_setp, copy them from
| + * user and return a pointer to a local copy of the list of pids. The
| + * caller must free the list, when they are done using it.
| + *
| + * If user did not specify any target pids, return NULL (caller should
| + * treat this like normal clone).
| + *
| + * On any errors, return the error code
| + */
| +static pid_t *copy_target_pids(void __user *upid_setp)
| +{
| +	int j;
| +	int rc;
| +	int size;
| +	int unum_pids;		/* # of pids specified by user */
| +	int knum_pids;		/* # of pids needed in kernel */
| +	pid_t *target_pids;
| +	struct target_pid_set pid_set;
| +
| +	if (!upid_setp)
| +		return NULL;
| +
| +	rc = copy_from_user(&pid_set, upid_setp, sizeof(pid_set));
| +	if (rc)
| +		return ERR_PTR(-EFAULT);
| +
| +	unum_pids = pid_set.num_pids;
| +	knum_pids = task_pid(current)->level + 1;
| +
| +	if (!unum_pids)
| +		return NULL;
| +
| +	if (unum_pids < 0 || unum_pids > knum_pids)
| +		return ERR_PTR(-EINVAL);
| +
| +	/*
| +	 * To keep alloc_pid() simple, allocate an extra pid_t in target_pids[]
| +	 * and set it to 0. This last entry in target_pids[] corresponds to the
| +	 * (yet-to-be-created) descendant pid-namespace if CLONE_NEWPID was
| +	 * specified. If CLONE_NEWPID was not specified, this last entry will
| +	 * simply be ignored.
| +	 */
| +	target_pids = kzalloc((knum_pids + 1) * sizeof(pid_t), GFP_KERNEL);
| +	if (!target_pids)
| +		return ERR_PTR(-ENOMEM);
| +
| +	/*
| +	 * A process running in a level 2 pid namespace has three pid namespaces
| +	 * and hence three pid numbers. If this process is checkpointed,
| +	 * information about these three namespaces are saved. We refer to these
| +	 * namespaces as 'known namespaces'.
| +	 *
| +	 * If this checkpointed process is however restarted in a level 3 pid
| +	 * namespace, the restarted process has an extra ancestor pid namespace
| +	 * (i.e 'unknown namespace') and 'knum_pids' exceeds 'unum_pids'.
| +	 *
| +	 * During restart, the process requests specific pids for its 'known
| +	 * namespaces' and lets kernel assign pids to its 'unknown namespaces'.
| +	 *
| +	 * Since the requested-pids correspond to 'known namespaces' and since
| +	 * 'known-namespaces' are younger than (i.e descendants of) 'unknown-
| +	 * namespaces', copy requested pids to the back-end of target_pids[]
| +	 * (i.e before the last entry for CLONE_NEWPID mentioned above).
| +	 * Any entries in target_pids[] not corresponding to a requested pid
| +	 * will be set to zero and kernel assigns a pid in those namespaces.
| +	 *
| +	 * NOTE: The order of pids in target_pids[] is oldest pid namespace to
| +	 * 	 youngest (target_pids[0] corresponds to init_pid_ns). i.e.
| +	 * 	 the order is:
| +	 *
| +	 * 		- pids for 'unknown-namespaces' (if any)
| +	 * 		- pids for 'known-namespaces' (requested pids)
| +	 * 		- 0 in the last entry (for CLONE_NEWPID).
| +	 */
| +	j = knum_pids - unum_pids;
| +	size = unum_pids * sizeof(pid_t);
| +
| +	rc = copy_from_user(&target_pids[j], pid_set.target_pids, size);
| +	if (rc) {
| +		rc = -EFAULT;
| +		goto out_free;
| +	}
| +
| +	return target_pids;
| +
| +out_free:
| +	kfree(target_pids);
| +	return ERR_PTR(rc);
| +}
| +
| +/*
|   *  Ok, this is the main fork-routine.
|   *
|   * It copies the process, and if successful kick-starts
| @@ -1352,7 +1443,7 @@ long do_fork_with_pids(unsigned long clone_flags,
|  	struct task_struct *p;
|  	int trace = 0;
|  	long nr;
| -	pid_t *target_pids = NULL;
| +	pid_t *target_pids;
| 
|  	/*
|  	 * Do some preliminary argument and permissions checking before we
| @@ -1386,6 +1477,17 @@ long do_fork_with_pids(unsigned long clone_flags,
|  		}
|  	}
| 
| +	target_pids = copy_target_pids(pid_setp);
| +
| +	if (target_pids) {
| +		if (IS_ERR(target_pids))
| +			return PTR_ERR(target_pids);
| +
| +		nr = -EPERM;
| +		if (!capable(CAP_SYS_ADMIN))
| +			goto out_free;
| +	}
| +
|  	/*
|  	 * When called from kernel_thread, don't do user tracing stuff.
|  	 */
| @@ -1453,6 +1555,10 @@ long do_fork_with_pids(unsigned long clone_flags,
|  	} else {
|  		nr = PTR_ERR(p);
|  	}
| +
| +out_free:
| +	kfree(target_pids);
| +
|  	return nr;
|  }
| 
| -- 
| 1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
