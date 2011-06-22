Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A496690016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 06:48:30 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EC3873EE081
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:48:24 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D371A45DF83
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:48:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BDD4945DF4D
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:48:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AD5191DB8040
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:48:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E2A61DB8037
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:48:24 +0900 (JST)
Message-ID: <4E01C86D.30006@jp.fujitsu.com>
Date: Wed, 22 Jun 2011 19:48:13 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 4/6] oom: oom-killer don't use proportion of system-ram internally
References: <4E01C7D5.3060603@jp.fujitsu.com>
In-Reply-To: <4E01C7D5.3060603@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

CAI Qian reported his kernel did hang-up if he ran fork intensive
workload and then invoke oom-killer.

The problem is, current oom calculation uses 0-1000 normalized value
(The unit is a permillage of system-ram). Its low precision make
a lot of same oom score. IOW, in his case, all processes have smaller
oom score than 1 and internal calculation round it to 1.

Thus oom-killer kill ineligible process. This regression is caused by
commit a63d83f427 (oom: badness heuristic rewrite).

The solution is, the internal calculation just use number of pages
instead of permillage of system-ram. And convert it to permillage
value at displaying time.

This patch doesn't change any ABI (included  /proc/<pid>/oom_score_adj)
even though current logic has a lot of my dislike thing.

Reported-by: CAI Qian <caiqian@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/proc/base.c      |   13 ++++++----
 include/linux/oom.h |    2 +-
 mm/oom_kill.c       |   60 ++++++++++++++++++++++++++++++--------------------
 3 files changed, 45 insertions(+), 30 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 14def99..4a10763 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -479,14 +479,17 @@ static const struct file_operations proc_lstats_operations = {

 static int proc_oom_score(struct task_struct *task, char *buffer)
 {
-	unsigned long points = 0;
+	unsigned long points;
+	unsigned long ratio = 0;
+	unsigned long totalpages = totalram_pages + total_swap_pages + 1;

 	read_lock(&tasklist_lock);
-	if (pid_alive(task))
-		points = oom_badness(task, NULL, NULL,
-					totalram_pages + total_swap_pages);
+	if (pid_alive(task)) {
+		points = oom_badness(task, NULL, NULL, totalpages);
+		ratio = points * 1000 / totalpages;
+	}
 	read_unlock(&tasklist_lock);
-	return sprintf(buffer, "%lu\n", points);
+	return sprintf(buffer, "%lu\n", ratio);
 }

 struct limit_names {
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 4952fb8..75b104c 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -42,7 +42,7 @@ enum oom_constraint {

 extern int test_set_oom_score_adj(int new_val);

-extern unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
+extern unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 			const nodemask_t *nodemask, unsigned long totalpages);
 extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 797308b..cff8000 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -159,10 +159,11 @@ static bool oom_unkillable_task(struct task_struct *p,
  * predictable as possible.  The goal is to return the highest value for the
  * task consuming the most memory to avoid subsequent oom failures.
  */
-unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
+unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 		      const nodemask_t *nodemask, unsigned long totalpages)
 {
-	int points;
+	unsigned long points;
+	unsigned long score_adj = 0;

 	if (oom_unkillable_task(p, mem, nodemask))
 		return 0;
@@ -194,33 +195,44 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 	 */
 	points = get_mm_rss(p->mm) + p->mm->nr_ptes;
 	points += get_mm_counter(p->mm, MM_SWAPENTS);
-
-	points *= 1000;
-	points /= totalpages;
 	task_unlock(p);

-	/*
-	 * Root processes get 3% bonus, just like the __vm_enough_memory()
-	 * implementation used by LSMs.
-	 */
-	if (task_euid(p) == 0)
-		points -= 30;
+	/* Root processes get 3% bonus. */
+	if (task_euid(p) == 0) {
+		if (points >= totalpages / 32)
+			points -= totalpages / 32;
+		else
+			points = 0;
+	}

 	/*
 	 * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
 	 * either completely disable oom killing or always prefer a certain
 	 * task.
 	 */
-	points += p->signal->oom_score_adj;
+	if (p->signal->oom_score_adj >= 0) {
+		score_adj = p->signal->oom_score_adj * (totalpages / 1000);
+		if (ULONG_MAX - points >= score_adj)
+			points += score_adj;
+		else
+			points = ULONG_MAX;
+	} else {
+		score_adj = -p->signal->oom_score_adj * (totalpages / 1000);
+		if (points >= score_adj)
+			points -= score_adj;
+		else
+			points = 0;
+	}

 	/*
 	 * Never return 0 for an eligible task that may be killed since it's
 	 * possible that no single user task uses more than 0.1% of memory and
 	 * no single admin tasks uses more than 3.0%.
 	 */
-	if (points <= 0)
-		return 1;
-	return (points < 1000) ? points : 1000;
+	if (!points)
+		points = 1;
+
+	return points;
 }

 /*
@@ -292,7 +304,7 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
  *
  * (not docbooked, we don't want this one cluttering up the manual)
  */
-static struct task_struct *select_bad_process(unsigned int *ppoints,
+static struct task_struct *select_bad_process(unsigned long *ppoints,
 		unsigned long totalpages, struct mem_cgroup *mem,
 		const nodemask_t *nodemask)
 {
@@ -301,7 +313,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 	*ppoints = 0;

 	do_each_thread_reverse(g, p) {
-		unsigned int points;
+		unsigned long points;

 		if (!p->mm)
 			continue;
@@ -332,7 +344,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 			 */
 			if (p == current) {
 				chosen = p;
-				*ppoints = 1000;
+				*ppoints = ULONG_MAX;
 			} else {
 				/*
 				 * If this task is not being ptraced on exit,
@@ -463,14 +475,14 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 #undef K

 static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
-			    unsigned int points, unsigned long totalpages,
+			    unsigned long points, unsigned long totalpages,
 			    struct mem_cgroup *mem, nodemask_t *nodemask,
 			    const char *message)
 {
 	struct task_struct *victim = p;
 	struct task_struct *child;
 	struct task_struct *t = p;
-	unsigned int victim_points = 0;
+	unsigned long victim_points = 0;

 	if (printk_ratelimit())
 		dump_header(p, gfp_mask, order, mem, nodemask);
@@ -485,7 +497,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	}

 	task_lock(p);
-	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
+	pr_err("%s: Kill process %d (%s) points %lu or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 	task_unlock(p);

@@ -497,7 +509,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 */
 	do {
 		list_for_each_entry(child, &t->children, sibling) {
-			unsigned int child_points;
+			unsigned long child_points;

 			if (child->mm == p->mm)
 				continue;
@@ -544,7 +556,7 @@ static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 {
 	unsigned long limit;
-	unsigned int points = 0;
+	unsigned long points = 0;
 	struct task_struct *p;

 	/*
@@ -693,7 +705,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	struct task_struct *p;
 	unsigned long totalpages;
 	unsigned long freed = 0;
-	unsigned int points;
+	unsigned long points;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 	int killed = 0;

-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
