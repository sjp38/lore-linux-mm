Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3E08B6B009B
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 00:16:59 -0400 (EDT)
Date: Mon, 23 Mar 2009 14:04:19 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] fix unused/stale swap cache handling on memcg  v3
Message-Id: <20090323140419.40235ce3.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090323114118.8b45105f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
	<20090318101727.f00dfc2f.nishimura@mxp.nes.nec.co.jp>
	<20090318103418.7d38dce0.kamezawa.hiroyu@jp.fujitsu.com>
	<20090318125154.f8ffe652.nishimura@mxp.nes.nec.co.jp>
	<20090318175734.f5a8a446.kamezawa.hiroyu@jp.fujitsu.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

> > @@ -40,12 +41,24 @@ static inline void SetPageCgroup##uname(struct page_cgroup *pc)\
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
> 
> This TESTCLEAR, TESTSET is not necessary in this approarch.
> SETPCGFLAG() and CLEARPCGFLAG() seems to be enough.
> All changes (including commit) is under zone->lru_lock.
> 
Okey.

> > @@ -1238,6 +1274,10 @@ int mem_cgroup_newpage_charge(struct page *page,
> >  				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
> >  }
> >  
> > +static void
> > +__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
> > +					enum charge_type ctype);
> > +
> >  int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> >  				gfp_t gfp_mask)
> >  {
> > @@ -1274,16 +1314,6 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> >  		unlock_page_cgroup(pc);
> >  	}
> >  
> > -	if (do_swap_account && PageSwapCache(page)) {
> > -		mem = try_get_mem_cgroup_from_swapcache(page);
> > -		if (mem)
> > -			mm = NULL;
> > -		  else
> > -			mem = NULL;
> > -		/* SwapCache may be still linked to LRU now. */
> > -		mem_cgroup_lru_del_before_commit_swapcache(page);
> > -	}
> > -
> >  	if (unlikely(!mm && !mem))
> >  		mm = &init_mm;
> >  
> > @@ -1291,32 +1321,16 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> >  		return mem_cgroup_charge_common(page, mm, gfp_mask,
> >  				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
> >  
> > -	ret = mem_cgroup_charge_common(page, mm, gfp_mask,
> > -				MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
> > -	if (mem)
> > -		css_put(&mem->css);
> > -	if (PageSwapCache(page))
> > -		mem_cgroup_lru_add_after_commit_swapcache(page);
> > +	/* shmem */
> > +	if (PageSwapCache(page)) {
> > +		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &mem);
> > +		if (!ret)
> > +			__mem_cgroup_commit_charge_swapin(page, mem,
> > +					MEM_CGROUP_CHARGE_TYPE_SHMEM);
> > +	} else
> > +		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
> > +					MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
> >  
> > -	if (do_swap_account && !ret && PageSwapCache(page)) {
> > -		swp_entry_t ent = {.val = page_private(page)};
> > -		unsigned short id;
> > -		/* avoid double counting */
> > -		id = swap_cgroup_record(ent, 0);
> > -		rcu_read_lock();
> > -		mem = mem_cgroup_lookup(id);
> > -		if (mem) {
> > -			/*
> > -			 * We did swap-in. Then, this entry is doubly counted
> > -			 * both in mem and memsw. We uncharge it, here.
> > -			 * Recorded ID can be obsolete. We avoid calling
> > -			 * css_tryget()
> > -			 */
> > -			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > -			mem_cgroup_put(mem);
> > -		}
> > -		rcu_read_unlock();
> > -	}
> >  	return ret;
> >  }
> >  
> Nice clean-up here :)
> 
Thanks, I'll send a cleanup patch for this part later.

> > @@ -1359,18 +1373,40 @@ charge_cur_mm:
> >  	return __mem_cgroup_try_charge(mm, mask, ptr, true);
> >  }
> >  
> > -void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
> > +static void
> > +__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
> > +					enum charge_type ctype)
> >  {
> > -	struct page_cgroup *pc;
> > +	unsigned long flags;
> > +	struct zone *zone = page_zone(page);
> > +	struct page_cgroup *pc = lookup_page_cgroup(page);
> > +	int locked = 0;
> >  
> >  	if (mem_cgroup_disabled())
> >  		return;
> >  	if (!ptr)
> >  		return;
> > -	pc = lookup_page_cgroup(page);
> > -	mem_cgroup_lru_del_before_commit_swapcache(page);
> > -	__mem_cgroup_commit_charge(ptr, pc, MEM_CGROUP_CHARGE_TYPE_MAPPED);
> > -	mem_cgroup_lru_add_after_commit_swapcache(page);
> > +
> > +	/*
> > +	 * Forget old LRU when this page_cgroup is *not* used. This Used bit
> > +	 * is guarded by lock_page() because the page is SwapCache.
> > +	 * If this pc is on orphan LRU, it is also removed from orphan LRU here.
> > +	 */
> > +	if (!PageCgroupUsed(pc)) {
> > +		locked = 1;
> > +		spin_lock_irqsave(&zone->lru_lock, flags);
> > +		mem_cgroup_del_lru_list(page, page_lru(page));
> > +	}
> Maybe nice. I tried to use lock_page_cgroup() in add_list but I can't ;(
> I think this works well. But I wonder...why you have to check PageCgroupUsed() ?
> And is it correct ? Removing PageCgroupUsed() bit check is nice.
> (This will be "usually returns true" check, anyway)
> 
I've just copied lru_del_before_commit_swapcache.

As you say, this check will return false only in (C) case in memcg_test.txt,
and even in (C) case calling mem_cgroup_del_lru_list(and mem_cgroup_add_lru_list later)
would be no problem.

OK, I'll remove this check.

This is the updated version(w/o cache_charge cleanup).

BTW, Should I merge reclaim part based on your patch and post it ?


Thanks,
Daisuke Nishimura.
===
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/page_cgroup.h |    5 ++
 mm/memcontrol.c             |  137 +++++++++++++++++++++++++++++--------------
 2 files changed, 97 insertions(+), 45 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 7339c7b..e65e61e 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -26,6 +26,7 @@ enum {
 	PCG_LOCK,  /* page cgroup is locked */
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
+	PCG_ORPHAN, /* this is not used from memcg:s view but on global LRU */
 };
 
 #define TESTPCGFLAG(uname, lname)			\
@@ -46,6 +47,10 @@ TESTPCGFLAG(Cache, CACHE)
 TESTPCGFLAG(Used, USED)
 CLEARPCGFLAG(Used, USED)
 
+TESTPCGFLAG(Orphan, ORPHAN)
+SETPCGFLAG(Orphan, ORPHAN)
+CLEARPCGFLAG(Orphan, ORPHAN)
+
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2fc6d6c..3492286 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -371,6 +371,50 @@ static int mem_cgroup_walk_tree(struct mem_cgroup *root, void *data,
  * When moving account, the page is not on LRU. It's isolated.
  */
 
+/*
+ * Orphan List is a list for page_cgroup which is not free but not under
+ * any cgroup. SwapCache which is prefetched by readahead() is typical type but
+ * there are other corner cases.
+ *
+ * Usually, updates to this list happens when swap cache is readaheaded and
+ * finally used by process.
+ */
+
+/* for orphan page_cgroups, updated under zone->lru_lock. */
+
+struct orphan_list_node {
+	struct orphan_list_zone {
+		struct list_head list;
+	} zone[MAX_NR_ZONES];
+};
+struct orphan_list_node *orphan_list[MAX_NUMNODES] __read_mostly;
+
+static inline struct orphan_list_zone *orphan_lru(int nid, int zid)
+{
+	/*
+	 * 2 cases for this BUG_ON(), swapcache is generated while init.
+	 * or NID should be invalid.
+	 */
+	BUG_ON(!orphan_list[nid]);
+	return  &orphan_list[nid]->zone[zid];
+}
+
+static inline void remove_orphan_list(struct page_cgroup *pc)
+{
+	ClearPageCgroupOrphan(pc);
+	list_del_init(&pc->lru);
+}
+
+static void add_orphan_list(struct page *page, struct page_cgroup *pc)
+{
+	struct orphan_list_zone *opl;
+
+	SetPageCgroupOrphan(pc);
+	opl = orphan_lru(page_to_nid(page), page_zonenum(page));
+	list_add_tail(&pc->lru, &opl->list);
+}
+
+
 void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
 {
 	struct page_cgroup *pc;
@@ -380,6 +424,14 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
 	if (mem_cgroup_disabled())
 		return;
 	pc = lookup_page_cgroup(page);
+	/*
+	 * If the page is SwapCache and already on global LRU, it will be on
+	 * orphan list. remove here
+	 */
+	if (unlikely(PageCgroupOrphan(pc))) {
+		remove_orphan_list(pc);
+		return;
+	}
 	/* can happen while we handle swapcache. */
 	if (list_empty(&pc->lru) || !pc->mem_cgroup)
 		return;
@@ -433,51 +485,17 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
 	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
 	 */
 	smp_rmb();
-	if (!PageCgroupUsed(pc))
-		return;
+	if (!PageCgroupUsed(pc) && !PageCgroupOrphan(pc)) {
+		/* handle swap cache here */
+		add_orphan_list(page, pc);
+ 		return;
+	}
 
 	mz = page_cgroup_zoneinfo(pc);
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
 	list_add(&pc->lru, &mz->lists[lru]);
 }
 
-/*
- * At handling SwapCache, pc->mem_cgroup may be changed while it's linked to
- * lru because the page may.be reused after it's fully uncharged (because of
- * SwapCache behavior).To handle that, unlink page_cgroup from LRU when charge
- * it again. This function is only used to charge SwapCache. It's done under
- * lock_page and expected that zone->lru_lock is never held.
- */
-static void mem_cgroup_lru_del_before_commit_swapcache(struct page *page)
-{
-	unsigned long flags;
-	struct zone *zone = page_zone(page);
-	struct page_cgroup *pc = lookup_page_cgroup(page);
-
-	spin_lock_irqsave(&zone->lru_lock, flags);
-	/*
-	 * Forget old LRU when this page_cgroup is *not* used. This Used bit
-	 * is guarded by lock_page() because the page is SwapCache.
-	 */
-	if (!PageCgroupUsed(pc))
-		mem_cgroup_del_lru_list(page, page_lru(page));
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
-}
-
-static void mem_cgroup_lru_add_after_commit_swapcache(struct page *page)
-{
-	unsigned long flags;
-	struct zone *zone = page_zone(page);
-	struct page_cgroup *pc = lookup_page_cgroup(page);
-
-	spin_lock_irqsave(&zone->lru_lock, flags);
-	/* link when the page is linked to LRU but page_cgroup isn't */
-	if (PageLRU(page) && list_empty(&pc->lru))
-		mem_cgroup_add_lru_list(page, page_lru(page));
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
-}
-
-
 void mem_cgroup_move_lists(struct page *page,
 			   enum lru_list from, enum lru_list to)
 {
@@ -784,6 +802,24 @@ static int mem_cgroup_count_children(struct mem_cgroup *mem)
 	return num;
 }
 
+static __init void init_orphan_lru(void)
+{
+	struct orphan_list_node *opl;
+	int nid, zid;
+	int size = sizeof(struct orphan_list_node);
+
+	for_each_node_state(nid, N_POSSIBLE) {
+		if (node_state(nid, N_NORMAL_MEMORY))
+			opl = kmalloc_node(size,  GFP_KERNEL, nid);
+		else
+			opl = kmalloc(size, GFP_KERNEL);
+		BUG_ON(!opl);
+		for (zid = 0; zid < MAX_NR_ZONES; zid++)
+			INIT_LIST_HEAD(&opl->zone[zid].list);
+		orphan_list[nid] = opl;
+	}
+}
+
 /*
  * Visit the first child (need not be the first child as per the ordering
  * of the cgroup list, since we track last_scanned_child) of @mem and use
@@ -1341,16 +1377,28 @@ static void
 __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
 					enum charge_type ctype)
 {
-	struct page_cgroup *pc;
+	unsigned long flags;
+	struct zone *zone = page_zone(page);
+	struct page_cgroup *pc = lookup_page_cgroup(page);
 
 	if (mem_cgroup_disabled())
 		return;
 	if (!ptr)
 		return;
-	pc = lookup_page_cgroup(page);
-	mem_cgroup_lru_del_before_commit_swapcache(page);
+
+	/* If this pc is on orphan LRU, it is removed from orphan list here. */
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	mem_cgroup_del_lru_list(page, page_lru(page));
+
+	/* We should hold zone->lru_lock to protect PCG_ORPHAN. */
+	VM_BUG_ON(PageCgroupOrphan(pc));
 	__mem_cgroup_commit_charge(ptr, pc, ctype);
-	mem_cgroup_lru_add_after_commit_swapcache(page);
+
+	/* link when the page is linked to LRU but page_cgroup isn't */
+	if (PageLRU(page) && list_empty(&pc->lru))
+		mem_cgroup_add_lru_list(page, page_lru(page));
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
+
 	/*
 	 * Now swap is on-memory. This means this page may be
 	 * counted both as mem and swap....double count.
@@ -1376,8 +1424,6 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
 		}
 		rcu_read_unlock();
 	}
-	/* add this page(page_cgroup) to the LRU we want. */
-
 }
 
 void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
@@ -2438,6 +2484,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
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
