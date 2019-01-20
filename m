Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 132BC8E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 16:51:09 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 12so11792574plb.18
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 13:51:09 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id r134sor17250465pgr.30.2019.01.20.13.51.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 13:51:07 -0800 (PST)
Date: Sun, 20 Jan 2019 13:50:59 -0800
Message-Id: <20190120215059.183552-1-shakeelb@google.com>
Mime-Version: 1.0
Subject: [PATCH] mm, oom: remove 'prefer children over parent' heuristic
From: Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Roman Gushchin <guro@fb.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

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
work. So, let's remove this whole heuristic.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/oom_kill.c | 49 ++++---------------------------------------------
 1 file changed, 4 insertions(+), 45 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1a007dae1e8f..6cee185dc147 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -944,12 +944,7 @@ static int oom_kill_memcg_member(struct task_struct *task, void *unused)
 static void oom_kill_process(struct oom_control *oc, const char *message)
 {
 	struct task_struct *p = oc->chosen;
-	unsigned int points = oc->chosen_points;
-	struct task_struct *victim = p;
-	struct task_struct *child;
-	struct task_struct *t;
 	struct mem_cgroup *oom_group;
-	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 
@@ -971,53 +966,17 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p);
 
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
+	pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
+		message, task_pid_nr(p), p->comm, oc->chosen_points);
 
 	/*
 	 * Do we need to kill the entire memory cgroup?
 	 * Or even one of the ancestor memory cgroups?
 	 * Check this out before killing the victim task.
 	 */
-	oom_group = mem_cgroup_get_oom_group(victim, oc->memcg);
+	oom_group = mem_cgroup_get_oom_group(p, oc->memcg);
 
-	__oom_kill_process(victim);
+	__oom_kill_process(p);
 
 	/*
 	 * If necessary, kill all tasks in the selected memory cgroup.
-- 
2.20.1.321.g9e740568ce-goog
