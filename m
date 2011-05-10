Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 830D090010F
	for <linux-mm@kvack.org>; Tue, 10 May 2011 06:20:38 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D8F2B3EE0B5
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:20:35 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B98C945DE52
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:20:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C13B45DE4F
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:20:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ED4B1DB803E
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:20:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FC8B1DB802F
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:20:35 +0900 (JST)
Date: Tue, 10 May 2011 19:13:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 7/7] memcg: workqueue for async reclaim
Message-Id: <20110510191353.fb17efb8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

workqueue for memory cgroup asynchronous memory shrinker.

This patch implements the workqueue of async shrinker routine. each
memcg has a work and only one work can be scheduled at the same time.

If shrinking memory doesn't goes well, delay will be added to the work.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   82 +++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 79 insertions(+), 3 deletions(-)

Index: mmotm-May6/mm/memcontrol.c
===================================================================
--- mmotm-May6.orig/mm/memcontrol.c
+++ mmotm-May6/mm/memcontrol.c
@@ -305,6 +305,12 @@ struct mem_cgroup {
 	 * mem_cgroup ? And what type of charges should we move ?
 	 */
 	unsigned long 	move_charge_at_immigrate;
+
+	/* For asynchronous memory reclaim */
+	struct delayed_work	async_work;
+	unsigned long		async_work_flags;
+#define ASYNC_NORESCHED	(0)	/* need to stop scanning */
+#define ASYNC_RUNNING	(1)	/* a work is in schedule or running. */
 	/*
 	 * percpu counter.
 	 */
@@ -3631,6 +3637,74 @@ unsigned long mem_cgroup_soft_limit_recl
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
+	shrink_to = limit - MEMCG_ASYNC_STOP_MARGIN - PAGE_SIZE;
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
+	if (test_bit(ASYNC_NORESCHED, &mem->async_work_flags)
+	    || mem_cgroup_async_should_stop(mem))
+		goto finish_scan;
+	/* If memory reclaim couldn't go well, add delay */
+	if (congested)
+		delay = HZ/10;
+
+	if (queue_delayed_work(memcg_async_shrinker, &mem->async_work, delay))
+		return;
+finish_scan:
+	cgroup_release_and_wakeup_rmdir(&mem->css);
+	clear_bit(ASYNC_RUNNING, &mem->async_work_flags);
+	return;
+}
+
+static void run_mem_cgroup_async_shrinker(struct mem_cgroup *mem)
+{
+	if (test_bit(ASYNC_NORESCHED, &mem->async_work_flags))
+		return;
+	if (test_and_set_bit(ASYNC_RUNNING, &mem->async_work_flags))
+		return;
+	cgroup_exclude_rmdir(&mem->css);
+	if (!queue_delayed_work(memcg_async_shrinker, &mem->async_work, 0)) {
+		cgroup_release_and_wakeup_rmdir(&mem->css);
+		clear_bit(ASYNC_RUNNING, &mem->async_work_flags);
+	}
+	return;
+}
+
+static void stop_mem_cgroup_async_shrinker(struct mem_cgroup *mem)
+{
+	set_bit(ASYNC_NORESCHED, &mem->async_work_flags);
+	flush_delayed_work(&mem->async_work);
+	clear_bit(ASYNC_NORESCHED, &mem->async_work_flags);
+}
+
 bool mem_cgroup_async_should_stop(struct mem_cgroup *mem)
 {
 	return res_counter_margin(&mem->res) >= MEMCG_ASYNC_STOP_MARGIN;
@@ -3640,9 +3714,8 @@ static void mem_cgroup_may_async_reclaim
 {
 	if (!mem->need_async_reclaim)
 		return;
-	if (res_counter_margin(&mem->res) <= MEMCG_ASYNC_START_MARGIN) {
-		/* Fill here */
-	}
+	if (res_counter_margin(&mem->res) <= MEMCG_ASYNC_START_MARGIN)
+		run_mem_cgroup_async_shrinker(mem);
 }
 
 /*
@@ -3727,6 +3800,7 @@ move_account:
 		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
 			goto out;
 		ret = -EINTR;
+		stop_mem_cgroup_async_shrinker(mem);
 		if (signal_pending(current))
 			goto out;
 		/* This is for making all *used* pages to be on LRU. */
@@ -4897,6 +4971,7 @@ mem_cgroup_create(struct cgroup_subsys *
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
