Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 797D86B0264
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 03:05:47 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id q2so124461198pap.1
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 00:05:47 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id gc6si8074463pab.18.2016.07.21.00.05.45
        for <linux-mm@kvack.org>;
        Thu, 21 Jul 2016 00:05:46 -0700 (PDT)
Date: Thu, 21 Jul 2016 16:10:03 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/5] mm: add per-zone lru list stat
Message-ID: <20160721071002.GA27554@js1304-P5Q-DELUXE>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
 <1469028111-1622-3-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469028111-1622-3-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 20, 2016 at 04:21:48PM +0100, Mel Gorman wrote:
> From: Minchan Kim <minchan@kernel.org>
> 
> While I did stress test with hackbench, I got OOM message frequently which
> didn't ever happen in zone-lru.
> 
> gfp_mask=0x26004c0(GFP_KERNEL|__GFP_REPEAT|__GFP_NOTRACK), order=0
> ..
> ..
>  [<c71a76e2>] __alloc_pages_nodemask+0xe52/0xe60
>  [<c71f31dc>] ? new_slab+0x39c/0x3b0
>  [<c71f31dc>] new_slab+0x39c/0x3b0
>  [<c71f4eca>] ___slab_alloc.constprop.87+0x6da/0x840
>  [<c763e6fc>] ? __alloc_skb+0x3c/0x260
>  [<c777e127>] ? _raw_spin_unlock_irq+0x27/0x60
>  [<c70cebfc>] ? trace_hardirqs_on_caller+0xec/0x1b0
>  [<c70a1506>] ? finish_task_switch+0xa6/0x220
>  [<c7219ee0>] ? poll_select_copy_remaining+0x140/0x140
>  [<c7201645>] __slab_alloc.isra.81.constprop.86+0x40/0x6d
>  [<c763e6fc>] ? __alloc_skb+0x3c/0x260
>  [<c71f525c>] kmem_cache_alloc+0x22c/0x260
>  [<c763e6fc>] ? __alloc_skb+0x3c/0x260
>  [<c763e6fc>] __alloc_skb+0x3c/0x260
>  [<c763eece>] alloc_skb_with_frags+0x4e/0x1a0
>  [<c7638d6a>] sock_alloc_send_pskb+0x16a/0x1b0
>  [<c770b581>] ? wait_for_unix_gc+0x31/0x90
>  [<c71cfb1d>] ? alloc_set_pte+0x2ad/0x310
>  [<c77084dd>] unix_stream_sendmsg+0x28d/0x340
>  [<c7634dad>] sock_sendmsg+0x2d/0x40
>  [<c7634e2c>] sock_write_iter+0x6c/0xc0
>  [<c7204a90>] __vfs_write+0xc0/0x120
>  [<c72053ab>] vfs_write+0x9b/0x1a0
>  [<c71cc4a9>] ? __might_fault+0x49/0xa0
>  [<c72062c4>] SyS_write+0x44/0x90
>  [<c70036c6>] do_fast_syscall_32+0xa6/0x1e0
>  [<c777ea2c>] sysenter_past_esp+0x45/0x74
> 
> Mem-Info:
> active_anon:104698 inactive_anon:105791 isolated_anon:192
>  active_file:433 inactive_file:283 isolated_file:22
>  unevictable:0 dirty:0 writeback:296 unstable:0
>  slab_reclaimable:6389 slab_unreclaimable:78927
>  mapped:474 shmem:0 pagetables:101426 bounce:0
>  free:10518 free_pcp:334 free_cma:0
> Node 0 active_anon:418792kB inactive_anon:423164kB active_file:1732kB inactive_file:1132kB unevictable:0kB isolated(anon):768kB isolated(file):88kB mapped:1896kB dirty:0kB writeback:1184kB shmem:0kB writeback_tmp:0kB unstable:0kB pages_scanned:1478632 all_unreclaimable? yes
> DMA free:3304kB min:68kB low:84kB high:100kB present:15992kB managed:15916kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:4088kB kernel_stack:0kB pagetables:2480kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> lowmem_reserve[]: 0 809 1965 1965
> Normal free:3436kB min:3604kB low:4504kB high:5404kB present:897016kB managed:858460kB mlocked:0kB slab_reclaimable:25556kB slab_unreclaimable:311712kB kernel_stack:164608kB pagetables:30844kB bounce:0kB free_pcp:620kB local_pcp:104kB free_cma:0kB
> lowmem_reserve[]: 0 0 9247 9247
> HighMem free:33808kB min:512kB low:1796kB high:3080kB present:1183736kB managed:1183736kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:372252kB bounce:0kB free_pcp:428kB local_pcp:72kB free_cma:0kB
> lowmem_reserve[]: 0 0 0 0
> DMA: 2*4kB (UM) 2*8kB (UM) 0*16kB 1*32kB (U) 1*64kB (U) 2*128kB (UM) 1*256kB (U) 1*512kB (M) 0*1024kB 1*2048kB (U) 0*4096kB = 3192kB
> Normal: 33*4kB (MH) 79*8kB (ME) 11*16kB (M) 4*32kB (M) 2*64kB (ME) 2*128kB (EH) 7*256kB (EH) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3244kB
> HighMem: 2590*4kB (UM) 1568*8kB (UM) 491*16kB (UM) 60*32kB (UM) 6*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 33064kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
> 25121 total pagecache pages
> 24160 pages in swap cache
> Swap cache stats: add 86371, delete 62211, find 42865/60187
> Free swap  = 4015560kB
> Total swap = 4192252kB
> 524186 pages RAM
> 295934 pages HighMem/MovableOnly
> 9658 pages reserved
> 0 pages cma reserved
> 
> The order-0 allocation for normal zone failed while there are a lot of
> reclaimable memory(i.e., anonymous memory with free swap). I wanted to
> analyze the problem but it was hard because we removed per-zone lru stat
> so I couldn't know how many of anonymous memory there are in normal/dma zone.
> 
> When we investigate OOM problem, reclaimable memory count is crucial stat
> to find a problem. Without it, it's hard to parse the OOM message so I
> believe we should keep it.
> 
> With per-zone lru stat,
> 
> gfp_mask=0x26004c0(GFP_KERNEL|__GFP_REPEAT|__GFP_NOTRACK), order=0
> Mem-Info:
> active_anon:101103 inactive_anon:102219 isolated_anon:0
>  active_file:503 inactive_file:544 isolated_file:0
>  unevictable:0 dirty:0 writeback:34 unstable:0
>  slab_reclaimable:6298 slab_unreclaimable:74669
>  mapped:863 shmem:0 pagetables:100998 bounce:0
>  free:23573 free_pcp:1861 free_cma:0
> Node 0 active_anon:404412kB inactive_anon:409040kB active_file:2012kB inactive_file:2176kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3452kB dirty:0kB writeback:136kB shmem:0kB writeback_tmp:0kB unstable:0kB pages_scanned:1320845 all_unreclaimable? yes
> DMA free:3296kB min:68kB low:84kB high:100kB active_anon:5540kB inactive_anon:0kB active_file:0kB inactive_file:0kB present:15992kB managed:15916kB mlocked:0kB slab_reclaimable:248kB slab_unreclaimable:2628kB kernel_stack:792kB pagetables:2316kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> lowmem_reserve[]: 0 809 1965 1965
> Normal free:3600kB min:3604kB low:4504kB high:5404kB active_anon:86304kB inactive_anon:0kB active_file:160kB inactive_file:376kB present:897016kB managed:858524kB mlocked:0kB slab_reclaimable:24944kB slab_unreclaimable:296048kB kernel_stack:163832kB pagetables:35892kB bounce:0kB free_pcp:3076kB local_pcp:656kB free_cma:0kB
> lowmem_reserve[]: 0 0 9247 9247
> HighMem free:86156kB min:512kB low:1796kB high:3080kB active_anon:312852kB inactive_anon:410024kB active_file:1924kB inactive_file:2012kB present:1183736kB managed:1183736kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:365784kB bounce:0kB free_pcp:3868kB local_pcp:720kB free_cma:0kB
> lowmem_reserve[]: 0 0 0 0
> DMA: 8*4kB (UM) 8*8kB (UM) 4*16kB (M) 2*32kB (UM) 2*64kB (UM) 1*128kB (M) 3*256kB (UME) 2*512kB (UE) 1*1024kB (E) 0*2048kB 0*4096kB = 3296kB
> Normal: 240*4kB (UME) 160*8kB (UME) 23*16kB (ME) 3*32kB (UE) 3*64kB (UME) 2*128kB (ME) 1*256kB (U) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3408kB
> HighMem: 10942*4kB (UM) 3102*8kB (UM) 866*16kB (UM) 76*32kB (UM) 11*64kB (UM) 4*128kB (UM) 1*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 86344kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
> 54409 total pagecache pages
> 53215 pages in swap cache
> Swap cache stats: add 300982, delete 247765, find 157978/226539
> Free swap  = 3803244kB
> Total swap = 4192252kB
> 524186 pages RAM
> 295934 pages HighMem/MovableOnly
> 9642 pages reserved
> 0 pages cma reserved
> 
> With that, we can see normal zone has a 86M reclaimable memory so we can
> know something goes wrong(I will fix the problem in next patch) in reclaim.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  include/linux/mm_inline.h |  2 ++
>  include/linux/mmzone.h    |  6 ++++++
>  mm/page_alloc.c           | 10 ++++++++++
>  mm/vmstat.c               |  5 +++++
>  4 files changed, 23 insertions(+)
> 
> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> index bcc4ed07fa90..9cc130f5feb2 100644
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -45,6 +45,8 @@ static __always_inline void __update_lru_size(struct lruvec *lruvec,
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>  
>  	__mod_node_page_state(pgdat, NR_LRU_BASE + lru, nr_pages);
> +	__mod_zone_page_state(&pgdat->node_zones[zid],
> +				NR_ZONE_LRU_BASE + lru, nr_pages);
>  	acct_highmem_file_pages(zid, lru, nr_pages);
>  }

Hello, Mel and Minchan.

Above change is not sufficient to update zone stat properly.
We should also change update_lru_sizes() to use proper zid even if
!CONFIG_HIGHMEM. My test setup is 64 bit with movable zone and in this
case, updaing is done wrongly.

Thanks.

>  
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index e6aca07cedb7..72625b04e9ba 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -110,6 +110,12 @@ struct zone_padding {
>  enum zone_stat_item {
>  	/* First 128 byte cacheline (assuming 64 bit words) */
>  	NR_FREE_PAGES,
> +	NR_ZONE_LRU_BASE, /* Used only for compaction and reclaim retry */
> +	NR_ZONE_INACTIVE_ANON = NR_ZONE_LRU_BASE,
> +	NR_ZONE_ACTIVE_ANON,
> +	NR_ZONE_INACTIVE_FILE,
> +	NR_ZONE_ACTIVE_FILE,
> +	NR_ZONE_UNEVICTABLE,
>  	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
>  	NR_SLAB_RECLAIMABLE,
>  	NR_SLAB_UNRECLAIMABLE,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 830ad49a584a..b44c9a8d879a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4388,6 +4388,11 @@ void show_free_areas(unsigned int filter)
>  			" min:%lukB"
>  			" low:%lukB"
>  			" high:%lukB"
> +			" active_anon:%lukB"
> +			" inactive_anon:%lukB"
> +			" active_file:%lukB"
> +			" inactive_file:%lukB"
> +			" unevictable:%lukB"
>  			" present:%lukB"
>  			" managed:%lukB"
>  			" mlocked:%lukB"
> @@ -4405,6 +4410,11 @@ void show_free_areas(unsigned int filter)
>  			K(min_wmark_pages(zone)),
>  			K(low_wmark_pages(zone)),
>  			K(high_wmark_pages(zone)),
> +			K(zone_page_state(zone, NR_ZONE_ACTIVE_ANON)),
> +			K(zone_page_state(zone, NR_ZONE_INACTIVE_ANON)),
> +			K(zone_page_state(zone, NR_ZONE_ACTIVE_FILE)),
> +			K(zone_page_state(zone, NR_ZONE_INACTIVE_FILE)),
> +			K(zone_page_state(zone, NR_ZONE_UNEVICTABLE)),
>  			K(zone->present_pages),
>  			K(zone->managed_pages),
>  			K(zone_page_state(zone, NR_MLOCK)),
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 91ecca96dcae..f10aad81a9a3 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -921,6 +921,11 @@ int fragmentation_index(struct zone *zone, unsigned int order)
>  const char * const vmstat_text[] = {
>  	/* enum zone_stat_item countes */
>  	"nr_free_pages",
> +	"nr_inactive_anon",
> +	"nr_active_anon",
> +	"nr_inactive_file",
> +	"nr_active_file",
> +	"nr_unevictable",
>  	"nr_mlock",
>  	"nr_slab_reclaimable",
>  	"nr_slab_unreclaimable",
> -- 
> 2.6.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
