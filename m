Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AD0076B004D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 05:40:16 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2H9eEJF017649
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Mar 2009 18:40:14 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A94AF45DE4F
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 18:40:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EE0C45DE53
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 18:40:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C892E08014
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 18:40:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D22071DB8013
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 18:40:12 +0900 (JST)
Date: Tue, 17 Mar 2009 18:38:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memcg: handle swapcache leak
Message-Id: <20090317183850.67c35b27.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090317162950.70c1245c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
	<20090317143903.a789cf57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317151113.79a3cc9d.nishimura@mxp.nes.nec.co.jp>
	<20090317162950.70c1245c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Mar 2009 16:29:50 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Give me time, I'll find a fix.
> 
Fowlling is  a result of quick hack, *not* tested.

but how this looks ? (please ignore garbage..)

==
---
 include/linux/page_cgroup.h |   13 ++++
 mm/memcontrol.c             |  140 +++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 146 insertions(+), 7 deletions(-)

Index: mmotm-2.6.29-Mar13/include/linux/page_cgroup.h
===================================================================
--- mmotm-2.6.29-Mar13.orig/include/linux/page_cgroup.h
+++ mmotm-2.6.29-Mar13/include/linux/page_cgroup.h
@@ -26,6 +26,7 @@ enum {
 	PCG_LOCK,  /* page cgroup is locked */
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
+	PCG_ORPHAN, /* this is not used from memcg:s view but on global LRU */
 };
 
 #define TESTPCGFLAG(uname, lname)			\
@@ -40,12 +41,24 @@ static inline void SetPageCgroup##uname(
 static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
 	{ clear_bit(PCG_##lname, &pc->flags);  }
 
+#define TESTSETPCGFLAG(uname, lname) \
+static inline int TestSetPageCgroup##uname(struct page_cgroup *pc) \
+        { return test_and_set_bit(PCG_##lname, &pc->flags);}
+
+#define TESTCLEARPCGFLAG(uname, lname) \
+static inline int TestClearPageCgroup##uname(struct page_cgroup *pc) \
+        { return test_and_clear_bit(PCG_##lname, &pc->flags);}
+
 /* Cache flag is set only once (at allocation) */
 TESTPCGFLAG(Cache, CACHE)
 
 TESTPCGFLAG(Used, USED)
 CLEARPCGFLAG(Used, USED)
 
+TESTSETPCGFLAG(Orphan, ORPHAN)
+TESTCLEARPCGFLAG(Orphan, ORPHAN)
+
+
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);
Index: mmotm-2.6.29-Mar13/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Mar13.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Mar13/mm/memcontrol.c
@@ -204,11 +204,29 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 };
 
 /* for encoding cft->private value on file */
-#define _MEM			(0)
-#define _MEMSWAP		(1)
-#define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
-#define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
-#define MEMFILE_ATTR(val)	((val) & 0xffff)
+#define _MEM                   (0)
+#define _MEMSWAP               (1)
+#define MEMFILE_PRIVATE(x, val)        (((x) << 16) | (val))
+#define MEMFILE_TYPE(val)      (((val) >> 16) & 0xffff)
+#define MEMFILE_ATTR(val)      ((val) & 0xffff)
+
+/* for orphan page_cgroups, guarded by zone->lock. */
+struct orphan_pcg_list {
+	struct list_head zone[MAX_NR_ZONES];
+};
+struct orphan_pcg_list *orphan_list[MAX_NUMNODES];
+atomic_t num_orphan_pages;
+
+static inline struct list_head *orphan_lru(int nid, int zid)
+{
+	/*
+	 * to kick this BUG_ON(), swapcache must be generated while init.
+	 * or NID should be invalid.
+	 */
+	BUG_ON(!orphan_list[nid]);
+	return  &orphan_list[nid]->zone[zid];
+}
+
 
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
@@ -380,6 +398,14 @@ void mem_cgroup_del_lru_list(struct page
 	if (mem_cgroup_disabled())
 		return;
 	pc = lookup_page_cgroup(page);
+	/*
+	 * If the page is SwapCache and already on global LRU, it will be on
+	 * orphan list. remove here
+	 */
+	if (unlikely(PageSwapCache(page) && TestClearPageCgroupOrphan(pc))) {
+		list_del_init(&pc->lru);
+		atomic_dec(&num_orphan_pages);
+	}
 	/* can happen while we handle swapcache. */
 	if (list_empty(&pc->lru) || !pc->mem_cgroup)
 		return;
@@ -414,7 +440,7 @@ void mem_cgroup_rotate_lru_list(struct p
 	 */
 	smp_rmb();
 	/* unused page is not rotated. */
-	if (!PageCgroupUsed(pc))
+	if (unlikely(!PageCgroupUsed(pc)))
 		return;
 	mz = page_cgroup_zoneinfo(pc);
 	list_move(&pc->lru, &mz->lists[lru]);
@@ -433,8 +459,15 @@ void mem_cgroup_add_lru_list(struct page
 	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
 	 */
 	smp_rmb();
-	if (!PageCgroupUsed(pc))
+	if (unlikely(!PageCgroupUsed(pc))) {
+		if (PageSwapCache(page) && !TestSetPageCgroupOrphan(pc)) {
+			struct list_head *lru;
+			lru = orphan_lru(page_to_nid(page), page_zonenum(page));
+			list_add_tail(&pc->lru, lru);
+			atomic_inc(&num_orphan_pages);
+		}
 		return;
+	}
 
 	mz = page_cgroup_zoneinfo(pc);
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
@@ -784,6 +817,95 @@ static int mem_cgroup_count_children(str
 	return num;
 }
 
+
+
+/* Using big number here for avoiding to free swap-cache of readahead. */
+#define CHECK_ORPHAN_THRESH  (4096)
+
+static __init void init_orphan_lru(void)
+{
+	struct orphan_pcg_list *opl;
+	int nid, zid;
+
+	for_each_node_state(nid, N_POSSIBLE) {
+		opl = kmalloc(sizeof(struct orphan_pcg_list),  GFP_KERNEL);
+		BUG_ON(!opl);
+		for (zid = 0; zid < MAX_NR_ZONES; zid++)
+			INIT_LIST_HEAD(&opl->zone[zid]);
+		orphan_list[nid] = opl;
+	}
+}
+/* 
+ * In usual, *unused* swap cache are reclaimed by global LRU. But, if no one
+ * kicks global LRU, they will not be reclaimed. When using memcg, it's trouble.
+ */
+static int drain_orphan_swapcaches(int nid, int zid)
+{
+	struct page_cgroup *pc;
+	struct zone *zone;
+	struct page *page;
+	struct list_head *lru = orphan_lru(nid, zid);
+	unsigned long flags;
+	int drain, scan;
+
+	zone = &NODE_DATA(nid)->node_zones[zid];
+	/* check one by one */
+	scan = 0;
+	drain = 0;
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	while (!list_empty(lru) && (scan < SWAP_CLUSTER_MAX*2)) {
+		scan++;
+		pc = list_entry(lru->next, struct page_cgroup, lru);
+		page = pc->page;
+		/* Rotate */
+		list_del(&pc->lru);
+		list_add_tail(&pc->lru, lru);
+		/* get page for isolate_lru_page() */
+		if (get_page_unless_zero(page)) {
+			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			if (!isolate_lru_page(page)) {
+				/* This page is not ON LRU */
+				if (trylock_page(page)) {
+					drain += try_to_free_swap(page);
+					unlock_page(page);
+				}
+				putback_lru_page(page);
+			}
+			put_page(page);
+			spin_lock_irqsave(&zone->lru_lock, flags);		
+		}
+	}
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
+
+	return drain;
+}
+
+static int last_visit;
+void check_stale_swapcaches(void)
+{
+	int nid, zid, drain;
+	
+	nid = last_visit;
+	drain = 0;
+	
+	if (atomic_read(&num_orphan_pages) < CHECK_ORPHAN_THRESH)
+		return;
+		
+again:
+	nid = next_node(nid, node_states[N_HIGH_MEMORY]);
+	if (nid == MAX_NUMNODES) {
+		nid = 0;
+		if (!node_state(nid, N_HIGH_MEMORY))
+			goto again;
+	}
+	last_visit = nid;
+
+	for (zid = 0; !drain && zid < MAX_NR_ZONES; zid++)
+		drain += drain_orphan_swapcaches(nid, zid);
+}
+
+
+
 /*
  * Visit the first child (need not be the first child as per the ordering
  * of the cgroup list, since we track last_scanned_child) of @mem and use
@@ -842,6 +964,9 @@ static int mem_cgroup_hierarchical_recla
 	int ret, total = 0;
 	int loop = 0;
 
+	if (vm_swap_full())
+		check_stale_swapcaches();
+
 	while (loop < 2) {
 		victim = mem_cgroup_select_victim(root_mem);
 		if (victim == root_mem)
@@ -2454,6 +2579,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	/* root ? */
 	if (cont->parent == NULL) {
 		enable_swap_cgroup();
+		init_orphan_lru();
 		parent = NULL;
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
