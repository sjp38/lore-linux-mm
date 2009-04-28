Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0413A6B00D4
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 20:20:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3S0KYq9022004
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Apr 2009 09:20:34 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A86C845DE62
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 09:20:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 838EC45DE51
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 09:20:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 667291DB803B
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 09:20:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AD081DB8038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 09:20:34 +0900 (JST)
Date: Tue, 28 Apr 2009 09:19:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix leak of swap accounting as stale swap cache under
 memcg
Message-Id: <20090428091902.fc44efbc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090427210856.d5f4109e.d-nishimura@mtf.biglobe.ne.jp>
References: <20090427181259.6efec90b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090427210856.d5f4109e.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Apr 2009 21:08:56 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> > Index: mmotm-2.6.30-Apr24/mm/vmscan.c
> > ===================================================================
> > --- mmotm-2.6.30-Apr24.orig/mm/vmscan.c
> > +++ mmotm-2.6.30-Apr24/mm/vmscan.c
> > @@ -661,6 +661,9 @@ static unsigned long shrink_page_list(st
> >  		if (PageAnon(page) && !PageSwapCache(page)) {
> >  			if (!(sc->gfp_mask & __GFP_IO))
> >  				goto keep_locked;
> > +			/* avoid making more stale swap caches */
> > +			if (memcg_stale_swap_congestion())
> > +				goto keep_locked;
> >  			if (!add_to_swap(page))
> >  				goto activate_locked;
> >  			may_enter_fs = 1;
> > 
> Well, as I mentioned before(http://marc.info/?l=linux-kernel&m=124066623510867&w=2),
> this cannot avoid type-2(set !PageCgroupUsed by the owner process via
> page_remove_rmap()->mem_cgroup_uncharge_page() before being added to swap cache).
> If these swap caches go through shrink_page_list() without beeing freed
> for some reason, these swap caches doesn't go back to memcg's LRU.
> 
> Type-2 doesn't pressure memsw.usage, but you can see it by plotting
> "grep SwapCached /proc/meminfo".
> 
> And I don't think it's a good idea to add memcg_stale_swap_congestion() here.
> This means less possibility to reclaim pages.
> 
Hmm. maybe adding congestion_wait() ?

> Do you dislike the patch I attached in the above mail ?
> 
I doubt whether the patch covers all type-2 case.

> If not, please merge it(I tested your prvious version with some fixes and
> my patch, and it worked well). Or shall I send is as a separate patch
> to fix type-2 after your patch(yours looks good to me for type-1)?
> (to tell the truth, I want reuse memcg_free_unused_swapcache() in another patch)
> 
> 
I'll consider again and post v3.
But I'll go into a series of holidays, so, may not come back until May/6.

Thanks,
-Kame


> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
