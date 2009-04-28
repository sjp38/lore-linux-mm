Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5F35E6B00D5
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 20:42:31 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3S0h6L6031294
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Apr 2009 09:43:06 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BAC5E45DE53
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 09:43:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A90045DD72
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 09:43:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 77558E18001
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 09:43:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EF47F1DB8037
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 09:43:04 +0900 (JST)
Date: Tue, 28 Apr 2009 09:41:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix leak of swap accounting as stale swap cache under
 memcg
Message-Id: <20090428094132.6f4e0912.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090427101323.GK4454@balbir.in.ibm.com>
References: <20090427181259.6efec90b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090427101323.GK4454@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
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
> > When memory cgroup is used, the global LRU will not be kicked and
> > stale Swap Caches will not be reclaimed. Newly read-in swap cache is
> > not accounted and not added to memcg's LRU until it's mapped.
> 
>       ^^^^^^^ I thought it was accounted for but not on LRU
> 
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
I'll drop this patch and consider again. (If no way found, I'll do this again.)
It's ok if you or Nishimura think of something new.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
