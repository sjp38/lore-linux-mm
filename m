Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 137EA6B007D
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 01:56:39 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8G5ueRj001985
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Sep 2010 14:56:40 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F18A745DE4F
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 14:56:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CD41545DE53
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 14:56:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B40431DB8012
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 14:56:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 599261DB8014
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 14:56:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/4] move cred_guard_mutex from task_struct to signal_struct
In-Reply-To: <20100916144930.3BAE.A69D9226@jp.fujitsu.com>
References: <20100916144930.3BAE.A69D9226@jp.fujitsu.com>
Message-Id: <20100916145623.3BB7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Sep 2010 14:56:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, oss-security@lists.openwall.com, Solar Designer <solar@openwall.com>, Kees Cook <kees.cook@canonical.com>, Al Viro <viro@zeniv.linux.org.uk>, Oleg Nesterov <oleg@redhat.com>, Neil Horman <nhorman@tuxdriver.com>, linux-fsdevel@vger.kernel.org, pageexec@freemail.hu, Brad Spengler <spender@grsecurity.net>, Eugene Teo <eugene@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>


Changelog
  o since v1
    - function comment also change current->cred_guard_mutex to
      current->signal->cred_guard_mutex.

Oleg Nesterov pointed out we have to prevent multiple-threads-inside-exec
itself and we can reuse ->cred_guard_mutex for it. Yes, concurrent
execve() has no worth.

Let's move ->cred_guard_mutex from task_struct to signal_struct. It
naturally prevent multiple-threads-inside-exec.

Reviewed-by: Oleg Nesterov <oleg@redhat.com>
Cc: Roland McGrath <roland@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/exec.c                 |   10 +++++-----
 fs/proc/base.c            |    8 ++++----
 include/linux/init_task.h |    4 ++--
 include/linux/sched.h     |    7 ++++---
 include/linux/tracehook.h |    2 +-
 kernel/cred.c             |    4 +---
 kernel/fork.c             |    2 ++
 kernel/ptrace.c           |    4 ++--
 8 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 2d94552..160eb46 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1064,14 +1064,14 @@ EXPORT_SYMBOL(setup_new_exec);
  */
 int prepare_bprm_creds(struct linux_binprm *bprm)
 {
-	if (mutex_lock_interruptible(&current->cred_guard_mutex))
+	if (mutex_lock_interruptible(&current->signal->cred_guard_mutex))
 		return -ERESTARTNOINTR;
 
 	bprm->cred = prepare_exec_creds();
 	if (likely(bprm->cred))
 		return 0;
 
-	mutex_unlock(&current->cred_guard_mutex);
+	mutex_unlock(&current->signal->cred_guard_mutex);
 	return -ENOMEM;
 }
 
@@ -1079,7 +1079,7 @@ void free_bprm(struct linux_binprm *bprm)
 {
 	free_arg_pages(bprm);
 	if (bprm->cred) {
-		mutex_unlock(&current->cred_guard_mutex);
+		mutex_unlock(&current->signal->cred_guard_mutex);
 		abort_creds(bprm->cred);
 	}
 	kfree(bprm);
@@ -1100,13 +1100,13 @@ void install_exec_creds(struct linux_binprm *bprm)
 	 * credentials; any time after this it may be unlocked.
 	 */
 	security_bprm_committed_creds(bprm);
-	mutex_unlock(&current->cred_guard_mutex);
+	mutex_unlock(&current->signal->cred_guard_mutex);
 }
 EXPORT_SYMBOL(install_exec_creds);
 
 /*
  * determine how safe it is to execute the proposed program
- * - the caller must hold current->cred_guard_mutex to protect against
+ * - the caller must hold ->cred_guard_mutex to protect against
  *   PTRACE_ATTACH
  */
 int check_unsafe_exec(struct linux_binprm *bprm)
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 55a16f2..fd97c8f 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -226,7 +226,7 @@ struct mm_struct *mm_for_maps(struct task_struct *task)
 {
 	struct mm_struct *mm;
 
-	if (mutex_lock_killable(&task->cred_guard_mutex))
+	if (mutex_lock_killable(&task->signal->cred_guard_mutex))
 		return NULL;
 
 	mm = get_task_mm(task);
@@ -235,7 +235,7 @@ struct mm_struct *mm_for_maps(struct task_struct *task)
 		mmput(mm);
 		mm = NULL;
 	}
-	mutex_unlock(&task->cred_guard_mutex);
+	mutex_unlock(&task->signal->cred_guard_mutex);
 
 	return mm;
 }
@@ -2273,14 +2273,14 @@ static ssize_t proc_pid_attr_write(struct file * file, const char __user * buf,
 		goto out_free;
 
 	/* Guard against adverse ptrace interaction */
-	length = mutex_lock_interruptible(&task->cred_guard_mutex);
+	length = mutex_lock_interruptible(&task->signal->cred_guard_mutex);
 	if (length < 0)
 		goto out_free;
 
 	length = security_setprocattr(task,
 				      (char*)file->f_path.dentry->d_name.name,
 				      (void*)page, count);
-	mutex_unlock(&task->cred_guard_mutex);
+	mutex_unlock(&task->signal->cred_guard_mutex);
 out_free:
 	free_page((unsigned long) page);
 out:
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 1f43fa5..ff3cc33 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -29,6 +29,8 @@ extern struct fs_struct init_fs;
 		.running = 0,						\
 		.lock = __SPIN_LOCK_UNLOCKED(sig.cputimer.lock),	\
 	},								\
+	.cred_guard_mutex =						\
+		 __MUTEX_INITIALIZER(sig.cred_guard_mutex),		\
 }
 
 extern struct nsproxy init_nsproxy;
@@ -139,8 +141,6 @@ extern struct cred init_cred;
 	.group_leader	= &tsk,						\
 	.real_cred	= &init_cred,					\
 	.cred		= &init_cred,					\
-	.cred_guard_mutex =						\
-		 __MUTEX_INITIALIZER(tsk.cred_guard_mutex),		\
 	.comm		= "swapper",					\
 	.thread		= INIT_THREAD,					\
 	.fs		= &init_fs,					\
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5e61d60..960a867 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -623,6 +623,10 @@ struct signal_struct {
 
 	int oom_adj;		/* OOM kill score adjustment (bit shift) */
 	long oom_score_adj;	/* OOM kill score adjustment */
+
+	struct mutex cred_guard_mutex;	/* guard against foreign influences on
+					 * credential calculations
+					 * (notably. ptrace) */
 };
 
 /* Context switch must be unlocked if interrupts are to be enabled */
@@ -1292,9 +1296,6 @@ struct task_struct {
 					 * credentials (COW) */
 	const struct cred *cred;	/* effective (overridable) subjective task
 					 * credentials (COW) */
-	struct mutex cred_guard_mutex;	/* guard against foreign influences on
-					 * credential calculations
-					 * (notably. ptrace) */
 	struct cred *replacement_session_keyring; /* for KEYCTL_SESSION_TO_PARENT */
 
 	char comm[TASK_COMM_LEN]; /* executable name excluding path
diff --git a/include/linux/tracehook.h b/include/linux/tracehook.h
index 10db010..3a2e66d 100644
--- a/include/linux/tracehook.h
+++ b/include/linux/tracehook.h
@@ -150,7 +150,7 @@ static inline void tracehook_report_syscall_exit(struct pt_regs *regs, int step)
  *
  * Return %LSM_UNSAFE_* bits applied to an exec because of tracing.
  *
- * @task->cred_guard_mutex is held by the caller through the do_execve().
+ * @task->signal->cred_guard_mutex is held by the caller through the do_execve().
  */
 static inline int tracehook_unsafe_exec(struct task_struct *task)
 {
diff --git a/kernel/cred.c b/kernel/cred.c
index 9a3e226..6a1aa00 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -325,7 +325,7 @@ EXPORT_SYMBOL(prepare_creds);
 
 /*
  * Prepare credentials for current to perform an execve()
- * - The caller must hold current->cred_guard_mutex
+ * - The caller must hold ->cred_guard_mutex
  */
 struct cred *prepare_exec_creds(void)
 {
@@ -384,8 +384,6 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 	struct cred *new;
 	int ret;
 
-	mutex_init(&p->cred_guard_mutex);
-
 	if (
 #ifdef CONFIG_KEYS
 		!p->cred->thread_keyring &&
diff --git a/kernel/fork.c b/kernel/fork.c
index b7e9d60..4c0d3ea 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -904,6 +904,8 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	sig->oom_adj = current->signal->oom_adj;
 	sig->oom_score_adj = current->signal->oom_score_adj;
 
+	mutex_init(&sig->cred_guard_mutex);
+
 	return 0;
 }
 
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index f34d798..ac5013a 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -181,7 +181,7 @@ int ptrace_attach(struct task_struct *task)
 	 * under ptrace.
 	 */
 	retval = -ERESTARTNOINTR;
-	if (mutex_lock_interruptible(&task->cred_guard_mutex))
+	if (mutex_lock_interruptible(&task->signal->cred_guard_mutex))
 		goto out;
 
 	task_lock(task);
@@ -208,7 +208,7 @@ int ptrace_attach(struct task_struct *task)
 unlock_tasklist:
 	write_unlock_irq(&tasklist_lock);
 unlock_creds:
-	mutex_unlock(&task->cred_guard_mutex);
+	mutex_unlock(&task->signal->cred_guard_mutex);
 out:
 	return retval;
 }
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
