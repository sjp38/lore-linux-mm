Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5A5D06B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 00:31:14 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAB5UrLi003795
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 11 Nov 2009 14:30:53 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 37C1745DE52
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 14:30:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 141BB45DE51
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 14:30:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EBFA2E1800D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 14:30:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F1E4E18009
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 14:30:52 +0900 (JST)
Date: Wed, 11 Nov 2009 14:28:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v4.1
Message-Id: <20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com>
	<20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110163419.361E.A69D9226@jp.fujitsu.com>
	<20091110164055.a1b44a4b.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110170338.9f3bb417.nishimura@mxp.nes.nec.co.jp>
	<20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, cl@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Sorry, missed to remove 'inline'...
==
From: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>

Fixing node-oriented allocation handling in oom-kill.c
I myself think this as bugfix not as ehnancement.

In these days, things are changed as
  - alloc_pages() eats nodemask as its arguments, __alloc_pages_nodemask().
  - mempolicy don't maintain its own private zonelists.
  (And cpuset doesn't use nodemask for __alloc_pages_nodemask())

So, current oom-killer's check function is wrong.

This patch does
  - check nodemask, if nodemask && nodemask doesn't cover all
    node_states[N_HIGH_MEMORY], this is CONSTRAINT_MEMORY_POLICY.
  - Scan all zonelist under nodemask, if it hits cpuset's wall
    this faiulre is from cpuset.
And
  - modifies the caller of out_of_memory not to call oom if __GFP_THISNODE.
    This doesn't change "current" behavior. If callers use __GFP_THISNODE
    it should handle "page allocation failure" by itself.

  - handle __GFP_NOFAIL+__GFP_THISNODE path.
    This is something like a FIXME but this gfpmask is not used now.

Changelog: 2009/11/11(2)
 - uses nodes_subset().
 - clean up.
 - added __GFP_NOFAIL case. And added waring.
 - removed inline

Changelog: 2009/11/11
 - fixed nodes_equal() calculation.
 - return CONSTRAINT_MEMPOLICY always if given nodemask is not enough big.

Changelog: 2009/11/06
 - fixed lack of oom.h

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>
---
 drivers/char/sysrq.c |    2 +-
 include/linux/oom.h  |    4 +++-
 mm/oom_kill.c        |   47 ++++++++++++++++++++++++++++++++++-------------
 mm/page_alloc.c      |   20 +++++++++++++++-----
 4 files changed, 53 insertions(+), 20 deletions(-)

Index: mm-test-kernel/drivers/char/sysrq.c
===================================================================
--- mm-test-kernel.orig/drivers/char/sysrq.c
+++ mm-test-kernel/drivers/char/sysrq.c
@@ -339,7 +339,7 @@ static struct sysrq_key_op sysrq_term_op
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0);
+	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
Index: mm-test-kernel/mm/oom_kill.c
===================================================================
--- mm-test-kernel.orig/mm/oom_kill.c
+++ mm-test-kernel/mm/oom_kill.c
@@ -196,27 +196,47 @@ unsigned long badness(struct task_struct
 /*
  * Determine the type of allocation constraint.
  */
-static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
-						    gfp_t gfp_mask)
-{
 #ifdef CONFIG_NUMA
+static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
+				    gfp_t gfp_mask, nodemask_t *nodemask)
+{
 	struct zone *zone;
 	struct zoneref *z;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
-	nodemask_t nodes = node_states[N_HIGH_MEMORY];
+	int ret = CONSTRAINT_NONE;
 
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
-		if (cpuset_zone_allowed_softwall(zone, gfp_mask))
-			node_clear(zone_to_nid(zone), nodes);
-		else
-			return CONSTRAINT_CPUSET;
+	/*
+	 * Reach here only when __GFP_NOFAIL is used. So, we should avoid
+ 	 * to kill current.We have to random task kill in this case.
+ 	 * Hopefully, CONSTRAINT_THISNODE...but no way to handle it, now.
+ 	 */
+	if (gfp_mask & __GPF_THISNODE)
+		return ret;
 
-	if (!nodes_empty(nodes))
+	/*
+ 	 * The nodemask here is a nodemask passed to alloc_pages(). Now,
+ 	 * cpuset doesn't use this nodemask for its hardwall/softwall/hierarchy
+ 	 * feature. mempolicy is an only user of nodemask here.
+	 * check mempolicy's nodemask contains all N_HIGH_MEMORY
+ 	 */
+	if (nodemask && !nodes_subset(node_states[N_HIGH_MEMORY], *nodemask))
 		return CONSTRAINT_MEMORY_POLICY;
-#endif
 
+	/* Check this allocation failure is caused by cpuset's wall function */
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+			high_zoneidx, nodemask)
+		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
+			return CONSTRAINT_CPUSET;
+
+	return CONSTRAINT_NONE;
+}
+#else
+static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
+				gfp_t gfp_mask, nodemask_t *nodemask)
+{
 	return CONSTRAINT_NONE;
 }
+#endif
 
 /*
  * Simple selection loop. We chose the process with the highest
@@ -603,7 +623,8 @@ rest_and_return:
  * OR try to be smart about which process to kill. Note that we
  * don't have to be perfect here, we just have to be good.
  */
-void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
+void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
+		int order, nodemask_t *nodemask)
 {
 	unsigned long freed = 0;
 	enum oom_constraint constraint;
@@ -622,7 +643,7 @@ void out_of_memory(struct zonelist *zone
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
-	constraint = constrained_alloc(zonelist, gfp_mask);
+	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
 	read_lock(&tasklist_lock);
 
 	switch (constraint) {
Index: mm-test-kernel/mm/page_alloc.c
===================================================================
--- mm-test-kernel.orig/mm/page_alloc.c
+++ mm-test-kernel/mm/page_alloc.c
@@ -1664,12 +1664,22 @@ __alloc_pages_may_oom(gfp_t gfp_mask, un
 	if (page)
 		goto out;
 
-	/* The OOM killer will not help higher order allocs */
-	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_NOFAIL))
-		goto out;
-
+	if (!(gfp_mask & __GFP_NOFAIL)) {
+		/* The OOM killer will not help higher order allocs */
+		if (order > PAGE_ALLOC_COSTLY_ORDER)
+			goto out;
+		/*
+	 	* GFP_THISNODE contains __GFP_NORETRY and we never hit this.
+	 	* Sanity check for bare calls of __GFP_THISNODE, not real OOM.
+	 	* The caller should handle page allocation failure by itself if
+	 	* it specifies __GFP_THISNODE.
+	 	* Note: Hugepage uses it but will hit PAGE_ALLOC_COSTLY_ORDER.
+	 	*/
+		if (gfp_mask & __GFP_THISNODE)
+			goto out;
+	}
 	/* Exhausted what can be done so it's blamo time */
-	out_of_memory(zonelist, gfp_mask, order);
+	out_of_memory(zonelist, gfp_mask, order, nodemask);
 
 out:
 	clear_zonelist_oom(zonelist, gfp_mask);
Index: mm-test-kernel/include/linux/oom.h
===================================================================
--- mm-test-kernel.orig/include/linux/oom.h
+++ mm-test-kernel/include/linux/oom.h
@@ -10,6 +10,7 @@
 #ifdef __KERNEL__
 
 #include <linux/types.h>
+#include <linux/nodemask.h>
 
 struct zonelist;
 struct notifier_block;
@@ -26,7 +27,8 @@ enum oom_constraint {
 extern int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
-extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
+extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
+		int order, nodemask_t *mask);
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
