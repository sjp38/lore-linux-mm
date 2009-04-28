Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 86F1C6B00EB
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 22:39:33 -0400 (EDT)
Message-id: <isapiwc.d5d1bc3c.6e29.49f66c08.26940.be@mail.jp.nec.com>
In-Reply-To: <20090428101924.88f67e27.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090427181259.6efec90b.kamezawa.hiroyu@jp.fujitsu.com>
 <20090427210856.d5f4109e.d-nishimura@mtf.biglobe.ne.jp>
 <20090428091902.fc44efbc.kamezawa.hiroyu@jp.fujitsu.com>
 <isapiwc.d5d1bc3c.6e29.49f6574a.db2ee.65@mail.jp.nec.com>
 <20090428101924.88f67e27.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 28 Apr 2009 11:38:00 +0900
From: nishimura@mxp.nes.nec.co.jp
Subject: Re: [PATCH] fix leak of swap accounting as stale swap cache under
 memcg
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

> On Tue, 28 Apr 2009 10:09:30 +0900
> nishimura@mxp.nes.nec.co.jp wrote:
> 
>> > On Mon, 27 Apr 2009 21:08:56 +0900
>> > Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:
>> > 
>> >> > Index: mmotm-2.6.30-Apr24/mm/vmscan.c
>> >> > ===================================================================
>> >> > --- mmotm-2.6.30-Apr24.orig/mm/vmscan.c
>> >> > +++ mmotm-2.6.30-Apr24/mm/vmscan.c
>> >> > @@ -661,6 +661,9 @@ static unsigned long shrink_page_list(st
>> >> >  		if (PageAnon(page) && !PageSwapCache(page)) {
>> >> >  			if (!(sc->gfp_mask & __GFP_IO))
>> >> >  				goto keep_locked;
>> >> > +			/* avoid making more stale swap caches */
>> >> > +			if (memcg_stale_swap_congestion())
>> >> > +				goto keep_locked;
>> >> >  			if (!add_to_swap(page))
>> >> >  				goto activate_locked;
>> >> >  			may_enter_fs = 1;
>> >> > 
>> >> Well, as I mentioned before(http://marc.info/?l=linux-kernel&m=124066623510867&w=2),
>> >> this cannot avoid type-2(set !PageCgroupUsed by the owner process via
>> >> page_remove_rmap()->mem_cgroup_uncharge_page() before being added to swap cache).
>> >> If these swap caches go through shrink_page_list() without beeing freed
>> >> for some reason, these swap caches doesn't go back to memcg's LRU.
>> >> 
>> >> Type-2 doesn't pressure memsw.usage, but you can see it by plotting
>> >> "grep SwapCached /proc/meminfo".
>> >> 
>> >> And I don't think it's a good idea to add memcg_stale_swap_congestion() here.
>> >> This means less possibility to reclaim pages.
>> >> 
>> > Hmm. maybe adding congestion_wait() ?
>> > 
>> I don't think no hook before add_to_swap() is needed.
>> 
>> >> Do you dislike the patch I attached in the above mail ?
>> >> 
>> > I doubt whether the patch covers all type-2 case.
>> > 
>> hmm, I didn't see any leak anymore when I tested the patch.
>> 
> 
> At first, your patch
> ==
>  		if (PageAnon(page) && !PageSwapCache(page)) {
>  			if (!(sc->gfp_mask & __GFP_IO))
>  				goto keep_locked;
> -			/* avoid making more stale swap caches */
> -			if (memcg_stale_swap_congestion())
> -				goto keep_locked;
>  			if (!add_to_swap(page))
>  				goto activate_locked;
> +			/*
> +			 * The owner process might have uncharged the page
> +			 * (by page_remove_rmap()) before it has been added
> +			 * to swap cache.
> +			 * Check it here to avoid making it stale.
> +			 */
> +			if (memcg_free_unused_swapcache(page))
> +				goto keep_locked;
>  			may_enter_fs = 1;
>  		}
> ==
> Should be
> ==
> 
> 	if (PageAnon(page) && !PageSwapCache(page)) {
> 		... // don't modify here
> 	}
> 	if (PageAnon(page) && PageSwapCache(page) && !page_mapped(page)) {
> 		if (try_to_free_page(page)) // or memcg_free_unused_swapcache()
> 			goto free_it;
> 	}
> ==
> I think.
> 
It may work too.

But if the page is on swap cache already at the point of page_remove_rmap()
-> mem_cgroup_uncharge_page, the page is not uncharged.
So, it can be freed in memcg's LRU scanning in the long run by
shrink_page_list()->pageout()->swap_writepage()->try_to_free_swap().

I added the hook there just because I wanted to clarify what the
problematic case is.

And I don't think "goto free_it" is good.
It calls free_hot_cold_page(), but some process (like swapoff) might
have got the swap cache already and be waiting for the lock of the page.

> And we need hook to free_swap_and_cache() for handling PageWriteback() case.
> 
Ah, You're right.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
