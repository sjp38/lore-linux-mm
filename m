Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BD6F36B00DA
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 21:20:43 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3S1L0cZ032483
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Apr 2009 10:21:01 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 938B645DE51
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 10:21:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 63F2745DD79
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 10:21:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2495A1DB8038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 10:21:00 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B5658E18001
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 10:20:56 +0900 (JST)
Date: Tue, 28 Apr 2009 10:19:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix leak of swap accounting as stale swap cache under
 memcg
Message-Id: <20090428101924.88f67e27.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <isapiwc.d5d1bc3c.6e29.49f6574a.db2ee.65@mail.jp.nec.com>
References: <20090427181259.6efec90b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090427210856.d5f4109e.d-nishimura@mtf.biglobe.ne.jp>
	<20090428091902.fc44efbc.kamezawa.hiroyu@jp.fujitsu.com>
	<isapiwc.d5d1bc3c.6e29.49f6574a.db2ee.65@mail.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Apr 2009 10:09:30 +0900
nishimura@mxp.nes.nec.co.jp wrote:

> > On Mon, 27 Apr 2009 21:08:56 +0900
> > Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:
> > 
> >> > Index: mmotm-2.6.30-Apr24/mm/vmscan.c
> >> > ===================================================================
> >> > --- mmotm-2.6.30-Apr24.orig/mm/vmscan.c
> >> > +++ mmotm-2.6.30-Apr24/mm/vmscan.c
> >> > @@ -661,6 +661,9 @@ static unsigned long shrink_page_list(st
> >> >  		if (PageAnon(page) && !PageSwapCache(page)) {
> >> >  			if (!(sc->gfp_mask & __GFP_IO))
> >> >  				goto keep_locked;
> >> > +			/* avoid making more stale swap caches */
> >> > +			if (memcg_stale_swap_congestion())
> >> > +				goto keep_locked;
> >> >  			if (!add_to_swap(page))
> >> >  				goto activate_locked;
> >> >  			may_enter_fs = 1;
> >> > 
> >> Well, as I mentioned before(http://marc.info/?l=linux-kernel&m=124066623510867&w=2),
> >> this cannot avoid type-2(set !PageCgroupUsed by the owner process via
> >> page_remove_rmap()->mem_cgroup_uncharge_page() before being added to swap cache).
> >> If these swap caches go through shrink_page_list() without beeing freed
> >> for some reason, these swap caches doesn't go back to memcg's LRU.
> >> 
> >> Type-2 doesn't pressure memsw.usage, but you can see it by plotting
> >> "grep SwapCached /proc/meminfo".
> >> 
> >> And I don't think it's a good idea to add memcg_stale_swap_congestion() here.
> >> This means less possibility to reclaim pages.
> >> 
> > Hmm. maybe adding congestion_wait() ?
> > 
> I don't think no hook before add_to_swap() is needed.
> 
> >> Do you dislike the patch I attached in the above mail ?
> >> 
> > I doubt whether the patch covers all type-2 case.
> > 
> hmm, I didn't see any leak anymore when I tested the patch.
> 

At first, your patch
==
 		if (PageAnon(page) && !PageSwapCache(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
-			/* avoid making more stale swap caches */
-			if (memcg_stale_swap_congestion())
-				goto keep_locked;
 			if (!add_to_swap(page))
 				goto activate_locked;
+			/*
+			 * The owner process might have uncharged the page
+			 * (by page_remove_rmap()) before it has been added
+			 * to swap cache.
+			 * Check it here to avoid making it stale.
+			 */
+			if (memcg_free_unused_swapcache(page))
+				goto keep_locked;
 			may_enter_fs = 1;
 		}
==
Should be
==

	if (PageAnon(page) && !PageSwapCache(page)) {
		... // don't modify here
	}
	if (PageAnon(page) && PageSwapCache(page) && !page_mapped(page)) {
		if (try_to_free_page(page)) // or memcg_free_unused_swapcache()
			goto free_it;
	}
==
I think.

And we need hook to free_swap_and_cache() for handling PageWriteback() case.


> But because of machine time limit, I could only test for about 3 hours.
> (I had seen some leak at that point before applying my patch)
> I'll test for longer time if possible.
> 
Sigh, my work time is also limited for these months ;(

> > I'll consider again and post v3.
> > But I'll go into a series of holidays, so, may not come back until May/6.
> > 
> It's the same for me :)
> 
Enjoy good holidays :)

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
