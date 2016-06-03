Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 257F66B025E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 05:16:55 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 132so34909708lfz.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 02:16:55 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id v3si7027678wmd.69.2016.06.03.02.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 02:16:51 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id e3so21991363wme.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 02:16:51 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 02/10] proc, oom: drop bogus sighand lock
Date: Fri,  3 Jun 2016 11:16:36 +0200
Message-Id: <1464945404-30157-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Oleg has pointed out that can simplify both oom_adj_{read,write}
and oom_score_adj_{read,write} even further and drop the sighand
lock. The main purpose of the lock was to protect p->signal from
going away but this will not happen since ea6d290ca34c ("signals:
make task_struct->signal immutable/refcountable").

The other role of the lock was to synchronize different writers,
especially those with CAP_SYS_RESOURCE. Introduce a mutex for this
purpose. Later patches will need this lock anyway.

Suggested-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/base.c | 51 +++++++++++++++++----------------------------------
 1 file changed, 17 insertions(+), 34 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index a6014e45c516..968d5ea06e62 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1024,23 +1024,21 @@ static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t count,
 	char buffer[PROC_NUMBUF];
 	int oom_adj = OOM_ADJUST_MIN;
 	size_t len;
-	unsigned long flags;
 
 	if (!task)
 		return -ESRCH;
-	if (lock_task_sighand(task, &flags)) {
-		if (task->signal->oom_score_adj == OOM_SCORE_ADJ_MAX)
-			oom_adj = OOM_ADJUST_MAX;
-		else
-			oom_adj = (task->signal->oom_score_adj * -OOM_DISABLE) /
-				  OOM_SCORE_ADJ_MAX;
-		unlock_task_sighand(task, &flags);
-	}
+	if (task->signal->oom_score_adj == OOM_SCORE_ADJ_MAX)
+		oom_adj = OOM_ADJUST_MAX;
+	else
+		oom_adj = (task->signal->oom_score_adj * -OOM_DISABLE) /
+			  OOM_SCORE_ADJ_MAX;
 	put_task_struct(task);
 	len = snprintf(buffer, sizeof(buffer), "%d\n", oom_adj);
 	return simple_read_from_buffer(buf, count, ppos, buffer, len);
 }
 
+static DEFINE_MUTEX(oom_adj_mutex);
+
 /*
  * /proc/pid/oom_adj exists solely for backwards compatibility with previous
  * kernels.  The effective policy is defined by oom_score_adj, which has a
@@ -1057,7 +1055,6 @@ static ssize_t oom_adj_write(struct file *file, const char __user *buf,
 	struct task_struct *task;
 	char buffer[PROC_NUMBUF];
 	int oom_adj;
-	unsigned long flags;
 	int err;
 
 	memset(buffer, 0, sizeof(buffer));
@@ -1083,11 +1080,6 @@ static ssize_t oom_adj_write(struct file *file, const char __user *buf,
 		goto out;
 	}
 
-	if (!lock_task_sighand(task, &flags)) {
-		err = -ESRCH;
-		goto err_put_task;
-	}
-
 	/*
 	 * Scale /proc/pid/oom_score_adj appropriately ensuring that a maximum
 	 * value is always attainable.
@@ -1097,10 +1089,11 @@ static ssize_t oom_adj_write(struct file *file, const char __user *buf,
 	else
 		oom_adj = (oom_adj * OOM_SCORE_ADJ_MAX) / -OOM_DISABLE;
 
+	mutex_lock(&oom_adj_mutex);
 	if (oom_adj < task->signal->oom_score_adj &&
 	    !capable(CAP_SYS_RESOURCE)) {
 		err = -EACCES;
-		goto err_sighand;
+		goto err_unlock;
 	}
 
 	/*
@@ -1113,9 +1106,8 @@ static ssize_t oom_adj_write(struct file *file, const char __user *buf,
 
 	task->signal->oom_score_adj = oom_adj;
 	trace_oom_score_adj_update(task);
-err_sighand:
-	unlock_task_sighand(task, &flags);
-err_put_task:
+err_unlock:
+	mutex_unlock(&oom_adj_mutex);
 	put_task_struct(task);
 out:
 	return err < 0 ? err : count;
@@ -1133,15 +1125,11 @@ static ssize_t oom_score_adj_read(struct file *file, char __user *buf,
 	struct task_struct *task = get_proc_task(file_inode(file));
 	char buffer[PROC_NUMBUF];
 	short oom_score_adj = OOM_SCORE_ADJ_MIN;
-	unsigned long flags;
 	size_t len;
 
 	if (!task)
 		return -ESRCH;
-	if (lock_task_sighand(task, &flags)) {
-		oom_score_adj = task->signal->oom_score_adj;
-		unlock_task_sighand(task, &flags);
-	}
+	oom_score_adj = task->signal->oom_score_adj;
 	put_task_struct(task);
 	len = snprintf(buffer, sizeof(buffer), "%hd\n", oom_score_adj);
 	return simple_read_from_buffer(buf, count, ppos, buffer, len);
@@ -1152,7 +1140,6 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 {
 	struct task_struct *task;
 	char buffer[PROC_NUMBUF];
-	unsigned long flags;
 	int oom_score_adj;
 	int err;
 
@@ -1179,25 +1166,21 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 		goto out;
 	}
 
-	if (!lock_task_sighand(task, &flags)) {
-		err = -ESRCH;
-		goto err_put_task;
-	}
-
+	mutex_lock(&oom_adj_mutex);
 	if ((short)oom_score_adj < task->signal->oom_score_adj_min &&
 			!capable(CAP_SYS_RESOURCE)) {
 		err = -EACCES;
-		goto err_sighand;
+		goto err_unlock;
 	}
 
 	task->signal->oom_score_adj = (short)oom_score_adj;
 	if (has_capability_noaudit(current, CAP_SYS_RESOURCE))
 		task->signal->oom_score_adj_min = (short)oom_score_adj;
+
 	trace_oom_score_adj_update(task);
 
-err_sighand:
-	unlock_task_sighand(task, &flags);
-err_put_task:
+err_unlock:
+	mutex_unlock(&oom_adj_mutex);
 	put_task_struct(task);
 out:
 	return err < 0 ? err : count;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
