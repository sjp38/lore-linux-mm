From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [Approach #2] [RFC][PATCH] Remove cgroup member from struct page
Date: Tue, 09 Sep 2008 19:11:09 -0700
Message-ID: <48C72CBD.6040602@linux.vnet.ibm.com>
References: <48C66AF8.5070505@linux.vnet.ibm.com> <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <200809091358.28350.nickpiggin@yahoo.com.au> <20080909135317.cbff4871.kamezawa.hiroyu@jp.fujitsu.com> <200809091500.10619.nickpiggin@yahoo.com.au> <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com> <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com> <20080910012048.GA32752@balbir.in.ibm.com> <20080910104940.a7ec9b5a.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753081AbYIJCM3@vger.kernel.org>
In-Reply-To: <20080910104940.a7ec9b5a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

KAMEZAWA Hiroyuki wrote:
> On Tue, 9 Sep 2008 18:20:48 -0700
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-09-09 21:30:12]:
>> OK, here is approach #2, it works for me and gives me really good
>> performance (surpassing even the current memory controller). I am
>> seeing almost a 7% increase
> This number is from pre-allcation, maybe.
> We really do alloc-at-boot all page_cgroup ? This seems a big change.
> 
>> Caveats
>>
>> 1. Uses more memory (since it allocates memory for each node based on
>>    spanned_pages. Ignores holes, so might not be the most efficient,
>>    but it is a tradeoff of complexity versus space. I propose refining it
>>    as we go along.
>> 2. Does not currently handle alloc_bootmem failure
>> 3. Needs lots of testing/tuning and polishing
>>
> If we can do alloc-at-boot, we can make memcg much simpler.
> 
> 
> 
>> I've tested it on an x86_64 box with 4G of memory
>>
>> Again, this is an early RFC patch, please review test. 
>>
>> Comments/Reviews?
>>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> ---
>>
>>  include/linux/memcontrol.h |   32 ++++++
>>  include/linux/mm_types.h   |    4 
>>  mm/memcontrol.c            |  212 +++++++++++++++++++++++++++------------------
>>  mm/page_alloc.c            |   10 --
>>  4 files changed, 162 insertions(+), 96 deletions(-)
>>
>> diff -puN mm/memcontrol.c~memcg_move_to_radix_tree mm/memcontrol.c
>> --- linux-2.6.27-rc5/mm/memcontrol.c~memcg_move_to_radix_tree	2008-09-04 03:15:54.000000000 -0700
>> +++ linux-2.6.27-rc5-balbir/mm/memcontrol.c	2008-09-09 17:56:54.000000000 -0700
>> @@ -18,6 +18,7 @@
>>   */
>>  
>>  #include <linux/res_counter.h>
>> +#include <linux/bootmem.h>
>>  #include <linux/memcontrol.h>
>>  #include <linux/cgroup.h>
>>  #include <linux/mm.h>
>> @@ -37,9 +38,10 @@
>>  #include <asm/uaccess.h>
>>  
>>  struct cgroup_subsys mem_cgroup_subsys __read_mostly;
>> -static struct kmem_cache *page_cgroup_cache __read_mostly;
>>  #define MEM_CGROUP_RECLAIM_RETRIES	5
>>  
>> +static struct page_cgroup *pcg_map[MAX_NUMNODES];
>> +
>>  /*
>>   * Statistics for memory cgroup.
>>   */
>> @@ -137,20 +139,6 @@ struct mem_cgroup {
>>  static struct mem_cgroup init_mem_cgroup;
>>  
>>  /*
>> - * We use the lower bit of the page->page_cgroup pointer as a bit spin
>> - * lock.  We need to ensure that page->page_cgroup is at least two
>> - * byte aligned (based on comments from Nick Piggin).  But since
>> - * bit_spin_lock doesn't actually set that lock bit in a non-debug
>> - * uniprocessor kernel, we should avoid setting it here too.
>> - */
>> -#define PAGE_CGROUP_LOCK_BIT 	0x0
>> -#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
>> -#define PAGE_CGROUP_LOCK 	(1 << PAGE_CGROUP_LOCK_BIT)
>> -#else
>> -#define PAGE_CGROUP_LOCK	0x0
>> -#endif
>> -
>> -/*
>>   * A page_cgroup page is associated with every page descriptor. The
>>   * page_cgroup helps us identify information about the cgroup
>>   */
>> @@ -158,12 +146,26 @@ struct page_cgroup {
>>  	struct list_head lru;		/* per cgroup LRU list */
>>  	struct page *page;
>>  	struct mem_cgroup *mem_cgroup;
>> -	int flags;
>> +	unsigned long flags;
>>  };
>> -#define PAGE_CGROUP_FLAG_CACHE	   (0x1)	/* charged as cache */
>> -#define PAGE_CGROUP_FLAG_ACTIVE    (0x2)	/* page is active in this cgroup */
>> -#define PAGE_CGROUP_FLAG_FILE	   (0x4)	/* page is file system backed */
>> -#define PAGE_CGROUP_FLAG_UNEVICTABLE (0x8)	/* page is unevictableable */
>> +
>> +/*
>> + * LOCK_BIT is 0, with value 1
>> + */
>> +#define PAGE_CGROUP_FLAG_LOCK_BIT  (0x0)  /* lock bit */
>> +
>> +#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
>> +#define PAGE_CGROUP_FLAG_LOCK      (0x1)  /* lock value */
>> +#else
>> +#define PAGE_CGROUP_FLAG_LOCK      (0x0)  /* lock value */
>> +#endif
>> +
>> +#define PAGE_CGROUP_FLAG_CACHE	   (0x2)   /* charged as cache */
>> +#define PAGE_CGROUP_FLAG_ACTIVE    (0x4)   /* page is active in this cgroup */
>> +#define PAGE_CGROUP_FLAG_FILE	   (0x8)   /* page is file system backed */
>> +#define PAGE_CGROUP_FLAG_UNEVICTABLE (0x10)/* page is unevictableable */
>> +#define PAGE_CGROUP_FLAG_INUSE     (0x20)/* pc is allocated and in use */
>> +#define PAGE_CGROUP_FLAG_VALID     (0x40)/* pc is allocated and in use */
>>  
>>  static int page_cgroup_nid(struct page_cgroup *pc)
>>  {
>> @@ -248,35 +250,99 @@ struct mem_cgroup *mem_cgroup_from_task(
>>  				struct mem_cgroup, css);
>>  }
>>  
>> -static inline int page_cgroup_locked(struct page *page)
>> +static inline void lock_page_cgroup(struct page_cgroup *pc)
>>  {
>> -	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
>> +	bit_spin_lock(PAGE_CGROUP_FLAG_LOCK_BIT, &pc->flags);
>>  }
>>  
>> -static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
>> +static inline int trylock_page_cgroup(struct page_cgroup *pc)
>>  {
>> -	VM_BUG_ON(!page_cgroup_locked(page));
>> -	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
>> +	return bit_spin_trylock(PAGE_CGROUP_FLAG_LOCK_BIT, &pc->flags);
>>  }
>>  
>> -struct page_cgroup *page_get_page_cgroup(struct page *page)
>> +static inline void unlock_page_cgroup(struct page_cgroup *pc)
>>  {
>> -	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
>> +	bit_spin_unlock(PAGE_CGROUP_FLAG_LOCK_BIT, &pc->flags);
>>  }
>>  
>> -static void lock_page_cgroup(struct page *page)
>> +/*
>> + * Called from memmap_init_zone(), has the advantage of dealing with
>> + * memory_hotplug (Addition of memory)
>> + */
>> +int page_cgroup_alloc(int n)
>>  {
>> -	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
>> +	struct pglist_data *pgdat;
>> +	unsigned long size, start, end;
>> +
>> +	if (mem_cgroup_subsys.disabled)
>> +		return;
>> +
>> +	pgdat = NODE_DATA(n);
>> +	/*
>> +	 * Already allocated, leave
>> +	 */
>> +	if (pcg_map[n])
>> +		return 0;
>> +
>> +	start = pgdat->node_start_pfn;
>> +	end = pgdat->node_start_pfn + pgdat->node_spanned_pages;
>> +	size = (end - start) * sizeof(struct page_cgroup);
>> +	printk("Allocating %lu bytes for node %d\n", size, n);
> ^^^^^
> 
> 1. This is nonsense...do you know the memory map of IBM's (maybe ppc) machine ?
> Node's memory are splitted into several pieces and not ordered by node number.
> example)
>    Node 0 | Node 1 | Node 2 | Node 1 | Node 2 | 
> 
> This seems special but when I helped SPARSEMEM and MEMORY_HOTPLUG,
> I saw mannnny kinds of memory map. As you wrote, this should be re-designed.
> 

Thanks, so that means that we cannot before hand predict the size of pcg_map[n],
we'll need to do an incremental addition to pcg_map?

> 2. If pre-allocating all is ok, I stop my work. Mine is of-no-use.

One of the goals of this patch is refinement, it is a starting piece, something
I shared very early. I am not asking you to stop your work. While I think
pre-allocating is not the best way to do this, the trade off is the sparseness
of the machine. I don't mind doing it in other ways, but we'll still need to do
some batch'ed preallocation (of a smaller size maybe).

> But you have to know that by pre-allocationg, we can't use avoid-lru-lock
> by batch like page_vec technique. We can't delay uncharge because a page
> can be reused soon.
> 
> 

Care to elaborate on this? Why not? If the page is reused, we act on the batch
and sync it up

> 
> 
>> +	pcg_map[n] = alloc_bootmem_node(pgdat, size);
>> +	/*
>> +	 * We can do smoother recovery
>> +	 */
>> +	BUG_ON(!pcg_map[n]);
>> +	return 0;
>>  }
>>  
>> -static int try_lock_page_cgroup(struct page *page)
>> +void page_cgroup_init(int nid, unsigned long pfn)
>>  {
>> -	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
>> +	unsigned long node_pfn;
>> +	struct page_cgroup *pc;
>> +
>> +	if (mem_cgroup_subsys.disabled)
>> +		return;
>> +
>> +	node_pfn = pfn - NODE_DATA(nid)->node_start_pfn;
>> +	pc = &pcg_map[nid][node_pfn];
>> +
>> +	BUG_ON(!pc);
>> +	pc->flags = PAGE_CGROUP_FLAG_VALID;
>> +	INIT_LIST_HEAD(&pc->lru);
>> +	pc->page = NULL;
> This NULL is unnecessary. pc->page = pnf_to_page(pfn) always.
> 

OK

> 
>> +	pc->mem_cgroup = NULL;
>>  }
>>  
>> -static void unlock_page_cgroup(struct page *page)
>> +struct page_cgroup *__page_get_page_cgroup(struct page *page, bool lock,
>> +						bool trylock)
>>  {
>> -	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
>> +	struct page_cgroup *pc;
>> +	int ret;
>> +	int node = page_to_nid(page);
>> +	unsigned long pfn;
>> +
>> +	pfn = page_to_pfn(page) - NODE_DATA(node)->node_start_pfn;
>> +	pc = &pcg_map[node][pfn];
>> +	BUG_ON(!(pc->flags & PAGE_CGROUP_FLAG_VALID));
>> +	if (lock)
>> +		lock_page_cgroup(pc);
>> +	else if (trylock) {
>> +		ret = trylock_page_cgroup(pc);
>> +		if (!ret)
>> +			pc = NULL;
>> +	}
>> +
>> +	return pc;
>> +}
>> +
>> +/*
>> + * Should be called with page_cgroup lock held. Any additions to pc->flags
>> + * should be reflected here. This might seem ugly, refine it later.
>> + */
>> +void page_clear_page_cgroup(struct page_cgroup *pc)
>> +{
>> +	pc->flags &= ~PAGE_CGROUP_FLAG_INUSE;
>>  }
>>  
>>  static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
>> @@ -377,17 +443,15 @@ void mem_cgroup_move_lists(struct page *
>>  	 * safely get to page_cgroup without it, so just try_lock it:
>>  	 * mem_cgroup_isolate_pages allows for page left on wrong list.
>>  	 */
>> -	if (!try_lock_page_cgroup(page))
>> +	pc = page_get_page_cgroup_trylock(page);
>> +	if (!pc)
>>  		return;
>>  
>> -	pc = page_get_page_cgroup(page);
>> -	if (pc) {
>> -		mz = page_cgroup_zoneinfo(pc);
>> -		spin_lock_irqsave(&mz->lru_lock, flags);
>> -		__mem_cgroup_move_lists(pc, lru);
>> -		spin_unlock_irqrestore(&mz->lru_lock, flags);
>> -	}
>> -	unlock_page_cgroup(page);
>> +	mz = page_cgroup_zoneinfo(pc);
>> +	spin_lock_irqsave(&mz->lru_lock, flags);
>> +	__mem_cgroup_move_lists(pc, lru);
>> +	spin_unlock_irqrestore(&mz->lru_lock, flags);
>> +	unlock_page_cgroup(pc);
> 
> This lock/unlock_page_cgroup is against what ?
> 

We use page_cgroup_zoneinfo(pc), we want to make sure pc does not disappear or
change from underneath us.

>>  }
>>  
>>  /*
>> @@ -521,10 +585,6 @@ static int mem_cgroup_charge_common(stru
>>  	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
>>  	struct mem_cgroup_per_zone *mz;
>>  
>> -	pc = kmem_cache_alloc(page_cgroup_cache, gfp_mask);
>> -	if (unlikely(pc == NULL))
>> -		goto err;
>> -
>>  	/*
>>  	 * We always charge the cgroup the mm_struct belongs to.
>>  	 * The mm_struct's mem_cgroup changes on task migration if the
>> @@ -567,43 +627,40 @@ static int mem_cgroup_charge_common(stru
>>  		}
>>  	}
>>  
>> +	pc = page_get_page_cgroup_locked(page);
>> +	if (pc->flags & PAGE_CGROUP_FLAG_INUSE) {
>> +		unlock_page_cgroup(pc);
>> +		res_counter_uncharge(&mem->res, PAGE_SIZE);
>> +		css_put(&mem->css);
>> +		goto done;
>> +	}
>> +
> Can this happen ? Our direction should be
> VM_BUG_ON(pc->flags & PAGE_CGROUP_FLAG_INUSE)
> 

Yes, it can.. several people trying to map the same page at once. Can't we race
doing that?

> 
> 
>>  	pc->mem_cgroup = mem;
>>  	pc->page = page;
>> +	pc->flags |= PAGE_CGROUP_FLAG_INUSE;
>> +
>>  	/*
>>  	 * If a page is accounted as a page cache, insert to inactive list.
>>  	 * If anon, insert to active list.
>>  	 */
>>  	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE) {
>> -		pc->flags = PAGE_CGROUP_FLAG_CACHE;
>> +		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
>>  		if (page_is_file_cache(page))
>>  			pc->flags |= PAGE_CGROUP_FLAG_FILE;
>>  		else
>>  			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
>>  	} else
>> -		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
>> -
>> -	lock_page_cgroup(page);
>> -	if (unlikely(page_get_page_cgroup(page))) {
>> -		unlock_page_cgroup(page);
>> -		res_counter_uncharge(&mem->res, PAGE_SIZE);
>> -		css_put(&mem->css);
>> -		kmem_cache_free(page_cgroup_cache, pc);
>> -		goto done;
>> -	}
>> -	page_assign_page_cgroup(page, pc);
>> +		pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
>>  
>>  	mz = page_cgroup_zoneinfo(pc);
>>  	spin_lock_irqsave(&mz->lru_lock, flags);
>>  	__mem_cgroup_add_list(mz, pc);
>>  	spin_unlock_irqrestore(&mz->lru_lock, flags);
>> -
>> -	unlock_page_cgroup(page);
>> +	unlock_page_cgroup(pc);
> 
> Is this lock/unlock_page_cgroup is for what kind of race ?

for setting pc->flags and for setting pc->page and pc->mem_cgroup.


-- 
	Balbir
