Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA4953Zm012407
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 4 Nov 2008 18:05:03 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F63645DD7F
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 18:05:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A96045DD7C
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 18:05:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EBB61DB8044
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 18:05:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C75711DB8040
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 18:05:02 +0900 (JST)
Date: Tue, 4 Nov 2008 18:04:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/5] memcg : handle swap cache
Message-Id: <20081104180429.4e47875e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081104174201.9e2dc44c.nishimura@mxp.nes.nec.co.jp>
References: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
	<20081031115411.25478878.kamezawa.hiroyu@jp.fujitsu.com>
	<20081104174201.9e2dc44c.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, hugh@veritas.com, taka@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Tue, 4 Nov 2008 17:42:01 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > +#ifdef CONFIG_SWAP
> > +int mem_cgroup_cache_charge_swapin(struct page *page,
> > +			struct mm_struct *mm, gfp_t mask)
> > +{
> > +	int ret = 0;
> > +
> > +	if (mem_cgroup_subsys.disabled)
> > +		return 0;
> > +	if (unlikely(!mm))
> > +		mm = &init_mm;
> > +
> > +	ret = mem_cgroup_charge_common(page, mm, mask,
> > +			MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
> > +	/*
> > +	 * The page may be dropped from SwapCache because we don't have
> > +	 * lock_page().This may cause charge-after-uncharge trouble.
> > +	 * Fix it up here. (the caller have refcnt to this page and
> > +	 * page itself is guaranteed not to be freed.)
> > +	 */
> > +	if (ret && !PageSwapCache(page))
> > +		mem_cgroup_uncharge_swapcache(page);
> > +
> Hmm.. after [5/5], mem_cgroup_cache_charge_swapin has 'locked' parameter,
> calls lock_page(if !locked), and checks PageSwapCache under page lock.
> 
> Why not doing it in this patch?
> 

My intention is to guard swap_cgroup by lock_page() against SwapCache.
In Mem+Swap controller. we get "memcg" from information in page->private.
I think we need lock_page(), there. 

But here, we don't refer page->private information. 
I think we don't need lock_page() because there is no inofrmation we depends on.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
