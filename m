Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 89F80828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 05:30:34 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id jq7so59603380obb.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 02:30:34 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k72si8462216oib.76.2016.02.18.02.30.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Feb 2016 02:30:33 -0800 (PST)
Subject: Re: [PATCH v2] mm,oom: exclude oom_task_origin processes if they are OOM-unkillable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1602171430500.15429@chino.kir.corp.google.com>
	<20160218080909.GA18149@dhcp22.suse.cz>
In-Reply-To: <20160218080909.GA18149@dhcp22.suse.cz>
Message-Id: <201602181930.HIH09321.SFVFOQLHOFMJOt@I-love.SAKURA.ne.jp>
Date: Thu, 18 Feb 2016 19:30:12 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: akpm@linux-foundation.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 17-02-16 14:31:54, David Rientjes wrote:
> > On Wed, 17 Feb 2016, Tetsuo Handa wrote:
> > 
> > > oom_scan_process_thread() returns OOM_SCAN_SELECT when there is a
> > > thread which returns oom_task_origin() == true. But it is possible
> > > that such thread is marked as OOM-unkillable. In that case, the OOM
> > > killer must not select such process.
> > > 
> > > Since it is meaningless to return OOM_SCAN_OK for OOM-unkillable
> > > process because subsequent oom_badness() call will return 0, this
> > > patch changes oom_scan_process_thread to return OOM_SCAN_CONTINUE
> > > if that process is marked as OOM-unkillable (regardless of
> > > oom_task_origin()).
> > > 
> > > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Suggested-by: Michal Hocko <mhocko@kernel.org>
> > > ---
> > >  mm/oom_kill.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 7653055..cf87153 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -282,7 +282,7 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> > >  		if (!is_sysrq_oom(oc))
> > >  			return OOM_SCAN_ABORT;
> > >  	}
> > > -	if (!task->mm)
> > > +	if (!task->mm || task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > >  		return OOM_SCAN_CONTINUE;
> > >  
> > >  	/*
> > 
> > I'm getting multiple emails from you with the identical patch, something 
> > is definitely wacky in your toolchain.

Sorry, my operation error. I didn't know I can't do like below.

  git send-email --to="rcpt1 rcpt2" --cc="rcpt3 rcpt4 rcpt5" file.patch

Thus, I resent the identical patch. Not a toolchain problem.

> > 
> > Anyway, this is NACK'd since task->signal->oom_score_adj is checked under 
> > task_lock() for threads with memory attached, that's the purpose of 
> > finding the correct thread in oom_badness() and taking task_lock().  We 
> > aren't going to duplicate logic in several functions that all do the same 
> > thing.
> 
> Is the task_lock really necessary, though? E.g. oom_task_origin()
> doesn't seem to depend on it for task->signal safety. If you are
> referring to races with changing oom_score_adj does such a race matter
> at all?
> 
> To me this looks like a reasonable cleanup because we _know_ that
> OOM_SCORE_ADJ_MIN means OOM_SCAN_CONTINUE and do not really have to go
> down to oom_badness to find that out. Or what am I missing?
> 

That NACK will not matter if a draft patch shown bottom is acceptable.

I got a question about commit 9cbb78bb314360a8 "mm, memcg: introduce own
oom handler to iterate only over its own threads" while trying to kill
duplicated oom_unkillable_task() checks by merging oom_scan_process_thread()
into oom_badness().

Currently, oom_scan_process_thread() is doing

  if (oom_unkillable_task(p, NULL, oc->nodemask))
  	return OOM_SCAN_CONTINUE;

and oom_badness() is doing

  if (oom_unkillable_task(p, memcg, nodemask))
  	return 0;

.

For normal OOM case, out_of_memory() is calling

  oom_scan_process_thread(oc, p, totalpages)
  oom_badness(p, NULL, oc->nodemask, totalpages)

which is translated to

  if (oom_unkillable_task(p, NULL, oc->nodemask))
      return OOM_SCAN_CONTINUE;
  if (oom_unkillable_task(p, NULL, oc->nodemask))
      return 0;

.

But for memcg OOM case, mem_cgroup_out_of_memory() is calling

  oom_scan_process_thread(oc, p, totalpages)
  oom_badness(p, memcg, NULL, totalpages)

which is translated to

  if (oom_unkillable_task(p, NULL, NULL))
      return OOM_SCAN_CONTINUE;
  if (oom_unkillable_task(p, memcg, NULL))
      return 0;

.

Commit 9cbb78bb314360a8 changed oom_scan_process_thread() to
always pass memcg == NULL by removing memcg argument from
oom_scan_process_thread(). As a result, after that commit,
we are doing test_tsk_thread_flag(p, TIF_MEMDIE) check and
oom_task_origin(p) check between two oom_unkillable_task()
calls of memcg OOM case. Why don't we skip these checks by
passing memcg != NULL to first oom_unkillable_task() call?
Was this change by error?

----------
>From 36f79bc270858e93be75de2adae1afe757d91b94 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 18 Feb 2016 19:21:26 +0900
Subject: [PATCH] mm,oom: kill duplicated oom_unkillable_task() checks.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 fs/proc/base.c      |  2 +-
 include/linux/oom.h | 16 +++-------
 mm/memcontrol.c     | 23 ++++----------
 mm/oom_kill.c       | 91 +++++++++++++++++++++++------------------------------
 4 files changed, 51 insertions(+), 81 deletions(-)

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
index ae8b81c..0d422bf 100644
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
@@ -1271,28 +1271,17 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
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
+			points = oom_badness(task, memcg, &oc, totalpages,
+					     true);
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
-			points = oom_badness(task, memcg, NULL, totalpages);
-			if (!points || points < chosen_points)
-				continue;
+			}
 			/* Prefer thread group leaders for display purposes */
 			if (points == chosen_points &&
 			    thread_group_leader(chosen))
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d7bb9c1..f426ce8 100644
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
@@ -268,36 +297,6 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
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
-	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
-		return OOM_SCAN_ABORT;
-
-	return OOM_SCAN_OK;
-}
-
 /*
  * Simple selection loop. We chose the process with the highest
  * number of 'points'.  Returns -1 on scan abort.
@@ -311,24 +310,14 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 
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
@@ -679,7 +668,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	struct task_struct *child;
 	struct task_struct *t;
 	struct mm_struct *mm;
-	unsigned int victim_points = 0;
+	unsigned long victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 	bool can_oom_reap = true;
@@ -712,15 +701,15 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
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
