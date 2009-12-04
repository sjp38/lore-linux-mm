Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DFDAE6007BA
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 05:53:38 -0500 (EST)
Date: Fri, 4 Dec 2009 19:53:27 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH -mmotm 6/7] memcg: move charges of anonymous swap
Message-Id: <20091204195327.cd2bb1e2.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20091204163237.996b0d89.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
	<20091204145255.85160b8b.nishimura@mxp.nes.nec.co.jp>
	<20091204163237.996b0d89.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 2009 16:32:37 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 4 Dec 2009 14:52:55 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This patch is another core part of this move-charge-at-task-migration feature.
> > It enables moving charges of anonymous swaps.
> > 
> > To move the charge of swap, we need to exchange swap_cgroup's record.
> > 
> > In current implementation, swap_cgroup's record is protected by:
> > 
> >   - page lock: if the entry is on swap cache.
> >   - swap_lock: if the entry is not on swap cache.
> > 
> > This works well in usual swap-in/out activity.
> > 
> > But this behavior make the feature of moving swap charge check many conditions
> > to exchange swap_cgroup's record safely.
> > 
> > So I changed modification of swap_cgroup's recored(swap_cgroup_record())
> > to use xchg, and define a new function to cmpxchg swap_cgroup's record.
> > 
> > This patch also enables moving charge of non pte_present but not uncharged swap
> > caches, which can be exist on swap-out path, by getting the target pages via
> > find_get_page() as do_mincore() does.
> > 
> > Changelog: 2009/12/04
> > - minor changes in comments and valuable names.
> > Changelog: 2009/11/19
> > - in can_attach(), instead of parsing the page table, make use of per process
> >   mm_counter(swap_usage).
> > Changelog: 2009/11/06
> > - drop support for shmem's swap(revisit in future).
> > - add mem_cgroup_count_swap_user() to prevent moving charges of swaps used by
> >   multiple processes(revisit in future).
> > Changelog: 2009/09/24
> > - do no swap-in in moving swap account any more.
> > - add support for shmem's swap.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  include/linux/page_cgroup.h |    2 +
> >  include/linux/swap.h        |    1 +
> >  mm/memcontrol.c             |  154 +++++++++++++++++++++++++++++++++----------
> >  mm/page_cgroup.c            |   35 +++++++++-
> >  mm/swapfile.c               |   31 +++++++++
> >  5 files changed, 185 insertions(+), 38 deletions(-)
> > 
> > diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> > index b0e4eb1..30b0813 100644
> > --- a/include/linux/page_cgroup.h
> > +++ b/include/linux/page_cgroup.h
> > @@ -118,6 +118,8 @@ static inline void __init page_cgroup_init_flatmem(void)
> >  #include <linux/swap.h>
> >  
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > +extern unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
> > +					unsigned short old, unsigned short new);
> >  extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
> >  extern unsigned short lookup_swap_cgroup(swp_entry_t ent);
> >  extern int swap_cgroup_swapon(int type, unsigned long max_pages);
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 9f0ca32..2a3209e 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -355,6 +355,7 @@ static inline void disable_swap_token(void)
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> >  extern void
> >  mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout);
> > +extern int mem_cgroup_count_swap_user(swp_entry_t ent, struct page **pagep);
> >  #else
> >  static inline void
> >  mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index f50ad15..6b3d17f 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -33,6 +33,7 @@
> >  #include <linux/rbtree.h>
> >  #include <linux/slab.h>
> >  #include <linux/swap.h>
> > +#include <linux/swapops.h>
> >  #include <linux/spinlock.h>
> >  #include <linux/fs.h>
> >  #include <linux/seq_file.h>
> > @@ -2258,6 +2259,53 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
> >  	}
> >  	rcu_read_unlock();
> >  }
> > +
> > +/**
> > + * mem_cgroup_move_swap_account - move swap charge and swap_cgroup's record.
> > + * @entry: swap entry to be moved
> > + * @from:  mem_cgroup which the entry is moved from
> > + * @to:  mem_cgroup which the entry is moved to
> > + *
> > + * It succeeds only when the swap_cgroup's record for this entry is the same
> > + * as the mem_cgroup's id of @from.
> > + *
> > + * Returns 0 on success, -EINVAL on failure.
> > + *
> > + * The caller must have charged to @to, IOW, called res_counter_charge() about
> > + * both res and memsw, and called css_get().
> > + */
> > +static int mem_cgroup_move_swap_account(swp_entry_t entry,
> > +				struct mem_cgroup *from, struct mem_cgroup *to)
> > +{
> > +	unsigned short old_id, new_id;
> > +
> > +	old_id = css_id(&from->css);
> > +	new_id = css_id(&to->css);
> > +
> > +	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
> > +		if (!mem_cgroup_is_root(from))
> > +			res_counter_uncharge(&from->memsw, PAGE_SIZE);
> > +		mem_cgroup_swap_statistics(from, false);
> > +		mem_cgroup_put(from);
> > +		/*
> > +		 * we charged both to->res and to->memsw, so we should uncharge
> > +		 * to->res.
> > +		 */
> > +		if (!mem_cgroup_is_root(to))
> > +			res_counter_uncharge(&to->res, PAGE_SIZE);
> > +		mem_cgroup_swap_statistics(to, true);
> > +		mem_cgroup_get(to);
> > +
> > +		return 0;
> > +	}
> > +	return -EINVAL;
> > +}
> 
> Hmm. Aren't there race with swapin ?
> 
>     Thread A
>    ----------
>    do_swap_page()
>    mem_cgroup_try_charge_swapin() <<== charge "memory" against old memcg.
>    page table lock
>    mem_cgroup_commit_charge_swapin()
>          lookup memcg from swap_cgroup() <<=== finds new memcg, moved one.
>                 res_counter_uncharge(&new_memcg->memsw,...)
>                  
> Then, Thread A does
>    old_memcg->res +1 
>    new_memcg->memsw -1
> 
> move_swap_account() does
>    old_memcg->memsw - 1
>    new_memcg->res - 1
>    new_memcg->memsw + 1
> 
> Hmm. old_memcg->res doesn't leak ? I think some check in commit_charge()
> for this new race is necessary.
> 
The race exists, but it's not a "leak": I mean the page will be charged
as memory to old_memcg.

Before state: (with sc->id == id of old_memcg)
	old_memcg->res: 0		new_memcg->res: 0
	old_memcg->memsw: 1	new_memcg->memsw: 0

Thread A does:
	do_swap_page()
		mem_cgroup_try_charge_swapin()
			=> old_memcg->res++, old_memcg->memsw++
		<task migration context moves the charge of swap>
		pte_offset_map_lock()
		mem_cgroup_try_charge_swapin()
			=> set pc->mem_cgroup to old_memcg(it's passed as an arg)
			mem_cgroup_lookup()
				=> finds new_memcg
			res_counter_uncharge()
				=> new_memcg->memsw--
		pte_unmap_unlock()

OTOH, the task migration context does:
	can_attach()
		do_precharge()
			=> new_memcg->res++, new_memcg->memsw++
	attach()
		pte_offset_map_lock()
		mem_cgroup_move_swap_account()
			=> old_memcg->memsw--, new_memcg->res--
		pte_unmap_unlock()

So,

After state: (with pc->mem_cgroup == old_memcg)
	old_memcg->res: 1		new_memcg->res: 0
	old_memcg->memsw: 1	new_memcg->memsw: 0

IMHO, some races where we cannot move the account would be unavoidable.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
