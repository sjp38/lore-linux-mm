Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 916256B0025
	for <linux-mm@kvack.org>; Thu, 26 May 2011 01:31:27 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1CBCC3EE0C0
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:31:23 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0419C45DF46
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:31:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CFF1245DF47
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:31:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AC41AE18001
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:31:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 51667E08002
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:31:22 +0900 (JST)
Date: Thu, 26 May 2011 14:24:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH v3 6/10] memcg : auto keep margin in background ,
 workqueue core.
Message-Id: <20110526142436.47388978.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>


Core codes for controling workqueue for keeping margin to limit
in background. For contrling work, this patch adds 2 flags.

ASYNC_WORKER_RUNNING indicates the worker for memcg is scheduled and
"don't need to add new work". ASYNC_WORKER_SHOULD_STOP indicates that
someone is trying to remove the memcg and "stop async reclaim".
Because a worker need to hold a reference count for the memcg,
"stop work" is required at removing cgroup.

memory cgroup's automatic-keep-margin-to-limit work is scheduled
by memcg_async_shrinker workqueue which is configured as WQ_UNBOUND.

A shrinker core code mem_cgroup_shrink_rate_limited() will be
implemented in following patches.

Changelog:
  - added comments and renamed flags.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    3 +
 mm/memcontrol.c      |   80 +++++++++++++++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c          |    6 +++
 3 files changed, 87 insertions(+), 2 deletions(-)

Index: memcg_async/mm/memcontrol.c
===================================================================
--- memcg_async.orig/mm/memcontrol.c
+++ memcg_async/mm/memcontrol.c
@@ -288,10 +288,12 @@ struct mem_cgroup {
  	 */
 	unsigned long	margin_to_limit_pages; /* margin to limit */
 	spinlock_t	update_margin_lock;
-	unsigned long	async_flags;
+	struct delayed_work	async_work;
+	unsigned long		async_flags;
 #define AUTO_KEEP_MARGIN_ENABLED	(0) /* user enabled async reclaim */
 #define FAILED_TO_KEEP_MARGIN		(1) /* someone hit limit */
-
+#define ASYNC_WORKER_RUNNING		(2) /* a worker runs */
+#define ASYNC_WORKER_SHOULD_STOP	(3) /* worker thread should stop */
 	/*
 	 * percpu counter.
 	 */
@@ -3862,10 +3864,82 @@ static void mem_cgroup_reset_margin_to_l
 }
 
 /*
+ * Codes for reclaim memory in background with help of kworker.
+ * memory cgroup uses UNBOUND workqueue.
+ */
+struct workqueue_struct *memcg_async_shrinker;
+
+static int memcg_async_shrinker_init(void)
+{
+	memcg_async_shrinker = alloc_workqueue("memcg_async",
+			WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_FREEZABLE, 0);
+	return 0;
+}
+module_init(memcg_async_shrinker_init);
+/*
+ * Called from rmdir() path and stop asynchronous worker because
+ * it has an extra reference count.
+ */
+static void mem_cgroup_stop_async_worker(struct mem_cgroup *mem)
+{
+	/* The worker will stop when see this flag */
+	set_bit(ASYNC_WORKER_SHOULD_STOP, &mem->async_flags);
+	flush_delayed_work(&mem->async_work);
+	clear_bit(ASYNC_WORKER_SHOULD_STOP, &mem->async_flags);
+}
+
+/*
+ * Reclaim memory in asynchronous way. This function is for getting
+ * enough margin to limit in background. If margin is enough big or
+ * someone tries to delete cgroup, stop reclaim.
+ * If margin is big even after shrink memory, reschedule itself again.
+ */
+static void mem_cgroup_async_shrink_worker(struct work_struct *work)
+{
+	struct delayed_work *dw = to_delayed_work(work);
+	struct mem_cgroup *mem;
+	int delay = 0;
+	long nr_to_reclaim;
+
+	mem = container_of(dw, struct mem_cgroup, async_work);
+
+	if (!test_bit(AUTO_KEEP_MARGIN_ENABLED, &mem->async_flags) ||
+	    test_bit(ASYNC_WORKER_SHOULD_STOP, &mem->async_flags))
+		goto finish_scan;
+
+	nr_to_reclaim = mem->margin_to_limit_pages - mem_cgroup_margin(mem);
+
+	if (nr_to_reclaim > 0)
+		mem_cgroup_shrink_rate_limited(mem, nr_to_reclaim);
+	else
+		goto finish_scan;
+	/* If margin is enough big, stop */
+	if (mem_cgroup_margin(mem) >= mem->margin_to_limit_pages)
+		goto finish_scan;
+	/* If someone tries to rmdir(), we should stop */
+	if (test_bit(ASYNC_WORKER_SHOULD_STOP, &mem->async_flags))
+		goto finish_scan;
+
+	queue_delayed_work(memcg_async_shrinker, &mem->async_work, delay);
+	return;
+finish_scan:
+	cgroup_release_and_wakeup_rmdir(&mem->css);
+	clear_bit(ASYNC_WORKER_RUNNING, &mem->async_flags);
+	return;
+}
+
+/*
  * Run a asynchronous memory reclaim on the memcg.
  */
 static void mem_cgroup_schedule_async_reclaim(struct mem_cgroup *mem)
 {
+	if (test_and_set_bit(ASYNC_WORKER_RUNNING, &mem->async_flags))
+		return;
+	cgroup_exclude_rmdir(&mem->css);
+	if (!queue_delayed_work(memcg_async_shrinker, &mem->async_work, 0)) {
+		cgroup_release_and_wakeup_rmdir(&mem->css);
+		clear_bit(ASYNC_WORKER_RUNNING, &mem->async_flags);
+	}
 }
 
 /*
@@ -3960,6 +4034,7 @@ static int mem_cgroup_force_empty(struct
 move_account:
 	do {
 		ret = -EBUSY;
+		mem_cgroup_stop_async_worker(mem);
 		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
 			goto out;
 		ret = -EINTR;
@@ -5239,6 +5314,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	spin_lock_init(&mem->update_margin_lock);
+	INIT_DELAYED_WORK(&mem->async_work, mem_cgroup_async_shrink_worker);
 	mutex_init(&mem->thresholds_lock);
 	return &mem->css;
 free_out:
Index: memcg_async/include/linux/swap.h
===================================================================
--- memcg_async.orig/include/linux/swap.h
+++ memcg_async/include/linux/swap.h
@@ -257,6 +257,9 @@ extern unsigned long mem_cgroup_shrink_n
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
 						unsigned long *nr_scanned);
+extern void mem_cgroup_shrink_rate_limited(struct mem_cgroup *mem,
+				           unsigned long nr_to_reclaim);
+
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
Index: memcg_async/mm/vmscan.c
===================================================================
--- memcg_async.orig/mm/vmscan.c
+++ memcg_async/mm/vmscan.c
@@ -2261,6 +2261,12 @@ unsigned long try_to_free_mem_cgroup_pag
 
 	return nr_reclaimed;
 }
+
+void mem_cgroup_shrink_rate_limited(struct mem_cgroup *mem,
+				unsigned long nr_to_reclaim)
+{
+}
+
 #endif
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
