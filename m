Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1D52B6B0089
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 21:40:57 -0500 (EST)
Date: Wed, 8 Dec 2010 10:40:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: ext4 memory leak?
Message-ID: <20101208024019.GA14424@localhost>
References: <20101205064430.GA15027@localhost>
 <4CFB9BE1.3030902@redhat.com>
 <20101207131136.GA20366@localhost>
 <20101207143351.GA23377@localhost>
 <20101207152120.GA28220@localhost>
 <20101207163820.GF24607@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101207163820.GF24607@thunk.org>
Sender: owner-linux-mm@kvack.org
To: Ted Ts'o <tytso@mit.edu>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Ted,

On Wed, Dec 08, 2010 at 12:38:20AM +0800, Theodore Ts'o wrote:
> On Tue, Dec 07, 2010 at 11:21:20PM +0800, Wu Fengguang wrote:
> > On Tue, Dec 07, 2010 at 10:33:51PM +0800, Wu Fengguang wrote:
> > > > In a simple dd test on a 8p system with "mem=256M", I find the light
> > > 
> > > When increasing to 10 concurrent dd tasks, I managed to crash ext4..
> > > (2 concurrent dd's are OK, with very good write performance.)
> 
> What was the dd command line?  Specifically, how big were the file

        dd bs=$bs if=/dev/zero of=$MNT/zero$i

where bs=1M, fs size is 21GB. The writes will continue for 300s at around
44MB/s, totally written 13GB data.

> writes?  I haven't been able to replicate a leak.  I'll try on a small
> system seeing if I can replicate an OOM kill, but I'm not seeing a
> leak.  (i.e., after the dd if=/dev/zero of=/test/$i" jobs) are
> finished, the memory utilization looks normal and I don't see any
> obvious slab leaks.

I also didn't see the declining global dirty limit lines with 4GB
memory size.

Note that my test case will do

        echo 10240 > /debug/tracing/buffer_size_kb

which eats some memory.

Here is the test scripts, you may run test-dd.sh with modified $DEV
and $MNT at the head of it. It's fine to run it on vanilla kernels
where it won't be able to gather and plot the trace points, but can
still plot the vmstat/iostat numbers.

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/

Here is the full data collected with "mem=512M", where the reclaimable
memory size still declines slowly. slabinfo is also collected.

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/512M/ext4-10dd-1M-8p-442M-2.6.37-rc4+-2010-12-08-09-19/

The increase of nr_slab_reclaimable roughly equals to the decrease of
nr_dirty_threshold. So it may be either the VM not able to reclaim the
slabs fast enough, or the slabs are not reclaimable at the time.

$ diff -u vmstat-begin vmstat-end
--- vmstat-begin        2010-12-08 09:19:32.000000000 +0800
+++ vmstat-end  2010-12-08 09:24:32.000000000 +0800
@@ -1,76 +1,76 @@
-nr_free_pages 93141
-nr_inactive_anon 9
-nr_active_anon 1733
-nr_inactive_file 1093
-nr_active_file 2166
+nr_free_pages 1479
+nr_inactive_anon 10
+nr_active_anon 5772
+nr_inactive_file 59819
+nr_active_file 2014
 nr_unevictable 0
 nr_mlock 0
-nr_anon_pages 1711
-nr_mapped 1329
-nr_file_pages 3350
-nr_dirty 0
-nr_writeback 0
-nr_slab_reclaimable 4341
-nr_slab_unreclaimable 4787
-nr_page_table_pages 273
-nr_kernel_stack 141
-nr_unstable 0
+nr_anon_pages 5683
+nr_mapped 1275
+nr_file_pages 61909
+nr_dirty 1911
+nr_writeback 9023
+nr_slab_reclaimable 12347
+nr_slab_unreclaimable 5185
+nr_page_table_pages 369
+nr_kernel_stack 150
+nr_unstable 1
 nr_bounce 0
-nr_vmscan_write 1
+nr_vmscan_write 983
 nr_writeback_temp 0
 nr_isolated_anon 0
 nr_isolated_file 0
 nr_shmem 75
-nr_dirtied 118086
-nr_written 118086
-numa_hit 224948
+nr_dirtied 4308257
+nr_written 3413957
+numa_hit 5456001
 numa_miss 0
 numa_foreign 0
 numa_interleave 3439
-numa_local 224948
+numa_local 5456001
 numa_other 0
-nr_dirty_threshold 19280
-nr_dirty_background_threshold 9640
-pgpgin 2921
-pgpgout 471820
+nr_dirty_threshold 12662
+nr_dirty_background_threshold 6331
+pgpgin 2993
+pgpgout 13648908
 pswpin 0
 pswpout 0
-pgalloc_dma 4216
-pgalloc_dma32 243254
+pgalloc_dma 108585
+pgalloc_dma32 5418669
 pgalloc_normal 0
 pgalloc_movable 0
-pgfree 341092
-pgactivate 2374
+pgfree 5529192
+pgactivate 3095
 pgdeactivate 12
-pgfault 211485
-pgmajfault 142
+pgfault 6071730
+pgmajfault 1006
 pgrefill_dma 0
 pgrefill_dma32 0
 pgrefill_normal 0
 pgrefill_movable 0
-pgsteal_dma 352
-pgsteal_dma32 33553
+pgsteal_dma 72515
+pgsteal_dma32 3210098
 pgsteal_normal 0
 pgsteal_movable 0
-pgscan_kswapd_dma 416
-pgscan_kswapd_dma32 27381
+pgscan_kswapd_dma 75166
+pgscan_kswapd_dma32 3276702
 pgscan_kswapd_normal 0
 pgscan_kswapd_movable 0
-pgscan_direct_dma 224
-pgscan_direct_dma32 6893
+pgscan_direct_dma 1763
+pgscan_direct_dma32 56500
 pgscan_direct_normal 0
 pgscan_direct_movable 0
 zone_reclaim_failed 0
-pginodesteal 0
-slabs_scanned 3968
-kswapd_steal 27190
-kswapd_inodesteal 0
-kswapd_low_wmark_hit_quickly 80
-kswapd_high_wmark_hit_quickly 40578
-kswapd_skip_congestion_wait 0
-pageoutrun 41100
-allocstall 207
-pgrotated 1
+pginodesteal 134
+slabs_scanned 7808
+kswapd_steal 3231964
+kswapd_inodesteal 732
+kswapd_low_wmark_hit_quickly 10778
+kswapd_high_wmark_hit_quickly 5383703
+kswapd_skip_congestion_wait 1
+pageoutrun 5465481
+allocstall 1324
+pgrotated 3
 htlb_buddy_alloc_success 0
 htlb_buddy_alloc_fail 0
 unevictable_pgs_culled 0

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
