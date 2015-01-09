Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6450C6B0038
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 03:59:10 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id r10so16334331pdi.9
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 00:59:10 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pz1si12567408pdb.159.2015.01.09.00.59.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jan 2015 00:59:08 -0800 (PST)
Date: Fri, 9 Jan 2015 11:58:55 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v3 3/9] vmscan: per memory cgroup slab shrinkers
Message-ID: <20150109085855.GC2110@esperanza>
References: <063c01d02bd6$38c64ce0$aa52e6a0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <063c01d02bd6$38c64ce0$aa52e6a0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Michal Hocko' <mhocko@suse.cz>, 'Greg Thelen' <gthelen@google.com>, 'Glauber Costa' <glommer@gmail.com>, 'Dave Chinner' <david@fromorbit.com>, 'Alexander Viro' <viro@zeniv.linux.org.uk>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Jan 09, 2015 at 02:33:46PM +0800, Hillf Danton wrote:
> > @@ -2318,16 +2357,22 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
> > 
> >  		memcg = mem_cgroup_iter(root, NULL, &reclaim);
> >  		do {
> > -			unsigned long lru_pages;
> > +			unsigned long lru_pages, scanned;
> >  			struct lruvec *lruvec;
> >  			int swappiness;
> > 
> >  			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
> >  			swappiness = mem_cgroup_swappiness(memcg);
> > +			scanned = sc->nr_scanned;
> > 
> >  			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
> >  			zone_lru_pages += lru_pages;
> > 
> > +			if (memcg && is_classzone)
> > +				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
> > +					    memcg, sc->nr_scanned - scanned,
> > +					    lru_pages);
> > +
> Looks sc->nr_reclaimed has to be updated for "limit reclaim".
> 

That's true, thank you for catching this!

I think we should move reclaim_state handling to shrink_slab(), as this
incremental patch does:

---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 16f3e45742d6..6961bf0a47af 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -347,6 +347,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
  * @memcg: memory cgroup whose slab caches to target
  * @nr_scanned: pressure numerator
  * @nr_eligible: pressure denominator
+ * @nr_reclaimed: number of reclaimed slab pages
  *
  * Call the shrink functions to age shrinkable caches.
  *
@@ -372,8 +373,10 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 				 struct mem_cgroup *memcg,
 				 unsigned long nr_scanned,
-				 unsigned long nr_eligible)
+				 unsigned long nr_eligible,
+				 unsigned long *nr_reclaimed)
 {
+	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
 
@@ -394,6 +397,9 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		goto out;
 	}
 
+	if (reclaim_state)
+		reclaim_state->reclaimed_slab = 0;
+
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		struct shrink_control sc = {
 			.gfp_mask = gfp_mask,
@@ -410,6 +416,9 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
 	}
 
+	if (reclaim_state)
+		*nr_reclaimed += reclaim_state->reclaimed_slab;
+
 	up_read(&shrinker_rwsem);
 out:
 	cond_resched();
@@ -419,6 +428,7 @@ out:
 void drop_slab_node(int nid)
 {
 	unsigned long freed;
+	unsigned long nr_reclaimed = 0;
 
 	do {
 		struct mem_cgroup *memcg = NULL;
@@ -426,7 +436,7 @@ void drop_slab_node(int nid)
 		freed = 0;
 		do {
 			freed += shrink_slab(GFP_KERNEL, nid, memcg,
-					     1000, 1000);
+					     1000, 1000, &nr_reclaimed);
 		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
 	} while (freed > 10);
 }
@@ -2339,7 +2349,6 @@ static inline bool should_continue_reclaim(struct zone *zone,
 static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			bool is_classzone)
 {
-	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
 	bool reclaimable = false;
 
@@ -2371,7 +2380,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			if (memcg && is_classzone)
 				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
 					    memcg, sc->nr_scanned - scanned,
-					    lru_pages);
+					    lru_pages, &sc->nr_reclaimed);
 
 			/*
 			 * Direct reclaim and kswapd have to scan all memory
@@ -2398,12 +2407,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 		if (global_reclaim(sc) && is_classzone)
 			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
 				    sc->nr_scanned - nr_scanned,
-				    zone_lru_pages);
-
-		if (reclaim_state) {
-			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-			reclaim_state->reclaimed_slab = 0;
-		}
+				    zone_lru_pages, &sc->nr_reclaimed);
 
 		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
 			   sc->nr_scanned - nr_scanned,
@@ -3367,10 +3371,7 @@ static int kswapd(void *p)
 	int balanced_classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
-
-	struct reclaim_state reclaim_state = {
-		.reclaimed_slab = 0,
-	};
+	struct reclaim_state reclaim_state;
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
 
 	lockdep_set_current_reclaim_state(GFP_KERNEL);
@@ -3508,7 +3509,6 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 
 	p->flags |= PF_MEMALLOC;
 	lockdep_set_current_reclaim_state(sc.gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
@@ -3697,7 +3697,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	 */
 	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
 	lockdep_set_current_reclaim_state(gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
 	if (zone_pagecache_reclaimable(zone) > zone->min_unmapped_pages) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
