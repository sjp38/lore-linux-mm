Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 90FD88D003A
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 15:57:00 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 11/12] proc: make check_mem_permission() return an mm_struct on success
Date: Sun, 13 Mar 2011 15:49:23 -0400
Message-Id: <1300045764-24168-12-git-send-email-wilsons@start.ca>
In-Reply-To: <1300045764-24168-1-git-send-email-wilsons@start.ca>
References: <1300045764-24168-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michel Lespinasse <walken@google.com>, Andi Kleen <ak@linux.intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stephen Wilson <wilsons@start.ca>

This change allows us to take advantage of access_remote_vm(), which in turn
eliminates a security issue with the mem_write() implementation.

The previous implementation of mem_write() was insecure since the target task
could exec a setuid-root binary between the permission check and the actual
write.  Holding a reference to the target mm_struct eliminates this
vulnerability.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 fs/proc/base.c |   58 ++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 34 insertions(+), 24 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index f6b644f..2af83bd 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -191,14 +191,20 @@ static int proc_root_link(struct inode *inode, struct path *path)
 	return result;
 }
 
-static int __check_mem_permission(struct task_struct *task)
+static struct mm_struct *__check_mem_permission(struct task_struct *task)
 {
+	struct mm_struct *mm;
+
+	mm = get_task_mm(task);
+	if (!mm)
+		return ERR_PTR(-EINVAL);
+
 	/*
 	 * A task can always look at itself, in case it chooses
 	 * to use system calls instead of load instructions.
 	 */
 	if (task == current)
-		return 0;
+		return mm;
 
 	/*
 	 * If current is actively ptrace'ing, and would also be
@@ -210,20 +216,23 @@ static int __check_mem_permission(struct task_struct *task)
 		match = (tracehook_tracer_task(task) == current);
 		rcu_read_unlock();
 		if (match && ptrace_may_access(task, PTRACE_MODE_ATTACH))
-			return 0;
+			return mm;
 	}
 
 	/*
 	 * Noone else is allowed.
 	 */
-	return -EPERM;
+	mmput(mm);
+	return ERR_PTR(-EPERM);
 }
 
 /*
- * Return zero if current may access user memory in @task, -error if not.
+ * If current may access user memory in @task return a reference to the
+ * corresponding mm, otherwise ERR_PTR.
  */
-static int check_mem_permission(struct task_struct *task)
+static struct mm_struct *check_mem_permission(struct task_struct *task)
 {
+	struct mm_struct *mm;
 	int err;
 
 	/*
@@ -232,12 +241,12 @@ static int check_mem_permission(struct task_struct *task)
 	 */
 	err = mutex_lock_killable(&task->signal->cred_guard_mutex);
 	if (err)
-		return err;
+		return ERR_PTR(err);
 
-	err = __check_mem_permission(task);
+	mm = __check_mem_permission(task);
 	mutex_unlock(&task->signal->cred_guard_mutex);
 
-	return err;
+	return mm;
 }
 
 struct mm_struct *mm_for_maps(struct task_struct *task)
@@ -793,18 +802,14 @@ static ssize_t mem_read(struct file * file, char __user * buf,
 	if (!task)
 		goto out_no_task;
 
-	if (check_mem_permission(task))
-		goto out;
-
 	ret = -ENOMEM;
 	page = (char *)__get_free_page(GFP_TEMPORARY);
 	if (!page)
 		goto out;
 
-	ret = 0;
- 
-	mm = get_task_mm(task);
-	if (!mm)
+	mm = check_mem_permission(task);
+	ret = PTR_ERR(mm);
+	if (IS_ERR(mm))
 		goto out_free;
 
 	ret = -EIO;
@@ -818,8 +823,8 @@ static ssize_t mem_read(struct file * file, char __user * buf,
 		int this_len, retval;
 
 		this_len = (count > PAGE_SIZE) ? PAGE_SIZE : count;
-		retval = access_process_vm(task, src, page, this_len, 0);
-		if (!retval || check_mem_permission(task)) {
+		retval = access_remote_vm(mm, src, page, this_len, 0);
+		if (!retval) {
 			if (!ret)
 				ret = -EIO;
 			break;
@@ -858,22 +863,25 @@ static ssize_t mem_write(struct file * file, const char __user *buf,
 	char *page;
 	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
 	unsigned long dst = *ppos;
+	struct mm_struct *mm;
 
 	copied = -ESRCH;
 	if (!task)
 		goto out_no_task;
 
-	if (check_mem_permission(task))
-		goto out;
+	mm = check_mem_permission(task);
+	copied = PTR_ERR(mm);
+	if (IS_ERR(mm))
+		goto out_task;
 
 	copied = -EIO;
 	if (file->private_data != (void *)((long)current->self_exec_id))
-		goto out;
+		goto out_mm;
 
 	copied = -ENOMEM;
 	page = (char *)__get_free_page(GFP_TEMPORARY);
 	if (!page)
-		goto out;
+		goto out_mm;
 
 	copied = 0;
 	while (count > 0) {
@@ -884,7 +892,7 @@ static ssize_t mem_write(struct file * file, const char __user *buf,
 			copied = -EFAULT;
 			break;
 		}
-		retval = access_process_vm(task, dst, page, this_len, 1);
+		retval = access_remote_vm(mm, dst, page, this_len, 1);
 		if (!retval) {
 			if (!copied)
 				copied = -EIO;
@@ -897,7 +905,9 @@ static ssize_t mem_write(struct file * file, const char __user *buf,
 	}
 	*ppos = dst;
 	free_page((unsigned long) page);
-out:
+out_mm:
+	mmput(mm);
+out_task:
 	put_task_struct(task);
 out_no_task:
 	return copied;
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
