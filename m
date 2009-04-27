Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D0D3A6B00AB
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 07:35:05 -0400 (EDT)
Date: Mon, 27 Apr 2009 20:35:35 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH] fix leak of swap accounting as stale swap cache under
 memcg
Message-Id: <20090427203535.4e3f970b.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20090427101323.GK4454@balbir.in.ibm.com>
References: <20090427181259.6efec90b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090427101323.GK4454@balbir.in.ibm.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Apr 2009 15:43:23 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-27 18:12:59]:
> 
> > Works very well under my test as following.
> >   prepare a program which does malloc, touch pages repeatedly.
> > 
> >   # echo 2M > /cgroup/A/memory.limit_in_bytes  # set limit to 2M.
> >   # echo 0 > /cgroup/A/tasks.                  # add shell to the group. 
> > 
> >   while true; do
> >     malloc_and_touch 1M &                       # run malloc and touch program.
> >     malloc_and_touch 1M &
> >     malloc_and_touch 1M &
> >     sleep 3
> >     pkill malloc_and_touch                      # kill them
> >   done
> > 
> > Then, you can see memory.memsw.usage_in_bytes increase gradually and exceeds 3M bytes.
> > This means account for swp_entry is not reclaimed at kill -> exit-> zap_pte()
> > because of race with swap-ops and zap_pte() under memcg.
> > 
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Because free_swap_and_cache() function is called under spinlocks,
> > it can't sleep and use trylock_page() instead of lock_page().
> > By this, swp_entry which is not used after zap_xx can exists as
> > SwapCache, which will be never used.
> > This kind of SwapCache is reclaimed by global LRU when it's found
> > at LRU rotation. Typical case is following.
> >
> 
> The changelog is not clear, this is the typical case for?
>  
Okey, let me summarise the problem.

First of all, what I think is problematic is "!PageCgroupUsed
swap cache without the owner process".
Those swap caches cannot be reclaimed by memcg's reclaim
because they are not on memcg's LRU(!PageCgroupUsed pages are not
linked to memcg's LRU).
Moreover, the owner prcess has already gone, only global LRU scanning
can free those swap caches.

Those swap caches causes some problems like:
(1) pressure the memsw.usage(only when MEM_RES_CTLR_SWAP).
(2) make struct mem_cgroup unfreeable even after rmdir, because
    we call mem_cgroup_get() when a page is swaped out(only when MEM_RES_CTLR_SWAP).
(3) pressure the usage of swap entry.

Those swap caches can be created in paths like:

Type-1) race between exit and swap-in path
  Assume processA is exiting and pte has swap entry of swaped out page.
  And processB is trying to swap in the entry by readahead.
  This entry holds memsw.usage and refcnt to struct mem_cgroup.

Type-1.1)
            processA                   |           processB
  -------------------------------------+-------------------------------------
    (free_swap_and_cache())            |  (read_swap_cache_async())
                                       |    swap_duplicate()
                                       |    __set_page_locked()
                                       |    add_to_swap_cache()
      swap_entry_free() == 1           |       
      find_get_page() -> found         |       
      try_lock_page() -> fail & return |
                                       |    lru_cache_add_anon()
                                       |      doesn't link this page to memcg's 
                                       |      LRU, because of !PageCgroupUsed.

Type-1.2)
            processA                   |           processB
  -------------------------------------+-------------------------------------
    (free_swap_and_cache())            |  (read_swap_cache_async())
                                       |    swap_duplicate()
      swap_entry_free() == 1           |       
      find_get_page() -> not found     |
                         & return      |    __set_page_locked()
                                       |    add_to_swap_cache()
                                       |    lru_cache_add_anon()
                                       |      doesn't link this page to memcg's 
                                       |      LRU, because of !PageCgroupUsed.

Type-2) race between exit and swap-out path
  Assume processA is exiting and pte points to a page(!PageSwapCache).
  And processB is trying reclaim the page.

            processA                   |           processB
  -------------------------------------+-------------------------------------
    (page_remove_rmap())               |  (shrink_page_list())
       mem_cgroup_uncharge_page()      |
          ->uncharged because it's not |
            PageSwapCache yet.         |       
            So, both mem/memsw.usage   |
            are decremented.           |       
                                       |    add_to_swap() -> added to swap cache.

  If this page goes thorough without being freed for some reason, this page
  doesn't goes back to memcg's LRU because of !PageCgroupUsed.

Type-1 has problem (1)-(3), and type-2 has (3) only.

> >        (CPU0 zap_pte)      (CPU1 swapin-readahead)
> >      zap_pte()                swap_duplicate()
> >      swap_entry_free()
> >      -> nothing to do 
> >                               swap will be read in.
> > 
> > (This race window is wider than expected because of readahead)
> > 
> 
> This should happen when the page is undergoing IO and this page_lock
> is not available. BTW, do we need page_lock to uncharge the page from
> the memory resource controller?
> 
This lock is needed for delete_from_swap_cache().

If free_swap_and_cache can hold the lock in this path:

  delete_from_swap_cache()
    mem_cgroup_uncharge_swapcache()
      -> does nothing because of !PageCgroupUsed
    swap_free()
      mem_cgroup_uncharge_swap()
        -> memsw.usage--, mem_cgroup_put()

> > When memory cgroup is used, the global LRU will not be kicked and
> > stale Swap Caches will not be reclaimed. Newly read-in swap cache is
> > not accounted and not added to memcg's LRU until it's mapped.
> 
>       ^^^^^^^ I thought it was accounted for but not on LRU
> 
Newly allocated pages are accounted before added to LRU,
but that's not true in swap-in path.
We remove the page from LRU once and put it back again to
add it to the proper memcg's LRU at commit_charge_swapin().

> > So, memcg itself cant reclaim it but swp_entry is freed untila
>                                                    ^ not?
> > global LRU finds it.
> > 
> > This is problematic because memcg's swap entry accounting is leaked
> > memcg can't know it. To catch this stale SwapCache, we have to chase it
> > and check the swap is alive or not again.
> > 
> > For chasing all swap entry, we need amount of memory but we don't
> > have enough space and it seems overkill. But, because stale-swap-cache
> > can be short-lived if we free it in proper way, we can check them
> > and sweep them out in lazy way with (small) static size buffer.
> > 
> > This patch adds a function to chase stale swap cache and reclaim it.
> > When zap_xxx fails to remove swap ent, it will be recoreded into buffer
> > and memcg's sweep routine will reclaim it later.
> > No sleep, no memory allocation under free_swap_and_cache().
> > 
> > This patch also adds stale-swap-cache-congestion logic and try to avoid to
> > have too much stale swap caches at once.
> > 
> > Implementation is naive but maybe the cost meets trade-off.
> >
> 
> To be honest, I don't like the code complexity added, that is why I
> want to explore more before agreeing to add an entire GC. We could
> consider using pagevecs, but we might not need some of the members
> like cold. I know you and Daisuke have worked hard on this problem, if
> we can't really find a better way, I'll let this pass.
>  
I don't care the method as long as this problem can be solved.
But I think this is the most simple way among what have
been proposed so far :)


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
