Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 150746B004A
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 19:34:40 -0400 (EDT)
Received: by iajr24 with SMTP id r24so434150iaj.14
        for <linux-mm@kvack.org>; Tue, 03 Apr 2012 16:34:39 -0700 (PDT)
Date: Tue, 3 Apr 2012 16:34:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, oom: avoid checking set of allowed nodes twice when
 selecting a victim
Message-ID: <alpine.DEB.2.00.1204031633460.8112@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

For systems with high CONFIG_NODES_SHIFT, checking nodes_intersect() for
each thread's set of allowed nodes is very expensive.  It's unnecessary
to do this twice for each thread, once in select_bad_process() and once
in oom_badness().  We've already filtered unkillable threads at the point
where oom_badness() is called.

oom_badness() must still check if a thread is a kthread, however, to
ensure /proc/pid/oom_score doesn't report one as killable.

This significantly speeds up the tasklist iteration when there are a
large number of threads on the system and CONFIG_NODES_SHIFT is high.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -151,13 +151,16 @@ struct task_struct *find_lock_task_mm(struct task_struct *p)
 	return NULL;
 }
 
+static bool is_unkillable_kthread(struct task_struct *p)
+{
+	return is_global_init(p) || (p->flags & PF_KTHREAD);
+}
+
 /* return true if the task is not adequate as candidate victim task. */
 static bool oom_unkillable_task(struct task_struct *p,
 		const struct mem_cgroup *memcg, const nodemask_t *nodemask)
 {
-	if (is_global_init(p))
-		return true;
-	if (p->flags & PF_KTHREAD)
+	if (is_unkillable_kthread(p))
 		return true;
 
 	/* When mem_cgroup_out_of_memory() and p is not member of the group */
@@ -185,7 +188,7 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 {
 	long points;
 
-	if (oom_unkillable_task(p, memcg, nodemask))
+	if (is_unkillable_kthread(p))
 		return 0;
 
 	p = find_lock_task_mm(p);
@@ -478,9 +481,8 @@ static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 			if (child->mm == p->mm)
 				continue;
-			/*
-			 * oom_badness() returns 0 if the thread is unkillable
-			 */
+			if (oom_unkillable_task(child, memcg, nodemask))
+				continue;
 			child_points = oom_badness(child, memcg, nodemask,
 								totalpages);
 			if (child_points > victim_points) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
