Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E5A246B00A0
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 02:12:16 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3M6CPoC018914
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 22 Apr 2009 15:12:25 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D46545DD80
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 15:12:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D2A9445DD82
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 15:12:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 58DD1E08004
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 15:12:24 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D70541DB8041
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 15:12:23 +0900 (JST)
Date: Wed, 22 Apr 2009 15:10:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] fix swap entries is not reclaimed in proper way
 for mem+swap controller
Message-Id: <20090422151052.5a511c52.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090422143833.2e11e10b.nishimura@mxp.nes.nec.co.jp>
References: <20090421162121.1a1d15fe.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422143833.2e11e10b.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Apr 2009 14:38:33 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 21 Apr 2009 16:21:21 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > maybe this patch covers almost all cases of swap-leak of memcg, Nishimura-san
> > reported. There are many callers of lock_page() but lock_page() which can
> > be racy with free_swap_and_cache() is not so much, I think.
> > 
> > Nishimura-san, How about this ?
> > 
> Thank you for your patch.
> 
> I've run this patch last night but unfortunately I got a BUG.
> 
>   BUG: sleeping function called from invalid context at include/linux/pagemap.h:327
>   in_atomic(): 1, irqs_disabled(): 0, pid: 9230, name: page01
> 
> hmm, calling lock_page() in end_swap_bio_* seems not safe.
> 
Ugh. ok, calling lock_page is bad.


> And, some comments are inlined.
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > free_swap_and_cache(), which is called under various spin_lock,
> > is designed to be best-effort function and it does nothing if the page
> > is locked, under I/O. But it's ok because global lru will find the page finally.
> > 
> > But, when it comes to memory+swap cgroup, global LRU may not work and
> > swap entry can be alive as "not used but not freed" state for very very long time
> > because memory cgroup's LRU routine scans its own LRU only.
> > (Such stale swap-cache is out of memcg's LRU)
> > 
> > Nishimura repoted such kind of swap cache makes memcg unstable and
> >  - we can never free mem_cgroup object (....it's big) even if no users.
> >  - OOM killer can happen because amounts of charge-to-swap is leaked.
> >
> And 
>  
> - All the swap space(swap entries) could be exhausted by these swap cache.
> 
Hmm, maybe.


> > This patch tries to fix the problem by adding PageCgroupStale() flag.
> > If a page which is under zappped is busy swap cache, recored it as Stale.
> > At the end of swap I/O, Stale flag is checked and swap and swapcache is
> > freed if necessary. Page migration case is also checked.
> > 
> > 
> > Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > ---
> >  include/linux/page_cgroup.h |    4 +++
> >  include/linux/swap.h        |    8 ++++++
> >  mm/memcontrol.c             |   51 ++++++++++++++++++++++++++++++++++++++++----
> >  mm/page_io.c                |    2 +
> >  mm/swapfile.c               |    1 
> >  5 files changed, 62 insertions(+), 4 deletions(-)
> > 
> > Index: linux-2.6.30-rc2/include/linux/page_cgroup.h
> > ===================================================================
> > --- linux-2.6.30-rc2.orig/include/linux/page_cgroup.h
> > +++ linux-2.6.30-rc2/include/linux/page_cgroup.h
> > @@ -26,6 +26,7 @@ enum {
> >  	PCG_LOCK,  /* page cgroup is locked */
> >  	PCG_CACHE, /* charged as cache */
> >  	PCG_USED, /* this object is in use. */
> > +	PCG_STALE, /* may be a stale swap-cache */
> >  };
> >  
> >  #define TESTPCGFLAG(uname, lname)			\
> > @@ -46,6 +47,9 @@ TESTPCGFLAG(Cache, CACHE)
> >  TESTPCGFLAG(Used, USED)
> >  CLEARPCGFLAG(Used, USED)
> >  
> > +TESTPCGFLAG(Stale, STALE)
> > +SETPCGFLAG(Stale, STALE)
> > +
> >  static inline int page_cgroup_nid(struct page_cgroup *pc)
> >  {
> >  	return page_to_nid(pc->page);
> > Index: linux-2.6.30-rc2/include/linux/swap.h
> > ===================================================================
> > --- linux-2.6.30-rc2.orig/include/linux/swap.h
> > +++ linux-2.6.30-rc2/include/linux/swap.h
> > @@ -344,10 +344,18 @@ mem_cgroup_uncharge_swapcache(struct pag
> >  #endif
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> >  extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
> > +extern void mem_cgroup_mark_swapcache_stale(struct page *page);
> > +extern void mem_cgroup_fixup_swapcache(struct page *page);
> >  #else
> >  static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
> >  {
> >  }
> > +static void mem_cgroup_check_mark_swapcache_stale(struct page *page)
> > +{
> > +}
> > +static void mem_cgroup_fixup_swapcache(struct page *page)
> > +{
> > +}
> >  #endif
> >  
> I think they should be defined in MEM_RES_CTLR case.
> Exhausting swap entries problem is not depend on MEM_RES_CTLR_SWAP.
> 
Hmm, ok.


> >  #else /* CONFIG_SWAP */
> > Index: linux-2.6.30-rc2/mm/memcontrol.c
> > ===================================================================
> > --- linux-2.6.30-rc2.orig/mm/memcontrol.c
> > +++ linux-2.6.30-rc2/mm/memcontrol.c
> > @@ -1534,6 +1534,47 @@ void mem_cgroup_uncharge_swap(swp_entry_
> >  	}
> >  	rcu_read_unlock();
> >  }
> > +
> > +/*
> > + * free_swap_and_cache() is an best-effort function and it doesn't free
> > + * swapent if the swapcache seems to be busy (ex. the page is locked.)
> > + * This behavior is designed to be as is but mem+swap cgroup has to handle it.
> > + * Otherwise, swp_entry seems to be leaked (for very long time)
> > + */
> > +void mem_cgroup_mark_swapcache_stale(struct page *page)
> > +{
> > +	struct page_cgroup *pc;
> > +
> > +	if (!PageSwapCache(page) || page_mapped(page))
> > +		return;
> > +
> > +	pc = lookup_page_cgroup(page);
> > +	lock_page_cgroup(pc);
> > +
> > +	/*
> > +	 * This "Stale" flag will be cleared when the page is reused
> > +	 * somewhere.
> > +	 */
> > +	if (!PageCgroupUsed(pc))
> > +		SetPageCgroupStale(pc);
> > +	unlock_page_cgroup(pc);
> > +}
> > +
> > +void mem_cgroup_fixup_swapcache(struct page *page)
> > +{
> > +	struct page_cgroup *pc = lookup_page_cgroup(page);
> > +
> > +	/* Stale flag will be cleared automatically */
> > +	if (unlikely(PageCgroupStale(pc))) {
> > +		if (get_page_unless_zero(page)) {
> > +			lock_page(page);
> > +			try_to_free_swap(page);
> > +			unlock_page(page);
> > +			page_cache_release(page);
> > +		}
> > +	}
> > +}
> > +
> >  #endif
> >  
> >  /*
> > @@ -1604,17 +1645,19 @@ void mem_cgroup_end_migration(struct mem
> >  	__mem_cgroup_commit_charge(mem, pc, ctype);
> >  
> >  	/*
> > -	 * Both of oldpage and newpage are still under lock_page().
> > -	 * Then, we don't have to care about race in radix-tree.
> > -	 * But we have to be careful that this page is unmapped or not.
> > +	 * oldpage is under lock_page() at migration. Then, we don't have to
> > +	 * care about race in radix-tree. But we have to be careful
> > +	 * that this page is unmapped or not.
> >  	 *
> >  	 * There is a case for !page_mapped(). At the start of
> >  	 * migration, oldpage was mapped. But now, it's zapped.
> >  	 * But we know *target* page is not freed/reused under us.
> >  	 * mem_cgroup_uncharge_page() does all necessary checks.
> >  	 */
> > -	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> > +	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED) {
> >  		mem_cgroup_uncharge_page(target);
> > +		mem_cgroup_fixup_swapcache(target);
> > +	}
> >  }
> >  
> >  /*
> hmm, the intention of the patch I posted(*) is not free stale SwapCache.
> 
> * http://marc.info/?l=linux-mm&m=124029196025611&w=2
> 
> If the oldpage was page_mapped() and !PageSwapCache, newpage would be
> uncharge by mem_cgroup_uncharge_page() if the owner process has been exited
> (because newpage is !page_mapped()).
> But if the oldpage was page_mapped and PageSwapCache, newpage cannot be
> uncharged by mem_cgroup_uncharge_page() even if the owner process has been exited.
> 
> Those SwapCache is put_back'ed to memcg's LRU, so it can be reclaimed
> if memcg's LRU scaning(Anon) run, but my intention was to fix this behavior
> for consistency.
> 
Hmm, but please remove lock_page() to newpage. (i.e. plz fix comment in memcontrol.c)

> > Index: linux-2.6.30-rc2/mm/page_io.c
> > ===================================================================
> > --- linux-2.6.30-rc2.orig/mm/page_io.c
> > +++ linux-2.6.30-rc2/mm/page_io.c
> > @@ -68,6 +68,7 @@ static void end_swap_bio_write(struct bi
> >  	}
> >  	end_page_writeback(page);
> >  	bio_put(bio);
> > +	mem_cgroup_fixup_swapcache(page);
> >  }
> >  
> >  void end_swap_bio_read(struct bio *bio, int err)
> > @@ -87,6 +88,7 @@ void end_swap_bio_read(struct bio *bio, 
> >  	}
> >  	unlock_page(page);
> >  	bio_put(bio);
> > +	mem_cgroup_fixup_swapcache(page);
> >  }
> >  
> >  /*
> > Index: linux-2.6.30-rc2/mm/swapfile.c
> > ===================================================================
> > --- linux-2.6.30-rc2.orig/mm/swapfile.c
> > +++ linux-2.6.30-rc2/mm/swapfile.c
> > @@ -587,6 +587,7 @@ int free_swap_and_cache(swp_entry_t entr
> >  		if (swap_entry_free(p, entry) == 1) {
> >  			page = find_get_page(&swapper_space, entry.val);
> >  			if (page && !trylock_page(page)) {
> > +				mem_cgroup_mark_swapcache_stale(page);
> >  				page_cache_release(page);
> >  				page = NULL;
> >  			}
> > 
> 
> IIUC, this patch cannot handle(even if it worked as intended) cases like:
> 
>             processA                   |           processB
>   -------------------------------------+-------------------------------------
>     (free_swap_and_cache())            |  (read_swap_cache_async())
>                                        |    swap_duplicate()
>       swap_entry_free() == 1           |
>       find_get_page()                  |
>          -> cannot find. so            |
>             PCG_STALE isn't set.       |
>                                        |    add_to_swap_cache()
>                                        |
>                                        |    swap_readpage()
>                                        |      end_swap_bio_read()
>                                        |        mem_cgroup_fixup_swapcache()
>                                        |          does nothing becase !PageCgroupStale
> 
>   (the page is mapped but not on swapcache)
>             processA                   |           processB
>   -------------------------------------+-------------------------------------
>     (zap_pte_range())                  |  (shrink_page_list())
>                                        |  (referenced flag is set in some reason)
>       page_remove_rmap()               |
>         -> uncharged(!PageSwapCache)   |
>                                        |    add_to_swap()
>                                        |      -> succeed
>                                        |
>                                        |  (not freed because referenced flag is set)
> 
> So, we should add check to shrink_page_list() anyway, IMHO.
> 
Maybe I should forget this patch ;)

> 
> Hmm... I tested a patch like below, but it seems to have a dead lock about swap_lock.
> (This patch has unhandled corner cases yet, even if it worked.)
> 
> I'll dig and try more including another aproach..
> 
> ---
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 62d8143..991dd53 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -336,11 +336,16 @@ static inline void disable_swap_token(void)
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
> +extern void mem_cgroup_fixup_swapcache(struct page *page);
>  #else
>  static inline void
>  mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
>  {
>  }
> +static inline void
> +mem_cgroup_fixup_swapcache(struct page *page)
> +{
> +}
>  #endif
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ba07cab..b2a4d52 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1568,6 +1568,19 @@ void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
>  		css_put(&memcg->css);
>  }
>  
> +void mem_cgroup_fixup_swapcache(struct page *page)
> +{
> +	if (mem_cgroup_disabled())
> +		return;
> +
> +	VM_BUG_ON(!PageLocked(page));
> +
> +	if (get_page_unless_zero(page)) {
> +		try_to_free_swap(page);
> +		page_cache_release(page);
> +	}
> +}
Because the page is locked, page_cache_release() is unnecessary.

> +
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  /*
>   * called from swap_entry_free(). remove record in swap_cgroup and
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 3023c47..2bafcd3 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -85,6 +85,7 @@ void end_swap_bio_read(struct bio *bio, int err)
>  	} else {
>  		SetPageUptodate(page);
>  	}
> +	mem_cgroup_fixup_swapcache(page);

try_to_free_swap() at every end_swap_bio_read() ? We'll get tons of NACK.

Thanks,
-Kame

>  	unlock_page(page);
>  	bio_put(bio);
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
