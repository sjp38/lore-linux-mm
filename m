Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 38CF66B0253
	for <linux-mm@kvack.org>; Sun,  8 Nov 2015 07:10:44 -0500 (EST)
Received: by wiby19 with SMTP id y19so589779wib.0
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 04:10:43 -0800 (PST)
Received: from thejh.net (thejh.net. [37.221.195.125])
        by mx.google.com with ESMTP id vu8si3990079wjc.28.2015.11.08.04.10.42
        for <linux-mm@kvack.org>;
        Sun, 08 Nov 2015 04:10:42 -0800 (PST)
From: Jann Horn <jann@thejh.net>
Subject: [PATCH] ptrace: use fsuid, fsgid, effective creds for fs access checks
Date: Sun,  8 Nov 2015 13:08:36 +0100
Message-Id: <1446984516-1784-1-git-send-email-jann@thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "Eric W. Biederman" <ebiederm@xmission.com>, Joe Perches <joe@perches.com>, Thomas Gleixner <tglx@linutronix.de>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, linux-api@vger.kernel.org, security@kernel.org, Willy Tarreau <w@1wt.eu>, Kees Cook <keescook@google.com>, Jann Horn <jann@thejh.net>

By checking the effective credentials instead of the real UID /
permitted capabilities, ensure that the calling process actually
intended to use its credentials.

To ensure that all ptrace checks use the correct caller
credentials (e.g. in case out-of-tree code or newly added code
omits the PTRACE_MODE_*CREDS flag), use two new flags and
require one of them to be set.

The problem was that when a privileged task had temporarily dropped
its privileges, e.g. by calling setreuid(0, user_uid), with the
intent to perform following syscalls with the credentials of
a user, it still passed ptrace access checks that the user would
not be able to pass.

While an attacker should not be able to convince the privileged
task to perform a ptrace() syscall, this is a problem because the
ptrace access check is reused for things in procfs.

In particular, the following somewhat interesting procfs entries
only rely on ptrace access checks:

 /proc/$pid/stat - uses the check for determining whether pointers
     should be visible, useful for bypassing ASLR
 /proc/$pid/maps - also useful for bypassing ASLR
 /proc/$pid/cwd - useful for gaining access to restricted
     directories that contain files with lax permissions, e.g. in
     this scenario:
     lrwxrwxrwx root root /proc/13020/cwd -> /root/foobar
     drwx------ root root /root
     drwxr-xr-x root root /root/foobar
     -rw-r--r-- root root /root/foobar/secret

Therefore, on a system where a root-owned mode 6755 binary
changes its effective credentials as described and then dumps a
user-specified file, this could be used by an attacker to reveal
the memory layout of root's processes or reveal the contents of
files he is not allowed to access (through /proc/$pid/cwd).

Signed-off-by: Jann Horn <jann@thejh.net>
---
 fs/proc/array.c        |  3 ++-
 fs/proc/base.c         | 24 ++++++++++++++----------
 fs/proc/namespaces.c   |  4 ++--
 include/linux/ptrace.h | 17 ++++++++++++++++-
 kernel/events/core.c   |  2 +-
 kernel/futex.c         |  2 +-
 kernel/futex_compat.c  |  2 +-
 kernel/kcmp.c          |  6 ++++--
 kernel/ptrace.c        | 37 ++++++++++++++++++++++++++++++-------
 mm/process_vm_access.c |  2 +-
 security/commoncap.c   |  7 ++++++-
 11 files changed, 78 insertions(+), 28 deletions(-)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index f60f012..00928c6 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -395,7 +395,8 @@ static int do_task_stat(struct seq_file *m, struct pid_namespace *ns,
 
 	state = *get_task_state(task);
 	vsize = eip = esp = 0;
-	permitted = ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_NOAUDIT);
+	permitted = ptrace_may_access(task,
+		PTRACE_MODE_READ | PTRACE_MODE_NOAUDIT | PTRACE_MODE_FSCREDS);
 	mm = get_task_mm(task);
 	if (mm) {
 		vsize = task_vsize(mm);
diff --git a/fs/proc/base.c b/fs/proc/base.c
index b25eee4..d6b9475 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -403,7 +403,8 @@ static const struct file_operations proc_pid_cmdline_ops = {
 static int proc_pid_auxv(struct seq_file *m, struct pid_namespace *ns,
 			 struct pid *pid, struct task_struct *task)
 {
-	struct mm_struct *mm = mm_access(task, PTRACE_MODE_READ);
+	struct mm_struct *mm = mm_access(task,
+		PTRACE_MODE_READ | PTRACE_MODE_FSCREDS);
 	if (mm && !IS_ERR(mm)) {
 		unsigned int nwords = 0;
 		do {
@@ -431,7 +432,8 @@ static int proc_pid_wchan(struct seq_file *m, struct pid_namespace *ns,
 	wchan = get_wchan(task);
 
 	if (lookup_symbol_name(wchan, symname) < 0) {
-		if (!ptrace_may_access(task, PTRACE_MODE_READ))
+		if (!ptrace_may_access(task,
+				PTRACE_MODE_READ | PTRACE_MODE_FSCREDS))
 			return 0;
 		seq_printf(m, "%lu", wchan);
 	} else {
@@ -447,7 +449,8 @@ static int lock_trace(struct task_struct *task)
 	int err = mutex_lock_killable(&task->signal->cred_guard_mutex);
 	if (err)
 		return err;
-	if (!ptrace_may_access(task, PTRACE_MODE_ATTACH)) {
+	if (!ptrace_may_access(task,
+			PTRACE_MODE_ATTACH | PTRACE_MODE_FSCREDS)) {
 		mutex_unlock(&task->signal->cred_guard_mutex);
 		return -EPERM;
 	}
@@ -700,7 +703,8 @@ static int proc_fd_access_allowed(struct inode *inode)
 	 */
 	task = get_proc_task(inode);
 	if (task) {
-		allowed = ptrace_may_access(task, PTRACE_MODE_READ);
+		allowed = ptrace_may_access(task,
+			PTRACE_MODE_READ | PTRACE_MODE_FSCREDS);
 		put_task_struct(task);
 	}
 	return allowed;
@@ -735,7 +739,7 @@ static bool has_pid_permissions(struct pid_namespace *pid,
 		return true;
 	if (in_group_p(pid->pid_gid))
 		return true;
-	return ptrace_may_access(task, PTRACE_MODE_READ);
+	return ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_FSCREDS);
 }
 
 
@@ -812,7 +816,7 @@ struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
 	struct mm_struct *mm = ERR_PTR(-ESRCH);
 
 	if (task) {
-		mm = mm_access(task, mode);
+		mm = mm_access(task, mode | PTRACE_MODE_FSCREDS);
 		put_task_struct(task);
 
 		if (!IS_ERR_OR_NULL(mm)) {
@@ -1849,7 +1853,7 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 	if (!task)
 		goto out_notask;
 
-	mm = mm_access(task, PTRACE_MODE_READ);
+	mm = mm_access(task, PTRACE_MODE_READ | PTRACE_MODE_FSCREDS);
 	if (IS_ERR_OR_NULL(mm))
 		goto out;
 
@@ -2000,7 +2004,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 		goto out;
 
 	result = -EACCES;
-	if (!ptrace_may_access(task, PTRACE_MODE_READ))
+	if (!ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_FSCREDS))
 		goto out_put_task;
 
 	result = -ENOENT;
@@ -2053,7 +2057,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 		goto out;
 
 	ret = -EACCES;
-	if (!ptrace_may_access(task, PTRACE_MODE_READ))
+	if (!ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_FSCREDS))
 		goto out_put_task;
 
 	ret = 0;
@@ -2522,7 +2526,7 @@ static int do_io_accounting(struct task_struct *task, struct seq_file *m, int wh
 	if (result)
 		return result;
 
-	if (!ptrace_may_access(task, PTRACE_MODE_READ)) {
+	if (!ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_FSCREDS)) {
 		result = -EACCES;
 		goto out_unlock;
 	}
diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
index f6e8354..0cbe012 100644
--- a/fs/proc/namespaces.c
+++ b/fs/proc/namespaces.c
@@ -42,7 +42,7 @@ static const char *proc_ns_follow_link(struct dentry *dentry, void **cookie)
 	if (!task)
 		return error;
 
-	if (ptrace_may_access(task, PTRACE_MODE_READ)) {
+	if (ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_FSCREDS)) {
 		error = ns_get_path(&ns_path, task, ns_ops);
 		if (!error)
 			nd_jump_link(&ns_path);
@@ -63,7 +63,7 @@ static int proc_ns_readlink(struct dentry *dentry, char __user *buffer, int bufl
 	if (!task)
 		return res;
 
-	if (ptrace_may_access(task, PTRACE_MODE_READ)) {
+	if (ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_FSCREDS)) {
 		res = ns_get_name(name, sizeof(name), task, ns_ops);
 		if (res >= 0)
 			res = readlink_copy(buffer, buflen, name);
diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
index 061265f..63f4a3c 100644
--- a/include/linux/ptrace.h
+++ b/include/linux/ptrace.h
@@ -57,7 +57,22 @@ extern void exit_ptrace(struct task_struct *tracer, struct list_head *dead);
 #define PTRACE_MODE_READ	0x01
 #define PTRACE_MODE_ATTACH	0x02
 #define PTRACE_MODE_NOAUDIT	0x04
-/* Returns true on success, false on denial. */
+#define PTRACE_MODE_FSCREDS 0x08
+#define PTRACE_MODE_REALCREDS 0x10
+/**
+ * ptrace_may_access - check whether the caller is permitted to access
+ * a target task.
+ * @task: target task
+ * @mode: selects type of access and caller credentials
+ *
+ * Returns true on success, false on denial.
+ *
+ * One of the flags PTRACE_MODE_FSCREDS and PTRACE_MODE_REALCREDS must
+ * be set in @mode to specify whether the access was requested through
+ * a filesystem syscall (should use effective capabilities and fsuid
+ * of the caller) or through an explicit syscall such as
+ * process_vm_writev or ptrace (and should use the real credentials).
+ */
 extern bool ptrace_may_access(struct task_struct *task, unsigned int mode);
 
 static inline int ptrace_reparented(struct task_struct *child)
diff --git a/kernel/events/core.c b/kernel/events/core.c
index b11756f..0decdf3 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -3384,7 +3384,7 @@ find_lively_task_by_vpid(pid_t vpid)
 
 	/* Reuse ptrace permission checks for now. */
 	err = -EACCES;
-	if (!ptrace_may_access(task, PTRACE_MODE_READ))
+	if (!ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_REALCREDS))
 		goto errout;
 
 	return task;
diff --git a/kernel/futex.c b/kernel/futex.c
index 6e443ef..11e467e 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -2872,7 +2872,7 @@ SYSCALL_DEFINE3(get_robust_list, int, pid,
 	}
 
 	ret = -EPERM;
-	if (!ptrace_may_access(p, PTRACE_MODE_READ))
+	if (!ptrace_may_access(p, PTRACE_MODE_READ | PTRACE_MODE_REALCREDS))
 		goto err_unlock;
 
 	head = p->robust_list;
diff --git a/kernel/futex_compat.c b/kernel/futex_compat.c
index 55c8c93..5596298 100644
--- a/kernel/futex_compat.c
+++ b/kernel/futex_compat.c
@@ -155,7 +155,7 @@ COMPAT_SYSCALL_DEFINE3(get_robust_list, int, pid,
 	}
 
 	ret = -EPERM;
-	if (!ptrace_may_access(p, PTRACE_MODE_READ))
+	if (!ptrace_may_access(p, PTRACE_MODE_READ | PTRACE_MODE_REALCREDS))
 		goto err_unlock;
 
 	head = p->compat_robust_list;
diff --git a/kernel/kcmp.c b/kernel/kcmp.c
index 0aa69ea..4a568e4 100644
--- a/kernel/kcmp.c
+++ b/kernel/kcmp.c
@@ -122,8 +122,10 @@ SYSCALL_DEFINE5(kcmp, pid_t, pid1, pid_t, pid2, int, type,
 			&task2->signal->cred_guard_mutex);
 	if (ret)
 		goto err;
-	if (!ptrace_may_access(task1, PTRACE_MODE_READ) ||
-	    !ptrace_may_access(task2, PTRACE_MODE_READ)) {
+	if (!ptrace_may_access(task1,
+		  PTRACE_MODE_READ | PTRACE_MODE_REALCREDS) ||
+	    !ptrace_may_access(task2,
+	    PTRACE_MODE_READ | PTRACE_MODE_REALCREDS)) {
 		ret = -EPERM;
 		goto err_unlock;
 	}
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 787320d..28f007b 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -219,6 +219,13 @@ static int ptrace_has_cap(struct user_namespace *ns, unsigned int mode)
 static int __ptrace_may_access(struct task_struct *task, unsigned int mode)
 {
 	const struct cred *cred = current_cred(), *tcred;
+	kuid_t caller_uid;
+	kgid_t caller_gid;
+
+	if (!(mode & PTRACE_MODE_FSCREDS) != !(mode & PTRACE_MODE_REALCREDS)) {
+		WARN(1, "denying ptrace access check without PTRACE_MODE_*CREDS\n");
+		return -EPERM;
+	}
 
 	/* May we inspect the given task?
 	 * This check is used both for attaching with ptrace
@@ -233,13 +240,28 @@ static int __ptrace_may_access(struct task_struct *task, unsigned int mode)
 	if (same_thread_group(task, current))
 		return 0;
 	rcu_read_lock();
+	if (mode & PTRACE_MODE_FSCREDS) {
+		caller_uid = cred->fsuid;
+		caller_gid = cred->fsgid;
+	} else {
+		/*
+		 * Using the euid would make more sense here, but something
+		 * in userland might rely on the old behavior, and this
+		 * shouldn't be a security problem since
+		 * PTRACE_MODE_REALCREDS implies that the caller explicitly
+		 * used a syscall that requests access to another process
+		 * (and not a filesystem syscall to procfs).
+		 */
+		caller_uid = cred->uid;
+		caller_gid = cred->gid;
+	}
 	tcred = __task_cred(task);
-	if (uid_eq(cred->uid, tcred->euid) &&
-	    uid_eq(cred->uid, tcred->suid) &&
-	    uid_eq(cred->uid, tcred->uid)  &&
-	    gid_eq(cred->gid, tcred->egid) &&
-	    gid_eq(cred->gid, tcred->sgid) &&
-	    gid_eq(cred->gid, tcred->gid))
+	if (uid_eq(caller_uid, tcred->euid) &&
+	    uid_eq(caller_uid, tcred->suid) &&
+	    uid_eq(caller_uid, tcred->uid)  &&
+	    gid_eq(caller_gid, tcred->egid) &&
+	    gid_eq(caller_gid, tcred->sgid) &&
+	    gid_eq(caller_gid, tcred->gid))
 		goto ok;
 	if (ptrace_has_cap(tcred->user_ns, mode))
 		goto ok;
@@ -306,7 +328,8 @@ static int ptrace_attach(struct task_struct *task, long request,
 		goto out;
 
 	task_lock(task);
-	retval = __ptrace_may_access(task, PTRACE_MODE_ATTACH);
+	retval = __ptrace_may_access(task,
+	  PTRACE_MODE_ATTACH | PTRACE_MODE_REALCREDS);
 	task_unlock(task);
 	if (retval)
 		goto unlock_creds;
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index e88d071..a2be821 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -194,7 +194,7 @@ static ssize_t process_vm_rw_core(pid_t pid, struct iov_iter *iter,
 		goto free_proc_pages;
 	}
 
-	mm = mm_access(task, PTRACE_MODE_ATTACH);
+	mm = mm_access(task, PTRACE_MODE_ATTACH | PTRACE_MODE_REALCREDS);
 	if (!mm || IS_ERR(mm)) {
 		rc = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
 		/*
diff --git a/security/commoncap.c b/security/commoncap.c
index 1832cf7..48071ed 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -137,12 +137,17 @@ int cap_ptrace_access_check(struct task_struct *child, unsigned int mode)
 {
 	int ret = 0;
 	const struct cred *cred, *child_cred;
+	const kernel_cap_t *caller_caps;
 
 	rcu_read_lock();
 	cred = current_cred();
 	child_cred = __task_cred(child);
+	if (mode & PTRACE_MODE_FSCREDS)
+		caller_caps = &cred->cap_effective;
+	else
+		caller_caps = &cred->cap_permitted;
 	if (cred->user_ns == child_cred->user_ns &&
-	    cap_issubset(child_cred->cap_permitted, cred->cap_permitted))
+	    cap_issubset(child_cred->cap_permitted, *caller_caps))
 		goto out;
 	if (ns_capable(child_cred->user_ns, CAP_SYS_PTRACE))
 		goto out;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
