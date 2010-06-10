Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7D64C6B0071
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 20:57:33 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o5A0vVS0021134
	for <linux-mm@kvack.org>; Wed, 9 Jun 2010 17:57:31 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by kpbe17.cbf.corp.google.com with ESMTP id o5A0vTjr001435
	for <linux-mm@kvack.org>; Wed, 9 Jun 2010 17:57:30 -0700
Received: by pzk36 with SMTP id 36so3651484pzk.32
        for <linux-mm@kvack.org>; Wed, 09 Jun 2010 17:57:29 -0700 (PDT)
Date: Wed, 9 Jun 2010 17:57:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 1/2] oom: remove constraint argument from select_bad_process
 and __out_of_memory
Message-ID: <alpine.DEB.2.00.1006091756270.1676@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

select_bad_process() and __out_of_memory() doe not need their
enum oom_constraint arguments: it's possible to pass a NULL nodemask if
constraint == CONSTRAINT_MEMORY_POLICY in the caller, out_of_memory().

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -284,8 +284,7 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
  * (not docbooked, we don't want this one cluttering up the manual)
  */
 static struct task_struct *select_bad_process(unsigned long *ppoints,
-		struct mem_cgroup *mem, enum oom_constraint constraint,
-		const nodemask_t *mask)
+		struct mem_cgroup *mem, const nodemask_t *nodemask)
 {
 	struct task_struct *p;
 	struct task_struct *chosen = NULL;
@@ -301,9 +300,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 			continue;
 		if (mem && !task_in_mem_cgroup(p, mem))
 			continue;
-		if (!has_intersects_mems_allowed(p,
-				constraint == CONSTRAINT_MEMORY_POLICY ? mask :
-									 NULL))
+		if (!has_intersects_mems_allowed(p, nodemask))
 			continue;
 
 		/*
@@ -518,7 +515,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0);
 	read_lock(&tasklist_lock);
 retry:
-	p = select_bad_process(&points, mem, CONSTRAINT_MEMCG, NULL);
+	p = select_bad_process(&points, mem, NULL);
 	if (!p || PTR_ERR(p) == -1UL)
 		goto out;
 
@@ -635,8 +632,7 @@ static void clear_system_oom(void)
 /*
  * Must be called with tasklist_lock held for read.
  */
-static void __out_of_memory(gfp_t gfp_mask, int order,
-			enum oom_constraint constraint, const nodemask_t *mask)
+static void __out_of_memory(gfp_t gfp_mask, int order, const nodemask_t *mask)
 {
 	struct task_struct *p;
 	unsigned long points;
@@ -650,7 +646,7 @@ retry:
 	 * Rambo mode: Shoot down a process and hope it solves whatever
 	 * issues we may have.
 	 */
-	p = select_bad_process(&points, NULL, constraint, mask);
+	p = select_bad_process(&points, NULL, mask);
 
 	if (PTR_ERR(p) == -1UL)
 		return;
@@ -708,7 +704,9 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
 	check_panic_on_oom(constraint, gfp_mask, order);
 	read_lock(&tasklist_lock);
-	__out_of_memory(gfp_mask, order, constraint, nodemask);
+	__out_of_memory(gfp_mask, order,
+			constraint == CONSTRAINT_MEMORY_POLICY ? nodemask :
+								 NULL);
 	read_unlock(&tasklist_lock);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
