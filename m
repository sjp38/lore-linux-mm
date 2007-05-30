Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4U0quOF022756
	for <linux-mm@kvack.org>; Tue, 29 May 2007 20:52:56 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4U0qphQ270840
	for <linux-mm@kvack.org>; Tue, 29 May 2007 18:52:56 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4U0qpLo004045
	for <linux-mm@kvack.org>; Tue, 29 May 2007 18:52:51 -0600
Subject: [RFC][PATCH] Replacing the /proc/<pid|self>/exe symlink code
From: Matt Helsley <matthltc@us.ibm.com>
Content-Type: text/plain
Date: Tue, 29 May 2007 17:52:49 -0700
Message-Id: <1180486369.11715.69.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch avoids holding the mmap semaphore while walking VMAs in response to
programs which read or follow the /proc/<pid|self>/exe symlink. This also allows us
to merge mmu and nommu proc_exe_link() functions. The costs are holding a separate
reference to the executable file stored in the task struct and increased code in
fork, exec, and exit paths.

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
---

Compiled and passed simple tests for regressions when patched against a 2.6.20
and 2.6.22-rc2-mm1 kernel.

 fs/exec.c             |    5 +++--
 fs/proc/base.c        |   20 ++++++++++++++++++++
 fs/proc/internal.h    |    1 -
 fs/proc/task_mmu.c    |   34 ----------------------------------
 fs/proc/task_nommu.c  |   34 ----------------------------------
 include/linux/sched.h |    1 +
 kernel/exit.c         |    2 ++
 kernel/fork.c         |   10 +++++++++-
 8 files changed, 35 insertions(+), 72 deletions(-)

Index: linux-2.6.22-rc2-mm1/include/linux/sched.h
===================================================================
--- linux-2.6.22-rc2-mm1.orig/include/linux/sched.h
+++ linux-2.6.22-rc2-mm1/include/linux/sched.h
@@ -988,10 +988,11 @@ struct task_struct {
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
Index: linux-2.6.22-rc2-mm1/fs/exec.c
===================================================================
--- linux-2.6.22-rc2-mm1.orig/fs/exec.c
+++ linux-2.6.22-rc2-mm1/fs/exec.c
@@ -1106,12 +1106,13 @@ int search_binary_handler(struct linux_b
 			read_unlock(&binfmt_lock);
 			retval = fn(bprm, regs);
 			if (retval >= 0) {
 				put_binfmt(fmt);
 				allow_write_access(bprm->file);
-				if (bprm->file)
-					fput(bprm->file);
+				if (current->exe_file)
+					fput(current->exe_file);
+				current->exe_file = bprm->file;
 				bprm->file = NULL;
 				current->did_exec = 1;
 				proc_exec_connector(current);
 				return retval;
 			}
Index: linux-2.6.22-rc2-mm1/fs/proc/base.c
===================================================================
--- linux-2.6.22-rc2-mm1.orig/fs/proc/base.c
+++ linux-2.6.22-rc2-mm1/fs/proc/base.c
@@ -951,10 +951,30 @@ const struct file_operations proc_pid_sc
 	.write		= sched_write,
 	.llseek		= seq_lseek,
 	.release	= seq_release,
 };
 
+static int proc_exe_link(struct inode *inode, struct dentry **dentry,
+    			 struct vfsmount **mnt)
+{
+	int error;
+	struct task_struct *task;
+
+	task = get_proc_task(inode);
+	if (!task)
+		return -ENOENT;
+	error = -ENOSYS;
+	if (!task->exe_file)
+		goto out;
+	*mnt = mntget(task->exe_file->f_path.mnt);
+	*dentry = dget(task->exe_file->f_path.dentry);
+	error = 0;
+out:
+	put_task_struct(task);
+	return error;
+}
+
 static void *proc_pid_follow_link(struct dentry *dentry, struct nameidata *nd)
 {
 	struct inode *inode = dentry->d_inode;
 	int error = -EACCES;
 
Index: linux-2.6.22-rc2-mm1/kernel/exit.c
===================================================================
--- linux-2.6.22-rc2-mm1.orig/kernel/exit.c
+++ linux-2.6.22-rc2-mm1/kernel/exit.c
@@ -924,10 +924,12 @@ fastcall void do_exit(long code)
 	if (unlikely(tsk->audit_context))
 		audit_free(tsk);
 
 	taskstats_exit(tsk, group_dead);
 
+	if (tsk->exe_file)
+		fput(tsk->exe_file);
 	exit_mm(tsk);
 
 	if (group_dead)
 		acct_process();
 	exit_sem(tsk);
Index: linux-2.6.22-rc2-mm1/kernel/fork.c
===================================================================
--- linux-2.6.22-rc2-mm1.orig/kernel/fork.c
+++ linux-2.6.22-rc2-mm1/kernel/fork.c
@@ -1163,10 +1163,13 @@ static struct task_struct *copy_process(
 
 	/* ok, now we should be set up.. */
 	p->exit_signal = (clone_flags & CLONE_THREAD) ? -1 : (clone_flags & CSIGNAL);
 	p->pdeath_signal = 0;
 	p->exit_state = 0;
+	p->exe_file = current->exe_file;
+	if (p->exe_file)
+		get_file(p->exe_file);
 
 	/*
 	 * Ok, make it visible to the rest of the system.
 	 * We dont wake it up yet.
 	 */
@@ -1218,11 +1221,11 @@ static struct task_struct *copy_process(
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
@@ -1274,10 +1277,15 @@ static struct task_struct *copy_process(
 		put_user(p->pid, parent_tidptr);
 
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
Index: linux-2.6.22-rc2-mm1/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.22-rc2-mm1.orig/fs/proc/task_mmu.c
+++ linux-2.6.22-rc2-mm1/fs/proc/task_mmu.c
@@ -71,44 +71,10 @@ int task_statm(struct mm_struct *mm, int
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
Index: linux-2.6.22-rc2-mm1/fs/proc/task_nommu.c
===================================================================
--- linux-2.6.22-rc2-mm1.orig/fs/proc/task_nommu.c
+++ linux-2.6.22-rc2-mm1/fs/proc/task_nommu.c
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
Index: linux-2.6.22-rc2-mm1/fs/proc/internal.h
===================================================================
--- linux-2.6.22-rc2-mm1.orig/fs/proc/internal.h
+++ linux-2.6.22-rc2-mm1/fs/proc/internal.h
@@ -38,11 +38,10 @@ extern int nommu_vma_show(struct seq_fil
 #endif
 
 extern int maps_protect;
 
 extern void create_seq_entry(char *name, mode_t mode, const struct file_operations *f);
-extern int proc_exe_link(struct inode *, struct dentry **, struct vfsmount **);
 extern int proc_tid_stat(struct task_struct *,  char *);
 extern int proc_tgid_stat(struct task_struct *, char *);
 extern int proc_pid_status(struct task_struct *, char *);
 extern int proc_pid_statm(struct task_struct *, char *);
 extern loff_t mem_lseek(struct file * file, loff_t offset, int orig);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
