Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m7Q4tveG023311
	for <linux-mm@kvack.org>; Tue, 26 Aug 2008 10:25:57 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7Q4tuPb1777780
	for <linux-mm@kvack.org>; Tue, 26 Aug 2008 10:25:56 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m7Q4ttL2002121
	for <linux-mm@kvack.org>; Tue, 26 Aug 2008 10:25:56 +0530
Message-ID: <48B38CDB.1070102@linux.vnet.ibm.com>
Date: Tue, 26 Aug 2008 10:25:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 3/14]  memcg: atomic_flags
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com> <20080822203228.98adf408.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822203228.98adf408.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This patch makes page_cgroup->flags to be atomic_ops and define
> functions (and macros) to access it.
> 
> This patch itself makes memcg slow but this patch's final purpose is 
> to remove lock_page_cgroup() and allowing fast access to page_cgroup.
> 

That is a cause of worry, do the patches that follow help performance? How do we
benefit from faster access to page_cgroup() if the memcg controller becomes slower?

> Before trying to modify memory resource controller, this atomic operation
> on flags is necessary.
> Changelog (v1) -> (v2)
>  - no changes
> Changelog  (preview) -> (v1):
>  - patch ordering is changed.
>  - Added macro for defining functions for Test/Set/Clear bit.
>  - made the names of flags shorter.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  mm/memcontrol.c |  108 +++++++++++++++++++++++++++++++++++++++-----------------
>  1 file changed, 77 insertions(+), 31 deletions(-)
> 
> Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
> ===================================================================
> --- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
> +++ mmtom-2.6.27-rc3+/mm/memcontrol.c
> @@ -163,12 +163,57 @@ struct page_cgroup {
>  	struct list_head lru;		/* per cgroup LRU list */
>  	struct page *page;
>  	struct mem_cgroup *mem_cgroup;
> -	int flags;
> +	unsigned long flags;
>  };
> -#define PAGE_CGROUP_FLAG_CACHE	   (0x1)	/* charged as cache */
> -#define PAGE_CGROUP_FLAG_ACTIVE    (0x2)	/* page is active in this cgroup */
> -#define PAGE_CGROUP_FLAG_FILE	   (0x4)	/* page is file system backed */
> -#define PAGE_CGROUP_FLAG_UNEVICTABLE (0x8)	/* page is unevictableable */
> +
> +enum {
> +	/* flags for mem_cgroup */
> +	Pcg_CACHE, /* charged as cache */

Why Pcg_CACHE and not PCG_CACHE or PAGE_CGROUP_CACHE? I think the latter is more
readable, no?

> +	/* flags for LRU placement */
> +	Pcg_ACTIVE, /* page is active in this cgroup */
> +	Pcg_FILE, /* page is file system backed */
> +	Pcg_UNEVICTABLE, /* page is unevictableable */
> +};
> +
> +#define TESTPCGFLAG(uname, lname)			\
                      ^^ uname and lname?
How about TEST_PAGE_CGROUP_FLAG(func, bit)

> +static inline int Pcg##uname(struct page_cgroup *pc)	\
> +	{ return test_bit(Pcg_##lname, &pc->flags); }
> +

I would prefer PageCgroup##func

> +#define SETPCGFLAG(uname, lname)			\
> +static inline void SetPcg##uname(struct page_cgroup *pc)\
> +	{ set_bit(Pcg_##lname, &pc->flags);  }
> +
> +#define CLEARPCGFLAG(uname, lname)			\
> +static inline void ClearPcg##uname(struct page_cgroup *pc)	\
> +	{ clear_bit(Pcg_##lname, &pc->flags);  }
> +
> +#define __SETPCGFLAG(uname, lname)			\
> +static inline void __SetPcg##uname(struct page_cgroup *pc)\
> +	{ __set_bit(Pcg_##lname, &pc->flags);  }
> +

OK, so we have the non-atomic verion as well

> +#define __CLEARPCGFLAG(uname, lname)			\
> +static inline void __ClearPcg##uname(struct page_cgroup *pc)	\
> +	{ __clear_bit(Pcg_##lname, &pc->flags);  }
> +
> +/* Cache flag is set only once (at allocation) */
> +TESTPCGFLAG(Cache, CACHE)
> +__SETPCGFLAG(Cache, CACHE)
> +
> +/* LRU management flags (from global-lru definition) */
> +TESTPCGFLAG(File, FILE)
> +SETPCGFLAG(File, FILE)
> +__SETPCGFLAG(File, FILE)
> +CLEARPCGFLAG(File, FILE)
> +
> +TESTPCGFLAG(Active, ACTIVE)
> +SETPCGFLAG(Active, ACTIVE)
> +__SETPCGFLAG(Active, ACTIVE)
> +CLEARPCGFLAG(Active, ACTIVE)
> +
> +TESTPCGFLAG(Unevictable, UNEVICTABLE)
> +SETPCGFLAG(Unevictable, UNEVICTABLE)
> +CLEARPCGFLAG(Unevictable, UNEVICTABLE)
> +
> 
>  static int page_cgroup_nid(struct page_cgroup *pc)
>  {
> @@ -189,14 +234,15 @@ enum charge_type {
>  /*
>   * Always modified under lru lock. Then, not necessary to preempt_disable()
>   */
> -static void mem_cgroup_charge_statistics(struct mem_cgroup *mem, int flags,
> -					bool charge)
> +static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
> +					 struct page_cgroup *pc,
> +					 bool charge)
>  {
>  	int val = (charge)? 1 : -1;
>  	struct mem_cgroup_stat *stat = &mem->stat;
> 
>  	VM_BUG_ON(!irqs_disabled());
> -	if (flags & PAGE_CGROUP_FLAG_CACHE)
> +	if (PcgCache(pc))

Shouldn't we use __PcgCache(), see my comments below

>  		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_CACHE, val);
>  	else
>  		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, val);
> @@ -289,18 +335,18 @@ static void __mem_cgroup_remove_list(str
>  {
>  	int lru = LRU_BASE;
> 
> -	if (pc->flags & PAGE_CGROUP_FLAG_UNEVICTABLE)
> +	if (PcgUnevictable(pc))

Since we call this under a lock, can't we use __PcgUnevictable(pc)? If not, what
are we buying by doing atomic operations under a lock?

>  		lru = LRU_UNEVICTABLE;
>  	else {
> -		if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
> +		if (PcgActive(pc))

Ditto

>  			lru += LRU_ACTIVE;
> -		if (pc->flags & PAGE_CGROUP_FLAG_FILE)
> +		if (PcgFile(pc))

Ditto

>  			lru += LRU_FILE;
>  	}
> 
>  	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
> 
> -	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, false);
> +	mem_cgroup_charge_statistics(pc->mem_cgroup, pc, false);
>  	list_del(&pc->lru);
>  }
> 
> @@ -309,27 +355,27 @@ static void __mem_cgroup_add_list(struct
>  {
>  	int lru = LRU_BASE;
> 
> -	if (pc->flags & PAGE_CGROUP_FLAG_UNEVICTABLE)
> +	if (PcgUnevictable(pc))

Ditto

>  		lru = LRU_UNEVICTABLE;
>  	else {
> -		if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
> +		if (PcgActive(pc))
>  			lru += LRU_ACTIVE;
> -		if (pc->flags & PAGE_CGROUP_FLAG_FILE)
> +		if (PcgFile(pc))

Ditto

>  			lru += LRU_FILE;
>  	}
> 
>  	MEM_CGROUP_ZSTAT(mz, lru) += 1;
>  	list_add(&pc->lru, &mz->lists[lru]);
> 
> -	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, true);
> +	mem_cgroup_charge_statistics(pc->mem_cgroup, pc, true);
>  }
> 
>  static void __mem_cgroup_move_lists(struct page_cgroup *pc, enum lru_list lru)
>  {
>  	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
> -	int active    = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
> -	int file      = pc->flags & PAGE_CGROUP_FLAG_FILE;
> -	int unevictable = pc->flags & PAGE_CGROUP_FLAG_UNEVICTABLE;
> +	int active    = PcgActive(pc);
> +	int file      = PcgFile(pc);
> +	int unevictable = PcgUnevictable(pc);
>  	enum lru_list from = unevictable ? LRU_UNEVICTABLE :
>  				(LRU_FILE * !!file + !!active);
> 
> @@ -339,14 +385,14 @@ static void __mem_cgroup_move_lists(stru
>  	MEM_CGROUP_ZSTAT(mz, from) -= 1;
> 
>  	if (is_unevictable_lru(lru)) {
> -		pc->flags &= ~PAGE_CGROUP_FLAG_ACTIVE;
> -		pc->flags |= PAGE_CGROUP_FLAG_UNEVICTABLE;
> +		ClearPcgActive(pc);
> +		SetPcgUnevictable(pc);
>  	} else {
>  		if (is_active_lru(lru))
> -			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
> +			SetPcgActive(pc);
>  		else
> -			pc->flags &= ~PAGE_CGROUP_FLAG_ACTIVE;
> -		pc->flags &= ~PAGE_CGROUP_FLAG_UNEVICTABLE;
> +			ClearPcgActive(pc);
> +		ClearPcgUnevictable(pc);

Again shouldn't we be using the __ variants?

>  	}
> 
>  	MEM_CGROUP_ZSTAT(mz, lru) += 1;
> @@ -580,18 +626,19 @@ static int mem_cgroup_charge_common(stru
> 
>  	pc->mem_cgroup = mem;
>  	pc->page = page;
> +	pc->flags = 0;
>  	/*
>  	 * If a page is accounted as a page cache, insert to inactive list.
>  	 * If anon, insert to active list.
>  	 */
>  	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE) {
> -		pc->flags = PAGE_CGROUP_FLAG_CACHE;
> +		__SetPcgCache(pc);
>  		if (page_is_file_cache(page))
> -			pc->flags |= PAGE_CGROUP_FLAG_FILE;
> +			__SetPcgFile(pc);
>  		else
> -			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
> +			__SetPcgActive(pc);
>  	} else
> -		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
> +		__SetPcgActive(pc);
> 
>  	lock_page_cgroup(page);
>  	if (unlikely(page_get_page_cgroup(page))) {
> @@ -699,8 +746,7 @@ __mem_cgroup_uncharge_common(struct page
>  	VM_BUG_ON(pc->page != page);
> 
>  	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> -	    && ((pc->flags & PAGE_CGROUP_FLAG_CACHE)
> -		|| page_mapped(page)))
> +	    && ((PcgCache(pc) || page_mapped(page))))
>  		goto unlock;
> 
>  	mz = page_cgroup_zoneinfo(pc);
> @@ -750,7 +796,7 @@ int mem_cgroup_prepare_migration(struct 
>  	if (pc) {
>  		mem = pc->mem_cgroup;
>  		css_get(&mem->css);
> -		if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
> +		if (PcgCache(pc))
>  			ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
>  	}
>  	unlock_page_cgroup(page);

Seems reasonable, my worry is the performance degradation that you've mentioned.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
