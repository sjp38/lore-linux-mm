Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id D33C16B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 10:01:46 -0400 (EDT)
Date: Thu, 12 Apr 2012 16:01:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, oom: avoid checking set of allowed nodes twice when
 selecting a victim
Message-ID: <20120412140137.GA32729@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1204031633460.8112@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1204031633460.8112@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Tue 03-04-12 16:34:36, David Rientjes wrote:
> For systems with high CONFIG_NODES_SHIFT, checking nodes_intersect() for
> each thread's set of allowed nodes is very expensive.  It's unnecessary
> to do this twice for each thread, once in select_bad_process() and once
> in oom_badness().  We've already filtered unkillable threads at the point
> where oom_badness() is called.
> 
> oom_badness() must still check if a thread is a kthread, however, to
> ensure /proc/pid/oom_score doesn't report one as killable.
> 
> This significantly speeds up the tasklist iteration when there are a
> large number of threads on the system and CONFIG_NODES_SHIFT is high.

Looks correct but I am not sure I like the subtle dependency between
oom_unkillable_task and oom_badness which is a result of this change.
We do not need it for proc oom_score because we are feeding it with NULL
cgroup and nodemask but we really care in other cases.

I do agree that the test duplication is not nice and it can be expensive
but this subtleness is not nice either.
Wouldn't it make more sense to extract __oom_badness without the checks
and make it explicit that the function can be called only for killable
tasks (namely only select_bad_process would use it)?

Something like (untested):
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 46bf2ed5..a9df008 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -171,23 +171,10 @@ static bool oom_unkillable_task(struct task_struct *p,
 	return false;
 }
 
-/**
- * oom_badness - heuristic function to determine which candidate task to kill
- * @p: task struct of which task we should calculate
- * @totalpages: total present RAM allowed for page allocation
- *
- * The heuristic for determining which task to kill is made to be as simple and
- * predictable as possible.  The goal is to return the highest value for the
- * task consuming the most memory to avoid subsequent oom failures.
- */
-unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
+/* can be used only for tasks which are killable as per oom_unkillable_task */
+static unsigned int __oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 		      const nodemask_t *nodemask, unsigned long totalpages)
 {
-	long points;
-
-	if (oom_unkillable_task(p, memcg, nodemask))
-		return 0;
-
 	p = find_lock_task_mm(p);
 	if (!p)
 		return 0;
@@ -239,6 +226,26 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	return (points < 1000) ? points : 1000;
 }
 
+/**
+ * oom_badness - heuristic function to determine which candidate task to kill
+ * @p: task struct of which task we should calculate
+ * @totalpages: total present RAM allowed for page allocation
+ *
+ * The heuristic for determining which task to kill is made to be as simple and
+ * predictable as possible.  The goal is to return the highest value for the
+ * task consuming the most memory to avoid subsequent oom failures.
+ */
+unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
+		      const nodemask_t *nodemask, unsigned long totalpages)
+{
+	long points;
+
+	if (oom_unkillable_task(p, memcg, nodemask))
+		return 0;
+
+	return __oom_badness(p, memcg, nodemask, totalpages);
+}
+
 /*
  * Determine the type of allocation constraint.
  */
@@ -366,7 +373,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 			}
 		}
 
-		points = oom_badness(p, memcg, nodemask, totalpages);
+		points = __oom_badness(p, memcg, nodemask, totalpages);
 		if (points > *ppoints) {
 			chosen = p;
 			*ppoints = points;

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
