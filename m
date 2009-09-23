Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E5C496B00A7
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:39 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 16/80] pids 6/7: Define do_fork_with_pids()
Date: Wed, 23 Sep 2009 19:50:56 -0400
Message-Id: <1253749920-18673-17-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>

do_fork_with_pids() is same as do_fork(), except that it takes an
additional, 'pid_set', parameter. This parameter, currently unused,
specifies the set of target pids of the process in each of its pid
namespaces.

Changelog[v3]:
	- Fix "long-line" warning from checkpatch.pl

Changelog[v2]:
	- To facilitate moving architecture-inpdendent code to kernel/fork.c
	  pass in 'struct target_pid_set __user *' to do_fork_with_pids()
	  rather than 'pid_t *' (next patch moves the arch-independent
	  code to kernel/fork.c)

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Reviewed-by: Oren Laadan <orenl@cs.columbia.edu>
---
 include/linux/sched.h |    3 +++
 include/linux/types.h |    5 +++++
 kernel/fork.c         |   16 ++++++++++++++--
 3 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0f1ea4a..2fa783d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2054,6 +2054,9 @@ extern int disallow_signal(int);
 
 extern int do_execve(char *, char __user * __user *, char __user * __user *, struct pt_regs *);
 extern long do_fork(unsigned long, unsigned long, struct pt_regs *, unsigned long, int __user *, int __user *);
+extern long do_fork_with_pids(unsigned long, unsigned long, struct pt_regs *,
+				unsigned long, int __user *, int __user *,
+				struct target_pid_set __user *pid_set);
 struct task_struct *fork_idle(int);
 
 extern void set_task_comm(struct task_struct *tsk, char *from);
diff --git a/include/linux/types.h b/include/linux/types.h
index c42724f..d9efefe 100644
--- a/include/linux/types.h
+++ b/include/linux/types.h
@@ -204,6 +204,11 @@ struct ustat {
 	char			f_fpack[6];
 };
 
+struct target_pid_set {
+	int num_pids;
+	pid_t *target_pids;
+};
+
 #endif	/* __KERNEL__ */
 #endif /*  __ASSEMBLY__ */
 #endif /* _LINUX_TYPES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 5156d02..59b21db 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1332,12 +1332,13 @@ struct task_struct * __cpuinit fork_idle(int cpu)
  * It copies the process, and if successful kick-starts
  * it and waits for it to finish using the VM if required.
  */
-long do_fork(unsigned long clone_flags,
+long do_fork_with_pids(unsigned long clone_flags,
 	      unsigned long stack_start,
 	      struct pt_regs *regs,
 	      unsigned long stack_size,
 	      int __user *parent_tidptr,
-	      int __user *child_tidptr)
+	      int __user *child_tidptr,
+	      struct target_pid_set __user *pid_setp)
 {
 	struct task_struct *p;
 	int trace = 0;
@@ -1440,6 +1441,17 @@ long do_fork(unsigned long clone_flags,
 	return nr;
 }
 
+long do_fork(unsigned long clone_flags,
+	      unsigned long stack_start,
+	      struct pt_regs *regs,
+	      unsigned long stack_size,
+	      int __user *parent_tidptr,
+	      int __user *child_tidptr)
+{
+	return do_fork_with_pids(clone_flags, stack_start, regs, stack_size,
+			parent_tidptr, child_tidptr, NULL);
+}
+
 #ifndef ARCH_MIN_MMSTRUCT_ALIGN
 #define ARCH_MIN_MMSTRUCT_ALIGN 0
 #endif
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
