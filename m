Date: Thu, 31 Jul 2008 15:25:33 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: memo: mem+swap controller
Message-Id: <20080731152533.dea7713a.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080731101533.c82357b7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080731101533.c82357b7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, Kamezawa-san.

On Thu, 31 Jul 2008 10:15:33 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Hi, mem+swap controller is suggested by Hugh Dickins and I think it's a great
> idea. Its concept is having 2 limits. (please point out if I misunderstand.)
> 
>  - memory.limit_in_bytes       .... limit memory usage.
>  - memory.total_limit_in_bytes .... limit memory+swap usage.
> 
When I've considered more, I wonder how we can accomplish
"do not use swap in this group".

Setting "limit_in_bytes == total_limit_in_bytes" doesn't meet it, I think.
"limit_in_bytes = total_limit_in_bytes = 1G" cannot
avoid "memory.usage = 700M swap.usage = 300M" under memory pressure
outside of the group(and I think this behavior is the diffrence
of "memory controller + swap controller" and "mem+swap controller").

I think total_limit_in_bytes and swappiness(or some flag to indicate
"do not swap out"?) for each group would make more sense.

> By this, we can avoid excessive use of swap under a cgroup without any bad effect
> to global LRU. (in page selection algorithm...overhead will be added, of course)
> 
Sorry, I cannot understand this part.

> Following is state transition and counter handling design memo.
> This uses "3" counters to handle above conrrectly. If you have other logic,
> please teach me. (and blame me if my diagram is broken.)
> 
I don't think counting "disk swap" is good idea(global linux
dosen't count it).
Instead, I prefer counting "total swap"(that is swap entry).

> A point is how to handle swap-cache, I think.
> (Maybe we need a _big_ change in memcg.)
> 
I think swap cache should be counted as both memory and swap,
as global linux does.


Thanks,
Daisuke Nishimura.

> ==
> 
> state definition
>   new alloc  .... an object is newly allocated
>   no_swap    .... an object with page without swp_entry
>   swap_cache .... an object with page with swp_entry
>   disk_swap  .... an object without page with swp_entry
>   freed      .... an object is freed (by munmap)
> 
> (*) an object is an enitity which is accoutned, page or swap.
> 
>  new alloc ->  no_swap  <=>  swap_cache  <=>  disk_swap
>                  |             |                 |
>   freed.   <-----------<-------------<-----------
> 
> use 3 counters, no_swap, swap_cache, disk_swap.
> 
>     on_memory = no_swap + swap_cache.
>     total     = no_swap + swap_cache + disk_swap
> 
> on_memory is limited by memory.limit_in_bytes
> total     is limtied by memory.total_limit_in_bytes.
> 
>                      no_swap  swap_cache  disk_swap  on_memory  total
> new alloc->no_swap     +1         -           -         +1        +1
> no_swap->swap_cache    -1        +1           -         -         -
> swap_cache->no_swap    +1        -1           -         -         -
> swap_cache->disk_swap  -         -1           +1        -1        -
> disk_swap->swap_cache  -         +1           -1        +1        -
> no_swap->freed         -1        -            -         -1        -1
> swap_cache->freed      -         -1           -         -1        -1
> disk_swap->freed       -         -            -1        -         -1
> 
> 
> any comments are welcome.
> 
> Regards,
> -Kame
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
