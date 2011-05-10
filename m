Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA536B0011
	for <linux-mm@kvack.org>; Tue, 10 May 2011 04:16:26 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4C3123EE0AE
	for <linux-mm@kvack.org>; Tue, 10 May 2011 17:16:23 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2ECBB45DF4E
	for <linux-mm@kvack.org>; Tue, 10 May 2011 17:16:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 139F845DF48
	for <linux-mm@kvack.org>; Tue, 10 May 2011 17:16:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F2974E08002
	for <linux-mm@kvack.org>; Tue, 10 May 2011 17:16:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ABA991DB8037
	for <linux-mm@kvack.org>; Tue, 10 May 2011 17:16:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/4] oom: don't kill random process
In-Reply-To: <20110510171335.16A7.A69D9226@jp.fujitsu.com>
References: <20110509182110.167F.A69D9226@jp.fujitsu.com> <20110510171335.16A7.A69D9226@jp.fujitsu.com>
Message-Id: <20110510171800.16B7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 10 May 2011 17:16:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

CAI Qian reported oom-killer killed all system daemons in his
system at first if he ran fork bomb as root. The problem is,
current logic give them bonus of 3% of system ram. Example,
he has 16GB machine, then root processes have ~500MB oom
immune. It bring us crazy bad result. _all_ processes have
oom-score=1 and then, oom killer ignore process memroy usage
and kill random process. This regression is caused by commit
a63d83f427 (oom: badness heuristic rewrite).

This patch changes select_bad_process() slightly. If oom points == 1,
it's a sign that the system have only root privileged processes or
similar. Thus, select_bad_process() calculate oom badness without
root bonus and select eligible process.

Reported-by: CAI Qian <caiqian@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/proc/base.c      |    2 +-
 include/linux/oom.h |    3 ++-
 mm/oom_kill.c       |   19 +++++++++++++++----
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index d6b0424..b608b69 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -482,7 +482,7 @@ static int proc_oom_score(struct task_struct *task, char *buffer)
 
 	read_lock(&tasklist_lock);
 	if (pid_alive(task)) {
-		points = oom_badness(task, NULL, NULL, totalpages);
+		points = oom_badness(task, NULL, NULL, totalpages, 1);
 		ratio = points * 1000 / totalpages;
 	}
 	read_unlock(&tasklist_lock);
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 0f5b588..3dd3669 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -42,7 +42,8 @@ enum oom_constraint {
 
 /* The badness from the OOM killer */
 extern unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
-			const nodemask_t *nodemask, unsigned long totalpages);
+			const nodemask_t *nodemask, unsigned long totalpages,
+			int protect_root);
 extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ba95870..525e1d2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -133,7 +133,8 @@ static bool oom_unkillable_task(struct task_struct *p,
  * task consuming the most memory to avoid subsequent oom failures.
  */
 unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
-		      const nodemask_t *nodemask, unsigned long totalpages)
+			 const nodemask_t *nodemask, unsigned long totalpages,
+			 int protect_root)
 {
 	unsigned long points;
 	unsigned long score_adj = 0;
@@ -186,7 +187,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 	 *
 	 * XXX: Too large bonus. Example,if the system have tera-bytes memory...
 	 */
-	if (has_capability_noaudit(p, CAP_SYS_ADMIN)) {
+	if (protect_root && has_capability_noaudit(p, CAP_SYS_ADMIN)) {
 		if (points >= totalpages / 32)
 			points -= totalpages / 32;
 		else
@@ -298,8 +299,10 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 {
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
+	int protect_root = 1;
 	*ppoints = 0;
 
+ retry:
 	do_each_thread_reverse(g, p) {
 		unsigned long points;
 
@@ -345,13 +348,18 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 			}
 		}
 
-		points = oom_badness(p, mem, nodemask, totalpages);
+		points = oom_badness(p, mem, nodemask, totalpages, protect_root);
 		if (points > *ppoints) {
 			chosen = p;
 			*ppoints = points;
 		}
 	} while_each_thread(g, p);
 
+	if (protect_root && (*ppoints == 1)) {
+		protect_root = 0;
+		goto retry;
+	}
+
 	return chosen;
 }
 
@@ -470,6 +478,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	struct task_struct *child;
 	struct task_struct *t = p;
 	unsigned long victim_points = 0;
+	int admin;
 
 	if (printk_ratelimit())
 		dump_header(p, gfp_mask, order, mem, nodemask);
@@ -494,6 +503,8 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * parent.  This attempts to lose the minimal amount of work done while
 	 * still freeing memory.
 	 */
+	admin = has_capability_noaudit(victim, CAP_SYS_ADMIN);
+	victim_points = oom_badness(victim, mem, nodemask, totalpages, !admin);
 	do {
 		list_for_each_entry(child, &t->children, sibling) {
 			unsigned long child_points;
@@ -504,7 +515,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			 * oom_badness() returns 0 if the thread is unkillable
 			 */
 			child_points = oom_badness(child, mem, nodemask,
-								totalpages);
+						   totalpages, !admin);
 			if (child_points > victim_points) {
 				victim = child;
 				victim_points = child_points;
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
