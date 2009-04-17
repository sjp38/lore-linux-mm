Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 120455F0001
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 02:38:57 -0400 (EDT)
Date: Fri, 17 Apr 2009 15:34:55 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] fix unused/stale swap cache handling on memcg  v3
Message-Id: <20090417153455.c6fe2ba6.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090325085713.6f0b7b74.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
	<20090318231738.4e042cbd.d-nishimura@mtf.biglobe.ne.jp>
	<20090319084523.1fbcc3cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090319111629.dcc9fe43.kamezawa.hiroyu@jp.fujitsu.com>
	<20090319180631.44b0130f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090319190118.db8a1dd7.nishimura@mxp.nes.nec.co.jp>
	<20090319191321.6be9b5e8.nishimura@mxp.nes.nec.co.jp>
	<100477cfc6c3c775abc7aecd4ce8c46e.squirrel@webmail-b.css.fujitsu.com>
	<432ace3655a26d2d492a56303369a88a.squirrel@webmail-b.css.fujitsu.com>
	<20090320164520.f969907a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323104555.cb7cd059.nishimura@mxp.nes.nec.co.jp>
	<20090323114118.8b45105f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323140419.40235ce3.nishimura@mxp.nes.nec.co.jp>
	<20090323142242.f6659457.kamezawa.hiroyu@jp.fujitsu.com>
	<20090324173218.4de33b90.nishimura@mxp.nes.nec.co.jp>
	<20090325085713.6f0b7b74.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Mar 2009 08:57:13 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 24 Mar 2009 17:32:18 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Mon, 23 Mar 2009 14:22:42 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Mon, 23 Mar 2009 14:04:19 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > > Nice clean-up here :)
> > > > > 
> > > > Thanks, I'll send a cleanup patch for this part later.
> > > > 
> > > Thank you, I'll look into.
> > > 
> > > > > > @@ -1359,18 +1373,40 @@ charge_cur_mm:
> > > > > >  	return __mem_cgroup_try_charge(mm, mask, ptr, true);
> > > > > >  }
> > > > > >  
> > > > > > -void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
> > > > > > +static void
> > > > > > +__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
> > > > > > +					enum charge_type ctype)
> > > > > >  {
> > > > > > -	struct page_cgroup *pc;
> > > > > > +	unsigned long flags;
> > > > > > +	struct zone *zone = page_zone(page);
> > > > > > +	struct page_cgroup *pc = lookup_page_cgroup(page);
> > > > > > +	int locked = 0;
> > > > > >  
> > > > > >  	if (mem_cgroup_disabled())
> > > > > >  		return;
> > > > > >  	if (!ptr)
> > > > > >  		return;
> > > > > > -	pc = lookup_page_cgroup(page);
> > > > > > -	mem_cgroup_lru_del_before_commit_swapcache(page);
> > > > > > -	__mem_cgroup_commit_charge(ptr, pc, MEM_CGROUP_CHARGE_TYPE_MAPPED);
> > > > > > -	mem_cgroup_lru_add_after_commit_swapcache(page);
> > > > > > +
> > > > > > +	/*
> > > > > > +	 * Forget old LRU when this page_cgroup is *not* used. This Used bit
> > > > > > +	 * is guarded by lock_page() because the page is SwapCache.
> > > > > > +	 * If this pc is on orphan LRU, it is also removed from orphan LRU here.
> > > > > > +	 */
> > > > > > +	if (!PageCgroupUsed(pc)) {
> > > > > > +		locked = 1;
> > > > > > +		spin_lock_irqsave(&zone->lru_lock, flags);
> > > > > > +		mem_cgroup_del_lru_list(page, page_lru(page));
> > > > > > +	}
> > > > > Maybe nice. I tried to use lock_page_cgroup() in add_list but I can't ;(
> > > > > I think this works well. But I wonder...why you have to check PageCgroupUsed() ?
> > > > > And is it correct ? Removing PageCgroupUsed() bit check is nice.
> > > > > (This will be "usually returns true" check, anyway)
> > > > > 
> > > > I've just copied lru_del_before_commit_swapcache.
> > > > 
> > > ya, considering now, it seems to be silly quick-hack.
> > > 
> > > > As you say, this check will return false only in (C) case in memcg_test.txt,
> > > > and even in (C) case calling mem_cgroup_del_lru_list(and mem_cgroup_add_lru_list later)
> > > > would be no problem.
> > > > 
> > > > OK, I'll remove this check.
> > > > 
> > > Thanks,
> > > 
> > > > This is the updated version(w/o cache_charge cleanup).
> > > > 
> > > > BTW, Should I merge reclaim part based on your patch and post it ?
> > > > 
> > > I think not necessary. keeping changes minimum is important as BUGFIX.
> > > We can visit here again when new -RC stage starts.
> > > 
> > > no problem from my review.
> > > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > Just FYI, this version of orphan list framework works fine
> > w/o causing BUG more than 24h.
> > 
> > So, I believe we can implement reclaim part based on this
> > to fix the original problem.
> > 
> ok, but I'd like to wait to start it until the end of merge-window.
> 
I made a patch for reclaiming SwapCache from orphan LRU based on your patch,
and have been testing it these days.

Major changes from your version:
- count the number of orphan pages per zone and make the threshold per zone(4MB).
- As for type 2 of orphan SwapCache, they are usually set dirty by add_to_swap.
  But try_to_drop_swapcache(__remove_mapping) can't free dirty pages,
  so add a check and try_to_free_swap to the end of shrink_page_list.

It seems work fine, no "pseud leak" of SwapCache can be seen.

What do you think ?
If it's all right, I'll merge this with the orphan list framework patch
and send it to Andrew with other fixes of memcg that I have.

Thanks,
Daisuke Nishimura.
===

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/swap.h |    6 +++
 mm/memcontrol.c      |  119 +++++++++++++++++++++++++++++++++++++++++++++++---
 mm/swapfile.c        |   23 ++++++++++
 mm/vmscan.c          |   20 ++++++++
 4 files changed, 162 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 62d8143..02baae1 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -311,6 +311,7 @@ extern sector_t swapdev_block(int, pgoff_t);
 extern struct swap_info_struct *get_swap_info_struct(unsigned);
 extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
+extern int try_to_drop_swapcache(struct page *);
 struct backing_dev_info;
 
 /* linux/mm/thrash.c */
@@ -418,6 +419,11 @@ static inline int try_to_free_swap(struct page *page)
 	return 0;
 }
 
+static inline int try_to_drop_swapcache(struct page *page)
+{
+	return 0;
+}
+
 static inline swp_entry_t get_swap_page(void)
 {
 	swp_entry_t entry;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 259b09e..8638c7b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -384,10 +384,14 @@ static int mem_cgroup_walk_tree(struct mem_cgroup *root, void *data,
 
 struct orphan_list_node {
 	struct orphan_list_zone {
+		unsigned long count;
 		struct list_head list;
 	} zone[MAX_NR_ZONES];
 };
 struct orphan_list_node *orphan_list[MAX_NUMNODES] __read_mostly;
+#define ORPHAN_THRESH (1024)	/* 4MB per zone */
+static void try_scan_orphan_list(int, int);
+static int memory_cgroup_is_used __read_mostly;
 
 static inline struct orphan_list_zone *orphan_lru(int nid, int zid)
 {
@@ -399,19 +403,29 @@ static inline struct orphan_list_zone *orphan_lru(int nid, int zid)
 	return  &orphan_list[nid]->zone[zid];
 }
 
-static inline void remove_orphan_list(struct page_cgroup *pc)
+static inline void remove_orphan_list(struct page *page, struct page_cgroup *pc)
 {
+	struct orphan_list_zone *opl;
+
 	ClearPageCgroupOrphan(pc);
+	opl = orphan_lru(page_to_nid(page), page_zonenum(page));
 	list_del_init(&pc->lru);
+	opl->count--;
 }
 
 static inline void add_orphan_list(struct page *page, struct page_cgroup *pc)
 {
+	int nid = page_to_nid(page);
+	int zid = page_zonenum(page);
 	struct orphan_list_zone *opl;
 
 	SetPageCgroupOrphan(pc);
-	opl = orphan_lru(page_to_nid(page), page_zonenum(page));
+	opl = orphan_lru(nid, zid);
 	list_add_tail(&pc->lru, &opl->list);
+	if (unlikely(opl->count++ > ORPHAN_THRESH))
+		/* Orphan is not problem if no mem_cgroup is used */
+		if (memory_cgroup_is_used)
+			try_scan_orphan_list(nid, zid);
 }
 
 
@@ -429,7 +443,7 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
 	 * orphan list. remove here
 	 */
 	if (unlikely(PageCgroupOrphan(pc))) {
-		remove_orphan_list(pc);
+		remove_orphan_list(page, pc);
 		return;
 	}
 	/* can happen while we handle swapcache. */
@@ -802,6 +816,89 @@ static int mem_cgroup_count_children(struct mem_cgroup *mem)
 	return num;
 }
 
+
+/*
+ * In usual, *unused* swap cache are reclaimed by global LRU. But, if no one
+ * kicks global LRU, they will not be reclaimed. When using memcg, it's trouble.
+ */
+static int drain_orphan_swapcaches(int nid, int zid)
+{
+	struct page_cgroup *pc;
+	struct zone *zone;
+	struct page *page;
+	struct orphan_list_zone *opl = orphan_lru(nid, zid);
+	unsigned long flags;
+	int drain = 0;
+	int scan;
+
+	zone = &NODE_DATA(nid)->node_zones[zid];
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	scan = opl->count/5;
+	while (!list_empty(&opl->list) && (scan > 0)) {
+		pc = list_entry(opl->list.next, struct page_cgroup, lru);
+		page = pc->page;
+		/* Rotate */
+		list_del(&pc->lru);
+		list_add_tail(&pc->lru, &opl->list);
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		scan--;
+		/* Remove from LRU */
+		if (!isolate_lru_page(page)) { /* get_page is called */
+			if (!page_mapped(page) && trylock_page(page)) {
+				/* This does all necessary jobs */
+				drain += try_to_drop_swapcache(page);
+				unlock_page(page);
+			}
+			putback_lru_page(page); /* put_page is called */
+		}
+		spin_lock_irqsave(&zone->lru_lock, flags);
+	}
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
+
+	return drain;
+}
+
+static void try_delete_orphan_caches_all(void)
+{
+	int nid, zid;
+
+	for_each_node_state(nid, N_HIGH_MEMORY)
+		for (zid = 0; zid < MAX_NR_ZONES; zid++)
+			drain_orphan_swapcaches(nid, zid);
+}
+
+/* Only one worker can scan orphan lists at the same time. */
+static atomic_t orphan_scan_worker;
+struct orphan_scan {
+	int node;
+	int zone;
+	struct work_struct work;
+};
+static struct orphan_scan orphan_scan;
+
+static void try_delete_orphan_caches(struct work_struct *work)
+{
+	int nid, zid;
+
+	nid = orphan_scan.node;
+	zid = orphan_scan.zone;
+	drain_orphan_swapcaches(nid, zid);
+	atomic_dec(&orphan_scan_worker);
+}
+
+static void try_scan_orphan_list(int nid, int zid)
+{
+	if (atomic_inc_return(&orphan_scan_worker) > 1) {
+		atomic_dec(&orphan_scan_worker);
+		return;
+	}
+	orphan_scan.node = nid;
+	orphan_scan.zone = zid;
+	INIT_WORK(&orphan_scan.work, try_delete_orphan_caches);
+	schedule_work(&orphan_scan.work);
+	/* call back function decrements orphan_scan_worker */
+}
+
 static __init void init_orphan_lru(void)
 {
 	struct orphan_list_node *opl;
@@ -814,8 +911,10 @@ static __init void init_orphan_lru(void)
 		else
 			opl = kmalloc(size, GFP_KERNEL);
 		BUG_ON(!opl);
-		for (zid = 0; zid < MAX_NR_ZONES; zid++)
+		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 			INIT_LIST_HEAD(&opl->zone[zid].list);
+			opl->zone[zid].count = 0;
+		}
 		orphan_list[nid] = opl;
 	}
 }
@@ -1000,6 +1099,10 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		if (ret)
 			continue;
 
+		/* unused SwapCache might pressure the memsw usage */
+		if (nr_retries < MEM_CGROUP_RECLAIM_RETRIES/2 && noswap)
+			try_delete_orphan_caches_all();
+
 		/*
 		 * try_to_free_mem_cgroup_pages() might not give us a full
 		 * picture of reclaim. Some pages are reclaimed and might be
@@ -1787,9 +1890,12 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true, true);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		/* Usage is reduced ? */
-		if (curusage >= oldusage)
+		if (curusage >= oldusage) {
 			retry_count--;
-		else
+			/* unused SwapCache might pressure the memsw usage */
+			if (retry_count < MEM_CGROUP_RECLAIM_RETRIES/2)
+				try_delete_orphan_caches_all();
+		} else
 			oldusage = curusage;
 	}
 	return ret;
@@ -2483,6 +2589,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
+		memory_cgroup_is_used = 1;
 	}
 
 	if (parent && parent->use_hierarchy) {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 312fafe..9416196 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -571,6 +571,29 @@ int try_to_free_swap(struct page *page)
 }
 
 /*
+ * Similar to try_to_free_swap() but this drops SwapCache without checking
+ * page_swapcount(). By this, this function removes not only unused swap entry
+ * but alos a swap-cache which is on memory but never used.
+ * The caller should have a reference to this page and it must be locked.
+ */
+int try_to_drop_swapcache(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page));
+
+	if (!PageSwapCache(page))
+		return 0;
+	if (PageWriteback(page))
+		return 0;
+	if (page_mapped(page))
+		return 0;
+	/*
+	 * remove_mapping() will success only when there is no extra
+	 * user of swap cache. (Keeping sanity be speculative lookup)
+	 */
+	return remove_mapping(&swapper_space, page);
+}
+
+/*
  * Free the swap entry like above, but also try to
  * free the page cache entry if it is the last user.
  */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 38d7506..b123eca 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -38,6 +38,7 @@
 #include <linux/kthread.h>
 #include <linux/freezer.h>
 #include <linux/memcontrol.h>
+#include <linux/page_cgroup.h>
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
 
@@ -785,6 +786,25 @@ activate_locked:
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
+		if (!scanning_global_lru(sc) && PageSwapCache(page)) {
+			struct page_cgroup *pc;
+
+			pc = lookup_page_cgroup(page);
+			/*
+			 * Used bit of swapcache is solid under page lock.
+			 */
+			if (unlikely(!PageCgroupUsed(pc)))
+				/*
+				 * This can happen if the page is unmapped by
+				 * the owner process before it is added to
+				 * swapcache.
+				 * These swapcaches are usually set dirty by
+				 * add_to_swap, but try_to_drop_swapcache can't
+				 * free dirty swapcaches.
+				 * So free these swapcaches here.
+				 */
+				try_to_free_swap(page);
+		}
 		unlock_page(page);
 keep:
 		list_add(&page->lru, &ret_pages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
