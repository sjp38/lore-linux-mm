Date: Tue, 2 May 2000 18:20:41 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
In-Reply-To: <Pine.LNX.4.21.0005021238430.10610-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0005021818070.1919-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Roger Larsson <roger.larsson@norran.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 May 2000, Rik van Riel wrote:

>That's a very bad idea.

However the lru_cache have definitely to be per-node and not global as now
in 2.3.99-pre6 and pre7-1 or you won't be able to do the smart things I
was mentining some day ago in linux-mm with NUMA.

My current tree looks like this:

#define LRU_SWAP_CACHE		0
#define LRU_NORMAL_CACHE	1
#define NR_LRU_CACHE		2
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
