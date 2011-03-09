Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4E3C88D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 19:44:44 -0500 (EST)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 5/6] proc: make check_mem_permission() return an mm_struct on success
Date: Tue,  8 Mar 2011 19:42:22 -0500
Message-Id: <1299631343-4499-6-git-send-email-wilsons@start.ca>
In-Reply-To: <1299631343-4499-1-git-send-email-wilsons@start.ca>
References: <1299631343-4499-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Roland McGrath <roland@redhat.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Stephen Wilson <wilsons@start.ca>

This change allows us to take advantage of access_remote_vm(), which in turn
enables a secure mem_write() implementation.

The previous implementation of mem_write() was insecure since the target task
could exec a setuid-root binary between the permission check and the actual
write.  Holding a reference to the target mm_struct eliminates this
vulnerability.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 fs/proc/base.c |   54 ++++++++++++++++++++++++++++++++----------------------
 1 files changed, 32 insertions(+), 22 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index e52702d..5ffc927 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -192,16 +192,23 @@ static int proc_root_link(struct inode *inode, struct path *path)
 }
 
 /*
- * Return zero if current may access user memory in @task, -error if not.
+ * If current may access user memory in @task return a reference to the
+ * corresponding mm, otherwise NULL.
  */
-static int check_mem_permission(struct task_struct *task)
+static struct mm_struct *check_mem_permission(struct task_struct *task)
 {
+	struct mm_struct *mm;
+
+	mm = get_task_mm(task);
+	if (!mm)
+		return NULL;
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
@@ -213,13 +220,14 @@ static int check_mem_permission(struct task_struct *task)
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
+	return NULL;
 }
 
 struct mm_struct *mm_for_maps(struct task_struct *task)
@@ -775,24 +783,20 @@ static ssize_t mem_read(struct file * file, char __user * buf,
 	if (!task)
 		goto out_no_task;
 
-	if (check_mem_permission(task))
+	ret = -EPERM;
+	mm = check_mem_permission(task);
+	if (!mm)
 		goto out;
 
 	ret = -ENOMEM;
 	page = (char *)__get_free_page(GFP_TEMPORARY);
 	if (!page)
-		goto out;
-
-	ret = 0;
- 
-	mm = get_task_mm(task);
-	if (!mm)
-		goto out_free;
+		goto out_put;
 
 	ret = -EIO;
  
 	if (file->private_data != (void*)((long)current->self_exec_id))
-		goto out_put;
+		goto out_free;
 
 	ret = 0;
  
@@ -800,8 +804,8 @@ static ssize_t mem_read(struct file * file, char __user * buf,
 		int this_len, retval;
 
 		this_len = (count > PAGE_SIZE) ? PAGE_SIZE : count;
-		retval = access_process_vm(task, src, page, this_len, 0);
-		if (!retval || check_mem_permission(task)) {
+		retval = access_remote_vm(mm, src, page, this_len, 0);
+		if (!retval) {
 			if (!ret)
 				ret = -EIO;
 			break;
@@ -819,10 +823,10 @@ static ssize_t mem_read(struct file * file, char __user * buf,
 	}
 	*ppos = src;
 
-out_put:
-	mmput(mm);
 out_free:
 	free_page((unsigned long) page);
+out_put:
+	mmput(mm);
 out:
 	put_task_struct(task);
 out_no_task:
@@ -838,6 +842,7 @@ static ssize_t mem_write(struct file * file, const char __user *buf,
 {
 	int copied;
 	char *page;
+	struct mm_struct *mm;
 	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
 	unsigned long dst = *ppos;
 
@@ -845,17 +850,19 @@ static ssize_t mem_write(struct file * file, const char __user *buf,
 	if (!task)
 		goto out_no_task;
 
-	if (check_mem_permission(task))
+	copied = -EPERM;
+	mm = check_mem_permission(task);
+	if (!mm)
 		goto out;
 
 	copied = -EIO;
 	if (file->private_data != (void *)((long)current->self_exec_id))
-		goto out;
+		goto out_put;
 
 	copied = -ENOMEM;
 	page = (char *)__get_free_page(GFP_TEMPORARY);
 	if (!page)
-		goto out;
+		goto out_put;
 
 	copied = 0;
 	while (count > 0) {
@@ -866,7 +873,7 @@ static ssize_t mem_write(struct file * file, const char __user *buf,
 			copied = -EFAULT;
 			break;
 		}
-		retval = access_process_vm(task, dst, page, this_len, 1);
+		retval = access_remote_vm(mm, dst, page, this_len, 1);
 		if (!retval) {
 			if (!copied)
 				copied = -EIO;
@@ -879,6 +886,9 @@ static ssize_t mem_write(struct file * file, const char __user *buf,
 	}
 	*ppos = dst;
 	free_page((unsigned long) page);
+
+out_put:
+	mmput(mm);
 out:
 	put_task_struct(task);
 out_no_task:
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
