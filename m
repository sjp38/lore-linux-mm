Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m713JULE016416
	for <linux-mm@kvack.org>; Fri, 1 Aug 2008 13:19:30 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m713KX453317792
	for <linux-mm@kvack.org>; Fri, 1 Aug 2008 13:20:33 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m713KXuc008322
	for <linux-mm@kvack.org>; Fri, 1 Aug 2008 13:20:33 +1000
Message-ID: <489280FE.2090203@linux.vnet.ibm.com>
Date: Fri, 01 Aug 2008 08:50:30 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: memo: mem+swap controller
References: <20080731101533.c82357b7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080731101533.c82357b7.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Hi, mem+swap controller is suggested by Hugh Dickins and I think it's a great
> idea. Its concept is having 2 limits. (please point out if I misunderstand.)
> 
>  - memory.limit_in_bytes       .... limit memory usage.
>  - memory.total_limit_in_bytes .... limit memory+swap usage.
> 
> By this, we can avoid excessive use of swap under a cgroup without any bad effect
> to global LRU. (in page selection algorithm...overhead will be added, of course)
> 
> Following is state transition and counter handling design memo.
> This uses "3" counters to handle above conrrectly. If you have other logic,
> please teach me. (and blame me if my diagram is broken.)
> 
> A point is how to handle swap-cache, I think.
> (Maybe we need a _big_ change in memcg.)
> 

Could you please describe the big change? What do you have in mind?

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

What is the expected behaviour when we exceed memory.total_limit_in_bytes? Can't
the memrlimit controller do what you ask for?



-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
