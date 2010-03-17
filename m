Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E86836B01C7
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:12:10 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 09/96] eclone (9/11): Implement sys_eclone for s390
Date: Wed, 17 Mar 2010 12:07:57 -0400
Message-Id: <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

From: Serge E. Hallyn <serue@us.ibm.com>

Implement the s390 hook for sys_eclone().

Changelog:
	Nov 24: Removed user-space code from commit log. See user-cr git tree.
	Nov 17: remove redundant flags_high check
	Nov 13: As suggested by Heiko, convert eclone to take its
		parameters via registers.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 arch/s390/include/asm/unistd.h    |    3 ++-
 arch/s390/kernel/compat_linux.c   |   17 +++++++++++++++++
 arch/s390/kernel/compat_wrapper.S |    8 ++++++++
 arch/s390/kernel/process.c        |   37 +++++++++++++++++++++++++++++++++++++
 arch/s390/kernel/syscalls.S       |    1 +
 5 files changed, 65 insertions(+), 1 deletions(-)

diff --git a/arch/s390/include/asm/unistd.h b/arch/s390/include/asm/unistd.h
index 6e9f049..2250950 100644
--- a/arch/s390/include/asm/unistd.h
+++ b/arch/s390/include/asm/unistd.h
@@ -269,7 +269,8 @@
 #define	__NR_pwritev		329
 #define __NR_rt_tgsigqueueinfo	330
 #define __NR_perf_event_open	331
-#define NR_syscalls 332
+#define __NR_eclone		332
+#define NR_syscalls 333
 
 /* 
  * There are some system calls that are not present on 64 bit, some
diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index 11c3aba..f9e8983 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -663,6 +663,23 @@ asmlinkage long sys32_write(unsigned int fd, char __user * buf, size_t count)
 	return sys_write(fd, buf, count);
 }
 
+asmlinkage long sys32_clone(void)
+{
+	struct pt_regs *regs = task_pt_regs(current);
+	unsigned long clone_flags;
+	unsigned long newsp;
+	int __user *parent_tidptr, *child_tidptr;
+
+	clone_flags = regs->gprs[3] & 0xffffffffUL;
+	newsp = regs->orig_gpr2 & 0x7fffffffUL;
+	parent_tidptr = compat_ptr(regs->gprs[4]);
+	child_tidptr = compat_ptr(regs->gprs[5]);
+	if (!newsp)
+		newsp = regs->gprs[15];
+	return do_fork(clone_flags, newsp, regs, 0,
+		       parent_tidptr, child_tidptr);
+}
+
 /*
  * 31 bit emulation wrapper functions for sys_fadvise64/fadvise64_64.
  * These need to rewrite the advise values for POSIX_FADV_{DONTNEED,NOREUSE}
diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
index 30de2d0..cfa227e 100644
--- a/arch/s390/kernel/compat_wrapper.S
+++ b/arch/s390/kernel/compat_wrapper.S
@@ -1847,6 +1847,14 @@ sys_clone_wrapper:
 	llgtr	%r5,%r5			# int *
 	jg	sys_clone		# branch to system call
 
+	.globl	sys_eclone_wrapper
+sys_eclone_wrapper:
+	llgfr	%r2,%r2			# unsigned int
+	llgtr	%r3,%r3			# struct clone_args *
+	lgfr	%r4,%r4			# int
+	llgtr	%r5,%r5			# pid_t *
+	jg	sys_eclone		# branch to system call
+
 	.globl	sys32_execve_wrapper
 sys32_execve_wrapper:
 	llgtr	%r2,%r2			# char *
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index 00b6d1d..5b0729a 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -240,6 +240,43 @@ SYSCALL_DEFINE4(clone, unsigned long, newsp, unsigned long, clone_flags,
 		       parent_tidptr, child_tidptr);
 }
 
+SYSCALL_DEFINE4(eclone, unsigned int, flags_low, struct clone_args __user *,
+		uca, int, args_size, pid_t __user *, pids)
+{
+	int rc;
+	struct pt_regs *regs = task_pt_regs(current);
+	struct clone_args kca;
+	int __user *parent_tid_ptr;
+	int __user *child_tid_ptr;
+	unsigned long flags;
+	unsigned long __user child_stack;
+	unsigned long stack_size;
+
+	rc = fetch_clone_args_from_user(uca, args_size, &kca);
+	if (rc)
+		return rc;
+
+	flags = flags_low;
+	parent_tid_ptr = (int __user *) kca.parent_tid_ptr;
+	child_tid_ptr =  (int __user *) kca.child_tid_ptr;
+
+	stack_size = (unsigned long) kca.child_stack_size;
+	if (stack_size)
+		return -EINVAL;
+
+	child_stack = (unsigned long) kca.child_stack;
+	if (!child_stack)
+		child_stack = regs->gprs[15];
+
+	/*
+	 * TODO: On 32-bit systems, clone_flags is passed in as 32-bit value
+	 * 	 to several functions. Need to convert clone_flags to 64-bit.
+	 */
+	return do_fork_with_pids(flags, child_stack, regs, stack_size,
+				parent_tid_ptr, child_tid_ptr, kca.nr_pids,
+				pids);
+}
+
 /*
  * This is trivial, and on the face of it looks like it
  * could equally well be done in user mode.
diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
index 30eca07..fb8708d 100644
--- a/arch/s390/kernel/syscalls.S
+++ b/arch/s390/kernel/syscalls.S
@@ -340,3 +340,4 @@ SYSCALL(sys_preadv,sys_preadv,compat_sys_preadv_wrapper)
 SYSCALL(sys_pwritev,sys_pwritev,compat_sys_pwritev_wrapper)
 SYSCALL(sys_rt_tgsigqueueinfo,sys_rt_tgsigqueueinfo,compat_sys_rt_tgsigqueueinfo_wrapper) /* 330 */
 SYSCALL(sys_perf_event_open,sys_perf_event_open,sys_perf_event_open_wrapper)
+SYSCALL(sys_eclone,sys_eclone,sys_eclone_wrapper)
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
