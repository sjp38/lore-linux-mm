Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E9CE76B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 01:10:36 -0500 (EST)
Date: Wed, 8 Dec 2010 14:10:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: ext4 memory leak?
Message-ID: <20101208061030.GA1956@localhost>
References: <20101205064430.GA15027@localhost>
 <4CFB9BE1.3030902@redhat.com>
 <20101207131136.GA20366@localhost>
 <20101207143351.GA23377@localhost>
 <20101207152120.GA28220@localhost>
 <20101207163820.GF24607@thunk.org>
 <20101208024019.GA14424@localhost>
 <A9D7CD0F-0A46-4EE6-9454-8689CD3FC03D@MIT.EDU>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A9D7CD0F-0A46-4EE6-9454-8689CD3FC03D@MIT.EDU>
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@MIT.EDU>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 08, 2010 at 11:07:24AM +0800, Theodore Ts'o wrote:
> 
> On Dec 7, 2010, at 9:40 PM, Wu Fengguang wrote:
> 
> > Here is the full data collected with "mem=512M", where the reclaimable
> > memory size still declines slowly. slabinfo is also collected.
> > 
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/512M/ext4-10dd-1M-8p-442M-2.6.37-rc4+-2010-12-08-09-19/
> > 
> > The increase of nr_slab_reclaimable roughly equals to the decrease of
> > nr_dirty_threshold. So it may be either the VM not able to reclaim the
> > slabs fast enough, or the slabs are not reclaimable at the time.
> 
> Can you try running this with CONFIG_SLAB instead of the SLUB allocator?

Sure. I've uploaded new data with CONFIG_SLAB to

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/512M/ext4-10dd-1M-8p-442M-2.6.37-rc5+-2010-12-08-12-53/

> One of the things I hate about the SLUB allocator is it tries too hard to prevent cache line ping-pong effects, which is fine if you have lots of memory, but if you have 8 processors and memory constrained to 256 megs, I suspect it doesn't work too well because it leaves too many slabs allocated so that every single CPU has its own portion of the slab cache.   In the case of slabs like ext4_io_end, which is 8 pages per slab, if you have 8 cpu's, and memory constrained down to 256 megs, memory starts getting wasted like it was going out of style.
> 
> Worse yet, with the SLUB allocator, you can't trust the number of active objects (I've had cases where it would swear up and down that all 16000 out of 16000 objects were in use, but then I'd run "slabinfo -s", and all of the slabs would be shrunk down to zero.  Grrr.... I wasted a lot of time looking for a memory leak before I realized that you can't trust # of active objects information in /proc/slabinfo when you enable CONFIG_SLUB.)

Interestingly nr_slab_reclaimable dropped but nr_slab_unreclaimable
increased. So there are still declining lines in the vmstat-dirty.png
graph. I can conveniently test other settings, just drop me a hint.

Thanks,
Fengguang
---
$ diff -u ext4-10dd-1M-8p-442M-2.6.37-rc4+-2010-12-08-09-19/vmstat-end ext4-2dd-1M-8p-442M-2.6.37-rc5+-2010-12-08-13-44/vmstat-end
--- ext4-10dd-1M-8p-442M-2.6.37-rc4+-2010-12-08-09-19/vmstat-end        2010-12-08 09:24:32.000000000 +0800
+++ ext4-2dd-1M-8p-442M-2.6.37-rc5+-2010-12-08-13-44/vmstat-end 2010-12-08 13:49:56.000000000 +0800
@@ -1,76 +1,76 @@
-nr_free_pages 1479
+nr_free_pages 1562
 nr_inactive_anon 10
-nr_active_anon 5772
-nr_inactive_file 59819
-nr_active_file 2014
+nr_active_anon 3522
+nr_inactive_file 66227
+nr_active_file 2717
 nr_unevictable 0
 nr_mlock 0
-nr_anon_pages 5683
-nr_mapped 1275
-nr_file_pages 61909
-nr_dirty 1911
-nr_writeback 9023
-nr_slab_reclaimable 12347
-nr_slab_unreclaimable 5185
-nr_page_table_pages 369
-nr_kernel_stack 150
-nr_unstable 1
+nr_anon_pages 3396
+nr_mapped 1282
+nr_file_pages 69061
+nr_dirty 5590
+nr_writeback 4885
+nr_slab_reclaimable 6076
+nr_slab_unreclaimable 9214
+nr_page_table_pages 341
+nr_kernel_stack 141
+nr_unstable 3
 nr_bounce 0
-nr_vmscan_write 983
+nr_vmscan_write 2
 nr_writeback_temp 0
 nr_isolated_anon 0
 nr_isolated_file 0
 nr_shmem 75
-nr_dirtied 4308257
-nr_written 3413957
-numa_hit 5456001
+nr_dirtied 5265866
+nr_written 4022995
+numa_hit 6013494
 numa_miss 0
 numa_foreign 0
-numa_interleave 3439
-numa_local 5456001
+numa_interleave 1662
+numa_local 6013494
 numa_other 0
-nr_dirty_threshold 12662
-nr_dirty_background_threshold 6331
-pgpgin 2993
-pgpgout 13648908
+nr_dirty_threshold 14101
+nr_dirty_background_threshold 7050
+pgpgin 3009
+pgpgout 16083928
 pswpin 0
 pswpout 0
-pgalloc_dma 108585
-pgalloc_dma32 5418669
+pgalloc_dma 124090
+pgalloc_dma32 5922555
 pgalloc_normal 0
 pgalloc_movable 0
-pgfree 5529192
-pgactivate 3095
-pgdeactivate 12
-pgfault 6071730
-pgmajfault 1006
+pgfree 6048669
+pgactivate 3229
+pgdeactivate 0
+pgfault 5927955
+pgmajfault 778
 pgrefill_dma 0
 pgrefill_dma32 0
 pgrefill_normal 0
 pgrefill_movable 0
-pgsteal_dma 72515
-pgsteal_dma32 3210098
+pgsteal_dma 84016
+pgsteal_dma32 3809225
 pgsteal_normal 0
 pgsteal_movable 0
-pgscan_kswapd_dma 75166
-pgscan_kswapd_dma32 3276702
+pgscan_kswapd_dma 84614
+pgscan_kswapd_dma32 3815256
 pgscan_kswapd_normal 0
 pgscan_kswapd_movable 0
-pgscan_direct_dma 1763
-pgscan_direct_dma32 56500
+pgscan_direct_dma 0
+pgscan_direct_dma32 128
 pgscan_direct_normal 0
 pgscan_direct_movable 0
 zone_reclaim_failed 0
-pginodesteal 134
-slabs_scanned 7808
-kswapd_steal 3231964
-kswapd_inodesteal 732
-kswapd_low_wmark_hit_quickly 10778
-kswapd_high_wmark_hit_quickly 5383703
+pginodesteal 0
+slabs_scanned 6656
+kswapd_steal 3893113
+kswapd_inodesteal 313
+kswapd_low_wmark_hit_quickly 13196
+kswapd_high_wmark_hit_quickly 3601730
 kswapd_skip_congestion_wait 1
-pageoutrun 5465481
-allocstall 1324
-pgrotated 3
+pageoutrun 3696936
+allocstall 4
+pgrotated 2
 htlb_buddy_alloc_success 0
 htlb_buddy_alloc_fail 0
 unevictable_pgs_culled 0
wfg ~/bee%  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
