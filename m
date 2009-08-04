Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3E3836B005C
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 05:59:54 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n74AQfgU031167
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 4 Aug 2009 19:26:42 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BCC7545DE51
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 19:26:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EAF445DE50
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 19:26:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 81BA91DB8038
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 19:26:41 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B19B1DB803C
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 19:26:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/4] oom: make oom_score to per-process value
In-Reply-To: <20090804191031.6A3D.A69D9226@jp.fujitsu.com>
References: <20090804191031.6A3D.A69D9226@jp.fujitsu.com>
Message-Id: <20090804192557.6A43.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  4 Aug 2009 19:26:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] oom: make oom_score to per-process value

oom-killer kill a process, not task. Then oom_score should be
calculated as per-process too. it makes consistency more and
makes speed up select_bad_process().


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>,
Cc: Andrew Morton <akpm@linux-foundation.org>,
---
 Documentation/filesystems/proc.txt |    4 ++--
 fs/proc/base.c                     |    2 +-
 mm/oom_kill.c                      |   36 +++++++++++++++++++++++++++++-------
 3 files changed, 32 insertions(+), 10 deletions(-)

Index: b/mm/oom_kill.c
===================================================================
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -58,6 +58,19 @@ void set_oom_adj(struct task_struct *tsk
 }
 
 
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
 
 /**
  * badness - calculate a numeric value for how bad this task has been
@@ -77,18 +90,26 @@ void set_oom_adj(struct task_struct *tsk
  *    algorithm has been meticulously tuned to meet the principle
  *    of least surprise ... (be careful when you change it)
  */
-
 unsigned long badness(struct task_struct *p, unsigned long uptime)
 {
 	unsigned long points, cpu_time, run_time;
 	struct mm_struct *mm;
 	struct task_struct *child;
 	int oom_adj;
+	struct task_cputime task_time;
+	unsigned long flags;
+	unsigned long utime;
+	unsigned long stime;
 
 	oom_adj = get_oom_adj(p);
 	if (oom_adj == OOM_DISABLE)
 		return 0;
 
+	if (!lock_task_sighand(p, &flags))
+		return 0;
+	thread_group_cputime(p, &task_time);
+	unlock_task_sighand(p, &flags);
+
 	task_lock(p);
 	mm = p->mm;
 	if (!mm) {
@@ -132,8 +153,9 @@ unsigned long badness(struct task_struct
          * of seconds. There is no particular reason for this other than
          * that it turned out to work very well in practice.
 	 */
-	cpu_time = (cputime_to_jiffies(p->utime) + cputime_to_jiffies(p->stime))
-		>> (SHIFT_HZ + 3);
+	utime = cputime_to_jiffies(task_time.utime);
+	stime = cputime_to_jiffies(task_time.stime);
+	cpu_time = (utime + stime) >> (SHIFT_HZ + 3);
 
 	if (uptime >= p->start_time.tv_sec)
 		run_time = (uptime - p->start_time.tv_sec) >> 10;
@@ -174,7 +196,7 @@ unsigned long badness(struct task_struct
 	 * because p may have allocated or otherwise mapped memory on
 	 * this node before. However it will be less likely.
 	 */
-	if (!cpuset_mems_allowed_intersects(current, p))
+	if (!has_intersects_mems_allowed(p))
 		points /= 8;
 
 	/*
@@ -230,13 +252,13 @@ static inline enum oom_constraint constr
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
@@ -286,7 +308,7 @@ static struct task_struct *select_bad_pr
 			chosen = p;
 			*ppoints = points;
 		}
-	} while_each_thread(g, p);
+	}
 
 	return chosen;
 }
Index: b/fs/proc/base.c
===================================================================
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -450,7 +450,7 @@ static int proc_oom_score(struct task_st
 
 	do_posix_clock_monotonic_gettime(&uptime);
 	read_lock(&tasklist_lock);
-	points = badness(task, uptime.tv_sec);
+	points = badness(task->group_leader, uptime.tv_sec);
 	read_unlock(&tasklist_lock);
 	return sprintf(buffer, "%lu\n", points);
 }
Index: b/Documentation/filesystems/proc.txt
===================================================================
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -1195,13 +1195,13 @@ The following heuristics are then applie
  * if the task was reniced, its score doubles
  * superuser or direct hardware access tasks (CAP_SYS_ADMIN, CAP_SYS_RESOURCE
  	or CAP_SYS_RAWIO) have their score divided by 4
- * if oom condition happened in one cpuset and checked task does not belong
+ * if oom condition happened in one cpuset and checked process does not belong
  	to it, its score is divided by 8
  * the resulting score is multiplied by two to the power of oom_adj, i.e.
 	points <<= oom_adj when it is positive and
 	points >>= -(oom_adj) otherwise
 
-The task with the highest badness score is then selected and its children
+The process with the highest badness score is then selected and its children
 are killed, process itself will be killed in an OOM situation when it does
 not have children or some of them disabled oom like described above.
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
