Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00A296B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 11:48:12 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b16so68688lfb.21
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 08:48:12 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l9si7903892lje.145.2017.10.04.08.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 08:48:11 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v10 1/6] mm, oom: refactor the oom_kill_process() function
Date: Wed, 4 Oct 2017 16:46:33 +0100
Message-ID: <20171004154638.710-2-guro@fb.com>
In-Reply-To: <20171004154638.710-1-guro@fb.com>
References: <20171004154638.710-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

The oom_kill_process() function consists of two logical parts:
the first one is responsible for considering task's children as
a potential victim and printing the debug information.
The second half is responsible for sending SIGKILL to all
tasks sharing the mm struct with the given victim.

This commit splits the oom_kill_process() function with
an intention to re-use the the second half: __oom_kill_process().

The cgroup-aware OOM killer will kill multiple tasks
belonging to the victim cgroup. We don't need to print
the debug information for the each task, as well as play
with task selection (considering task's children),
so we can't use the existing oom_kill_process().

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Michal Hocko <mhocko@kernel.org>
Acked-by: David Rientjes <rientjes@google.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 mm/oom_kill.c | 123 +++++++++++++++++++++++++++++++---------------------------
 1 file changed, 65 insertions(+), 58 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index e284810b9851..1e7b8a27e6cc 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -822,68 +822,12 @@ static bool task_will_free_mem(struct task_struct *task)
 	return ret;
 }
 
-static void oom_kill_process(struct oom_control *oc, const char *message)
+static void __oom_kill_process(struct task_struct *victim)
 {
-	struct task_struct *p = oc->chosen;
-	unsigned int points = oc->chosen_points;
-	struct task_struct *victim = p;
-	struct task_struct *child;
-	struct task_struct *t;
+	struct task_struct *p;
 	struct mm_struct *mm;
-	unsigned int victim_points = 0;
-	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
-					      DEFAULT_RATELIMIT_BURST);
 	bool can_oom_reap = true;
 
-	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just give it access to memory reserves
-	 * so it can die quickly
-	 */
-	task_lock(p);
-	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		wake_oom_reaper(p);
-		task_unlock(p);
-		put_task_struct(p);
-		return;
-	}
-	task_unlock(p);
-
-	if (__ratelimit(&oom_rs))
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
-	read_unlock(&tasklist_lock);
-
 	p = find_lock_task_mm(victim);
 	if (!p) {
 		put_task_struct(victim);
@@ -957,6 +901,69 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 }
 #undef K
 
+static void oom_kill_process(struct oom_control *oc, const char *message)
+{
+	struct task_struct *p = oc->chosen;
+	unsigned int points = oc->chosen_points;
+	struct task_struct *victim = p;
+	struct task_struct *child;
+	struct task_struct *t;
+	unsigned int victim_points = 0;
+	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
+					      DEFAULT_RATELIMIT_BURST);
+
+	/*
+	 * If the task is already exiting, don't alarm the sysadmin or kill
+	 * its children or threads, just give it access to memory reserves
+	 * so it can die quickly
+	 */
+	task_lock(p);
+	if (task_will_free_mem(p)) {
+		mark_oom_victim(p);
+		wake_oom_reaper(p);
+		task_unlock(p);
+		put_task_struct(p);
+		return;
+	}
+	task_unlock(p);
+
+	if (__ratelimit(&oom_rs))
+		dump_header(oc, p);
+
+	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
+		message, task_pid_nr(p), p->comm, points);
+
+	/*
+	 * If any of p's children has a different mm and is eligible for kill,
+	 * the one with the highest oom_badness() score is sacrificed for its
+	 * parent.  This attempts to lose the minimal amount of work done while
+	 * still freeing memory.
+	 */
+	read_lock(&tasklist_lock);
+	for_each_thread(p, t) {
+		list_for_each_entry(child, &t->children, sibling) {
+			unsigned int child_points;
+
+			if (process_shares_mm(child, p->mm))
+				continue;
+			/*
+			 * oom_badness() returns 0 if the thread is unkillable
+			 */
+			child_points = oom_badness(child,
+				oc->memcg, oc->nodemask, oc->totalpages);
+			if (child_points > victim_points) {
+				put_task_struct(victim);
+				victim = child;
+				victim_points = child_points;
+				get_task_struct(victim);
+			}
+		}
+	}
+	read_unlock(&tasklist_lock);
+
+	__oom_kill_process(victim);
+}
+
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
