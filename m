Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 065966B0044
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 02:41:18 -0400 (EDT)
Received: by ied10 with SMTP id 10so1561745ied.14
        for <linux-mm@kvack.org>; Sun, 16 Sep 2012 23:41:18 -0700 (PDT)
Date: Sun, 16 Sep 2012 23:40:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] memory cgroup: update root memory cgroup when node is
 onlined
In-Reply-To: <50528C72.3080008@cn.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1209162212320.4181@eggly.anvils>
References: <505187D4.7070404@cn.fujitsu.com> <20120913205935.GK1560@cmpxchg.org> <50528C72.3080008@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Jiang Liu <liuj97@gmail.com>, mhocko@suse.cz, bsingharora@gmail.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, paul.gortmaker@windriver.com

On Fri, 14 Sep 2012, Wen Congyang wrote:
> 
> Hmm, if we don't update lruvec_zone(lruvec) when a node is onlined,
> lruver_zone(lruvec) contains a invalid pointer, so we should check
> all place that accesses lruvec_zone(lruvec). We store zone in lruvec
> but we can't access it. And we can't avoid to access it in the
> furture. So I think it is better to update it when the node is
> onlined.

Thanks for your feedback (-), and Johannes (+), and Konstantin (-):
though your remarks above appear to be in reply to Johannes, I took
them as applying to my patch.

I think it's okay to update lruvec->zone in mem_cgroup_zone_lruvec()
and mem_cgroup_page_lruvec(), rather than in each place we call
lruvec_zone(lruvec), because the lruvec addressed is not pulled out
of nowhere: it has been supplied by either mem_cgroup_zone_lruvec()
or mem_cgroup_page_lruvec().

But your comment did prompt me to go back and check on that, and
I did find one other place which makes its own determination of the
lruvec: mem_cgroup_force_empty_list().  Now, that happens to be safe
at present because of its list_empty() check, but it's easy to imagine
a future patch which would accidentally make it go wrong: so in the
updated version of my lruvec->zone patch below, I've changed the
assignments at the head of mem_cgroup_force_empty_list() to use
the standard mem_cgroup_zone_lruvec() to determine lruvec.

But I've made another change (in both places) too - though if you've
already been testing the earlier patch, this will not be any worse:
I've removed the VM_BUG_ONs, after realizing that hotremove of
memory node followed by hotadd of memory node would need to
update lruvec->zone even though it's currently non-zero -
unless hotremove goes through updating all memcgs in the
same way as you propose that hotadd does.

I'm not sure how I feel about my patch: really, I think I'd
like to see the "update all memcgs when memory node is onlined and
offlined" patch that you and Konstantin prefer (but I'd prefer one
of you to write), before we make up our minds which way to go.

If it's not too complicated, yes, I may well prefer it myself too;
but I worry that it may turn out to be hard to get the serialization
against mem cgroup creation and destruction right.

Konstantin remarks that it would be nice to have notifier chains
in memory hotplug: I believe that's already there, and, for example,
KSM is one user of hotplug_memory_notifier().

I've seen you comment elsewhere that memory hotremove is not working
with memcg, and I wonder if you've found it far away from working,
or nearly there.  That might determine which patch to choose: if
it's nearly working, then you may need to update all memcgs anyway
to get it fully working, in which case it would probably be right
to handle lruvec->zone that way too.  But if it's hard to get working,
but hotadd nearly right, then my patch may be the right choice for now.

I've still not written the patch comment: it was when I started to
write that, that I realized the hotadd after hotremove issue.

Reported-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 include/linux/mmzone.h |    2 -
 mm/memcontrol.c        |   46 +++++++++++++++++++++++++++++----------
 mm/mmzone.c            |    6 -----
 mm/page_alloc.c        |    2 -
 4 files changed, 38 insertions(+), 18 deletions(-)

--- 3.6-rc6/include/linux/mmzone.h	2012-08-03 08:31:26.892842267 -0700
+++ linux/include/linux/mmzone.h	2012-09-13 17:07:51.893772372 -0700
@@ -744,7 +744,7 @@ extern int init_currently_empty_zone(str
 				     unsigned long size,
 				     enum memmap_context context);
 
-extern void lruvec_init(struct lruvec *lruvec, struct zone *zone);
+extern void lruvec_init(struct lruvec *lruvec);
 
 static inline struct zone *lruvec_zone(struct lruvec *lruvec)
 {
--- 3.6-rc6/mm/memcontrol.c	2012-08-03 08:31:27.060842270 -0700
+++ linux/mm/memcontrol.c	2012-09-16 21:49:28.583284601 -0700
@@ -1061,12 +1061,24 @@ struct lruvec *mem_cgroup_zone_lruvec(st
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
@@ -1093,9 +1105,12 @@ struct lruvec *mem_cgroup_page_lruvec(st
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
@@ -1113,7 +1128,16 @@ struct lruvec *mem_cgroup_page_lruvec(st
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
@@ -3694,17 +3718,17 @@ unsigned long mem_cgroup_soft_limit_recl
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
@@ -4742,7 +4766,7 @@ static int alloc_mem_cgroup_per_zone_inf
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		lruvec_init(&mz->lruvec, &NODE_DATA(node)->node_zones[zone]);
+		lruvec_init(&mz->lruvec);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->memcg = memcg;
--- 3.6-rc6/mm/mmzone.c	2012-08-03 08:31:27.064842271 -0700
+++ linux/mm/mmzone.c	2012-09-13 17:06:28.921766001 -0700
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
--- 3.6-rc6/mm/page_alloc.c	2012-08-22 14:25:39.508279046 -0700
+++ linux/mm/page_alloc.c	2012-09-13 17:06:08.265763526 -0700
@@ -4456,7 +4456,7 @@ static void __paginginit free_area_init_
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
