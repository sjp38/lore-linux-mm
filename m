Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1B93D8D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 07:06:53 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 431E83EE0C2
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:06:50 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 28A3D45DE55
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:06:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 060F345DE4E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:06:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAD2A1DB8038
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:06:49 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A717D1DB803C
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:06:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/5] Revert "oom: give the dying task a higher priority"
In-Reply-To: <20110322194721.B05E.A69D9226@jp.fujitsu.com>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com> <20110322194721.B05E.A69D9226@jp.fujitsu.com>
Message-Id: <20110322200657.B064.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 22 Mar 2011 20:06:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>

This reverts commit 93b43fa55088fe977503a156d1097cc2055449a2.

The commit dramatically improve oom killer logic when fork-bomb
occur. But, I've found it has nasty corner case. Now cpu cgroup
has strange default RT runtime. It's 0! That said, if a process
under cpu cgroup promote RT scheduling class, the process never
run at all.

Eventually, kernel may hang up when oom kill occur.

The author need to resubmit it as adding knob and disabled
by default if he really need this feature.

Cc: Luis Claudio R. Goncalves <lclaudio@uudg.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   27 ---------------------------
 1 files changed, 0 insertions(+), 27 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3100bc5..739dee4 100644
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
 
@@ -701,7 +675,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 */
 	if (fatal_signal_pending(current)) {
 		set_thread_flag(TIF_MEMDIE);
-		boost_dying_task_prio(current, NULL);
 		return;
 	}
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
