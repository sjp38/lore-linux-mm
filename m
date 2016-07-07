Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 524866B0260
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 12:06:25 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l202so48632154ioe.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 09:06:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 185si38764oia.232.2016.07.07.09.06.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 09:06:24 -0700 (PDT)
Subject: [PATCH 5/6] mm,oom: Remove OOM_SCAN_ABORT case and signal_struct->oom_victims.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
In-Reply-To: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
Message-Id: <201607080106.DCD82819.tJFHVLSOOQFMFO@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jul 2016 01:06:12 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

>From 2da51204250a2f1127792f98c12436771c07b67d Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jul 2016 00:41:38 +0900
Subject: [PATCH 5/6] mm,oom: Remove OOM_SCAN_ABORT case and signal_struct->oom_victims.

Since oom_has_pending_mm() controls whether to select next OOM victim,
we no longer need to abort OOM victim selection loop using OOM_SCAN_ABORT
case. Also, since signal_struct->oom_victims was used only for allowing
oom_scan_process_thread() to return OOM_SCAN_ABORT, we no longer need to
use signal_struct->oom_victims.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h   |  1 -
 include/linux/sched.h |  1 -
 mm/memcontrol.c       |  8 --------
 mm/oom_kill.c         | 26 +-------------------------
 4 files changed, 1 insertion(+), 35 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index cb3f041..27be4ba 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -49,7 +49,6 @@ enum oom_constraint {
 enum oom_scan_t {
 	OOM_SCAN_OK,		/* scan thread and find its badness */
 	OOM_SCAN_CONTINUE,	/* do not consider thread for oom kill */
-	OOM_SCAN_ABORT,		/* abort the iteration and return */
 	OOM_SCAN_SELECT,	/* always select this thread first */
 };
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index c0efd80..2f57cf1c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -670,7 +670,6 @@ struct signal_struct {
 	atomic_t		sigcnt;
 	atomic_t		live;
 	int			nr_threads;
-	atomic_t oom_victims; /* # of TIF_MEDIE threads in this thread group */
 	struct list_head	thread_head;
 
 	wait_queue_head_t	wait_chldexit;	/* for wait4() */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5043324..6afe1c5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1262,14 +1262,6 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				/* fall through */
 			case OOM_SCAN_CONTINUE:
 				continue;
-			case OOM_SCAN_ABORT:
-				css_task_iter_end(&it);
-				mem_cgroup_iter_break(memcg, iter);
-				if (chosen)
-					put_task_struct(chosen);
-				/* Set a dummy value to return "true". */
-				chosen = (void *) 1;
-				goto unlock;
 			case OOM_SCAN_OK:
 				break;
 			};
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 223e1fe..b6b79ae 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -304,25 +304,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 		return OOM_SCAN_CONTINUE;
 
 	/*
-	 * This task already has access to memory reserves and is being killed.
-	 * Don't allow any other task to have access to the reserves unless
-	 * the task has MMF_OOM_REAPED because chances that it would release
-	 * any memory is quite low.
-	 */
-	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
-		struct task_struct *p = find_lock_task_mm(task);
-		enum oom_scan_t ret = OOM_SCAN_ABORT;
-
-		if (p) {
-			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
-				ret = OOM_SCAN_CONTINUE;
-			task_unlock(p);
-		}
-
-		return ret;
-	}
-
-	/*
 	 * If task is allocating a lot of memory and has been marked to be
 	 * killed first if it triggers an oom, then select it.
 	 */
@@ -354,9 +335,6 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 			/* fall through */
 		case OOM_SCAN_CONTINUE:
 			continue;
-		case OOM_SCAN_ABORT:
-			rcu_read_unlock();
-			return (struct task_struct *)(-1UL);
 		case OOM_SCAN_OK:
 			break;
 		};
@@ -626,7 +604,6 @@ void mark_oom_victim(struct task_struct *tsk)
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
-	atomic_inc(&tsk->signal->oom_victims);
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -659,7 +636,6 @@ void exit_oom_victim(struct task_struct *tsk)
 {
 	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
-	atomic_dec(&tsk->signal->oom_victims);
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
@@ -1012,7 +988,7 @@ bool out_of_memory(struct oom_control *oc)
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (p && p != (void *)-1UL) {
+	if (p) {
 		oom_kill_process(oc, p, points, totalpages, "Out of memory");
 		/*
 		 * Give the killed process a good chance to exit before trying
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
