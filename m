Date: Fri, 1 Aug 2008 12:45:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memo: mem+swap controller
Message-Id: <20080801124524.7dc947e7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <489280FE.2090203@linux.vnet.ibm.com>
References: <20080731101533.c82357b7.kamezawa.hiroyu@jp.fujitsu.com>
	<489280FE.2090203@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 01 Aug 2008 08:50:30 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Hi, mem+swap controller is suggested by Hugh Dickins and I think it's a great
> > idea. Its concept is having 2 limits. (please point out if I misunderstand.)
> > 
> >  - memory.limit_in_bytes       .... limit memory usage.
> >  - memory.total_limit_in_bytes .... limit memory+swap usage.
> > 
> > By this, we can avoid excessive use of swap under a cgroup without any bad effect
> > to global LRU. (in page selection algorithm...overhead will be added, of course)
> > 
> > Following is state transition and counter handling design memo.
> > This uses "3" counters to handle above conrrectly. If you have other logic,
> > please teach me. (and blame me if my diagram is broken.)
> > 
> > A point is how to handle swap-cache, I think.
> > (Maybe we need a _big_ change in memcg.)
> > 
> 
> Could you please describe the big change? What do you have in mind?
> 
Replace res_counter with new counter to handle 
  - 2 or 3 counters and
  - 2 limits
at once.

> > ==
> > 
> > state definition
> >   new alloc  .... an object is newly allocated
> >   no_swap    .... an object with page without swp_entry
> >   swap_cache .... an object with page with swp_entry
> >   disk_swap  .... an object without page with swp_entry
> >   freed      .... an object is freed (by munmap)
> > 
> > (*) an object is an enitity which is accoutned, page or swap.
> > 
> >  new alloc ->  no_swap  <=>  swap_cache  <=>  disk_swap
> >                  |             |                 |
> >   freed.   <-----------<-------------<-----------
> > 
> > use 3 counters, no_swap, swap_cache, disk_swap.
> > 
> >     on_memory = no_swap + swap_cache.
> >     total     = no_swap + swap_cache + disk_swap
> > 
> > on_memory is limited by memory.limit_in_bytes
> > total     is limtied by memory.total_limit_in_bytes.
> > 
> >                      no_swap  swap_cache  disk_swap  on_memory  total
> > new alloc->no_swap     +1         -           -         +1        +1
> > no_swap->swap_cache    -1        +1           -         -         -
> > swap_cache->no_swap    +1        -1           -         -         -
> > swap_cache->disk_swap  -         -1           +1        -1        -
> > disk_swap->swap_cache  -         +1           -1        +1        -
> > no_swap->freed         -1        -            -         -1        -1
> > swap_cache->freed      -         -1           -         -1        -1
> > disk_swap->freed       -         -            -1        -         -1
> > 
> > 
> > any comments are welcome.
> 
> What is the expected behaviour when we exceed memory.total_limit_in_bytes?
Just call try_to_free_mem_cgroup_pages() as now.

> Can't the memrlimit controller do what you ask for?
> 
Never. 

Example 1). assume a HPC program which treats very-sparse big matrix
and designed to be a process just handles part of it.

Example 2) When an Admin tried to use vm.overcommit_memory, he asked
30+ applications on his server "Please let me know what amount of (mmap)
memory you'll use."
Finally, He couldn't get good answer because of tons of Java and applications.

"Really used pages/swaps" can be shown by accounting and he can limit it by
his experience. And only "really used" numbers can tell resource usage.

Anyway, one of purposes,  we archive by cgroup, is sever integlation.

To integrate servers, System Admin cannot know what amounts of mmap will
he use because proprietaty application software tends to say "very safe"
value and cannot handle -ENOMEM well which returns by mmap().
(*) size of mmap() can have vairable numbers by application's configration
and workload. 

"Real resource usage" is tend to be set by estimated value which system admin
measured. So, it's easy to use than address space size when we integlate several
servers at once.

But for other purpose, for limiting a user program which is created by himself.
memrlimit has enough meaning, I think. He can handle -ENOMEM.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
