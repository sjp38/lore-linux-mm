Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C29436B00AA
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 04:05:34 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2595TbF008015
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Mar 2009 18:05:29 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 24CE045DE57
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:05:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 027AB45DE51
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:05:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D54791DB8038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:05:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E8951DB803A
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:05:28 +0900 (JST)
Date: Thu, 5 Mar 2009 18:04:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-Id: <20090305180410.a44035e0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090303111244.GP11421@balbir.in.ibm.com>
References: <20090302044043.GC11421@balbir.in.ibm.com>
	<20090302143250.f47758f9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302060519.GG11421@balbir.in.ibm.com>
	<20090302152128.e74f51ef.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302063649.GJ11421@balbir.in.ibm.com>
	<20090302160602.521928a5.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302124210.GK11421@balbir.in.ibm.com>
	<c31ccd23cb41f0f7594b3f56b20f0165.squirrel@webmail-b.css.fujitsu.com>
	<20090302174156.GM11421@balbir.in.ibm.com>
	<20090303085914.555089b1.kamezawa.hiroyu@jp.fujitsu.com>
	<20090303111244.GP11421@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Mar 2009 16:42:44 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > I wrote
> > ==
> >  if (victim is not over soft-limit)
> > ==
> > ....Maybe this discussion style is bad and I should explain my approach in patch.
> > (I can't write code today, sorry.)
> > 

This is an example of my direction, " do it lazy" softlimit.

Maybe this is not perfect but this addresses almost all my concern.
I hope this will be an input for you.
I didn't divide patch into small pieces intentionally to show a big picture.
Thanks,
-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

An example patch. Don't trust me, this patch may have bugs.

Memory Cgroup Softlimit support(Yet another one)

 memory cgroup accounts and limits usage of memory in the system but it
 don't care of NUMA memory usage. Cpuset can be a help for NUMA user but
 for usual users, it's better easy knob to control "how to avoid memory
 shortage".
 When the user sets softlimit to cgroup, kswapd() checks victim
 groups which has usage over softlimit at first and reclaim memory from them.

 Victim selection condition is
	if (memcg is over its softlimit && it has pages in zone)
 Select Algorithm is Round-Robin.
 And if priority goes high(means small.), this softlimit logic will not work
 and memory cgroup will not disturb kswapd.

 All information is maintained per node and there are no global locks.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |   16 +++
 mm/memcontrol.c            |  215 +++++++++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c                |   36 +++++++
 3 files changed, 259 insertions(+), 8 deletions(-)

Index: mmotm-2.6.29-Mar3/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Mar3.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Mar3/mm/memcontrol.c
@@ -175,12 +175,18 @@ struct mem_cgroup {
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
-
+	/*
+	 * Softlimit information.
+	 */
+	u64 softlimit;
+	nodemask_t softlimit_mask;
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
 	struct mem_cgroup_stat stat;
 };
+static struct mem_cgroup *init_mem_cgroup __read_mostly;
+
 
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
@@ -210,6 +216,8 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 #define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
 
+#define SOFTLIMIT               (0x10)
+
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
@@ -325,16 +333,13 @@ static bool mem_cgroup_is_obsolete(struc
 /*
  * Call callback function against all cgroup under hierarchy tree.
  */
-static int mem_cgroup_walk_tree(struct mem_cgroup *root, void *data,
+static int __mem_cgroup_walk_tree(struct mem_cgroup *root, void *data,
 			  int (*func)(struct mem_cgroup *, void *))
 {
 	int found, ret, nextid;
 	struct cgroup_subsys_state *css;
 	struct mem_cgroup *mem;
 
-	if (!root->use_hierarchy)
-		return (*func)(root, data);
-
 	nextid = 1;
 	do {
 		ret = 0;
@@ -357,6 +362,22 @@ static int mem_cgroup_walk_tree(struct m
 	return ret;
 }
 
+static int mem_cgroup_walk_tree(struct mem_cgroup *root, void *data,
+			  int (*func)(struct mem_cgroup *, void *))
+{
+
+	if (!root->use_hierarchy)
+		return (*func)(root, data);
+
+	return __mem_cgroup_walk_tree(root, data, func);
+}
+
+static int mem_cgroup_walk_all(void *data,
+			       int (*func)(struct mem_cgroup *, void *))
+{
+	return __mem_cgroup_walk_tree(init_mem_cgroup, data, func);
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -1618,6 +1639,168 @@ void mem_cgroup_end_migration(struct mem
 }
 
 /*
+ * Calls for softlimit.
+ */
+/*
+ * When vmscan.c::balance_pgdat() calls this softlimit, A zone in the system
+ * is under memory shortage. We select appropriate victim group..
+ * All calles for softlimit is called by kswapd() per node and each node's
+ * status is independent from others.
+ */
+
+struct softlimit_pernode_info {
+	int last_victim;	    /* ID of mem_cgroup last visited */
+	int count;                  /* # of softlimit reclaim candidates */
+};
+/* Control information per node */
+struct softlimit_pernode_info softlimit_control[MAX_NUMNODES];
+
+static unsigned long
+memcg_evictable_usage(struct mem_cgroup *mem, int nid, int zid)
+{
+	unsigned long total = 0;
+	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
+
+	if (nr_swap_pages) { /* We have swap ? */
+		total += MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
+		total += MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON);
+	}
+	total += MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE);
+	total += MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);
+	return total;
+}
+
+/*
+ * Return true if an ancestor hits its softlimit.
+ */
+static bool memcg_hit_soft_limit(struct mem_cgroup *mem)
+{
+	unsigned long usage;
+	struct cgroup *cgroup;
+
+	do {
+		usage = res_counter_read_u64(&mem->res, RES_USAGE);
+		if (usage > mem->softlimit)
+			return true;
+		cgroup = mem->css.cgroup;
+		if (cgroup->parent) {
+			cgroup = cgroup->parent;
+			mem = mem_cgroup_from_cont(cgroup);
+		} else
+			mem = NULL;
+	} while (mem && mem->use_hierarchy);
+
+	return false;
+}
+
+static int
+__mem_cgroup_update_soft_limit_hint(struct mem_cgroup *mem, void *data)
+{
+	long nid = (long)data;
+	struct softlimit_pernode_info *spi = &softlimit_control[nid];
+	unsigned long usage = 0;
+	int zid;
+
+	/* At first, delete this from candidate.*/
+	node_clear(nid, mem->softlimit_mask);
+
+	/* Calc from High zone is better...*/
+	for (usage = 0, zid = MAX_NR_ZONES - 1;
+	     !usage && zid >= 0;
+	     zid--)
+		usage += memcg_evictable_usage(mem, nid, zid);
+
+	/* This group don't have any evictable page on this node .go to next.*/
+	if (!usage)
+		return 0;
+
+	/* If one of ancestor hits limit, this is reclaim candidate */
+	if (memcg_hit_soft_limit(mem)) {
+		node_set(nid, mem->softlimit_mask);
+		spi->count++;
+	}
+	return 0;
+}
+/*
+ * Calculate hint per appropriate kswapd iteration. Because balance_pgdat()
+ * visits a zone/node several times repeatedly, this hint is helpful for
+ * reducing unnecessary works.
+ */
+void mem_cgroup_update_softlimit_hint(int nid)
+{
+	struct softlimit_pernode_info *spi = &softlimit_control[nid];
+
+	spi->count = 0;
+	/* Visit all and fill per-node hint. */
+	mem_cgroup_walk_all(((void *)(long)nid),
+			    __mem_cgroup_update_soft_limit_hint);
+}
+
+/*
+ * Scan mem_cgroup and return candidate to softlimit-reclaim. Reclaim
+ * information is maintainder per node and this routine checks evictable
+ * usage of memcg in specified zone.
+ * mem->softlimit nodemask is used as a hint to show that reclaiming memory
+ * from this memcg will be help or not.
+ */
+struct mem_cgroup *mem_cgroup_get_victim(int nid, int zid)
+{
+	struct softlimit_pernode_info *spi = &softlimit_control[nid];
+	struct mem_cgroup *ret = NULL;
+	struct mem_cgroup *mem = NULL;
+	int checked, nextid, found;
+	struct cgroup_subsys_state *css;
+	if (spi->count == 0)
+		return NULL;
+
+	checked = 0;
+	while (checked < spi->count) {
+
+		mem = NULL;
+		rcu_read_lock();
+		nextid  = spi->last_victim + 1;
+		css = css_get_next(&mem_cgroup_subsys,
+				   nextid, &init_mem_cgroup->css, &found);
+		if (css && css_tryget(css))
+			mem = container_of(css, struct mem_cgroup, css);
+		rcu_read_unlock();
+
+		if (!css) {
+			spi->last_victim = 0;
+			continue;
+		}
+
+		spi->last_victim = found;
+		if (!mem)
+			continue;
+
+		/* check hint status of this memcg */
+		if (!node_isset(nid, mem->softlimit_mask)) {
+			css_put(css);
+			continue;
+		}
+		checked++;
+
+		if (!memcg_hit_soft_limit(mem)) {
+			/* the hint is obsolete....*/
+			node_clear(nid, mem->softlimit_mask);
+			spi->count--;
+		} else if (memcg_evictable_usage(mem, nid, zid)) {
+			ret = mem;
+			break;
+		}
+		css_put(css);
+	}
+	return ret;
+}
+
+void mem_cgroup_put_victim(struct mem_cgroup *mem)
+{
+	if (mem)
+		css_put(&mem->css);
+}
+
+/*
  * A call to try to shrink memory usage under specified resource controller.
  * This is typically used for page reclaiming for shmem for reducing side
  * effect of page allocation from shmem, which is used by some mem_cgroup.
@@ -1949,7 +2132,10 @@ static u64 mem_cgroup_read(struct cgroup
 	name = MEMFILE_ATTR(cft->private);
 	switch (type) {
 	case _MEM:
-		val = res_counter_read_u64(&mem->res, name);
+		if (name == SOFTLIMIT)
+			val = mem->softlimit;
+		else
+			val = res_counter_read_u64(&mem->res, name);
 		break;
 	case _MEMSWAP:
 		if (do_swap_account)
@@ -1986,6 +2172,12 @@ static int mem_cgroup_write(struct cgrou
 		else
 			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		break;
+	case SOFTLIMIT:
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (ret)
+			break;
+		memcg->softlimit = val;
+		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
 		break;
@@ -2241,6 +2433,12 @@ static struct cftype mem_cgroup_files[] 
 		.read_u64 = mem_cgroup_read,
 	},
 	{
+		.name = "softlimit",
+		.private = MEMFILE_PRIVATE(_MEM, SOFTLIMIT),
+		.read_u64 = mem_cgroup_read,
+		.write_string = mem_cgroup_write,
+	},
+	{
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
@@ -2464,6 +2662,11 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (parent)
 		mem->swappiness = get_swappiness(parent);
 	atomic_set(&mem->refcnt, 1);
+
+	/* Record the root */
+	if (!init_mem_cgroup)
+		init_mem_cgroup = mem;
+
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
Index: mmotm-2.6.29-Mar3/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.29-Mar3.orig/include/linux/memcontrol.h
+++ mmotm-2.6.29-Mar3/include/linux/memcontrol.h
@@ -116,6 +116,10 @@ static inline bool mem_cgroup_disabled(v
 }
 
 extern bool mem_cgroup_oom_called(struct task_struct *task);
+/* SoftLimit stuff */
+extern void mem_cgroup_update_softlimit_hint(int nid);
+extern struct mem_cgroup *mem_cgroup_get_victim(int nid, int zid);
+extern void mem_cgroup_put_victim(struct mem_cgroup *mem);
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
@@ -264,6 +268,18 @@ mem_cgroup_print_oom_info(struct mem_cgr
 {
 }
 
+static inline void mem_cgroup_update_softlimit_hint(int nid)
+{
+}
+
+static inline struct mem_cgroup *mem_cgroup_get_victim(int nid, int zid)
+{
+	return NULL;
+}
+static inline void mem_cgroup_put_victim(struct mem_cgroup *mem)
+{
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
Index: mmotm-2.6.29-Mar3/mm/vmscan.c
===================================================================
--- mmotm-2.6.29-Mar3.orig/mm/vmscan.c
+++ mmotm-2.6.29-Mar3/mm/vmscan.c
@@ -1734,6 +1734,26 @@ unsigned long try_to_free_mem_cgroup_pag
 #endif
 
 /*
+ * When mem_cgroup's softlimit is used, capture kswapd and reclaim in softlimit.
+ * This will be never called when priority is bad.
+ */
+
+void softlimit_shrink_zone(int nid, int zid, int priority, struct zone *zone,
+			      struct scan_control *sc)
+{
+	sc->mem_cgroup = mem_cgroup_get_victim(nid, zid);
+	if (sc->mem_cgroup) {
+		sc->isolate_pages = mem_cgroup_isolate_pages;
+		/* Should we use memcg's swappiness here ? */
+		shrink_zone(priority, zone, sc);
+		mem_cgroup_put_victim(sc->mem_cgroup);
+		sc->mem_cgroup = NULL;
+		sc->isolate_pages = isolate_pages_global;
+	} else
+		shrink_zone(priority, zone, sc);
+}
+
+/*
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at pages_high.
  *
@@ -1758,6 +1778,7 @@ static unsigned long balance_pgdat(pg_da
 {
 	int all_zones_ok;
 	int priority;
+	int nid = pgdat->node_id;
 	int i;
 	unsigned long total_scanned;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
@@ -1785,6 +1806,8 @@ loop_again:
 	for (i = 0; i < pgdat->nr_zones; i++)
 		temp_priority[i] = DEF_PRIORITY;
 
+	mem_cgroup_update_softlimit_hint(nid);
+
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 		unsigned long lru_pages = 0;
@@ -1863,8 +1886,17 @@ loop_again:
 			 * zone has way too many pages free already.
 			 */
 			if (!zone_watermark_ok(zone, order, 8*zone->pages_high,
-						end_zone, 0))
-				shrink_zone(priority, zone, &sc);
+					       end_zone, 0)) {
+				/*
+				 * If priority is not so bad, try softlimit
+				 * of memcg.
+				 */
+				if (!(priority < DEF_PRIORITY - 2))
+					softlimit_shrink_zone(nid, i,
+							 priority, zone, &sc);
+				else
+					shrink_zone(priority, zone, &sc);
+			}
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
