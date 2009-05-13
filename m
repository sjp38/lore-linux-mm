Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 882C96B00BB
	for <linux-mm@kvack.org>; Tue, 12 May 2009 23:56:38 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4D3vU0T024712
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 May 2009 12:57:30 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DBE312AEA82
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:57:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C5411EF084
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:57:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 379C31DB8038
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:57:29 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C2595E18006
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:57:28 +0900 (JST)
Date: Wed, 13 May 2009 12:55:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][BUGFIX] memcg: fix for deadlock between
 lock_page_cgroup and mapping tree_lock
Message-Id: <20090513125558.57be0db6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090513093250.7803d3d0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512140648.0974cb10.nishimura@mxp.nes.nec.co.jp>
	<20090512160901.8a6c5f64.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512170007.ad7f5c7b.nishimura@mxp.nes.nec.co.jp>
	<20090512171356.3d3a7554.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512195823.15c5cb80.d-nishimura@mtf.biglobe.ne.jp>
	<20090513085949.3c4b7b97.kamezawa.hiroyu@jp.fujitsu.com>
	<20090513092828.cbaa5a76.nishimura@mxp.nes.nec.co.jp>
	<20090513093250.7803d3d0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 13 May 2009 09:32:50 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 13 May 2009 09:28:28 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Wed, 13 May 2009 08:59:49 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Tue, 12 May 2009 19:58:23 +0900
> > > Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:
> > > 
> > > > On Tue, 12 May 2009 17:13:56 +0900
> > > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > 
> > > > > On Tue, 12 May 2009 17:00:07 +0900
> > > > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > > hmm, I see.
> > > > > > cache_charge is outside of tree_lock, so moving uncharge would make sense.
> > > > > > IMHO, we should make the period of spinlock as small as possible,
> > > > > > and charge/uncharge of pagecache/swapcache is protected by page lock, not tree_lock.
> > > > > > 
> > > > > How about this ?
> > > > Looks good conceptually, but it cannot be built :)
> > > > 
> > > > It needs a fix like this.
> > > > Passed build test with enabling/disabling both CONFIG_MEM_RES_CTLR
> > > > and CONFIG_SWAP.
> > > > 
> > > ok, will update. can I add you Signed-off-by on the patch ?
> > > 
> > Sure.
> > 
> > 	Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > The patch(with my fix applied) seems to work fine, I need run it
> > for more long time though.
> > 
> Ok, I'll treat this as an independent issue, not as "4/4".
> 
Could you merge mine and yours and send it to Andrew ?
I think this is a fix for dead-lock and priority is very high.
I foumd my system broken and installing the whole system again, now.
So, I can't post patch today.


> Thanks,
> -Kame
> 
> 
> > > Thanks,
> > > -Kame
> > > > ===
> > > >  include/linux/swap.h |    5 +++++
> > > >  mm/memcontrol.c      |    4 +++-
> > > >  mm/swap_state.c      |    4 +---
> > > >  mm/vmscan.c          |    2 +-
> > > >  4 files changed, 10 insertions(+), 5 deletions(-)
> > > > 
> > > > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > > > index caf0767..6ea541d 100644
> > > > --- a/include/linux/swap.h
> > > > +++ b/include/linux/swap.h
> > > > @@ -431,6 +431,11 @@ static inline swp_entry_t get_swap_page(void)
> > > >  #define has_swap_token(x) 0
> > > >  #define disable_swap_token() do { } while(0)
> > > >  
> > > > +static inline void
> > > > +mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
> > > > +{
> > > > +}
> > > > +
> > > >  #endif /* CONFIG_SWAP */
> > > >  #endif /* __KERNEL__*/
> > > >  #endif /* _LINUX_SWAP_H */
> > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > index 0c9c1ad..89523cf 100644
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > > @@ -1488,8 +1488,9 @@ void mem_cgroup_uncharge_cache_page(struct page *page)
> > > >  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
> > > >  }
> > > >  
> > > > +#ifdef CONFIG_SWAP
> > > >  /*
> > > > - * called from __delete_from_swap_cache() and drop "page" account.
> > > > + * called after __delete_from_swap_cache() and drop "page" account.
> > > >   * memcg information is recorded to swap_cgroup of "ent"
> > > >   */
> > > >  void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
> > > > @@ -1506,6 +1507,7 @@ void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
> > > >  	if (memcg)
> > > >  		css_put(&memcg->css);
> > > >  }
> > > > +#endif
> > > >  
> > > >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > > >  /*
> > > > diff --git a/mm/swap_state.c b/mm/swap_state.c
> > > > index 87f10d4..7624c89 100644
> > > > --- a/mm/swap_state.c
> > > > +++ b/mm/swap_state.c
> > > > @@ -109,8 +109,6 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
> > > >   */
> > > >  void __delete_from_swap_cache(struct page *page)
> > > >  {
> > > > -	swp_entry_t ent = {.val = page_private(page)};
> > > > -
> > > >  	VM_BUG_ON(!PageLocked(page));
> > > >  	VM_BUG_ON(!PageSwapCache(page));
> > > >  	VM_BUG_ON(PageWriteback(page));
> > > > @@ -190,7 +188,7 @@ void delete_from_swap_cache(struct page *page)
> > > >  	__delete_from_swap_cache(page);
> > > >  	spin_unlock_irq(&swapper_space.tree_lock);
> > > >  
> > > > -	mem_cgroup_uncharge_swapcache(page, ent);
> > > > +	mem_cgroup_uncharge_swapcache(page, entry);
> > > >  	swap_free(entry);
> > > >  	page_cache_release(page);
> > > >  }
> > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > index 6c5988d..a7d7a06 100644
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -470,7 +470,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
> > > >  		swp_entry_t swap = { .val = page_private(page) };
> > > >  		__delete_from_swap_cache(page);
> > > >  		spin_unlock_irq(&mapping->tree_lock);
> > > > -		mem_cgroup_uncharge_swapcache(page);
> > > > +		mem_cgroup_uncharge_swapcache(page, swap);
> > > >  		swap_free(swap);
> > > >  	} else {
> > > >  		__remove_from_page_cache(page);
> > > > ===
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > > Please read the FAQ at  http://www.tux.org/lkml/
> > > > 
> > > 
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
