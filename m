Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CCAEF6B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 07:52:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c82so20727734wme.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 04:52:28 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id k197si37772449wmg.0.2016.06.09.04.52.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 04:52:27 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n184so10067081wmn.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 04:52:26 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 01/10] proc, oom: drop bogus task_lock and mm check
Date: Thu,  9 Jun 2016 13:52:08 +0200
Message-Id: <1465473137-22531-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

both oom_adj_write and oom_score_adj_write are using task_lock,
check for task->mm and fail if it is NULL. This is not needed because
the oom_score_adj is per signal struct so we do not need mm at all.
The code has been introduced by 3d5992d2ac7d ("oom: add per-mm oom
disable count") but we do not do per-mm oom disable since c9f01245b6a7
("oom: remove oom_disable_count").

The task->mm check is even not correct because the current thread might
have exited but the thread group might be still alive - e.g. thread
group leader would lead that echo $VAL > /proc/pid/oom_score_adj would
always fail with EINVAL while /proc/pid/task/$other_tid/oom_score_adj
would succeed. This is unexpected at best.

Remove the lock along with the check to fix the unexpected behavior
and also because there is not real need for the lock in the first place.

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/base.c | 22 ++++------------------
 1 file changed, 4 insertions(+), 18 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index be73f4d0cb01..a6014e45c516 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1083,15 +1083,9 @@ static ssize_t oom_adj_write(struct file *file, const char __user *buf,
 		goto out;
 	}
 
-	task_lock(task);
-	if (!task->mm) {
-		err = -EINVAL;
-		goto err_task_lock;
-	}
-
 	if (!lock_task_sighand(task, &flags)) {
 		err = -ESRCH;
-		goto err_task_lock;
+		goto err_put_task;
 	}
 
 	/*
@@ -1121,8 +1115,7 @@ static ssize_t oom_adj_write(struct file *file, const char __user *buf,
 	trace_oom_score_adj_update(task);
 err_sighand:
 	unlock_task_sighand(task, &flags);
-err_task_lock:
-	task_unlock(task);
+err_put_task:
 	put_task_struct(task);
 out:
 	return err < 0 ? err : count;
@@ -1186,15 +1179,9 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 		goto out;
 	}
 
-	task_lock(task);
-	if (!task->mm) {
-		err = -EINVAL;
-		goto err_task_lock;
-	}
-
 	if (!lock_task_sighand(task, &flags)) {
 		err = -ESRCH;
-		goto err_task_lock;
+		goto err_put_task;
 	}
 
 	if ((short)oom_score_adj < task->signal->oom_score_adj_min &&
@@ -1210,8 +1197,7 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 
 err_sighand:
 	unlock_task_sighand(task, &flags);
-err_task_lock:
-	task_unlock(task);
+err_put_task:
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
