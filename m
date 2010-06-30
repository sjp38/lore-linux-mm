Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 28B0E6B01C4
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 05:28:41 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U9Sc6P023008
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Jun 2010 18:28:38 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 69EA245DE50
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:28:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 46FF545DE4F
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:28:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 347051DB803F
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:28:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E4E8F1DB8048
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:28:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 03/11] oom: make oom_unkillable_task() helper function
In-Reply-To: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
Message-Id: <20100630182752.AA4E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Jun 2010 18:28:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now, we have the same task check in two places. Unify it.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   33 ++++++++++++++++++++++-----------
 1 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dc8589e..a4a5439 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -101,6 +101,26 @@ static struct task_struct *find_lock_task_mm(struct task_struct *p)
 	return NULL;
 }
 
+/* return true if the task is not adequate as candidate victim task. */
+static bool oom_unkillable_task(struct task_struct *p, struct mem_cgroup *mem,
+			   const nodemask_t *nodemask)
+{
+	if (is_global_init(p))
+		return true;
+	if (p->flags & PF_KTHREAD)
+		return true;
+
+	/* When mem_cgroup_out_of_memory() and p is not member of the group */
+	if (mem && !task_in_mem_cgroup(p, mem))
+		return true;
+
+	/* p may not have freeable memory in nodemask */
+	if (!has_intersects_mems_allowed(p, nodemask))
+		return true;
+
+	return false;
+}
+
 /**
  * badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
@@ -295,12 +315,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 	for_each_process(p) {
 		unsigned long points;
 
-		/* skip the init task and kthreads */
-		if (is_global_init(p) || (p->flags & PF_KTHREAD))
-			continue;
-		if (mem && !task_in_mem_cgroup(p, mem))
-			continue;
-		if (!has_intersects_mems_allowed(p, nodemask))
+		if (oom_unkillable_task(p, mem, nodemask))
 			continue;
 
 		/*
@@ -467,11 +482,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 			if (child->mm == p->mm)
 				continue;
-			if (child->flags & PF_KTHREAD)
-				continue;
-			if (mem && !task_in_mem_cgroup(child, mem))
-				continue;
-			if (!has_intersects_mems_allowed(child, nodemask))
+			if (oom_unkillable_task(p, mem, nodemask))
 				continue;
 
 			/* badness() returns 0 if the thread is unkillable */
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
