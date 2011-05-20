Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE4F6B0024
	for <linux-mm@kvack.org>; Thu, 19 May 2011 23:55:26 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 0CA0F3EE0B5
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:55:23 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E2C1A45DE58
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:55:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C87D845DE54
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:55:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B9ED0EF8004
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:55:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 75481E08001
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:55:22 +0900 (JST)
Date: Fri, 20 May 2011 12:48:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 8/8] memcg asyncrhouns reclaim workqueue
Message-Id: <20110520124837.72978344.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

workqueue for memory cgroup asynchronous memory shrinker.

This patch implements the workqueue of async shrinker routine. each
memcg has a work and only one work can be scheduled at the same time.

If shrinking memory doesn't goes well, delay will be added to the work.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   84 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 81 insertions(+), 3 deletions(-)

Index: mmotm-May11/mm/memcontrol.c
===================================================================
--- mmotm-May11.orig/mm/memcontrol.c
+++ mmotm-May11/mm/memcontrol.c
@@ -302,12 +302,17 @@ struct mem_cgroup {
 	 * mem_cgroup ? And what type of charges should we move ?
 	 */
 	unsigned long 	move_charge_at_immigrate;
+
+	/* For asynchronous memory reclaim */
+	struct delayed_work	async_work;
 	/*
  	 * Checks for async reclaim.
  	 */
 	unsigned long	async_flags;
 #define AUTO_ASYNC_ENABLED	(0)
 #define USE_AUTO_ASYNC		(1)
+#define ASYNC_NORESCHED		(2)	/* need to stop scanning */
+#define ASYNC_RUNNING		(3)	/* a work is in schedule or running. */
 	/*
 	 * percpu counter.
 	 */
@@ -3647,6 +3652,78 @@ unsigned long mem_cgroup_soft_limit_recl
 	return nr_reclaimed;
 }
 
+struct workqueue_struct *memcg_async_shrinker;
+
+static int memcg_async_shrinker_init(void)
+{
+	memcg_async_shrinker = alloc_workqueue("memcg_async",
+				WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_FREEZABLE, 0);
+	return 0;
+}
+module_init(memcg_async_shrinker_init);
+
+static void mem_cgroup_async_shrink(struct work_struct *work)
+{
+	struct delayed_work *dw = to_delayed_work(work);
+	struct mem_cgroup *mem = container_of(dw,
+			struct mem_cgroup, async_work);
+	bool congested = false;
+	int delay = 0;
+	unsigned long long required, usage, limit, shrink_to;
+
+	limit = res_counter_read_u64(&mem->res, RES_LIMIT);
+	shrink_to = limit - MEMCG_ASYNC_MARGIN - PAGE_SIZE;
+	usage = res_counter_read_u64(&mem->res, RES_USAGE);
+	if (shrink_to <= usage) {
+		required = usage - shrink_to;
+		required = (required >> PAGE_SHIFT) + 1;
+		/*
+		 * This scans some number of pages and returns that memory
+		 * reclaim was slow or now. If slow, we add a delay as
+		 * congestion_wait() in vmscan.c
+		 */
+		congested = mem_cgroup_shrink_static_scan(mem, (long)required);
+	}
+	if (test_bit(ASYNC_NORESCHED, &mem->async_flags)
+	    || mem_cgroup_async_should_stop(mem))
+		goto finish_scan;
+	/* If memory reclaim couldn't go well, add delay */
+	if (congested)
+		delay = HZ/10;
+
+	queue_delayed_work(memcg_async_shrinker, &mem->async_work, delay);
+	return;
+finish_scan:
+	cgroup_release_and_wakeup_rmdir(&mem->css);
+	clear_bit(ASYNC_RUNNING, &mem->async_flags);
+	return;
+}
+
+static void run_mem_cgroup_async_shrinker(struct mem_cgroup *mem)
+{
+	if (test_bit(ASYNC_NORESCHED, &mem->async_flags))
+		return;
+	if (test_and_set_bit(ASYNC_RUNNING, &mem->async_flags))
+		return;
+	cgroup_exclude_rmdir(&mem->css);
+	/*
+	 * start reclaim with small delay. This delay will allow us to do job
+	 * in batch.
+	 */
+	if (!queue_delayed_work(memcg_async_shrinker, &mem->async_work, 1)) {
+		cgroup_release_and_wakeup_rmdir(&mem->css);
+		clear_bit(ASYNC_RUNNING, &mem->async_flags);
+	}
+	return;
+}
+
+static void stop_mem_cgroup_async_shrinker(struct mem_cgroup *mem)
+{
+	set_bit(ASYNC_NORESCHED, &mem->async_flags);
+	flush_delayed_work(&mem->async_work);
+	clear_bit(ASYNC_NORESCHED, &mem->async_flags);
+}
+
 bool mem_cgroup_async_should_stop(struct mem_cgroup *mem)
 {
 	return res_counter_margin(&mem->res) >= MEMCG_ASYNC_MARGIN;
@@ -3656,9 +3733,8 @@ static void mem_cgroup_may_async_reclaim
 {
 	if (!test_bit(USE_AUTO_ASYNC, &mem->async_flags))
 		return;
-	if (res_counter_margin(&mem->res) <= MEMCG_ASYNC_MARGIN) {
-		/* Fill here */
-	}
+	if (res_counter_margin(&mem->res) <= MEMCG_ASYNC_MARGIN)
+		run_mem_cgroup_async_shrinker(mem);
 }
 
 /*
@@ -3743,6 +3819,7 @@ move_account:
 		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
 			goto out;
 		ret = -EINTR;
+		stop_mem_cgroup_async_shrinker(mem);
 		if (signal_pending(current))
 			goto out;
 		/* This is for making all *used* pages to be on LRU. */
@@ -4941,6 +5018,7 @@ mem_cgroup_create(struct cgroup_subsys *
 		mem->swappiness = mem_cgroup_swappiness(parent);
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
+	INIT_DELAYED_WORK(&mem->async_work, mem_cgroup_async_shrink);
 	mutex_init(&mem->thresholds_lock);
 	return &mem->css;
 free_out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
