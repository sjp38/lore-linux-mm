Date: Thu, 31 Jul 2008 22:03:23 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: memo: mem+swap controller
Message-Id: <20080731220323.61e44dec.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080731155127.064aaf11.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080731101533.c82357b7.kamezawa.hiroyu@jp.fujitsu.com>
	<20080731152533.dea7713a.nishimura@mxp.nes.nec.co.jp>
	<20080731155127.064aaf11.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > > By this, we can avoid excessive use of swap under a cgroup without any bad effect
> > > to global LRU. (in page selection algorithm...overhead will be added, of course)
> > > 
> > Sorry, I cannot understand this part.
> > 
> From global LRU's view, anonymous page can be swapped out everytime.
> Because it never hits limit.
> ==
>                       no_swap  swap_cache  disk_swap  on_memory  total
> no_swap->swap_cache    -1        +1           -         -         -
> ==
> no changes in total.
> 
I see. Thanks.

> > > Following is state transition and counter handling design memo.
> > > This uses "3" counters to handle above conrrectly. If you have other logic,
> > > please teach me. (and blame me if my diagram is broken.)
> > > 
> > I don't think counting "disk swap" is good idea(global linux
> > dosen't count it).
> > Instead, I prefer counting "total swap"(that is swap entry).
> > 
> Maybe my illustration is bad. 
> 
> total_swap = swap_cache + disk_swap. Yes, I count swp_entry.
> But just divides it to on-memory or not.
> 
> This is just a state transition problem. When we counting only total_swap,
> we cannot avoid double counting of a swap_cache as memory and as swap.
> 
I agree.
My intention was not counting only total_swap, but counting both
total_swap and swap_cache.

> > > A point is how to handle swap-cache, I think.
> > > (Maybe we need a _big_ change in memcg.)
> > > 
> > I think swap cache should be counted as both memory and swap,
> > as global linux does.
> 
> No. If we allow double counting, we'll see OOM-Killer very soon. 
> 
on_memory = no_swap + swap_cache (your difinition)
swap = swap_cache + disk_swap
total = no_swap + swap_cache + disk_swap (your difinition)

total is NOT "on_memory + swap"(swap_cache is not doble counted).

so, in the sense of limitting, this is the same as yours.

> If what you say is
> ==
>                       no_swap  swap   on_memory  total
> no_swap->swap_cache             +1       -         +1
> ==
> What happens when global lru's swap_out hits limit ?
> 
> If what you say is
> ==
>                       no_swap  swap   on_memory  total
> no_swap->swap_cache      -1      +1       -        -
> ==
> What happens when SwapCache is mapped ? 
> 
The latter, and I think there would be no defference
about no_swap/swap_cache/disk_swap counters even when the swap cache is mapped.

(current memory controller charges swap caches only when it is mapped,
but I'm not talking about it.)


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
