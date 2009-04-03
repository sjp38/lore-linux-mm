Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CFEC16B004D
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 04:18:46 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n338J2PR005448
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Apr 2009 17:19:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A134345DD7E
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:19:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F12945DD78
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:19:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 56C631DB803F
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:19:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C6091DB803C
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:19:02 +0900 (JST)
Date: Fri, 3 Apr 2009 17:17:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 8/9] lru reordering
Message-Id: <20090403171735.7a048a25.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch adds a function to change the LRU order of pages in global LRU
under control of memcg's victim of soft limit.

FILE and ANON victim is divided and LRU rotation will be done independently.
(memcg which only includes FILE cache or ANON can exists.)

This patch removes finds specfied number of pages from memcg's LRU and
move it to top of global LRU. They will be the first target of shrink_xxx_list.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |   15 ++++++++++
 mm/memcontrol.c            |   67 +++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |   18 +++++++++++-
 3 files changed, 99 insertions(+), 1 deletion(-)

Index: softlimit-test2/include/linux/memcontrol.h
===================================================================
--- softlimit-test2.orig/include/linux/memcontrol.h
+++ softlimit-test2/include/linux/memcontrol.h
@@ -117,6 +117,9 @@ static inline bool mem_cgroup_disabled(v
 
 extern bool mem_cgroup_oom_called(struct task_struct *task);
 
+void mem_cgroup_soft_limit_reorder_lru(struct zone *zone,
+			       unsigned long nr_to_scan, enum lru_list l);
+int mem_cgroup_soft_limit_inactive_anon_is_low(struct zone *zone);
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -264,6 +267,18 @@ mem_cgroup_print_oom_info(struct mem_cgr
 {
 }
 
+static inline void
+mem_cgroup_soft_limit_reorder_lru(struct zone *zone, unsigned long nr_to_scan,
+				  enum lru_list lru);
+{
+}
+
+static inline
+int mem_cgroup_soft_limit_inactive_anon_is_low(struct zone *zone)
+{
+	return 0;
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
Index: softlimit-test2/mm/memcontrol.c
===================================================================
--- softlimit-test2.orig/mm/memcontrol.c
+++ softlimit-test2/mm/memcontrol.c
@@ -1257,6 +1257,73 @@ static struct mem_cgroup *get_soft_limit
 	return ret;
 }
 
+/*
+ * zone->lru and memcg's lru is synchronous under zone->lock.
+ * This tries to rotate pages in specfied LRU.
+ */
+void mem_cgroup_soft_limit_reorder_lru(struct zone *zone,
+				      unsigned long nr_to_scan,
+				      enum lru_list l)
+{
+	struct mem_cgroup *mem;
+	struct mem_cgroup_per_zone *mz;
+	int nid, zid, file;
+	unsigned long scan, flags;
+	struct list_head *src;
+	LIST_HEAD(found);
+	struct page_cgroup *pc;
+	struct page *page;
+
+	nid = zone->zone_pgdat->node_id;
+	zid = zone_idx(zone);
+
+	file = is_file_lru(l);
+
+	mem = get_soft_limit_victim(zone, file);
+	if (!mem)
+		return;
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	src = &mz->lists[l];
+	scan = 0;
+
+	/* Find at most nr_to_scan pages from local LRU */
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	list_for_each_entry_reverse(pc, src, lru) {
+		if (scan >= nr_to_scan)
+			break;
+		/* We don't check Used bit */
+		page = pc->page;
+		/* Can happen ? */
+		if (unlikely(!PageLRU(page)))
+			continue;
+		/* This page is on (the same) LRU */
+		list_move(&page->lru, &found);
+		scan++;
+	}
+	/* vmscan searches pages from lru->prev. link this to lru->prev. */
+	list_splice_tail(&found, &zone->lru[l].list);
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
+
+	/* When we cannot fill the request, check we should forget this cache
+	   or not */
+	if (scan < nr_to_scan &&
+	    !is_active_lru(l) &&
+	    mem_cgroup_usage(mem, zone, file) < SWAP_CLUSTER_MAX)
+		slc_reset_cache_ticket(file);
+}
+
+/* Returns 1 if soft limit is active && memcg's zone's status is that */
+int mem_cgroup_soft_limit_inactive_anon_is_low(struct zone *zone)
+{
+	struct soft_limit_cache *slc;
+	int ret = 0;
+
+	slc = &get_cpu_var(soft_limit_cache);
+	if (slc->mem[SL_ANON])
+		ret = mem_cgroup_inactive_anon_is_low(slc->mem[SL_ANON], zone);
+	put_cpu_var(soft_limit_cache);
+	return ret;
+}
 
 static void softlimitq_init(void)
 {
Index: softlimit-test2/mm/vmscan.c
===================================================================
--- softlimit-test2.orig/mm/vmscan.c
+++ softlimit-test2/mm/vmscan.c
@@ -1066,6 +1066,13 @@ static unsigned long shrink_inactive_lis
 	pagevec_init(&pvec, 1);
 
 	lru_add_drain();
+	if (scanning_global_lru(sc)) {
+		enum lru_list l = LRU_INACTIVE_ANON;
+		if (file)
+			l = LRU_INACTIVE_FILE;
+		mem_cgroup_soft_limit_reorder_lru(zone, max_scan, l);
+	}
+
 	spin_lock_irq(&zone->lru_lock);
 	do {
 		struct page *page;
@@ -1233,6 +1240,13 @@ static void shrink_active_list(unsigned 
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
 	lru_add_drain();
+	if (scanning_global_lru(sc)) {
+		enum lru_list l = LRU_ACTIVE_ANON;
+		if (file)
+			l = LRU_ACTIVE_FILE;
+		mem_cgroup_soft_limit_reorder_lru(zone, nr_pages, l);
+	}
+
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = sc->isolate_pages(nr_pages, &l_hold, &pgscanned, sc->order,
 					ISOLATE_ACTIVE, zone,
@@ -1328,7 +1342,9 @@ static int inactive_anon_is_low_global(s
 
 	if (inactive * zone->inactive_ratio < active)
 		return 1;
-
+	/* check soft limit vicitm's status */
+	if (mem_cgroup_soft_limit_inactive_anon_is_low(zone))
+		return 1;
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
