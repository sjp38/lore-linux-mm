Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 50B226B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 07:52:08 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id dh6so190049014obb.1
        for <linux-mm@kvack.org>; Fri, 20 May 2016 04:52:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 81si4710052itu.29.2016.05.20.04.52.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 May 2016 04:52:07 -0700 (PDT)
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160518125138.GH21654@dhcp22.suse.cz>
	<201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
	<20160520075035.GF19172@dhcp22.suse.cz>
In-Reply-To: <20160520075035.GF19172@dhcp22.suse.cz>
Message-Id: <201605202051.EBC82806.QLVMOtJOOFFFSH@I-love.SAKURA.ne.jp>
Date: Fri, 20 May 2016 20:51:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, oleg@redhat.com

Michal Hocko wrote:
> Here is a follow up for this patch. As I've mentioned in the other
> email, I would like to mark oom victim in the mm_struct but that
> requires more changes and the patch simplifies select_bad_process
> nicely already so I like this patch even now.
> ---
> From 06fc6821e581f82fb186770d84f5ee28f9fe18c3 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 20 May 2016 09:45:05 +0200
> Subject: [PATCH] mmotm: mmoom-speed-up-select_bad_process-loop-fix
> 
> Do not blow the signal_struct size. pahole -C signal_struct says:
> 
> struct signal_struct {
> 	atomic_t                   sigcnt;               /*     0     4 */
> 	atomic_t                   live;                 /*     4     4 */
> 	int                        nr_threads;           /*     8     4 */
> 
> 	/* XXX 4 bytes hole, try to pack */
> 
> 	struct list_head           thread_head;          /*    16    16 */
> 
> So we can stick the new counter after nr_threads and keep the size
> of the structure on 64b.
> 
> While we are at it also remove the thread_group_leader check from
> select_bad_process because it is not really needed as we are iterating
> processes rather than threads.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Or, we can do equivalent thing without adding "atomic_t oom_victims".
If you prefer below approach, we can revert "[PATCH v3] mm,oom: speed up
select_bad_process() loop.".

---
 include/linux/oom.h   |  3 ++-
 include/linux/sched.h |  1 -
 mm/memcontrol.c       |  2 +-
 mm/oom_kill.c         | 37 ++++++++++++++++++++++++++++---------
 4 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 8346952..6b4a2f3 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -90,7 +90,8 @@ extern void check_panic_on_oom(struct oom_control *oc,
 			       struct mem_cgroup *memcg);
 
 extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
-		struct task_struct *task, unsigned long totalpages);
+					       struct task_struct *task,
+					       bool is_thread_group);
 
 extern bool out_of_memory(struct oom_control *oc);
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1496c50..b245c72 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -772,7 +772,6 @@ struct signal_struct {
 	 */
 	unsigned long long sum_sched_runtime;
 
-	atomic_t oom_victims; /* # of TIF_MEDIE threads in this thread group */
 	/*
 	 * We don't bother to synchronize most readers of this at all,
 	 * because there is no reader checking a limit that actually needs
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b3f16ab..a1fa626 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1287,7 +1287,7 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 		css_task_iter_start(&iter->css, &it);
 		while ((task = css_task_iter_next(&it))) {
-			switch (oom_scan_process_thread(&oc, task, totalpages)) {
+			switch (oom_scan_process_thread(&oc, task, false)) {
 			case OOM_SCAN_SELECT:
 				if (chosen)
 					put_task_struct(chosen);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8e151d0..7d9437c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -273,8 +273,25 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 }
 #endif
 
+static bool has_pending_victim(struct task_struct *p)
+{
+	struct task_struct *t;
+	bool ret = false;
+
+	rcu_read_lock();
+	for_each_thread(p, t) {
+		if (test_tsk_thread_flag(t, TIF_MEMDIE)) {
+			ret = true;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	return ret;
+}
+
 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
-			struct task_struct *task, unsigned long totalpages)
+					struct task_struct *task,
+					bool is_thread_group)
 {
 	if (oom_unkillable_task(task, NULL, oc->nodemask))
 		return OOM_SCAN_CONTINUE;
@@ -283,8 +300,15 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves.
 	 */
-	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
-		return OOM_SCAN_ABORT;
+	if (is_thread_group) {
+		if (!is_sysrq_oom(oc) && has_pending_victim(task))
+			return OOM_SCAN_ABORT;
+	} else {
+		if (test_tsk_thread_flag(task, TIF_MEMDIE))
+			return OOM_SCAN_ABORT;
+		if (!task->mm)
+			return OOM_SCAN_CONTINUE;
+	}
 
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
@@ -311,7 +335,7 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 	for_each_process(p) {
 		unsigned int points;
 
-		switch (oom_scan_process_thread(oc, p, totalpages)) {
+		switch (oom_scan_process_thread(oc, p, true)) {
 		case OOM_SCAN_SELECT:
 			chosen = p;
 			chosen_points = ULONG_MAX;
@@ -327,9 +351,6 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 		points = oom_badness(p, NULL, oc->nodemask, totalpages);
 		if (!points || points < chosen_points)
 			continue;
-		/* Prefer thread group leaders for display purposes */
-		if (points == chosen_points && thread_group_leader(chosen))
-			continue;
 
 		chosen = p;
 		chosen_points = points;
@@ -669,7 +690,6 @@ void mark_oom_victim(struct task_struct *tsk)
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
-	atomic_inc(&tsk->signal->oom_victims);
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -687,7 +707,6 @@ void exit_oom_victim(struct task_struct *tsk)
 {
 	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
-	atomic_dec(&tsk->signal->oom_victims);
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
-- 
1.8.3.1

Note that "[PATCH v3] mm,oom: speed up select_bad_process() loop." temporarily
broke oom_task_origin(task) case, for oom_select_bad_process() might select
a task without mm because oom_badness() which checks for mm != NULL will not be
called. This regression can be fixed by changing oom_badness() to return large
value by moving oom_task_origin(task) test into oom_badness().

 mm/oom_kill.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7d9437c..c40c649 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -175,6 +175,15 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 		return 0;
 
 	/*
+	 * If task is allocating a lot of memory and has been marked to be
+	 * killed first if it triggers an oom, then select it.
+	 */
+	if (oom_task_origin(p)) {
+		task_unlock(p);
+		return UINT_MAX - 1;
+	}
+
+	/*
 	 * Do not even consider tasks which are explicitly marked oom
 	 * unkillable or have been already oom reaped.
 	 */
@@ -310,13 +319,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 			return OOM_SCAN_CONTINUE;
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
 
-- 
1.8.3.1

Presumably, we want to do oom_task_origin(p) test after adj == OOM_SCORE_ADJ_MIN ||
test_bit(MMF_OOM_REAPED, &p->mm->flags) test because oom_task_origin(p) could become
"not suitable for victims" after p was selected as OOM victim and is OOM reaped.



By the way, I noticed that mem_cgroup_out_of_memory() might have a bug about its
return value. It returns true if hit OOM_SCAN_ABORT after chosen != NULL, false
if hit OOM_SCAN_ABORT before chosen != NULL. Which is expected return value?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
