Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D989D6B01C1
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:23:51 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o536NphB018482
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 15:23:51 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8279E45DE4F
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:23:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5858545DE4E
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:23:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F35F1DB803C
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:23:51 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EEA8F1DB8037
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:23:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 07/12] oom: Fix child process iteration properly
In-Reply-To: <20100603135106.7247.A69D9226@jp.fujitsu.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com>
Message-Id: <20100603152304.725C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Jun 2010 15:23:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Oleg pointed out that current oom child process iterating logic is wrong.

  > list_for_each_entry(p->children) can only see the tasks forked
  > by p, it can't see other children forked by its sub-threads.

This patch fixes it.

Reported-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   35 +++++++++++++++++++++--------------
 1 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d4484c5..35a2ecc 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -88,6 +88,7 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 {
 	unsigned long points, cpu_time, run_time;
 	struct task_struct *c;
+	struct task_struct *t;
 	struct task_struct *child;
 	int oom_adj = p->signal->oom_adj;
 	struct task_cputime task_time;
@@ -125,14 +126,17 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 	 * child is eating the vast majority of memory, adding only half
 	 * to the parents will make the child our kill candidate of choice.
 	 */
-	list_for_each_entry(c, &p->children, sibling) {
-		child = find_lock_task_mm(c);
-		if (child) {
-			if (child->mm != p->mm)
-				points += child->mm->total_vm/2 + 1;
-			task_unlock(child);
+	t = p;
+	do {
+		list_for_each_entry(c, &t->children, sibling) {
+			child = find_lock_task_mm(c);
+			if (child) {
+				if (child->mm != p->mm)
+					points += child->mm->total_vm/2 + 1;
+				task_unlock(child);
+			}
 		}
-	}
+	} while_each_thread(p, t);
 
 	/*
 	 * CPU time is in tens of seconds and run time is in thousands
@@ -432,6 +436,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			    const char *message)
 {
 	struct task_struct *c;
+	struct task_struct *t = p;
 
 	if (printk_ratelimit())
 		dump_header(p, gfp_mask, order, mem);
@@ -449,14 +454,16 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 					message, task_pid_nr(p), p->comm, points);
 
 	/* Try to kill a child first */
-	list_for_each_entry(c, &p->children, sibling) {
-		if (c->mm == p->mm)
-			continue;
+	do {
+		list_for_each_entry(c, &t->children, sibling) {
+			if (c->mm == p->mm)
+				continue;
 
-		/* Ok, Kill the child */
-		if (!__oom_kill_process(c, mem, 1))
-			return 0;
-	}
+			/* Ok, Kill the child */
+			if (!__oom_kill_process(c, mem, 1))
+				return 0;
+		}
+	} while_each_thread(p, t);
 
 	return __oom_kill_process(p, mem, 1);
 }
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
