Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 746056B007D
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 12:18:37 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id un15so705624pbc.5
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 09:18:37 -0800 (PST)
Received: from psmtp.com ([74.125.245.201])
        by mx.google.com with SMTP id it5si24264120pbc.245.2013.11.13.09.18.35
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 09:18:36 -0800 (PST)
Received: by mail-qc0-f202.google.com with SMTP id m20so57945qcx.1
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 09:18:34 -0800 (PST)
From: Sameer Nanda <snanda@chromium.org>
Subject: [PATCH v6] mm, oom: Fix race when selecting process to kill
Date: Wed, 13 Nov 2013 09:18:13 -0800
Message-Id: <1384363093-8025-1-git-send-email-snanda@chromium.org>
In-Reply-To: <CANMivWaXE=bn4fhvGdz3cPwN+CZpWwrWqmU1BKX8o+vE2JawOw@mail.gmail.com>
References: <CANMivWaXE=bn4fhvGdz3cPwN+CZpWwrWqmU1BKX8o+vE2JawOw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, rusty@rustcorp.com.au, semenzato@google.com, murzin.v@gmail.com, oleg@redhat.com, dserrg@gmail.com, msb@chromium.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sameer Nanda <snanda@chromium.org>

The selection of the process to be killed happens in two spots:
first in select_bad_process and then a further refinement by
looking for child processes in oom_kill_process. Since this is
a two step process, it is possible that the process selected by
select_bad_process may get a SIGKILL just before oom_kill_process
executes. If this were to happen, __unhash_process deletes this
process from the thread_group list. This results in oom_kill_process
getting stuck in an infinite loop when traversing the thread_group
list of the selected process.

Fix this race by adding a pid_alive check for the selected process
with tasklist_lock held in oom_kill_process.

Signed-off-by: Sameer Nanda <snanda@chromium.org>
---
 include/linux/sched.h |  5 +++++
 mm/oom_kill.c         | 34 +++++++++++++++++++++-------------
 2 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index e27baee..8975dbb 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2156,6 +2156,11 @@ extern bool current_is_single_threaded(void);
 #define do_each_thread(g, t) \
 	for (g = t = &init_task ; (g = t = next_task(g)) != &init_task ; ) do
 
+/*
+ * Careful: while_each_thread is not RCU safe. Callers should hold
+ * read_lock(tasklist_lock) across while_each_thread loops.
+ */
+
 #define while_each_thread(g, t) \
 	while ((t = next_thread(t)) != g)
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6738c47..0d1f804 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -412,31 +412,33 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 
+	if (__ratelimit(&oom_rs))
+		dump_header(p, gfp_mask, order, memcg, nodemask);
+
+	task_lock(p);
+	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
+		message, task_pid_nr(p), p->comm, points);
+	task_unlock(p);
+
+	read_lock(&tasklist_lock);
+
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
-	if (p->flags & PF_EXITING) {
+	if (p->flags & PF_EXITING || !pid_alive(p)) {
 		set_tsk_thread_flag(p, TIF_MEMDIE);
 		put_task_struct(p);
+		read_unlock(&tasklist_lock);
 		return;
 	}
 
-	if (__ratelimit(&oom_rs))
-		dump_header(p, gfp_mask, order, memcg, nodemask);
-
-	task_lock(p);
-	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
-		message, task_pid_nr(p), p->comm, points);
-	task_unlock(p);
-
 	/*
 	 * If any of p's children has a different mm and is eligible for kill,
 	 * the one with the highest oom_badness() score is sacrificed for its
 	 * parent.  This attempts to lose the minimal amount of work done while
 	 * still freeing memory.
 	 */
-	read_lock(&tasklist_lock);
 	do {
 		list_for_each_entry(child, &t->children, sibling) {
 			unsigned int child_points;
@@ -456,12 +458,17 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			}
 		}
 	} while_each_thread(p, t);
-	read_unlock(&tasklist_lock);
 
-	rcu_read_lock();
 	p = find_lock_task_mm(victim);
+
+	/*
+	 * Since while_each_thread is currently not RCU safe, this unlock of
+	 * tasklist_lock may need to be moved further down if any additional
+	 * while_each_thread loops get added to this function.
+	 */
+	read_unlock(&tasklist_lock);
+
 	if (!p) {
-		rcu_read_unlock();
 		put_task_struct(victim);
 		return;
 	} else if (victim != p) {
@@ -487,6 +494,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * That thread will now get access to memory reserves since it has a
 	 * pending fatal signal.
 	 */
+	rcu_read_lock();
 	for_each_process(p)
 		if (p->mm == mm && !same_thread_group(p, victim) &&
 		    !(p->flags & PF_KTHREAD)) {
-- 
1.8.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
