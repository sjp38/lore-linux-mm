From: David Howells <dhowells@redhat.com>
Subject: [PATCH 59/59] CRED: Wrap task credential accesses in the core kernel
Date: Wed, 27 Aug 2008 14:50:47 +0100
Message-ID: <20080827135046.19980.77189.stgit@warthog.procyon.org.uk>
In-Reply-To: <20080827134541.19980.61042.stgit@warthog.procyon.org.uk>
References: <20080827134541.19980.61042.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, David Howells <dhowells@redhat.com>, Serge Hallyn <serue@us.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-audit@redhat.com, containers@lists.linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Wrap access to task credentials so that they can be separated more easily from
the task_struct during the introduction of COW creds.

Change most current->(|e|s|fs)[ug]id to current_(|e|s|fs)[ug]id().

Change some task->e?[ug]id to task_e?[ug]id().  In some places it makes more
sense to use RCU directly rather than a convenient wrapper; these will be
addressed by later patches.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: James Morris <jmorris@namei.org>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-audit@redhat.com
Cc: containers@lists.linux-foundation.org
Cc: linux-mm@kvack.org
---

 kernel/acct.c           |    7 +++----
 kernel/auditsc.c        |    6 ++++--
 kernel/cgroup.c         |    9 +++++----
 kernel/futex.c          |    8 +++++---
 kernel/futex_compat.c   |    3 ++-
 kernel/ptrace.c         |   15 +++++++++------
 kernel/sched.c          |   11 +++++++----
 kernel/signal.c         |   15 +++++++++------
 kernel/sys.c            |   16 ++++++++--------
 kernel/sysctl.c         |    2 +-
 kernel/timer.c          |    8 ++++----
 kernel/user_namespace.c |    2 +-
 mm/mempolicy.c          |    7 +++++--
 mm/migrate.c            |    7 +++++--
 mm/shmem.c              |    8 ++++----
 15 files changed, 72 insertions(+), 52 deletions(-)


diff --git a/kernel/acct.c b/kernel/acct.c
index f6006a6..d57b7cb 100644
--- a/kernel/acct.c
+++ b/kernel/acct.c
@@ -530,15 +530,14 @@ static void do_acct_process(struct bsd_acct_struct *acct,
 	do_div(elapsed, AHZ);
 	ac.ac_btime = get_seconds() - elapsed;
 	/* we really need to bite the bullet and change layout */
-	ac.ac_uid = current->uid;
-	ac.ac_gid = current->gid;
+	current_uid_gid(&ac.ac_uid, &ac.ac_gid);
 #if ACCT_VERSION==2
 	ac.ac_ahz = AHZ;
 #endif
 #if ACCT_VERSION==1 || ACCT_VERSION==2
 	/* backward-compatible 16 bit fields */
-	ac.ac_uid16 = current->uid;
-	ac.ac_gid16 = current->gid;
+	ac.ac_uid16 = ac.ac_uid;
+	ac.ac_gid16 = ac.ac_gid;
 #endif
 #if ACCT_VERSION==3
 	ac.ac_pid = task_tgid_nr_ns(current, ns);
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index cf5bc2f..e7d7061 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -2440,7 +2440,8 @@ void audit_core_dumps(long signr)
 {
 	struct audit_buffer *ab;
 	u32 sid;
-	uid_t auid = audit_get_loginuid(current);
+	uid_t auid = audit_get_loginuid(current), uid;
+	gid_t gid;
 	unsigned int sessionid = audit_get_sessionid(current);
 
 	if (!audit_enabled)
@@ -2450,8 +2451,9 @@ void audit_core_dumps(long signr)
 		return;
 
 	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_ANOM_ABEND);
+	current_uid_gid(&uid, &gid);
 	audit_log_format(ab, "auid=%u uid=%u gid=%u ses=%u",
-			auid, current->uid, current->gid, sessionid);
+			 auid, uid, gid, sessionid);
 	security_task_getsecid(current, &sid);
 	if (sid) {
 		char *ctx = NULL;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 13932ab..9f5a62a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -573,8 +573,8 @@ static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
 
 	if (inode) {
 		inode->i_mode = mode;
-		inode->i_uid = current->fsuid;
-		inode->i_gid = current->fsgid;
+		inode->i_uid = current_fsuid();
+		inode->i_gid = current_fsgid();
 		inode->i_blocks = 0;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		inode->i_mapping->backing_dev_info = &cgroup_backing_dev_info;
@@ -1276,6 +1276,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 static int attach_task_by_pid(struct cgroup *cgrp, u64 pid)
 {
 	struct task_struct *tsk;
+	uid_t euid;
 	int ret;
 
 	if (pid) {
@@ -1288,8 +1289,8 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid)
 		get_task_struct(tsk);
 		rcu_read_unlock();
 
-		if ((current->euid) && (current->euid != tsk->uid)
-		    && (current->euid != tsk->suid)) {
+		euid = current_euid();
+		if (euid && euid != tsk->uid && euid != tsk->suid) {
 			put_task_struct(tsk);
 			return -EACCES;
 		}
diff --git a/kernel/futex.c b/kernel/futex.c
index 7d1136e..a28b82b 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -439,10 +439,11 @@ static void free_pi_state(struct futex_pi_state *pi_state)
 static struct task_struct * futex_find_get_task(pid_t pid)
 {
 	struct task_struct *p;
+	uid_t euid = current_euid();
 
 	rcu_read_lock();
 	p = find_task_by_vpid(pid);
-	if (!p || ((current->euid != p->euid) && (current->euid != p->uid)))
+	if (!p || (euid != p->euid && euid != p->uid))
 		p = ERR_PTR(-ESRCH);
 	else
 		get_task_struct(p);
@@ -1826,6 +1827,7 @@ sys_get_robust_list(int pid, struct robust_list_head __user * __user *head_ptr,
 {
 	struct robust_list_head __user *head;
 	unsigned long ret;
+	uid_t euid = current_euid();
 
 	if (!futex_cmpxchg_enabled)
 		return -ENOSYS;
@@ -1841,8 +1843,8 @@ sys_get_robust_list(int pid, struct robust_list_head __user * __user *head_ptr,
 		if (!p)
 			goto err_unlock;
 		ret = -EPERM;
-		if ((current->euid != p->euid) && (current->euid != p->uid) &&
-				!capable(CAP_SYS_PTRACE))
+		if (euid != p->euid && euid != p->uid &&
+		    !capable(CAP_SYS_PTRACE))
 			goto err_unlock;
 		head = p->robust_list;
 		rcu_read_unlock();
diff --git a/kernel/futex_compat.c b/kernel/futex_compat.c
index 04ac3a9..3254d4e 100644
--- a/kernel/futex_compat.c
+++ b/kernel/futex_compat.c
@@ -135,6 +135,7 @@ compat_sys_get_robust_list(int pid, compat_uptr_t __user *head_ptr,
 {
 	struct compat_robust_list_head __user *head;
 	unsigned long ret;
+	uid_t euid = current_euid();
 
 	if (!futex_cmpxchg_enabled)
 		return -ENOSYS;
@@ -150,7 +151,7 @@ compat_sys_get_robust_list(int pid, compat_uptr_t __user *head_ptr,
 		if (!p)
 			goto err_unlock;
 		ret = -EPERM;
-		if ((current->euid != p->euid) && (current->euid != p->uid) &&
+		if (euid != p->euid && euid != p->uid &&
 				!capable(CAP_SYS_PTRACE))
 			goto err_unlock;
 		head = p->compat_robust_list;
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 356699a..0dafab1 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -123,16 +123,19 @@ int __ptrace_may_access(struct task_struct *task, unsigned int mode)
 	 * because setting up the necessary parent/child relationship
 	 * or halting the specified task is impossible.
 	 */
+	uid_t uid;
+	gid_t gid;
 	int dumpable = 0;
 	/* Don't let security modules deny introspection */
 	if (task == current)
 		return 0;
-	if (((current->uid != task->euid) ||
-	     (current->uid != task->suid) ||
-	     (current->uid != task->uid) ||
-	     (current->gid != task->egid) ||
-	     (current->gid != task->sgid) ||
-	     (current->gid != task->gid)) && !capable(CAP_SYS_PTRACE))
+	current_uid_gid(&uid, &gid);
+	if ((uid != task->euid ||
+	     uid != task->suid ||
+	     uid != task->uid  ||
+	     gid != task->egid ||
+	     gid != task->sgid ||
+	     gid != task->gid) && !capable(CAP_SYS_PTRACE))
 		return -EPERM;
 	smp_rmb();
 	if (task->mm)
diff --git a/kernel/sched.c b/kernel/sched.c
index 4a7da9e..58690f3 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -5008,6 +5008,7 @@ static int __sched_setscheduler(struct task_struct *p, int policy,
 	unsigned long flags;
 	const struct sched_class *prev_class = p->sched_class;
 	struct rq *rq;
+	uid_t euid;
 
 	/* may grab non-irq protected spin_locks */
 	BUG_ON(in_interrupt());
@@ -5060,8 +5061,9 @@ recheck:
 			return -EPERM;
 
 		/* can't change other user's priorities */
-		if ((current->euid != p->euid) &&
-		    (current->euid != p->uid))
+		euid = current_euid();
+		if (euid != p->euid &&
+		    euid != p->uid)
 			return -EPERM;
 	}
 
@@ -5272,6 +5274,7 @@ long sched_setaffinity(pid_t pid, const cpumask_t *in_mask)
 	cpumask_t cpus_allowed;
 	cpumask_t new_mask = *in_mask;
 	struct task_struct *p;
+	uid_t euid;
 	int retval;
 
 	get_online_cpus();
@@ -5292,9 +5295,9 @@ long sched_setaffinity(pid_t pid, const cpumask_t *in_mask)
 	get_task_struct(p);
 	read_unlock(&tasklist_lock);
 
+	euid = current_euid();
 	retval = -EPERM;
-	if ((current->euid != p->euid) && (current->euid != p->uid) &&
-			!capable(CAP_SYS_NICE))
+	if (euid != p->euid && euid != p->uid && !capable(CAP_SYS_NICE))
 		goto out_unlock;
 
 	retval = security_task_setscheduler(p, 0, NULL);
diff --git a/kernel/signal.c b/kernel/signal.c
index bf40ecc..141d2b9 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -567,6 +567,7 @@ static int check_kill_permission(int sig, struct siginfo *info,
 				 struct task_struct *t)
 {
 	struct pid *sid;
+	uid_t uid, euid;
 	int error;
 
 	if (!valid_signal(sig))
@@ -579,8 +580,10 @@ static int check_kill_permission(int sig, struct siginfo *info,
 	if (error)
 		return error;
 
-	if ((current->euid ^ t->suid) && (current->euid ^ t->uid) &&
-	    (current->uid  ^ t->suid) && (current->uid  ^ t->uid) &&
+	uid = current_uid();
+	euid = current_euid();
+	if ((euid ^ t->suid) && (euid ^ t->uid) &&
+	    (uid  ^ t->suid) && (uid  ^ t->uid) &&
 	    !capable(CAP_KILL)) {
 		switch (sig) {
 		case SIGCONT:
@@ -844,7 +847,7 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			q->info.si_errno = 0;
 			q->info.si_code = SI_USER;
 			q->info.si_pid = task_pid_vnr(current);
-			q->info.si_uid = current->uid;
+			q->info.si_uid = current_uid();
 			break;
 		case (unsigned long) SEND_SIG_PRIV:
 			q->info.si_signo = sig;
@@ -1597,7 +1600,7 @@ void ptrace_notify(int exit_code)
 	info.si_signo = SIGTRAP;
 	info.si_code = exit_code;
 	info.si_pid = task_pid_vnr(current);
-	info.si_uid = current->uid;
+	info.si_uid = current_uid();
 
 	/* Let the debugger run.  */
 	spin_lock_irq(&current->sighand->siglock);
@@ -2210,7 +2213,7 @@ sys_kill(pid_t pid, int sig)
 	info.si_errno = 0;
 	info.si_code = SI_USER;
 	info.si_pid = task_tgid_vnr(current);
-	info.si_uid = current->uid;
+	info.si_uid = current_uid();
 
 	return kill_something_info(sig, &info, pid);
 }
@@ -2227,7 +2230,7 @@ static int do_tkill(pid_t tgid, pid_t pid, int sig)
 	info.si_errno = 0;
 	info.si_code = SI_TKILL;
 	info.si_pid = task_tgid_vnr(current);
-	info.si_uid = current->uid;
+	info.si_uid = current_uid();
 
 	rcu_read_lock();
 	p = find_task_by_vpid(pid);
diff --git a/kernel/sys.c b/kernel/sys.c
index 234d945..f82827d 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -114,10 +114,10 @@ void (*pm_power_off_prepare)(void);
 
 static int set_one_prio(struct task_struct *p, int niceval, int error)
 {
+	uid_t euid = current_euid();
 	int no_nice;
 
-	if (p->uid != current->euid &&
-		p->euid != current->euid && !capable(CAP_SYS_NICE)) {
+	if (p->uid != euid && p->euid != euid && !capable(CAP_SYS_NICE)) {
 		error = -EPERM;
 		goto out;
 	}
@@ -176,16 +176,16 @@ asmlinkage long sys_setpriority(int which, int who, int niceval)
 		case PRIO_USER:
 			user = current->user;
 			if (!who)
-				who = current->uid;
+				who = current_uid();
 			else
-				if ((who != current->uid) && !(user = find_user(who)))
+				if (who != current_uid() && !(user = find_user(who)))
 					goto out_unlock;	/* No processes for this user */
 
 			do_each_thread(g, p)
 				if (p->uid == who)
 					error = set_one_prio(p, niceval, error);
 			while_each_thread(g, p);
-			if (who != current->uid)
+			if (who != current_uid())
 				free_uid(user);		/* For find_user() */
 			break;
 	}
@@ -238,9 +238,9 @@ asmlinkage long sys_getpriority(int which, int who)
 		case PRIO_USER:
 			user = current->user;
 			if (!who)
-				who = current->uid;
+				who = current_uid();
 			else
-				if ((who != current->uid) && !(user = find_user(who)))
+				if (who != current_uid() && !(user = find_user(who)))
 					goto out_unlock;	/* No processes for this user */
 
 			do_each_thread(g, p)
@@ -250,7 +250,7 @@ asmlinkage long sys_getpriority(int which, int who)
 						retval = niceval;
 				}
 			while_each_thread(g, p);
-			if (who != current->uid)
+			if (who != current_uid())
 				free_uid(user);		/* for find_user() */
 			break;
 	}
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index deceea0..9e4c8d3 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1667,7 +1667,7 @@ out:
 
 static int test_perm(int mode, int op)
 {
-	if (!current->euid)
+	if (!current_euid())
 		mode >>= 6;
 	else if (in_egroup_p(0))
 		mode >>= 3;
diff --git a/kernel/timer.c b/kernel/timer.c
index 56becf3..b54e464 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -1123,25 +1123,25 @@ asmlinkage long sys_getppid(void)
 asmlinkage long sys_getuid(void)
 {
 	/* Only we change this so SMP safe */
-	return current->uid;
+	return current_uid();
 }
 
 asmlinkage long sys_geteuid(void)
 {
 	/* Only we change this so SMP safe */
-	return current->euid;
+	return current_euid();
 }
 
 asmlinkage long sys_getgid(void)
 {
 	/* Only we change this so SMP safe */
-	return current->gid;
+	return current_gid();
 }
 
 asmlinkage long sys_getegid(void)
 {
 	/* Only we change this so SMP safe */
-	return  current->egid;
+	return  current_egid();
 }
 
 #endif
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 532858f..f82730a 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -38,7 +38,7 @@ static struct user_namespace *clone_user_ns(struct user_namespace *old_ns)
 	}
 
 	/* Reset current->user with a new one */
-	new_user = alloc_uid(ns, current->uid);
+	new_user = alloc_uid(ns, current_uid());
 	if (!new_user) {
 		free_uid(ns->root_user);
 		kfree(ns);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8336905..27bcf7e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1110,6 +1110,7 @@ asmlinkage long sys_migrate_pages(pid_t pid, unsigned long maxnode,
 	nodemask_t old;
 	nodemask_t new;
 	nodemask_t task_nodes;
+	uid_t uid, euid;
 	int err;
 
 	err = get_nodes(&old, old_nodes, maxnode);
@@ -1139,8 +1140,10 @@ asmlinkage long sys_migrate_pages(pid_t pid, unsigned long maxnode,
 	 * capabilities, superuser privileges or the same
 	 * userid as the target process.
 	 */
-	if ((current->euid != task->suid) && (current->euid != task->uid) &&
-	    (current->uid != task->suid) && (current->uid != task->uid) &&
+	uid = current_uid();
+	euid = current_euid();
+	if (euid != task->suid && euid != task->uid &&
+	    uid  != task->suid && uid  != task->uid &&
 	    !capable(CAP_SYS_NICE)) {
 		err = -EPERM;
 		goto out;
diff --git a/mm/migrate.c b/mm/migrate.c
index f9897ba..e6223d1 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -990,6 +990,7 @@ asmlinkage long sys_move_pages(pid_t pid, unsigned long nr_pages,
 	nodemask_t task_nodes;
 	struct mm_struct *mm;
 	struct page_to_node *pm = NULL;
+	uid_t uid, euid;
 
 	/* Check flags */
 	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
@@ -1017,8 +1018,10 @@ asmlinkage long sys_move_pages(pid_t pid, unsigned long nr_pages,
 	 * capabilities, superuser privileges or the same
 	 * userid as the target process.
 	 */
-	if ((current->euid != task->suid) && (current->euid != task->uid) &&
-	    (current->uid != task->suid) && (current->uid != task->uid) &&
+	uid = current_uid();
+	euid = current_euid();
+	if (euid != task->suid && euid != task->uid &&
+	    uid  != task->suid && uid  != task->uid &&
 	    !capable(CAP_SYS_NICE)) {
 		err = -EPERM;
 		goto out2;
diff --git a/mm/shmem.c b/mm/shmem.c
index 04fb4f1..c935bb4 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1510,8 +1510,8 @@ shmem_get_inode(struct super_block *sb, int mode, dev_t dev)
 	inode = new_inode(sb);
 	if (inode) {
 		inode->i_mode = mode;
-		inode->i_uid = current->fsuid;
-		inode->i_gid = current->fsgid;
+		inode->i_uid = current_fsuid();
+		inode->i_gid = current_fsgid();
 		inode->i_blocks = 0;
 		inode->i_mapping->backing_dev_info = &shmem_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
@@ -2275,8 +2275,8 @@ static int shmem_fill_super(struct super_block *sb,
 	sbinfo->max_blocks = 0;
 	sbinfo->max_inodes = 0;
 	sbinfo->mode = S_IRWXUGO | S_ISVTX;
-	sbinfo->uid = current->fsuid;
-	sbinfo->gid = current->fsgid;
+	sbinfo->uid = current_fsuid();
+	sbinfo->gid = current_fsgid();
 	sbinfo->mpol = NULL;
 	sb->s_fs_info = sbinfo;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
