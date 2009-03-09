Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7F6296B00C6
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 03:42:27 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n297gOek012522
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 9 Mar 2009 16:42:24 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C62F645DD82
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:42:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A79B45DD7F
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:42:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F696E08003
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:42:23 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 13D121DB8043
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:42:23 +0900 (JST)
Date: Mon, 9 Mar 2009 16:41:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/4] memcg: softlimit priority and victim scheduler
Message-Id: <20090309164103.73d9b60e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Per-zone queue/scheduler for memory cgroup softlimit.

At handling softlimit, we have to check following 2 points.
  (A) usage on memcg is bigger than softlimit or not.
  (B) memcg has evictable memory on specified zone.

One of design choice is how to call softlimit code. This patch uses
uses kswapd() as a thread for reclaiming memory.
I think this is reasonable. kswapd() is spawned per node.
(The caller itself will be in the next patch.)

Another design choice is "When there are multiple cgroups over softlimit,
which one should be selected."
I added "softlimit_priority" to handle this and implemented static priority
round-robin logic.

>From above, this uses following design.

  1. per-zone schedule queue with priority
  2. scheduling(selection) algorithm is Static Priority Round Robin.
  3. Fortunately, memcg has mem_cgroup_per_zone objects already, Use it
     as scheduling unit.

Initially, memcg has softlimit_priority=SOFTLIMIT_MAXPRIO and it's not queued.
When it is set to some number, it will be added to softlimit queue per zone.

Kswapd() will select the memcg from the top of per-zone queue and check it
satisfies above (A) and (B). If satisfies, memory will be reclaimed from 
selected one and pushed back to tail of CHECK queue. If doesn't, it will be
moved to IGNORE queue.

When kswapd() enters next turn of scanning, IGNORE queue will be merged back
to CHECK queue. (What "next turn" means is another point for discussion..)

(Consideration)
 I wonder we have a chance to implement dynamic-priority scheduling rather than
 static-priority, later. So, priority rage 0-8 is too small ?
 (If no concerns, I'll not increase the range.)

TODO:
 - This patch is more complicated than expected..should be divided...

Changelog: v1->v2
 - totally re-designed.
 - Now, 0 is the lowest, 8 is the highest priority.
 - per-zone queue.
 - Allow kswapd() to pass parameter to requeue this or not.
 - fixed bugs.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |   19 ++
 mm/memcontrol.c            |  324 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 342 insertions(+), 1 deletion(-)

Index: develop/mm/memcontrol.c
===================================================================
--- develop.orig/mm/memcontrol.c
+++ develop/mm/memcontrol.c
@@ -116,6 +116,11 @@ struct mem_cgroup_per_zone {
 	unsigned long		count[NR_LRU_LISTS];
 
 	struct zone_reclaim_stat reclaim_stat;
+	/* For softlimit per-zone queue. See softlimit handling code. */
+	struct mem_cgroup *mem;
+	struct list_head sl_queue;
+	int              sl_state;
+	long             sl_prev_usage;
 };
 /* Macro for accessing counter */
 #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
@@ -179,6 +184,7 @@ struct mem_cgroup {
 	 * Softlimit Params.
 	 */
 	u64		softlimit;
+	int             softlimit_priority;
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -214,6 +220,7 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
 
 #define _MEM_SOFTLIMIT		(0x10)
+#define _MEM_SOFTLIMIT_PRIO	(0x11)
 
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
@@ -1908,12 +1915,131 @@ int mem_cgroup_force_empty_write(struct 
 /*
  * Softlimit Handling.
  */
+/*
+ * Priority of softlimit is a scheduling parameter for kswapd(). 0...is the
+ * lowest priority and 8 is the highest. This value is inherited at create()
+ * if hierarchical accounting is used (use_hierarchy==1). If not, prio is
+ * set to MAXPRIO and it will be ignored.
+ */
+#define SOFTLIMIT_MAXPRIO (8)
+#define SOFTLIMIT_DEFPRIO (0)
+
+/* Name of queue in softlimit_queue_zone */
+enum {
+	SLQ_CHECK,     /* schedulig target queue */
+	SLQ_IGNORE,   /* ignored queue until next reschedule */
+	SLQ_NUM
+};
+/*
+ * Per-zone softlimit queue. mem_cgroup_per_zone struct will be queued.
+ */
+struct softlimit_queue_zone {
+	spinlock_t lock;
+	struct list_head queue[SLQ_NUM][SOFTLIMIT_MAXPRIO];
+};
+
+struct softlimit_queue_node {
+	struct softlimit_queue_zone zone[MAX_NR_ZONES];
+};
+
+struct softlimit_queue_node *softlimit_sched[MAX_NUMNODES];
 
 /*
+ * Write-Locked at setting priority by user-land and new group creation.
+ * (for keeping sanity of hierarchy) in other case, read-locked
+ */
+DECLARE_RWSEM(softlimit_sem);
+
+/* For mz->sl_state */
+enum {
+	MZ_NOT_ON_QUEUE,
+	MZ_ON_QUEUE,
+	MZ_SELECTED,
+};
+
+/*
+ * Returns queue for zone.
+ */
+static inline struct softlimit_queue_zone *softlimit_queue(int nid, int zid)
+{
+	if (softlimit_sched[nid] == NULL)
+		return NULL;
+	return &softlimit_sched[nid]->zone[zid];
+}
+
+/*
+ * Returns # of evictable memory. (i.e, don't include ANON on swap-less system)
+ */
+static long mz_evictable_usage(struct mem_cgroup_per_zone *mz)
+{
+	long usage = 0;
+
+	/* Not necessary to be very precise. We don't take lock here */
+	if (nr_swap_pages) {
+		usage += MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON);
+		usage += MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
+	}
+	usage += MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE);
+	usage += MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);
+	return usage;
+}
+
+/* Now, use static-priority */
+static int mz_softlimit_priority(struct mem_cgroup *mem,
+				struct mem_cgroup_per_zone *mz)
+{
+	return mem->softlimit_priority;
+}
+
+static void memcg_softlimit_dequeue(struct mem_cgroup *mem, int nid, int zid)
+{
+	struct softlimit_queue_zone *sqz = softlimit_queue(nid, zid);
+	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
+
+	spin_lock(&sqz->lock);
+	list_del_init(&mz->sl_queue);
+	mz->sl_state = MZ_NOT_ON_QUEUE;
+	spin_unlock(&sqz->lock);
+}
+
+static void
+memcg_softlimit_enqueue(struct mem_cgroup *mem, int nid, int zid, bool check)
+{
+	struct softlimit_queue_zone *sqz = softlimit_queue(nid, zid);
+	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	int queue = SLQ_CHECK;
+	int prio;
+
+	if (mem->softlimit_priority == SOFTLIMIT_MAXPRIO)
+		return;
+	if (!check)
+		queue = SLQ_IGNORE;
+	spin_lock(&sqz->lock);
+	prio = mz_softlimit_priority(mem, mz);
+	if (mz->sl_state != MZ_ON_QUEUE) {
+		list_add_tail(&mz->sl_queue, &sqz->queue[queue][prio]);
+		mz->sl_state = MZ_ON_QUEUE;
+	}
+	spin_unlock(&sqz->lock);
+}
+
+/* merge inactive queue to the tail of check queue */
+static void memcg_softlimit_rotate(int nid, int zid)
+{
+	struct softlimit_queue_zone *sqz = softlimit_queue(nid, zid);
+	int i;
+
+	spin_lock(&sqz->lock);
+	for (i = 0; i < SOFTLIMIT_MAXPRIO; i++)
+		list_splice_tail_init(&sqz->queue[SLQ_IGNORE][i],
+				      &sqz->queue[SLQ_CHECK][i]);
+	spin_unlock(&sqz->lock);
+}
+/*
  * A group under hierarchy has to check all ancestors.
  * css's refcnt of "mem" should be in caller.
  */
-static bool mem_cgroup_hit_softlimit(struct mem_cgroup *mem, void *data)
+static bool mem_cgroup_hit_softlimit(struct mem_cgroup *mem)
 {
 	struct mem_cgroup *tmp = mem;
 	struct cgroup *cg;
@@ -1932,12 +2058,174 @@ static bool mem_cgroup_hit_softlimit(str
 	return false;
 }
 
+static int __mem_cgroup_resize_softlimit(struct mem_cgroup *mem, void *data)
+{
+	int nid;
+	int zid;
+
+	/* softlimit_priority will not change under us. */
+	if (mem->softlimit_priority >= SOFTLIMIT_MAXPRIO)
+		goto out;
+	/* Add mz to queue if never enqueued */
+	for_each_node_state(nid, N_POSSIBLE) {
+		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+			struct mem_cgroup_per_zone *mz;
+			/*
+			 * We are under semaphore and this check before
+			 * taking lock is safe
+			 */
+			mz = mem_cgroup_zoneinfo(mem, nid, zid);
+			if (mz->sl_state == MZ_NOT_ON_QUEUE)
+				memcg_softlimit_enqueue(mem, nid, zid, true);
+		}
+	}
+out:
+	return 0;
+}
+
 static int mem_cgroup_resize_softlimit(struct mem_cgroup *mem, u64 val)
 {
+
+	down_read(&softlimit_sem);
 	mem->softlimit = val;
+	mem_cgroup_walk_tree(mem, NULL, __mem_cgroup_resize_softlimit);
+	up_read(&softlimit_sem);
 	return 0;
 }
 
+static int mem_cgroup_set_softlimit_priority(struct mem_cgroup *mem, int prio)
+{
+	int nid, zid;
+
+	down_write(&softlimit_sem);
+	if (mem->softlimit_priority < SOFTLIMIT_MAXPRIO) {
+		for_each_node_state(nid, N_POSSIBLE)
+			for (zid = 0; zid < MAX_NR_ZONES; zid++)
+				memcg_softlimit_dequeue(mem, nid, zid);
+	}
+	mem->softlimit_priority = prio;
+	if (mem->softlimit_priority < SOFTLIMIT_MAXPRIO) {
+		for_each_node_state(nid, N_POSSIBLE)
+			for (zid = 0; zid < MAX_NR_ZONES; zid++)
+				memcg_softlimit_enqueue(mem, nid, zid, true);
+	}
+
+	up_write(&softlimit_sem);
+	return 0;
+}
+
+/*
+ * Called by kswapd() and returns victim group to be reclaimed. Used algorithm
+ * is Static-Priority Round Robin against cgroups which hits softlimit.
+ * If cgroup is found to be not candidate, it will be linked to INACTIVE queue.
+ */
+struct mem_cgroup *mem_cgroup_schedule(int nid, int zid)
+{
+	struct mem_cgroup *ret = NULL;
+	struct mem_cgroup_per_zone *mz;
+	struct softlimit_queue_zone *sqz = softlimit_queue(nid, zid);
+	long usage;
+	int prio;
+
+	/* avoid balance_pgdat() starvation */
+	if (!down_read_trylock(&softlimit_sem))
+		return NULL;
+	spin_lock(&sqz->lock);
+	for (prio = 0; !ret && (prio < SOFTLIMIT_MAXPRIO); prio++) {
+		while (!list_empty(&sqz->queue[SLQ_CHECK][prio])) {
+			/* Pick up the first entry */
+			mz = list_first_entry(&sqz->queue[SLQ_CHECK][prio],
+					      struct mem_cgroup_per_zone,
+					      sl_queue);
+			list_del_init(&mz->sl_queue);
+			/*
+			 * For avoiding alloc() v.s. free() war, usage below
+			 * threshold is ignored.
+			 */
+			usage = mz_evictable_usage(mz);
+			if (usage) {
+				struct mem_cgroup *mem = mz->mem;
+				if (mem_cgroup_hit_softlimit(mem) &&
+				    css_tryget(&mem->css)) {
+					mz->sl_state = MZ_SELECTED;
+					mz->sl_prev_usage = usage;
+					ret = mem;
+					break;
+				}
+			}
+			/* move to INACTIVE queue */
+			list_add_tail(&mz->sl_queue,
+				      &sqz->queue[SLQ_IGNORE][prio]);
+		}
+	}
+	spin_unlock(&sqz->lock);
+	up_read(&softlimit_sem);
+
+	return ret;
+}
+
+void mem_cgroup_schedule_end(int nid, int zid, struct mem_cgroup *mem,
+			     bool requeue)
+{
+	struct mem_cgroup_per_zone *mz;
+	long usage;
+
+	if (!mem)
+		return;
+	/* mem->softlimit_priority will not change under this */
+	down_read(&softlimit_sem);
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	usage = mz_evictable_usage(mz);
+	/* Worth to be requeued ? */
+	if (requeue && (usage > SWAP_CLUSTER_MAX))
+		/* Move back to the ACTIVE queue of priority */
+		memcg_softlimit_enqueue(mem, nid, zid, true);
+	else /* Not enough page or Recaliming was not good. */
+		memcg_softlimit_enqueue(mem, nid, zid, false);
+	up_read(&softlimit_sem);
+	/* put refcnt from mem_cgroup_schedule() */
+	css_put(&mem->css);
+}
+
+/* Called by kswapd() once per calling balance_pgdat() */
+void mem_cgroup_reschedule(int nid)
+{
+	int zid;
+
+	/* mem->softlimit_priority will not change under this */
+	down_read(&softlimit_sem);
+	for (zid = 0; zid < MAX_NR_ZONES; zid++)
+		memcg_softlimit_rotate(nid, zid);
+	up_read(&softlimit_sem);
+}
+
+/* Called at first call to mem_cgroup_create() */
+static void __init softlimit_init(void)
+{
+	int zid, i, node, tmp;
+
+	for_each_node_state(node, N_POSSIBLE) {
+		struct softlimit_queue_node *sqn;
+
+		tmp = node;
+		if (!node_state(node, N_NORMAL_MEMORY))
+			tmp = -1;
+		sqn = kmalloc_node(sizeof(*sqn), GFP_KERNEL, tmp);
+		BUG_ON(!sqn);
+
+		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+			struct softlimit_queue_zone *sqz = &sqn->zone[zid];
+
+			spin_lock_init(&sqz->lock);
+			for (i = 0; i < SOFTLIMIT_MAXPRIO; i++) {
+				INIT_LIST_HEAD(&sqz->queue[SLQ_CHECK][i]);
+				INIT_LIST_HEAD(&sqz->queue[SLQ_IGNORE][i]);
+			}
+		}
+		softlimit_sched[node] = sqn;
+	}
+}
+
 
 static u64 mem_cgroup_hierarchy_read(struct cgroup *cont, struct cftype *cft)
 {
@@ -1977,6 +2265,16 @@ static int mem_cgroup_hierarchy_write(st
 	return retval;
 }
 
+static int mem_cgroup_softlimit_priority_write(struct cgroup *cgrp,
+					       struct cftype *cft,
+					       u64 val)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	if (val > SOFTLIMIT_MAXPRIO)
+		return -EINVAL;
+	return mem_cgroup_set_softlimit_priority(mem, val);
+}
+
 static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
@@ -1991,6 +2289,9 @@ static u64 mem_cgroup_read(struct cgroup
 		case _MEM_SOFTLIMIT:
 			val = mem->softlimit;
 			break;
+		case _MEM_SOFTLIMIT_PRIO:
+			val = mem->softlimit_priority;
+			break;
 		default:
 			val = res_counter_read_u64(&mem->res, name);
 			break;
@@ -2292,6 +2593,12 @@ static struct cftype mem_cgroup_files[] 
 		.read_u64 = mem_cgroup_read,
 	},
 	{
+		.name = "softlimit_priority",
+		.private = MEMFILE_PRIVATE(_MEM, _MEM_SOFTLIMIT_PRIO),
+		.write_u64 = mem_cgroup_softlimit_priority_write,
+		.read_u64 = mem_cgroup_read,
+	},
+	{
 		.name = "failcnt",
 		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
 		.trigger = mem_cgroup_reset,
@@ -2385,12 +2692,19 @@ static int alloc_mem_cgroup_per_zone_inf
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(l)
 			INIT_LIST_HEAD(&mz->lists[l]);
+		mz->mem = mem;
+		INIT_LIST_HEAD(&mz->sl_queue);
+		mz->sl_state = MZ_NOT_ON_QUEUE;
 	}
 	return 0;
 }
 
 static void free_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 {
+	int zid;
+	for (zid = 0; zid < MAX_NR_ZONES; zid++)
+		memcg_softlimit_dequeue(mem, node, zid);
+
 	kfree(mem->info.nodeinfo[node]);
 }
 
@@ -2495,12 +2809,14 @@ mem_cgroup_create(struct cgroup_subsys *
 	/* root ? */
 	if (cont->parent == NULL) {
 		enable_swap_cgroup();
+		softlimit_init();
 		parent = NULL;
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
 	}
 
+	down_write(&softlimit_sem);
 	if (parent && parent->use_hierarchy) {
 		res_counter_init(&mem->res, &parent->res);
 		res_counter_init(&mem->memsw, &parent->memsw);
@@ -2511,9 +2827,11 @@ mem_cgroup_create(struct cgroup_subsys *
 		 * mem_cgroup(see mem_cgroup_put).
 		 */
 		mem_cgroup_get(parent);
+		mem->softlimit_priority = parent->softlimit_priority;
 	} else {
 		res_counter_init(&mem->res, NULL);
 		res_counter_init(&mem->memsw, NULL);
+		mem->softlimit_priority = SOFTLIMIT_MAXPRIO;
 	}
 	mem->last_scanned_child = 0;
 	spin_lock_init(&mem->reclaim_param_lock);
@@ -2521,6 +2839,10 @@ mem_cgroup_create(struct cgroup_subsys *
 
 	if (parent)
 		mem->swappiness = get_swappiness(parent);
+
+	/* add to softlimit queue if necessary */
+	__mem_cgroup_resize_softlimit(mem, NULL);
+	up_write(&softlimit_sem);
 	atomic_set(&mem->refcnt, 1);
 	return &mem->css;
 free_out:
Index: develop/include/linux/memcontrol.h
===================================================================
--- develop.orig/include/linux/memcontrol.h
+++ develop/include/linux/memcontrol.h
@@ -117,6 +117,12 @@ static inline bool mem_cgroup_disabled(v
 
 extern bool mem_cgroup_oom_called(struct task_struct *task);
 
+/* For Softlimit Handler */
+extern struct mem_cgroup *mem_cgroup_schedule(int nid, int zid);
+extern void
+mem_cgroup_schedule_end(int nid, int zid, struct mem_cgroup *mem, bool requeue);
+extern void mem_cgroup_reschedule(int nid);
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -264,6 +270,19 @@ mem_cgroup_print_oom_info(struct mem_cgr
 {
 }
 
+/* For Softlimit Handler */
+static inline struct mem_cgroup *mem_cgroup_schedule(int nid, int zid)
+{
+	return NULL;
+}
+static inline void
+mem_cgroup_schedule_end(int nid, int zid, struct mem_cgroup *mem, bool requeue)
+{
+}
+static inline void mem_cgroup_reschedule(int nid)
+{
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
