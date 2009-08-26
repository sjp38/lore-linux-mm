Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2C7CC6B0087
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 05:35:30 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7Q9ZTMe030033
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 26 Aug 2009 18:35:29 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9144745DE7E
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 18:35:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E30645DE7A
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 18:35:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0818C1DB8040
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 18:35:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 87678E08003
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 18:35:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH 2/4] oom: make oom_score to per-process value
In-Reply-To: <20090826182634.3968.A69D9226@jp.fujitsu.com>
References: <20090826182634.3968.A69D9226@jp.fujitsu.com>
Message-Id: <20090826183432.396E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 26 Aug 2009 18:35:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

oom-killer kill a process, not task. Then oom_score should be
calculated as per-process too. it makes consistency more and
makes speed up select_bad_process().

Cc: Paul Menage <menage@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 Documentation/filesystems/proc.txt |    2 +-
 fs/proc/base.c                     |    2 +-
 mm/oom_kill.c                      |   35 +++++++++++++++++++++++++++++------
 3 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index c97c430..2f17eee 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -1207,7 +1207,7 @@ The following heuristics are then applied:
  * if the task was reniced, its score doubles
  * superuser or direct hardware access tasks (CAP_SYS_ADMIN, CAP_SYS_RESOURCE
  	or CAP_SYS_RAWIO) have their score divided by 4
- * if oom condition happened in one cpuset and checked task does not belong
+ * if oom condition happened in one cpuset and checked process does not belong
  	to it, its score is divided by 8
  * the resulting score is multiplied by two to the power of oom_adj, i.e.
 	points <<= oom_adj when it is positive and
diff --git a/fs/proc/base.c b/fs/proc/base.c
index fbf8788..0c1757c 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -448,7 +448,7 @@ static int proc_oom_score(struct task_struct *task, char *buffer)
 
 	do_posix_clock_monotonic_gettime(&uptime);
 	read_lock(&tasklist_lock);
-	points = badness(task, uptime.tv_sec);
+	points = badness(task->group_leader, uptime.tv_sec);
 	read_unlock(&tasklist_lock);
 	return sprintf(buffer, "%lu\n", points);
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 55dcadd..26725bc 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -34,6 +34,23 @@ int sysctl_oom_dump_tasks;
 static DEFINE_SPINLOCK(zone_scan_lock);
 /* #define DEBUG */
 
+/*
+ * Is all threads of the target process nodes overlap ours?
+ */
+static int has_intersects_mems_allowed(struct task_struct *tsk)
+{
+	struct task_struct *t;
+
+	t = tsk;
+	do {
+		if (cpuset_mems_allowed_intersects(current, t))
+			return 1;
+		t = next_thread(t);
+	} while (t != tsk);
+
+	return 0;
+}
+
 /**
  * badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
@@ -59,6 +76,9 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 	struct mm_struct *mm;
 	struct task_struct *child;
 	int oom_adj = p->signal->oom_adj;
+	struct task_cputime task_time;
+	unsigned long utime;
+	unsigned long stime;
 
 	if (oom_adj == OOM_DISABLE)
 		return 0;
@@ -106,8 +126,11 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
          * of seconds. There is no particular reason for this other than
          * that it turned out to work very well in practice.
 	 */
-	cpu_time = (cputime_to_jiffies(p->utime) + cputime_to_jiffies(p->stime))
-		>> (SHIFT_HZ + 3);
+	thread_group_cputime(p, &task_time);
+	utime = cputime_to_jiffies(task_time.utime);
+	stime = cputime_to_jiffies(task_time.stime);
+	cpu_time = (utime + stime) >> (SHIFT_HZ + 3);
+
 
 	if (uptime >= p->start_time.tv_sec)
 		run_time = (uptime - p->start_time.tv_sec) >> 10;
@@ -148,7 +171,7 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 	 * because p may have allocated or otherwise mapped memory on
 	 * this node before. However it will be less likely.
 	 */
-	if (!cpuset_mems_allowed_intersects(current, p))
+	if (!has_intersects_mems_allowed(p))
 		points /= 8;
 
 	/*
@@ -204,13 +227,13 @@ static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
 static struct task_struct *select_bad_process(unsigned long *ppoints,
 						struct mem_cgroup *mem)
 {
-	struct task_struct *g, *p;
+	struct task_struct *p;
 	struct task_struct *chosen = NULL;
 	struct timespec uptime;
 	*ppoints = 0;
 
 	do_posix_clock_monotonic_gettime(&uptime);
-	do_each_thread(g, p) {
+	for_each_process(p) {
 		unsigned long points;
 
 		/*
@@ -263,7 +286,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 			chosen = p;
 			*ppoints = points;
 		}
-	} while_each_thread(g, p);
+	}
 
 	return chosen;
 }
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
