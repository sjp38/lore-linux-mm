Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2D58E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 16:59:12 -0500 (EST)
Received: by mail-vk1-f198.google.com with SMTP id b189so4409362vke.21
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:59:12 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v71sor6896583vsa.93.2019.01.21.13.59.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 13:59:11 -0800 (PST)
Date: Mon, 21 Jan 2019 13:58:50 -0800
In-Reply-To: <20190121215850.221745-1-shakeelb@google.com>
Message-Id: <20190121215850.221745-2-shakeelb@google.com>
Mime-Version: 1.0
References: <20190121215850.221745-1-shakeelb@google.com>
Subject: [PATCH v3 2/2] mm, oom: remove 'prefer children over parent' heuristic
From: Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Roman Gushchin <guro@fb.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@suse.com>

>From the start of the git history of Linux, the kernel after selecting
the worst process to be oom-killed, prefer to kill its child (if the
child does not share mm with the parent). Later it was changed to prefer
to kill a child who is worst. If the parent is still the worst then the
parent will be killed.

This heuristic assumes that the children did less work than their parent
and by killing one of them, the work lost will be less. However this is
very workload dependent. If there is a workload which can benefit from
this heuristic, can use oom_score_adj to prefer children to be killed
before the parent.

The select_bad_process() has already selected the worst process in the
system/memcg. There is no need to recheck the badness of its children
and hoping to find a worse candidate. That's a lot of unneeded racy
work. Also the heuristic is dangerous because it make fork bomb like
workloads to recover much later because we constantly pick and kill
processes which are not memory hogs. So, let's remove this whole
heuristic.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

---
Changelog since v2:
- Propagate the message to __oom_kill_process().

Changelog since v1:
- Improved commit message based on mhocko's comment.
- Replaced 'p' with 'victim'.
- Removed extra pr_err message.

---
 mm/oom_kill.c | 78 ++++++++++++---------------------------------------
 1 file changed, 18 insertions(+), 60 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1a007dae1e8f..c90184fd48a3 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -843,7 +843,7 @@ static bool task_will_free_mem(struct task_struct *task)
 	return ret;
 }
 
-static void __oom_kill_process(struct task_struct *victim)
+static void __oom_kill_process(struct task_struct *victim, const char *message)
 {
 	struct task_struct *p;
 	struct mm_struct *mm;
@@ -874,8 +874,9 @@ static void __oom_kill_process(struct task_struct *victim)
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
 	mark_oom_victim(victim);
-	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
+	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+		message, task_pid_nr(victim), victim->comm,
+		K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
 		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
 		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
@@ -932,24 +933,19 @@ static void __oom_kill_process(struct task_struct *victim)
  * Kill provided task unless it's secured by setting
  * oom_score_adj to OOM_SCORE_ADJ_MIN.
  */
-static int oom_kill_memcg_member(struct task_struct *task, void *unused)
+static int oom_kill_memcg_member(struct task_struct *task, void *message)
 {
 	if (task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(task);
-		__oom_kill_process(task);
+		__oom_kill_process(task, message);
 	}
 	return 0;
 }
 
 static void oom_kill_process(struct oom_control *oc, const char *message)
 {
-	struct task_struct *p = oc->chosen;
-	unsigned int points = oc->chosen_points;
-	struct task_struct *victim = p;
-	struct task_struct *child;
-	struct task_struct *t;
+	struct task_struct *victim = oc->chosen;
 	struct mem_cgroup *oom_group;
-	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 
@@ -958,57 +954,18 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 * its children or threads, just give it access to memory reserves
 	 * so it can die quickly
 	 */
-	task_lock(p);
-	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		wake_oom_reaper(p);
-		task_unlock(p);
-		put_task_struct(p);
+	task_lock(victim);
+	if (task_will_free_mem(victim)) {
+		mark_oom_victim(victim);
+		wake_oom_reaper(victim);
+		task_unlock(victim);
+		put_task_struct(victim);
 		return;
 	}
-	task_unlock(p);
+	task_unlock(victim);
 
 	if (__ratelimit(&oom_rs))
-		dump_header(oc, p);
-
-	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
-		message, task_pid_nr(p), p->comm, points);
-
-	/*
-	 * If any of p's children has a different mm and is eligible for kill,
-	 * the one with the highest oom_badness() score is sacrificed for its
-	 * parent.  This attempts to lose the minimal amount of work done while
-	 * still freeing memory.
-	 */
-	read_lock(&tasklist_lock);
-
-	/*
-	 * The task 'p' might have already exited before reaching here. The
-	 * put_task_struct() will free task_struct 'p' while the loop still try
-	 * to access the field of 'p', so, get an extra reference.
-	 */
-	get_task_struct(p);
-	for_each_thread(p, t) {
-		list_for_each_entry(child, &t->children, sibling) {
-			unsigned int child_points;
-
-			if (process_shares_mm(child, p->mm))
-				continue;
-			/*
-			 * oom_badness() returns 0 if the thread is unkillable
-			 */
-			child_points = oom_badness(child,
-				oc->memcg, oc->nodemask, oc->totalpages);
-			if (child_points > victim_points) {
-				put_task_struct(victim);
-				victim = child;
-				victim_points = child_points;
-				get_task_struct(victim);
-			}
-		}
-	}
-	put_task_struct(p);
-	read_unlock(&tasklist_lock);
+		dump_header(oc, victim);
 
 	/*
 	 * Do we need to kill the entire memory cgroup?
@@ -1017,14 +974,15 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 */
 	oom_group = mem_cgroup_get_oom_group(victim, oc->memcg);
 
-	__oom_kill_process(victim);
+	__oom_kill_process(victim, message);
 
 	/*
 	 * If necessary, kill all tasks in the selected memory cgroup.
 	 */
 	if (oom_group) {
 		mem_cgroup_print_oom_group(oom_group);
-		mem_cgroup_scan_tasks(oom_group, oom_kill_memcg_member, NULL);
+		mem_cgroup_scan_tasks(oom_group, oom_kill_memcg_member,
+				      (void*) message);
 		mem_cgroup_put(oom_group);
 	}
 }
-- 
2.20.1.321.g9e740568ce-goog
