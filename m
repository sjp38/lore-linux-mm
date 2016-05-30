Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B75B6B0260
	for <linux-mm@kvack.org>; Mon, 30 May 2016 09:06:10 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 132so58481305lfz.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:06:10 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id xa9si44406564wjc.51.2016.05.30.06.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 06:06:07 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n129so22523291wmn.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:06:06 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/6] proc, oom_adj: extract oom_score_adj setting into a helper
Date: Mon, 30 May 2016 15:05:52 +0200
Message-Id: <1464613556-16708-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Currently we have two proc interfaces to set oom_score_adj. The legacy
/proc/<pid>/oom_adj and /proc/<pid>/oom_score_adj which both have their
specific handlers. Big part of the logic is duplicated so extract the
common code into __set_oom_adj helper. Legacy knob still expects some
details slightly different so make sure those are handled same way - e.g.
the legacy mode ignores oom_score_adj_min and it warns about the usage.

This patch shouldn't introduce any functional changes.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/base.c | 112 +++++++++++++++++++++++++++------------------------------
 1 file changed, 52 insertions(+), 60 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index a6014e45c516..0afc77d4d84a 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1041,6 +1041,56 @@ static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t count,
 	return simple_read_from_buffer(buf, count, ppos, buffer, len);
 }
 
+static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
+{
+	struct task_struct *task;
+	unsigned long flags;
+	int err = 0;
+
+	task = get_proc_task(file_inode(file));
+	if (!task) {
+		err = -ESRCH;
+		goto out;
+	}
+
+	if (!lock_task_sighand(task, &flags)) {
+		err = -ESRCH;
+		goto err_put_task;
+	}
+
+	if (legacy) {
+		if (oom_adj < task->signal->oom_score_adj &&
+				!capable(CAP_SYS_RESOURCE)) {
+			err = -EACCES;
+			goto err_sighand;
+		}
+		/*
+		 * /proc/pid/oom_adj is provided for legacy purposes, ask users to use
+		 * /proc/pid/oom_score_adj instead.
+		 */
+		pr_warn_once("%s (%d): /proc/%d/oom_adj is deprecated, please use /proc/%d/oom_score_adj instead.\n",
+			  current->comm, task_pid_nr(current), task_pid_nr(task),
+			  task_pid_nr(task));
+	} else {
+		if ((short)oom_adj < task->signal->oom_score_adj_min &&
+				!capable(CAP_SYS_RESOURCE)) {
+			err = -EACCES;
+			goto err_sighand;
+		}
+	}
+
+	task->signal->oom_score_adj = oom_adj;
+	if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
+		task->signal->oom_score_adj_min = (short)oom_adj;
+	trace_oom_score_adj_update(task);
+err_sighand:
+	unlock_task_sighand(task, &flags);
+err_put_task:
+	put_task_struct(task);
+out:
+	return err;
+}
+
 /*
  * /proc/pid/oom_adj exists solely for backwards compatibility with previous
  * kernels.  The effective policy is defined by oom_score_adj, which has a
@@ -1054,10 +1104,8 @@ static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t count,
 static ssize_t oom_adj_write(struct file *file, const char __user *buf,
 			     size_t count, loff_t *ppos)
 {
-	struct task_struct *task;
 	char buffer[PROC_NUMBUF];
 	int oom_adj;
-	unsigned long flags;
 	int err;
 
 	memset(buffer, 0, sizeof(buffer));
@@ -1077,17 +1125,6 @@ static ssize_t oom_adj_write(struct file *file, const char __user *buf,
 		goto out;
 	}
 
-	task = get_proc_task(file_inode(file));
-	if (!task) {
-		err = -ESRCH;
-		goto out;
-	}
-
-	if (!lock_task_sighand(task, &flags)) {
-		err = -ESRCH;
-		goto err_put_task;
-	}
-
 	/*
 	 * Scale /proc/pid/oom_score_adj appropriately ensuring that a maximum
 	 * value is always attainable.
@@ -1097,26 +1134,8 @@ static ssize_t oom_adj_write(struct file *file, const char __user *buf,
 	else
 		oom_adj = (oom_adj * OOM_SCORE_ADJ_MAX) / -OOM_DISABLE;
 
-	if (oom_adj < task->signal->oom_score_adj &&
-	    !capable(CAP_SYS_RESOURCE)) {
-		err = -EACCES;
-		goto err_sighand;
-	}
+	err = __set_oom_adj(file, oom_adj, true);
 
-	/*
-	 * /proc/pid/oom_adj is provided for legacy purposes, ask users to use
-	 * /proc/pid/oom_score_adj instead.
-	 */
-	pr_warn_once("%s (%d): /proc/%d/oom_adj is deprecated, please use /proc/%d/oom_score_adj instead.\n",
-		  current->comm, task_pid_nr(current), task_pid_nr(task),
-		  task_pid_nr(task));
-
-	task->signal->oom_score_adj = oom_adj;
-	trace_oom_score_adj_update(task);
-err_sighand:
-	unlock_task_sighand(task, &flags);
-err_put_task:
-	put_task_struct(task);
 out:
 	return err < 0 ? err : count;
 }
@@ -1150,9 +1169,7 @@ static ssize_t oom_score_adj_read(struct file *file, char __user *buf,
 static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 					size_t count, loff_t *ppos)
 {
-	struct task_struct *task;
 	char buffer[PROC_NUMBUF];
-	unsigned long flags;
 	int oom_score_adj;
 	int err;
 
@@ -1173,32 +1190,7 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 		goto out;
 	}
 
-	task = get_proc_task(file_inode(file));
-	if (!task) {
-		err = -ESRCH;
-		goto out;
-	}
-
-	if (!lock_task_sighand(task, &flags)) {
-		err = -ESRCH;
-		goto err_put_task;
-	}
-
-	if ((short)oom_score_adj < task->signal->oom_score_adj_min &&
-			!capable(CAP_SYS_RESOURCE)) {
-		err = -EACCES;
-		goto err_sighand;
-	}
-
-	task->signal->oom_score_adj = (short)oom_score_adj;
-	if (has_capability_noaudit(current, CAP_SYS_RESOURCE))
-		task->signal->oom_score_adj_min = (short)oom_score_adj;
-	trace_oom_score_adj_update(task);
-
-err_sighand:
-	unlock_task_sighand(task, &flags);
-err_put_task:
-	put_task_struct(task);
+	err = __set_oom_adj(file, oom_score_adj, false);
 out:
 	return err < 0 ? err : count;
 }
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
