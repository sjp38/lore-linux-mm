Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id C56AC6B010E
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 18:38:25 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so8259259pbc.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 15:38:25 -0800 (PST)
Date: Mon, 20 Feb 2012 15:38:01 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 9/10] mm/memcg: move lru_lock into lruvec
In-Reply-To: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1202201537040.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We're nearly there.  Now move lru_lock and irqflags into struct lruvec,
so they are in every zone (for !MEM_RES_CTLR and mem_cgroup_disabled()
cases) and in every memcg lruvec.

Extend the memcg version of page_relock_lruvec() to drop old and take
new lock whenever changing lruvec.  But the memcg will only be stable
once we already have the lock: so, having got it, check if it's still
the lock we want, and retry if not.  It's for this retry that we route
all page lruvec locking through page_relock_lruvec().

No need for lock_page_cgroup() in here (which would entail reinverting
the lock ordering, and _irq'ing all of its calls): the lrucare protocol
when charging (holding old lock while changing owner then acquiring new)
fits correctly with this retry protocol.  In some places we rely also on
page_count 0 preventing further references, in some places on !PageLRU
protecting a page from outside interference: mem_cgroup_move_account()

What if page_relock_lruvec() were preempted for a while, after reading
a valid mem_cgroup from page_cgroup, but before acquiring the lock?
In that case, a rmdir might free the mem_cgroup and its associated
zoneinfo, and we take a spin_lock in freed memory.  But rcu_read_lock()
before we read mem_cgroup keeps it safe: cgroup.c uses synchronize_rcu()
in between pre_destroy (force_empty) and destroy (freeing structures).
mem_cgroup_force_empty() cannot succeed while there's any charge, or any
page on any of its lrus - and checks list_empty() while holding the lock.

But although we are now fully prepared, in this patch keep on using
the zone->lru_lock for all of its memcgs: so that the cost or benefit
of split locking can be easily compared with the final patch (but
of course, some costs and benefits come earlier in the series).

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/mmzone.h |    4 +-
 include/linux/swap.h   |   13 +++---
 mm/memcontrol.c        |   74 ++++++++++++++++++++++++++-------------
 mm/page_alloc.c        |    2 -
 4 files changed, 59 insertions(+), 34 deletions(-)

--- mmotm.orig/include/linux/mmzone.h	2012-02-18 11:57:42.675524592 -0800
+++ mmotm/include/linux/mmzone.h	2012-02-18 11:58:09.047525220 -0800
@@ -174,6 +174,8 @@ struct zone_reclaim_stat {
 
 struct lruvec {
 	struct zone *zone;
+	spinlock_t lru_lock;
+	unsigned long irqflags;
 	struct list_head lists[NR_LRU_LISTS];
 	struct zone_reclaim_stat reclaim_stat;
 };
@@ -373,8 +375,6 @@ struct zone {
 	ZONE_PADDING(_pad1_)
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;
-	unsigned long		irqflags;
 	struct lruvec		lruvec;
 
 	unsigned long		pages_scanned;	   /* since last reclaim */
--- mmotm.orig/include/linux/swap.h	2012-02-18 11:57:42.675524592 -0800
+++ mmotm/include/linux/swap.h	2012-02-18 11:58:09.047525220 -0800
@@ -252,25 +252,24 @@ static inline void lru_cache_add_file(st
 
 static inline spinlock_t *lru_lockptr(struct lruvec *lruvec)
 {
-	return &lruvec->zone->lru_lock;
+	/* Still use per-zone lru_lock */
+	return &lruvec->zone->lruvec.lru_lock;
 }
 
 static inline void lock_lruvec(struct lruvec *lruvec)
 {
-	struct zone *zone = lruvec->zone;
 	unsigned long irqflags;
 
-	spin_lock_irqsave(&zone->lru_lock, irqflags);
-	zone->irqflags = irqflags;
+	spin_lock_irqsave(lru_lockptr(lruvec), irqflags);
+	lruvec->irqflags = irqflags;
 }
 
 static inline void unlock_lruvec(struct lruvec *lruvec)
 {
-	struct zone *zone = lruvec->zone;
 	unsigned long irqflags;
 
-	irqflags = zone->irqflags;
-	spin_unlock_irqrestore(&zone->lru_lock, irqflags);
+	irqflags = lruvec->irqflags;
+	spin_unlock_irqrestore(lru_lockptr(lruvec), irqflags);
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
--- mmotm.orig/mm/memcontrol.c	2012-02-18 11:58:02.451525062 -0800
+++ mmotm/mm/memcontrol.c	2012-02-18 11:58:09.051525220 -0800
@@ -1048,39 +1048,64 @@ void page_relock_lruvec(struct page *pag
 	struct page_cgroup *pc;
 	struct lruvec *lruvec;
 
-	if (mem_cgroup_disabled())
+	if (unlikely(mem_cgroup_disabled())) {
 		lruvec = &page_zone(page)->lruvec;
-	else {
-		pc = lookup_page_cgroup(page);
-		memcg = pc->mem_cgroup;
-		/*
-		 * At present we start up with all page_cgroups initialized
-		 * to zero: correct that to root_mem_cgroup once we see it.
-		 */
-		if (unlikely(!memcg))
-			memcg = pc->mem_cgroup = root_mem_cgroup;
-		/*
-		 * We must reset pc->mem_cgroup back to root before freeing
-		 * a page: avoid additional callouts from hot paths by doing
-		 * it here when we see the page is frozen (can safely be done
-		 * before taking lru_lock because the page is frozen).
-		 */
-		if (memcg != root_mem_cgroup && !page_count(page))
-			pc->mem_cgroup = root_mem_cgroup;
-		mz = page_cgroup_zoneinfo(memcg, page);
-		lruvec = &mz->lruvec;
+		if (*lruvp && *lruvp != lruvec) {
+			unlock_lruvec(*lruvp);
+			*lruvp = NULL;
+		}
+		if (!*lruvp) {
+			*lruvp = lruvec;
+			lock_lruvec(lruvec);
+		}
+		return;
 	}
 
+	pc = lookup_page_cgroup(page);
+	/*
+	 * Imagine being preempted for a long time: we need to make sure that
+	 * the structure at pc->mem_cgroup, and structures it links to, cannot
+	 * be freed while we locate and acquire its zone lru_lock.  cgroup's
+	 * synchronize_rcu() between pre_destroy and destroy makes this safe.
+	 */
+	rcu_read_lock();
+again:
+	memcg = rcu_dereference(pc->mem_cgroup);
 	/*
-	 * For the moment, simply lock by zone just as before.
+	 * At present we start up with all page_cgroups initialized
+	 * to zero: here treat NULL as root_mem_cgroup, then correct
+	 * the page_cgroup below once we really have it locked.
 	 */
-	if (*lruvp && (*lruvp)->zone != lruvec->zone) {
+	mz = page_cgroup_zoneinfo(memcg ? : root_mem_cgroup, page);
+	lruvec = &mz->lruvec;
+
+	/*
+	 * Sometimes we are called with non-NULL *lruvp spinlock already held:
+	 * hold on if we want the same lock again, otherwise drop and acquire.
+	 */
+	if (*lruvp && *lruvp != lruvec) {
 		unlock_lruvec(*lruvp);
 		*lruvp = NULL;
 	}
-	if (!*lruvp)
+	if (!*lruvp) {
+		*lruvp = lruvec;
 		lock_lruvec(lruvec);
-	*lruvp = lruvec;
+		/*
+		 * But pc->mem_cgroup may have changed since we looked...
+		 */
+		if (unlikely(pc->mem_cgroup != memcg))
+			goto again;
+	}
+
+	/*
+	 * We must reset pc->mem_cgroup back to root before freeing a page:
+	 * avoid additional callouts from hot paths by doing it here when we
+	 * see the page is frozen.  Also initialize pc at first use of page.
+	 */
+	if (memcg != root_mem_cgroup && (!memcg || !page_count(page)))
+		pc->mem_cgroup = root_mem_cgroup;
+
+	rcu_read_unlock();
 }
 
 void mem_cgroup_reset_uncharged_to_root(struct page *page)
@@ -4744,6 +4769,7 @@ static int alloc_mem_cgroup_per_zone_inf
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
 		mz->lruvec.zone = &NODE_DATA(node)->node_zones[zone];
+		spin_lock_init(&mz->lruvec.lru_lock);
 		for_each_lru(lru)
 			INIT_LIST_HEAD(&mz->lruvec.lists[lru]);
 		mz->usage_in_excess = 0;
--- mmotm.orig/mm/page_alloc.c	2012-02-18 11:57:28.375524252 -0800
+++ mmotm/mm/page_alloc.c	2012-02-18 11:58:09.051525220 -0800
@@ -4360,12 +4360,12 @@ static void __paginginit free_area_init_
 #endif
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
-		spin_lock_init(&zone->lru_lock);
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
 		zone_pcp_init(zone);
 		zone->lruvec.zone = zone;
+		spin_lock_init(&zone->lruvec.lru_lock);
 		for_each_lru(lru)
 			INIT_LIST_HEAD(&zone->lruvec.lists[lru]);
 		zone->lruvec.reclaim_stat.recent_rotated[0] = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
