Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC7D8D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 01:31:23 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8B4933EE0BD
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:31:20 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 74A9545DE56
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:31:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 53B3B45DE5B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:31:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3977EE08002
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:31:20 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 488E51DB8050
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:31:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/4] remove boost_dying_task_prio()
In-Reply-To: <20110411142949.006C.A69D9226@jp.fujitsu.com>
References: <20110411142949.006C.A69D9226@jp.fujitsu.com>
Message-Id: <20110411143215.0074.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 11 Apr 2011 14:31:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrey Vagin <avagin@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

This is a almost revert commit 93b43fa (oom: give the dying
task a higher priority).

The commit dramatically improve oom killer logic when fork-bomb
occur. But, I've found it has nasty corner case. Now cpu cgroup
has strange default RT runtime. It's 0! That said, if a process
under cpu cgroup promote RT scheduling class, the process never
run at all.

Eventually, kernel may hang up when oom kill occur.
I and Luis who original author agreed to disable this logic at
once.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Luis Claudio R. Goncalves <lclaudio@uudg.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/oom_kill.c |   28 ----------------------------
 1 files changed, 0 insertions(+), 28 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6a819d1..83fb72c1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -84,24 +84,6 @@ static bool has_intersects_mems_allowed(struct task_struct *tsk,
 #endif /* CONFIG_NUMA */
 
 /*
- * If this is a system OOM (not a memcg OOM) and the task selected to be
- * killed is not already running at high (RT) priorities, speed up the
- * recovery by boosting the dying task to the lowest FIFO priority.
- * That helps with the recovery and avoids interfering with RT tasks.
- */
-static void boost_dying_task_prio(struct task_struct *p,
-				  struct mem_cgroup *mem)
-{
-	struct sched_param param = { .sched_priority = 1 };
-
-	if (mem)
-		return;
-
-	if (!rt_task(p))
-		sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
-}
-
-/*
  * The process p may have detached its own ->mm while exiting or through
  * use_mm(), but one or more of its subthreads may still have a valid
  * pointer.  Return p, or any of its subthreads with a valid ->mm, with
@@ -452,13 +434,6 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 	set_tsk_thread_flag(p, TIF_MEMDIE);
 	force_sig(SIGKILL, p);
 
-	/*
-	 * We give our sacrificial lamb high priority and access to
-	 * all the memory it needs. That way it should be able to
-	 * exit() and clear out its resources quickly...
-	 */
-	boost_dying_task_prio(p, mem);
-
 	return 0;
 }
 #undef K
@@ -482,7 +457,6 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 */
 	if (p->flags & PF_EXITING) {
 		set_tsk_thread_flag(p, TIF_MEMDIE);
-		boost_dying_task_prio(p, mem);
 		return 0;
 	}
 
@@ -556,7 +530,6 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 	 */
 	if (fatal_signal_pending(current)) {
 		set_thread_flag(TIF_MEMDIE);
-		boost_dying_task_prio(current, NULL);
 		return;
 	}
 
@@ -712,7 +685,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 */
 	if (fatal_signal_pending(current)) {
 		set_thread_flag(TIF_MEMDIE);
-		boost_dying_task_prio(current, NULL);
 		return;
 	}
 
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
