Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BE0906B01AC
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:45:17 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H1jErE023433
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Jun 2010 10:45:14 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B6A145DE4E
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:45:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C39F45DE4D
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:45:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 557DA1DB8037
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:45:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 147ADE08003
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:45:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/9] oom: don't try to kill oom_unkillable child
Message-Id: <20100617104311.FB7A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Jun 2010 10:45:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Now, badness() doesn't care neigher CPUSET nor mempolicy. Then
if the victim child process have disjoint nodemask, __out_of_memory()
can makes kernel hang eventually.

This patch fixes it.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 26ae697..0aeacb2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -429,7 +429,7 @@ static int oom_kill_task(struct task_struct *p)
 
 static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			    unsigned long points, struct mem_cgroup *mem,
-			    const char *message)
+			    nodemask_t *nodemask, const char *message)
 {
 	struct task_struct *victim = p;
 	struct task_struct *child;
@@ -469,6 +469,8 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 				continue;
 			if (mem && !task_in_mem_cgroup(child, mem))
 				continue;
+			if (!has_intersects_mems_allowed(child, nodemask))
+				continue;
 
 			/* badness() returns 0 if the thread is unkillable */
 			child_points = badness(child, uptime.tv_sec);
@@ -519,7 +521,7 @@ retry:
 	if (!p || PTR_ERR(p) == -1UL)
 		goto out;
 
-	if (oom_kill_process(p, gfp_mask, 0, points, mem,
+	if (oom_kill_process(p, gfp_mask, 0, points, mem, NULL,
 				"Memory cgroup out of memory"))
 		goto retry;
 out:
@@ -678,7 +680,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		 * non-zero, current could not be killed so we must fallback to
 		 * the tasklist scan.
 		 */
-		if (!oom_kill_process(current, gfp_mask, order, 0, NULL,
+		if (!oom_kill_process(current, gfp_mask, order, 0, NULL, nodemask,
 				"Out of memory (oom_kill_allocating_task)"))
 			return;
 	}
@@ -697,7 +699,7 @@ retry:
 		panic("Out of memory and no killable processes...\n");
 	}
 
-	if (oom_kill_process(p, gfp_mask, order, points, NULL,
+	if (oom_kill_process(p, gfp_mask, order, points, NULL, nodemask,
 			     "Out of memory"))
 		goto retry;
 	read_unlock(&tasklist_lock);
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
