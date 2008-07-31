Date: Thu, 31 Jul 2008 10:15:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: memo: mem+swap controller
Message-Id: <20080731101533.c82357b7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
Cc: "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, mem+swap controller is suggested by Hugh Dickins and I think it's a great
idea. Its concept is having 2 limits. (please point out if I misunderstand.)

 - memory.limit_in_bytes       .... limit memory usage.
 - memory.total_limit_in_bytes .... limit memory+swap usage.

By this, we can avoid excessive use of swap under a cgroup without any bad effect
to global LRU. (in page selection algorithm...overhead will be added, of course)

Following is state transition and counter handling design memo.
This uses "3" counters to handle above conrrectly. If you have other logic,
please teach me. (and blame me if my diagram is broken.)

A point is how to handle swap-cache, I think.
(Maybe we need a _big_ change in memcg.)

==

state definition
  new alloc  .... an object is newly allocated
  no_swap    .... an object with page without swp_entry
  swap_cache .... an object with page with swp_entry
  disk_swap  .... an object without page with swp_entry
  freed      .... an object is freed (by munmap)

(*) an object is an enitity which is accoutned, page or swap.

 new alloc ->  no_swap  <=>  swap_cache  <=>  disk_swap
                 |             |                 |
  freed.   <-----------<-------------<-----------

use 3 counters, no_swap, swap_cache, disk_swap.

    on_memory = no_swap + swap_cache.
    total     = no_swap + swap_cache + disk_swap

on_memory is limited by memory.limit_in_bytes
total     is limtied by memory.total_limit_in_bytes.

                     no_swap  swap_cache  disk_swap  on_memory  total
new alloc->no_swap     +1         -           -         +1        +1
no_swap->swap_cache    -1        +1           -         -         -
swap_cache->no_swap    +1        -1           -         -         -
swap_cache->disk_swap  -         -1           +1        -1        -
disk_swap->swap_cache  -         +1           -1        +1        -
no_swap->freed         -1        -            -         -1        -1
swap_cache->freed      -         -1           -         -1        -1
disk_swap->freed       -         -            -1        -         -1


any comments are welcome.

Regards,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
