Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF56E6B01FC
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:33:55 -0400 (EDT)
Date: Wed, 18 Aug 2010 17:31:32 +0100
From: Chris Webb <chris@arachsys.com>
Subject: Re: Over-eager swapping
Message-ID: <20100818163132.GC2370@arachsys.com>
References: <20100804032400.GA14141@localhost>
 <20100804095811.GC2326@arachsys.com>
 <20100804114933.GA13527@localhost>
 <20100804120430.GB23551@arachsys.com>
 <20100818143801.GA9086@localhost>
 <20100818144655.GX2370@arachsys.com>
 <20100818152103.GA11268@localhost>
 <1282147034.77481.33.camel@useless.localdomain>
 <20100818155825.GA2370@arachsys.com>
 <20100818161346.GA12932@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100818161346.GA12932@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang <fengguang.wu@intel.com> writes:

> Chris, can you post /proc/vmstat on the problem machines?

Here's /proc/vmstat from one of the bad machines with swap taken out:

  # cat /proc/vmstat
  nr_free_pages 115572
  nr_inactive_anon 562140
  nr_active_anon 5015609
  nr_inactive_file 997097
  nr_active_file 996989
  nr_unevictable 1368
  nr_mlock 1368
  nr_anon_pages 5862299
  nr_mapped 1414
  nr_file_pages 1994569
  nr_dirty 619
  nr_writeback 0
  nr_slab_reclaimable 88883
  nr_slab_unreclaimable 129859
  nr_page_table_pages 15744
  nr_kernel_stack 1132
  nr_unstable 0
  nr_bounce 0
  nr_vmscan_write 68708505
  nr_writeback_temp 0
  nr_isolated_anon 0
  nr_isolated_file 0
  nr_shmem 14
  numa_hit 15295188815
  numa_miss 9391232519
  numa_foreign 9391232519
  numa_interleave 16982
  numa_local 15294742520
  numa_other 9391678814
  pgpgin 20644565778
  pgpgout 28740368207
  pswpin 63818244
  pswpout 61199234
  pgalloc_dma 0
  pgalloc_dma32 4967135753
  pgalloc_normal 19812671901
  pgalloc_movable 0
  pgfree 24779926775
  pgactivate 1290396237
  pgdeactivate 1289759899
  pgfault 19993995783
  pgmajfault 21059190
  pgrefill_dma 0
  pgrefill_dma32 133366009
  pgrefill_normal 921184739
  pgrefill_movable 0
  pgsteal_dma 0
  pgsteal_dma32 1275354745
  pgsteal_normal 5641309780
  pgsteal_movable 0
  pgscan_kswapd_dma 0
  pgscan_kswapd_dma32 1333139288
  pgscan_kswapd_normal 5870516663
  pgscan_kswapd_movable 0
  pgscan_direct_dma 0
  pgscan_direct_dma32 1064518
  pgscan_direct_normal 13317302
  pgscan_direct_movable 0
  zone_reclaim_failed 0
  pginodesteal 0
  slabs_scanned 1682790400
  kswapd_steal 6902288285
  kswapd_inodesteal 4909342
  pageoutrun 65408579
  allocstall 33223
  pgrotated 68402979
  htlb_buddy_alloc_success 0
  htlb_buddy_alloc_fail 0
  unevictable_pgs_culled 3538872
  unevictable_pgs_scanned 0
  unevictable_pgs_rescued 4989403
  unevictable_pgs_mlocked 5192009
  unevictable_pgs_munlocked 4989074
  unevictable_pgs_cleared 2295
  unevictable_pgs_stranded 0
  unevictable_pgs_mlockfreed 0

The not-so-bad machine that's 3G in swap that I mentioned previously has

  # cat /proc/vmstat 
  nr_free_pages 898394
  nr_inactive_anon 834445
  nr_active_anon 4118034
  nr_inactive_file 904411
  nr_active_file 910902
  nr_unevictable 2440
  nr_mlock 2440
  nr_anon_pages 4836349
  nr_mapped 1553
  nr_file_pages 2243152
  nr_dirty 1097
  nr_writeback 0
  nr_slab_reclaimable 88788
  nr_slab_unreclaimable 127310
  nr_page_table_pages 14762
  nr_kernel_stack 532
  nr_unstable 0
  nr_bounce 0
  nr_vmscan_write 37404214
  nr_writeback_temp 0
  nr_isolated_anon 0
  nr_isolated_file 0
  nr_shmem 12
  numa_hit 14220178949
  numa_miss 3903552922
  numa_foreign 3903552922
  numa_interleave 16282
  numa_local 14219905325
  numa_other 3903826546
  pgpgin 6500403846
  pgpgout 13255814979
  pswpin 36384510
  pswpout 36380545
  pgalloc_dma 4
  pgalloc_dma32 2019546454
  pgalloc_normal 16466621455
  pgalloc_movable 0
  pgfree 18487068066
  pgactivate 530670561
  pgdeactivate 506674301
  pgfault 19986735100
  pgmajfault 10611234
  pgrefill_dma 0
  pgrefill_dma32 41306492
  pgrefill_normal 318767138
  pgrefill_movable 0
  pgsteal_dma 0
  pgsteal_dma32 214447663
  pgsteal_normal 1645250232
  pgsteal_movable 0
  pgscan_kswapd_dma 0
  pgscan_kswapd_dma32 218030201
  pgscan_kswapd_normal 1812499810
  pgscan_kswapd_movable 0
  pgscan_direct_dma 0
  pgscan_direct_dma32 157144
  pgscan_direct_normal 1095919
  pgscan_direct_movable 0
  zone_reclaim_failed 0
  pginodesteal 0
  slabs_scanned 50051072
  kswapd_steal 1858447127
  kswapd_inodesteal 202297
  pageoutrun 15070446
  allocstall 3104
  pgrotated 37181651
  htlb_buddy_alloc_success 0
  htlb_buddy_alloc_fail 0
  unevictable_pgs_culled 2113384
  unevictable_pgs_scanned 0
  unevictable_pgs_rescued 3055005
  unevictable_pgs_mlocked 3184675
  unevictable_pgs_munlocked 3045129
  unevictable_pgs_cleared 10034
  unevictable_pgs_stranded 0
  unevictable_pgs_mlockfreed 0

Best wishes,

Chris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
