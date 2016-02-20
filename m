Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id D719F6B0005
	for <linux-mm@kvack.org>; Sat, 20 Feb 2016 00:50:44 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id l127so130456555iof.3
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 21:50:44 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id qd10si18040804igb.33.2016.02.19.21.50.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 21:50:44 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: speed up select_bad_process() loop.
Date: Sat, 20 Feb 2016 14:49:58 +0900
Message-Id: <1455947398-14414-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov@virtuozzo.com
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Currently, oom_unkillable_task() is called for twice for each thread,
once at oom_scan_process_thread() and again at oom_badness().

The reason oom_scan_process_thread() needs to call oom_unkillable_task()
is to skip TIF_MEMDIE test and !mm test and oom_task_origin() test if
that thread is OOM-unkillable. Note that task_will_free_mem() test will be
removed by "mm,oom: don't abort on exiting processes when selecting a victim."
patch ( http://lkml.kernel.org/r/20160217143917.GP29196@dhcp22.suse.cz ).

If we call oom_badness() first, we can exclude OOM-unkillable processes
first. Also, we no longer need to do !mm test because oom_badness() calls
find_lock_task_mm() which includes !mm test. Also, we don't need to do
oom_task_origin() test for each thread because oom_task_origin() returns
the same result for threads in a process. Thus, what we need to do can be
reduced to TIF_MEMDIE test for each thread and oom_task_origin() test for
each process.

This patch changes select_bad_process() to again use for_each_process()
rather than for_each_process_thread() (which was restored by
commit 3a5dda7a17cf ("oom: prevent unnecessary oom kills or kernel panics").

As a side effect of this patch, TIF_MEMDIE test and oom_task_origin()
test are done after oom_score_adj test. While it is unlikely that
oom_score_adj of a process that does swapoff() operation is set to -1000,
it might become true when we merge the OOM reaper because currently it
is supposed to update oom_score_adj to -1000 in order to avoid selecting
the same process forever. Maybe the OOM reaper is updated to use a flag
bit for avoid selecting the same process forever.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 38 ++++++++++++++++++++------------------
 1 file changed, 20 insertions(+), 18 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 703537a2..0330788 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -302,29 +302,31 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 static struct task_struct *select_bad_process(struct oom_control *oc,
 		unsigned int *ppoints, unsigned long totalpages)
 {
-	struct task_struct *g, *p;
+	struct task_struct *p, *t;
 	struct task_struct *chosen = NULL;
 	unsigned long chosen_points = 0;
 
 	rcu_read_lock();
-	for_each_process_thread(g, p) {
-		unsigned int points;
-
-		switch (oom_scan_process_thread(oc, p, totalpages)) {
-		case OOM_SCAN_SELECT:
-			chosen = p;
-			chosen_points = ULONG_MAX;
-			/* fall through */
-		case OOM_SCAN_CONTINUE:
+	for_each_process(p) {
+		/* Filter out any OOM-unkillable processes. */
+		unsigned long points = oom_badness(p, NULL, oc->nodemask,
+						   totalpages);
+
+		if (!points)
 			continue;
-		case OOM_SCAN_ABORT:
-			rcu_read_unlock();
-			return (struct task_struct *)(-1UL);
-		case OOM_SCAN_OK:
-			break;
-		};
-		points = oom_badness(p, NULL, oc->nodemask, totalpages);
-		if (!points || points < chosen_points)
+		/* Wait for existing OOM-killed processes if any. */
+		if (!is_sysrq_oom(oc)) {
+			for_each_thread(p, t) {
+				if (!test_tsk_thread_flag(t, TIF_MEMDIE))
+					continue;
+				rcu_read_unlock();
+				return (struct task_struct *)(-1UL);
+			}
+		}
+		/* Check for processes doing swapoff() operation. */
+		if (oom_task_origin(p))
+			points = ULONG_MAX;
+		if (points < chosen_points)
 			continue;
 		/* Prefer thread group leaders for display purposes */
 		if (points == chosen_points && thread_group_leader(chosen))
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
