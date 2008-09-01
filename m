Date: Mon, 1 Sep 2008 16:15:01 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 14/14]memcg: mem+swap accounting
Message-Id: <20080901161501.2cba948e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080822204455.922f87dc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822204455.922f87dc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi, Kamezawa-san.

I'm testing these patches on mmotm-2008-08-29-01-08
(with some trivial fixes I've reported and some debug codes),
but swap_in_bytes sometimes becomes very huge(it seems that
over uncharge is happening..) and I can see OOM
if I've set memswap_limit.

I'm digging this now, but have you also ever seen it?


Thanks,
Daisuke Nishimura.

On Fri, 22 Aug 2008 20:44:55 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Add Swap accounting feature to memory resource controller.
> 
> Accounting is done in following logic.
> 
> Swap-out:
>   - When add_to_swap_cache() is called, swp_entry is marked as to be under
>     page->page_cgroup->mem_cgroup.
>   - When swap-cache is uncharged (fully unmapped), we don't uncharge it.
>   - When swap-cache is deleted, we uncharge it from memory and charge it to
>     swaps. This ops is done only when swap cache is already charged.
>            res.pages -=1, res.swaps +=1.
> 
> Swap-in:
>   - When add_to_swapcache() is called, we do nothing.
>   - When swap is mapped, we charge to memory and uncharge from swap
> 	   res.pages +=1, res.swaps -=1.
> 
> SwapCache-Deleting:
>   - If the page doesn't have page_cgroup, nothing to do.
>   - If the page is still charged as swap, just uncharge memory.
>     (This can happen under shmem/tmpfs.)
>   - If the page is not charged as swap, res.pages -= 1, res.swaps +=1.
> 
> Swap-Freeing:
>   - if swap entry is charged, res.swaps -= 1.
> 
> Almost all operations are done against SwapCache, which is Locked.
> 
> This patch uses an array to remember the owner of swp_entry. Considering x86-32,we should avoid to use NORMAL memory and vmalloc() area too much. This patch
> uses HIGHMEM to record information under kmap_atomic(KM_USER0). And information
> is recored in 2 bytes per 1 swap page.
> (memory controller's id is defined as smaller than unsigned short)
> 
> Changelog: (preview) -> (v2)
>  - removed radix-tree. just use array.
>  - removed linked-list.
>  - use memcgroup_id rather than pointer.
>  - added force_empty (temporal) support.
>    This should be reworked in future. (But for now, this works well for us.)
>  
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  include/linux/swap.h |   38 +++++
>  init/Kconfig         |    2 
>  mm/memcontrol.c      |  364 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>  mm/migrate.c         |    7 
>  mm/swap_state.c      |    7 
>  mm/swapfile.c        |   14 +
>  6 files changed, 422 insertions(+), 10 deletions(-)
> 
> Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
> ===================================================================
> --- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
> +++ mmtom-2.6.27-rc3+/mm/memcontrol.c
> @@ -34,6 +34,10 @@
>  #include <linux/mm_inline.h>
>  #include <linux/pagemap.h>
>  #include <linux/page_cgroup.h>
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
> +#endif
>  
>  #include <asm/uaccess.h>
>  
> @@ -43,9 +47,28 @@ static struct kmem_cache *page_cgroup_ca
>  #define NR_MEMCGRP_ID			(32767)
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> +
>  #define do_swap_account	(1)
> +
> +static void
> +swap_cgroup_delete_account(struct mem_cgroup *mem, struct page *page);
> +
> +static struct mem_cgroup *lookup_mem_cgroup_from_swap(struct page *page);
> +static void swap_cgroup_clean_account(struct mem_cgroup *mem);
>  #else
>  #define do_swap_account	(0)
> +
> +static void
> +swap_cgroup_delete_account(struct mem_cgroup *mem, struct page *page)
> +{
> +}
> +static struct mem_cgroup *lookup_mem_cgroup_from_swap(struct page *page)
> +{
> +	return NULL;
> +}
> +static void swap_cgroup_clean_account(struct mem_cgroup *mem)
> +{
> +}
>  #endif
>  
>  
> @@ -889,6 +912,9 @@ static int mem_cgroup_charge_common(stru
>  	__mem_cgroup_add_list(mz, pc);
>  	spin_unlock_irqrestore(&mz->lru_lock, flags);
>  
> +	/* We did swap-in, uncharge swap. */
> +	if (do_swap_account && PageSwapCache(page))
> +		swap_cgroup_delete_account(mem, page);
>  	return 0;
>  out:
>  	css_put(&mem->css);
> @@ -899,6 +925,8 @@ err:
>  
>  int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
>  {
> +	struct mem_cgroup *memcg = NULL;
> +
>  	if (mem_cgroup_subsys.disabled)
>  		return 0;
>  
> @@ -935,13 +963,19 @@ int mem_cgroup_charge(struct page *page,
>  		}
>  		rcu_read_unlock();
>  	}
> +	/* Swap-in ? */
> +	if (do_swap_account && PageSwapCache(page))
> +		memcg = lookup_mem_cgroup_from_swap(page);
> +
>  	return mem_cgroup_charge_common(page, mm, gfp_mask,
> -				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
> +				MEM_CGROUP_CHARGE_TYPE_MAPPED, memcg);
>  }
>  
>  int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  				gfp_t gfp_mask)
>  {
> +	struct mem_cgroup *memcg = NULL;
> +
>  	if (mem_cgroup_subsys.disabled)
>  		return 0;
>  
> @@ -971,9 +1005,11 @@ int mem_cgroup_cache_charge(struct page 
>  
>  	if (unlikely(!mm))
>  		mm = &init_mm;
> +	if (do_swap_account && PageSwapCache(page))
> +		memcg = lookup_mem_cgroup_from_swap(page);
>  
>  	return mem_cgroup_charge_common(page, mm, gfp_mask,
> -				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
> +				MEM_CGROUP_CHARGE_TYPE_CACHE, memcg);
>  }
>  
>  /*
> @@ -998,9 +1034,11 @@ __mem_cgroup_uncharge_common(struct page
>  
>  	VM_BUG_ON(pc->page != page);
>  
> -	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> -	    && ((PcgCache(pc) || page_mapped(page))))
> -		goto out;
> +	if ((ctype != MEM_CGROUP_CHARGE_TYPE_FORCE))
> +		if (PageSwapCache(page) || page_mapped(page) ||
> +		    (page->mapping && !PageAnon(page)))
> +			goto out;
> +
>  	mem = pc->mem_cgroup;
>  	SetPcgObsolete(pc);
>  	page_assign_page_cgroup(page, NULL);
> @@ -1577,6 +1615,8 @@ static void mem_cgroup_pre_destroy(struc
>  {
>  	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
>  	mem_cgroup_force_empty(mem);
> +	if (do_swap_account)
> +		swap_cgroup_clean_account(mem);
>  }
>  
>  static void mem_cgroup_destroy(struct cgroup_subsys *ss,
> @@ -1635,3 +1675,317 @@ struct cgroup_subsys mem_cgroup_subsys =
>  	.attach = mem_cgroup_move_task,
>  	.early_init = 0,
>  };
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> +/*
> + * swap accounting infrastructure.
> + */
> +DEFINE_MUTEX(swap_cgroup_mutex);
> +spinlock_t swap_cgroup_lock[MAX_SWAPFILES];
> +struct page **swap_cgroup_map[MAX_SWAPFILES];
> +unsigned long swap_cgroup_pages[MAX_SWAPFILES];
> +
> +
> +/* This definition is based onf NR_MEM_CGROUP==32768 */
> +struct swap_cgroup {
> +	unsigned short memcgrp_id:15;
> +	unsigned short count:1;
> +};
> +#define ENTS_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
> +
> +/*
> + * Called from get_swap_ent().
> + */
> +int swap_cgroup_prepare(swp_entry_t ent, gfp_t mask)
> +{
> +	struct page *page;
> +	unsigned long array_index = swp_offset(ent) / ENTS_PER_PAGE;
> +	int type = swp_type(ent);
> +	unsigned long flags;
> +
> +	if (swap_cgroup_map[type][array_index])
> +		return 0;
> +	page = alloc_page(mask | __GFP_HIGHMEM | __GFP_ZERO);
> +	if (!page)
> +		return -ENOMEM;
> +	spin_lock_irqsave(&swap_cgroup_lock[type], flags);
> +	if (swap_cgroup_map[type][array_index] == NULL) {
> +		swap_cgroup_map[type][array_index] = page;
> +		page = NULL;
> +	}
> +	spin_unlock_irqrestore(&swap_cgroup_lock[type], flags);
> +
> +	if (page)
> +		__free_page(page);
> +	return 0;
> +}
> +
> +/**
> + * swap_cgroup_record_info
> + * @page ..... a page which is in some mem_cgroup.
> + * @entry .... swp_entry of the page. (or old swp_entry of the page)
> + * @delete ... if 0 add entry, if 1 remove entry.
> + *
> + * At set new value:
> + * This is called from add_to_swap_cache() after added to swapper_space.
> + * Then...this is called under page_lock() and this page is on radix-tree
> + * We're safe to access page->page_cgroup->mem_cgroup.
> + * This function never fails. (may leak information...but it's not Oops.)
> + *
> + * At delettion:
> + * Returns count is set or not.
> + */
> +int swap_cgroup_record_info(struct page *page, swp_entry_t entry, bool del)
> +{
> +	unsigned long flags;
> +	int type = swp_type(entry);
> +	unsigned long offset = swp_offset(entry);
> +	unsigned long array_index = offset/ENTS_PER_PAGE;
> +	unsigned long index = offset & (ENTS_PER_PAGE - 1);
> +	struct page *mappage;
> +	struct swap_cgroup *map;
> +	struct page_cgroup *pc = NULL;
> +	int ret = 0;
> +
> +	if (!del) {
> +		/*
> +		 * At swap-in, the page is added to swap cache before tied to
> +		 * mem_cgroup. This page will be finally charged at page fault.
> +		 * Ignore this at this point.
> +		 */
> +		pc = page_get_page_cgroup(page);
> +		if (!pc)
> +			return ret;
> +	}
> +	if (!swap_cgroup_map[type])
> +		return ret;
> +	mappage = swap_cgroup_map[type][array_index];
> +	if (!mappage)
> +		return ret;
> +
> +	local_irq_save(flags);
> +	map = kmap_atomic(mappage, KM_USER0);
> +	if (!del) {
> +		map[index].memcgrp_id = pc->mem_cgroup->memcgrp_id;
> +		map[index].count = 0;
> +	} else {
> +		if (map[index].count) {
> +			ret = map[index].memcgrp_id;
> +			map[index].count = 0;
> +		}
> +		map[index].memcgrp_id = 0;
> +	}
> +	kunmap_atomic(mappage, KM_USER0);
> +	local_irq_restore(flags);
> +	return ret;
> +}
> +
> +/*
> + * returns mem_cgroup pointer when swp_entry is assgiend to.
> + */
> +static struct mem_cgroup *swap_cgroup_lookup(swp_entry_t entry)
> +{
> +	unsigned long flags;
> +	int type = swp_type(entry);
> +	unsigned long offset = swp_offset(entry);
> +	unsigned long array_index = offset/ENTS_PER_PAGE;
> +	unsigned long index = offset & (ENTS_PER_PAGE - 1);
> +	struct page *mappage;
> +	struct swap_cgroup *map;
> +	unsigned short id;
> +
> +	if (!swap_cgroup_map[type])
> +		return NULL;
> +	mappage = swap_cgroup_map[type][array_index];
> +	if (!mappage)
> +		return NULL;
> +
> +	local_irq_save(flags);
> +	map = kmap_atomic(mappage, KM_USER0);
> +	id = map[index].memcgrp_id;
> +	kunmap_atomic(mappage, KM_USER0);
> +	local_irq_restore(flags);
> +	return mem_cgroup_id_lookup(id);
> +}
> +
> +static struct mem_cgroup *lookup_mem_cgroup_from_swap(struct page *page)
> +{
> +	swp_entry_t entry = { .val = page_private(page) };
> +	return swap_cgroup_lookup(entry);
> +}
> +
> +/*
> + * set/clear accounting information of swap_cgroup.
> + *
> + * Called when set/clear accounting information.
> + * returns 1 at success.
> + */
> +static int swap_cgroup_account(struct mem_cgroup *memcg,
> +			       swp_entry_t entry, bool set)
> +{
> +	unsigned long flags;
> +	int type = swp_type(entry);
> +	unsigned long offset = swp_offset(entry);
> +	unsigned long array_index = offset/ENTS_PER_PAGE;
> +	unsigned long index = offset & (ENTS_PER_PAGE - 1);
> +	struct page *mappage;
> +	struct swap_cgroup *map;
> +	int ret = 0;
> +
> +	if (!swap_cgroup_map[type])
> +		return ret;
> +	mappage = swap_cgroup_map[type][array_index];
> +	if (!mappage)
> +		return ret;
> +
> +
> +	local_irq_save(flags);
> +	map = kmap_atomic(mappage, KM_USER0);
> +	if (map[index].memcgrp_id == memcg->memcgrp_id) {
> +		if (set && map[index].count == 0) {
> +			map[index].count = 1;
> +			ret = 1;
> +		} else if (!set && map[index].count == 1) {
> +			map[index].count = 0;
> +			ret = 1;
> +		}
> +	}
> +	kunmap_atomic(mappage, KM_USER0);
> +	local_irq_restore(flags);
> +	return ret;
> +}
> +
> +void swap_cgroup_delete_account(struct mem_cgroup *mem, struct page *page)
> +{
> +	swp_entry_t val = { .val = page_private(page) };
> +	if (swap_cgroup_account(mem, val, false))
> +		mem_counter_uncharge_swap(mem);
> +}
> +
> +/*
> + * Called from delete_from_swap_cache() then, page is Locked! and
> + * swp_entry is still in use.
> + */
> +void swap_cgroup_delete_swapcache(struct page *page, swp_entry_t entry)
> +{
> +	struct page_cgroup *pc;
> +
> +	pc = page_get_page_cgroup(page);
> +	/* swap-in but not mapped. */
> +	if (!pc)
> +		return;
> +
> +	if (swap_cgroup_account(pc->mem_cgroup, entry, true))
> +		__mem_cgroup_uncharge_common(page,
> +				MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
> +	else if (page->mapping && !PageAnon(page))
> +		__mem_cgroup_uncharge_common(page,
> +				MEM_CGROUP_CHARGE_TYPE_CACHE);
> +	else
> +		__mem_cgroup_uncharge_common(page,
> +				MEM_CGROUP_CHARGE_TYPE_MAPPED);
> +	return;
> +}
> +
> +void swap_cgroup_delete_swap(swp_entry_t entry)
> +{
> +	int ret;
> +	struct mem_cgroup *mem;
> +
> +	ret = swap_cgroup_record_info(NULL, entry, true);
> +	if (ret) {
> +		mem = mem_cgroup_id_lookup(ret);
> +		if (mem)
> +			mem_counter_uncharge_swap(mem);
> +	}
> +}
> +
> +
> +/*
> + * Forget all accounts under swap_cgroup of memcg.
> + * Called from destroying context.
> + */
> +static void swap_cgroup_clean_account(struct mem_cgroup *memcg)
> +{
> +	int type;
> +	unsigned long array_index, flags;
> +	int index;
> +	struct page *page;
> +	struct swap_cgroup *map;
> +
> +	if (!memcg->res.swaps)
> +		return;
> +	mutex_lock(&swap_cgroup_mutex);
> +	for (type = 0; type < MAX_SWAPFILES; type++) {
> +		if (swap_cgroup_pages[type] == 0)
> +			continue;
> +		for (array_index = 0;
> +		     array_index < swap_cgroup_pages[type];
> +		     array_index++) {
> +			page = swap_cgroup_map[type][array_index];
> +			if (!page)
> +				continue;
> +			local_irq_save(flags);
> +			map = kmap_atomic(page, KM_USER0);
> +			for (index = 0; index < ENTS_PER_PAGE; index++) {
> +				if (map[index].memcgrp_id
> +				    == memcg->memcgrp_id) {
> +					map[index].memcgrp_id = 0;
> +					map[index].count = 0;
> +				}
> +			}
> +			kunmap_atomic(page, KM_USER0);
> +			local_irq_restore(flags);
> +		}
> +		mutex_unlock(&swap_cgroup_mutex);
> +		yield();
> +		mutex_lock(&swap_cgroup_mutex);
> +	}
> +	mutex_unlock(&swap_cgroup_mutex);
> +}
> +
> +/*
> + * called from swapon().
> + */
> +int swap_cgroup_swapon(int type, unsigned long max_pages)
> +{
> +	void *array;
> +	int array_size;
> +
> +	VM_BUG_ON(swap_cgroup_map[type]);
> +
> +	array_size = ((max_pages/ENTS_PER_PAGE) + 1) * sizeof(void *);
> +
> +	array = vmalloc(array_size);
> +	if (!array) {
> +		printk("swap %d will not be accounted\n", type);
> +		return -ENOMEM;
> +	}
> +	memset(array, 0, array_size);
> +	mutex_lock(&swap_cgroup_mutex);
> +	swap_cgroup_pages[type] = (max_pages/ENTS_PER_PAGE + 1);
> +	swap_cgroup_map[type] = array;
> +	mutex_unlock(&swap_cgroup_mutex);
> +	spin_lock_init(&swap_cgroup_lock[type]);
> +	return 0;
> +}
> +
> +/*
> + * called from swapoff().
> + */
> +void swap_cgroup_swapoff(int type)
> +{
> +	int i;
> +	for (i = 0; i < swap_cgroup_pages[type]; i++) {
> +		struct page *page = swap_cgroup_map[type][i];
> +		if (page)
> +			__free_page(page);
> +	}
> +	mutex_lock(&swap_cgroup_mutex);
> +	vfree(swap_cgroup_map[type]);
> +	swap_cgroup_map[type] = NULL;
> +	mutex_unlock(&swap_cgroup_mutex);
> +	swap_cgroup_pages[type] = 0;
> +}
> +
> +#endif
> Index: mmtom-2.6.27-rc3+/include/linux/swap.h
> ===================================================================
> --- mmtom-2.6.27-rc3+.orig/include/linux/swap.h
> +++ mmtom-2.6.27-rc3+/include/linux/swap.h
> @@ -335,6 +335,44 @@ static inline void disable_swap_token(vo
>  	put_swap_token(swap_token_mm);
>  }
>  
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> +extern int swap_cgroup_swapon(int type, unsigned long max_pages);
> +extern void swap_cgroup_swapoff(int type);
> +extern void swap_cgroup_delete_swap(swp_entry_t entry);
> +extern int swap_cgroup_prepare(swp_entry_t ent, gfp_t mask);
> +extern int swap_cgroup_record_info(struct page *, swp_entry_t ent, bool del);
> +extern void swap_cgroup_delete_swapcache(struct page *page, swp_entry_t entry);
> +
> +#else
> +static inline int swap_cgroup_swapon(int type, unsigned long max_pages)
> +{
> +	return 0;
> +}
> +static inline void swap_cgroup_swapoff(int type)
> +{
> +	return;
> +}
> +static inline void swap_cgroup_delete_swap(swp_entry_t entry)
> +{
> +	return;
> +}
> +static inline int swap_cgroup_prapare(swp_entry_t ent, gfp_t mask)
> +{
> +	return 0;
> +}
> +static inline int
> + swap_cgroup_record_info(struct page *, swp_entry_t ent, bool del)
> +{
> +	return 0;
> +}
> +static inline
> +void swap_cgroup_delete_swapcache(struct page *page, swp_entry_t entry)
> +{
> +	return;
> +}
> +#endif
> +
> +
>  #else /* CONFIG_SWAP */
>  
>  #define total_swap_pages			0
> Index: mmtom-2.6.27-rc3+/mm/swapfile.c
> ===================================================================
> --- mmtom-2.6.27-rc3+.orig/mm/swapfile.c
> +++ mmtom-2.6.27-rc3+/mm/swapfile.c
> @@ -270,8 +270,9 @@ out:
>  	return NULL;
>  }	
>  
> -static int swap_entry_free(struct swap_info_struct *p, unsigned long offset)
> +static int swap_entry_free(struct swap_info_struct *p, swp_entry_t entry)
>  {
> +	unsigned long offset = swp_offset(entry);
>  	int count = p->swap_map[offset];
>  
>  	if (count < SWAP_MAP_MAX) {
> @@ -286,6 +287,7 @@ static int swap_entry_free(struct swap_i
>  				swap_list.next = p - swap_info;
>  			nr_swap_pages++;
>  			p->inuse_pages--;
> +			swap_cgroup_delete_swap(entry);
>  		}
>  	}
>  	return count;
> @@ -301,7 +303,7 @@ void swap_free(swp_entry_t entry)
>  
>  	p = swap_info_get(entry);
>  	if (p) {
> -		swap_entry_free(p, swp_offset(entry));
> +		swap_entry_free(p, entry);
>  		spin_unlock(&swap_lock);
>  	}
>  }
> @@ -420,7 +422,7 @@ void free_swap_and_cache(swp_entry_t ent
>  
>  	p = swap_info_get(entry);
>  	if (p) {
> -		if (swap_entry_free(p, swp_offset(entry)) == 1) {
> +		if (swap_entry_free(p, entry) == 1) {
>  			page = find_get_page(&swapper_space, entry.val);
>  			if (page && !trylock_page(page)) {
>  				page_cache_release(page);
> @@ -1343,6 +1345,7 @@ asmlinkage long sys_swapoff(const char _
>  	spin_unlock(&swap_lock);
>  	mutex_unlock(&swapon_mutex);
>  	vfree(swap_map);
> +	swap_cgroup_swapoff(type);
>  	inode = mapping->host;
>  	if (S_ISBLK(inode->i_mode)) {
>  		struct block_device *bdev = I_BDEV(inode);
> @@ -1669,6 +1672,11 @@ asmlinkage long sys_swapon(const char __
>  				1 /* header page */;
>  		if (error)
>  			goto bad_swap;
> +
> +		if (swap_cgroup_swapon(type, maxpages)) {
> +			printk("We don't enable swap accounting because of"
> +				"memory shortage\n");
> +		}
>  	}
>  
>  	if (nr_good_pages) {
> Index: mmtom-2.6.27-rc3+/mm/swap_state.c
> ===================================================================
> --- mmtom-2.6.27-rc3+.orig/mm/swap_state.c
> +++ mmtom-2.6.27-rc3+/mm/swap_state.c
> @@ -76,6 +76,9 @@ int add_to_swap_cache(struct page *page,
>  	BUG_ON(PageSwapCache(page));
>  	BUG_ON(PagePrivate(page));
>  	BUG_ON(!PageSwapBacked(page));
> +	error = swap_cgroup_prepare(entry, gfp_mask);
> +	if (error)
> +		return error;
>  	error = radix_tree_preload(gfp_mask);
>  	if (!error) {
>  		page_cache_get(page);
> @@ -89,6 +92,7 @@ int add_to_swap_cache(struct page *page,
>  			total_swapcache_pages++;
>  			__inc_zone_page_state(page, NR_FILE_PAGES);
>  			INC_CACHE_INFO(add_total);
> +			swap_cgroup_record_info(page, entry, false);
>  		}
>  		spin_unlock_irq(&swapper_space.tree_lock);
>  		radix_tree_preload_end();
> @@ -108,6 +112,8 @@ int add_to_swap_cache(struct page *page,
>   */
>  void __delete_from_swap_cache(struct page *page)
>  {
> +	swp_entry_t entry = { .val = page_private(page) };
> +
>  	BUG_ON(!PageLocked(page));
>  	BUG_ON(!PageSwapCache(page));
>  	BUG_ON(PageWriteback(page));
> @@ -117,6 +123,7 @@ void __delete_from_swap_cache(struct pag
>  	set_page_private(page, 0);
>  	ClearPageSwapCache(page);
>  	total_swapcache_pages--;
> +	swap_cgroup_delete_swapcache(page, entry);
>  	__dec_zone_page_state(page, NR_FILE_PAGES);
>  	INC_CACHE_INFO(del_total);
>  }
> Index: mmtom-2.6.27-rc3+/init/Kconfig
> ===================================================================
> --- mmtom-2.6.27-rc3+.orig/init/Kconfig
> +++ mmtom-2.6.27-rc3+/init/Kconfig
> @@ -416,7 +416,7 @@ config CGROUP_MEM_RES_CTLR
>  	  could in turn add some fork/exit overhead.
>  
>  config CGROUP_MEM_RES_CTLR_SWAP
> -	bool "Memory Resource Controller Swap Extension (Broken)"
> +	bool "Memory Resource Controller Swap Extension (EXPERIMENTAL)"
>  	depends on CGROUP_MEM_RES_CTLR && SWAP && EXPERIMENTAL
>  	help
>  	 Add swap management feature to memory resource controller. By this,
> Index: mmtom-2.6.27-rc3+/mm/migrate.c
> ===================================================================
> --- mmtom-2.6.27-rc3+.orig/mm/migrate.c
> +++ mmtom-2.6.27-rc3+/mm/migrate.c
> @@ -339,6 +339,8 @@ static int migrate_page_move_mapping(str
>   */
>  static void migrate_page_copy(struct page *newpage, struct page *page)
>  {
> +	int was_swapcache = 0;
> +
>  	copy_highpage(newpage, page);
>  
>  	if (PageError(page))
> @@ -372,14 +374,17 @@ static void migrate_page_copy(struct pag
>  	mlock_migrate_page(newpage, page);
>  
>  #ifdef CONFIG_SWAP
> +	was_swapcache = PageSwapCache(page);
>  	ClearPageSwapCache(page);
>  #endif
>  	ClearPagePrivate(page);
>  	set_page_private(page, 0);
>  	/* page->mapping contains a flag for PageAnon() */
>  	if (PageAnon(page)) {
> -		/* This page is uncharged at try_to_unmap(). */
> +		/* This page is uncharged at try_to_unmap() if not SwapCache. */
>  		page->mapping = NULL;
> +		if (was_swapcache)
> +			mem_cgroup_uncharge_page(page);
>  	} else {
>  		/* Obsolete file cache should be uncharged */
>  		page->mapping = NULL;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
