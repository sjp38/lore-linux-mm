Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BB89C6B005C
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 22:58:28 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L2xLtP030590
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Apr 2009 11:59:21 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 836F245DE51
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:59:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B58345DD79
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:59:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F9FEE18001
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:59:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D64171DB8038
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:59:20 +0900 (JST)
Date: Tue, 21 Apr 2009 11:57:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix unused/stale swap cache handling on memcg  v3
Message-Id: <20090421115749.bcb12fa7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090421113525.29332f3d.nishimura@mxp.nes.nec.co.jp>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
	<432ace3655a26d2d492a56303369a88a.squirrel@webmail-b.css.fujitsu.com>
	<20090320164520.f969907a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323104555.cb7cd059.nishimura@mxp.nes.nec.co.jp>
	<20090323114118.8b45105f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323140419.40235ce3.nishimura@mxp.nes.nec.co.jp>
	<20090323142242.f6659457.kamezawa.hiroyu@jp.fujitsu.com>
	<20090324173218.4de33b90.nishimura@mxp.nes.nec.co.jp>
	<20090325085713.6f0b7b74.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417153455.c6fe2ba6.nishimura@mxp.nes.nec.co.jp>
	<20090417155411.76901324.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417165036.bdca7163.nishimura@mxp.nes.nec.co.jp>
	<20090417165806.4ca40a08.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417171201.6c79bee5.nishimura@mxp.nes.nec.co.jp>
	<20090417171343.e848481f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090421113525.29332f3d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Apr 2009 11:35:25 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> @@ -785,6 +786,23 @@ activate_locked:
>                 SetPageActive(page);
>                 pgactivate++;
>  keep_locked:
> +               if (!scanning_global_lru(sc) && PageSwapCache(page)) {
> +                       struct page_cgroup *pc;
> +
> +                       pc = lookup_page_cgroup(page);
> +                       /*
> +                        * Used bit of swapcache is solid under page lock.
> +                        */
> +                       if (unlikely(!PageCgroupUsed(pc)))
> +                               /*
> +                                * This can happen if the page is free'ed by
> +                                * the owner process before it is added to
> +                                * swapcache.
> +                                * These swapcache cannot be managed by memcg
> +                                * well, so free it here.
> +                                */
> +                               try_to_free_swap(page);
> +               }
>                 unlock_page(page);
>  keep:
>                 list_add(&page->lru, &ret_pages);
> 
> This cannot prevent type-1 orphan SwapCache(caused by the race
> between exit() and swap-in readahead).
> Type-1 can pressure the memsw usage(trigger OOM if memsw.limit is set, as a result)
> and make struct mem_cgroup unfreeable even after rmdir(because it holds refcount
> to mem_cgroup).
Hmm.
   free_swap_cache()
	-> trylock_page() => failure case ?

add following codes.
==
 588                         page = find_get_page(&swapper_space, entry.val);
 589                         if (page && !trylock_page(page)) {
				     mem_cgroup_retry_free_swap_lazy(page);  <=====
 590                                 page_cache_release(page);
 591                                 page = NULL;
 592                         }
==
and  do some kind of lazy ops..I'll try some.

> 
> Do you have any ideas to solve orphan SwapCache problem by adding some hooks to shrink_zone() ?
> (scan some pages from global LRU and check whether it's orphan SwapCache or not by
> adding some code like above ?)
> 
> And, what do you think about adding above code to shrink_page_list() ?
> I think it might be unnecessary if we can solve the problem in another way, though.
> 

I think your hook itself is not very bad. (even if we remove this later..)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
