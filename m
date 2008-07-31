Date: Thu, 31 Jul 2008 15:51:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memo: mem+swap controller
Message-Id: <20080731155127.064aaf11.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080731152533.dea7713a.nishimura@mxp.nes.nec.co.jp>
References: <20080731101533.c82357b7.kamezawa.hiroyu@jp.fujitsu.com>
	<20080731152533.dea7713a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jul 2008 15:25:33 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi, Kamezawa-san.
> 
> On Thu, 31 Jul 2008 10:15:33 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Hi, mem+swap controller is suggested by Hugh Dickins and I think it's a great
> > idea. Its concept is having 2 limits. (please point out if I misunderstand.)
> > 
> >  - memory.limit_in_bytes       .... limit memory usage.
> >  - memory.total_limit_in_bytes .... limit memory+swap usage.
> > 
> When I've considered more, I wonder how we can accomplish
> "do not use swap in this group".
> 
you can't do that. This direction is to overcommit swap usage by
counting pages which is kicked out.


> Setting "limit_in_bytes == total_limit_in_bytes" doesn't meet it, I think.
> "limit_in_bytes = total_limit_in_bytes = 1G" cannot
> avoid "memory.usage = 700M swap.usage = 300M" under memory pressure
> outside of the group(and I think this behavior is the diffrence
> of "memory controller + swap controller" and "mem+swap controller").
> 
> I think total_limit_in_bytes and swappiness(or some flag to indicate
> "do not swap out"?) for each group would make more sense.
> 
"do not swap out" is bad direction. please use mlock().

(*) I have no objection to add a control file to move a page from swap
    to on-memory.

> > By this, we can avoid excessive use of swap under a cgroup without any bad effect
> > to global LRU. (in page selection algorithm...overhead will be added, of course)
> > 
> Sorry, I cannot understand this part.
> 
>From global LRU's view, anonymous page can be swapped out everytime.
Because it never hits limit.
==
                      no_swap  swap_cache  disk_swap  on_memory  total
no_swap->swap_cache    -1        +1           -         -         -
==
no changes in total.

> > Following is state transition and counter handling design memo.
> > This uses "3" counters to handle above conrrectly. If you have other logic,
> > please teach me. (and blame me if my diagram is broken.)
> > 
> I don't think counting "disk swap" is good idea(global linux
> dosen't count it).
> Instead, I prefer counting "total swap"(that is swap entry).
> 
Maybe my illustration is bad. 

total_swap = swap_cache + disk_swap. Yes, I count swp_entry.
But just divides it to on-memory or not.

This is just a state transition problem. When we counting only total_swap,
we cannot avoid double counting of a swap_cache as memory and as swap.


> > A point is how to handle swap-cache, I think.
> > (Maybe we need a _big_ change in memcg.)
> > 
> I think swap cache should be counted as both memory and swap,
> as global linux does.

No. If we allow double counting, we'll see OOM-Killer very soon. 

If what you say is
==
                      no_swap  swap   on_memory  total
no_swap->swap_cache             +1       -         +1
==
What happens when global lru's swap_out hits limit ?

If what you say is
==
                      no_swap  swap   on_memory  total
no_swap->swap_cache      -1      +1       -        -
==
What happens when SwapCache is mapped ? 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
