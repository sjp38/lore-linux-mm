Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9CE6B01F2
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 15:44:45 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o31Jihsk013763
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 12:44:43 -0700
Received: from pzk28 (pzk28.prod.google.com [10.243.19.156])
	by wpaz17.hot.corp.google.com with ESMTP id o31Jifcj000872
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 12:44:42 -0700
Received: by pzk28 with SMTP id 28so1401990pzk.11
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 12:44:41 -0700 (PDT)
Date: Thu, 1 Apr 2010 12:44:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 5/5] oom: cleanup oom_badness
In-Reply-To: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1004011244040.13247@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

oom_badness() no longer uses its uptime formal, so it can be removed.

Reported-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/proc/base.c      |    5 +----
 include/linux/oom.h |    2 +-
 mm/oom_kill.c       |   12 +++---------
 3 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -431,17 +431,14 @@ static const struct file_operations proc_lstats_operations = {
 static int proc_oom_score(struct task_struct *task, char *buffer)
 {
 	unsigned long points;
-	struct timespec uptime;
 
-	do_posix_clock_monotonic_gettime(&uptime);
 	read_lock(&tasklist_lock);
 	points = oom_badness(task->group_leader,
 				global_page_state(NR_INACTIVE_ANON) +
 				global_page_state(NR_ACTIVE_ANON) +
 				global_page_state(NR_INACTIVE_FILE) +
 				global_page_state(NR_ACTIVE_FILE) +
-				total_swap_pages,
-				uptime.tv_sec);
+				total_swap_pages);
 	read_unlock(&tasklist_lock);
 	return sprintf(buffer, "%lu\n", points);
 }
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -41,7 +41,7 @@ enum oom_constraint {
 };
 
 extern unsigned int oom_badness(struct task_struct *p,
-			unsigned long totalpages, unsigned long uptime);
+			unsigned long totalpages);
 extern int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -133,14 +133,12 @@ static unsigned long oom_forkbomb_penalty(struct task_struct *tsk)
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
  * @totalpages: total present RAM allowed for page allocation
- * @uptime: current uptime in seconds
  *
  * The heuristic for determining which task to kill is made to be as simple and
  * predictable as possible.  The goal is to return the highest value for the
  * task consuming the most memory to avoid subsequent oom conditions.
  */
-unsigned int oom_badness(struct task_struct *p, unsigned long totalpages,
-							unsigned long uptime)
+unsigned int oom_badness(struct task_struct *p, unsigned long totalpages)
 {
 	struct mm_struct *mm;
 	int points;
@@ -283,10 +281,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 {
 	struct task_struct *p;
 	struct task_struct *chosen = NULL;
-	struct timespec uptime;
 	*ppoints = 0;
 
-	do_posix_clock_monotonic_gettime(&uptime);
 	for_each_process(p) {
 		unsigned int points;
 
@@ -339,7 +335,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 			continue;
 
-		points = oom_badness(p, totalpages, uptime.tv_sec);
+		points = oom_badness(p, totalpages);
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
@@ -443,7 +439,6 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	struct task_struct *victim = p;
 	struct task_struct *c;
 	unsigned int victim_points = 0;
-	struct timespec uptime;
 
 	if (printk_ratelimit())
 		dump_header(p, gfp_mask, order, mem);
@@ -460,7 +455,6 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	pr_err("%s: Kill process %d (%s) with score %d or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 
-	do_posix_clock_monotonic_gettime(&uptime);
 	/* Try to sacrifice the worst child first */
 	list_for_each_entry(c, &p->children, sibling) {
 		unsigned int cpoints;
@@ -471,7 +465,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			continue;
 
 		/* oom_badness() returns 0 if the thread is unkillable */
-		cpoints = oom_badness(c, totalpages, uptime.tv_sec);
+		cpoints = oom_badness(c, totalpages);
 		if (cpoints > victim_points) {
 			victim = c;
 			victim_points = cpoints;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
