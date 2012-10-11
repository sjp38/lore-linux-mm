Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id F003F6B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 04:52:32 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id hq7so1539640wib.8
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 01:52:31 -0700 (PDT)
Message-ID: <507688CC.9000104@suse.cz>
Date: Thu, 11 Oct 2012 10:52:28 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: kswapd0: wxcessive CPU usage
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jiri Slaby <jirislaby@gmail.com>

Hi,

with 3.6.0-next-20121008, kswapd0 is spinning my CPU at 100% for 1
minute or so. If I try to suspend to RAM, this trace appears:
kswapd0         R  running task        0   577      2 0x00000000
 0000000000000000 00000000000000c0 cccccccccccccccd ffff8801c4146800
 ffff8801c4b15c88 ffffffff8116ee05 0000000000003e32 ffff8801c3a79000
 ffff8801c4b15ca8 ffffffff8116fdf8 ffff8801c480f398 ffff8801c3a79000
Call Trace:
 [<ffffffff8116ee05>] ? put_super+0x25/0x40
 [<ffffffff8116fdd4>] ? grab_super_passive+0x24/0xa0
 [<ffffffff8116ff99>] ? prune_super+0x149/0x1b0
 [<ffffffff81131531>] ? shrink_slab+0xa1/0x2d0
 [<ffffffff8113452d>] ? kswapd+0x66d/0xb60
 [<ffffffff81133ec0>] ? try_to_free_pages+0x180/0x180
 [<ffffffff810a2770>] ? kthread+0xc0/0xd0
 [<ffffffff810a26b0>] ? kthread_create_on_node+0x130/0x130
 [<ffffffff816a6c9c>] ? ret_from_fork+0x7c/0x90
 [<ffffffff810a26b0>] ? kthread_create_on_node+0x130/0x130

# cat /proc/vmstat
nr_free_pages 239962
nr_inactive_anon 89825
nr_active_anon 711136
nr_inactive_file 60386
nr_active_file 46668
nr_unevictable 0
nr_mlock 0
nr_anon_pages 500678
nr_mapped 41319
nr_file_pages 319317
nr_dirty 45
nr_writeback 0
nr_slab_reclaimable 21909
nr_slab_unreclaimable 21598
nr_page_table_pages 12131
nr_kernel_stack 491
nr_unstable 0
nr_bounce 0
nr_vmscan_write 1674280
nr_vmscan_immediate_reclaim 301662
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 212263
nr_dirtied 10620227
nr_written 9260939
nr_anon_transparent_hugepages 172
nr_free_cma 0
nr_dirty_threshold 31459
nr_dirty_background_threshold 15729
pgpgin 31311778
pgpgout 38987552
pswpin 0
pswpout 0
pgalloc_dma 0
pgalloc_dma32 245169455
pgalloc_normal 279685864
pgalloc_movable 0
pgfree 537318727
pgactivate 13126755
pgdeactivate 2482953
pgfault 645947575
pgmajfault 193427
pgrefill_dma 0
pgrefill_dma32 1124272
pgrefill_normal 1998033
pgrefill_movable 0
pgsteal_kswapd_dma 0
pgsteal_kswapd_dma32 2531015
pgsteal_kswapd_normal 3403006
pgsteal_kswapd_movable 0
pgsteal_direct_dma 0
pgsteal_direct_dma32 362488
pgsteal_direct_normal 1134511
pgsteal_direct_movable 0
pgscan_kswapd_dma 0
pgscan_kswapd_dma32 2693620
pgscan_kswapd_normal 5836491
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_dma32 368374
pgscan_direct_normal 1658486
pgscan_direct_movable 0
pgscan_direct_throttle 0
pginodesteal 258410
slabs_scanned 86459392
kswapd_inodesteal 3907549
kswapd_low_wmark_hit_quickly 15408
kswapd_high_wmark_hit_quickly 23113
kswapd_skip_congestion_wait 10
pageoutrun 2165627235
allocstall 11256
pgrotated 219624
compact_blocks_moved 4862077
compact_pages_moved 1970005
compact_pagemigrate_failed 1726156
compact_stall 21275
compact_fail 6589
compact_success 14686
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 2799
unevictable_pgs_scanned 0
unevictable_pgs_rescued 22563
unevictable_pgs_mlocked 22563
unevictable_pgs_munlocked 22563
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
thp_fault_alloc 18725
thp_fault_fallback 64868
thp_collapse_alloc 9216
thp_collapse_alloc_failed 2031
thp_split 2146

Any ideas what it could be?

-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
