Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DD6FA6B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 04:08:48 -0400 (EDT)
Date: Fri, 24 Apr 2009 17:07:21 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH] fix swap entries is not reclaimed in proper way
 for memg v3.
Message-Id: <20090424170721.d51d8a89.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090424162840.2ad06d8a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090421162121.1a1d15fe.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422143833.2e11e10b.nishimura@mxp.nes.nec.co.jp>
	<20090424133306.0d9fb2ce.kamezawa.hiroyu@jp.fujitsu.com>
	<20090424152103.a5ee8d13.nishimura@mxp.nes.nec.co.jp>
	<20090424162840.2ad06d8a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 24 Apr 2009 16:28:40 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Because free_swap_and_cache() function is called under spinlocks,
> it can't sleep and use trylock_page() instead of lock_page().
> By this, swp_entry which is not used after zap_xx can exists as
> SwapCache, which will be never used.
> This kind of SwapCache is reclaimed by global LRU when it's found
> at LRU rotation.
> 
> When memory cgroup is used,  the global LRU will not be kicked and
> stale Swap Caches will not be reclaimed. This is problematic because
> memcg's swap entry accounting is leaked and memcg can't know it.
> To catch this stale SwapCache, we have to chase it and check the
> swap is alive or not again.
> 
> This patch adds a function to chase stale swap cache and reclaim it
> in modelate way. When zap_xxx fails to remove swap ent, it will be
> recoreded into buffer and memcg's "work" will reclaim it later.
> No sleep, no memory allocation under free_swap_and_cache().
> 
> This patch also adds stale-swap-cache-congestion logic and try to avoid having
> too much stale swap caches at the same time.
> 
> Implementation is naive but maybe the cost meets trade-off.
> 
> How to test:
>   1. set limit of memory to very small (1-2M?). 
>   2. run some amount of program and run page reclaim/swap-in.
>   3. kill programs by SIGKILL etc....then, Stale Swap Cache will
>      be increased. After this patch, stale swap caches are reclaimed
>      and mem+swap controller will not go to OOM.
> 
Thank you for your patch!

It seems good at first glance.
I'll test it this weekend.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
