Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 0EA206B0092
	for <linux-mm@kvack.org>; Wed, 23 May 2012 03:15:07 -0400 (EDT)
Received: by dakp5 with SMTP id p5so13350632dak.14
        for <linux-mm@kvack.org>; Wed, 23 May 2012 00:15:06 -0700 (PDT)
Date: Wed, 23 May 2012 00:15:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, oom: normalize oom scores to oom_score_adj scale only
 for userspace
In-Reply-To: <20120517145022.a99f41e8.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1205230014450.9290@chino.kir.corp.google.com>
References: <20120426193551.GA24968@redhat.com> <alpine.DEB.2.00.1204261437470.28376@chino.kir.corp.google.com> <alpine.DEB.2.00.1205031513400.1631@chino.kir.corp.google.com> <20120503222949.GA13762@redhat.com> <alpine.DEB.2.00.1205171432250.6951@chino.kir.corp.google.com>
 <20120517145022.a99f41e8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The oom_score_adj scale ranges from -1000 to 1000 and represents the
proportion of memory available to the process at allocation time.  This
means an oom_score_adj value of 300, for example, will bias a process as
though it was using an extra 30.0% of available memory and a value of
-350 will discount 35.0% of available memory from its usage.

The oom killer badness heuristic also uses this scale to report the oom
score for each eligible process in determining the "best" process to
kill.  Thus, it can only differentiate each process's memory usage by
0.1% of system RAM.

On large systems, this can end up being a large amount of memory: 256MB
on 256GB systems, for example.

This can be fixed by having the badness heuristic to use the actual
memory usage in scoring threads and then normalizing it to the
oom_score_adj scale for userspace.  This results in better comparison
between eligible threads for kill and no change from the userspace
perspective.

Suggested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Tested-by: Dave Jones <davej@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/proc/base.c      |    5 +++--
 include/linux/oom.h |    5 +++--
 mm/oom_kill.c       |   44 ++++++++++++++++----------------------------
 3 files changed, 22 insertions(+), 32 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -410,12 +410,13 @@ static const struct file_operations proc_lstats_operations = {
 
 static int proc_oom_score(struct task_struct *task, char *buffer)
 {
+	unsigned long totalpages = totalram_pages + total_swap_pages;
 	unsigned long points = 0;
 
 	read_lock(&tasklist_lock);
 	if (pid_alive(task))
-		points = oom_badness(task, NULL, NULL,
-					totalram_pages + total_swap_pages);
+		points = oom_badness(task, NULL, NULL, totalpages) *
+						1000 / totalpages;
 	read_unlock(&tasklist_lock);
 	return sprintf(buffer, "%lu\n", points);
 }
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -43,8 +43,9 @@ enum oom_constraint {
 extern void compare_swap_oom_score_adj(int old_val, int new_val);
 extern int test_set_oom_score_adj(int new_val);
 
-extern unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
-			const nodemask_t *nodemask, unsigned long totalpages);
+extern unsigned long oom_badness(struct task_struct *p,
+		struct mem_cgroup *memcg, const nodemask_t *nodemask,
+		unsigned long totalpages);
 extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -180,10 +180,10 @@ static bool oom_unkillable_task(struct task_struct *p,
  * predictable as possible.  The goal is to return the highest value for the
  * task consuming the most memory to avoid subsequent oom failures.
  */
-unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
-		      const nodemask_t *nodemask, unsigned long totalpages)
+unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
+			  const nodemask_t *nodemask, unsigned long totalpages)
 {
-	long points;
+	unsigned long points;
 
 	if (oom_unkillable_task(p, memcg, nodemask))
 		return 0;
@@ -198,21 +198,11 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	}
 
 	/*
-	 * The memory controller may have a limit of 0 bytes, so avoid a divide
-	 * by zero, if necessary.
-	 */
-	if (!totalpages)
-		totalpages = 1;
-
-	/*
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + p->mm->nr_ptes;
-	points += get_mm_counter(p->mm, MM_SWAPENTS);
-
-	points *= 1000;
-	points /= totalpages;
+	points = get_mm_rss(p->mm) + p->mm->nr_ptes +
+		 get_mm_counter(p->mm, MM_SWAPENTS);
 	task_unlock(p);
 
 	/*
@@ -220,23 +210,20 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * implementation used by LSMs.
 	 */
 	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
-		points -= 30;
+		points -= 30 * totalpages / 1000;
 
 	/*
 	 * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
 	 * either completely disable oom killing or always prefer a certain
 	 * task.
 	 */
-	points += p->signal->oom_score_adj;
+	points += p->signal->oom_score_adj * totalpages / 1000;
 
 	/*
-	 * Never return 0 for an eligible task that may be killed since it's
-	 * possible that no single user task uses more than 0.1% of memory and
-	 * no single admin tasks uses more than 3.0%.
+	 * Never return 0 for an eligible task regardless of the root bonus and
+	 * oom_score_adj (oom_score_adj can't be OOM_SCORE_ADJ_MIN here).
 	 */
-	if (points <= 0)
-		return 1;
-	return (points < 1000) ? points : 1000;
+	return points ? points : 1;
 }
 
 /*
@@ -314,7 +301,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 {
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
-	*ppoints = 0;
+	unsigned long chosen_points = 0;
 
 	do_each_thread(g, p) {
 		unsigned int points;
@@ -354,7 +341,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 			 */
 			if (p == current) {
 				chosen = p;
-				*ppoints = 1000;
+				chosen_points = ULONG_MAX;
 			} else if (!force_kill) {
 				/*
 				 * If this task is not being ptraced on exit,
@@ -367,12 +354,13 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		}
 
 		points = oom_badness(p, memcg, nodemask, totalpages);
-		if (points > *ppoints) {
+		if (points > chosen_points) {
 			chosen = p;
-			*ppoints = points;
+			chosen_points = points;
 		}
 	} while_each_thread(g, p);
 
+	*ppoints = chosen_points * 1000 / totalpages;
 	return chosen;
 }
 
@@ -572,7 +560,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	}
 
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
-	limit = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT;
+	limit = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
 	read_lock(&tasklist_lock);
 	p = select_bad_process(&points, limit, memcg, NULL, false);
 	if (p && PTR_ERR(p) != -1UL)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
