Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EB5BA6B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 20:58:45 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C0wheX021513
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 09:58:43 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 007ED45DE4F
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:58:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CCEB645DE50
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:58:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BC4491DB803E
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:58:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DFE6E18001
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:58:42 +0900 (JST)
Date: Thu, 12 Mar 2009 09:57:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/5] memcg per zone softlimit scheduler core
Message-Id: <20090312095720.0dc397dc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch implements per-zone queue for softlimit and adds some
member to memcg.
(This patch adds softlimit_priority but interface to modify this is
 in other patch.)

There are following requirements to implement softlimit.
  - softlimit has to check the whole usage of memcg v.s. softlimit.
  - hierarchy should be handled.
  - Need to know per-zone usage for making a cgroup to be victim.
  - Keeping predictability of behavior by users is important.
  - We want to avoid too much scan and global locks.

Considering above, this patch's softlimit handling concept is
  - Handle softlimit by priority queue
  - Use per-zone priority queue
  - Victim selection algorithm is static priority round robin
  - Prepare 2 lines of queue , Active Queue and Inactive queue.
    If an entry on Active queue doesn't hit condition for softlimit,
    it's moved to Inactive queue.
  - When reschedule_all() is called, Inactive queues are merged to
    Active queue to check all again.

For easy review, user interface etc...is in other patches.

Changelog v2->v3:
 - removed global rwsem.
 - renamed some definitions.
 - fixed problem at memory cgroup is disabled case.
 - almost all comments are rewritten.
 - removed sl_state from per-zone struct. added queue->victim.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |   20 +++
 mm/memcontrol.c            |  232 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 250 insertions(+), 2 deletions(-)

Index: mmotm-2.6.29-Mar10/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Mar10.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Mar10/mm/memcontrol.c
@@ -116,6 +116,9 @@ struct mem_cgroup_per_zone {
 	unsigned long		count[NR_LRU_LISTS];
 
 	struct zone_reclaim_stat reclaim_stat;
+	/* For softlimit per-zone queue. See softlimit handling code. */
+	struct mem_cgroup *mem;
+	struct list_head sl_queue;
 };
 /* Macro for accessing counter */
 #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
@@ -175,7 +178,11 @@ struct mem_cgroup {
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
-
+	/*
+	 * priority of softlimit.
+	 */
+	int softlimit_priority;
+	struct mutex softlimit_mutex;
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -1916,6 +1923,221 @@ int mem_cgroup_force_empty_write(struct 
 	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont), true);
 }
 
+/*
+ * SoftLimit
+ */
+/*
+ * Priority of softlimit. This is a scheduling parameter for softlimit victim
+ * selection logic. Low number is low priority. If priority is maximum, the
+ * cgroup will never be victim at softlimit memory reclaiming.
+ */
+#define SOFTLIMIT_MAXPRI (8)
+
+/* Name of queue for softlimit */
+enum {
+	SLQ_ACTIVE, /* queue for candidates of softlimit victim */
+	SLQ_INACTIVE, /* queue for not-candidates of softlimit victim */
+	SLQ_NUM,
+};
+/*
+ * On this queue, mem_cgroup_per_zone will be enqueued (sl_queue is used.)
+ * mz can take following 4 state.
+ * softlimitq_zone->victim == mz (selected by kswapd) or
+ * on ACTIVE queue (candidates for victim)
+ * on INACTIVE queue (not candidates for victim but prirority is not the highest
+ * out-of-queue (has the maximum priority or on some transition status)
+ */
+struct softlimitq_zone {
+	spinlock_t lock;
+	struct mem_cgroup_per_zone *victim;
+	struct list_head queue[SLQ_NUM][SOFTLIMIT_MAXPRI];
+};
+
+struct softlimitq_node {
+	struct softlimitq_zone zone[MAX_NR_ZONES];
+};
+
+struct softlimitq_node *softlimitq[MAX_NUMNODES];
+
+/* Return queue head for zone */
+static inline struct softlimitq_zone *softlimit_queue(int nid, int zid)
+{
+	return &softlimitq[nid]->zone[zid];
+}
+
+static void __init softlimitq_init(void)
+{
+	struct softlimitq_node *sqn;
+	struct softlimitq_zone *sqz;
+	int nid, zid, i;
+
+	for_each_node_state(nid, N_POSSIBLE) {
+		int tmp = nid;
+
+		if (!node_state(tmp, N_NORMAL_MEMORY))
+			tmp = -1;
+		sqn = kmalloc_node(sizeof(*sqn), GFP_KERNEL, tmp);
+		BUG_ON(!sqn);
+		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+			sqz = &sqn->zone[zid];
+			spin_lock_init(&sqz->lock);
+			sqz->victim = NULL;
+			for (i = 0; i < SOFTLIMIT_MAXPRI;i++) {
+				INIT_LIST_HEAD(&sqz->queue[SLQ_ACTIVE][i]);
+				INIT_LIST_HEAD(&sqz->queue[SLQ_INACTIVE][i]);
+			}
+		}
+		softlimitq[nid] = sqn;
+	}
+}
+
+/*
+ * Add (or remove) all mz of mem_cgroup to the queue. Using open codes to
+ * to handle racy corner case. Called by softlimit_priority user interface.
+ */
+static void memcg_softlimit_requeue(struct mem_cgroup *mem, int prio)
+{
+	int nid, zid;
+
+	/*
+	 * This mutex is for serializing multiple writers to softlimit file...
+	 * pesimistic but necessary for sanity.
+	 */
+	mutex_lock(&mem->softlimit_mutex);
+	mem->softlimit_priority = prio;
+
+	for_each_node_state(nid, N_POSSIBLE) {
+		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+			struct softlimitq_zone *sqz;
+			struct mem_cgroup_per_zone *mz;
+
+			sqz = softlimit_queue(nid, zid);
+			mz = mem_cgroup_zoneinfo(mem, nid, zid);
+			spin_lock(&sqz->lock);
+			/* If now grabbed by kswapd(), nothing to do */
+			if (sqz->victim != mz) {
+				list_del_init(&mz->sl_queue);
+				if (prio < SOFTLIMIT_MAXPRI)
+					list_add_tail(&mz->sl_queue,
+						&sqz->queue[SLQ_ACTIVE][prio]);
+			}
+			spin_unlock(&sqz->lock);
+		}
+	}
+	mutex_unlock(&mem->softlimit_mutex);
+}
+
+/*
+ * Join inactive list to active list to restart schedule and
+ * refresh queue information
+ */
+static void __softlimit_join_queue(int nid, int zid)
+{
+	struct softlimitq_zone *sqz = softlimit_queue(nid, zid);
+	int i;
+
+	spin_lock(&sqz->lock);
+	for (i = 0; i < SOFTLIMIT_MAXPRI; i++)
+		list_splice_tail_init(&sqz->queue[SLQ_INACTIVE][i],
+				      &sqz->queue[SLQ_ACTIVE][i]);
+	spin_unlock(&sqz->lock);
+}
+
+/* Return # of evictable memory in zone */
+static int mz_evictable_usage(struct mem_cgroup_per_zone *mz)
+{
+	long usage = 0;
+
+	if (nr_swap_pages) {
+		usage += MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON);
+		usage += MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
+	}
+	usage += MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE);
+	usage += MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);
+
+	return usage;
+}
+
+struct mem_cgroup *mem_cgroup_schedule(int nid, int zid)
+{
+	struct softlimitq_zone *sqz;
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup *mem, *ret;
+	int prio;
+
+	if (mem_cgroup_disabled())
+		return NULL;
+	sqz = softlimit_queue(nid, zid);
+	ret = NULL;
+	spin_lock(&sqz->lock);
+	for (prio = 0; prio < SOFTLIMIT_MAXPRI; prio++) {
+		if (list_empty(&sqz->queue[SLQ_ACTIVE][prio]))
+			continue;
+		mz = list_first_entry(&sqz->queue[SLQ_ACTIVE][prio],
+				      struct mem_cgroup_per_zone, sl_queue);
+		list_del_init(&mz->sl_queue);
+		/*
+		 * Victim will be selected if
+		 * 1. it has memory in this zone.
+		 * 2. usage is bigger than softlimit
+		 * 3. it's not obsolete.
+		 */
+		if (mz_evictable_usage(mz)) {
+			mem = mz->mem;
+			if (!res_counter_check_under_softlimit(&mem->res)
+			    && css_tryget(&mem->css)) {
+				sqz->victim = mz;
+				ret = mem;
+				break;
+			}
+		}
+		/* This is not a candidate. enqueue this to INACTIVE list */
+		list_add_tail(&mz->sl_queue, &sqz->queue[SLQ_INACTIVE][prio]);
+	}
+	spin_unlock(&sqz->lock);
+	return ret;
+}
+
+/* requeue selected victim */
+void
+mem_cgroup_schedule_end(int nid, int zid, struct mem_cgroup *mem, bool hint)
+{
+	struct mem_cgroup_per_zone *mz;
+	struct softlimitq_zone *sqz;
+	long usage;
+	int prio;
+
+	if (!mem)
+		return;
+
+	sqz = softlimit_queue(nid, zid);
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	spin_lock(&sqz->lock);
+	/* clear information */
+	sqz->victim = NULL;
+	prio = mem->softlimit_priority;
+	/* priority can be changed */
+	if (prio == SOFTLIMIT_MAXPRI)
+		goto out;
+
+	usage = mz_evictable_usage(mz);
+	/* worth to be requeued ? */
+	if (hint)
+		list_add_tail(&mz->sl_queue, &sqz->queue[SLQ_ACTIVE][prio]);
+	else
+		list_add_tail(&mz->sl_queue, &sqz->queue[SLQ_INACTIVE][prio]);
+out:
+	spin_unlock(&sqz->lock);
+	css_put(&mem->css);
+}
+
+void mem_cgroup_reschedule_all(int nid)
+{
+	int zid;
+
+	for (zid = 0; zid < MAX_NR_ZONES; zid++)
+		__softlimit_join_queue(nid, zid);
+}
 
 static u64 mem_cgroup_hierarchy_read(struct cgroup *cont, struct cftype *cft)
 {
@@ -2356,6 +2578,8 @@ static int alloc_mem_cgroup_per_zone_inf
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(l)
 			INIT_LIST_HEAD(&mz->lists[l]);
+		INIT_LIST_HEAD(&mz->sl_queue);
+		mz->mem = mem;
 	}
 	return 0;
 }
@@ -2466,6 +2690,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	/* root ? */
 	if (cont->parent == NULL) {
 		enable_swap_cgroup();
+		softlimitq_init();
 		parent = NULL;
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
@@ -2487,6 +2712,8 @@ mem_cgroup_create(struct cgroup_subsys *
 		res_counter_init(&mem->memsw, NULL);
 	}
 	mem->last_scanned_child = 0;
+	mem->softlimit_priority = SOFTLIMIT_MAXPRI;
+	mutex_init(&mem->softlimit_mutex);
 	spin_lock_init(&mem->reclaim_param_lock);
 
 	if (parent)
@@ -2510,7 +2737,8 @@ static void mem_cgroup_destroy(struct cg
 				struct cgroup *cont)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-
+	/* By calling this with MAXPRI, mz->sl_queue will be removed */
+	memcg_softlimit_requeue(mem, SOFTLIMIT_MAXPRI);
 	mem_cgroup_put(mem);
 }
 
Index: mmotm-2.6.29-Mar10/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.29-Mar10.orig/include/linux/memcontrol.h
+++ mmotm-2.6.29-Mar10/include/linux/memcontrol.h
@@ -117,6 +117,12 @@ static inline bool mem_cgroup_disabled(v
 
 extern bool mem_cgroup_oom_called(struct task_struct *task);
 
+/* softlimit */
+struct mem_cgroup *mem_cgroup_schedule(int nid, int zid);
+void mem_cgroup_schedule_end(int nid, int zid,
+		struct mem_cgroup *mem, bool hint);
+void mem_cgroup_reschedule_all(int nid);
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -264,6 +270,20 @@ mem_cgroup_print_oom_info(struct mem_cgr
 {
 }
 
+struct mem_cgroup *mem_cgroup_schedule(int nid, int zid)
+{
+	return NULL;
+}
+
+void mem_cgroup_schedule_end(int nid, int zid,
+	struct mem_cgroup *mem, bool hint)
+{
+}
+
+void mem_cgroup_reschedule(int nid)
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
