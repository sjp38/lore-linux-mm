Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6547E6B0055
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 01:45:36 -0400 (EDT)
Received: from mt3.gw.fujitsu.co.jp ([10.75.179.173])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2H5jXOD015966
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Mar 2009 14:45:34 +0900
Received: from smail (mt3 [127.0.0.1])
	by outgoing.mt3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AF8545DD86
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 14:45:30 +0900 (JST)
Received: from st3.gw.fujitsu.co.jp (st3.gw.fujitsu.co.jp [10.75.179.163])
	by mt3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E12C1EF084
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 14:45:30 +0900 (JST)
Received: from st3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by st3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3953AE08006
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 14:45:30 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by st3.gw.fujitsu.co.jp (Postfix) with ESMTP id B9DE01DB804C
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 14:45:26 +0900 (JST)
Date: Tue, 17 Mar 2009 14:39:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memcg: handle swapcache leak
Message-Id: <20090317143903.a789cf57.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Mar 2009 13:57:02 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi.
> 
> There are (at least) 2 types(described later) of swapcache leak in current memcg.
> 
> I mean by "swapcache leak" a swapcache which:
>   a. the process that used the page has already exited(or
>      unmapped the page).
>   b. is not linked to memcg's LRU because the page is !PageCgroupUsed.
> 
> So, only the global page reclaim or swapoff can free these leaked swapcaches.
> This means memcg's memory pressure can use up all swap entries if
> the memory size of the system is greater than that of swap.
> 
> 1. race between exit and swap-in
>   Assume processA is exitting and processB is doing swap-in.
> 
>   If some pages of processA has been swapped out, it calls free_swap_and_cache().
>   And if at the same time, processB is calling read_swap_cache_async() about
>   a swap entry *that is used by processA*, a race like below can happen.
> 
>             processA                   |           processB
>   -------------------------------------+-------------------------------------
>     (free_swap_and_cache())            |  (read_swap_cache_async())
>                                        |    swap_duplicate()
>                                        |    __set_page_locked()
>                                        |    add_to_swap_cache()
>       swap_entry_free() == 0           |
                          == 1?
>       find_get_page() -> found         |
>       try_lock_page() -> fail & return |
>                                        |    lru_cache_add_anon()
>                                        |      doesn't link this page to memcg's
>                                        |      LRU, because of !PageCgroupUsed.
> 
>   This type of leak can be avoided by setting /proc/sys/vm/page-cluster to 0.
> 
>   And this type of leaked swapcaches have been charged as swap,
>   so swap entries of them have reference to the associated memcg
>   and the refcnt of the memcg has been incremented.
>   As a result this memcg cannot be free'ed until global page reclaim
>   frees this swapcache or swapoff is executed.
> 
Okay. can happen.

>   Actually, I saw "struct mem_cgroup leak"(checked by "grep kmalloc-1024 /proc/slabinfo")
>   in my test, where I create a new directory, move all tasks to the new
>   directory, and remove the old directory under memcg's memory pressure.
>   And, this "struct mem_cgroup leak" didn't happen with setting
>   /proc/sys/vm/page-cluster to 0.
> 

Hmm, but IHMO, this is not "leak". "leak" means the object will not be freed forever.
This is a "delay".

And I tend to allow this. (stale SwapCache will be on LRU until global LRU found it,
but it's not called leak.)



> 2. race between exit and swap-out
>   If page_remove_rmap() is called by the owner process about an anonymous
>   page(not on swapchache, so uncharged here) before shrink_page_list() adds
>   the page to swapcache, this page becomes a swapcache with !PageCgroupUsed.
> 
>   And if this swapcache is not free'ed by shrink_page_list(), it goes back
>   to global LRU, but doesn't go back to memcg's LRU because the page is
>   !PageCgroupUsed.
> 
>   This type of leak can be avoided by modifying shrink_page_list() like:
> 
> ===
> @@ -775,6 +776,21 @@ activate_locked:
>  		SetPageActive(page);
>  		pgactivate++;
>  keep_locked:
> +		if (!scanning_global_lru(sc) && PageSwapCache(page)) {
> +			struct page_cgroup *pc;
> +
> +			pc = lookup_page_cgroup(page);
> +			/*
> +			 * Used bit of swapcache is solid under page lock.
> +			 */
> +			if (unlikely(!PageCgroupUsed(pc)))
> +				/*
> +				 * This can happen if the page is unmapped by
> +				 * the owner process before it is added to
> +				 * swapcache.
> +				 */
> +				try_to_free_swap(page);
> +		}
>  		unlock_page(page);
>  keep:
>  		list_add(&page->lru, &ret_pages);
> ===
> 
> 
> I've confirmed that no leak happens with this patch for shrink_page_list() applied
> and setting /proc/sys/vm/page-cluster to 0 in a simple swap in/out test.
> (I think I should check page migration and rmdir too.)
> 

But this is also "delay", isn't it ?

I think both "delay" comes from nature of current LRU desgin which allows small window
of this kinds. But there is no "leak". 

IMHO, I tend to allow this kinds of "delay" considering trade-off.

I have no troubles if rmdir() can success.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
