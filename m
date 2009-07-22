Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C8EDD6B00A3
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:10:20 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 56/60] c/r: clone_with_pids: define the s390 syscall
Date: Wed, 22 Jul 2009 06:00:18 -0400
Message-Id: <1248256822-23416-57-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Serge E. Hallyn <serue@us.ibm.com>

Hook up the clone_with_pids system call for s390x.  clone_with_pids()
takes an additional argument over clone(), which we pass in through
register 7.  Stub code for using the syscall looks like:

struct target_pid_set {
        int num_pids;
        pid_t *target_pids;
        unsigned long flags;
};

    register unsigned long int __r2 asm ("2") = (unsigned long int)(stack);
    register unsigned long int __r3 asm ("3") = (unsigned long int)(flags);
    register unsigned long int __r4 asm ("4") = (unsigned long int)(NULL);
    register unsigned long int __r5 asm ("5") = (unsigned long int)(NULL);
    register unsigned long int __r6 asm ("6") = (unsigned long int)(NULL);
    register unsigned long int __r7 asm ("7") = (unsigned long int)(setp);
    register unsigned long int __result asm ("2");
    __asm__ __volatile__(
            " lghi %%r1,332\n"
            " svc 0\n"
            : "=d" (__result)
            : "0" (__r2), "d" (__r3),
              "d" (__r4), "d" (__r5), "d" (__r6), "d" (__r7)
            : "1", "cc", "memory"
    );
            __result;
    })

    struct target_pid_set pid_set;
    int pids[1] = { 19799 };
    pid_set.num_pids = 1;
    pid_set.target_pids = &pids[0];
    pid_set.flags = 0;

    rc = do_clone_with_pids(topstack, clone_flags, setp);
    if (rc == 0)
	printf("Child\n");
    else if (rc > 0)
	printf("Parent: child pid %d\n", rc);
    else
	printf("Error %d\n", rc);

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 arch/s390/include/asm/unistd.h  |    3 ++-
 arch/s390/kernel/compat_linux.c |   19 +++++++++++++++++++
 arch/s390/kernel/process.c      |   19 +++++++++++++++++++
 arch/s390/kernel/syscalls.S     |    1 +
 4 files changed, 41 insertions(+), 1 deletions(-)

diff --git a/arch/s390/include/asm/unistd.h b/arch/s390/include/asm/unistd.h
index 5d1678a..2a84f9c 100644
--- a/arch/s390/include/asm/unistd.h
+++ b/arch/s390/include/asm/unistd.h
@@ -271,7 +271,8 @@
 #define __NR_perf_counter_open	331
 #define __NR_checkpoint		332
 #define __NR_restart		333
-#define NR_syscalls 334
+#define __NR_clone_with_pids	334
+#define NR_syscalls 335
 
 /* 
  * There are some system calls that are not present on 64 bit, some
diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index 9ab188d..c6dc681 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -818,6 +818,25 @@ asmlinkage long sys32_clone(void)
 		       parent_tidptr, child_tidptr);
 }
 
+asmlinkage long sys32_clone_with_pids(void)
+{
+	struct pt_regs *regs = task_pt_regs(current);
+	unsigned long clone_flags;
+	unsigned long newsp;
+	int __user *parent_tidptr, *child_tidptr;
+	void __user *upid_setp;
+
+	clone_flags = regs->gprs[3] & 0xffffffffUL;
+	newsp = regs->orig_gpr2 & 0x7fffffffUL;
+	parent_tidptr = compat_ptr(regs->gprs[4]);
+	child_tidptr = compat_ptr(regs->gprs[5]);
+	upid_setp = compat_ptr(regs->gprs[7]);
+	if (!newsp)
+		newsp = regs->gprs[15];
+	return do_fork_with_pids(clone_flags, newsp, regs, 0,
+		       parent_tidptr, child_tidptr, upid_setp);
+}
+
 /*
  * 31 bit emulation wrapper functions for sys_fadvise64/fadvise64_64.
  * These need to rewrite the advise values for POSIX_FADV_{DONTNEED,NOREUSE}
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index 5a43f27..263d3ab 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -247,6 +247,25 @@ SYSCALL_DEFINE0(clone)
 		       parent_tidptr, child_tidptr);
 }
 
+SYSCALL_DEFINE0(clone_with_pids)
+{
+	struct pt_regs *regs = task_pt_regs(current);
+	unsigned long clone_flags;
+	unsigned long newsp;
+	int __user *parent_tidptr, *child_tidptr;
+	void __user *upid_setp;
+
+	clone_flags = regs->gprs[3];
+	newsp = regs->orig_gpr2;
+	parent_tidptr = (int __user *) regs->gprs[4];
+	child_tidptr = (int __user *) regs->gprs[5];
+	upid_setp = (void __user *) regs->gprs[7];
+	if (!newsp)
+		newsp = regs->gprs[15];
+	return do_fork_with_pids(clone_flags, newsp, regs, 0, parent_tidptr,
+			child_tidptr, upid_setp);
+}
+
 /*
  * This is trivial, and on the face of it looks like it
  * could equally well be done in user mode.
diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
index 67518e2..db850e7 100644
--- a/arch/s390/kernel/syscalls.S
+++ b/arch/s390/kernel/syscalls.S
@@ -342,3 +342,4 @@ SYSCALL(sys_rt_tgsigqueueinfo,sys_rt_tgsigqueueinfo,compat_sys_rt_tgsigqueueinfo
 SYSCALL(sys_perf_counter_open,sys_perf_counter_open,sys_perf_counter_open_wrapper)
 SYSCALL(sys_checkpoint,sys_checkpoint,sys_checkpoint_wrapper)
 SYSCALL(sys_restart,sys_restart,sys_restore_wrapper)
+SYSCALL(sys_clone_with_pids,sys_clone_with_pids,sys_clone_with_pids_wrapper)
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
