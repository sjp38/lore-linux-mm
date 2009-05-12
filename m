Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 97CDF6B004F
	for <linux-mm@kvack.org>; Tue, 12 May 2009 05:51:14 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4C9lnkx010461
	for <linux-mm@kvack.org>; Tue, 12 May 2009 05:47:49 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4C9q0Lb184936
	for <linux-mm@kvack.org>; Tue, 12 May 2009 05:52:01 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4C9o3VL004456
	for <linux-mm@kvack.org>; Tue, 12 May 2009 05:50:03 -0400
Date: Tue, 12 May 2009 15:21:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/3] fix stale swap cache account leak  in memcg v7
Message-ID: <20090512095158.GB6351@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-12 10:44:01]:

> I hope this version gets acks..
> ==
> As Nishimura reported, there is a race at handling swap cache.
> 
> Typical cases are following (from Nishimura's mail)
> 
> 
> == Type-1 ==
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
>       find_get_page() -> found         |
>       try_lock_page() -> fail & return |
>                                        |    lru_cache_add_anon()
>                                        |      doesn't link this page to memcg's
>                                        |      LRU, because of !PageCgroupUsed.
> 
>   This type of leak can be avoided by setting /proc/sys/vm/page-cluster to 0.
> 
> 
> == Type-2 ==
>     Assume processA is exiting and pte points to a page(!PageSwapCache).
>     And processB is trying reclaim the page.
> 
>               processA                   |           processB
>     -------------------------------------+-------------------------------------
>       (page_remove_rmap())               |  (shrink_page_list())
>          mem_cgroup_uncharge_page()      |
>             ->uncharged because it's not |
>               PageSwapCache yet.         |
>               So, both mem/memsw.usage   |
>               are decremented.           |
>                                          |    add_to_swap() -> added to swap cache.
> 
>     If this page goes thorough without being freed for some reason, this page
>     doesn't goes back to memcg's LRU because of !PageCgroupUsed.
> 
> 
> Considering Type-1, it's better to avoid swapin-readahead when memcg is used.
> swapin-readahead just read swp_entries which are near to requested entry. So,
> pages not to be used can be on memory (on global LRU). When memcg is used,
> this is not good behavior anyway.
> 
> Considering Type-2, the page should be freed from SwapCache right after WriteBack.
> Free swapped out pages as soon as possible is a good nature to memcg, anyway.
> 
> The patch set includes followng
>  [1/3] add mem_cgroup_is_activated() function. which tell us memcg is _really_ used.
>  [2/3] fix swap cache handling race by avoidng readahead.
>  [3/3] fix swap cache handling race by check swapcount again.
> 
> Result is good under my test.

What was the result (performance data impact) of disabling swap
readahead? Otherwise, this looks the most reasonable set of patches
for this problem.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
