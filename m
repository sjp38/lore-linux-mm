Date: Wed, 10 Sep 2008 11:35:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Approach #2] [RFC][PATCH] Remove cgroup member from struct
 page
Message-Id: <20080910113546.7e5b2fe8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48C72CBD.6040602@linux.vnet.ibm.com>
References: <48C66AF8.5070505@linux.vnet.ibm.com>
	<20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com>
	<200809091358.28350.nickpiggin@yahoo.com.au>
	<20080909135317.cbff4871.kamezawa.hiroyu@jp.fujitsu.com>
	<200809091500.10619.nickpiggin@yahoo.com.au>
	<20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com>
	<30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com>
	<20080910012048.GA32752@balbir.in.ibm.com>
	<20080910104940.a7ec9b5a.kamezawa.hiroyu@jp.fujitsu.com>
	<48C72CBD.6040602@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 09 Sep 2008 19:11:09 -0700
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 1. This is nonsense...do you know the memory map of IBM's (maybe ppc) machine ?
> > Node's memory are splitted into several pieces and not ordered by node number.
> > example)
> >    Node 0 | Node 1 | Node 2 | Node 1 | Node 2 | 
> > 
> > This seems special but when I helped SPARSEMEM and MEMORY_HOTPLUG,
> > I saw mannnny kinds of memory map. As you wrote, this should be re-designed.
> > 
> 
> Thanks, so that means that we cannot before hand predict the size of pcg_map[n],
> we'll need to do an incremental addition to pcg_map?
Or use some "allocate a chunk of page_cgroup for a chunk of continuous pages".
(This is the reason I mentioned SPARSEMEM.)

> 
> > 2. If pre-allocating all is ok, I stop my work. Mine is of-no-use.
> 
> One of the goals of this patch is refinement, it is a starting piece, something
> I shared very early. I am not asking you to stop your work. While I think
> pre-allocating is not the best way to do this, the trade off is the sparseness
> of the machine. I don't mind doing it in other ways, but we'll still need to do
> some batch'ed preallocation (of a smaller size maybe).
> 
Hmm, maybe clarifying trade-off and comapring them is the first step.
I'll post my idea if it comes.

> > But you have to know that by pre-allocationg, we can't use avoid-lru-lock
> > by batch like page_vec technique. We can't delay uncharge because a page
> > can be reused soon.
> > 
> > 
> 
> Care to elaborate on this? Why not? If the page is reused, we act on the batch
> and sync it up
> 
And touch vec on other cpu ? The reason "vec" is fast is because it's per-cpu.
If we want to use "delaying", we'll have to make page_cgroup unused and not-on-lru
when the page of page_cgroup is added to free queue.

> > 
> > 
> >> +	pcg_map[n] = alloc_bootmem_node(pgdat, size);
> >> +	/*
> >> +	 * We can do smoother recovery
> >> +	 */
> >> +	BUG_ON(!pcg_map[n]);
> >> +	return 0;
> >>  }
> >>  
> >> -static int try_lock_page_cgroup(struct page *page)
> >> +void page_cgroup_init(int nid, unsigned long pfn)
> >>  {
> >> -	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> >> +	unsigned long node_pfn;
> >> +	struct page_cgroup *pc;
> >> +
> >> +	if (mem_cgroup_subsys.disabled)
> >> +		return;
> >> +
> >> +	node_pfn = pfn - NODE_DATA(nid)->node_start_pfn;
> >> +	pc = &pcg_map[nid][node_pfn];
> >> +
> >> +	BUG_ON(!pc);
> >> +	pc->flags = PAGE_CGROUP_FLAG_VALID;
> >> +	INIT_LIST_HEAD(&pc->lru);
> >> +	pc->page = NULL;
> > This NULL is unnecessary. pc->page = pnf_to_page(pfn) always.
> > 
> 
> OK
> 
> > 
> >> +	pc->mem_cgroup = NULL;
> >>  }
> >>  
> >> -static void unlock_page_cgroup(struct page *page)
> >> +struct page_cgroup *__page_get_page_cgroup(struct page *page, bool lock,
> >> +						bool trylock)
> >>  {
> >> -	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> >> +	struct page_cgroup *pc;
> >> +	int ret;
> >> +	int node = page_to_nid(page);
> >> +	unsigned long pfn;
> >> +
> >> +	pfn = page_to_pfn(page) - NODE_DATA(node)->node_start_pfn;
> >> +	pc = &pcg_map[node][pfn];
> >> +	BUG_ON(!(pc->flags & PAGE_CGROUP_FLAG_VALID));
> >> +	if (lock)
> >> +		lock_page_cgroup(pc);
> >> +	else if (trylock) {
> >> +		ret = trylock_page_cgroup(pc);
> >> +		if (!ret)
> >> +			pc = NULL;
> >> +	}
> >> +
> >> +	return pc;
> >> +}
> >> +
> >> +/*
> >> + * Should be called with page_cgroup lock held. Any additions to pc->flags
> >> + * should be reflected here. This might seem ugly, refine it later.
> >> + */
> >> +void page_clear_page_cgroup(struct page_cgroup *pc)
> >> +{
> >> +	pc->flags &= ~PAGE_CGROUP_FLAG_INUSE;
> >>  }
> >>  
> >>  static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
> >> @@ -377,17 +443,15 @@ void mem_cgroup_move_lists(struct page *
> >>  	 * safely get to page_cgroup without it, so just try_lock it:
> >>  	 * mem_cgroup_isolate_pages allows for page left on wrong list.
> >>  	 */
> >> -	if (!try_lock_page_cgroup(page))
> >> +	pc = page_get_page_cgroup_trylock(page);
> >> +	if (!pc)
> >>  		return;
> >>  
> >> -	pc = page_get_page_cgroup(page);
> >> -	if (pc) {
> >> -		mz = page_cgroup_zoneinfo(pc);
> >> -		spin_lock_irqsave(&mz->lru_lock, flags);
> >> -		__mem_cgroup_move_lists(pc, lru);
> >> -		spin_unlock_irqrestore(&mz->lru_lock, flags);
> >> -	}
> >> -	unlock_page_cgroup(page);
> >> +	mz = page_cgroup_zoneinfo(pc);
> >> +	spin_lock_irqsave(&mz->lru_lock, flags);
> >> +	__mem_cgroup_move_lists(pc, lru);
> >> +	spin_unlock_irqrestore(&mz->lru_lock, flags);
> >> +	unlock_page_cgroup(pc);
> > 
> > This lock/unlock_page_cgroup is against what ?
> > 
> 
> We use page_cgroup_zoneinfo(pc), we want to make sure pc does not disappear or
> change from underneath us.
> 
> >>  }
> >>  
> >>  /*
> >> @@ -521,10 +585,6 @@ static int mem_cgroup_charge_common(stru
> >>  	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> >>  	struct mem_cgroup_per_zone *mz;
> >>  
> >> -	pc = kmem_cache_alloc(page_cgroup_cache, gfp_mask);
> >> -	if (unlikely(pc == NULL))
> >> -		goto err;
> >> -
> >>  	/*
> >>  	 * We always charge the cgroup the mm_struct belongs to.
> >>  	 * The mm_struct's mem_cgroup changes on task migration if the
> >> @@ -567,43 +627,40 @@ static int mem_cgroup_charge_common(stru
> >>  		}
> >>  	}
> >>  
> >> +	pc = page_get_page_cgroup_locked(page);
> >> +	if (pc->flags & PAGE_CGROUP_FLAG_INUSE) {
> >> +		unlock_page_cgroup(pc);
> >> +		res_counter_uncharge(&mem->res, PAGE_SIZE);
> >> +		css_put(&mem->css);
> >> +		goto done;
> >> +	}
> >> +
> > Can this happen ? Our direction should be
> > VM_BUG_ON(pc->flags & PAGE_CGROUP_FLAG_INUSE)
> > 
> 
> Yes, it can.. several people trying to map the same page at once. Can't we race
> doing that?
> 
I'll dig this. My version(lockless) already removed this and use VM_BUG_ON()

> > 
> > 
> >>  	pc->mem_cgroup = mem;
> >>  	pc->page = page;
> >> +	pc->flags |= PAGE_CGROUP_FLAG_INUSE;
> >> +
> >>  	/*
> >>  	 * If a page is accounted as a page cache, insert to inactive list.
> >>  	 * If anon, insert to active list.
> >>  	 */
> >>  	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE) {
> >> -		pc->flags = PAGE_CGROUP_FLAG_CACHE;
> >> +		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
> >>  		if (page_is_file_cache(page))
> >>  			pc->flags |= PAGE_CGROUP_FLAG_FILE;
> >>  		else
> >>  			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
> >>  	} else
> >> -		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
> >> -
> >> -	lock_page_cgroup(page);
> >> -	if (unlikely(page_get_page_cgroup(page))) {
> >> -		unlock_page_cgroup(page);
> >> -		res_counter_uncharge(&mem->res, PAGE_SIZE);
> >> -		css_put(&mem->css);
> >> -		kmem_cache_free(page_cgroup_cache, pc);
> >> -		goto done;
> >> -	}
> >> -	page_assign_page_cgroup(page, pc);
> >> +		pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
> >>  
> >>  	mz = page_cgroup_zoneinfo(pc);
> >>  	spin_lock_irqsave(&mz->lru_lock, flags);
> >>  	__mem_cgroup_add_list(mz, pc);
> >>  	spin_unlock_irqrestore(&mz->lru_lock, flags);
> >> -
> >> -	unlock_page_cgroup(page);
> >> +	unlock_page_cgroup(pc);
> > 
> > Is this lock/unlock_page_cgroup is for what kind of race ?
> 
> for setting pc->flags and for setting pc->page and pc->mem_cgroup.
> 

Hmm...there is a confustion, maybe.

The page_cgroup is now 1:1 to struct page. Then, we can guarantee that

- There is no race between charge v.s. uncharge.

Only problem is force_empty. (But it's difficult..)

This means pc->mem_cgroup is safe here. 
And pc->flags should be atomic flags, anyway. I believe we have to record
"Dirty bit" at el, later.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
