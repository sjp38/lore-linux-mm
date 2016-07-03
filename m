Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90DFD6B0253
	for <linux-mm@kvack.org>; Sat,  2 Jul 2016 22:40:29 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id o10so232686048obp.3
        for <linux-mm@kvack.org>; Sat, 02 Jul 2016 19:40:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y130si684329ioy.129.2016.07.02.19.40.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 02 Jul 2016 19:40:29 -0700 (PDT)
Subject: [PATCH 4/8] mm,oom: Remove OOM_SCAN_ABORT case.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
In-Reply-To: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
Message-Id: <201607031139.DFD39537.QLVOHJMSFtOOFF@I-love.SAKURA.ne.jp>
Date: Sun, 3 Jul 2016 11:39:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

>From e2d850ccbc7abc2643f5aac4dd09787f09270fd4 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 2 Jul 2016 23:01:17 +0900
Subject: [PATCH 4/8] mm,oom: Remove OOM_SCAN_ABORT case.

Since oom_has_pending_mm() controls whether to select next OOM victim,
we no longer need to abort OOM victim selection loop using OOM_SCAN_ABORT
case. Remove it.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h |  1 -
 mm/memcontrol.c     |  8 --------
 mm/oom_kill.c       | 24 +-----------------------
 3 files changed, 1 insertion(+), 32 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 1e538c5..5991d41 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -49,7 +49,6 @@ enum oom_constraint {
 enum oom_scan_t {
 	OOM_SCAN_OK,		/* scan thread and find its badness */
 	OOM_SCAN_CONTINUE,	/* do not consider thread for oom kill */
-	OOM_SCAN_ABORT,		/* abort the iteration and return */
 	OOM_SCAN_SELECT,	/* always select this thread first */
 };
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 835c95c..c17160d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1263,14 +1263,6 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
index 39c5034..734378a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -324,25 +324,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
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
@@ -374,9 +355,6 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 			/* fall through */
 		case OOM_SCAN_CONTINUE:
 			continue;
-		case OOM_SCAN_ABORT:
-			rcu_read_unlock();
-			return (struct task_struct *)(-1UL);
 		case OOM_SCAN_OK:
 			break;
 		};
@@ -1075,7 +1053,7 @@ bool out_of_memory(struct oom_control *oc)
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
