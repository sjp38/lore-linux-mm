Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CA7176B00AD
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 08:08:51 -0400 (EDT)
Date: Mon, 27 Apr 2009 21:08:56 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH] fix leak of swap accounting as stale swap cache under
 memcg
Message-Id: <20090427210856.d5f4109e.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20090427181259.6efec90b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090427181259.6efec90b.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Index: mmotm-2.6.30-Apr24/mm/vmscan.c
> ===================================================================
> --- mmotm-2.6.30-Apr24.orig/mm/vmscan.c
> +++ mmotm-2.6.30-Apr24/mm/vmscan.c
> @@ -661,6 +661,9 @@ static unsigned long shrink_page_list(st
>  		if (PageAnon(page) && !PageSwapCache(page)) {
>  			if (!(sc->gfp_mask & __GFP_IO))
>  				goto keep_locked;
> +			/* avoid making more stale swap caches */
> +			if (memcg_stale_swap_congestion())
> +				goto keep_locked;
>  			if (!add_to_swap(page))
>  				goto activate_locked;
>  			may_enter_fs = 1;
> 
Well, as I mentioned before(http://marc.info/?l=linux-kernel&m=124066623510867&w=2),
this cannot avoid type-2(set !PageCgroupUsed by the owner process via
page_remove_rmap()->mem_cgroup_uncharge_page() before being added to swap cache).
If these swap caches go through shrink_page_list() without beeing freed
for some reason, these swap caches doesn't go back to memcg's LRU.

Type-2 doesn't pressure memsw.usage, but you can see it by plotting
"grep SwapCached /proc/meminfo".

And I don't think it's a good idea to add memcg_stale_swap_congestion() here.
This means less possibility to reclaim pages.

Do you dislike the patch I attached in the above mail ?

If not, please merge it(I tested your prvious version with some fixes and
my patch, and it worked well). Or shall I send is as a separate patch
to fix type-2 after your patch(yours looks good to me for type-1)?
(to tell the truth, I want reuse memcg_free_unused_swapcache() in another patch)


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
