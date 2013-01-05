Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 90F816B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 20:07:17 -0500 (EST)
Date: Sat, 5 Jan 2013 01:07:15 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130105010715.GA12385@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130104160148.GB3885@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130104160148.GB3885@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Mel Gorman <mgorman@suse.de> wrote:
> On Wed, Jan 02, 2013 at 08:08:48PM +0000, Eric Wong wrote:
> > Instead, I disabled THP+compaction under v3.7.1 and I've been unable to
> > reproduce the issue without THP+compaction.
> > 
> 
> Implying that it's stuck in compaction somewhere. It could be the case
> that compaction alters timing enough to trigger another bug. You say it
> tests differently depending on whether TCP or unix sockets are used
> which might indicate multiple problems. However, lets try and see if
> compaction is the primary problem or not.

I've only managed to encounter this issue with TCP sockets.

No luck reproducing the issue with Unix sockets, not even with 90K
buffers as suggested by Eric Dumazet.  This seems unique to TCP.

Fwiw, I also tried going back to a 16K MTU on loopback a few days ago,
but was still able to reproduce the issue, so
commit 0cf833aefaa85bbfce3ff70485e5534e09254773 doesn't seem
to be a culprit, either.

> > As I mention in http://mid.gmane.org/20121229113434.GA13336@dcvr.yhbt.net
> > I run my below test (`toosleepy') with heavy network and disk activity
> > for a long time before hitting this.
> > 
> 
> Using a 3.7.1 or 3.8-rc2 kernel, can you reproduce the problem and then
> answer the following questions please?

OK, I'm on 3.8-rc2.

> 1. What are the contents of /proc/vmstat at the time it is stuck?

nr_free_pages 1998
nr_inactive_anon 3401
nr_active_anon 3349
nr_inactive_file 94361
nr_active_file 10929
nr_unevictable 0
nr_mlock 0
nr_anon_pages 6643
nr_mapped 2255
nr_file_pages 105400
nr_dirty 44
nr_writeback 0
nr_slab_reclaimable 0
nr_slab_unreclaimable 0
nr_page_table_pages 697
nr_kernel_stack 161
nr_unstable 0
nr_bounce 0
nr_vmscan_write 0
nr_vmscan_immediate_reclaim 0
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 114
nr_dirtied 1076168
nr_written 46330
nr_anon_transparent_hugepages 0
nr_free_cma 0
nr_dirty_threshold 22495
nr_dirty_background_threshold 11247
pgpgin 4398164
pgpgout 188556
pswpin 0
pswpout 0
pgalloc_dma 369887
pgalloc_dma32 28406230
pgalloc_normal 0
pgalloc_movable 0
pgfree 28779104
pgactivate 18160
pgdeactivate 17404
pgfault 34862559
pgmajfault 358
pgrefill_dma 14076
pgrefill_dma32 3328
pgrefill_normal 0
pgrefill_movable 0
pgsteal_kswapd_dma 12708
pgsteal_kswapd_dma32 917837
pgsteal_kswapd_normal 0
pgsteal_kswapd_movable 0
pgsteal_direct_dma 73
pgsteal_direct_dma32 4085
pgsteal_direct_normal 0
pgsteal_direct_movable 0
pgscan_kswapd_dma 12708
pgscan_kswapd_dma32 918789
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 73
pgscan_direct_dma32 4115
pgscan_direct_normal 0
pgscan_direct_movable 0
pgscan_direct_throttle 0
pginodesteal 0
slabs_scanned 257024
kswapd_inodesteal 69910
kswapd_low_wmark_hit_quickly 2165
kswapd_high_wmark_hit_quickly 275
kswapd_skip_congestion_wait 0
pageoutrun 13412
allocstall 73
pgrotated 3
pgmigrate_success 448
pgmigrate_fail 0
compact_migrate_scanned 14860
compact_free_scanned 219867
compact_isolated 1652
compact_stall 33
compact_fail 10
compact_success 23
unevictable_pgs_culled 1058
unevictable_pgs_scanned 0
unevictable_pgs_rescued 1671
unevictable_pgs_mlocked 1671
unevictable_pgs_munlocked 1671
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
thp_fault_alloc 0
thp_fault_fallback 0
thp_collapse_alloc 0
thp_collapse_alloc_failed 0
thp_split 0
thp_zero_page_alloc 0
thp_zero_page_alloc_failed 0

> 2. What are the contents of /proc/PID/stack for every toosleepy
>    process when they are stuck?

Oops, I needed a rebuild with CONFIG_STACKTRACE=y (it took some effort
to get the right combination of options).

I probably enabled a few more debugging options than I needed and it
seems to have taken longer to reproduce the issue.  Unfortunately I was
distracted when toosleepy got stuck and missed the change to inspect
before hitting ETIMEDOUT :x

Attempting to reproduce the issue while I'm looking.

> 3. Can you do a sysrq+m and post the resulting dmesg?

SysRq : Show Memory
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 144
CPU    1: hi:  186, btch:  31 usd: 160
active_anon:3358 inactive_anon:3379 isolated_anon:0
 active_file:10615 inactive_file:92319 isolated_file:0
 unevictable:0 dirty:3 writeback:0 unstable:0
 free:2240 slab_reclaimable:0 slab_unreclaimable:0
 mapped:2333 shmem:114 pagetables:697 bounce:0
 free_cma:0
DMA free:2408kB min:84kB low:104kB high:124kB active_anon:8kB inactive_anon:44kB active_file:824kB inactive_file:11512kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15676kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:16kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:112kB pagetables:20kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 489 489 489
DMA32 free:6552kB min:2784kB low:3480kB high:4176kB active_anon:13424kB inactive_anon:13472kB active_file:41636kB inactive_file:357764kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:500952kB managed:491396kB mlocked:0kB dirty:12kB writeback:0kB mapped:9316kB shmem:456kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:1160kB pagetables:2768kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 52*4kB (UMR) 13*8kB (UMR) 4*16kB (R) 2*32kB (R) 1*64kB (R) 1*128kB (R) 1*256kB (R) 1*512kB (R) 1*1024kB (R) 0*2048kB 0*4096kB = 2424kB
DMA32: 1608*4kB (UM) 15*8kB (M) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 6552kB
103053 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 392188kB
Total swap = 392188kB
131054 pages RAM
3477 pages reserved
283467 pages shared
111732 pages non-shared

> What I'm looking for is a throttling bug (if pgscan_direct_throttle is
> elevated), an isolated page accounting bug (nr_isolated_* is elevated
> and process is stuck in congestion_wait in a too_many_isolated() loop)
> or a free page accounting bug (big difference between nr_free_pages and
> buddy list figures).
> 
> I'll try reproducing this early next week if none of that shows an
> obvious candidate.

Thanks!  I'll try to get you more information as soon as possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
