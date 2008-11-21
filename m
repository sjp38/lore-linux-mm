Date: Fri, 21 Nov 2008 15:16:23 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg-swap-cgroup-for-remembering-usage-v2.patch
Message-Id: <20081121151623.843962ea.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081121145426.e3250716.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081118180721.cb2fe744.nishimura@mxp.nes.nec.co.jp>
	<20081118182637.97ae0e48.kamezawa.hiroyu@jp.fujitsu.com>
	<20081118192135.300803ec.nishimura@mxp.nes.nec.co.jp>
	<20081118210838.c99887fd.nishimura@mxp.nes.nec.co.jp>
	<Pine.LNX.4.64.0811181234430.9680@blonde.site>
	<20081119001756.0a31b11e.d-nishimura@mtf.biglobe.ne.jp>
	<6023.10.75.179.61.1227024730.squirrel@webmail-b.css.fujitsu.com>
	<Pine.LNX.4.64.0811181629070.417@blonde.site>
	<Pine.LNX.4.64.0811181653290.3506@blonde.site>
	<59529.10.75.179.61.1227098677.squirrel@webmail-b.css.fujitsu.com>
	<20081121145426.e3250716.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, LiZefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Nov 2008 14:54:26 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> This patch is written as a replacement for
>   memcg-swap-cgroup-for-remembering-usage.patch
>   memcg-swap-cgroup-for-remembering-usage-fix.patch
>   memcg-swap-cgroup-for-remembering-usage-fix-2.patch
>   memcg-swap-cgroup-for-remembering-usage-fix-3.patch
>   memcg-swap-cgroup-for-remembering-usage-fix-4.patch
> 
> in mm queue. (sorry for low quality.)
> 
> I'm now testing this. (replace above 5 patches with this). S
> Nishimura-san, Could you try ?
> 
Sure.

I'll test with this patch applied.


Thanks,
Daisuke Nishimura.

> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Unified patch + rework for memcg-swap-cgroup-for-remembering-usage.patch
> 
> For accounting swap, we need a record per swap entry, at least.
> 
> This patch adds following function.
>   - swap_cgroup_swapon() .... called from swapon
>   - swap_cgroup_swapoff() ... called at the end of swapoff.
> 
>   - swap_cgroup_record() .... record information of swap entry.
>   - swap_cgroup_lookup() .... lookup information of swap entry.
> 
> This patch just implements "how to record information".  No actual method
> for limit the usage of swap.  These routine uses flat table to record and
> lookup.  "wise" lookup system like radix-tree requires requires memory
> allocation at new records but swap-out is usually called under memory
> shortage (or memcg hits limit.) So, I used static allocation.  (maybe
> dynamic allocation is not very hard but it adds additional memory
> allocation in memory shortage path.)
> 
> Note1: In this, we use pointer to record information and this means
>       8bytes per swap entry. I think we can reduce this when we
>       create "id of cgroup" in the range of 0-65535 or 0-255.
> 
> Changelog: v1->v2
>  - make mutex to be static (from Andrew Morton <akpm@linux-foundation.org>)
>  - fixed typo (from  Balbir Singh <balbir@linux.vnet.ibm.com>)
>  - omit HIGHMEM functions. put that in TODO list.
>  - delete spinlock around operations.(added comment "why we're safe.")
> 
> Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Reported-by: Hugh Dickins <hugh@veritas.com>
> Reported-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> 
>  include/linux/page_cgroup.h |   35 +++++++
>  mm/page_cgroup.c            |  197 ++++++++++++++++++++++++++++++++++++++++++++
>  mm/swapfile.c               |    8 +
>  3 files changed, 240 insertions(+)
> 
> Index: mmotm-2.6.28-Nov20/include/linux/page_cgroup.h
> ===================================================================
> --- mmotm-2.6.28-Nov20.orig/include/linux/page_cgroup.h
> +++ mmotm-2.6.28-Nov20/include/linux/page_cgroup.h
> @@ -105,4 +105,39 @@ static inline void page_cgroup_init(void
>  }
>  
>  #endif
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> +#include <linux/swap.h>
> +extern struct mem_cgroup *
> +swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem);
> +extern struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent);
> +extern int swap_cgroup_swapon(int type, unsigned long max_pages);
> +extern void swap_cgroup_swapoff(int type);
> +#else
> +#include <linux/swap.h>
> +
> +static inline
> +struct mem_cgroup *swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem)
> +{
> +	return NULL;
> +}
> +
> +static inline
> +struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
> +{
> +	return NULL;
> +}
> +
> +static inline int
> +swap_cgroup_swapon(int type, unsigned long max_pages)
> +{
> +	return 0;
> +}
> +
> +static inline void swap_cgroup_swapoff(int type)
> +{
> +	return;
> +}
> +
> +#endif
>  #endif
> Index: mmotm-2.6.28-Nov20/mm/page_cgroup.c
> ===================================================================
> --- mmotm-2.6.28-Nov20.orig/mm/page_cgroup.c
> +++ mmotm-2.6.28-Nov20/mm/page_cgroup.c
> @@ -8,6 +8,7 @@
>  #include <linux/memory.h>
>  #include <linux/vmalloc.h>
>  #include <linux/cgroup.h>
> +#include <linux/swapops.h>
>  
>  static void __meminit
>  __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
> @@ -266,3 +267,199 @@ void __init pgdat_page_cgroup_init(struc
>  }
>  
>  #endif
> +
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> +
> +static DEFINE_MUTEX(swap_cgroup_mutex);
> +struct swap_cgroup_ctrl {
> +	struct page **map;
> +	unsigned long length;
> +};
> +
> +struct swap_cgroup_ctrl swap_cgroup_ctrl[MAX_SWAPFILES];
> +
> +/*
> + * This 8bytes seems big..maybe we can reduce this when we can use "id" for
> + * cgroup rather than pointer.
> + */
> +struct swap_cgroup {
> +	struct mem_cgroup	*val;
> +};
> +#define SC_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
> +#define SC_POS_MASK	(SC_PER_PAGE - 1)
> +
> +/*
> + * SwapCgroup implements "lookup" and "exchange" operations.
> + * In typical usage, this swap_cgroup is accessed via memcg's charge/uncharge
> + * against SwapCache. At swap_free(), this is accessed directly from swap.
> + *
> + * This means,
> + *  - we have no race in "exchange" when we're accessed via SwapCache because
> + *    SwapCache(and its swp_entry) is under lock.
> + *  - When called via swap_free(), there is no user of this entry and no race.
> + * Then, we don't need lock around "exchange".
> + *
> + * TODO: we can push these buffers out to HIGHMEM.
> + */
> +
> +/*
> + * allocate buffer for swap_cgroup.
> + */
> +static int swap_cgroup_prepare(int type)
> +{
> +	struct page *page;
> +	struct swap_cgroup_ctrl *ctrl;
> +	unsigned long idx, max;
> +
> +	if (!do_swap_account)
> +		return 0;
> +	ctrl = &swap_cgroup_ctrl[type];
> +
> +	for (idx = 0; idx < ctrl->length; idx++) {
> +		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
> +		if (!page)
> +			goto not_enough_page;
> +		ctrl->map[idx] = page;
> +	}
> +	return 0;
> +not_enough_page:
> +	max = idx;
> +	for (idx = 0; idx < max; idx++)
> +		__free_page(ctrl->map[idx]);
> +
> +	return -ENOMEM;
> +}
> +
> +/**
> + * swap_cgroup_record - record mem_cgroup for this swp_entry.
> + * @ent: swap entry to be recorded into
> + * @mem: mem_cgroup to be recorded
> + *
> + * Returns old value at success, NULL at failure.
> + * (Of course, old value can be NULL.)
> + */
> +struct mem_cgroup *swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem)
> +{
> +	int type = swp_type(ent);
> +	unsigned long offset = swp_offset(ent);
> +	unsigned long idx = offset / SC_PER_PAGE;
> +	unsigned long pos = offset & SC_POS_MASK;
> +	struct swap_cgroup_ctrl *ctrl;
> +	struct page *mappage;
> +	struct swap_cgroup *sc;
> +	struct mem_cgroup *old;
> +
> +	if (!do_swap_account)
> +		return NULL;
> +
> +	ctrl = &swap_cgroup_ctrl[type];
> +
> +	mappage = ctrl->map[idx];
> +	sc = page_address(mappage);
> +	sc += pos;
> +	old = sc->val;
> +	sc->val = mem;
> +
> +	return old;
> +}
> +
> +/**
> + * lookup_swap_cgroup - lookup mem_cgroup tied to swap entry
> + * @ent: swap entry to be looked up.
> + *
> + * Returns pointer to mem_cgroup at success. NULL at failure.
> + */
> +struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
> +{
> +	int type = swp_type(ent);
> +	unsigned long offset = swp_offset(ent);
> +	unsigned long idx = offset / SC_PER_PAGE;
> +	unsigned long pos = offset & SC_POS_MASK;
> +	struct swap_cgroup_ctrl *ctrl;
> +	struct page *mappage;
> +	struct swap_cgroup *sc;
> +	struct mem_cgroup *ret;
> +
> +	if (!do_swap_account)
> +		return NULL;
> +
> +	ctrl = &swap_cgroup_ctrl[type];
> +	mappage = ctrl->map[idx];
> +	sc = page_address(mappage);
> +	sc += pos;
> +	ret = sc->val;
> +	return ret;
> +}
> +
> +int swap_cgroup_swapon(int type, unsigned long max_pages)
> +{
> +	void *array;
> +	unsigned long array_size;
> +	unsigned long length;
> +	struct swap_cgroup_ctrl *ctrl;
> +
> +	if (!do_swap_account)
> +		return 0;
> +
> +	length = ((max_pages/SC_PER_PAGE) + 1);
> +	array_size = length * sizeof(void *);
> +
> +	array = vmalloc(array_size);
> +	if (!array)
> +		goto nomem;
> +
> +	memset(array, 0, array_size);
> +	ctrl = &swap_cgroup_ctrl[type];
> +	mutex_lock(&swap_cgroup_mutex);
> +	ctrl->length = length;
> +	ctrl->map = array;
> +	if (swap_cgroup_prepare(type)) {
> +		/* memory shortage */
> +		ctrl->map = NULL;
> +		ctrl->length = 0;
> +		vfree(array);
> +		mutex_unlock(&swap_cgroup_mutex);
> +		goto nomem;
> +	}
> +	mutex_unlock(&swap_cgroup_mutex);
> +
> +	printk(KERN_INFO
> +		"swap_cgroup: uses %ld bytes of vmalloc for pointer array space"
> +		" and %ld bytes to hold mem_cgroup pointers on swap\n",
> +		array_size, length * PAGE_SIZE);
> +	printk(KERN_INFO
> +	"swap_cgroup can be disabled by noswapaccount boot option.\n");
> +
> +	return 0;
> +nomem:
> +	printk(KERN_INFO "couldn't allocate enough memory for swap_cgroup.\n");
> +	printk(KERN_INFO
> +		"swap_cgroup can be disabled by noswapaccount boot option\n");
> +	return -ENOMEM;
> +}
> +
> +void swap_cgroup_swapoff(int type)
> +{
> +	int i;
> +	struct swap_cgroup_ctrl *ctrl;
> +
> +	if (!do_swap_account)
> +		return;
> +
> +	mutex_lock(&swap_cgroup_mutex);
> +	ctrl = &swap_cgroup_ctrl[type];
> +	if (ctrl->map) {
> +		for (i = 0; i < ctrl->length; i++) {
> +			struct page *page = ctrl->map[i];
> +			if (page)
> +				__free_page(page);
> +		}
> +		vfree(ctrl->map);
> +		ctrl->map = NULL;
> +		ctrl->length = 0;
> +	}
> +	mutex_unlock(&swap_cgroup_mutex);
> +}
> +
> +#endif
> Index: mmotm-2.6.28-Nov20/mm/swapfile.c
> ===================================================================
> --- mmotm-2.6.28-Nov20.orig/mm/swapfile.c
> +++ mmotm-2.6.28-Nov20/mm/swapfile.c
> @@ -32,6 +32,7 @@
>  #include <asm/pgtable.h>
>  #include <asm/tlbflush.h>
>  #include <linux/swapops.h>
> +#include <linux/page_cgroup.h>
>  
>  static DEFINE_SPINLOCK(swap_lock);
>  static unsigned int nr_swapfiles;
> @@ -1345,6 +1346,9 @@ asmlinkage long sys_swapoff(const char _
>  	spin_unlock(&swap_lock);
>  	mutex_unlock(&swapon_mutex);
>  	vfree(swap_map);
> +	/* Destroy swap account informatin */
> +	swap_cgroup_swapoff(type);
> +
>  	inode = mapping->host;
>  	if (S_ISBLK(inode->i_mode)) {
>  		struct block_device *bdev = I_BDEV(inode);
> @@ -1669,6 +1673,10 @@ asmlinkage long sys_swapon(const char __
>  		nr_good_pages = swap_header->info.last_page -
>  				swap_header->info.nr_badpages -
>  				1 /* header page */;
> +
> +		if (!error)
> +			error = swap_cgroup_swapon(type, maxpages);
> +
>  		if (error)
>  			goto bad_swap;
>  	}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
