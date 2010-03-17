Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6656B01C8
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:12:10 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 08/96] eclone (8/11): Implement sys_eclone for x86 (32,64)
Date: Wed, 17 Mar 2010 12:07:56 -0400
Message-Id: <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>

Container restart requires that a task have the same pid it had when it was
checkpointed. When containers are nested the tasks within the containers
exist in multiple pid namespaces and hence have multiple pids to specify
during restart.

eclone(), intended for use during restart, is the same as
clone(), except that it takes a 'pids' paramter. This parameter lets
caller choose specific pid numbers for the child process, in the
process's active and ancestor pid namespaces. (Descendant pid namespaces
in general don't matter since processes don't have pids in them anyway,
but see comments in copy_target_pids() regarding CLONE_NEWPID).

eclone() also attempts to address a second limitation of the
clone() system call. clone() is restricted to 32 clone flags and all but
one of these are in use. If more new clone flags are needed, we will be
forced to define a new variant of the clone() system call. To address
this, eclone() allows at least 64 clone flags with some room
for more if necessary.

To prevent unprivileged processes from misusing this interface,
eclone() currently needs CAP_SYS_ADMIN, when the 'pids' parameter
is non-NULL.

See Documentation/eclone in next patch for more details and an
example of its usage.

NOTE:
	- System calls are restricted to 6 parameters and the number and sizes
	  of parameters needed for eclone() exceed 6 integers. The new
	  prototype works around this restriction while providing some
	  flexibility if eclone() needs to be further extended in the
	  future.
TODO:
	- We should convert clone-flags to 64-bit value in all architectures.
	  Its probably best to do that as a separate patchset since clone_flags
	  touches several functions and that patchset seems independent of this
	  new system call.

Changelog[v14]:
	- [Oren Laadan] Rebase to kernel 2.6.33
	  * introduce PTREGSCALL4 for sys_eclone
	  * consolidate syscall definitions for 32/64 bit
	- [Oren Laadan] Merge x86_64 (trivial patch) with current
        - [Serge Hallyn] Add eclone stub for ia32 eclone

Changelog[v13]:
	- [Dave Hansen]: Reorg to enable sharing code between x86 and x86-64.
	- [Arnd Bergmann]: With args_size parameter, ->reserved1 is redundant
	  and can be removed.
	- [Nathan Lynch]: stop warnings about assigning u64 to a (32-bit) int*.
	- [Nathan Lynch, Serge Hallyn] Rename ->child_stack_base to
	  ->child_stack and ensure ->child_stack_size is 0 on architectures
	  that don't need it (see comments in types.h for details).

Changelog[v12]:
	- [Serge Hallyn] Ignore ->child_stack_size if ->child_stack_base
	  is NULL.
	- [Oren Laadan, Serge Hallyn] Rename clone_with_pids() to eclone()
Changelog[v11]:
	- [Dave Hansen] Move clone_args validation checks to arch-indpeendent
	  code.
	- [Oren Laadan] Make args_size a parameter to system call and remove
	  it from 'struct clone_args'

Changelog[v10]:
	- Rename clone3() to clone_with_pids()
	- [Linus Torvalds] Use PTREGSCALL() rather than the generic syscall
	  implementation

Changelog[v9]:
	- [Roland McGrath, H. Peter Anvin] To avoid confusion on 64-bit
	  architectures split the new clone-flags into 'low' and 'high'
	  words and pass in the 'lower' flags as the first argument.
	  This would maintain similarity of the clone3() with clone()/
	  clone2(). Also has the side-effect of the name matching the
	  number of parameters :-)
	- [Roland McGrath] Rename structure to 'clone_args' and add a
	  'child_stack_size' field

Changelog[v8]
	- [Oren Laadan] parent_tid and child_tid fields in 'struct clone_arg'
	  must be 64-bit.
	- clone2() is in use in IA64. Rename system call to clone3().

Changelog[v7]:
	- [Peter Zijlstra, Arnd Bergmann] Rename system call to clone2()
	  and group parameters into a new 'struct clone_struct' object.

Changelog[v6]:
	- (Nathan Lynch, Arnd Bergmann, H. Peter Anvin, Linus Torvalds)
	  Change 'pid_set.pids' to a 'pid_t pids[]' so size of 'struct pid_set'
	  is constant across architectures.
	- (Nathan Lynch) Change pid_set.num_pids to unsigned and remove
	  'unum_pids < 0' check.

Changelog[v4]:
	- (Oren Laadan) rename 'struct target_pid_set' to 'struct pid_set'

Changelog[v3]:
	- (Oren Laadan) Allow CLONE_NEWPID flag (by allocating an extra pid
	  in the target_pids[] list and setting it 0. See copy_target_pids()).
	- (Oren Laadan) Specified target pids should apply only to youngest
	  pid-namespaces (see copy_target_pids())
	- (Matt Helsley) Update patch description.

Changelog[v2]:
	- Remove unnecessary printk and add a note to callers of
	  copy_target_pids() to free target_pids.
	- (Serge Hallyn) Mention CAP_SYS_ADMIN restriction in patch description.
	- (Oren Laadan) Add checks for 'num_pids < 0' (return -EINVAL) and
	  'num_pids == 0' (fall back to normal clone()).
	- Move arch-independent code (sanity checks and copy-in of target-pids)
	  into kernel/fork.c and simplify sys_clone_with_pids()

Changelog[v1]:
	- Fixed some compile errors (had fixed these errors earlier in my
	  git tree but had not refreshed patches before emailing them)

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
Acked-by: Oren Laadan <orenl.cs.columbia.edu>
---
 arch/x86/ia32/ia32entry.S          |    2 +
 arch/x86/include/asm/syscalls.h    |    2 +
 arch/x86/include/asm/unistd_32.h   |    3 +-
 arch/x86/include/asm/unistd_64.h   |    2 +
 arch/x86/kernel/entry_32.S         |   14 ++++
 arch/x86/kernel/entry_64.S         |    1 +
 arch/x86/kernel/process.c          |   40 +++++++++++-
 arch/x86/kernel/syscall_table_32.S |    1 +
 include/linux/sched.h              |    2 +
 include/linux/types.h              |   16 +++++
 kernel/fork.c                      |  124 +++++++++++++++++++++++++++++++++++-
 11 files changed, 204 insertions(+), 3 deletions(-)

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index 53147ad..5eec1d9 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -477,6 +477,7 @@ quiet_ni_syscall:
 	PTREGSCALL stub32_clone, sys32_clone, %rdx
 	PTREGSCALL stub32_vfork, sys_vfork, %rdi
 	PTREGSCALL stub32_iopl, sys_iopl, %rsi
+	PTREGSCALL stub32_eclone, sys_eclone, %r8
 
 ENTRY(ia32_ptregs_common)
 	popq %r11
@@ -842,4 +843,5 @@ ia32_sys_call_table:
 	.quad compat_sys_rt_tgsigqueueinfo	/* 335 */
 	.quad sys_perf_event_open
 	.quad compat_sys_recvmmsg
+	.quad stub32_eclone
 ia32_syscall_end:
diff --git a/arch/x86/include/asm/syscalls.h b/arch/x86/include/asm/syscalls.h
index 8868b94..972ab0e 100644
--- a/arch/x86/include/asm/syscalls.h
+++ b/arch/x86/include/asm/syscalls.h
@@ -27,6 +27,8 @@ long sys_execve(char __user *, char __user * __user *,
 		char __user * __user *, struct pt_regs *);
 long sys_clone(unsigned long, unsigned long, void __user *,
 	       void __user *, struct pt_regs *);
+long sys_eclone(unsigned flags_low, struct clone_args __user *uca,
+		int args_size, pid_t __user *pids, struct pt_regs *regs);
 
 /* kernel/ldt.c */
 asmlinkage int sys_modify_ldt(int, void __user *, unsigned long);
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index 3baf379..cd7ca6a 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -343,10 +343,11 @@
 #define __NR_rt_tgsigqueueinfo	335
 #define __NR_perf_event_open	336
 #define __NR_recvmmsg		337
+#define __NR_eclone		338
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 338
+#define NR_syscalls 339
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index 4843f7b..d87318d 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -663,6 +663,8 @@ __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
 __SYSCALL(__NR_perf_event_open, sys_perf_event_open)
 #define __NR_recvmmsg				299
 __SYSCALL(__NR_recvmmsg, sys_recvmmsg)
+#define __NR_eclone                   		300
+__SYSCALL(__NR_eclone, stub_eclone)
 
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
index 44a8e0d..65e1735 100644
--- a/arch/x86/kernel/entry_32.S
+++ b/arch/x86/kernel/entry_32.S
@@ -758,6 +758,19 @@ ptregs_##name: \
 	addl $4,%esp; \
 	ret
 
+#define PTREGSCALL4(name) \
+	ALIGN; \
+ptregs_##name: \
+	leal 4(%esp),%eax; \
+	pushl %eax; \
+	pushl PT_ESI(%eax); \
+	movl PT_EDX(%eax),%ecx; \
+	movl PT_ECX(%eax),%edx; \
+	movl PT_EBX(%eax),%eax; \
+	call sys_##name; \
+	addl $8,%esp; \
+	ret
+
 PTREGSCALL1(iopl)
 PTREGSCALL0(fork)
 PTREGSCALL0(vfork)
@@ -767,6 +780,7 @@ PTREGSCALL0(sigreturn)
 PTREGSCALL0(rt_sigreturn)
 PTREGSCALL2(vm86)
 PTREGSCALL1(vm86old)
+PTREGSCALL4(eclone)
 
 /* Clone is an oddball.  The 4th arg is in %edi */
 	ALIGN;
diff --git a/arch/x86/kernel/entry_64.S b/arch/x86/kernel/entry_64.S
index 0697ff1..216681e 100644
--- a/arch/x86/kernel/entry_64.S
+++ b/arch/x86/kernel/entry_64.S
@@ -698,6 +698,7 @@ END(\label)
 	PTREGSCALL stub_vfork, sys_vfork, %rdi
 	PTREGSCALL stub_sigaltstack, sys_sigaltstack, %rdx
 	PTREGSCALL stub_iopl, sys_iopl, %rsi
+	PTREGSCALL stub_eclone, sys_eclone, %r8
 
 ENTRY(ptregscall_common)
 	DEFAULT_FRAME 1 8	/* offset 8: return address */
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index c9b3522..b2352d9 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -252,6 +252,45 @@ sys_clone(unsigned long clone_flags, unsigned long newsp,
 	return do_fork(clone_flags, newsp, regs, 0, parent_tid, child_tid);
 }
 
+long
+sys_eclone(unsigned flags_low, struct clone_args __user *uca,
+	   int args_size, pid_t __user *pids, struct pt_regs *regs)
+{
+	int rc;
+	struct clone_args kca;
+	unsigned long flags;
+	int __user *parent_tidp;
+	int __user *child_tidp;
+	unsigned long __user stack;
+	unsigned long stack_size;
+
+	rc = fetch_clone_args_from_user(uca, args_size, &kca);
+	if (rc)
+		return rc;
+
+	/*
+	 * TODO: Convert 'clone-flags' to 64-bits on all architectures.
+	 * TODO: When ->clone_flags_high is non-zero, copy it in to the
+	 * 	 higher word(s) of 'flags':
+	 *
+	 * 		flags = (kca.clone_flags_high << 32) | flags_low;
+	 */
+	flags = flags_low;
+	parent_tidp = (int *)(unsigned long)kca.parent_tid_ptr;
+	child_tidp = (int *)(unsigned long)kca.child_tid_ptr;
+
+	stack_size = (unsigned long)kca.child_stack_size;
+	if (stack_size)
+		return -EINVAL;
+
+	stack = (unsigned long)kca.child_stack;
+	if (!stack)
+		stack = regs->sp;
+
+	return do_fork_with_pids(flags, stack, regs, stack_size, parent_tidp,
+				child_tidp, kca.nr_pids, pids);
+}
+
 /*
  * This gets run with %si containing the
  * function to call, and %di containing
@@ -677,4 +716,3 @@ unsigned long arch_randomize_brk(struct mm_struct *mm)
 	unsigned long range_end = mm->brk + 0x02000000;
 	return randomize_range(mm->brk, range_end, 0) ? : mm->brk;
 }
-
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index 15228b5..22ae7ef 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -337,3 +337,4 @@ ENTRY(sys_call_table)
 	.long sys_rt_tgsigqueueinfo	/* 335 */
 	.long sys_perf_event_open
 	.long sys_recvmmsg
+	.long ptregs_eclone
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 4f079f7..bcc44ad 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2189,6 +2189,8 @@ extern int disallow_signal(int);
 
 extern int do_execve(char *, char __user * __user *, char __user * __user *, struct pt_regs *);
 extern long do_fork(unsigned long, unsigned long, struct pt_regs *, unsigned long, int __user *, int __user *);
+extern int fetch_clone_args_from_user(struct clone_args __user *, int,
+				struct clone_args *);
 extern long do_fork_with_pids(unsigned long, unsigned long, struct pt_regs *,
 				unsigned long, int __user *, int __user *,
 				unsigned int, pid_t __user *);
diff --git a/include/linux/types.h b/include/linux/types.h
index c42724f..d8bfd6b 100644
--- a/include/linux/types.h
+++ b/include/linux/types.h
@@ -204,6 +204,22 @@ struct ustat {
 	char			f_fpack[6];
 };
 
+struct clone_args {
+	u64 clone_flags_high;
+	/*
+	 * Architectures can use child_stack for either the stack pointer or
+	 * the base of of stack. If child_stack is used as the stack pointer,
+	 * child_stack_size must be 0. Otherwise child_stack_size must be
+	 * set to size of allocated stack.
+	 */
+	u64 child_stack;
+	u64 child_stack_size;
+	u64 parent_tid_ptr;
+	u64 child_tid_ptr;
+	u32 nr_pids;
+	u32 reserved0;
+};
+
 #endif	/* __KERNEL__ */
 #endif /*  __ASSEMBLY__ */
 #endif /* _LINUX_TYPES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index fb92128..0f202ae 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1370,6 +1370,114 @@ struct task_struct * __cpuinit fork_idle(int cpu)
 }
 
 /*
+ * If user specified any 'target-pids' in @upid_setp, copy them from
+ * user and return a pointer to a local copy of the list of pids. The
+ * caller must free the list, when they are done using it.
+ *
+ * If user did not specify any target pids, return NULL (caller should
+ * treat this like normal clone).
+ *
+ * On any errors, return the error code
+ */
+static pid_t *copy_target_pids(int unum_pids, pid_t __user *upids)
+{
+	int j;
+	int rc;
+	int size;
+	int knum_pids;		/* # of pids needed in kernel */
+	pid_t *target_pids;
+
+	if (!unum_pids)
+		return NULL;
+
+	knum_pids = task_pid(current)->level + 1;
+	if (unum_pids > knum_pids)
+		return ERR_PTR(-EINVAL);
+
+	/*
+	 * To keep alloc_pid() simple, allocate an extra pid_t in target_pids[]
+	 * and set it to 0. This last entry in target_pids[] corresponds to the
+	 * (yet-to-be-created) descendant pid-namespace if CLONE_NEWPID was
+	 * specified. If CLONE_NEWPID was not specified, this last entry will
+	 * simply be ignored.
+	 */
+	target_pids = kzalloc((knum_pids + 1) * sizeof(pid_t), GFP_KERNEL);
+	if (!target_pids)
+		return ERR_PTR(-ENOMEM);
+
+	/*
+	 * A process running in a level 2 pid namespace has three pid namespaces
+	 * and hence three pid numbers. If this process is checkpointed,
+	 * information about these three namespaces are saved. We refer to these
+	 * namespaces as 'known namespaces'.
+	 *
+	 * If this checkpointed process is however restarted in a level 3 pid
+	 * namespace, the restarted process has an extra ancestor pid namespace
+	 * (i.e 'unknown namespace') and 'knum_pids' exceeds 'unum_pids'.
+	 *
+	 * During restart, the process requests specific pids for its 'known
+	 * namespaces' and lets kernel assign pids to its 'unknown namespaces'.
+	 *
+	 * Since the requested-pids correspond to 'known namespaces' and since
+	 * 'known-namespaces' are younger than (i.e descendants of) 'unknown-
+	 * namespaces', copy requested pids to the back-end of target_pids[]
+	 * (i.e before the last entry for CLONE_NEWPID mentioned above).
+	 * Any entries in target_pids[] not corresponding to a requested pid
+	 * will be set to zero and kernel assigns a pid in those namespaces.
+	 *
+	 * NOTE: The order of pids in target_pids[] is oldest pid namespace to
+	 * 	 youngest (target_pids[0] corresponds to init_pid_ns). i.e.
+	 * 	 the order is:
+	 *
+	 * 		- pids for 'unknown-namespaces' (if any)
+	 * 		- pids for 'known-namespaces' (requested pids)
+	 * 		- 0 in the last entry (for CLONE_NEWPID).
+	 */
+	j = knum_pids - unum_pids;
+	size = unum_pids * sizeof(pid_t);
+
+	rc = copy_from_user(&target_pids[j], upids, size);
+	if (rc) {
+		rc = -EFAULT;
+		goto out_free;
+	}
+
+	return target_pids;
+
+out_free:
+	kfree(target_pids);
+	return ERR_PTR(rc);
+}
+
+int
+fetch_clone_args_from_user(struct clone_args __user *uca, int args_size,
+			struct clone_args *kca)
+{
+	int rc;
+
+	/*
+	 * TODO: If size of clone_args is not what the kernel expects, it
+	 * 	 could be that kernel is newer and has an extended structure.
+	 * 	 When that happens, this check needs to be smarter.  For now,
+	 * 	 assume exact match.
+	 */
+	if (args_size != sizeof(struct clone_args))
+		return -EINVAL;
+
+	rc = copy_from_user(kca, uca, args_size);
+	if (rc)
+		return -EFAULT;
+
+	/*
+	 * To avoid future compatibility issues, ensure unused fields are 0.
+	 */
+	if (kca->reserved0 || kca->clone_flags_high)
+		return -EINVAL;
+
+	return 0;
+}
+
+/*
  *  Ok, this is the main fork-routine.
  *
  * It copies the process, and if successful kick-starts
@@ -1387,7 +1495,7 @@ long do_fork_with_pids(unsigned long clone_flags,
 	struct task_struct *p;
 	int trace = 0;
 	long nr;
-	pid_t *target_pids = NULL;
+	pid_t *target_pids;
 
 	/*
 	 * Do some preliminary argument and permissions checking before we
@@ -1421,6 +1529,16 @@ long do_fork_with_pids(unsigned long clone_flags,
 		}
 	}
 
+	target_pids = copy_target_pids(num_pids, upids);
+	if (target_pids) {
+		if (IS_ERR(target_pids))
+			return PTR_ERR(target_pids);
+
+		nr = -EPERM;
+		if (!capable(CAP_SYS_ADMIN))
+			goto out_free;
+	}
+
 	/*
 	 * When called from kernel_thread, don't do user tracing stuff.
 	 */
@@ -1482,6 +1600,10 @@ long do_fork_with_pids(unsigned long clone_flags,
 	} else {
 		nr = PTR_ERR(p);
 	}
+
+out_free:
+	kfree(target_pids);
+
 	return nr;
 }
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
