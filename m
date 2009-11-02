Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2BCED6B0078
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 02:33:02 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA27Wvpc002855
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Nov 2009 16:32:58 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C042545DE6F
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:32:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CE4245DE70
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:32:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BC131DB803E
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:32:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EB0F41DB803F
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:32:56 +0900 (JST)
Date: Mon, 2 Nov 2009 16:30:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][-mm][PATCH 6/6] oom-killer: rewrite badness
Message-Id: <20091102163023.4f5c7282.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, aarcange@redhat.com, akpm@linux-foundation.org, minchan.kim@gmail.com, rientjes@google.com, vedran.furac@gmail.com, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

rewrite __badness() heuristics.
Now, we have much more useful information for badness. use it.
And this patch changes too strong bonuses of cputime and runtime.

 - use "constraint" for changing base value.
   CPUSET: RSS tend to be unbalnaced between nodes. And we don't have
           per node RSS value....use total_vm instead of it.
   LOWMEM: we need to kill a process witch has low_rss.
   MEMCG, NONE: use RSS+SWAP as base value.

 - Runtime bonus.
   Runtime bonus is 0.1% per sec for each base value up to 50%
   For NONE/MEMCG, using total_vm-shared_vm here for taking requested amounts
   of memory into account. This may be bigger than base value.

 - cputime bonus
   removed.

 - Last Expansion bonus
   If last call for mmap() which expands hiwat_total_vm was far in past,
   get bonus. 0.1% per sec up to 25%.

 - nice bonus was removed. (we have oom_adj, ROOT is checked.)

 - import codes from KOSAKI's patch which coalesce capability checks.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/oom_kill.c |  124 +++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 84 insertions(+), 40 deletions(-)

Index: mmotm-2.6.32-Nov2/mm/oom_kill.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/oom_kill.c
+++ mmotm-2.6.32-Nov2/mm/oom_kill.c
@@ -77,12 +77,10 @@ static unsigned long __badness(struct ta
 		      unsigned long uptime, enum oom_constraint constraint,
 		      struct mem_cgroup *mem)
 {
-	unsigned long points, cpu_time, run_time;
+	unsigned long points;
+	long runtime, quiet_time, penalty;
 	struct mm_struct *mm;
 	int oom_adj = p->signal->oom_adj;
-	struct task_cputime task_time;
-	unsigned long utime;
-	unsigned long stime;
 
 	if (oom_adj == OOM_DISABLE)
 		return 0;
@@ -93,11 +91,28 @@ static unsigned long __badness(struct ta
 		task_unlock(p);
 		return 0;
 	}
-
-	/*
-	 * The memory size of the process is the basis for the badness.
-	 */
-	points = get_mm_rss(mm);
+	switch (constraint) {
+	case CONSTRAINT_CPUSET:
+		/*
+		 * Because size of RSS/SWAP is highly affected by cpuset's
+		 * configuration and not by result of memory reclaim.
+		 * Then we use VM size here instead of RSS.
+		 * (we don't have per-node-rss counting, now)
+		 */
+		points = mm->total_vm;
+		break;
+	case CONSTRAINT_LOWMEM:
+		points = get_mm_counter(mm, low_rss);
+		break;
+	case CONSTRAINT_MEMCG:
+	case CONSTRAINT_NONE:
+		points = get_mm_counter(mm, anon_rss);
+		points += get_mm_counter(mm, swap_usage);
+		break;
+	default: /* mempolicy will not come here */
+		BUG();
+		break;
+	}
 
 	/*
 	 * After this unlock we can no longer dereference local variable `mm'
@@ -109,53 +124,82 @@ static unsigned long __badness(struct ta
 	 */
 	if (p->flags & PF_OOM_ORIGIN)
 		return ULONG_MAX;
-
 	/*
-	 * CPU time is in tens of seconds and run time is in thousands
-         * of seconds. There is no particular reason for this other than
-         * that it turned out to work very well in practice.
-	 */
-	thread_group_cputime(p, &task_time);
-	utime = cputime_to_jiffies(task_time.utime);
-	stime = cputime_to_jiffies(task_time.stime);
-	cpu_time = (utime + stime) >> (SHIFT_HZ + 3);
-
+ 	 * Check process's behavior and vm activity. And give bonus and
+ 	 * penalty.
+ 	 */
+	runtime = uptime - p->start_time.tv_sec;
+	penalty = 0;
+	/*
+	 * At oom, younger processes tend to be bad one. And there is no
+	 * good reason to kill a process which works very well befor OOM.
+	 * This adds short-run-time penalty at most 50% of its vm size.
+	 * and long-run process will get bonus up to 50% of its vm size.
+	 * If a process runs 1sec, it gets 0.1% bonus.
+	 *
+	 * We just check run_time here.
+	 */
+	runtime = 5000 - runtime;
+	if (runtime < -5000)
+		runtime = -5000;
+	switch (constraint) {
+	case CONSTRAINT_LOWMEM:
+		/* If LOWMEM OOM, seeing total_vm is wrong */
+		penalty = points * penalty / 10000;
+		break;
+	case CONSTRAINT_CPUSET:
+		penalty = mm->total_vm * penalty / 10000;
+		break;
+	default:
+		/* use total_vm - shared size as base of bonus */
+		penalty = (mm->total_vm - mm->shared_vm)* penalty / 10000;
+		break;
+	}
 
-	if (uptime >= p->start_time.tv_sec)
-		run_time = (uptime - p->start_time.tv_sec) >> 10;
+	if (likely(jiffies > mm->last_vm_expansion))
+		quiet_time = jiffies - mm->last_vm_expansion;
 	else
-		run_time = 0;
-
-	if (cpu_time)
-		points /= int_sqrt(cpu_time);
-	if (run_time)
-		points /= int_sqrt(int_sqrt(run_time));
+		quiet_time = ULONG_MAX - mm->last_vm_expansion + jiffies;
 
+	quiet_time = jiffies_to_msecs(quiet_time)/1000;
 	/*
-	 * Niced processes are most likely less important, so double
-	 * their badness points.
+	 * If a process recently expanded its (highest) vm size, get penalty.
+	 * This is for catching slow memory leaker. 12.5% is half of runtime
+	 * penalty.
 	 */
-	if (task_nice(p) > 0)
-		points *= 2;
+	quiet_time = 2500 - quiet_time;
+	if (quiet_time < -2500)
+		quiet_time = -1250;
+
+	switch (constraint) {
+	case CONSTRAINT_LOWMEM:
+		/* If LOWMEM OOM, seeing total_vm is wrong */
+		penalty += points * quiet_time / 10000;
+		break;
+	case CONSTRAINT_CPUSET:
+		penalty += mm->total_vm * quiet_time / 10000;
+		break;
+	default:
+		penalty += (mm->total_vm - mm->shared_vm) * quiet_time / 10000;
+		break;
+	}
+	/*
+ 	 * If an old process was quiet, it gets 75% of bonus at maximum.
+ 	 */
+	if ((penalty < 0) && (-penalty > points))
+		return 0;
+	points += penalty;
 
 	/*
 	 * Superuser processes are usually more important, so we make it
 	 * less likely that we kill those.
 	 */
 	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
+	    has_capability_noaudit(p, CAP_SYS_RAWIO) ||
 	    has_capability_noaudit(p, CAP_SYS_RESOURCE))
 		points /= 4;
 
 	/*
-	 * We don't want to kill a process with direct hardware access.
-	 * Not only could that mess up the hardware, but usually users
-	 * tend to only have this flag set on applications they think
-	 * of as important.
-	 */
-	if (has_capability_noaudit(p, CAP_SYS_RAWIO))
-		points /= 4;
-
-	/*
 	 * If p's nodes don't overlap ours, it may still help to kill p
 	 * because p may have allocated or otherwise mapped memory on
 	 * this node before. However it will be less likely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
