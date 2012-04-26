Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 1A8916B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 17:40:51 -0400 (EDT)
Received: by iajr24 with SMTP id r24so134692iaj.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 14:40:50 -0700 (PDT)
Date: Thu, 26 Apr 2012 14:40:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: 3.4-rc4 oom killer out of control.
In-Reply-To: <20120426193551.GA24968@redhat.com>
Message-ID: <alpine.DEB.2.00.1204261437470.28376@chino.kir.corp.google.com>
References: <20120426193551.GA24968@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, 26 Apr 2012, Dave Jones wrote:

> On a test machine that was running my system call fuzzer, I just saw
> the oom killer take out everything but the process that was doing all
> the memory exhausting.
> 

Would it be possible to try the below patch?  It should kill the thread 
using the most memory (which happens to only be a couple more megabytes on 
your system), but it might just delay the inevitable since the system is 
still in a pretty bad state.

KOSAKI-san suggested doing this before and I think it's the best direction 
to go in anyway.
---
 fs/proc/base.c      |    5 +++--
 include/linux/oom.h |    5 +++--
 mm/oom_kill.c       |   39 ++++++++++++++-------------------------
 3 files changed, 20 insertions(+), 29 deletions(-)

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
index 3d76475..e4c29bc 100644
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
index 46bf2ed5..4bbf085 100644
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
@@ -198,45 +198,33 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
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
 	 * Root processes get 3% bonus, just like the __vm_enough_memory()
 	 * implementation used by LSMs.
 	 */
-	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
-		points -= 30;
+	if (has_capability_noaudit(p, CAP_SYS_ADMIN) && totalpages)
+		points -= 30 * totalpages / 1000;
 
 	/*
 	 * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
 	 * either completely disable oom killing or always prefer a certain
 	 * task.
 	 */
-	points += p->signal->oom_score_adj;
+	points += p->signal->oom_score_adj * totalpages / 1000;
 
 	/*
 	 * Never return 0 for an eligible task that may be killed since it's
 	 * possible that no single user task uses more than 0.1% of memory and
 	 * no single admin tasks uses more than 3.0%.
 	 */
-	if (points <= 0)
-		return 1;
-	return (points < 1000) ? points : 1000;
+	return points <= 0 ? 1 : points;
 }
 
 /*
@@ -314,7 +302,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 {
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
-	*ppoints = 0;
+	unsigned long chosen_points = 0;
 
 	do_each_thread(g, p) {
 		unsigned int points;
@@ -354,7 +342,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 			 */
 			if (p == current) {
 				chosen = p;
-				*ppoints = 1000;
+				chosen_points = ULONG_MAX;
 			} else if (!force_kill) {
 				/*
 				 * If this task is not being ptraced on exit,
@@ -367,12 +355,13 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
