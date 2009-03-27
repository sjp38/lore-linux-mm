Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D47216B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 01:01:20 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2R58LjI005341
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 27 Mar 2009 14:08:21 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 53D5345DD72
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:08:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1540845DE50
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:08:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EAFC5E18007
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:08:20 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 984F4E18002
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:08:20 +0900 (JST)
Date: Fri, 27 Mar 2009 14:06:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/8] memcg soft limit priority array queue.
Message-Id: <20090327140653.a12c6b1e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

I'm now search a way to reduce lock contention without complex...
-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Softlimitq. for memcg.

Implements an array of queue to list memcgs, array index is determined by
the amount of memory usage excess the soft limit.

While Balbir's one uses RB-tree and my old one used a per-zone queue
(with round-robin), this is one of mixture of them.
(I'd like to use rotation of queue in later patches)

Priority is determined by following.
   unit = total pages/1024.
   if excess is...
      < unit,          priority = 0
      < unit*2,        priority = 1,
      < unit*2*2,      priority = 2,
      ...
      < unit*2^9,      priority = 9,
      < unit*2^10,      priority = 10,

This patch just includes queue management part and not includes 
selection logic from queue. Some trick will be used for selecting victims at
soft limit in efficient way.

And this equips 2 queues, for anon and file. Inset/Delete of both list is
done at once but scan will be independent. (These 2 queues are used later.)

Major difference from Balbir's one other than RB-tree is bahavior under
hierarchy. This one adds all children to queue by checking hierarchical
priority. This is for helping per-zone usage check on victim-selection logic.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  121 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 120 insertions(+), 1 deletion(-)

Index: mmotm-2.6.29-Mar23/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Mar23.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Mar23/mm/memcontrol.c
@@ -192,7 +192,13 @@ struct mem_cgroup {
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
-
+	/*
+	 * For soft limit.
+	 */
+	int soft_limit_priority;
+	struct list_head soft_limit_anon;
+	struct list_head soft_limit_file;
+	spinlock_t soft_limit_lock;
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -938,11 +944,116 @@ static bool mem_cgroup_soft_limit_check(
 	return ret;
 }
 
+/*
+ * Assume "base_amount", and excess = usage - soft limit.
+ *
+ * 0...... if excess < base_amount
+ * 1...... if excess < base_amount * 2
+ * 2...... if excess < base_amount * 2^2
+ * 3.......if excess < base_amount * 2^3
+ * ....
+ * 9.......if excess < base_amount * 2^9
+ * 10 .....if excess < base_amount * 2^10
+ */
+
+#define SLQ_MAXPRIO (11)
+static struct {
+	spinlock_t lock;
+	struct list_head queue[SLQ_MAXPRIO][2]; /* 0:anon 1:file */
+#define SL_ANON (0)
+#define SL_FILE (1)
+} softlimitq;
+
+#define SLQ_PRIO_FACTOR (1024) /* 2^10 */
+static unsigned long memcg_softlimit_base __read_mostly;
+
+static int __calc_soft_limit_prio(unsigned long long excess)
+{
+	unsigned long val;
+
+	val = excess / PAGE_SIZE;
+	val = val /memcg_softlimit_base;
+	return fls(val);
+}
+
+static int mem_cgroup_soft_limit_prio(struct mem_cgroup *mem)
+{
+	unsigned long long excess, max_excess;
+	struct res_counter *c;
+
+	max_excess = 0;
+	for (c = &mem->res; c; c = c->parent) {
+		excess = res_counter_soft_limit_excess(c);
+		if (max_excess < excess)
+			max_excess = excess;
+	}
+	return __calc_soft_limit_prio(max_excess);
+}
+
+static void __mem_cgroup_requeue(struct mem_cgroup *mem)
+{
+	/* enqueue to softlimit queue */
+	int prio = mem->soft_limit_priority;
+
+	spin_lock(&softlimitq.lock);
+	list_del_init(&mem->soft_limit_anon);
+	list_add_tail(&mem->soft_limit_anon, &softlimitq.queue[prio][SL_ANON]);
+	list_del_init(&mem->soft_limit_file,ist[SL_FILE]);
+	list_add_tail(&mem->soft_limit_file, &softlimitq.queue[prio][SL_FILE]);
+	spin_unlock(&softlimitq.lock);
+}
+
+static void __mem_cgroup_dequeue(struct mem_cgroup *mem)
+{
+	spin_lock(&softlimitq.lock);
+	list_del_init(&mem->soft_limit_anon);
+	list_del_init(&mem->soft_limit_file);
+	spin_unlock(&softlimitq.lock);
+}
+
+static int
+__mem_cgroup_update_soft_limit_cb(struct mem_cgroup *mem, void *data)
+{
+	int priority;
+	/* If someone updates, we don't need more */
+	if (!spin_trylock(&mem->soft_limit_lock))
+		return 0;
+
+	priority = mem_cgroup_soft_limit_prio(mem);
+
+	if (priority != mem->soft_limit_priority) {
+		mem->soft_limit_priority = priority;
+		__mem_cgroup_requeue(mem);
+	}
+	spin_unlock(&mem->soft_limit_lock);
+	return 0;
+}
+
 static void mem_cgroup_update_soft_limit(struct mem_cgroup *mem)
 {
+	int priority;
+
+	/* check status change */
+	priority = mem_cgroup_soft_limit_prio(mem);
+	if (priority != mem->soft_limit_priority) {
+		mem_cgroup_walk_tree(mem, NULL,
+				     __mem_cgroup_update_soft_limit_cb);
+	}
 	return;
 }
 
+static void softlimitq_init(void)
+{
+	int i;
+
+	spin_lock_init(&softlimitq.lock);
+	for (i = 0; i < SLQ_MAXPRIO; i++) {
+		INIT_LIST_HEAD(&softlimitq.queue[i][SL_ANON]);
+		INIT_LIST_HEAD(&softlimitq.queue[i][SL_FILE]);
+	}
+	memcg_softlimit_base = totalram_pages / SLQ_PRIO_FACTOR;
+}
+
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
  * oom-killer can be invoked.
@@ -2527,6 +2638,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (cont->parent == NULL) {
 		enable_swap_cgroup();
 		parent = NULL;
+		softlimitq_init();
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
@@ -2547,6 +2659,10 @@ mem_cgroup_create(struct cgroup_subsys *
 		res_counter_init(&mem->memsw, NULL);
 	}
 	mem->last_scanned_child = 0;
+	mem->soft_limit_priority = 0;
+	INIT_LIST_HEAD(&mem->soft_limit_anon);
+	INIT_LIST_HEAD(&mem->soft_limit_file);
+	spin_lock_init(&mem->soft_limit_lock);
 	spin_lock_init(&mem->reclaim_param_lock);
 
 	if (parent)
@@ -2571,6 +2687,9 @@ static void mem_cgroup_destroy(struct cg
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 
+	spin_lock(&mem->soft_limit_lock);
+	__mem_cgroup_dequeue(mem);
+	spin_unlock(&mem->soft_limit_lock);
 	mem_cgroup_put(mem);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
