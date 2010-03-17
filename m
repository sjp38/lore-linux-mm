Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2DD776B01BD
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:10:15 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 07/96] eclone (7/11): Define do_fork_with_pids()
Date: Wed, 17 Mar 2010 12:07:55 -0400
Message-Id: <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>

do_fork_with_pids() is same as do_fork(), except that it takes an
additional, 'pid_set', parameter. This parameter, currently unused,
specifies the set of target pids of the process in each of its pid
namespaces.

Changelog[v7]:
	- Drop 'struct pid_set' object and pass in 'pid_t *target_pids'
	  instead of 'struct pid_set *'.

Changelog[v6]:
	- (Nathan Lynch, Arnd Bergmann, H. Peter Anvin, Linus Torvalds)
	  Change 'pid_set.pids' to a 'pid_t pids[]' so size of 'struct pid_set'
	  is constant across architectures.
	- (Nathan Lynch) Change 'pid_set.num_pids' to 'unsigned int'.

Changelog[v4]:
	- Rename 'struct target_pid_set' to 'struct pid_set' since it may
	  be useful in other contexts.

Changelog[v3]:
	- Fix "long-line" warning from checkpatch.pl

Changelog[v2]:
	- To facilitate moving architecture-inpdendent code to kernel/fork.c
	  pass in 'struct target_pid_set __user *' to do_fork_with_pids()
	  rather than 'pid_t *' (next patch moves the arch-independent
	  code to kernel/fork.c)

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
Reviewed-by: Oren Laadan <orenl@cs.columbia.edu>
---
 include/linux/sched.h |    3 +++
 kernel/fork.c         |   17 +++++++++++++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index d57eab8..4f079f7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2189,6 +2189,9 @@ extern int disallow_signal(int);
 
 extern int do_execve(char *, char __user * __user *, char __user * __user *, struct pt_regs *);
 extern long do_fork(unsigned long, unsigned long, struct pt_regs *, unsigned long, int __user *, int __user *);
+extern long do_fork_with_pids(unsigned long, unsigned long, struct pt_regs *,
+				unsigned long, int __user *, int __user *,
+				unsigned int, pid_t __user *);
 struct task_struct *fork_idle(int);
 
 extern void set_task_comm(struct task_struct *tsk, char *from);
diff --git a/kernel/fork.c b/kernel/fork.c
index f95cbd2..fb92128 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1375,12 +1375,14 @@ struct task_struct * __cpuinit fork_idle(int cpu)
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
+	      unsigned int num_pids,
+	      pid_t __user *upids)
 {
 	struct task_struct *p;
 	int trace = 0;
@@ -1483,6 +1485,17 @@ long do_fork(unsigned long clone_flags,
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
+			parent_tidptr, child_tidptr, 0, NULL);
+}
+
 #ifndef ARCH_MIN_MMSTRUCT_ALIGN
 #define ARCH_MIN_MMSTRUCT_ALIGN 0
 #endif
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
