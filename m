Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B4F8A6B003D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 19:46:51 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2INkmKi020604
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 19 Mar 2009 08:46:48 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7319E45DD76
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 08:46:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E50C45DD74
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 08:46:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 38090E08003
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 08:46:48 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B7D30E0800C
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 08:46:47 +0900 (JST)
Date: Thu, 19 Mar 2009 08:45:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix unused/stale swap cache handling on memcg  v1 (Re:
 [RFC] memcg: handle swapcache leak
Message-Id: <20090319084523.1fbcc3cb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090318231738.4e042cbd.d-nishimura@mtf.biglobe.ne.jp>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
	<20090317143903.a789cf57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317151113.79a3cc9d.nishimura@mxp.nes.nec.co.jp>
	<20090317162950.70c1245c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317183850.67c35b27.kamezawa.hiroyu@jp.fujitsu.com>
	<20090318101727.f00dfc2f.nishimura@mxp.nes.nec.co.jp>
	<20090318103418.7d38dce0.kamezawa.hiroyu@jp.fujitsu.com>
	<20090318125154.f8ffe652.nishimura@mxp.nes.nec.co.jp>
	<20090318175734.f5a8a446.kamezawa.hiroyu@jp.fujitsu.com>
	<20090318231738.4e042cbd.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Mar 2009 23:17:38 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> On Wed, 18 Mar 2009 17:57:34 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > How about this ? I did short test and this eems to work well.
> > I'm glad if you share us your test method.
> > (Hopefully, update memcg_debug.txt ;)
> > 
> s/memcg_debug/memcg_test/ ?
> 
> I don't do anything special not in the document.
> I just do one (or combination) of them for a long time and repeatedly,
> and observe what happens.
> 
Hmm, ok.

> > Changes:
> >  - modified condition to trigger reclaim orphan paes.
> > 
> > If I get good answer, I'll repost this with CC: to Andrew.
> > 
> It looks good to me.
> 
> Unfortunately, I don't have enough time tomorrow.
> I'll test this during this weekend and report the result in next week.
> 
Okay, thank you very much. I'll review this again.

Thanks,
-Kame


> 
> Thanks,
> Daisuke Nishimura.
> 
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Nishimura reported unused-swap-cache is not reclaimed well under memcg.
> > 
> > Assume that memory cgroup well limits the memory usage of all applications
> > and file caches, and global-LRU-scan (kswapd() etc..) never runs.
> > 
> > First, there is *allowed* race to SwapCache on global LRU. There can be
> > SwapCaches on global LRU, even when swp_entry is not referred by anyone(ptes).
> > When global LRU scan runs, it will be reclaimed by try_to_free_swap().
> > But, they will not appear in memcg's private LRU and never reclaimed by
> > memcg's reclaim routines.
> > 
> > Second, there are readahead SwapCaches, some of then tend to be not used
> > and reclaimed by global LRU when scan runs, at last. But they are not on
> > memcg's private LRU and will not be reclaimed until global-lru-scan runs.
> > 
> > From memcg's point of view, above 2 is not very good. Especially, *unused*
> > swp_entry adds pressure to memcg's mem+swap controller and finally cause OOM.
> > (Nishimura confirmed this can cause OOM.)
> > 
> > This patch tries to reclaim unused-swapcache by 
> >   - add a list for unused-swapcache (orphan_list)
> >   - try to recalim orhan list by some threshold.
> > 
> > Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/page_cgroup.h |   13 +++
> >  mm/memcontrol.c             |  185 +++++++++++++++++++++++++++++++++++++++++++-
> >  2 files changed, 197 insertions(+), 1 deletion(-)
> > 
> > Index: mmotm-2.6.29-Mar13/include/linux/page_cgroup.h
> > ===================================================================
> > --- mmotm-2.6.29-Mar13.orig/include/linux/page_cgroup.h
> > +++ mmotm-2.6.29-Mar13/include/linux/page_cgroup.h
> > @@ -26,6 +26,7 @@ enum {
> >  	PCG_LOCK,  /* page cgroup is locked */
> >  	PCG_CACHE, /* charged as cache */
> >  	PCG_USED, /* this object is in use. */
> > +	PCG_ORPHAN, /* this is not used from memcg:s view but on global LRU */
> >  };
> >  
> >  #define TESTPCGFLAG(uname, lname)			\
> > @@ -40,12 +41,24 @@ static inline void SetPageCgroup##uname(
> >  static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
> >  	{ clear_bit(PCG_##lname, &pc->flags);  }
> >  
> > +#define TESTSETPCGFLAG(uname, lname) \
> > +static inline int TestSetPageCgroup##uname(struct page_cgroup *pc) \
> > +	{ return test_and_set_bit(PCG_##lname, &pc->flags); }
> > +
> > +#define TESTCLEARPCGFLAG(uname, lname) \
> > +static inline int TestClearPageCgroup##uname(struct page_cgroup *pc) \
> > +	{ return test_and_clear_bit(PCG_##lname, &pc->flags); }
> > +
> >  /* Cache flag is set only once (at allocation) */
> >  TESTPCGFLAG(Cache, CACHE)
> >  
> >  TESTPCGFLAG(Used, USED)
> >  CLEARPCGFLAG(Used, USED)
> >  
> > +TESTPCGFLAG(Orphan, ORPHAN)
> > +TESTSETPCGFLAG(Orphan, ORPHAN)
> > +TESTCLEARPCGFLAG(Orphan, ORPHAN)
> > +
> >  static inline int page_cgroup_nid(struct page_cgroup *pc)
> >  {
> >  	return page_to_nid(pc->page);
> > Index: mmotm-2.6.29-Mar13/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.29-Mar13.orig/mm/memcontrol.c
> > +++ mmotm-2.6.29-Mar13/mm/memcontrol.c
> > @@ -371,6 +371,61 @@ static int mem_cgroup_walk_tree(struct m
> >   * When moving account, the page is not on LRU. It's isolated.
> >   */
> >  
> > +/*
> > + * Orphan List is a list for page_cgroup which is not free but not under
> > + * any cgroup. SwapCache which is prefetched by readahead() is typical type but
> > + * there are other corner cases.
> > + *
> > + * Usually, updates to this list happens when swap cache is readaheaded and
> > + * finally used by process.
> > + */
> > +
> > +/* for orphan page_cgroups, updated under zone->lru_lock. */
> > +
> > +struct orphan_list_node {
> > +	struct orphan_list_zone {
> > +		int event;
> > +		struct list_head list;
> > +	} zone[MAX_NR_ZONES];
> > +};
> > +struct orphan_list_node *orphan_list[MAX_NUMNODES] __read_mostly;
> > +#define ORPHAN_EVENT_THRESH (256)
> > +static void check_orphan_stat(void);
> > +atomic_t nr_orphan_caches;
> > +
> > +static inline struct orphan_list_zone *orphan_lru(int nid, int zid)
> > +{
> > +	/*
> > +	 * 2 cases for this BUG_ON(), swapcache is generated while init.
> > +	 * or NID should be invalid.
> > +	 */
> > +	BUG_ON(!orphan_list[nid]);
> > +	return  &orphan_list[nid]->zone[zid];
> > +}
> > +
> > +static inline void remove_orphan_list(struct page_cgroup *pc)
> > +{
> > +	if (TestClearPageCgroupOrphan(pc)) {
> > +		list_del_init(&pc->lru);
> > +		atomic_dec(&nr_orphan_caches);
> > +	}
> > +}
> > +
> > +static void add_orphan_list(struct page *page, struct page_cgroup *pc)
> > +{
> > +	if (TestSetPageCgroupOrphan(pc)) {
> > +		struct orphan_list_zone *opl;
> > +		opl = orphan_lru(page_to_nid(page), page_zonenum(page));
> > +		list_add_tail(&pc->lru, &opl->list);
> > +		atomic_inc(&nr_orphan_caches);
> > +		if (opl->event++ > ORPHAN_EVENT_THRESH) {
> > +			check_orphan_stat();
> > +			opl->event = 0;
> > +		}
> > +	}
> > +}
> > +
> > +
> >  void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
> >  {
> >  	struct page_cgroup *pc;
> > @@ -380,6 +435,14 @@ void mem_cgroup_del_lru_list(struct page
> >  	if (mem_cgroup_disabled())
> >  		return;
> >  	pc = lookup_page_cgroup(page);
> > +	/*
> > +	 * If the page is SwapCache and already on global LRU, it will be on
> > +	 * orphan list. remove here
> > +	 */
> > +	if (unlikely(PageCgroupOrphan(pc))) {
> > +		remove_orphan_list(pc);
> > +		return;
> > +	}
> >  	/* can happen while we handle swapcache. */
> >  	if (list_empty(&pc->lru) || !pc->mem_cgroup)
> >  		return;
> > @@ -433,8 +496,11 @@ void mem_cgroup_add_lru_list(struct page
> >  	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
> >  	 */
> >  	smp_rmb();
> > -	if (!PageCgroupUsed(pc))
> > +	if (!PageCgroupUsed(pc)) {
> > +		/* handle swap cache here */
> > +		add_orphan_list(page, pc);
> >  		return;
> > +	}
> >  
> >  	mz = page_cgroup_zoneinfo(pc);
> >  	MEM_CGROUP_ZSTAT(mz, lru) += 1;
> > @@ -471,6 +537,9 @@ static void mem_cgroup_lru_add_after_com
> >  	struct page_cgroup *pc = lookup_page_cgroup(page);
> >  
> >  	spin_lock_irqsave(&zone->lru_lock, flags);
> > +	if (PageCgroupOrphan(pc))
> > +		remove_orphan_list(pc);
> > +
> >  	/* link when the page is linked to LRU but page_cgroup isn't */
> >  	if (PageLRU(page) && list_empty(&pc->lru))
> >  		mem_cgroup_add_lru_list(page, page_lru(page));
> > @@ -784,6 +853,119 @@ static int mem_cgroup_count_children(str
> >  	return num;
> >  }
> >  
> > +
> > +
> > +/*
> > + * Using big number here for avoiding to free orphan swap-cache by readahead
> > + * We don't want to delete swap caches read by readahead.
> > + */
> > +static int orphan_thresh(void)
> > +{
> > +	int nr_pages = (1 << page_cluster); /* max size of a swap readahead */
> > +	int base = num_online_cpus() * 256; /* 1M per cpu if swap is 4k */
> > +
> > +	nr_pages *= nr_threads/2; /* nr_threads can be too big, too small */
> > +
> > +	/* too small value will kill readahead */
> > +	if (nr_pages < base)
> > +		return base;
> > +
> > +	/* too big is not suitable here */
> > +	if (nr_pages > base * 4)
> > +		return base * 4;
> > +
> > +	return nr_pages;
> > +}
> > +
> > +/*
> > + * In usual, *unused* swap cache are reclaimed by global LRU. But, if no one
> > + * kicks global LRU, they will not be reclaimed. When using memcg, it's trouble.
> > + */
> > +static int drain_orphan_swapcaches(int nid, int zid)
> > +{
> > +	struct page_cgroup *pc;
> > +	struct zone *zone;
> > +	struct page *page;
> > +	struct orphan_list_zone *lru = orphan_lru(nid, zid);
> > +	unsigned long flags;
> > +	int drain, scan;
> > +
> > +	zone = &NODE_DATA(nid)->node_zones[zid];
> > +	/* check one by one */
> > +	scan = 0;
> > +	drain = 0;
> > +	spin_lock_irqsave(&zone->lru_lock, flags);
> > +	while (!list_empty(&lru->list) && (scan < SWAP_CLUSTER_MAX*2)) {
> > +		scan++;
> > +		pc = list_entry(lru->list.next, struct page_cgroup, lru);
> > +		page = pc->page;
> > +		/* Rotate */
> > +		list_del(&pc->lru);
> > +		list_add_tail(&pc->lru, &lru->list);
> > +		/* get page for isolate_lru_page() */
> > +		if (get_page_unless_zero(page)) {
> > +			spin_unlock_irqrestore(&zone->lru_lock, flags);
> > +			if (!isolate_lru_page(page)) {
> > +				/* Now, This page is removed from LRU */
> > +				if (trylock_page(page)) {
> > +					drain += try_to_free_swap(page);
> > +					unlock_page(page);
> > +				}
> > +				putback_lru_page(page);
> > +			}
> > +			put_page(page);
> > +			spin_lock_irqsave(&zone->lru_lock, flags);
> > +		}
> > +	}
> > +	spin_unlock_irqrestore(&zone->lru_lock, flags);
> > +
> > +	return drain;
> > +}
> > +
> > +/* access without lock...serialization is not so important here. */
> > +static int last_visit;
> > +void try_delete_orphan_caches(struct work_struct *work)
> > +{
> > +	int nid, zid, drain;
> > +
> > +	nid = last_visit;
> > +	drain = 0;
> > +	while (drain < SWAP_CLUSTER_MAX) {
> > +		nid = next_node(nid, node_states[N_HIGH_MEMORY]);
> > +		if (nid == MAX_NUMNODES)
> > +			nid = 0;
> > +		last_visit = nid;
> > +		if (node_state(nid, N_HIGH_MEMORY))
> > +			for (zid = 0; zid < MAX_NR_ZONES; zid++)
> > +				drain += drain_orphan_swapcaches(nid, zid);
> > +		if (nid == 0)
> > +			break;
> > +	}
> > +}
> > +DECLARE_WORK(orphan_delete_work, try_delete_orphan_caches);
> > +
> > +static void check_orphan_stat(void)
> > +{
> > +	if (atomic_read(&nr_orphan_caches) > orphan_thresh())
> > +		schedule_work(&orphan_delete_work);
> > +}
> > +
> > +static __init void init_orphan_lru(void)
> > +{
> > +	struct orphan_list_node *opl;
> > +	int nid, zid;
> > +
> > +	for_each_node_state(nid, N_POSSIBLE) {
> > +		opl = kmalloc(sizeof(struct orphan_list_node),  GFP_KERNEL);
> > +		BUG_ON(!opl);
> > +		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> > +			INIT_LIST_HEAD(&opl->zone[zid].list);
> > +			opl->zone[zid].event = 0;
> > +		}
> > +		orphan_list[nid] = opl;
> > +	}
> > +}
> > +
> >  /*
> >   * Visit the first child (need not be the first child as per the ordering
> >   * of the cgroup list, since we track last_scanned_child) of @mem and use
> > @@ -2454,6 +2636,7 @@ mem_cgroup_create(struct cgroup_subsys *
> >  	/* root ? */
> >  	if (cont->parent == NULL) {
> >  		enable_swap_cgroup();
> > +		init_orphan_lru();
> >  		parent = NULL;
> >  	} else {
> >  		parent = mem_cgroup_from_cont(cont->parent);
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
