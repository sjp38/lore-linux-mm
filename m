Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 631676B01F1
	for <linux-mm@kvack.org>; Sat, 28 Aug 2010 18:25:24 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o7SMPLL0019747
	for <linux-mm@kvack.org>; Sat, 28 Aug 2010 15:25:22 -0700
Received: from pvh1 (pvh1.prod.google.com [10.241.210.193])
	by kpbe17.cbf.corp.google.com with ESMTP id o7SMPKps009820
	for <linux-mm@kvack.org>; Sat, 28 Aug 2010 15:25:20 -0700
Received: by pvh1 with SMTP id 1so2140357pvh.23
        for <linux-mm@kvack.org>; Sat, 28 Aug 2010 15:25:20 -0700 (PDT)
Date: Sat, 28 Aug 2010 15:25:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] oom: fix locking for oom_adj and oom_score_adj
In-Reply-To: <20100827144835.a125feea.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1008281524120.24754@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com> <20100827144835.a125feea.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Aug 2010, Andrew Morton wrote:

> > From: Ying Han <yinghan@google.com>
> > 
> > It's pointless to kill a task if another thread sharing its mm cannot be
> > killed to allow future memory freeing.  A subsequent patch will prevent
> > kills in such cases, but first it's necessary to have a way to flag a
> > task that shares memory with an OOM_DISABLE task that doesn't incur an
> > additional tasklist scan, which would make select_bad_process() an O(n^2)
> > function.
> > 
> > This patch adds an atomic counter to struct mm_struct that follows how
> > many threads attached to it have an oom_score_adj of OOM_SCORE_ADJ_MIN.
> > They cannot be killed by the kernel, so their memory cannot be freed in
> > oom conditions.
> > 
> > This only requires task_lock() on the task that we're operating on, it
> > does not require mm->mmap_sem since task_lock() pins the mm and the
> > operation is atomic.
> 
> I don't think lockdep likes us taking task_lock() inside
> lock_task_sighand(), in oom_adjust_write():
> 
> [   78.185341] 
> [   78.185341] =========================================================
> [   78.185341] [ INFO: possible irq lock inversion dependency detected ]
> [   78.185341] 2.6.36-rc2-mm1 #6
> [   78.185341] ---------------------------------------------------------
> [   78.185341] kworker/0:1/0 just changed the state of lock:
> [   78.185341]  (&(&sighand->siglock)->rlock){-.....}, at: [<ffffffff81042d83>] lock_task_sighand+0x9a/0xda
> [   78.185341] but this lock took another, HARDIRQ-unsafe lock in the past:
> [   78.185341]  (&(&p->alloc_lock)->rlock){+.+...}
> [   78.185341] 
> [   78.185341] and interrupts could create inverse lock ordering between them.



oom: fix locking for oom_adj and oom_score_adj

The locking order in oom_adjust_write() and oom_score_adj_write() for 
task->alloc_lock and task->sighand->siglock is reversed, and lockdep
notices that irqs could encounter an ABBA scenario.

This fixes the locking order so that we always take task_lock(task) prior
to lock_task_sighand(task).

Reported-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Can't be folded into the offending patch, 
 oom-add-per-mm-oom-disable-count.patch, because later patch
 oom-rewrite-error-handling-for-oom_adj-and-oom_score_adj-tunables.patch 
 rewrites error handling in these functions.

 fs/proc/base.c |   40 +++++++++++++++++++++-------------------
 1 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1042,9 +1042,16 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 		err = -ESRCH;
 		goto out;
 	}
+
+	task_lock(task);
+	if (!task->mm) {
+		err = -EINVAL;
+		goto err_task_lock;
+	}
+	
 	if (!lock_task_sighand(task, &flags)) {
 		err = -ESRCH;
-		goto err_task_struct;
+		goto err_task_lock;
 	}
 
 	if (oom_adjust < task->signal->oom_adj && !capable(CAP_SYS_RESOURCE)) {
@@ -1052,12 +1059,6 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 		goto err_sighand;
 	}
 
-	task_lock(task);
-	if (!task->mm) {
-		err = -EINVAL;
-		goto err_task_lock;
-	}
-
 	if (oom_adjust != task->signal->oom_adj) {
 		if (oom_adjust == OOM_DISABLE)
 			atomic_inc(&task->mm->oom_disable_count);
@@ -1083,11 +1084,10 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 	else
 		task->signal->oom_score_adj = (oom_adjust * OOM_SCORE_ADJ_MAX) /
 								-OOM_DISABLE;
-err_task_lock:
-	task_unlock(task);
 err_sighand:
 	unlock_task_sighand(task, &flags);
-err_task_struct:
+err_task_lock:
+	task_unlock(task);
 	put_task_struct(task);
 out:
 	return err < 0 ? err : count;
@@ -1150,21 +1150,24 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 		err = -ESRCH;
 		goto out;
 	}
+
+	task_lock(task);
+	if (!task->mm) {
+		err = -EINVAL;
+		goto err_task_lock;
+	}
+
 	if (!lock_task_sighand(task, &flags)) {
 		err = -ESRCH;
-		goto err_task_struct;
+		goto err_task_lock;
 	}
+
 	if (oom_score_adj < task->signal->oom_score_adj &&
 			!capable(CAP_SYS_RESOURCE)) {
 		err = -EACCES;
 		goto err_sighand;
 	}
 
-	task_lock(task);
-	if (!task->mm) {
-		err = -EINVAL;
-		goto err_task_lock;
-	}
 	if (oom_score_adj != task->signal->oom_score_adj) {
 		if (oom_score_adj == OOM_SCORE_ADJ_MIN)
 			atomic_inc(&task->mm->oom_disable_count);
@@ -1181,11 +1184,10 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 	else
 		task->signal->oom_adj = (oom_score_adj * OOM_ADJUST_MAX) /
 							OOM_SCORE_ADJ_MAX;
-err_task_lock:
-	task_unlock(task);
 err_sighand:
 	unlock_task_sighand(task, &flags);
-err_task_struct:
+err_task_lock:
+	task_unlock(task);
 	put_task_struct(task);
 out:
 	return err < 0 ? err : count;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
