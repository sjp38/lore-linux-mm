Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 598946B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 01:27:59 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8H5S59C018991
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Sep 2009 14:28:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5923E45DD77
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 14:28:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1351A45DE51
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 14:28:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C22C31DB803B
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 14:28:04 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 622441DB8042
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 14:28:04 +0900 (JST)
Date: Thu, 17 Sep 2009 14:25:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 7/8] memcg: migrate charge of swap
Message-Id: <20090917142558.58f3e8ef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090917112817.b3829458.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917112817.b3829458.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Sep 2009 11:28:17 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch is another core part of this charge migration feature.
> It enables charge migration of swap.
> 
> Unlike mapped page, swaps of anonymous pages have its entry stored in the pte.
> So this patch calls read_swap_cache_async() and do the same thing about the swap-in'ed
> page as anonymous pages in migrate_charge_prepare_pte_range(), and handles !PageCgroupUsed
> case in mem_cgroup_migrate_charge().

Hmmm.....do we really need to do swap-in ? I think no.

> 
> To exchange swap_cgroup's record safely, this patch changes swap_cgroup_record()
> to use xchg, and define new function to cmpxchg swap_cgroup's record.
> 
I think this is enough.

BTW, it's not very bad to do this exchange under swap_lock. (if charge is done.)
Then, the whole logic can be simple.



> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  include/linux/page_cgroup.h |    2 +
>  mm/memcontrol.c             |  127 +++++++++++++++++++++++++++++++++++++++++--
>  mm/page_cgroup.c            |   35 +++++++++++-
>  3 files changed, 158 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 321f037..6bf83f7 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -122,6 +122,8 @@ static inline void __init page_cgroup_init_flatmem(void)
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  #include <linux/swap.h>
> +extern unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
> +					unsigned short old, unsigned short new);
>  extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
>  extern unsigned short lookup_swap_cgroup(swp_entry_t ent);
>  extern int swap_cgroup_swapon(int type, unsigned long max_pages);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f46fd19..c8542e7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -34,6 +34,7 @@
>  #include <linux/rbtree.h>
>  #include <linux/slab.h>
>  #include <linux/swap.h>
> +#include <linux/swapops.h>
>  #include <linux/spinlock.h>
>  #include <linux/fs.h>
>  #include <linux/seq_file.h>
> @@ -1982,6 +1983,49 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
>  	}
>  	rcu_read_unlock();
>  }
> +
> +/**
> + * mem_cgroup_move_swap_account - move swap charge and swap_cgroup's record.
> + * @entry: swap entry to be moved
> + * @from:  mem_cgroup which the entry is moved from
> + * @to:  mem_cgroup which the entry is moved to
> + *
> + * It successes only when the swap_cgroup's record for this entry is the same
> + * as the mem_cgroup's id of @from.
> + *
> + * Returns 0 on success, 1 on failure.
> + *
> + * The caller must have called __mem_cgroup_try_charge on @to.
> + */
> +static int mem_cgroup_move_swap_account(swp_entry_t entry,
> +				struct mem_cgroup *from, struct mem_cgroup *to)
> +{
> +	unsigned short old_id, new_id;
> +
> +	old_id = css_id(&from->css);
> +	new_id = css_id(&to->css);
> +
> +	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
> +		if (!mem_cgroup_is_root(from))
> +			res_counter_uncharge(&from->memsw, PAGE_SIZE, NULL);
> +		mem_cgroup_swap_statistics(from, false);
> +		mem_cgroup_put(from);
> +
> +		if (!mem_cgroup_is_root(to))
> +			res_counter_uncharge(&to->res, PAGE_SIZE, NULL);
> +		mem_cgroup_swap_statistics(to, true);
> +		mem_cgroup_get(to);
> +
> +		return 0;
> +	}
> +	return 1;
> +}
> +#else
> +static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
> +				struct mem_cgroup *from, struct mem_cgroup *to)
> +{
> +	return 0;
> +}
>  #endif
>  
>  /*
> @@ -2845,6 +2889,7 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  enum migrate_charge_type {
>  	MIGRATE_CHARGE_ANON,
>  	MIGRATE_CHARGE_SHMEM,
> +	MIGRATE_CHARGE_SWAP,
>  	NR_MIGRATE_CHARGE_TYPE,
>  };
>  
> @@ -3213,6 +3258,17 @@ static int migrate_charge_prepare_pte_range(pmd_t *pmd,
>  	bool move_anon = (mc->to->migrate_charge & (1 << MIGRATE_CHARGE_ANON));
>  	bool move_shmem = (mc->to->migrate_charge &
>  					(1 << MIGRATE_CHARGE_SHMEM));
> +	bool move_swap = do_swap_account &&
> +			(mc->to->migrate_charge & (1 << MIGRATE_CHARGE_SWAP));
> +	swp_entry_t *table = NULL;
> +	int idx = 0;
> +
> +	if (move_swap) {
> +		table = kmalloc(sizeof(swp_entry_t) * PTRS_PER_PTE, GFP_KERNEL);
> +		if (!table)
> +			return -ENOMEM;
> +		memset(table, 0, sizeof(swp_entry_t) * PTRS_PER_PTE);
> +	}
>  
>  	lru_add_drain_all();
>  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> @@ -3220,8 +3276,29 @@ static int migrate_charge_prepare_pte_range(pmd_t *pmd,
>  		struct page_cgroup *pc;
>  
>  		ptent = *pte;
> -		if (!pte_present(ptent))
> +		if (!pte_present(ptent)) {
> +			swp_entry_t ent = { .val = 0 };
> +
> +			if (!move_swap)
> +				continue;
> +
> +			/* TODO: handle swap of shmes/tmpfs */
> +			if (pte_none(ptent) || pte_file(ptent))
> +				continue;
> +			else if (is_swap_pte(ptent) && move_anon)
> +				ent = pte_to_swp_entry(ptent);
> +
> +			if (ent.val == 0)
> +				continue;
> +			if (is_migration_entry(ent))
> +				continue;
> +			if (css_id(&mc->from->css) != lookup_swap_cgroup(ent))
> +				continue;
> +
> +			swap_duplicate(ent);	/* freed later */
> +			table[idx++] = ent;
>  			continue;
> +		}
>  
>  		page = vm_normal_page(vma, addr, ptent);
>  		if (!page)
> @@ -3253,6 +3330,24 @@ static int migrate_charge_prepare_pte_range(pmd_t *pmd,
>  	pte_unmap_unlock(pte - 1, ptl);
>  	cond_resched();
>  
> +	if (table) {
> +		int i;
> +		for (i = 0; i < idx; i++) {
> +			page = read_swap_cache_async(table[i],
> +						GFP_HIGHUSER_MOVABLE, vma, 0);

Hmm...I think this should be..

			page = lookup_swap_cache(table[i]);
..

			if (page) {
				isolate this page. and put into the list if PageCgroupUsed().

				pc = lookup_page_cgroup(page);
				lock_page_cgroup(pc);
				if (PageCgroupUsed(pc) && pc->mem_cgroup )
					charge against this.
					mc->charged++;
					
			}
			/* If !page or page is not accounted */
			if (!mem) {
				id = lookup_swap_cgroup(ent);
				account aganst "id"
				mc->swap_charged++.
			}
...

IIUC, we do exchange in swap_cgroup[] under swap_lock(), we can do safe exchange
of account because we can know there are swapcache or not by swap_map.
(see swap_has_cache())

Anyway, I never want to see this swapin ;(


Thanks,
-Kame

> +			swap_free(table[i]);
> +			if (!page) {
> +				ret = -ENOMEM;
> +				goto out;
> +			}
> +			lru_add_drain();
> +			if (!isolate_lru_page(page))
> +				list_add_tail(&page->lru, &list);
> +			else
> +				put_page(page);
> +			cond_resched();
> +		}
> +	}
>  	if (!list_empty(&list))
>  		list_for_each_entry_safe(page, tmp, &list, lru) {
>  			struct mem_cgroup *mem = mc->to;
> @@ -3263,10 +3358,10 @@ static int migrate_charge_prepare_pte_range(pmd_t *pmd,
>  			list_move_tail(&page->lru, &mc->list);
>  			cond_resched();
>  		}
> -
> +out:
>  	/*
>  	 * We should put back all pages which remain on "list".
> -	 * This means try_charge above has failed.
> +	 * This means try_charge or read_swap_cache_async above has failed.
>  	 * Pages which have been moved to mc->list would be put back at
>  	 * clear_migrate_charge.
>  	 */
> @@ -3277,7 +3372,7 @@ static int migrate_charge_prepare_pte_range(pmd_t *pmd,
>  			put_page(page);
>  		}
>  	}
> -
> +	kfree(table);
>  	return ret;
>  }
>  
> @@ -3391,10 +3486,14 @@ static void mem_cgroup_migrate_charge(void)
>  {
>  	struct page *page, *tmp;
>  	struct page_cgroup *pc;
> +	bool move_swap;
>  
>  	if (!mc)
>  		return;
>  
> +	move_swap = do_swap_account &&
> +			(mc->to->migrate_charge & (1 << MIGRATE_CHARGE_SWAP));
> +
>  	if (!list_empty(&mc->list))
>  		list_for_each_entry_safe(page, tmp, &mc->list, lru) {
>  			pc = lookup_page_cgroup(page);
> @@ -3406,7 +3505,27 @@ static void mem_cgroup_migrate_charge(void)
>  				list_del(&page->lru);
>  				putback_lru_page(page);
>  				put_page(page);
> +			} else if (!PageCgroupUsed(pc) && move_swap) {
> +				/*
> +				 * we can't call lock_page() under
> +				 * page_cgroup lock.
> +				 */
> +				if (!trylock_page(page))
> +					goto out;
> +				if (PageSwapCache(page)) {
> +					swp_entry_t ent;
> +					ent.val = page_private(page);
> +					if (!mem_cgroup_move_swap_account(ent,
> +							mc->from, mc->to)) {
> +						css_put(&mc->to->css);
> +						list_del(&page->lru);
> +						putback_lru_page(page);
> +						put_page(page);
> +					}
> +				}
> +				unlock_page(page);
>  			}
> +out:
>  			unlock_page_cgroup(pc);
>  			cond_resched();
>  		}
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 3d535d5..9532169 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -9,6 +9,7 @@
>  #include <linux/vmalloc.h>
>  #include <linux/cgroup.h>
>  #include <linux/swapops.h>
> +#include <asm/cmpxchg.h>
>  
>  static void __meminit
>  __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
> @@ -335,6 +336,37 @@ not_enough_page:
>  }
>  
>  /**
> + * swap_cgroupo_cmpxchg - cmpxchg mem_cgroup's id for this swp_entry.
> + * @end: swap entry to be cmpxchged
> + * @old: old id
> + * @new: new id
> + *
> + * Returns old id at success, 0 at failure.
> + * (There is no mem_cgroup useing 0 as its id)
> + */
> +unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
> +					unsigned short old, unsigned short new)
> +{
> +	int type = swp_type(ent);
> +	unsigned long offset = swp_offset(ent);
> +	unsigned long idx = offset / SC_PER_PAGE;
> +	unsigned long pos = offset & SC_POS_MASK;
> +	struct swap_cgroup_ctrl *ctrl;
> +	struct page *mappage;
> +	struct swap_cgroup *sc;
> +
> +	ctrl = &swap_cgroup_ctrl[type];
> +
> +	mappage = ctrl->map[idx];
> +	sc = page_address(mappage);
> +	sc += pos;
> +	if (cmpxchg(&sc->id, old, new) == old)
> +		return old;
> +	else
> +		return 0;
> +}
> +
> +/**
>   * swap_cgroup_record - record mem_cgroup for this swp_entry.
>   * @ent: swap entry to be recorded into
>   * @mem: mem_cgroup to be recorded
> @@ -358,8 +390,7 @@ unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>  	mappage = ctrl->map[idx];
>  	sc = page_address(mappage);
>  	sc += pos;
> -	old = sc->id;
> -	sc->id = id;
> +	old = xchg(&sc->id, id);
>  
>  	return old;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
