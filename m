Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 16EC36B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 04:43:07 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0M9h2aY003040
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Jan 2009 18:43:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CB9945DE5D
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:43:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E3BDB45DD79
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:43:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AD79CE18008
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:43:01 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B49CE38001
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:43:01 +0900 (JST)
Date: Thu, 22 Jan 2009 18:41:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] [PATCH 7/7] memcg: background reclaim (example)
Message-Id: <20090122184157.2307bf5b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090122183411.3cabdfd2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090122183411.3cabdfd2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

A sample for background-reclaim for memcg using pdflush().

Just an example, any comments are welcome.
Maybe it needs some amount of more work/time to fix this patch.

This is a patch for background memory reclaim for memcg, like kswapd().
In this, pdflush() is used for reclaim some more memory when tasks
under memcg hits limit.

Note:
 - considering hierarchy, high-low watermark in the kernel seems to be
   very complex. My purpose is adding an funcitonality like kswapd().
   No performance test yet.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   87 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 85 insertions(+), 2 deletions(-)

Index: mmotm-2.6.29-Jan16/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Jan16.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Jan16/mm/memcontrol.c
@@ -37,7 +37,7 @@
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
 #include "internal.h"
-
+#include <linux/writeback.h>
 #include <asm/uaccess.h>
 
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
@@ -166,6 +166,7 @@ struct mem_cgroup {
 	 * reclaimed from.
 	 */
 	int last_scanned_child;
+	int pdflush_called;
 	/*
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
@@ -297,7 +298,7 @@ static struct mem_cgroup *try_get_mem_cg
 	struct mem_cgroup *mem = NULL;
 
 	if (!mm)
-		return;
+		return NULL;
 	/*
 	 * Because we have no locks, mm->owner's may be being moved to other
 	 * cgroup. We use css_tryget() here even if this looks
@@ -771,6 +772,7 @@ mem_cgroup_select_victim(struct mem_cgro
 	return ret;
 }
 
+static void mem_cgroup_bg_reclaim(unsigned long arg0);
 /*
  * Scan the hierarchy if needed to reclaim memory. We remember the last child
  * we reclaimed from, so that we don't end up penalizing one child extensively
@@ -790,6 +792,17 @@ static int mem_cgroup_hierarchical_recla
 	int ret, total = 0;
 	int loop = 0;
 
+	if (!shrink) { /* memory usage hit limit */
+		if (!root_mem->pdflush_called) {
+			if (!pdflush_operation(mem_cgroup_bg_reclaim,
+					      css_id(&root_mem->css))) {
+				spin_lock(&root_mem->reclaim_param_lock);
+				root_mem->pdflush_called = 1;
+				spin_unlock(&root_mem->reclaim_param_lock);
+			}
+		}
+	}
+
 	while (loop < 2) {
 		victim = mem_cgroup_select_victim(root_mem);
 		if (victim == root_mem)
@@ -817,6 +830,76 @@ static int mem_cgroup_hierarchical_recla
 	return total;
 }
 
+/*
+ * Called when hierarchy reclaim triggered by memory limitation check.
+ * ID of hierarchy root is the argument.
+ */
+#define FREE_THRESH_RATIO	(95)	      /* 95% */
+#define FREE_THRESH_MAX		(1024 * 1024) /* 1M bytes*/
+#define FREE_THRESH_MIN		(128 * 1024)  /* 128kbytes */
+static u64 memcg_stable_free_thresh(u64 limit)
+{
+	u64 ret;
+
+	ret = limit * FREE_THRESH_RATIO/100;
+	/* backgroubd writeout is overkill to this cgroup ? */
+	if (ret < FREE_THRESH_MIN)
+		ret = 0;
+	if (ret > FREE_THRESH_MAX)
+		ret = FREE_THRESH_MAX;
+	return ret;
+}
+
+static void mem_cgroup_bg_reclaim(unsigned long arg0)
+{
+	struct cgroup_subsys_state *css;
+	struct mem_cgroup *mem = NULL;
+	u64 usage, limit;
+	bool memshortage, noswap;
+	int retry;
+
+	rcu_read_lock();
+	css = css_lookup(&mem_cgroup_subsys, arg0);
+	if (css && css_tryget(css))
+		mem = container_of(css, struct mem_cgroup, css);
+	rcu_read_unlock();
+	if (!mem)
+		return;
+	retry = mem_cgroup_count_children(mem);
+	while (retry--) {
+		/* check situation */
+		memshortage = false;
+		noswap = false;
+		usage = res_counter_read_u64(&mem->res, RES_USAGE);
+		limit = res_counter_read_u64(&mem->res, RES_LIMIT);
+
+		if (usage > limit - memcg_stable_free_thresh(limit))
+			memshortage = true;
+
+		if (do_swap_account) {
+			usage = res_counter_read_u64(&mem->res, RES_USAGE);
+			limit = res_counter_read_u64(&mem->res, RES_LIMIT);
+			if (usage > limit - memcg_stable_free_thresh(limit))
+				noswap = true;
+		}
+		if (memshortage || noswap)
+			mem_cgroup_hierarchical_reclaim(mem, GFP_KERNEL,
+							noswap, true);
+		else
+			break;
+		cond_resched();
+	}
+
+	spin_lock(&mem->reclaim_param_lock);
+	mem->pdflush_called = 0;
+	spin_unlock(&mem->reclaim_param_lock);
+	css_put(&mem->css);
+
+	return;
+}
+
+
+
 bool mem_cgroup_oom_called(struct task_struct *task)
 {
 	bool ret = false;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
