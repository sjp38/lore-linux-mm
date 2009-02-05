Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 84CF56B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 08:17:45 -0500 (EST)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n15DFl32004588
	for <linux-mm@kvack.org>; Thu, 5 Feb 2009 08:15:47 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n15DHgnq158694
	for <linux-mm@kvack.org>; Thu, 5 Feb 2009 08:17:42 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n15DHggX021521
	for <linux-mm@kvack.org>; Thu, 5 Feb 2009 08:17:42 -0500
Date: Thu, 5 Feb 2009 05:17:41 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] Reduce size of swap_cgroup by CSS ID
Message-ID: <20090205131741.GC6915@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20090205185959.7971dee4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090205185959.7971dee4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 05, 2009 at 06:59:59PM +0900, KAMEZAWA Hiroyuki wrote:
> !!EXPERIMENTAL!!
> 
> against mmotm.
> 
> This patch tires to use CSS ID for records in swap_cgroup instead of pointer.
> By this, on 64bit machine, size of swap_cgroup goes down to 2 bytes from 8bytes.
> 
> This means, when 2GB of swap is equipped, (assume the page size is 4096bytes)
> 	From size of swap_cgroup = 2G/4k * 8 = 4Mbytes.
> 	To   size of swap_cgroup = 2G/4k * 2 = 1Mbytes.
> Reduction is large. Of course, there are trade-offs. This CSS ID will add
> overhead to swap-in/swap-out/swap-free.
> 
> But in general,
>   - swap is a resource which the user tend to avoid use.
>   - If swap is never used, swap_cgroup area is not used.
>   - Reading traditional manuals, size of swap should be proportional to
>     size of memory. Memory size of machine is increasing now. So, reducing
>     size of swap_cgroup makes sense.
> Note:
>   ID->CSS lookup routine has no locks, it's under RCU-Read-Side.

One question about css_tryget() below.

							Thanx, Paul

> This is still under test. Any comments are welcome.
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/page_cgroup.h |    9 +++----
>  mm/memcontrol.c             |   55 +++++++++++++++++++++++++++++++++++---------
>  mm/page_cgroup.c            |   22 ++++++++---------
>  3 files changed, 59 insertions(+), 27 deletions(-)
> 
> Index: mmotm-2.6.29-Feb03/include/linux/page_cgroup.h
> ===================================================================
> --- mmotm-2.6.29-Feb03.orig/include/linux/page_cgroup.h
> +++ mmotm-2.6.29-Feb03/include/linux/page_cgroup.h
> @@ -91,22 +91,21 @@ static inline void page_cgroup_init(void
> 
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  #include <linux/swap.h>
> -extern struct mem_cgroup *
> -swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem);
> -extern struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent);
> +extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
> +extern unsigned short lookup_swap_cgroup(swp_entry_t ent);
>  extern int swap_cgroup_swapon(int type, unsigned long max_pages);
>  extern void swap_cgroup_swapoff(int type);
>  #else
>  #include <linux/swap.h>
> 
>  static inline
> -struct mem_cgroup *swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem)
> +unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>  {
>  	return NULL;
>  }
> 
>  static inline
> -struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
> +unsigned short lookup_swap_cgroup(swp_entry_t ent)
>  {
>  	return NULL;
>  }
> Index: mmotm-2.6.29-Feb03/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.29-Feb03.orig/mm/memcontrol.c
> +++ mmotm-2.6.29-Feb03/mm/memcontrol.c
> @@ -1001,20 +1001,38 @@ nomem:
>  	return -ENOMEM;
>  }
> 
> +/*
> + * A helper function to get mem_cgroup from ID. must be called under
> + * rcu_read_lock(). Because css_tryget() is called under this, css_put
> + * should be called later.
> + */
> +static struct mem_cgroup *mem_cgroup_lookup_get(unsigned short id)
> +{
> +	struct cgroup_subsys_state *css;
> +
> +	/* ID 0 is unused ID */
> +	if (!id)
> +		return NULL;
> +	css = css_lookup(&mem_cgroup_subsys, id);
> +	if (css && css_tryget(css))
> +		return container_of(css, struct mem_cgroup, css);

So css_tryget(), if successful, prevents the structure referenced by
css from being freed, correct?  (If not, the range of the RCU read-side
critical sections surrounding calls to mem_cgroup_lookup_get() must be
extended.)

> +	return NULL;
> +}
> +
>  static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
>  {
> -	struct mem_cgroup *mem;
> +	unsigned short id;
> +	struct mem_cgroup *mem = NULL;
>  	swp_entry_t ent;
> 
>  	if (!PageSwapCache(page))
>  		return NULL;
> 
>  	ent.val = page_private(page);
> -	mem = lookup_swap_cgroup(ent);
> -	if (!mem)
> -		return NULL;
> -	if (!css_tryget(&mem->css))
> -		return NULL;
> +	id = lookup_swap_cgroup(ent);
> +	rcu_read_lock();
> +	mem = mem_cgroup_lookup_get(id);
> +	rcu_read_unlock();
>  	return mem;
>  }
> 
> @@ -1275,11 +1293,16 @@ int mem_cgroup_cache_charge(struct page 
> 
>  	if (do_swap_account && !ret && PageSwapCache(page)) {
>  		swp_entry_t ent = {.val = page_private(page)};
> +		unsigned short id;
>  		/* avoid double counting */
> -		mem = swap_cgroup_record(ent, NULL);
> +		id = swap_cgroup_record(ent, 0);
> +		rcu_read_lock();
> +		mem = mem_cgroup_lookup_get(id);
> +		rcu_read_unlock();
>  		if (mem) {
>  			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
>  			mem_cgroup_put(mem);
> +			css_put(&mem->css);
>  		}
>  	}
>  	return ret;
> @@ -1345,13 +1368,18 @@ void mem_cgroup_commit_charge_swapin(str
>  	 */
>  	if (do_swap_account && PageSwapCache(page)) {
>  		swp_entry_t ent = {.val = page_private(page)};
> +		unsigned short id;
>  		struct mem_cgroup *memcg;
> -		memcg = swap_cgroup_record(ent, NULL);
> +
> +		id = swap_cgroup_record(ent, 0);
> +		rcu_read_lock();
> +		memcg = mem_cgroup_lookup_get(id);
> +		rcu_read_unlock();
>  		if (memcg) {
>  			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
>  			mem_cgroup_put(memcg);
> +			css_put(&memcg->css);
>  		}
> -
>  	}
>  	/* add this page(page_cgroup) to the LRU we want. */
> 
> @@ -1472,7 +1500,7 @@ void mem_cgroup_uncharge_swapcache(struc
>  					MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
>  	/* record memcg information */
>  	if (do_swap_account && memcg) {
> -		swap_cgroup_record(ent, memcg);
> +		swap_cgroup_record(ent, css_id(&memcg->css));
>  		mem_cgroup_get(memcg);
>  	}
>  	if (memcg)
> @@ -1487,14 +1515,19 @@ void mem_cgroup_uncharge_swapcache(struc
>  void mem_cgroup_uncharge_swap(swp_entry_t ent)
>  {
>  	struct mem_cgroup *memcg;
> +	unsigned short id;
> 
>  	if (!do_swap_account)
>  		return;
> 
> -	memcg = swap_cgroup_record(ent, NULL);
> +	id = swap_cgroup_record(ent, 0);
> +	rcu_read_lock();
> +	memcg = mem_cgroup_lookup_get(id);
> +	rcu_read_unlock();
>  	if (memcg) {
>  		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
>  		mem_cgroup_put(memcg);
> +		css_put(&memcg->css);
>  	}
>  }
>  #endif
> Index: mmotm-2.6.29-Feb03/mm/page_cgroup.c
> ===================================================================
> --- mmotm-2.6.29-Feb03.orig/mm/page_cgroup.c
> +++ mmotm-2.6.29-Feb03/mm/page_cgroup.c
> @@ -290,7 +290,7 @@ struct swap_cgroup_ctrl swap_cgroup_ctrl
>   * cgroup rather than pointer.
>   */
>  struct swap_cgroup {
> -	struct mem_cgroup	*val;
> +	unsigned short		id;
>  };
>  #define SC_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
>  #define SC_POS_MASK	(SC_PER_PAGE - 1)
> @@ -345,7 +345,7 @@ not_enough_page:
>   * Returns old value at success, NULL at failure.
>   * (Of course, old value can be NULL.)
>   */
> -struct mem_cgroup *swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem)
> +unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>  {
>  	int type = swp_type(ent);
>  	unsigned long offset = swp_offset(ent);
> @@ -354,18 +354,18 @@ struct mem_cgroup *swap_cgroup_record(sw
>  	struct swap_cgroup_ctrl *ctrl;
>  	struct page *mappage;
>  	struct swap_cgroup *sc;
> -	struct mem_cgroup *old;
> +	unsigned short old;
> 
>  	if (!do_swap_account)
> -		return NULL;
> +		return 0;
> 
>  	ctrl = &swap_cgroup_ctrl[type];
> 
>  	mappage = ctrl->map[idx];
>  	sc = page_address(mappage);
>  	sc += pos;
> -	old = sc->val;
> -	sc->val = mem;
> +	old = sc->id;
> +	sc->id = id;
> 
>  	return old;
>  }
> @@ -374,9 +374,9 @@ struct mem_cgroup *swap_cgroup_record(sw
>   * lookup_swap_cgroup - lookup mem_cgroup tied to swap entry
>   * @ent: swap entry to be looked up.
>   *
> - * Returns pointer to mem_cgroup at success. NULL at failure.
> + * Returns CSS ID of mem_cgroup at success. NULL at failure.
>   */
> -struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
> +unsigned short lookup_swap_cgroup(swp_entry_t ent)
>  {
>  	int type = swp_type(ent);
>  	unsigned long offset = swp_offset(ent);
> @@ -385,16 +385,16 @@ struct mem_cgroup *lookup_swap_cgroup(sw
>  	struct swap_cgroup_ctrl *ctrl;
>  	struct page *mappage;
>  	struct swap_cgroup *sc;
> -	struct mem_cgroup *ret;
> +	unsigned short ret;
> 
>  	if (!do_swap_account)
> -		return NULL;
> +		return 0; /* 0 is invalid ID */
> 
>  	ctrl = &swap_cgroup_ctrl[type];
>  	mappage = ctrl->map[idx];
>  	sc = page_address(mappage);
>  	sc += pos;
> -	ret = sc->val;
> +	ret = sc->id;
>  	return ret;
>  }
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
