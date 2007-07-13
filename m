Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6D20CDL013068
	for <linux-mm@kvack.org>; Thu, 12 Jul 2007 22:00:12 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6D20Cx2517100
	for <linux-mm@kvack.org>; Thu, 12 Jul 2007 22:00:12 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6D20BUi004959
	for <linux-mm@kvack.org>; Thu, 12 Jul 2007 22:00:11 -0400
Subject: [PATCH] Simplify /proc/<pid|self>/exe symlink code
From: Matt Helsley <matthltc@us.ibm.com>
Content-Type: text/plain
Date: Thu, 12 Jul 2007 19:00:12 -0700
Message-Id: <1184292012.13479.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Chris Wright <chrisw@sous-sol.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "Hallyn, Serge" <serue@us.ibm.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

This patch avoids holding the mmap semaphore while walking VMAs in response to
programs which read or follow the /proc/<pid|self>/exe symlink. This also allows
us to merge mmu and nommu proc_exe_link() functions. The costs are holding the
task lock, a separate reference to the executable file stored in the task
struct, and increased code in fork, exec, and exit paths.

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
---

Changelog:

Hold task_lock() while using task->exe_file. With this change I haven't
	been able to reproduce Chris Wright's Oops report:
		http://lkml.org/lkml/2007/5/31/34 
	I used a 4-way, x86 system running kernbench. I also tried a 4-way x86_64
	system running pidof. I used oprofile during all runs but I could not
	reproduce Chris' Oops with the new patch.

Compiled and passed simple tests for regressions when patched against a 2.6.20
and a 2.6.22 kernel. Regression tests included a variety of file operations on
/proc/<pid|self>/exe such as stat, lstat, open, close, readlink, and unlink. All
produced the expected, baseline output results.

Andrew, please consider this patch for inclusion in -mm.

 fs/exec.c             |    7 +++++--
 fs/proc/base.c        |   21 +++++++++++++++++++++
 fs/proc/internal.h    |    1 -
 fs/proc/task_mmu.c    |   34 ----------------------------------
 fs/proc/task_nommu.c  |   34 ----------------------------------
 include/linux/sched.h |    3 ++-
 kernel/exit.c         |    6 ++++++
 kernel/fork.c         |    9 ++++++++-
 8 files changed, 42 insertions(+), 73 deletions(-)

Index: linux-2.6.22/include/linux/sched.h
===================================================================
--- linux-2.6.22.orig/include/linux/sched.h
+++ linux-2.6.22/include/linux/sched.h
@@ -937,10 +937,11 @@ struct task_struct {
 	int oomkilladj; /* OOM kill score adjustment (bit shift). */
 	char comm[TASK_COMM_LEN]; /* executable name excluding path
 				     - access with [gs]et_task_comm (which lock
 				       it with task_lock())
 				     - initialized normally by flush_old_exec */
+	struct file *exe_file;
 /* file system info */
 	int link_count, total_link_count;
 #ifdef CONFIG_SYSVIPC
 /* ipc stuff */
 	struct sysv_sem sysvsem;
@@ -1490,11 +1491,11 @@ static inline int thread_group_empty(str
 
 #define delay_group_leader(p) \
 		(thread_group_leader(p) && !thread_group_empty(p))
 
 /*
- * Protects ->fs, ->files, ->mm, ->group_info, ->comm, keyring
+ * Protects ->fs, ->files, ->mm, ->group_info, ->comm, ->exe_file, keyring
  * subscriptions and synchronises with wait4().  Also used in procfs.  Also
  * pins the final release of task.io_context.  Also protects ->cpuset.
  *
  * Nests both inside and outside of read_lock(&tasklist_lock).
  * It must not be nested with write_lock_irq(&tasklist_lock),
Index: linux-2.6.22/fs/exec.c
===================================================================
--- linux-2.6.22.orig/fs/exec.c
+++ linux-2.6.22/fs/exec.c
@@ -1106,12 +1106,15 @@ int search_binary_handler(struct linux_b
 			read_unlock(&binfmt_lock);
 			retval = fn(bprm, regs);
 			if (retval >= 0) {
 				put_binfmt(fmt);
 				allow_write_access(bprm->file);
-				if (bprm->file)
-					fput(bprm->file);
+				task_lock(current);
+				if (current->exe_file)
+					fput(current->exe_file);
+				current->exe_file = bprm->file;
+				task_unlock(current);
 				bprm->file = NULL;
 				current->did_exec = 1;
 				proc_exec_connector(current);
 				return retval;
 			}
Index: linux-2.6.22/fs/proc/base.c
===================================================================
--- linux-2.6.22.orig/fs/proc/base.c
+++ linux-2.6.22/fs/proc/base.c
@@ -927,10 +927,31 @@ static const struct file_operations proc
 	.read		= proc_fault_inject_read,
 	.write		= proc_fault_inject_write,
 };
 #endif
 
+static int proc_exe_link(struct inode *inode, struct dentry **dentry,
+    			 struct vfsmount **mnt)
+{
+	int error = -ENOENT;
+	struct task_struct *task;
+
+	task = get_proc_task(inode);
+	if (!task)
+		return error;
+	task_lock(task);
+	if (!task->exe_file)
+		goto out;
+	*mnt = mntget(task->exe_file->f_path.mnt);
+	*dentry = dget(task->exe_file->f_path.dentry);
+	error = 0;
+out:
+	task_unlock(task);
+	put_task_struct(task);
+	return error;
+}
+
 static void *proc_pid_follow_link(struct dentry *dentry, struct nameidata *nd)
 {
 	struct inode *inode = dentry->d_inode;
 	int error = -EACCES;
 
Index: linux-2.6.22/kernel/exit.c
===================================================================
--- linux-2.6.22.orig/kernel/exit.c
+++ linux-2.6.22/kernel/exit.c
@@ -941,10 +941,16 @@ fastcall NORET_TYPE void do_exit(long co
 	if (unlikely(tsk->audit_context))
 		audit_free(tsk);
 
 	taskstats_exit(tsk, group_dead);
 
+	task_lock(tsk);
+	if (tsk->exe_file) {
+		fput(tsk->exe_file);
+		tsk->exe_file = NULL;
+	}
+	task_unlock(tsk);
 	exit_mm(tsk);
 
 	if (group_dead)
 		acct_process();
 	exit_sem(tsk);
Index: linux-2.6.22/kernel/fork.c
===================================================================
--- linux-2.6.22.orig/kernel/fork.c
+++ linux-2.6.22/kernel/fork.c
@@ -1164,10 +1164,12 @@ static struct task_struct *copy_process(
 
 	/* ok, now we should be set up.. */
 	p->exit_signal = (clone_flags & CLONE_THREAD) ? -1 : (clone_flags & CSIGNAL);
 	p->pdeath_signal = 0;
 	p->exit_state = 0;
+	if (p->exe_file) /* ptr copied in dup_task_struct still needs a ref */
+		get_file(p->exe_file);
 
 	/*
 	 * Ok, make it visible to the rest of the system.
 	 * We dont wake it up yet.
 	 */
@@ -1219,11 +1221,11 @@ static struct task_struct *copy_process(
  	recalc_sigpending();
 	if (signal_pending(current)) {
 		spin_unlock(&current->sighand->siglock);
 		write_unlock_irq(&tasklist_lock);
 		retval = -ERESTARTNOINTR;
-		goto bad_fork_cleanup_namespaces;
+		goto bad_fork_cleanup_exe_file;
 	}
 
 	if (clone_flags & CLONE_THREAD) {
 		p->group_leader = current->group_leader;
 		list_add_tail_rcu(&p->thread_group, &p->group_leader->thread_group);
@@ -1267,10 +1269,15 @@ static struct task_struct *copy_process(
 	spin_unlock(&current->sighand->siglock);
 	write_unlock_irq(&tasklist_lock);
 	proc_fork_connector(p);
 	return p;
 
+bad_fork_cleanup_exe_file:
+	if (p->exe_file) {
+		fput(p->exe_file);
+		p->exe_file = NULL;
+	}
 bad_fork_cleanup_namespaces:
 	exit_task_namespaces(p);
 bad_fork_cleanup_keys:
 	exit_keys(p);
 bad_fork_cleanup_mm:
Index: linux-2.6.22/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.22.orig/fs/proc/task_mmu.c
+++ linux-2.6.22/fs/proc/task_mmu.c
@@ -70,44 +70,10 @@ int task_statm(struct mm_struct *mm, int
 	*data = mm->total_vm - mm->shared_vm;
 	*resident = *shared + get_mm_counter(mm, anon_rss);
 	return mm->total_vm;
 }
 
-int proc_exe_link(struct inode *inode, struct dentry **dentry, struct vfsmount **mnt)
-{
-	struct vm_area_struct * vma;
-	int result = -ENOENT;
-	struct task_struct *task = get_proc_task(inode);
-	struct mm_struct * mm = NULL;
-
-	if (task) {
-		mm = get_task_mm(task);
-		put_task_struct(task);
-	}
-	if (!mm)
-		goto out;
-	down_read(&mm->mmap_sem);
-
-	vma = mm->mmap;
-	while (vma) {
-		if ((vma->vm_flags & VM_EXECUTABLE) && vma->vm_file)
-			break;
-		vma = vma->vm_next;
-	}
-
-	if (vma) {
-		*mnt = mntget(vma->vm_file->f_path.mnt);
-		*dentry = dget(vma->vm_file->f_path.dentry);
-		result = 0;
-	}
-
-	up_read(&mm->mmap_sem);
-	mmput(mm);
-out:
-	return result;
-}
-
 static void pad_len_spaces(struct seq_file *m, int len)
 {
 	len = 25 + sizeof(void*) * 6 - len;
 	if (len < 1)
 		len = 1;
Index: linux-2.6.22/fs/proc/task_nommu.c
===================================================================
--- linux-2.6.22.orig/fs/proc/task_nommu.c
+++ linux-2.6.22/fs/proc/task_nommu.c
@@ -102,44 +102,10 @@ int task_statm(struct mm_struct *mm, int
 	up_read(&mm->mmap_sem);
 	*resident = size;
 	return size;
 }
 
-int proc_exe_link(struct inode *inode, struct dentry **dentry, struct vfsmount **mnt)
-{
-	struct vm_list_struct *vml;
-	struct vm_area_struct *vma;
-	struct task_struct *task = get_proc_task(inode);
-	struct mm_struct *mm = get_task_mm(task);
-	int result = -ENOENT;
-
-	if (!mm)
-		goto out;
-	down_read(&mm->mmap_sem);
-
-	vml = mm->context.vmlist;
-	vma = NULL;
-	while (vml) {
-		if ((vml->vma->vm_flags & VM_EXECUTABLE) && vml->vma->vm_file) {
-			vma = vml->vma;
-			break;
-		}
-		vml = vml->next;
-	}
-
-	if (vma) {
-		*mnt = mntget(vma->vm_file->f_path.mnt);
-		*dentry = dget(vma->vm_file->f_path.dentry);
-		result = 0;
-	}
-
-	up_read(&mm->mmap_sem);
-	mmput(mm);
-out:
-	return result;
-}
-
 /*
  * display mapping lines for a particular process's /proc/pid/maps
  */
 static int show_map(struct seq_file *m, void *_vml)
 {
Index: linux-2.6.22/fs/proc/internal.h
===================================================================
--- linux-2.6.22.orig/fs/proc/internal.h
+++ linux-2.6.22/fs/proc/internal.h
@@ -38,11 +38,10 @@ extern int nommu_vma_show(struct seq_fil
 #endif
 
 extern int maps_protect;
 
 extern void create_seq_entry(char *name, mode_t mode, const struct file_operations *f);
-extern int proc_exe_link(struct inode *, struct dentry **, struct vfsmount **);
 extern int proc_tid_stat(struct task_struct *,  char *);
 extern int proc_tgid_stat(struct task_struct *, char *);
 extern int proc_pid_status(struct task_struct *, char *);
 extern int proc_pid_statm(struct task_struct *, char *);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
