Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0A6386B01CB
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 05:30:23 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U9UL4d016936
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Jun 2010 18:30:22 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 78BE345DE51
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:30:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 46BDA45DE4D
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:30:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 21818E18004
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:30:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FA2B1DB803E
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:30:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 05/11] oom: /proc/<pid>/oom_score treat kernel thread honestly
In-Reply-To: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
Message-Id: <20100630182922.AA56.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Jun 2010 18:30:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

If kernel thread are using use_mm(), badness() return positive value.
This is not big issue because caller care it correctly. but there is
one exception, /proc/<pid>/oom_score call badness() directly and
don't care the task is regular process.

another example, /proc/1/oom_score return !0 value. but it's unkillable.
This incorrectness makes confusing to admin a bit.

This patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/proc/base.c |    5 +++--
 mm/oom_kill.c  |   13 +++++++------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 28099a1..56b8d3e 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -428,7 +428,8 @@ static const struct file_operations proc_lstats_operations = {
 #endif
 
 /* The badness from the OOM killer */
-unsigned long badness(struct task_struct *p, unsigned long uptime);
+unsigned long badness(struct task_struct *p, struct mem_cgroup *mem,
+		      nodemask_t *nodemask, unsigned long uptime);
 static int proc_oom_score(struct task_struct *task, char *buffer)
 {
 	unsigned long points = 0;
@@ -437,7 +438,7 @@ static int proc_oom_score(struct task_struct *task, char *buffer)
 	do_posix_clock_monotonic_gettime(&uptime);
 	read_lock(&tasklist_lock);
 	if (pid_alive(task))
-		points = badness(task, uptime.tv_sec);
+		points = badness(task, NULL, NULL, uptime.tv_sec);
 	read_unlock(&tasklist_lock);
 	return sprintf(buffer, "%lu\n", points);
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ee00817..fcbd21b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -139,8 +139,8 @@ static bool oom_unkillable_task(struct task_struct *p, struct mem_cgroup *mem,
  *    algorithm has been meticulously tuned to meet the principle
  *    of least surprise ... (be careful when you change it)
  */
-
-unsigned long badness(struct task_struct *p, unsigned long uptime)
+unsigned long badness(struct task_struct *p, struct mem_cgroup *mem,
+		      const nodemask_t *nodemask, unsigned long uptime)
 {
 	unsigned long points, cpu_time, run_time;
 	struct task_struct *child;
@@ -150,6 +150,8 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 	unsigned long utime;
 	unsigned long stime;
 
+	if (oom_unkillable_task(p, mem, nodemask))
+		return 0;
 	if (oom_adj == OOM_DISABLE)
 		return 0;
 
@@ -351,7 +353,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 		if (p->signal->oom_adj == OOM_DISABLE)
 			continue;
 
-		points = badness(p, uptime.tv_sec);
+		points = badness(p, mem, nodemask, uptime.tv_sec);
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
@@ -482,11 +484,10 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 			if (child->mm == p->mm)
 				continue;
-			if (oom_unkillable_task(p, mem, nodemask))
-				continue;
 
 			/* badness() returns 0 if the thread is unkillable */
-			child_points = badness(child, uptime.tv_sec);
+			child_points = badness(child, mem, nodemask,
+					       uptime.tv_sec);
 			if (child_points > victim_points) {
 				victim = child;
 				victim_points = child_points;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
