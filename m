Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2068E6B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 03:10:17 -0400 (EDT)
Date: Thu, 7 May 2009 15:59:50 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: fix stale swap cache leak v5
Message-Id: <20090507155950.80dd504a.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090504163806.GA4407@balbir.in.ibm.com>
References: <20090430161627.0ccce565.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430163539.7a882cef.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430180426.25ae2fa6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430094252.GG4430@balbir.in.ibm.com>
	<20090430184738.752858ea.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430181246.GM4430@balbir.in.ibm.com>
	<20090501133317.9c372d38.d-nishimura@mtf.biglobe.ne.jp>
	<20090504163806.GA4407@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>, d-nishimura@mtf.biglobe.ne.jp, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 4 May 2009 22:08:06 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> [2009-05-01 13:33:17]:
> 
> >               processA                   |           processB
> >     -------------------------------------+-------------------------------------
> >       (page_remove_rmap())               |  (shrink_page_list())
> >          mem_cgroup_uncharge_page()      |
> >             ->uncharged because it's not |
> >               PageSwapCache yet.         |
> >               So, both mem/memsw.usage   |
> >               are decremented.           |
> >                                          |    add_to_swap() -> added to swap cache.
> > 
> >     If this page goes thorough without being freed for some reason, this page
> >     doesn't goes back to memcg's LRU because of !PageCgroupUsed.
> 
> For some reason could use some clarification.
> 
If swap_writepage() is called(via pageout()), try_to_free_swap() in swap_writepage()
will free this unused swap cache.
But there are many checks before swap_writepage() is called.

For example, if page_referenced() returned true, "referenced" will be set,
so we hit the check:

	If (PageDirty(page)) {
		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
			goto keep_locked;

I think there are other cases.

> > 
> > These swap cache cannot be freed in memcg's LRU scanning, and swp_entry cannot
> > be freed properly as a result.
> > This patch adds a hook after add_to_swap() to check the page is mapped by a
> > process or not, and frees it if it has been unmapped already.
> > 
> > If a page has been on swap cache already when the owner process calls
> > page_remove_rmap() -> mem_cgroup_uncharge_page(), the page is not uncharged.
> > It goes back to memcg's LRU even if it goes through shrink_page_list()
> > without being freed, so this patch ignores these case.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  include/linux/swap.h |   12 ++++++++++++
> >  mm/memcontrol.c      |   14 ++++++++++++++
> >  mm/vmscan.c          |    8 ++++++++
> >  3 files changed, 34 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index caf0767..8e75d7a 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -336,11 +336,17 @@ static inline void disable_swap_token(void)
> > 
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> >  extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
> > +extern int memcg_free_unused_swapcache(struct page *page);
> >  #else
> >  static inline void
> >  mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
> >  {
> >  }
> > +static inline int
> > +memcg_free_unused_swapcache(struct page *page)
> > +{
> > +	return 0;
> > +}
> >  #endif
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> >  extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
> > @@ -431,6 +437,12 @@ static inline swp_entry_t get_swap_page(void)
> >  #define has_swap_token(x) 0
> >  #define disable_swap_token() do { } while(0)
> > 
> > +static inline int
> > +memcg_free_unused_swapcache(struct page *page)
> > +{
> > +	return 0;
> > +}
> > +
> >  #endif /* CONFIG_SWAP */
> >  #endif /* __KERNEL__*/
> >  #endif /* _LINUX_SWAP_H */
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 01c2d8f..4f7e5b6 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1488,6 +1488,7 @@ void mem_cgroup_uncharge_cache_page(struct page *page)
> >  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
> >  }
> > 
> > +#ifdef CONFIG_SWAP
> >  /*
> >   * called from __delete_from_swap_cache() and drop "page" account.
> >   * memcg information is recorded to swap_cgroup of "ent"
> > @@ -1507,6 +1508,19 @@ void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
> >  		css_put(&memcg->css);
> >  }
> > 
> > +int memcg_free_unused_swapcache(struct page *page)
> > +{
> > +	VM_BUG_ON(!PageLocked(page));
> > +	VM_BUG_ON(!PageSwapCache(page));
> > +
> > +	if (mem_cgroup_disabled())
> > +		return 0;
> > +	if (!PageAnon(page) || page_mapped(page))
> > +		return 0;
> 
> Do we need these checks? Isn't PageSwapCache() check and
> page_swapcount() check enough in try_to_free_swap()?
> 
I think this is needed.
page_swapcount() will return true, because this page has just been added
to swap cache(try_to_unmap() has not been called yet).

> > +	return try_to_free_swap(page);	/* checks page_swapcount */
> 
> try_to_free_swap() marks the page as dirty, do you know why?
> 
I'm not sure.
Other callers of delete_from_swap_cache() also set the page dirty.

> > +}
> > +#endif /* CONFIG_SWAP */
> > +
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> >  /*
> >   * called from swap_entry_free(). remove record in swap_cgroup and
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index eac9577..c1a7a6f 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -656,6 +656,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  				goto keep_locked;
> >  			if (!add_to_swap(page))
> >  				goto activate_locked;
> > +			/*
> > +			 * The owner process might have uncharged the page
> > +			 * (by page_remove_rmap()) before it has been added
> > +			 * to swap cache.
> > +			 * Check it here to avoid making it stale.
> > +			 */
> > +			if (memcg_free_unused_swapcache(page))
> > +				goto keep_locked;
> 
> Seems reasonable, but I think it is better to check for
> scan_global_lru().. no?
> 
hmm, we cannot ensure that additional global LRU scanning will happen after this,
so I think it would be better to free this swap cache if possible
instead of making it stale.


Thanks,
Daisuke Nishimura.

> >  			may_enter_fs = 1;
> >  		}
> > 
> > 
> 
> -- 
> 	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
