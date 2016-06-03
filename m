Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5DC76B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 08:00:41 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id d10so32062671oby.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:00:41 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x193si2625759oix.55.2016.06.03.05.00.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Jun 2016 05:00:40 -0700 (PDT)
Subject: Re: [PATCH 0/10 -v3] Handle oom bypass more gracefully
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
Message-Id: <201606032100.AIH12958.HMOOOFLJSFQtVF@I-love.SAKURA.ne.jp>
Date: Fri, 3 Jun 2016 21:00:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> Patch 8 is new in this version and it addresses an issue pointed out
> by 0-day OOM report where an oom victim was reaped several times.

I believe we need below once-you-nacked patch as well.

It would be possible to clear victim->signal->oom_flag_origin when
that victim gets TIF_MEMDIE, but I think that moving oom_task_origin()
test to oom_badness() will allow oom_scan_process_thread() which calls
oom_unkillable_task() only for testing task->signal->oom_victims to be
removed by also moving task->signal->oom_victims test to oom_badness().
Thus, I prefer this way.
----------------------------------------
>From 91f167dc3a216894e124f976c3ffdcdf6fd802fd Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 3 Jun 2016 20:47:58 +0900
Subject: [PATCH] mm, oom: oom_task_origin should skip oom_reaped tasks

While "mm, oom: task_will_free_mem should skip oom_reaped tasks" meant to
make sure that task_will_free_mem(current) shortcut shall not select
MMF_OOM_REAPED current task after once the OOM reaper reaped current->mm
(or gave up reaping it), there is an unhandled exception.

Currently, oom_scan_process_thread() returns OOM_SCAN_SELECT if
oom_task_origin() returned true. But this might cause OOM livelock
because the OOM killer does not call oom_badness() in order to skip
MMF_OOM_REAPED task while it is possible that try_to_unuse() from swapoff
path or unmerge_and_remove_all_rmap_items() from ksm's run_store path
gets stuck at unkillable waits. We can't afford (at least for now)
replacing mmput() with mmput_async(), lock_page() with
lock_page_killable(), wait_on_page_bit() with wait_on_page_bit_killable(),
mutex_lock() with mutex_lock_killable(), down_read() with
down_read_killable() and so on which are used inside these paths.

Once the OOM reaper reaped that task's memory (or gave up reaping it),
the OOM killer must not select that task again when oom_task_origin(task)
returned true. We need to select different victims until that task can
call clear_current_oom_origin().

Since oom_badness() is a function which returns score of the given thread
group with eligibility/livelock test, it is more natural and safer to let
oom_badness() return highest score when oom_task_origin(task) == true.

This patch moves oom_task_origin() test from oom_scan_process_thread() to
after MMF_OOM_REAPED test inside oom_badness(), changes the callers to
receive the score using "unsigned long" variable, and eliminates
OOM_SCAN_SELECT path in the callers.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h |  1 -
 mm/memcontrol.c     |  9 +--------
 mm/oom_kill.c       | 22 ++++++++++------------
 3 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 5bc0457..d6e4f2a 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -50,7 +50,6 @@ enum oom_scan_t {
 	OOM_SCAN_OK,		/* scan thread and find its badness */
 	OOM_SCAN_CONTINUE,	/* do not consider thread for oom kill */
 	OOM_SCAN_ABORT,		/* abort the iteration and return */
-	OOM_SCAN_SELECT,	/* always select this thread first */
 };
 
 extern struct mutex oom_lock;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f161fe8..c325336 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1266,7 +1266,7 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	struct mem_cgroup *iter;
 	unsigned long chosen_points = 0;
 	unsigned long totalpages;
-	unsigned int points = 0;
+	unsigned long points = 0;
 	struct task_struct *chosen = NULL;
 
 	mutex_lock(&oom_lock);
@@ -1291,13 +1291,6 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		css_task_iter_start(&iter->css, &it);
 		while ((task = css_task_iter_next(&it))) {
 			switch (oom_scan_process_thread(&oc, task)) {
-			case OOM_SCAN_SELECT:
-				if (chosen)
-					put_task_struct(chosen);
-				chosen = task;
-				chosen_points = ULONG_MAX;
-				get_task_struct(chosen);
-				/* fall through */
 			case OOM_SCAN_CONTINUE:
 				continue;
 			case OOM_SCAN_ABORT:
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 340ea11..a9af021 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -188,6 +188,15 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	}
 
 	/*
+	 * If task is allocating a lot of memory and has been marked to be
+	 * killed first if it triggers an oom, then select it.
+	 */
+	if (oom_task_origin(p)) {
+		task_unlock(p);
+		return ULONG_MAX;
+	}
+
+	/*
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
@@ -297,13 +306,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 		return OOM_SCAN_OK;
 	}
 
-	/*
-	 * If task is allocating a lot of memory and has been marked to be
-	 * killed first if it triggers an oom, then select it.
-	 */
-	if (oom_task_origin(task))
-		return OOM_SCAN_SELECT;
-
 	return OOM_SCAN_OK;
 }
 
@@ -320,13 +322,9 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 
 	rcu_read_lock();
 	for_each_process(p) {
-		unsigned int points;
+		unsigned long points;
 
 		switch (oom_scan_process_thread(oc, p)) {
-		case OOM_SCAN_SELECT:
-			chosen = p;
-			chosen_points = ULONG_MAX;
-			/* fall through */
 		case OOM_SCAN_CONTINUE:
 			continue;
 		case OOM_SCAN_ABORT:
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
