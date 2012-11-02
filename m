Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 321A46B004D
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 21:28:13 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so5467092ied.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2012 18:28:12 -0700 (PDT)
Date: Thu, 1 Nov 2012 18:28:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] memcg: fix hotplugged memory zone oops
In-Reply-To: <20121018220306.GA1739@cmpxchg.org>
Message-ID: <alpine.LNX.2.00.1211011822190.20048@eggly.anvils>
References: <505187D4.7070404@cn.fujitsu.com> <20120913205935.GK1560@cmpxchg.org> <alpine.LSU.2.00.1209131816070.1908@eggly.anvils> <507CF789.6050307@cn.fujitsu.com> <alpine.LSU.2.00.1210181129180.2137@eggly.anvils> <20121018220306.GA1739@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Wen Congyang <wency@cn.fujitsu.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Jiang Liu <liuj97@gmail.com>, mhocko@suse.cz, bsingharora@gmail.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, paul.gortmaker@windriver.com, Tang Chen <tangchen@cn.fujitsu.com>

When MEMCG is configured on (even when it's disabled by boot option),
when adding or removing a page to/from its lru list, the zone pointer
used for stats updates is nowadays taken from the struct lruvec.
(On many configurations, calculating zone from page is slower.)

But we have no code to update all the lruvecs (per zone, per memcg)
when a memory node is hotadded.  Here's an extract from the oops which
results when running numactl to bind a program to a newly onlined node:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000f60
IP: [<ffffffff811870b9>] __mod_zone_page_state+0x9/0x60
PGD 0 
Oops: 0000 [#1] SMP 
CPU 2 
Pid: 1219, comm: numactl Not tainted 3.6.0-rc5+ #180 Bochs Bochs
Process numactl (pid: 1219, threadinfo ffff880039abc000, task ffff8800383c4ce0)
Stack:
 ffff880039abdaf8 ffffffff8117390f ffff880039abdaf8 000000008167c601
 ffffffff81174162 ffff88003a480f00 0000000000000001 ffff8800395e0000
 ffff88003dbd0e80 0000000000000282 ffff880039abdb48 ffffffff81174181
Call Trace:
 [<ffffffff8117390f>] __pagevec_lru_add_fn+0xdf/0x140
 [<ffffffff81174181>] pagevec_lru_move_fn+0xb1/0x100
 [<ffffffff811741ec>] __pagevec_lru_add+0x1c/0x30
 [<ffffffff81174383>] lru_add_drain_cpu+0xa3/0x130
 [<ffffffff8117443f>] lru_add_drain+0x2f/0x40
 ...

The natural solution might be to use a memcg callback whenever memory
is hotadded; but that solution has not been scoped out, and it happens
that we do have an easy location at which to update lruvec->zone.  The
lruvec pointer is discovered either by mem_cgroup_zone_lruvec() or by
mem_cgroup_page_lruvec(), and both of those do know the right zone.

So check and set lruvec->zone in those; and remove the inadequate
attempt to set lruvec->zone from lruvec_init(), which is called
before NODE_DATA(node) has been allocated in such cases.

Ah, there was one exceptionr.  For no particularly good reason,
mem_cgroup_force_empty_list() has its own code for deciding lruvec.
Change it to use the standard mem_cgroup_zone_lruvec() and
mem_cgroup_get_lru_size() too.  In fact it was already safe against
such an oops (the lru lists in danger could only be empty),
but we're better proofed against future changes this way.

Reported-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: stable@vger.kernel.org
---
I've marked this for stable (3.6) since we introduced the problem
in 3.5 (now closed to stable); but I have no idea if this is the
only fix needed to get memory hotadd working with memcg in 3.6,
and received no answer when I enquired twice before.

 include/linux/mmzone.h |    2 -
 mm/memcontrol.c        |   46 +++++++++++++++++++++++++++++----------
 mm/mmzone.c            |    6 -----
 mm/page_alloc.c        |    2 -
 4 files changed, 38 insertions(+), 18 deletions(-)

--- 3.7-rc3/include/linux/mmzone.h	2012-10-14 16:16:57.665308933 -0700
+++ linux/include/linux/mmzone.h	2012-11-01 14:31:04.284185741 -0700
@@ -752,7 +752,7 @@ extern int init_currently_empty_zone(str
 				     unsigned long size,
 				     enum memmap_context context);
 
-extern void lruvec_init(struct lruvec *lruvec, struct zone *zone);
+extern void lruvec_init(struct lruvec *lruvec);
 
 static inline struct zone *lruvec_zone(struct lruvec *lruvec)
 {
--- 3.7-rc3/mm/memcontrol.c	2012-10-14 16:16:58.341309118 -0700
+++ linux/mm/memcontrol.c	2012-11-01 14:31:04.284185741 -0700
@@ -1055,12 +1055,24 @@ struct lruvec *mem_cgroup_zone_lruvec(st
 				      struct mem_cgroup *memcg)
 {
 	struct mem_cgroup_per_zone *mz;
+	struct lruvec *lruvec;
 
-	if (mem_cgroup_disabled())
-		return &zone->lruvec;
+	if (mem_cgroup_disabled()) {
+		lruvec = &zone->lruvec;
+		goto out;
+	}
 
 	mz = mem_cgroup_zoneinfo(memcg, zone_to_nid(zone), zone_idx(zone));
-	return &mz->lruvec;
+	lruvec = &mz->lruvec;
+out:
+	/*
+	 * Since a node can be onlined after the mem_cgroup was created,
+	 * we have to be prepared to initialize lruvec->zone here;
+	 * and if offlined then reonlined, we need to reinitialize it.
+	 */
+	if (unlikely(lruvec->zone != zone))
+		lruvec->zone = zone;
+	return lruvec;
 }
 
 /*
@@ -1087,9 +1099,12 @@ struct lruvec *mem_cgroup_page_lruvec(st
 	struct mem_cgroup_per_zone *mz;
 	struct mem_cgroup *memcg;
 	struct page_cgroup *pc;
+	struct lruvec *lruvec;
 
-	if (mem_cgroup_disabled())
-		return &zone->lruvec;
+	if (mem_cgroup_disabled()) {
+		lruvec = &zone->lruvec;
+		goto out;
+	}
 
 	pc = lookup_page_cgroup(page);
 	memcg = pc->mem_cgroup;
@@ -1107,7 +1122,16 @@ struct lruvec *mem_cgroup_page_lruvec(st
 		pc->mem_cgroup = memcg = root_mem_cgroup;
 
 	mz = page_cgroup_zoneinfo(memcg, page);
-	return &mz->lruvec;
+	lruvec = &mz->lruvec;
+out:
+	/*
+	 * Since a node can be onlined after the mem_cgroup was created,
+	 * we have to be prepared to initialize lruvec->zone here;
+	 * and if offlined then reonlined, we need to reinitialize it.
+	 */
+	if (unlikely(lruvec->zone != zone))
+		lruvec->zone = zone;
+	return lruvec;
 }
 
 /**
@@ -3688,17 +3712,17 @@ unsigned long mem_cgroup_soft_limit_recl
 static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 				int node, int zid, enum lru_list lru)
 {
-	struct mem_cgroup_per_zone *mz;
+	struct lruvec *lruvec;
 	unsigned long flags, loop;
 	struct list_head *list;
 	struct page *busy;
 	struct zone *zone;
 
 	zone = &NODE_DATA(node)->node_zones[zid];
-	mz = mem_cgroup_zoneinfo(memcg, node, zid);
-	list = &mz->lruvec.lists[lru];
+	lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+	list = &lruvec->lists[lru];
 
-	loop = mz->lru_size[lru];
+	loop = mem_cgroup_get_lru_size(lruvec, lru);
 	/* give some margin against EBUSY etc...*/
 	loop += 256;
 	busy = NULL;
@@ -4736,7 +4760,7 @@ static int alloc_mem_cgroup_per_zone_inf
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		lruvec_init(&mz->lruvec, &NODE_DATA(node)->node_zones[zone]);
+		lruvec_init(&mz->lruvec);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->memcg = memcg;
--- 3.7-rc3/mm/mmzone.c	2012-09-30 16:47:46.000000000 -0700
+++ linux/mm/mmzone.c	2012-11-01 14:31:04.284185741 -0700
@@ -87,7 +87,7 @@ int memmap_valid_within(unsigned long pf
 }
 #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
 
-void lruvec_init(struct lruvec *lruvec, struct zone *zone)
+void lruvec_init(struct lruvec *lruvec)
 {
 	enum lru_list lru;
 
@@ -95,8 +95,4 @@ void lruvec_init(struct lruvec *lruvec,
 
 	for_each_lru(lru)
 		INIT_LIST_HEAD(&lruvec->lists[lru]);
-
-#ifdef CONFIG_MEMCG
-	lruvec->zone = zone;
-#endif
 }
--- 3.7-rc3/mm/page_alloc.c	2012-10-28 13:48:00.021774166 -0700
+++ linux/mm/page_alloc.c	2012-11-01 14:31:04.284185741 -0700
@@ -4505,7 +4505,7 @@ static void __paginginit free_area_init_
 		zone->zone_pgdat = pgdat;
 
 		zone_pcp_init(zone);
-		lruvec_init(&zone->lruvec, zone);
+		lruvec_init(&zone->lruvec);
 		if (!size)
 			continue;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
