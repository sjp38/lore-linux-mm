Date: Tue, 18 Mar 2008 10:17:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/7] memcg: page migration
Message-Id: <20080318101710.bd68c836.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47DDD939.7050309@cn.fujitsu.com>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314191543.7b0f0fa3.kamezawa.hiroyu@jp.fujitsu.com>
	<47DDD939.7050309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Mar 2008 11:36:41 +0900
Li Zefan <lizf@cn.fujitsu.com> wrote:

> > @@ -147,6 +147,8 @@ struct mem_cgroup {
> >  	 * statistics.
> >  	 */
> >  	struct mem_cgroup_stat stat;
> > +	/* migration is under going ? */
> 
> Please stick to this comment style:
> 	/*
> 	 * ...
> 	 */
> 
ok.


> > +	pc = get_page_cgroup(page, GFP_ATOMIC, false);
> > +	spin_lock_irqsave(&pc->lock, flags);
> > +	if (pc && pc->refcnt) {
> 
> You check if (pc) after you deference it by &pc->lock, it's a bug
> here or the check is unneeded ?
> 
Ah, BUG. Thanks.

> > +		mem = pc->mem_cgroup;
> > +		if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
> > +			type = MEM_CGROUP_CHARGE_TYPE_MIGRATION_CACHE;
> > +		else
> > +			type = MEM_CGROUP_CHARGE_TYPE_MIGRATION_MAPPED;
> > +	}
> > +	spin_unlock_irqrestore(&pc->lock, flags);
> >  
> > -void mem_cgroup_end_migration(struct page *page)
> > -{
> > -	mem_cgroup_uncharge_page(page);
> > +	if (mem) {
> > +		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
> > +				type, mem);
> > +	}
> > +	return ret;
> >  }
> > -
> >  /*
> > - * We know both *page* and *newpage* are now not-on-LRU and PG_locked.
> > - * And no race with uncharge() routines because page_cgroup for *page*
> > - * has extra one reference by mem_cgroup_prepare_migration.
> > + * At the end of migration, we'll push newpage to LRU and
> > + * drop one refcnt which added at prepare_migration.
> >   */
> > -void mem_cgroup_page_migration(struct page *page, struct page *newpage)
> > +void mem_cgroup_end_migration(struct page *newpage)
> >  {
> >  	struct page_cgroup *pc;
> >  	struct mem_cgroup_per_zone *mz;
> > +	struct mem_cgroup *mem;
> >  	unsigned long flags;
> > +	int moved = 0;
> >  
> > -	lock_page_cgroup(page);
> > -	pc = page_get_page_cgroup(page);
> > -	if (!pc) {
> > -		unlock_page_cgroup(page);
> > +	if (mem_cgroup_subsys.disabled)
> >  		return;
> > -	}
> > -
> > -	mz = page_cgroup_zoneinfo(pc);
> > -	spin_lock_irqsave(&mz->lru_lock, flags);
> > -	__mem_cgroup_remove_list(pc);
> > -	spin_unlock_irqrestore(&mz->lru_lock, flags);
> > -
> > -	page_assign_page_cgroup(page, NULL);
> > -	unlock_page_cgroup(page);
> > -
> > -	pc->page = newpage;
> > -	lock_page_cgroup(newpage);
> > -	page_assign_page_cgroup(newpage, pc);
> >  
> > -	mz = page_cgroup_zoneinfo(pc);
> > -	spin_lock_irqsave(&mz->lru_lock, flags);
> > -	__mem_cgroup_add_list(pc);
> > -	spin_unlock_irqrestore(&mz->lru_lock, flags);
> > -
> > -	unlock_page_cgroup(newpage);
> > +	pc = get_page_cgroup(newpage, GFP_ATOMIC, false);
> > +	if (!pc)
> > +		return;
> > +	spin_lock_irqsave(&pc->lock, flags);
> > +	if (pc->flags & PAGE_CGROUP_FLAG_MIGRATION) {
> > +		pc->flags &= ~PAGE_CGROUP_FLAG_MIGRATION;
> > +		mem = pc->mem_cgroup;
> > +		mz = page_cgroup_zoneinfo(pc);
> > +		spin_lock(&mz->lru_lock);
> > +		__mem_cgroup_add_list(pc);
> > +		spin_unlock(&mz->lru_lock);
> > +		moved = 1;
> > +	}
> > +	spin_unlock_irqrestore(&pc->lock, flags);
> > +	if (!pc)
> > +		return;
> 
> redundant check ?
> 
yes. will fix.


Thank you.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
