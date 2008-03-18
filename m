Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2IICqeE029241
	for <linux-mm@kvack.org>; Wed, 19 Mar 2008 05:12:52 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2IIDU0C2769014
	for <linux-mm@kvack.org>; Wed, 19 Mar 2008 05:13:30 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2IIDUJq032372
	for <linux-mm@kvack.org>; Wed, 19 Mar 2008 05:13:30 +1100
Date: Tue, 18 Mar 2008 23:41:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/7] memcg: page migration
Message-ID: <20080318181141.GD24473@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com> <20080314191543.7b0f0fa3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20080314191543.7b0f0fa3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-03-14 19:15:43]:

> Christoph Lameter, writer of page migraion, suggested me that
> new page_cgroup should be assignd to new page at page is allocated.
> This patch changes migration path to assign page_cgroup of new page
> at allocation.
> 
> Pros:
>  - We can avoid compliated lock depndencies.
> Cons:
>  - Have to handle a page which is not on LRU in memory resource controller.
> 
> For pages not-on-LRU, I added PAGE_CGROUP_FLAG_MIGRATION and
> mem_cgroup->migrations counter.
> (force_empty will not end while migration because new page's
>  refcnt is alive until the end of migration.)
> 
> I think this version simplifies complicated lock dependency in page migraiton,
> but I admit this adds some hacky codes. If you have good idea, please advise me.
> 
> Works well under my tests.

This code is easier to read as well. I think this a good approach. To
be honest, I've not had the chance to test page migration very often.
Should we update Documentation/controllers/memory.txt to indicate that
migration might prevent force_empty and hence rmdir() from working?

> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 
> 
> 
>  include/linux/memcontrol.h  |    5 -
>  include/linux/page_cgroup.h |    1 
>  mm/memcontrol.c             |  153 +++++++++++++++++++++++++++-----------------
>  mm/migrate.c                |   22 ++++--
>  4 files changed, 113 insertions(+), 68 deletions(-)
> 
> Index: mm-2.6.25-rc5-mm1/include/linux/memcontrol.h
> ===================================================================
> --- mm-2.6.25-rc5-mm1.orig/include/linux/memcontrol.h
> +++ mm-2.6.25-rc5-mm1/include/linux/memcontrol.h
> @@ -48,9 +48,8 @@ int task_in_mem_cgroup(struct task_struc
>  #define mm_match_cgroup(mm, cgroup)	\
>  	((cgroup) == rcu_dereference((mm)->mem_cgroup))
> 
> -extern int mem_cgroup_prepare_migration(struct page *page);
> -extern void mem_cgroup_end_migration(struct page *page);
> -extern void mem_cgroup_page_migration(struct page *page, struct page *newpage);
> +extern int mem_cgroup_prepare_migration(struct page *, struct page *);
> +extern void mem_cgroup_end_migration(struct page *);
> 
>  /*
>   * For memory reclaim.
> Index: mm-2.6.25-rc5-mm1/include/linux/page_cgroup.h
> ===================================================================
> --- mm-2.6.25-rc5-mm1.orig/include/linux/page_cgroup.h
> +++ mm-2.6.25-rc5-mm1/include/linux/page_cgroup.h
> @@ -23,6 +23,7 @@ struct page_cgroup {
>  /* flags */
>  #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache. */
>  #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* is on active list */
> +#define PAGE_CGROUP_FLAG_MIGRATION (0x4) /* is on active list */
> 
>  /*
>   * Lookup and return page_cgroup struct.
> Index: mm-2.6.25-rc5-mm1/mm/memcontrol.c
> ===================================================================
> --- mm-2.6.25-rc5-mm1.orig/mm/memcontrol.c
> +++ mm-2.6.25-rc5-mm1/mm/memcontrol.c
> @@ -147,6 +147,8 @@ struct mem_cgroup {
>  	 * statistics.
>  	 */
>  	struct mem_cgroup_stat stat;
> +	/* migration is under going ? */
> +	atomic_t migrations;
>  };
>  static struct mem_cgroup init_mem_cgroup;
> 
> @@ -164,6 +166,9 @@ static enum zone_type page_cgroup_zid(st
>  enum charge_type {
>  	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
>  	MEM_CGROUP_CHARGE_TYPE_MAPPED,
> +	/* this 2 types are not linked to LRU */
          ^^^^^
          these
> +	MEM_CGROUP_CHARGE_TYPE_MIGRATION_CACHE,
> +	MEM_CGROUP_CHARGE_TYPE_MIGRATION_MAPPED,
>  };
> 
>  /*
> @@ -480,7 +485,8 @@ unsigned long mem_cgroup_isolate_pages(u
>   * < 0 if the cgroup is over its limit
>   */
>  static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
> -				gfp_t gfp_mask, enum charge_type ctype)
> +				gfp_t gfp_mask, enum charge_type ctype,
> +				struct mem_cgroup *memcg)

I think it'll be a good idea to add a comment stating that memcg is
NOT NULL only for migration cases.

>  {
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc;
> @@ -514,16 +520,21 @@ static int mem_cgroup_charge_common(stru
>  	 * thread group leader migrates. It's possible that mm is not
>  	 * set, if so charge the init_mm (happens for pagecache usage).
>  	 */
> -	if (!mm)
> +	if (!mm && !memcg)
>  		mm = &init_mm;
> 
> -	rcu_read_lock();
> -	mem = rcu_dereference(mm->mem_cgroup);
> -	/*
> -	 * For every charge from the cgroup, increment reference count
> -	 */
> -	css_get(&mem->css);
> -	rcu_read_unlock();
> +	if (mm) {
> +		rcu_read_lock();
> +		mem = rcu_dereference(mm->mem_cgroup);
> +		/*
> +	 	* For every charge from the cgroup, increment reference count
> +	 	*/
> +		css_get(&mem->css);
> +		rcu_read_unlock();
> +	} else {
> +		mem = memcg;
> +		css_get(&mem->css);
> +	}
> 
>  	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
>  		if (!(gfp_mask & __GFP_WAIT))
> @@ -566,12 +577,24 @@ static int mem_cgroup_charge_common(stru
>  	pc->refcnt = 1;
>  	pc->mem_cgroup = mem;
>  	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
> -	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
> +	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE ||
> +		ctype == MEM_CGROUP_CHARGE_TYPE_MIGRATION_CACHE)
>  		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
> -	mz = page_cgroup_zoneinfo(pc);
> -	spin_lock(&mz->lru_lock);
> -	__mem_cgroup_add_list(pc);
> -	spin_unlock(&mz->lru_lock);
> +
> +	if (ctype == MEM_CGROUP_CHARGE_TYPE_MIGRATION_MAPPED ||
> +		ctype == MEM_CGROUP_CHARGE_TYPE_MIGRATION_CACHE)
> +		pc->flags |= PAGE_CGROUP_FLAG_MIGRATION;
> +
> +	if (pc->flags & PAGE_CGROUP_FLAG_MIGRATION) {
> +		/* just remember there is migration */
> +		atomic_inc(&mem->migrations);
> +	} else {
> +		/* add to LRU */
> +		mz = page_cgroup_zoneinfo(pc);
> +		spin_lock(&mz->lru_lock);
> +		__mem_cgroup_add_list(pc);
> +		spin_unlock(&mz->lru_lock);
> +	}
>  	spin_unlock_irqrestore(&pc->lock, flags);
> 
>  success:
> @@ -584,7 +607,7 @@ nomem:
>  int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
>  {
>  	return mem_cgroup_charge_common(page, mm, gfp_mask,
> -				MEM_CGROUP_CHARGE_TYPE_MAPPED);
> +				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
>  }
> 
>  int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> @@ -593,7 +616,7 @@ int mem_cgroup_cache_charge(struct page 
>  	if (!mm)
>  		mm = &init_mm;
>  	return mem_cgroup_charge_common(page, mm, gfp_mask,
> -				MEM_CGROUP_CHARGE_TYPE_CACHE);
> +				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
>  }
> 
>  /*
> @@ -637,65 +660,75 @@ void mem_cgroup_uncharge_page(struct pag
>  }
> 
>  /*
> - * Returns non-zero if a page (under migration) has valid page_cgroup member.
> - * Refcnt of page_cgroup is incremented.
> + * Pre-charge against newpage while moving a page.
> + * This function is called before taking page locks.
>   */
> -int mem_cgroup_prepare_migration(struct page *page)
> +int mem_cgroup_prepare_migration(struct page *page, struct page *newpage)
>  {
>  	struct page_cgroup *pc;
> +	struct mem_cgroup *mem = NULL;
> +	int ret = 0;
> +	enum charge_type type;
> +	unsigned long flags;
> 
>  	if (mem_cgroup_subsys.disabled)
> -		return 0;
> +		return ret;
> +	/* check newpage isn't under memory resource control */
> +	pc = get_page_cgroup(newpage, GFP_ATOMIC, false);
> +	VM_BUG_ON(pc && pc->refcnt);
> 
> -	lock_page_cgroup(page);
> -	pc = page_get_page_cgroup(page);
> -	if (pc)
> -		pc->ref_cnt++;
> -	unlock_page_cgroup(page);
> -	return pc != NULL;
> -}
> +	pc = get_page_cgroup(page, GFP_ATOMIC, false);
> +	spin_lock_irqsave(&pc->lock, flags);
> +	if (pc && pc->refcnt) {
> +		mem = pc->mem_cgroup;
> +		if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
> +			type = MEM_CGROUP_CHARGE_TYPE_MIGRATION_CACHE;
> +		else
> +			type = MEM_CGROUP_CHARGE_TYPE_MIGRATION_MAPPED;
> +	}
> +	spin_unlock_irqrestore(&pc->lock, flags);
> 
> -void mem_cgroup_end_migration(struct page *page)
> -{
> -	mem_cgroup_uncharge_page(page);
> +	if (mem) {
> +		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
> +				type, mem);
> +	}
> +	return ret;
>  }
> -
>  /*
> - * We know both *page* and *newpage* are now not-on-LRU and PG_locked.
> - * And no race with uncharge() routines because page_cgroup for *page*
> - * has extra one reference by mem_cgroup_prepare_migration.
> + * At the end of migration, we'll push newpage to LRU and
> + * drop one refcnt which added at prepare_migration.
>   */
> -void mem_cgroup_page_migration(struct page *page, struct page *newpage)
> +void mem_cgroup_end_migration(struct page *newpage)
>  {
>  	struct page_cgroup *pc;
>  	struct mem_cgroup_per_zone *mz;
> +	struct mem_cgroup *mem;
>  	unsigned long flags;
> +	int moved = 0;
> 
> -	lock_page_cgroup(page);
> -	pc = page_get_page_cgroup(page);
> -	if (!pc) {
> -		unlock_page_cgroup(page);
> +	if (mem_cgroup_subsys.disabled)
>  		return;
> -	}
> -
> -	mz = page_cgroup_zoneinfo(pc);
> -	spin_lock_irqsave(&mz->lru_lock, flags);
> -	__mem_cgroup_remove_list(pc);
> -	spin_unlock_irqrestore(&mz->lru_lock, flags);
> -
> -	page_assign_page_cgroup(page, NULL);
> -	unlock_page_cgroup(page);
> -
> -	pc->page = newpage;
> -	lock_page_cgroup(newpage);
> -	page_assign_page_cgroup(newpage, pc);
> 
> -	mz = page_cgroup_zoneinfo(pc);
> -	spin_lock_irqsave(&mz->lru_lock, flags);
> -	__mem_cgroup_add_list(pc);
> -	spin_unlock_irqrestore(&mz->lru_lock, flags);
> -
> -	unlock_page_cgroup(newpage);
> +	pc = get_page_cgroup(newpage, GFP_ATOMIC, false);
> +	if (!pc)
> +		return;
> +	spin_lock_irqsave(&pc->lock, flags);
> +	if (pc->flags & PAGE_CGROUP_FLAG_MIGRATION) {
> +		pc->flags &= ~PAGE_CGROUP_FLAG_MIGRATION;
> +		mem = pc->mem_cgroup;
> +		mz = page_cgroup_zoneinfo(pc);
> +		spin_lock(&mz->lru_lock);
> +		__mem_cgroup_add_list(pc);
> +		spin_unlock(&mz->lru_lock);
> +		moved = 1;
> +	}
> +	spin_unlock_irqrestore(&pc->lock, flags);
> +	if (!pc)
> +		return;
> +	if (moved) {
> +		mem_cgroup_uncharge_page(newpage);

Not sure I understand this part correctly? Why uncharge on move? Is it
just to drop the extra reference count we have? Also should we
disallow task migration as in migrating to different cgroups when page
migration is in progress?

> +		atomic_dec(&mem->migrations);
> +	}
>  }
> 
>  /*
> @@ -757,6 +790,10 @@ static int mem_cgroup_force_empty(struct
>  	while (mem->res.usage > 0) {
>  		if (atomic_read(&mem->css.cgroup->count) > 0)
>  			goto out;
> +		if (atomic_read(&mem->migrations)) {
> +			cond_resched();
> +			continue;
> +		}
>  		for_each_node_state(node, N_POSSIBLE)
>  			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
>  				struct mem_cgroup_per_zone *mz;
> Index: mm-2.6.25-rc5-mm1/mm/migrate.c
> ===================================================================
> --- mm-2.6.25-rc5-mm1.orig/mm/migrate.c
> +++ mm-2.6.25-rc5-mm1/mm/migrate.c
> @@ -358,6 +358,12 @@ static int migrate_page_move_mapping(str
> 
>  	write_unlock_irq(&mapping->tree_lock);
> 
> +	/* by mem_cgroup_prepare_migration, newpage is already
> +	   assigned to valid cgroup. and current->mm and GFP_ATOMIC
> +	   will not be used...*/
> +	mem_cgroup_uncharge_page(page);
> +	mem_cgroup_cache_charge(newpage, current->mm ,GFP_ATOMIC);
> +
>  	return 0;
>  }
> 
> @@ -603,7 +609,6 @@ static int move_to_new_page(struct page 
>  		rc = fallback_migrate_page(mapping, newpage, page);
> 
>  	if (!rc) {
> -		mem_cgroup_page_migration(page, newpage);
>  		remove_migration_ptes(page, newpage);
>  	} else
>  		newpage->mapping = NULL;
> @@ -633,6 +638,12 @@ static int unmap_and_move(new_page_t get
>  		/* page was freed from under us. So we are done. */
>  		goto move_newpage;
> 
> +	charge = mem_cgroup_prepare_migration(page, newpage);
> +	if (charge == -ENOMEM) {
> +		rc = -ENOMEM;
> +		goto move_newpage;
> +	}
> +
>  	rc = -EAGAIN;
>  	if (TestSetPageLocked(page)) {
>  		if (!force)
> @@ -684,19 +695,14 @@ static int unmap_and_move(new_page_t get
>  		goto rcu_unlock;
>  	}
> 
> -	charge = mem_cgroup_prepare_migration(page);
>  	/* Establish migration ptes or remove ptes */
>  	try_to_unmap(page, 1);
> 
>  	if (!page_mapped(page))
>  		rc = move_to_new_page(newpage, page);
> 
> -	if (rc) {
> +	if (rc)
>  		remove_migration_ptes(page, page);
> -		if (charge)
> -			mem_cgroup_end_migration(page);
> -	} else if (charge)
> - 		mem_cgroup_end_migration(newpage);
>  rcu_unlock:
>  	if (rcu_locked)
>  		rcu_read_unlock();
> @@ -717,6 +723,8 @@ unlock:
>  	}
> 
>  move_newpage:
> +	if (!charge)
> +		mem_cgroup_end_migration(newpage);
>  	/*
>  	 * Move the new page to the LRU. If migration was not successful
>  	 * then this will free the page.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
