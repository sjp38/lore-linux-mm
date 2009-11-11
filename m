Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 44CCF6B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 01:36:55 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAB6aqSx004488
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 11 Nov 2009 15:36:52 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F04245DE4F
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 15:36:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 002D445DE4E
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 15:36:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D7EC51DB8044
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 15:36:51 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E8C01DB8042
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 15:36:51 +0900 (JST)
Date: Wed, 11 Nov 2009 15:34:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v4.2
Message-Id: <20091111153414.3c263842.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0911102224440.6652@chino.kir.corp.google.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com>
	<20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110163419.361E.A69D9226@jp.fujitsu.com>
	<20091110164055.a1b44a4b.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110170338.9f3bb417.nishimura@mxp.nes.nec.co.jp>
	<20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911102155580.2924@chino.kir.corp.google.com>
	<20091111152004.3d585cee.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911102224440.6652@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Nov 2009 22:26:19 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:
	 */
> > > > +	if (gfp_mask & __GPF_THISNODE)
> > > > +		return ret;
> > > >  
> > > 
> > > That shouldn't compile.
> > > 
> > Why ?
> > 
> 
> Even when I pointed it out, you still didn't bother to try compiling it?  
> You need s/GPF/GFP, it stands for "get free pages."
> 
You're right.
Ah. I noticed CONFIG_NUMA=n
....(of course, I usually set it =y)

> You can also eliminate the ret variable, it's not doing anything.
> 
ok. fixed one here. Thank you.
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
 - removed 'ret'

Changelog: 2009/11/11
 - fixed nodes_equal() calculation.
 - return CONSTRAINT_MEMPOLICY always if given nodemask is not enough big.

Changelog: 2009/11/06
 - fixed lack of oom.h

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>
---
 drivers/char/sysrq.c |    2 +-
 include/linux/oom.h  |    4 +++-
 mm/oom_kill.c        |   46 +++++++++++++++++++++++++++++++++-------------
 mm/page_alloc.c      |   20 +++++++++++++++-----
 4 files changed, 52 insertions(+), 20 deletions(-)

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
@@ -196,27 +196,46 @@ unsigned long badness(struct task_struct
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
+	if (gfp_mask & __GFP_THISNODE)
+		return CONSTRAINT_NONE;
 
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
@@ -603,7 +622,8 @@ rest_and_return:
  * OR try to be smart about which process to kill. Note that we
  * don't have to be perfect here, we just have to be good.
  */
-void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
+void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
+		int order, nodemask_t *nodemask)
 {
 	unsigned long freed = 0;
 	enum oom_constraint constraint;
@@ -622,7 +642,7 @@ void out_of_memory(struct zonelist *zone
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
