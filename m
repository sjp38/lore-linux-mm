Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 013C76B01AD
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 20:57:45 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o5A0vaWR021196
	for <linux-mm@kvack.org>; Wed, 9 Jun 2010 17:57:37 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by kpbe17.cbf.corp.google.com with ESMTP id o5A0vZJJ001462
	for <linux-mm@kvack.org>; Wed, 9 Jun 2010 17:57:35 -0700
Received: by pzk1 with SMTP id 1so943988pzk.8
        for <linux-mm@kvack.org>; Wed, 09 Jun 2010 17:57:35 -0700 (PDT)
Date: Wed, 9 Jun 2010 17:57:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 2/2] oom: fold __out_of_memory into out_of_memory
In-Reply-To: <alpine.DEB.2.00.1006091756270.1676@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006091757080.1676@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006091756270.1676@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

__out_of_memory() only has a single caller, so fold it into
out_of_memory() and add a comment about locking for its call to
oom_kill_process().

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   65 +++++++++++++++++++++++++-------------------------------
 1 files changed, 29 insertions(+), 36 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -628,41 +628,6 @@ static void clear_system_oom(void)
 	spin_unlock(&zone_scan_lock);
 }
 
-
-/*
- * Must be called with tasklist_lock held for read.
- */
-static void __out_of_memory(gfp_t gfp_mask, int order, const nodemask_t *mask)
-{
-	struct task_struct *p;
-	unsigned long points;
-
-	if (sysctl_oom_kill_allocating_task)
-		if (!oom_kill_process(current, gfp_mask, order, 0, NULL,
-				"Out of memory (oom_kill_allocating_task)"))
-			return;
-retry:
-	/*
-	 * Rambo mode: Shoot down a process and hope it solves whatever
-	 * issues we may have.
-	 */
-	p = select_bad_process(&points, NULL, mask);
-
-	if (PTR_ERR(p) == -1UL)
-		return;
-
-	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!p) {
-		dump_header(NULL, gfp_mask, order, NULL);
-		read_unlock(&tasklist_lock);
-		panic("Out of memory and no killable processes...\n");
-	}
-
-	if (oom_kill_process(p, gfp_mask, order, points, NULL,
-			     "Out of memory"))
-		goto retry;
-}
-
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  * @zonelist: zonelist pointer
@@ -678,7 +643,9 @@ retry:
 void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *nodemask)
 {
+	struct task_struct *p;
 	unsigned long freed = 0;
+	unsigned long points;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
@@ -703,10 +670,36 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	if (zonelist)
 		constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
 	check_panic_on_oom(constraint, gfp_mask, order);
+
 	read_lock(&tasklist_lock);
-	__out_of_memory(gfp_mask, order,
+	if (sysctl_oom_kill_allocating_task) {
+		/*
+		 * oom_kill_process() needs tasklist_lock held.  If it returns
+		 * non-zero, current could not be killed so we must fallback to
+		 * the tasklist scan.
+		 */
+		if (!oom_kill_process(current, gfp_mask, order, 0, NULL,
+				"Out of memory (oom_kill_allocating_task)"))
+			return;
+	}
+
+retry:
+	p = select_bad_process(&points, NULL,
 			constraint == CONSTRAINT_MEMORY_POLICY ? nodemask :
 								 NULL);
+	if (PTR_ERR(p) == -1UL)
+		return;
+
+	/* Found nothing?!?! Either we hang forever, or we panic. */
+	if (!p) {
+		dump_header(NULL, gfp_mask, order, NULL);
+		read_unlock(&tasklist_lock);
+		panic("Out of memory and no killable processes...\n");
+	}		
+
+	if (oom_kill_process(p, gfp_mask, order, points, NULL,
+			     "Out of memory"))
+		goto retry;
 	read_unlock(&tasklist_lock);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
