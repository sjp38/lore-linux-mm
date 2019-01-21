Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 665088E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:51:19 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id b24so13659199pls.11
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:51:19 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 32sor19075937plb.49.2019.01.21.10.51.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 10:51:18 -0800 (PST)
Date: Mon, 21 Jan 2019 10:50:32 -0800
In-Reply-To: <20190121185033.161015-1-shakeelb@google.com>
Message-Id: <20190121185033.161015-2-shakeelb@google.com>
Mime-Version: 1.0
References: <20190121185033.161015-1-shakeelb@google.com>
Subject: [PATCH v2 2/2] mm, oom: remove 'prefer children over parent' heuristic
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
Changelog since v1:
- Improved commit message based on mhocko's comment.
- Replaced 'p' with 'victim'.
- Removed extra pr_err message.

 mm/oom_kill.c | 62 ++++++++-------------------------------------------
 1 file changed, 9 insertions(+), 53 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1a007dae1e8f..4da73e656c29 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -943,13 +943,8 @@ static int oom_kill_memcg_member(struct task_struct *task, void *unused)
 
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
 
@@ -958,57 +953,18 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
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
-- 
2.20.1.321.g9e740568ce-goog
