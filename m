Date: Thu, 21 Sep 2000 07:21:59 +0200 (CEST)
From: Mike Galbraith <mikeg@weiden.de>
Subject: Re: 2.4.0-test9-pre4: __alloc_pages(...) try_again:
In-Reply-To: <39C91CC8.F8D27899@norran.net>
Message-ID: <Pine.Linu.4.10.10009210655320.761-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@conectiva.com.br>, "Juan J. Quintela" <quintela@fi.udc.es>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Sep 2000, Roger Larsson wrote:

> Hi,
> 
> 
> Trying to find out why test9-pre4 freezes with mmap002
> I added a counter for try_again loops.
> 
> ... __alloc_pages(...)
> 
>         int direct_reclaim = 0;
>         unsigned int gfp_mask = zonelist->gfp_mask;
>         struct page * page = NULL;
> +       int try_again_loops = 0;
> 
> - - -
> 
> +         printk("VM: sync kswapd (direct_reclaim: %d) try_again #
> %d\n",
> +                direct_reclaim, ++try_again_loops);
>                         wakeup_kswapd(1);
>                         goto try_again;
> 
> 
> Result was surprising:
>   direct_reclaim was 1.
>   try_again_loops did never stop increasing (note: it is not static,
>   and should restart from zero after each success)
> 
> Why does this happen?
> a) kswapd did not succeed in freeing a suitable page?
> b) __alloc_pages did not succeed in grabbing the page?

Hi Roger,

A trace of locked up box shows endless repetitions of kswapd aparantly
failing to free anything.  What I don't see in the trace snippet below
is reclaim_page().  I wonder if this test in __alloc_pages_limit()
should include an || direct_reclaim.

		if (z->free_pages + z->inactive_clean_pages > water_mark) {
			struct page *page = NULL;
			/* If possible, reclaim a page directly. */
			if (direct_reclaim && z->free_pages < z->pages_min + 8)
				page = reclaim_page(z);
			/* If that fails, fall back to rmqueue. */
			if (!page)
				page = rmqueue(z, order);
			if (page)
				return page;
		}

dmesg log after breakout: 
SysRq: Suspending trace
SysRq: Show Memory
Mem-info:
Free pages:        1404kB (     0kB HighMem)
( Active: 274, inactive_dirty: 49, inactive_clean: 0, free: 351 (255 510 765) )
0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB = 512kB)
1*4kB 1*8kB 1*16kB 1*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB = 892kB)
= 0kB)
Swap cache: add 470291, delete 470291, find 212689/658406
Free swap:       199024kB
32752 pages of RAM
0 pages of HIGHMEM
4321 reserved pages
296 pages shared
0 pages swap cached
0 pages in page table cache
Buffer memory:      120kB
SysRq: Terminate All Tasks

trace snippet:
........
c0134aa7  try_to_free_buffers +<13/130> (0.18) pid(3)
c0134a47  sync_page_buffers +<13/60> (0.27) pid(3)
c0117fb3  __wake_up +<13/144> (0.25) pid(3)
c012dea9  __free_pages +<d/28> (0.26) pid(3)
c0134aa7  try_to_free_buffers +<13/130> (0.16) pid(3)
c0134a47  sync_page_buffers +<13/60> (0.33) pid(3)
c0117fb3  __wake_up +<13/144> (0.25) pid(3)
c012dea9  __free_pages +<d/28> (0.20) pid(3)
c012cce7  free_shortage +<13/ac> (0.13) pid(3)
c012df1e  nr_free_pages +<e/3c> (0.16) pid(3)
c012df5a  nr_inactive_clean_pages +<e/40> (0.16) pid(3)
c012df1e  nr_free_pages +<e/3c> (0.21) pid(3)
c014261d  shrink_dcache_memory +<d/38> (0.24) pid(3)
c0142280  prune_dcache +<10/120> (0.18) pid(3)
c012a8ea  kmem_cache_shrink +<e/58> (0.14) pid(3)
c012a832  is_chained_kmem_cache +<e/60> (0.96) pid(3)
c012a892  __kmem_cache_shrink +<e/58> (0.36) pid(3)
c0143849  shrink_icache_memory +<d/38> (0.24) pid(3)
c014375f  prune_icache +<13/f0> (0.14) pid(3)
c01432e4  sync_all_inodes +<10/120> (1.12) pid(3)
c01435ef  dispose_list +<f/68> (0.21) pid(3)
c012a8ea  kmem_cache_shrink +<e/58> (0.14) pid(3)
c012a832  is_chained_kmem_cache +<e/60> (0.29) pid(3)
c012a892  __kmem_cache_shrink +<e/58> (0.26) pid(3)
c012cde3  refill_inactive +<13/128> (0.12) pid(3)
c012cd8e  inactive_shortage +<e/50> (0.14) pid(3)
c012df1e  nr_free_pages +<e/3c> (0.18) pid(3)
c012df5a  nr_inactive_clean_pages +<e/40> (0.23) pid(3)
c012cce7  free_shortage +<13/ac> (0.13) pid(3)
c012df1e  nr_free_pages +<e/3c> (0.21) pid(3)
c012df5a  nr_inactive_clean_pages +<e/40> (0.16) pid(3)
c012df1e  nr_free_pages +<e/3c> (0.19) pid(3)
c012af3b  kmem_cache_reap +<13/1f0> (2.17) pid(3)
c0117bb3  schedule +<13/400> (1.20) pid(3->5)
c0109263  __switch_to +<13/cc> (0.69) pid(5)
c0134c9f  flush_dirty_buffers +<13/cc> (0.19) pid(5)
c012df1e  nr_free_pages +<e/3c> (0.16) pid(5)
c012df5a  nr_inactive_clean_pages +<e/40> (0.20) pid(5)
c0117fb3  __wake_up +<13/144> (0.31) pid(5)
c0117bb3  schedule +<13/400> (1.20) pid(5->141)
c0109263  __switch_to +<13/cc> (0.41) pid(141)
c0118d7d  remove_wait_queue +<d/24> (0.40) pid(141)
c012db24  __alloc_pages_limit +<10/b8> (0.35) pid(141)
c012db24  __alloc_pages_limit +<10/b8> (0.23) pid(141)
c012d0d2  wakeup_kswapd +<12/cc> (0.17) pid(141)
c012db24  __alloc_pages_limit +<10/b8> (0.25) pid(141)
c012d0d2  wakeup_kswapd +<12/cc> (0.16) pid(141)
c0118d13  add_wait_queue +<f/38> (0.22) pid(141)
c0117bb3  schedule +<13/400> (1.12) pid(141->144)
c0109263  __switch_to +<13/cc> (0.38) pid(144)
c0118d7d  remove_wait_queue +<d/24> (0.33) pid(144)
c012db24  __alloc_pages_limit +<10/b8> (0.22) pid(144)
c012db24  __alloc_pages_limit +<10/b8> (0.20) pid(144)
c012d0d2  wakeup_kswapd +<12/cc> (0.17) pid(144)
c012db24  __alloc_pages_limit +<10/b8> (0.24) pid(144)
c012d0d2  wakeup_kswapd +<12/cc> (0.16) pid(144)
c0118d13  add_wait_queue +<f/38> (0.22) pid(144)
c0117bb3  schedule +<13/400> (1.20) pid(144->1237)
c0109263  __switch_to +<13/cc> (0.36) pid(1237)
c0118d7d  remove_wait_queue +<d/24> (0.33) pid(1237)
c012db24  __alloc_pages_limit +<10/b8> (0.22) pid(1237)
c012db24  __alloc_pages_limit +<10/b8> (0.20) pid(1237)
c012d0d2  wakeup_kswapd +<12/cc> (0.17) pid(1237)
c012db24  __alloc_pages_limit +<10/b8> (0.24) pid(1237)
c012d0d2  wakeup_kswapd +<12/cc> (0.19) pid(1237)
c0118d13  add_wait_queue +<f/38> (0.22) pid(1237)
c0117bb3  schedule +<13/400> (1.08) pid(1237->194)
c0109263  __switch_to +<13/cc> (0.37) pid(194)
c0118d7d  remove_wait_queue +<d/24> (0.31) pid(194)
c012db24  __alloc_pages_limit +<10/b8> (0.22) pid(194)
c012db24  __alloc_pages_limit +<10/b8> (0.20) pid(194)
c012d0d2  wakeup_kswapd +<12/cc> (0.17) pid(194)
c012db24  __alloc_pages_limit +<10/b8> (0.24) pid(194)
c012d0d2  wakeup_kswapd +<12/cc> (0.16) pid(194)
c0118d13  add_wait_queue +<f/38> (0.22) pid(194)
c0117bb3  schedule +<13/400> (0.99) pid(194->99)
c0109263  __switch_to +<13/cc> (0.38) pid(99)
c0118d7d  remove_wait_queue +<d/24> (0.31) pid(99)
c012db24  __alloc_pages_limit +<10/b8> (0.22) pid(99)
c012db24  __alloc_pages_limit +<10/b8> (0.20) pid(99)
c012d0d2  wakeup_kswapd +<12/cc> (0.22) pid(99)
c012db24  __alloc_pages_limit +<10/b8> (0.24) pid(99)
c012d0d2  wakeup_kswapd +<12/cc> (0.16) pid(99)
c0118d13  add_wait_queue +<f/38> (0.22) pid(99)
c0117bb3  schedule +<13/400> (0.89) pid(99->218)
c0109263  __switch_to +<13/cc> (0.38) pid(218)
c0118d7d  remove_wait_queue +<d/24> (0.31) pid(218)
c012db24  __alloc_pages_limit +<10/b8> (0.22) pid(218)
c012db24  __alloc_pages_limit +<10/b8> (0.20) pid(218)
c012d0d2  wakeup_kswapd +<12/cc> (0.17) pid(218)
c012db24  __alloc_pages_limit +<10/b8> (0.24) pid(218)
c012d0d2  wakeup_kswapd +<12/cc> (0.18) pid(218)
c0118d13  add_wait_queue +<f/38> (0.22) pid(218)
c0117bb3  schedule +<13/400> (0.90) pid(218->1238)
c0109263  __switch_to +<13/cc> (0.48) pid(1238)
c0118d7d  remove_wait_queue +<d/24> (0.31) pid(1238)
c012db24  __alloc_pages_limit +<10/b8> (0.22) pid(1238)
c012db24  __alloc_pages_limit +<10/b8> (0.20) pid(1238)
c012d0d2  wakeup_kswapd +<12/cc> (0.17) pid(1238)
c012db24  __alloc_pages_limit +<10/b8> (0.24) pid(1238)
c012d0d2  wakeup_kswapd +<12/cc> (0.16) pid(1238)
c0118d13  add_wait_queue +<f/38> (0.22) pid(1238)
c0117bb3  schedule +<13/400> (0.53) pid(1238->3)
c0109263  __switch_to +<13/cc> (0.35) pid(3)
c012cbf3  refill_inactive_scan +<13/f4> (0.18) pid(3)
c012b30d  age_page_down_nolock +<d/28> (0.16) pid(3)
c012b39b  deactivate_page_nolock +<f/254> (0.40) pid(3)
c012cbf3  refill_inactive_scan +<13/f4> (0.16) pid(3)
c012b30d  age_page_down_nolock +<d/28> (0.16) pid(3)
c012b39b  deactivate_page_nolock +<f/254> (0.32) pid(3)
..........

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
