From: frankeh@us.ibm.com
Message-ID: <852568D3.005FC088.00@D51MTA07.pok.ibm.com>
Date: Tue, 2 May 2000 13:26:46 -0400
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: riel@nl.linux.org, Roger Larsson <roger.larsson@norran.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It makes sense to me to make the number of pools configurable and not tie
them directly to the number of nodes in a NUMA system.
In particular allow memory pools (i.e. instance of pg_dat_t) to be smaller
than a node size.

The smart things that I see has to happen is to allow a set of processes to
be attached to a set of memory pools and the OS basically enforcing
allocation in those constraints. I brought this up before and I think
Andrea proposed something similar. Allocation should take place in those
pools along the allocation levels based on GFP_MASK, so first allocate on
HIGH along all specified pools and if unsuccessful, then fallback on a
previous level.
With each pool we should associate a kswapd.

Making the size of the pools configurable allows to control the velocity at
which we can swap out. Standard Queuing theory: if we can't get the desired
througput, then increase the number of servers, here kswapd.

Comments...

-- Hubertus




Andrea Arcangeli <andrea@suse.de>@kvack.org on 05/02/2000 12:20:41 PM

Sent by:  owner-linux-mm@kvack.org


To:   riel@nl.linux.org
cc:   Roger Larsson <roger.larsson@norran.net>,
      linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Subject:  Re: kswapd @ 60-80% CPU during heavy HD i/o.



On Tue, 2 May 2000, Rik van Riel wrote:

>That's a very bad idea.

However the lru_cache have definitely to be per-node and not global as now
in 2.3.99-pre6 and pre7-1 or you won't be able to do the smart things I
was mentining some day ago in linux-mm with NUMA.

My current tree looks like this:

#define LRU_SWAP_CACHE        0
#define LRU_NORMAL_CACHE 1
#define NR_LRU_CACHE          2
typedef struct lru_cache_s {
     struct list_head heads[NR_LRU_CACHE];
     unsigned long nr_cache_pages; /* pages in the lrus */
     unsigned long nr_map_pages; /* pages temporarly out of the lru */
     /* keep lock in a separate cacheline to avoid ping pong in SMP */
     spinlock_t lock ____cacheline_aligned_in_smp;
} lru_cache_t;

struct bootmem_data;
typedef struct pglist_data {
     int nr_zones;
     zone_t node_zones[MAX_NR_ZONES];
     gfpmask_zone_t node_gfpmask_zone[NR_GFPINDEX];
     lru_cache_t lru_cache;
     struct page *node_mem_map;
     unsigned long *valid_addr_bitmap;
     struct bootmem_data *bdata;
     unsigned long node_start_paddr;
     unsigned long node_start_mapnr;
     unsigned long node_size;
     int node_id;
     struct pglist_data *node_next;
     spinlock_t freelist_lock ____cacheline_aligned_in_smp;
} pg_data_t;

Stay tuned...

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
