Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA524412002145
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 5 Nov 2008 11:04:04 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DB6F645DD82
	for <linux-mm@kvack.org>; Wed,  5 Nov 2008 11:04:03 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 930DC45DD7B
	for <linux-mm@kvack.org>; Wed,  5 Nov 2008 11:04:03 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B3FF1DB8044
	for <linux-mm@kvack.org>; Wed,  5 Nov 2008 11:04:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 0ED8B1DB8037
	for <linux-mm@kvack.org>; Wed,  5 Nov 2008 11:04:03 +0900 (JST)
Date: Wed, 5 Nov 2008 11:03:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/5] memcg : handle swap cache
Message-Id: <20081105110329.a66d4679.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081105090749.a8756b03.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
	<20081031115411.25478878.kamezawa.hiroyu@jp.fujitsu.com>
	<20081104174201.9e2dc44c.nishimura@mxp.nes.nec.co.jp>
	<20081104180429.4e47875e.kamezawa.hiroyu@jp.fujitsu.com>
	<20081104192822.fc87868b.nishimura@mxp.nes.nec.co.jp>
	<20081105090749.a8756b03.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, hugh@veritas.com, taka@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Wed, 5 Nov 2008 09:07:49 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 4 Nov 2008 19:28:22 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Tue, 4 Nov 2008 18:04:29 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Tue, 4 Nov 2008 17:42:01 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > > +#ifdef CONFIG_SWAP
> > > > > +int mem_cgroup_cache_charge_swapin(struct page *page,
> > > > > +			struct mm_struct *mm, gfp_t mask)
> > > > > +{
> > > > > +	int ret = 0;
> > > > > +
> > > > > +	if (mem_cgroup_subsys.disabled)
> > > > > +		return 0;
> > > > > +	if (unlikely(!mm))
> > > > > +		mm = &init_mm;
> > > > > +
> > > > > +	ret = mem_cgroup_charge_common(page, mm, mask,
> > > > > +			MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
> > > > > +	/*
> > > > > +	 * The page may be dropped from SwapCache because we don't have
> > > > > +	 * lock_page().This may cause charge-after-uncharge trouble.
> > > > > +	 * Fix it up here. (the caller have refcnt to this page and
> > > > > +	 * page itself is guaranteed not to be freed.)
> > > > > +	 */
> > > > > +	if (ret && !PageSwapCache(page))
> > > > > +		mem_cgroup_uncharge_swapcache(page);
> > > > > +
> > > > Hmm.. after [5/5], mem_cgroup_cache_charge_swapin has 'locked' parameter,
> > > > calls lock_page(if !locked), and checks PageSwapCache under page lock.
> > > > 
> > > > Why not doing it in this patch?
> > > > 
> > > 
> > > My intention is to guard swap_cgroup by lock_page() against SwapCache.
> > > In Mem+Swap controller. we get "memcg" from information in page->private.
> > > I think we need lock_page(), there. 
> > > 
> > > But here, we don't refer page->private information. 
> > > I think we don't need lock_page() because there is no inofrmation we depends on.
> > > 
> > I just thought it would be simpler to check PageSwapCache after holding
> > page lock rather than to handle the case that the page might be removed from
> > swap cache.
> > 
> > And to be honest, I can't understand the "charge-after-uncharge trouble".
> > Could you explain more?
> > 

I'll add lock_page() here to make this simple.

Thanks,
-Kame


> Maybe typical case is following.
> __delete_from_swapcache can happen while the page is unlocked.
> ==
>                                                   some other thread.
>    page = shmem_swapin()
>    	swapin_readahead();
>    # page is SwapCache here.
>    # but this page is not locked.
>                                                   ___delete_from_swapcache(page)
>    # This is not SwapCache.                                 => uncharge swapcache.
>    mem_cgroup_charge_cache_swapin();
>    {
>        charge();  # charged this page but we don't know this is still swapcache.
>        if (!PageSwapCache(page)) {
> 		# Oh we should unroll this.
>        }
>    }
> =
> 
> Thanks,
> -Kame
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
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
