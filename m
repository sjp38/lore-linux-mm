Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4C5D66B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 09:33:57 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id g6so39833133igt.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 06:33:57 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id i5si21726876iof.113.2016.02.19.06.33.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 06:33:56 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: kill duplicated oom_unkillable_task() checks.
Date: Fri, 19 Feb 2016 23:33:31 +0900
Message-Id: <1455892411-7611-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov@virtuozzo.com
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Currently, oom_unkillable_task() is called for twice for each thread,
once at oom_scan_process_thread() and again at oom_badness().

The reason oom_scan_process_thread() needs to call oom_unkillable_task()
is to skip TIF_MEMDIE test and oom_task_origin() test if that thread is
not OOM-killable.

But there is a problem with this ordering, for oom_task_origin() == true
will unconditionally select that thread regardless of oom_score_adj.
When we merge the OOM reaper, the OOM reaper will mark already reaped
process as OOM-unkillable by updating oom_score_adj. In order to avoid
falling into infinite loop, oom_score_adj needs to be checked before
doing oom_task_origin() test.

This patch merges oom_scan_process_thread() into oom_badness() in order
to check oom_score_adj before oom_task_origin() and in order to avoid
duplicated oom_unkillable_task(), by passing a flag for telling whether
to do TIF_MEMDIE test and oom_task_origin() test.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 fs/proc/base.c      |  2 +-
 include/linux/oom.h | 16 +++-------
 mm/memcontrol.c     | 22 +++-----------
 mm/oom_kill.c       | 88 ++++++++++++++++++++++++-----------------------------
 4 files changed, 50 insertions(+), 78 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index d7c51ca..3020aa2 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -581,7 +581,7 @@ static int proc_oom_score(struct seq_file *m, struct pid_namespace *ns,
 
 	read_lock(&tasklist_lock);
 	if (pid_alive(task))
-		points = oom_badness(task, NULL, NULL, totalpages) *
+		points = oom_badness(task, NULL, NULL, totalpages, false) *
 						1000 / totalpages;
 	read_unlock(&tasklist_lock);
 	seq_printf(m, "%lu\n", points);
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 45993b8..b31467e 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -43,13 +43,6 @@ enum oom_constraint {
 	CONSTRAINT_MEMCG,
 };
 
-enum oom_scan_t {
-	OOM_SCAN_OK,		/* scan thread and find its badness */
-	OOM_SCAN_CONTINUE,	/* do not consider thread for oom kill */
-	OOM_SCAN_ABORT,		/* abort the iteration and return */
-	OOM_SCAN_SELECT,	/* always select this thread first */
-};
-
 /* Thread is the potential origin of an oom condition; kill first on oom */
 #define OOM_FLAG_ORIGIN		((__force oom_flags_t)0x1)
 
@@ -73,8 +66,10 @@ static inline bool oom_task_origin(const struct task_struct *p)
 extern void mark_oom_victim(struct task_struct *tsk);
 
 extern unsigned long oom_badness(struct task_struct *p,
-		struct mem_cgroup *memcg, const nodemask_t *nodemask,
-		unsigned long totalpages);
+				 struct mem_cgroup *memcg,
+				 struct oom_control *oc,
+				 unsigned long totalpages,
+				 bool check_exceptions);
 
 extern int oom_kills_count(void);
 extern void note_oom_kill(void);
@@ -86,9 +81,6 @@ extern void check_panic_on_oom(struct oom_control *oc,
 			       enum oom_constraint constraint,
 			       struct mem_cgroup *memcg);
 
-extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
-		struct task_struct *task, unsigned long totalpages);
-
 extern bool out_of_memory(struct oom_control *oc);
 
 extern void exit_oom_victim(struct task_struct *tsk);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3c96dd3..4cc210c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1248,7 +1248,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	struct mem_cgroup *iter;
 	unsigned long chosen_points = 0;
 	unsigned long totalpages;
-	unsigned int points = 0;
+	unsigned long points = 0;
 	struct task_struct *chosen = NULL;
 
 	mutex_lock(&oom_lock);
@@ -1271,28 +1271,16 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 		css_task_iter_start(&iter->css, &it);
 		while ((task = css_task_iter_next(&it))) {
-			switch (oom_scan_process_thread(&oc, task, totalpages)) {
-			case OOM_SCAN_SELECT:
-				if (chosen)
-					put_task_struct(chosen);
-				chosen = task;
-				chosen_points = ULONG_MAX;
-				get_task_struct(chosen);
-				/* fall through */
-			case OOM_SCAN_CONTINUE:
+			points = oom_badness(task, NULL, &oc, totalpages, true);
+			if (!points || points < chosen_points)
 				continue;
-			case OOM_SCAN_ABORT:
+			if (points == ULONG_MAX) {
 				css_task_iter_end(&it);
 				mem_cgroup_iter_break(memcg, iter);
 				if (chosen)
 					put_task_struct(chosen);
 				goto unlock;
-			case OOM_SCAN_OK:
-				break;
-			};
-			points = oom_badness(task, NULL, NULL, totalpages);
-			if (!points || points < chosen_points)
-				continue;
+			}
 			/* Prefer thread group leaders for display purposes */
 			if (points == chosen_points &&
 			    thread_group_leader(chosen))
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 28d6a32..f426ce8 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -155,21 +155,40 @@ static bool oom_unkillable_task(struct task_struct *p,
 /**
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
+ * @memcg: memory cgroup. NULL unless memcg OOM case.
+ * @oc: oom_control struct. NULL if /proc/pid/oom_score_adj case.
  * @totalpages: total present RAM allowed for page allocation
+ * @check_exceptions: whether to check for TIF_MEMDIE and oom_task_origin().
+ *
+ * Returns ULONG_MAX if @p is marked as OOM-victim.
+ * Returns ULONG_MAX - 1 if @p is marked as oom_task_origin().
+ * Returns 0 if @p is marked as OOM-unkillable.
+ * Returns integer between 1 and ULONG_MAX - 2 otherwise.
  *
  * The heuristic for determining which task to kill is made to be as simple and
  * predictable as possible.  The goal is to return the highest value for the
  * task consuming the most memory to avoid subsequent oom failures.
  */
 unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
-			  const nodemask_t *nodemask, unsigned long totalpages)
+			  struct oom_control *oc, unsigned long totalpages,
+			  bool check_exceptions)
 {
 	long points;
 	long adj;
 
-	if (oom_unkillable_task(p, memcg, nodemask))
+	if (oom_unkillable_task(p, memcg, oc ? oc->nodemask : NULL))
 		return 0;
 
+	/*
+	 * This task already has access to memory reserves and is being killed.
+	 * Don't allow any other task to have access to the reserves.
+	 */
+	if (check_exceptions)
+		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
+			if (!is_sysrq_oom(oc))
+				return ULONG_MAX;
+		}
+
 	p = find_lock_task_mm(p);
 	if (!p)
 		return 0;
@@ -181,6 +200,16 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	}
 
 	/*
+	 * If task is allocating a lot of memory and has been marked to be
+	 * killed first if it triggers an oom, then select it.
+	 */
+	if (check_exceptions)
+		if (oom_task_origin(p)) {
+			task_unlock(p);
+			return ULONG_MAX - 1;
+		}
+
+	/*
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
@@ -268,33 +297,6 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 }
 #endif
 
-enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
-			struct task_struct *task, unsigned long totalpages)
-{
-	if (oom_unkillable_task(task, NULL, oc->nodemask))
-		return OOM_SCAN_CONTINUE;
-
-	/*
-	 * This task already has access to memory reserves and is being killed.
-	 * Don't allow any other task to have access to the reserves.
-	 */
-	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
-		if (!is_sysrq_oom(oc))
-			return OOM_SCAN_ABORT;
-	}
-	if (!task->mm)
-		return OOM_SCAN_CONTINUE;
-
-	/*
-	 * If task is allocating a lot of memory and has been marked to be
-	 * killed first if it triggers an oom, then select it.
-	 */
-	if (oom_task_origin(task))
-		return OOM_SCAN_SELECT;
-
-	return OOM_SCAN_OK;
-}
-
 /*
  * Simple selection loop. We chose the process with the highest
  * number of 'points'.  Returns -1 on scan abort.
@@ -308,24 +310,14 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 
 	rcu_read_lock();
 	for_each_process_thread(g, p) {
-		unsigned int points;
-
-		switch (oom_scan_process_thread(oc, p, totalpages)) {
-		case OOM_SCAN_SELECT:
-			chosen = p;
-			chosen_points = ULONG_MAX;
-			/* fall through */
-		case OOM_SCAN_CONTINUE:
+		const unsigned long points = oom_badness(p, NULL, oc,
+							 totalpages, true);
+		if (!points || points < chosen_points)
 			continue;
-		case OOM_SCAN_ABORT:
+		if (points == ULONG_MAX) {
 			rcu_read_unlock();
 			return (struct task_struct *)(-1UL);
-		case OOM_SCAN_OK:
-			break;
-		};
-		points = oom_badness(p, NULL, oc->nodemask, totalpages);
-		if (!points || points < chosen_points)
-			continue;
+		}
 		/* Prefer thread group leaders for display purposes */
 		if (points == chosen_points && thread_group_leader(chosen))
 			continue;
@@ -676,7 +668,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	struct task_struct *child;
 	struct task_struct *t;
 	struct mm_struct *mm;
-	unsigned int victim_points = 0;
+	unsigned long victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 	bool can_oom_reap = true;
@@ -709,15 +701,15 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	read_lock(&tasklist_lock);
 	for_each_thread(p, t) {
 		list_for_each_entry(child, &t->children, sibling) {
-			unsigned int child_points;
+			unsigned long child_points;
 
 			if (process_shares_mm(child, p->mm))
 				continue;
 			/*
 			 * oom_badness() returns 0 if the thread is unkillable
 			 */
-			child_points = oom_badness(child, memcg, oc->nodemask,
-								totalpages);
+			child_points = oom_badness(child, memcg, oc,
+						   totalpages, false);
 			if (child_points > victim_points) {
 				put_task_struct(victim);
 				victim = child;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
