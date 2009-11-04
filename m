Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 467896B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 03:12:20 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA48CHKn007193
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Nov 2009 17:12:17 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D548945DE66
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 17:12:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 94B2F45DE65
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 17:12:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 46E418F8005
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 17:12:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A83C81DB803F
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 17:12:15 +0900 (JST)
Date: Wed, 4 Nov 2009 17:09:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
Message-Id: <20091104170944.cef988c7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, cl@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

If clarification is not enough, let me know.
Thank you for all your review in RFC version.
Thanks,
-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>

Fixing node-oriented allocation handling in oom-kill.c
I myself think this as bugfix not as enhancement.

In these days, things are changed as
  - alloc_pages() eats nodemask as its arguments, __alloc_pages_nodemask().
  - mempolicy don't maintain its own private zonelists.
  (And cpuset doesn't use nodemask for __alloc_pages_nodemask())

So, current oom-killer's check function is wrong.

This patch does
  - check nodemask, if nodemask && nodemask != node_states[N_HIGH_MEMORY]
    this is never be CONSTRAINT_NONE. We assume this from mempolicy.
  - Scan all zonelist under nodemask, if it hits cpuset's wall
    this faiulre is from cpuset.
And
  - modifies the caller of out_of_memory not to call oom if __GFP_THISNODE.
    This doesn't change "current" behavior.
    If callers use __GFP_THISNODE, it should handle "page allocation failure"
    by itself.

Changelog: 2009/11/04
 - cut out as bug-fix for passing nodemask.
 - added GFP_THISNODE sanity check.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>
---
 drivers/char/sysrq.c |    2 +-
 mm/oom_kill.c        |   38 ++++++++++++++++++++++++++------------
 mm/page_alloc.c      |   10 ++++++++--
 3 files changed, 35 insertions(+), 15 deletions(-)

Index: mmotm-2.6.32-Nov2/drivers/char/sysrq.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/drivers/char/sysrq.c
+++ mmotm-2.6.32-Nov2/drivers/char/sysrq.c
@@ -339,7 +339,7 @@ static struct sysrq_key_op sysrq_term_op
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0);
+	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
Index: mmotm-2.6.32-Nov2/mm/oom_kill.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/oom_kill.c
+++ mmotm-2.6.32-Nov2/mm/oom_kill.c
@@ -196,27 +196,40 @@ unsigned long badness(struct task_struct
 /*
  * Determine the type of allocation constraint.
  */
+#ifdef CONFIG_NUMA
 static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
-						    gfp_t gfp_mask)
+				    gfp_t gfp_mask, nodemask_t *nodemask)
 {
-#ifdef CONFIG_NUMA
 	struct zone *zone;
 	struct zoneref *z;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
-	nodemask_t nodes = node_states[N_HIGH_MEMORY];
+	int ret = CONSTRAINT_NONE;
 
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
-		if (cpuset_zone_allowed_softwall(zone, gfp_mask))
-			node_clear(zone_to_nid(zone), nodes);
-		else
+	/*
+ 	 * The nodemask here is a nodemask passed to alloc_pages(). Now,
+ 	 * cpuset doesn't use this nodemask for its hardwall/softwall/hierarchy
+ 	 * feature. Then, only mempolicy use this nodemask.
+ 	 */
+	if (nodemask && nodes_equal(*nodemask, node_states[N_HIGH_MEMORY]))
+		ret = CONSTRAINT_MEMORY_POLICY;
+
+	/* Check this allocation failure is caused by cpuset's wall function */
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+			high_zoneidx, nodemask)
+		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
 			return CONSTRAINT_CPUSET;
 
-	if (!nodes_empty(nodes))
-		return CONSTRAINT_MEMORY_POLICY;
-#endif
+	/* __GFP_THISNODE never calls OOM.*/
 
+	return ret;
+}
+#else
+static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
+				gfp_t gfp_mask, nodemask_t *nodemask)
+{
 	return CONSTRAINT_NONE;
 }
+#endif
 
 /*
  * Simple selection loop. We chose the process with the highest
@@ -603,7 +616,8 @@ rest_and_return:
  * OR try to be smart about which process to kill. Note that we
  * don't have to be perfect here, we just have to be good.
  */
-void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
+void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
+		int order, nodemask_t *nodemask)
 {
 	unsigned long freed = 0;
 	enum oom_constraint constraint;
@@ -622,7 +636,7 @@ void out_of_memory(struct zonelist *zone
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
-	constraint = constrained_alloc(zonelist, gfp_mask);
+	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
 	read_lock(&tasklist_lock);
 
 	switch (constraint) {
Index: mmotm-2.6.32-Nov2/mm/page_alloc.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/page_alloc.c
+++ mmotm-2.6.32-Nov2/mm/page_alloc.c
@@ -1667,9 +1667,15 @@ __alloc_pages_may_oom(gfp_t gfp_mask, un
 	/* The OOM killer will not help higher order allocs */
 	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_NOFAIL))
 		goto out;
-
+	/*
+	 * In usual, GFP_THISNODE contains __GFP_NORETRY and we never hit this.
+	 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
+	 * Note: Hugepage uses it but will hit PAGE_ALLOC_COSTLY_ORDER.
+	 */
+	if (gfp_mask & __GFP_THISNODE)
+		goto out;
 	/* Exhausted what can be done so it's blamo time */
-	out_of_memory(zonelist, gfp_mask, order);
+	out_of_memory(zonelist, gfp_mask, order, nodemask);
 
 out:
 	clear_zonelist_oom(zonelist, gfp_mask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
