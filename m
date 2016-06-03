Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 470F36B025F
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 05:16:57 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e3so38456690wme.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 02:16:57 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id r4si6319809wjm.231.2016.06.03.02.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 02:16:52 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n184so21522759wmn.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 02:16:52 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 03/10] proc, oom_adj: extract oom_score_adj setting into a helper
Date: Fri,  3 Jun 2016 11:16:37 +0200
Message-Id: <1464945404-30157-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
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
 fs/proc/base.c | 97 ++++++++++++++++++++++++++++------------------------------
 1 file changed, 46 insertions(+), 51 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 968d5ea06e62..520fa467cad0 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1037,7 +1037,50 @@ static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t count,
 	return simple_read_from_buffer(buf, count, ppos, buffer, len);
 }
 
-static DEFINE_MUTEX(oom_adj_mutex);
+static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
+{
+	static DEFINE_MUTEX(oom_adj_mutex);
+	struct task_struct *task;
+	int err = 0;
+
+	task = get_proc_task(file_inode(file));
+	if (!task) {
+		err = -ESRCH;
+		goto out;
+	}
+
+	mutex_lock(&oom_adj_mutex);
+	if (legacy) {
+		if (oom_adj < task->signal->oom_score_adj &&
+				!capable(CAP_SYS_RESOURCE)) {
+			err = -EACCES;
+			goto err_unlock;
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
+			goto err_unlock;
+		}
+	}
+
+	task->signal->oom_score_adj = oom_adj;
+	if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
+		task->signal->oom_score_adj_min = (short)oom_adj;
+	trace_oom_score_adj_update(task);
+err_unlock:
+	mutex_unlock(&oom_adj_mutex);
+	put_task_struct(task);
+out:
+	return err;
+}
 
 /*
  * /proc/pid/oom_adj exists solely for backwards compatibility with previous
@@ -1052,7 +1095,6 @@ static DEFINE_MUTEX(oom_adj_mutex);
 static ssize_t oom_adj_write(struct file *file, const char __user *buf,
 			     size_t count, loff_t *ppos)
 {
-	struct task_struct *task;
 	char buffer[PROC_NUMBUF];
 	int oom_adj;
 	int err;
@@ -1074,12 +1116,6 @@ static ssize_t oom_adj_write(struct file *file, const char __user *buf,
 		goto out;
 	}
 
-	task = get_proc_task(file_inode(file));
-	if (!task) {
-		err = -ESRCH;
-		goto out;
-	}
-
 	/*
 	 * Scale /proc/pid/oom_score_adj appropriately ensuring that a maximum
 	 * value is always attainable.
@@ -1089,26 +1125,7 @@ static ssize_t oom_adj_write(struct file *file, const char __user *buf,
 	else
 		oom_adj = (oom_adj * OOM_SCORE_ADJ_MAX) / -OOM_DISABLE;
 
-	mutex_lock(&oom_adj_mutex);
-	if (oom_adj < task->signal->oom_score_adj &&
-	    !capable(CAP_SYS_RESOURCE)) {
-		err = -EACCES;
-		goto err_unlock;
-	}
-
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
-err_unlock:
-	mutex_unlock(&oom_adj_mutex);
-	put_task_struct(task);
+	err = __set_oom_adj(file, oom_adj, true);
 out:
 	return err < 0 ? err : count;
 }
@@ -1138,7 +1155,6 @@ static ssize_t oom_score_adj_read(struct file *file, char __user *buf,
 static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 					size_t count, loff_t *ppos)
 {
-	struct task_struct *task;
 	char buffer[PROC_NUMBUF];
 	int oom_score_adj;
 	int err;
@@ -1160,28 +1176,7 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 		goto out;
 	}
 
-	task = get_proc_task(file_inode(file));
-	if (!task) {
-		err = -ESRCH;
-		goto out;
-	}
-
-	mutex_lock(&oom_adj_mutex);
-	if ((short)oom_score_adj < task->signal->oom_score_adj_min &&
-			!capable(CAP_SYS_RESOURCE)) {
-		err = -EACCES;
-		goto err_unlock;
-	}
-
-	task->signal->oom_score_adj = (short)oom_score_adj;
-	if (has_capability_noaudit(current, CAP_SYS_RESOURCE))
-		task->signal->oom_score_adj_min = (short)oom_score_adj;
-
-	trace_oom_score_adj_update(task);
-
-err_unlock:
-	mutex_unlock(&oom_adj_mutex);
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
