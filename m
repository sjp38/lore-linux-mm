Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CF19F6B008C
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 04:22:37 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3R8Mujb013006
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 27 Apr 2009 17:22:56 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 184B245DD75
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:22:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E0C7845DD78
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:22:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E77D11DB8013
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:22:55 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 91BC61DB8012
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:22:52 +0900 (JST)
Date: Mon, 27 Apr 2009 17:21:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] fix swap entries is not reclaimed in proper way
 for memg v3.
Message-Id: <20090427172119.d84aaa68.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090427081206.GI4454@balbir.in.ibm.com>
References: <20090421162121.1a1d15fe.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422143833.2e11e10b.nishimura@mxp.nes.nec.co.jp>
	<20090424133306.0d9fb2ce.kamezawa.hiroyu@jp.fujitsu.com>
	<20090424152103.a5ee8d13.nishimura@mxp.nes.nec.co.jp>
	<20090424162840.2ad06d8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090427081206.GI4454@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Apr 2009 13:42:06 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-24 16:28:40]:
> 
> > This is new one. (using new logic.) Maybe enough light-weight and caches all cases.
> 
> You sure mean catches above :)
> 
> 
> > 
> > Thanks,
> > -Kame
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Because free_swap_and_cache() function is called under spinlocks,
> > it can't sleep and use trylock_page() instead of lock_page().
> > By this, swp_entry which is not used after zap_xx can exists as
> > SwapCache, which will be never used.
> > This kind of SwapCache is reclaimed by global LRU when it's found
> > at LRU rotation.
> > 
> > When memory cgroup is used,  the global LRU will not be kicked and
> > stale Swap Caches will not be reclaimed. This is problematic because
> > memcg's swap entry accounting is leaked and memcg can't know it.
> > To catch this stale SwapCache, we have to chase it and check the
> > swap is alive or not again.
> > 
> > This patch adds a function to chase stale swap cache and reclaim it
> > in modelate way. When zap_xxx fails to remove swap ent, it will be
> > recoreded into buffer and memcg's "work" will reclaim it later.
> > No sleep, no memory allocation under free_swap_and_cache().
> > 
> > This patch also adds stale-swap-cache-congestion logic and try to avoid having
> > too much stale swap caches at the same time.
> > 
> > Implementation is naive but maybe the cost meets trade-off.
> > 
> > How to test:
> >   1. set limit of memory to very small (1-2M?). 
> >   2. run some amount of program and run page reclaim/swap-in.
> >   3. kill programs by SIGKILL etc....then, Stale Swap Cache will
> >      be increased. After this patch, stale swap caches are reclaimed
> >      and mem+swap controller will not go to OOM.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Quick comment on the design
> 
> 1. I like the marking of swap cache entries as stale

I like to. But there is no space to record it as stale. And "race" makes
that difficult even if we have enough space. If you read the whole thread,
you know there are many patterns of race.

> 2. Can't we reclaim stale entries during memcg LRU reclaim? Why write
> a GC for it?
> 
Because they are not on memcg LRU. we can't reclaim it by memcg LRU.
(See the first mail from Nishimura of this thread. It explains well.)

One easy case is here.

  - CPU0 call zap_pte()->free_swap_and_cache()
  - CPU1 tries to swap-in it.
  In this case, free_swap_and_cache() doesn't free swp_entry and swp_entry
  is read into the memory. But it will never be added memcg's LRU until
  it's mapped.
  (What we have to consider here is swapin-readahead. It can swap-in memory
   even if it's not accessed. Then, this race window is larger than expected.)

We can't use memcg's LRU then...what we can do is.

 - scanning global LRU all
 or
 - use some trick to reclaim them in lazy way.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
