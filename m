Date: Tue, 4 Nov 2008 19:28:22 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 2/5] memcg : handle swap cache
Message-Id: <20081104192822.fc87868b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081104180429.4e47875e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
	<20081031115411.25478878.kamezawa.hiroyu@jp.fujitsu.com>
	<20081104174201.9e2dc44c.nishimura@mxp.nes.nec.co.jp>
	<20081104180429.4e47875e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, hugh@veritas.com, taka@valinux.co.jp, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Tue, 4 Nov 2008 18:04:29 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 4 Nov 2008 17:42:01 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > +#ifdef CONFIG_SWAP
> > > +int mem_cgroup_cache_charge_swapin(struct page *page,
> > > +			struct mm_struct *mm, gfp_t mask)
> > > +{
> > > +	int ret = 0;
> > > +
> > > +	if (mem_cgroup_subsys.disabled)
> > > +		return 0;
> > > +	if (unlikely(!mm))
> > > +		mm = &init_mm;
> > > +
> > > +	ret = mem_cgroup_charge_common(page, mm, mask,
> > > +			MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
> > > +	/*
> > > +	 * The page may be dropped from SwapCache because we don't have
> > > +	 * lock_page().This may cause charge-after-uncharge trouble.
> > > +	 * Fix it up here. (the caller have refcnt to this page and
> > > +	 * page itself is guaranteed not to be freed.)
> > > +	 */
> > > +	if (ret && !PageSwapCache(page))
> > > +		mem_cgroup_uncharge_swapcache(page);
> > > +
> > Hmm.. after [5/5], mem_cgroup_cache_charge_swapin has 'locked' parameter,
> > calls lock_page(if !locked), and checks PageSwapCache under page lock.
> > 
> > Why not doing it in this patch?
> > 
> 
> My intention is to guard swap_cgroup by lock_page() against SwapCache.
> In Mem+Swap controller. we get "memcg" from information in page->private.
> I think we need lock_page(), there. 
> 
> But here, we don't refer page->private information. 
> I think we don't need lock_page() because there is no inofrmation we depends on.
> 
I just thought it would be simpler to check PageSwapCache after holding
page lock rather than to handle the case that the page might be removed from
swap cache.

And to be honest, I can't understand the "charge-after-uncharge trouble".
Could you explain more?


Thanks,
Dasiuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
