Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DBB1F6B0352
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 21:59:09 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o7O1af4E002992
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 18:36:41 -0700
Received: from pxi17 (pxi17.prod.google.com [10.243.27.17])
	by kpbe17.cbf.corp.google.com with ESMTP id o7O1ad6x032355
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 18:36:40 -0700
Received: by pxi17 with SMTP id 17so2783088pxi.13
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 18:36:39 -0700 (PDT)
Date: Mon, 23 Aug 2010 18:36:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 1/2] oom: rewrite error handling for oom_adj and
 oom_score_adj tunables
Message-ID: <alpine.DEB.2.00.1008231829230.6483@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It's better to use proper error handling in oom_adjust_write() and 
oom_score_adj_write() instead of duplicating the locking order on various
exit paths.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/proc/base.c |   83 ++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 48 insertions(+), 35 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1023,36 +1023,39 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 	memset(buffer, 0, sizeof(buffer));
 	if (count > sizeof(buffer) - 1)
 		count = sizeof(buffer) - 1;
-	if (copy_from_user(buffer, buf, count))
-		return -EFAULT;
+	if (copy_from_user(buffer, buf, count)) {
+		err = -EFAULT;
+		goto out;
+	}
 
 	err = strict_strtol(strstrip(buffer), 0, &oom_adjust);
 	if (err)
-		return -EINVAL;
+		goto out;
 	if ((oom_adjust < OOM_ADJUST_MIN || oom_adjust > OOM_ADJUST_MAX) &&
-	     oom_adjust != OOM_DISABLE)
-		return -EINVAL;
+	     oom_adjust != OOM_DISABLE) {
+		err = -EINVAL;
+		goto out;
+	}
 
 	task = get_proc_task(file->f_path.dentry->d_inode);
-	if (!task)
-		return -ESRCH;
+	if (!task) {
+		err = -ESRCH;
+		goto out;
+	}
 	if (!lock_task_sighand(task, &flags)) {
-		put_task_struct(task);
-		return -ESRCH;
+		err = -ESRCH;
+		goto err_task_struct;
 	}
 
 	if (oom_adjust < task->signal->oom_adj && !capable(CAP_SYS_RESOURCE)) {
-		unlock_task_sighand(task, &flags);
-		put_task_struct(task);
-		return -EACCES;
+		err = -EACCES;
+		goto err_sighand;
 	}
 
 	task_lock(task);
 	if (!task->mm) {
-		task_unlock(task);
-		unlock_task_sighand(task, &flags);
-		put_task_struct(task);
-		return -EINVAL;
+		err = -EINVAL;
+		goto err_task_lock;
 	}
 
 	if (oom_adjust != task->signal->oom_adj) {
@@ -1080,11 +1083,14 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 	else
 		task->signal->oom_score_adj = (oom_adjust * OOM_SCORE_ADJ_MAX) /
 								-OOM_DISABLE;
+err_task_lock:
 	task_unlock(task);
+err_sighand:
 	unlock_task_sighand(task, &flags);
+err_task_struct:
 	put_task_struct(task);
-
-	return count;
+out:
+	return err < 0 ? err : count;
 }
 
 static const struct file_operations proc_oom_adjust_operations = {
@@ -1125,36 +1131,39 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 	memset(buffer, 0, sizeof(buffer));
 	if (count > sizeof(buffer) - 1)
 		count = sizeof(buffer) - 1;
-	if (copy_from_user(buffer, buf, count))
-		return -EFAULT;
+	if (copy_from_user(buffer, buf, count)) {
+		err = -EFAULT;
+		goto out;
+	}
 
 	err = strict_strtol(strstrip(buffer), 0, &oom_score_adj);
 	if (err)
-		return -EINVAL;
+		goto out;
 	if (oom_score_adj < OOM_SCORE_ADJ_MIN ||
-			oom_score_adj > OOM_SCORE_ADJ_MAX)
-		return -EINVAL;
+			oom_score_adj > OOM_SCORE_ADJ_MAX) {
+		err = -EINVAL;
+		goto out;
+	}
 
 	task = get_proc_task(file->f_path.dentry->d_inode);
-	if (!task)
-		return -ESRCH;
+	if (!task) {
+		err = -ESRCH;
+		goto out;
+	}
 	if (!lock_task_sighand(task, &flags)) {
-		put_task_struct(task);
-		return -ESRCH;
+		err = -ESRCH;
+		goto err_task_struct;
 	}
 	if (oom_score_adj < task->signal->oom_score_adj &&
 			!capable(CAP_SYS_RESOURCE)) {
-		unlock_task_sighand(task, &flags);
-		put_task_struct(task);
-		return -EACCES;
+		err = -EACCES;
+		goto err_sighand;
 	}
 
 	task_lock(task);
 	if (!task->mm) {
-		task_unlock(task);
-		unlock_task_sighand(task, &flags);
-		put_task_struct(task);
-		return -EINVAL;
+		err = -EINVAL;
+		goto err_task_lock;
 	}
 	if (oom_score_adj != task->signal->oom_score_adj) {
 		if (oom_score_adj == OOM_SCORE_ADJ_MIN)
@@ -1172,10 +1181,14 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 	else
 		task->signal->oom_adj = (oom_score_adj * OOM_ADJUST_MAX) /
 							OOM_SCORE_ADJ_MAX;
+err_task_lock:
 	task_unlock(task);
+err_sighand:
 	unlock_task_sighand(task, &flags);
+err_task_struct:
 	put_task_struct(task);
-	return count;
+out:
+	return err < 0 ? err : count;
 }
 
 static const struct file_operations proc_oom_score_adj_operations = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
