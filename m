Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3E16B0031
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 21:57:24 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so2576519pde.35
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 18:57:23 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id gm1si2361538pac.245.2014.01.08.18.57.21
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 18:57:22 -0800 (PST)
Date: Thu, 9 Jan 2014 10:57:15 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [numa shrinker] 9b17c62382: -36.6% regression on sparse file copy
Message-ID: <20140109025715.GA11984@localhost>
References: <20140106082048.GA567@localhost>
 <20140106131042.GA5145@destitution>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="jI8keyz6grp/JLjh"
Content-Disposition: inline
In-Reply-To: <20140106131042.GA5145@destitution>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@parallels.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, lkp@linux.intel.com


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

As you suggested, I added tests for ext4 and btrfs, the results are
the same.

Then I tried running perf record for 10 seconds starting from 200s.
(The test runs for 410s). I see several warning messages and hope
they do not impact the accuracy too much:

[  252.608069] perf samples too long (2532 > 2500), lowering kernel.perf_event_max_sample_rate to 50000
[  252.608863] perf samples too long (2507 > 2500), lowering kernel.perf_event_max_sample_rate to 25000
[  252.609422] INFO: NMI handler (perf_event_nmi_handler) took too long to run: 1.389 msecs

Anyway the noticeable perf change are:

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     12.15 ~10%    +209.8%      37.63 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
     12.88 ~16%    +189.4%      37.27 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
     15.24 ~ 9%    +146.0%      37.50 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
     40.27         +179.1%     112.40       TOTAL perf-profile.cpu-cycles._raw_spin_lock.grab_super_passive.super_cache_count.shrink_slab.do_try_to_free_pages

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     11.91 ~12%    +218.2%      37.89 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
     12.47 ~16%    +200.3%      37.44 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
     15.36 ~11%    +145.4%      37.68 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
     39.73         +184.5%     113.01       TOTAL perf-profile.cpu-cycles._raw_spin_lock.put_super.drop_super.super_cache_count.shrink_slab

perf report for 9b17c62382dd2e7507984b989:

# Overhead          Command       Shared Object                                          Symbol
# ........  ...............  ..................  ..............................................
#
    77.74%               dd  [kernel.kallsyms]   [k] _raw_spin_lock                            
                         |
                         --- _raw_spin_lock
                            |          
                            |--47.65%-- grab_super_passive
                            |          super_cache_count
                            |          shrink_slab
                            |          do_try_to_free_pages
                            |          try_to_free_pages
                            |          __alloc_pages_nodemask
                            |          alloc_pages_current
                            |          __page_cache_alloc
                            |          __do_page_cache_readahead
                            |          ra_submit
                            |          ondemand_readahead
                            |          |          
                            |          |--92.13%-- page_cache_async_readahead
                            |          |          generic_file_aio_read
                            |          |          xfs_file_aio_read
                            |          |          do_sync_read
                            |          |          vfs_read
                            |          |          SyS_read
                            |          |          system_call_fastpath
                            |          |          read
                            |          |          
                            |           --7.87%-- page_cache_sync_readahead
                            |                     generic_file_aio_read
                            |                     xfs_file_aio_read
                            |                     do_sync_read
                            |                     vfs_read
                            |                     SyS_read
                            |                     system_call_fastpath
                            |                     read
                            |--47.48%-- put_super
                            |          drop_super
                            |          super_cache_count
                            |          shrink_slab
                            |          do_try_to_free_pages
                            |          try_to_free_pages
                            |          __alloc_pages_nodemask
                            |          alloc_pages_current
                            |          __page_cache_alloc
                            |          __do_page_cache_readahead
                            |          ra_submit
                            |          ondemand_readahead
                            |          |          
                            |          |--92.04%-- page_cache_async_readahead
                            |          |          generic_file_aio_read
                            |          |          xfs_file_aio_read
                            |          |          do_sync_read
                            |          |          vfs_read
                            |          |          SyS_read
                            |          |          system_call_fastpath
                            |          |          read
                            |          |          
                            |           --7.96%-- page_cache_sync_readahead
                            |                     generic_file_aio_read
                            |                     xfs_file_aio_read
                            |                     do_sync_read
                            |                     vfs_read
                            |                     SyS_read
                            |                     system_call_fastpath
                            |                     read
                             --4.87%-- [...]

The full changeset is attached.

Thanks,
Fengguang

--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=9b17c62382dd2e7507984b9890bf44e070cdd8bb

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     36.90 ~28%     -62.2%      13.96 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
     67.26 ~12%     -79.0%      14.15 ~ 6%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
     45.75 ~38%     -70.4%      13.56 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
     69.74 ~28%     -81.2%      13.11 ~ 8%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
     78.86 ~23%     -83.1%      13.35 ~ 3%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
    298.51          -77.2%      68.13       TOTAL vm-scalability.stddev

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
   9668836 ~ 3%     -35.0%    6281286 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  13895724 ~ 2%     -39.4%    8418087 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  13262793 ~ 0%     -37.5%    8288611 ~ 2%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
   9502935 ~ 2%     -29.0%    6748913 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  13629906 ~ 2%     -38.2%    8417200 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  13213877 ~ 3%     -36.9%    8333983 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  13222395 ~ 2%     -36.6%    8380368 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
  86396468          -36.5%   54868449       TOTAL vm-scalability.throughput

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      1.44         -100.0%       0.00       brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      1.44         -100.0%       0.00       TOTAL perf-profile.cpu-cycles._raw_spin_lock.free_pcppages_bulk.generic_smp_call_function_single_interrupt.__alloc_pages_nodemask.alloc_pages_current

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      1632 ~ 5%     -88.9%        181 ~ 7%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
       801 ~ 1%     -85.3%        117 ~ 8%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
       753 ~ 6%     -83.1%        127 ~10%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
      1583 ~ 3%     -88.5%        182 ~ 3%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
       797 ~ 0%     -85.4%        116 ~13%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
       755 ~ 5%     -83.5%        124 ~ 2%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
       828 ~ 6%     -85.1%        123 ~11%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
      7152          -86.4%        972       TOTAL proc-vmstat.nr_isolated_file

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     12.95 ~ 2%    -100.0%       0.00       brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
     12.95         -100.0%       0.00       TOTAL perf-profile.cpu-cycles._raw_spin_lock.free_pcppages_bulk.drain_pages.rain_local_pages

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
       370 ~ 1%     -89.5%         38 ~ 7%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
       153 ~ 6%     -83.7%         25 ~ 3%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
       145 ~ 3%     -81.7%         26 ~19%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
       366 ~ 4%     -90.5%         35 ~ 6%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
       153 ~ 3%     -83.4%         25 ~ 6%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
       156 ~ 5%     -85.7%         22 ~ 2%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      1345          -87.1%        173       TOTAL numa-vmstat.node3.nr_isolated_file

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
       357 ~ 5%     -91.1%         32 ~10%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
       152 ~ 3%     -81.0%         29 ~10%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
       151 ~ 3%     -82.0%         27 ~14%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
       318 ~ 4%     -89.6%         33 ~ 4%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
       149 ~ 3%     -82.1%         26 ~ 9%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
       146 ~ 7%     -81.5%         27 ~12%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
       160 ~ 7%     -83.9%         25 ~ 6%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
      1436          -86.0%        200       TOTAL numa-vmstat.node2.nr_isolated_file

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     12.86         -100.0%       0.00       brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
     12.86         -100.0%       0.00       TOTAL perf-profile.cpu-cycles._raw_spin_lock.free_pcppages_bulk.generic_smp_call_function_single_interrupt.smp_call_function_interrupt.all_function_interrupt

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      5.22         -100.0%       0.00       brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      5.22         -100.0%       0.00       TOTAL perf-profile.cpu-cycles._raw_spin_lock.free_pcppages_bulk.generic_smp_call_function_single_interrupt.shrink_lruvec.shrink_zone

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      8.94 ~ 3%     -99.9%       0.01       brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
      8.94          -99.9%       0.01       TOTAL perf-profile.cpu-cycles._raw_spin_lock.free_pcppages_bulk.drain_pages.drain_local_pages.generic_smp_call_function_single_interrupt

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     11.47 ~ 3%     -98.8%       0.13 ~14%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
     11.47          -98.8%       0.13       TOTAL perf-profile.cpu-cycles._raw_spin_lock.clear_extent_bit.try_release_extent_mapping.__btrfs_releasepage.btrfs_releasepage

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     11.92 ~ 3%     -98.9%       0.14 ~22%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
     11.92          -98.9%       0.14       TOTAL perf-profile.cpu-cycles._raw_spin_lock.test_range_bit.try_release_extent_mapping.__btrfs_releasepage.btrfs_releasepage

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
       329 ~ 2%     -90.2%         32 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
       142 ~ 3%     -83.6%         23 ~11%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
       149 ~ 2%     -79.4%         30 ~22%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
       332 ~ 5%     -88.9%         37 ~ 7%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
       149 ~ 4%     -83.3%         25 ~ 5%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
       161 ~ 5%     -83.2%         27 ~10%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
      1264          -86.1%        175       TOTAL numa-vmstat.node1.nr_isolated_file

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      1.74         -100.0%       0.00       brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      1.74         -100.0%       0.00       TOTAL perf-profile.cpu-cycles._raw_spin_lock.free_pcppages_bulk.generic_smp_call_function_single_interrupt.pagevec_lru_move_fn.__pagevec_lru_add

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      1.43         -100.0%       0.00       brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      1.43         -100.0%       0.00       TOTAL perf-profile.cpu-cycles._raw_spin_lock.free_pcppages_bulk.generic_smp_call_function_single_interrupt.grab_super_passive.super_cache_count

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      7.12 ~22%     -90.3%       0.69 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
      7.12          -90.3%       0.69       TOTAL perf-profile.cpu-cycles._raw_spin_lock_irqsave.pagevec_lru_move_fn.__pagevec_lru_add.__lru_cache_add.add_to_page_cache_lru

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      1.03         -100.0%       0.00       brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      1.03         -100.0%       0.00       TOTAL perf-profile.cpu-cycles._raw_spin_lock.free_pcppages_bulk.generic_smp_call_function_single_interrupt.put_super.drop_super

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     13.30         -100.0%       0.00       brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
     13.30         -100.0%       0.00       TOTAL perf-profile.cpu-cycles._raw_spin_lock.free_pcppages_bulk.generic_smp_call_function_single_interrupt.smp_call_function_interrupt.call_function_interrupt

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     10.62         -100.0%       0.00       brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
     10.62         -100.0%       0.00       TOTAL perf-profile.cpu-cycles._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_current._page_cache_alloc

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     14970 ~ 7%     -93.1%       1039 ~ 9%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
     14970          -93.1%       1039       TOTAL numa-vmstat.node1.nr_shmem

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      5385 ~134%     -99.6%         23 ~24%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      5385          -99.6%         23       TOTAL numa-vmstat.node1.nr_inactive_anon

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     59673 ~ 8%     -93.0%       4147 ~ 9%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
     59673          -93.0%       4147       TOTAL numa-meminfo.node1.Shmem

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      1199         -100.0%          0       brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      1199         -100.0%          0       TOTAL proc-vmstat.compact_isolated

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
   8388847         -100.0%          0       brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
   8388847         -100.0%          0       TOTAL proc-vmstat.compact_free_scanned

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      9.96         -100.0%       0.00       brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      9.96         -100.0%       0.00       TOTAL perf-profile.cpu-cycles._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.page_cache_async_readahead.generic_file_aio_read

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
       542 ~ 4%     -89.2%         58 ~ 8%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
       340 ~ 2%     -88.5%         39 ~17%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
       299 ~ 2%     -87.4%         37 ~16%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
       543 ~ 3%     -88.2%         64 ~19%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
       328 ~ 4%     -88.1%         39 ~ 9%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
       322 ~ 5%     -87.9%         39 ~12%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
      2375          -88.3%        277       TOTAL numa-vmstat.node0.nr_isolated_file

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      4.94 ~ 8%     -84.9%       0.75 ~ 6%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
      4.49 ~ 8%     -81.8%       0.82 ~12%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      9.44          -83.4%       1.57       TOTAL perf-profile.cpu-cycles._raw_spin_lock_irq.shrink_inactive_list.shrink_lruvec.shrink_zone.do_try_to_free_pages

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      5.40 ~12%    -100.0%       0.00       brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
     11.72 ~ 7%    -100.0%       0.00       brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
     17.12         -100.0%       0.00       TOTAL perf-profile.cpu-cycles._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_current.__page_cache_alloc

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      3.67 ~14%     -79.1%       0.77 ~ 7%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
      3.67          -79.1%       0.77       TOTAL perf-profile.cpu-cycles._raw_spin_lock_irq.shrink_active_list.shrink_lruvec.shrink_zone.do_try_to_free_pages

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
   9683723 ~ 5%     -79.7%    1962307 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
   6260244 ~ 7%     -75.2%    1551554 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
   7200253 ~ 2%     -78.3%    1561062 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
   9806814 ~ 2%     -80.2%    1944315 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
   6793846 ~ 7%     -77.2%    1549055 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
   7203478 ~ 5%     -78.3%    1562578 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  46948359          -78.4%   10130872       TOTAL interrupts.CAL

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      3.30 ~ 6%     -73.4%       0.88 ~10%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
      3.26 ~ 4%     -76.6%       0.76 ~ 2%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
      3.40 ~ 6%     -78.7%       0.72 ~11%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      9.96          -76.3%       2.36       TOTAL perf-profile.cpu-cycles.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_current.__page_cache_alloc.__do_page_cache_readahead

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
       499 ~95%     -91.1%         44 ~ 2%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
       499          -91.1%         44       TOTAL numa-vmstat.node0.nr_shmem

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
         6 ~ 7%     -73.7%          1 ~28%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
         4 ~10%     -76.9%          1 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
        10          -75.0%          2       TOTAL vmstat.procs.b

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
   2059464 ~ 1%     -66.8%     683364 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
   2211078 ~ 1%     -70.2%     658319 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
   2254191 ~ 0%     -70.7%     660213 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
   2051749 ~ 0%     -67.2%     673278 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
   2235716 ~ 1%     -70.5%     659914 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
   2240505 ~ 0%     -70.6%     658796 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
   2317157 ~ 1%     -71.3%     665435 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
  15369862          -69.7%    4659321       TOTAL proc-vmstat.allocstall

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 2.925e+08 ~ 1%     -64.7%  1.033e+08 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 3.122e+08 ~ 1%     -70.1%   93285655 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 3.226e+08 ~ 0%     -71.0%   93448491 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 2.917e+08 ~ 0%     -65.2%  1.016e+08 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 3.171e+08 ~ 1%     -70.5%   93507813 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 3.203e+08 ~ 0%     -70.9%   93256664 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 3.318e+08 ~ 2%     -71.6%   94121050 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 2.188e+09          -69.3%  6.725e+08       TOTAL proc-vmstat.pgsteal_direct_normal

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 2.927e+08 ~ 1%     -64.6%  1.035e+08 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 3.123e+08 ~ 1%     -70.1%   93463514 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 3.227e+08 ~ 0%     -71.0%   93623627 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 2.919e+08 ~ 0%     -65.1%  1.017e+08 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 3.173e+08 ~ 1%     -70.5%   93676631 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 3.205e+08 ~ 0%     -70.8%   93430361 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 3.319e+08 ~ 2%     -71.6%   94296363 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 2.189e+09          -69.2%  6.738e+08       TOTAL proc-vmstat.pgscan_direct_normal

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  72878652 ~ 1%     -64.4%   25926019 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  77184982 ~ 1%     -70.1%   23083957 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  79650217 ~ 0%     -70.9%   23159518 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  72692240 ~ 0%     -65.0%   25471750 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  78366386 ~ 1%     -70.5%   23154383 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  79176009 ~ 0%     -70.8%   23105888 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  81841025 ~ 2%     -71.5%   23286086 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 541789514          -69.1%  167187602       TOTAL proc-vmstat.pgscan_direct_dma32

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  72875907 ~ 1%     -64.4%   25925641 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  77183060 ~ 1%     -70.1%   23083859 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  79649309 ~ 0%     -70.9%   23159440 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  72689417 ~ 0%     -65.0%   25471377 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  78364720 ~ 1%     -70.5%   23154281 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  79174839 ~ 0%     -70.8%   23105746 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  81839986 ~ 2%     -71.5%   23285993 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 541777240          -69.1%  167186339       TOTAL proc-vmstat.pgsteal_direct_dma32

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  94951845 ~ 0%     -67.3%   31083607 ~ 2%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  82484199 ~ 1%     -68.5%   26021552 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  84162804 ~ 0%     -69.1%   25993994 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  94108027 ~ 0%     -67.0%   31024521 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  83119481 ~ 1%     -68.7%   26006491 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  83655427 ~ 0%     -69.0%   25970626 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  86404323 ~ 1%     -69.7%   26171022 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 608886108          -68.4%  192271815       TOTAL proc-vmstat.pgalloc_dma32

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     12.15 ~10%    +209.8%      37.63 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
     12.88 ~16%    +189.4%      37.27 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
     15.24 ~ 9%    +146.0%      37.50 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
     40.27         +179.1%     112.40       TOTAL perf-profile.cpu-cycles._raw_spin_lock.grab_super_passive.super_cache_count.shrink_slab.do_try_to_free_pages

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     11.91 ~12%    +218.2%      37.89 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
     12.47 ~16%    +200.3%      37.44 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
     15.36 ~11%    +145.4%      37.68 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
     39.73         +184.5%     113.01       TOTAL perf-profile.cpu-cycles._raw_spin_lock.put_super.drop_super.super_cache_count.shrink_slab

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.269e+08 ~ 3%     -56.9%   54712338 ~ 3%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.258e+08 ~ 1%     -55.4%   56071637 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.282e+08 ~ 0%     -56.9%   55304171 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.258e+08 ~ 2%     -52.9%   59285061 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  1.23e+08 ~ 0%     -54.9%   55433738 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 1.278e+08 ~ 1%     -56.4%   55784132 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 1.283e+08 ~ 2%     -56.2%   56147285 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 8.858e+08          -55.7%  3.927e+08       TOTAL numa-numastat.node0.local_node

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.269e+08 ~ 3%     -56.9%   54712623 ~ 3%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.258e+08 ~ 1%     -55.4%   56072685 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.282e+08 ~ 0%     -56.9%   55305194 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.258e+08 ~ 2%     -52.9%   59286811 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  1.23e+08 ~ 0%     -54.9%   55436432 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 1.278e+08 ~ 1%     -56.4%   55785683 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 1.283e+08 ~ 2%     -56.2%   56148288 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 8.858e+08          -55.7%  3.927e+08       TOTAL numa-numastat.node0.numa_hit

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  94682303 ~ 3%     -55.4%   42214392 ~ 6%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  79205610 ~ 1%     -54.0%   36422113 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  81460484 ~ 0%     -56.1%   35772865 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  92975188 ~ 2%     -53.0%   43726957 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  77074137 ~ 2%     -53.6%   35781819 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  80955277 ~ 2%     -55.7%   35873093 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  83815289 ~ 2%     -57.4%   35703181 ~ 2%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 590168290          -55.0%  265494421       TOTAL numa-numastat.node0.numa_miss

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  94682625 ~ 3%     -55.4%   42214676 ~ 6%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  79206862 ~ 1%     -54.0%   36423161 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  81461211 ~ 0%     -56.1%   35773887 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  92976784 ~ 2%     -53.0%   43728707 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  77074970 ~ 2%     -53.6%   35784512 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  80957406 ~ 2%     -55.7%   35874644 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  83815794 ~ 2%     -57.4%   35704184 ~ 2%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 590175654          -55.0%  265503774       TOTAL numa-numastat.node0.other_node

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.155e+08 ~ 0%     -53.7%   53455816 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.182e+08 ~ 2%     -55.0%   53197826 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  1.16e+08 ~ 1%     -54.0%   53341823 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 1.181e+08 ~ 0%     -55.1%   53044266 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  1.19e+08 ~ 3%     -55.0%   53536204 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 5.868e+08          -54.6%  2.666e+08       TOTAL numa-numastat.node1.local_node

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.155e+08 ~ 0%     -53.7%   53456917 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.182e+08 ~ 2%     -55.0%   53198862 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  1.16e+08 ~ 1%     -54.0%   53344345 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 1.181e+08 ~ 0%     -55.1%   53047677 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  1.19e+08 ~ 3%     -55.0%   53537244 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 5.868e+08          -54.6%  2.666e+08       TOTAL numa-numastat.node1.numa_hit

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      0.50 ~ 9%    +136.4%       1.19 ~ 3%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
      0.56 ~ 5%    +104.8%       1.14 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      1.06         +119.8%       2.33       TOTAL perf-profile.cpu-cycles.read_hpet.ktime_get.sched_clock_tick.scheduler_tick.update_process_times

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  48095138 ~ 3%     -52.6%   22780517 ~ 2%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  50143039 ~ 0%     -54.8%   22678551 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  62885916 ~ 2%     -50.1%   31389445 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  47567762 ~ 1%     -53.1%   22296735 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  49435123 ~ 2%     -54.5%   22476197 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  50429805 ~ 3%     -55.3%   22560307 ~ 2%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 308556783          -53.3%  144181753       TOTAL numa-vmstat.node0.numa_miss

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  48151365 ~ 3%     -52.6%   22813640 ~ 2%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  50198919 ~ 0%     -54.8%   22693477 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  62942247 ~ 2%     -50.0%   31445889 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  47623721 ~ 1%     -53.1%   22353526 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  49491732 ~ 2%     -54.5%   22532377 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  50485560 ~ 3%     -55.2%   22616231 ~ 2%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 308893545          -53.2%  144455141       TOTAL numa-vmstat.node0.numa_other

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 4.558e+08 ~ 3%     -52.0%  2.186e+08 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 4.674e+08 ~ 0%     -53.5%  2.175e+08 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 4.788e+08 ~ 0%     -54.8%  2.162e+08 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 4.472e+08 ~ 2%     -47.3%  2.356e+08 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 4.677e+08 ~ 1%     -53.4%  2.179e+08 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 4.771e+08 ~ 1%     -54.7%  2.159e+08 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 4.835e+08 ~ 1%     -54.9%   2.18e+08 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 3.278e+09          -53.0%   1.54e+09       TOTAL proc-vmstat.numa_local

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 4.558e+08 ~ 3%     -52.0%  2.186e+08 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 4.674e+08 ~ 0%     -53.5%  2.175e+08 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 4.788e+08 ~ 0%     -54.8%  2.162e+08 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 4.472e+08 ~ 2%     -47.3%  2.356e+08 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 4.677e+08 ~ 1%     -53.4%  2.179e+08 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 4.771e+08 ~ 1%     -54.7%  2.159e+08 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 4.835e+08 ~ 1%     -54.9%   2.18e+08 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 3.278e+09          -53.0%   1.54e+09       TOTAL proc-vmstat.numa_hit

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  87307833 ~ 2%     -52.6%   41414031 ~ 3%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  79958521 ~ 1%     -52.9%   37638054 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  81255755 ~ 0%     -53.6%   37722772 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  87440015 ~ 2%     -48.6%   44908141 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  78828004 ~ 1%     -52.9%   37099427 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  81029376 ~ 2%     -53.6%   37571414 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  80067455 ~ 2%     -52.5%   38004701 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 575886961          -52.4%  274358542       TOTAL numa-vmstat.node0.numa_local

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  87349825 ~ 2%     -52.6%   41428656 ~ 3%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  80014745 ~ 1%     -52.9%   37671175 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  81311633 ~ 0%     -53.6%   37737696 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  87496345 ~ 2%     -48.6%   44964584 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  78883959 ~ 1%     -52.9%   37156215 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  81085981 ~ 2%     -53.6%   37627592 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  80123207 ~ 2%     -52.5%   38060622 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 576265696          -52.3%  274646542       TOTAL numa-vmstat.node0.numa_hit

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.071e+08 ~ 4%     -49.2%   54398310 ~ 3%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.125e+08 ~ 0%     -52.6%   53361698 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.152e+08 ~ 1%     -54.0%   53022957 ~ 2%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.018e+08 ~ 3%     -44.8%   56194086 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.134e+08 ~ 1%     -52.3%   54100761 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  1.15e+08 ~ 2%     -53.9%   53017495 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 1.182e+08 ~ 1%     -54.5%   53767747 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 7.832e+08          -51.8%  3.779e+08       TOTAL numa-numastat.node2.local_node

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.071e+08 ~ 4%     -49.2%   54398623 ~ 3%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.125e+08 ~ 0%     -52.6%   53362847 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.152e+08 ~ 1%     -54.0%   53024012 ~ 2%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.018e+08 ~ 3%     -44.8%   56194881 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.134e+08 ~ 1%     -52.3%   54102880 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  1.15e+08 ~ 2%     -53.9%   53018701 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 1.182e+08 ~ 1%     -54.5%   53768794 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 7.832e+08          -51.8%  3.779e+08       TOTAL numa-numastat.node2.numa_hit

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  74131063 ~ 0%     -51.3%   36100047 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  75697120 ~ 1%     -51.9%   36439328 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  74602871 ~ 1%     -51.7%   36031716 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  75386707 ~ 1%     -51.9%   36236813 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  75049747 ~ 3%     -51.2%   36624834 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 374867510          -51.6%  181432739       TOTAL numa-vmstat.node1.numa_local

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.109e+08 ~ 0%     -52.6%   52585451 ~ 2%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.136e+08 ~ 1%     -51.9%   54646005 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.172e+08 ~ 0%     -53.4%   54667014 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.109e+08 ~ 1%     -47.3%   58515165 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.154e+08 ~ 1%     -52.3%   55022835 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 1.163e+08 ~ 2%     -53.5%   54050919 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 1.179e+08 ~ 2%     -53.7%   54601288 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 8.022e+08          -52.1%  3.841e+08       TOTAL numa-numastat.node3.local_node

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.109e+08 ~ 0%     -52.6%   52585708 ~ 2%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.136e+08 ~ 1%     -51.9%   54647144 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.172e+08 ~ 0%     -53.4%   54668098 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.109e+08 ~ 1%     -47.3%   58517028 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.154e+08 ~ 1%     -52.3%   55026288 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 1.163e+08 ~ 2%     -53.5%   54054438 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 1.179e+08 ~ 2%     -53.7%   54602308 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 8.022e+08          -52.1%  3.841e+08       TOTAL numa-numastat.node3.numa_hit

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  74146232 ~ 0%     -51.2%   36155968 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  75711789 ~ 1%     -51.8%   36495257 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  74619247 ~ 1%     -51.7%   36047630 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  75401720 ~ 1%     -51.9%   36252986 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  75075335 ~ 3%     -51.2%   36639687 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 374954324          -51.6%  181591529       TOTAL numa-vmstat.node1.numa_hit

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      0.53 ~ 9%    +108.1%       1.11 ~ 3%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
      0.58 ~ 5%     +87.4%       1.09 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      1.11          +97.3%       2.20       TOTAL perf-profile.cpu-cycles.read_hpet.ktime_get.tick_sched_timer.__run_hrtimer.hrtimer_interrupt

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  49841915 ~ 3%     -52.4%   23744572 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  42304074 ~ 1%     -46.7%   22558148 ~ 3%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  47288559 ~ 7%     -50.1%   23609167 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 139434548          -49.9%   69911887       TOTAL proc-vmstat.pgrefill_dma32

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  79009689 ~ 6%     +90.3%  1.503e+08 ~ 3%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  79009689          +90.3%  1.503e+08       TOTAL proc-vmstat.pgsteal_kswapd_normal

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  79013369 ~ 6%     +90.3%  1.503e+08 ~ 3%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  79013369          +90.3%  1.503e+08       TOTAL proc-vmstat.pgscan_kswapd_normal

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  76716612 ~ 1%     -47.1%   40547248 ~ 2%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  73094331 ~ 1%     -49.5%   36876144 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  74967377 ~ 0%     -50.1%   37380767 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  77721956 ~ 2%     -42.6%   44623929 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  73837089 ~ 0%     -50.0%   36938585 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  74357992 ~ 2%     -50.4%   36870593 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  74088721 ~ 1%     -49.6%   37377389 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 524784079          -48.4%  270614657       TOTAL numa-vmstat.node3.numa_local

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  76786167 ~ 1%     -47.1%   40616706 ~ 2%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  73164578 ~ 1%     -49.5%   36946312 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  75037254 ~ 0%     -50.1%   37450866 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  77792595 ~ 2%     -42.5%   44694549 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  73907932 ~ 0%     -49.9%   37009959 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  74429457 ~ 2%     -50.4%   36941966 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  74158434 ~ 1%     -49.5%   37447354 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 525276420          -48.4%  271107715       TOTAL numa-vmstat.node3.numa_hit

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  74584929 ~ 3%     -44.0%   41798884 ~ 4%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  72590121 ~ 0%     -50.3%   36058819 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  73673221 ~ 1%     -50.4%   36577740 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  71918152 ~ 3%     -40.2%   43028418 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  72952233 ~ 0%     -50.0%   36440162 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  73412623 ~ 2%     -50.8%   36149219 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  74169375 ~ 2%     -50.4%   36795263 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 513300657          -48.0%  266848506       TOTAL numa-vmstat.node2.numa_local

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  74654623 ~ 3%     -43.9%   41868664 ~ 4%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  72660388 ~ 0%     -50.3%   36110667 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  73743281 ~ 1%     -50.3%   36647767 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  71989282 ~ 3%     -40.1%   43098345 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  73023843 ~ 0%     -50.0%   36510619 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  73483883 ~ 2%     -50.7%   36219343 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  74228290 ~ 2%     -50.3%   36865360 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 513783592          -48.0%  267320767       TOTAL numa-vmstat.node2.numa_hit

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 6.176e+08 ~ 2%     -44.3%   3.44e+08 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 6.097e+08 ~ 0%     -46.6%  3.258e+08 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 6.326e+08 ~ 0%     -48.7%  3.243e+08 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 6.077e+08 ~ 2%     -39.7%  3.663e+08 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 6.131e+08 ~ 2%     -46.8%   3.26e+08 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 6.301e+08 ~ 2%     -48.6%  3.237e+08 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 6.414e+08 ~ 2%     -49.3%  3.251e+08 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 4.352e+09          -46.3%  2.335e+09       TOTAL proc-vmstat.pgfree

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      3.93 ~ 1%     -47.3%       2.07 ~ 7%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      3.93          -47.3%       2.07       TOTAL perf-profile.cpu-cycles.do_mpage_readpage.mpage_readpages.xfs_vm_readpages.__do_page_cache_readahead.ra_submit

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      3.88 ~ 3%     -42.4%       2.23 ~ 3%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
      3.88          -42.4%       2.23       TOTAL perf-profile.cpu-cycles.do_mpage_readpage.mpage_readpages.ext4_readpages.__do_page_cache_readahead.ra_submit

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
       828 ~ 2%     -52.5%        393 ~ 6%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
       743 ~ 2%     -44.3%        413 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
       728 ~ 4%     -30.3%        508 ~ 4%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
      2299          -42.8%       1315       TOTAL proc-vmstat.compact_stall

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 5.272e+08 ~ 0%     -43.1%  2.998e+08 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 5.485e+08 ~ 0%     -45.6%  2.983e+08 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 5.137e+08 ~ 2%     -34.7%  3.354e+08 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
   5.3e+08 ~ 2%     -43.4%  3.001e+08 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 5.465e+08 ~ 2%     -45.5%  2.978e+08 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  5.55e+08 ~ 2%     -46.1%  2.989e+08 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 3.221e+09          -43.2%   1.83e+09       TOTAL proc-vmstat.pgalloc_normal

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
    627295 ~ 1%     -33.7%     415654 ~ 3%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
    696283 ~ 0%     -39.7%     419538 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
    726880 ~ 1%     -39.3%     441395 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
    621933 ~ 2%     -35.2%     403005 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
    696893 ~ 1%     -39.7%     420411 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
    723556 ~ 1%     -40.5%     430350 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
    744013 ~ 1%     -40.9%     439561 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
   4836856          -38.6%    2969917       TOTAL softirqs.RCU

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  49467746 ~ 3%     -39.6%   29860477 ~ 4%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  43017846 ~ 2%     -34.7%   28082427 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  45597759 ~ 3%     -37.5%   28494510 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  44537606 ~ 4%     -36.5%   28271416 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  46158212 ~ 0%     -40.3%   27537130 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 228779171          -37.8%  142245961       TOTAL numa-numastat.node1.numa_foreign

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
    856198 ~19%     +82.0%    1558017 ~ 5%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
    856198          +82.0%    1558017       TOTAL proc-vmstat.pgsteal_kswapd_dma32

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
    856230 ~19%     +82.0%    1558036 ~ 5%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
    856230          +82.0%    1558036       TOTAL proc-vmstat.pgscan_kswapd_dma32

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  41060785 ~ 0%     -35.7%   26401827 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  41060785          -35.7%   26401827       TOTAL numa-numastat.node3.numa_foreign

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  19700847 ~ 6%     +70.9%   33665538 ~11%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  19700847          +70.9%   33665538       TOTAL numa-numastat.node1.numa_miss

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  19701101 ~ 6%     +70.9%   33665824 ~11%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  19701101          +70.9%   33665824       TOTAL numa-numastat.node1.other_node

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  39386270 ~ 1%     -30.8%   27260690 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  42069415 ~ 1%     -36.9%   26557244 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  48316406 ~ 3%     -27.8%   34894046 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  39687408 ~ 2%     -32.7%   26705161 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  42109966 ~ 2%     -35.6%   27108368 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  42093581 ~ 3%     -36.1%   26915182 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
 253663047          -33.2%  169440693       TOTAL numa-numastat.node2.numa_foreign

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  32720191 ~ 3%     -34.7%   21367538 ~ 5%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  26057166 ~ 3%     -31.7%   17784379 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  27799346 ~ 3%     -34.4%   18230046 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  27070838 ~ 5%     -33.9%   17898870 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 113647542          -33.8%   75280835       TOTAL numa-vmstat.node1.numa_foreign

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  23761122 ~ 3%     -27.9%   17141955 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  25754254 ~ 2%     -34.4%   16889730 ~ 2%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  24282521 ~ 2%     -31.0%   16764287 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  73797899          -31.2%   50795973       TOTAL numa-vmstat.node2.numa_foreign

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  23160052 ~ 4%     -27.9%   16688396 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  25096981 ~ 0%     -33.2%   16768470 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  48257034          -30.7%   33456866       TOTAL numa-vmstat.node3.numa_foreign

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  13592587 ~ 5%     +80.4%   24518680 ~13%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  13781233 ~ 0%     +13.5%   15636441 ~ 2%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  27373821          +46.7%   40155121       TOTAL numa-vmstat.node1.numa_other

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  13564435 ~ 5%     +80.3%   24463313 ~13%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  13766562 ~ 0%     +13.2%   15580509 ~ 2%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  27330997          +46.5%   40043822       TOTAL numa-vmstat.node1.numa_miss

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 4.329e+08 ~ 5%     -31.4%  2.971e+08 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 4.092e+08 ~ 9%     -27.4%  2.969e+08 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 8.421e+08          -29.5%   5.94e+08       TOTAL proc-vmstat.pgdeactivate

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  4.48e+08 ~ 5%     -30.3%  3.123e+08 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 4.244e+08 ~ 8%     -26.4%  3.122e+08 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 8.724e+08          -28.4%  6.245e+08       TOTAL proc-vmstat.pgactivate

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.617e+08 ~ 0%     -22.5%  1.253e+08 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.422e+08 ~ 2%     -23.9%  1.082e+08 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.537e+08 ~ 1%     -29.7%   1.08e+08 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.605e+08 ~ 0%     -18.6%  1.307e+08 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.529e+08 ~ 3%     -29.6%  1.077e+08 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  7.71e+08          -24.8%  5.799e+08       TOTAL proc-vmstat.numa_miss

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.617e+08 ~ 0%     -22.5%  1.253e+08 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.422e+08 ~ 2%     -23.9%  1.082e+08 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.537e+08 ~ 1%     -29.7%   1.08e+08 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.605e+08 ~ 0%     -18.6%  1.307e+08 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.529e+08 ~ 3%     -29.6%  1.077e+08 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  7.71e+08          -24.8%  5.799e+08       TOTAL proc-vmstat.numa_foreign

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.617e+08 ~ 0%     -22.5%  1.253e+08 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.422e+08 ~ 2%     -23.9%  1.082e+08 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.537e+08 ~ 1%     -29.7%   1.08e+08 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.605e+08 ~ 0%     -18.6%  1.307e+08 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.529e+08 ~ 3%     -29.6%  1.077e+08 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  7.71e+08          -24.8%  5.799e+08       TOTAL proc-vmstat.numa_other

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
   4165558 ~ 0%     -26.1%    3076451 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
   3838755 ~ 1%     -23.3%    2943713 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
   3812731 ~ 0%     -22.5%    2953906 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
   4312133 ~ 1%     -24.2%    3268580 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
   3904377 ~ 2%     -23.4%    2992387 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
   3883567 ~ 0%     -22.4%    3012952 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
   3722419 ~ 0%     -20.1%    2975619 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
  27639542          -23.2%   21223611       TOTAL proc-vmstat.pgfault

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  12548911 ~ 2%     +31.1%   16451571 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  12548911          +31.1%   16451571       TOTAL numa-vmstat.node0.numa_foreign

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 3.619e+08 ~ 9%     -24.5%  2.733e+08 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 3.619e+08          -24.5%  2.733e+08       TOTAL proc-vmstat.pgrefill_normal

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     17896 ~ 5%     -21.1%      14125 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
     17896          -21.1%      14125       TOTAL uptime.idle

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
   6466452 ~ 5%     +30.4%    8430018 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
   4928982 ~ 2%     +17.3%    5781355 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  11395434          +24.7%   14211373       TOTAL numa-meminfo.node0.MemFree

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  21181569 ~ 3%     +23.4%   26145811 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  21181569          +23.4%   26145811       TOTAL numa-numastat.node0.numa_foreign

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  20506164 ~ 5%     -20.2%   16357450 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  20579951 ~ 1%     -16.7%   17143898 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  41086115          -18.5%   33501349       TOTAL vmstat.memory.free

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
   6551320 ~ 4%     +26.3%    8276306 ~ 5%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
   6551320          +26.3%    8276306       TOTAL numa-meminfo.node1.MemFree

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
       598 ~ 0%     +23.7%        740 ~ 4%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
       598          +23.7%        740       TOTAL proc-vmstat.kswapd_low_wmark_hit_quickly

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
   7099382 ~ 2%     +22.5%    8697177 ~ 3%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
   7099382          +22.5%    8697177       TOTAL numa-meminfo.node2.MemFree

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      2637 ~ 0%     -12.9%       2296 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
      2637          -12.9%       2296       TOTAL proc-vmstat.pgpgout

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     30033 ~ 1%     -13.7%      25904 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
     30033          -13.7%      25904       TOTAL numa-vmstat.node0.nr_slab_reclaimable

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
    120327 ~ 1%     -13.8%     103668 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
    120327          -13.8%     103668       TOTAL numa-meminfo.node0.SReclaimable

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
    479277 ~ 5%     -87.3%      60940 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
    373524 ~ 2%     -86.9%      48773 ~ 2%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
    449659 ~ 8%     -86.9%      58694 ~ 5%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
   1302461          -87.1%     168408       TOTAL time.voluntary_context_switches

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
   2106711 ~ 2%     -74.7%     532547 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
   1991668 ~ 0%     -73.7%     522959 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
   2242015 ~ 3%     -68.6%     703493 ~ 4%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
   2081024 ~ 2%     -74.8%     523569 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
   1936544 ~ 6%     -72.8%     526416 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
   1999446 ~ 6%     -73.1%     537069 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
  12357409          -72.9%    3346054       TOTAL time.involuntary_context_switches

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
   3298565 ~ 2%     -73.5%     873685 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
   3032872 ~ 0%     -71.9%     852607 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
   3413724 ~ 4%     -63.6%    1243241 ~ 4%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
   3236238 ~ 3%     -73.3%     862842 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
   2973889 ~ 7%     -71.4%     849866 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  15955289          -70.7%    4682242       TOTAL perf-stat.context-switches

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      8103 ~ 1%     -70.3%       2408 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
      7472 ~ 0%     -68.8%       2332 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
      7166 ~ 2%     -59.7%       2885 ~ 6%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
      7880 ~ 1%     -69.8%       2382 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
      7774 ~ 7%     -70.1%       2322 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
     38397          -67.9%      12332       TOTAL vmstat.system.cs

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 4.538e+09 ~ 2%     -66.1%  1.536e+09 ~ 6%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 5.524e+09 ~ 0%     -60.2%  2.196e+09 ~ 9%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 5.233e+09 ~ 6%     -69.7%  1.584e+09 ~12%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 1.529e+10          -65.2%  5.317e+09       TOTAL perf-stat.dTLB-store-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 5.615e+09 ~ 2%     -61.9%  2.138e+09 ~ 3%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 5.615e+09          -61.9%  2.138e+09       TOTAL perf-stat.branch-load-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.377e+10 ~ 1%     -54.1%  6.315e+09 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.393e+10 ~ 1%     -53.8%  6.432e+09 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.336e+10 ~ 1%     -47.9%  6.957e+09 ~ 3%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.407e+10 ~ 4%     -52.5%  6.689e+09 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.433e+10 ~ 2%     -56.0%  6.309e+09 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 1.337e+10 ~ 1%     -48.4%  6.903e+09 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 8.283e+10          -52.2%  3.961e+10       TOTAL perf-stat.L1-icache-load-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  7.89e+09 ~ 2%     -47.0%  4.182e+09 ~ 2%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 5.079e+09 ~ 1%     -42.7%   2.91e+09 ~13%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 8.026e+09 ~ 4%     -60.3%  3.189e+09 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
   2.1e+10          -51.0%  1.028e+10       TOTAL perf-stat.branch-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
  4.67e+10 ~ 2%     -45.3%  2.554e+10 ~ 2%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 5.371e+10 ~ 0%     -49.6%  2.707e+10 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 5.494e+10 ~ 1%     -51.2%  2.681e+10 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 4.633e+10 ~ 2%     -41.1%  2.727e+10 ~ 3%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 5.362e+10 ~ 1%     -50.1%  2.673e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 5.463e+10 ~ 1%     -49.9%  2.738e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 3.099e+11          -48.1%  1.608e+11       TOTAL perf-stat.LLC-stores

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 9.659e+09 ~ 4%     -57.0%  4.154e+09 ~ 5%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 6.466e+09 ~ 1%     -32.9%  4.342e+09 ~ 5%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.613e+10          -47.3%  8.496e+09       TOTAL perf-stat.node-prefetch-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 4.745e+10 ~ 1%     -41.6%  2.773e+10 ~ 3%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 6.099e+10 ~ 1%     -48.9%  3.117e+10 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 6.303e+10 ~ 1%     -50.6%  3.113e+10 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
  4.73e+10 ~ 1%     -37.7%  2.945e+10 ~ 3%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 6.063e+10 ~ 0%     -48.3%  3.137e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 6.277e+10 ~ 0%     -48.3%  3.243e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 3.422e+11          -46.4%  1.833e+11       TOTAL perf-stat.L1-dcache-store-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 3.143e+10 ~ 0%     -42.8%  1.797e+10 ~ 2%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 3.468e+10 ~ 0%     -46.9%  1.842e+10 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
  3.68e+10 ~ 0%     -49.7%  1.852e+10 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 3.128e+10 ~ 3%     -39.7%  1.886e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 3.502e+10 ~ 3%     -46.6%  1.868e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 3.736e+10 ~ 5%     -50.4%  1.851e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 2.066e+11          -46.3%   1.11e+11       TOTAL perf-stat.LLC-store-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 3.088e+10 ~ 1%     -43.3%   1.75e+10 ~ 2%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
  3.36e+10 ~ 1%     -44.1%  1.879e+10 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 3.613e+10 ~ 1%     -48.6%  1.857e+10 ~ 2%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 2.989e+10 ~ 0%     -39.0%  1.823e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  3.53e+10 ~ 4%     -48.1%  1.831e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 3.621e+10 ~ 3%     -49.0%  1.846e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  2.02e+11          -45.6%  1.099e+11       TOTAL perf-stat.node-stores

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
       296 ~ 2%     -48.8%        151 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
       272 ~ 1%     -44.1%        152 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
       186 ~ 2%     -38.5%        114 ~ 3%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
       286 ~ 4%     -46.8%        152 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
       271 ~ 4%     -43.4%        153 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
       260 ~ 6%     -48.9%        133 ~ 1%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
      1573          -45.5%        857       TOTAL time.user_time

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.373e+10 ~ 5%     -55.4%   6.12e+09 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 8.102e+09 ~ 3%     -29.7%  5.697e+09 ~ 3%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 2.184e+10          -45.9%  1.182e+10       TOTAL perf-stat.LLC-prefetch-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.283e+10 ~ 4%     -53.0%  6.031e+09 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 9.084e+09 ~ 6%     -41.6%  5.304e+09 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 8.323e+09 ~ 8%     -37.1%  5.234e+09 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.353e+10 ~ 7%     -53.2%  6.335e+09 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 8.276e+09 ~ 6%     -31.4%  5.681e+09 ~ 2%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 5.204e+10          -45.1%  2.859e+10       TOTAL perf-stat.node-prefetches

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 5.805e+10 ~ 1%     -42.3%   3.35e+10 ~ 3%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 5.992e+10 ~ 2%     -44.9%  3.303e+10 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 5.917e+10 ~ 0%     -44.5%  3.282e+10 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 5.728e+10 ~ 1%     -37.8%  3.564e+10 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 5.896e+10 ~ 1%     -43.9%  3.308e+10 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 5.941e+10 ~ 0%     -43.8%   3.34e+10 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 3.528e+11          -42.9%  2.015e+11       TOTAL perf-stat.cache-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.514e+11 ~ 2%     -42.8%  8.666e+10 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.791e+11 ~ 0%     -44.6%   9.93e+10 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.774e+11 ~ 0%     -44.0%  9.943e+10 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.495e+11 ~ 2%     -38.3%  9.227e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.776e+11 ~ 0%     -43.9%  9.965e+10 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  1.78e+11 ~ 1%     -43.4%  1.007e+11 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 1.013e+12          -42.9%   5.78e+11       TOTAL perf-stat.L1-dcache-load-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 5.373e+10 ~ 3%     -41.8%  3.127e+10 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 5.373e+10          -41.8%  3.127e+10       TOTAL perf-stat.LLC-load-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 3.608e+10 ~ 4%     -45.0%  1.985e+10 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 4.242e+10 ~ 1%     -40.4%  2.527e+10 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 4.204e+10 ~ 0%     -40.0%  2.521e+10 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 3.574e+10 ~ 3%     -41.7%  2.082e+10 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 4.251e+10 ~ 1%     -41.5%  2.488e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
  4.13e+10 ~ 0%     -39.7%  2.492e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 2.401e+11          -41.3%  1.409e+11       TOTAL perf-stat.LLC-prefetches

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.187e+11 ~ 1%     -40.3%   7.08e+10 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.358e+11 ~ 1%     -42.3%  7.838e+10 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.346e+11 ~ 0%     -42.0%  7.804e+10 ~ 2%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.166e+11 ~ 1%     -36.7%  7.385e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.343e+11 ~ 0%     -42.6%  7.705e+10 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 1.339e+11 ~ 1%     -42.6%  7.691e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 7.739e+11          -41.2%   4.55e+11       TOTAL perf-stat.cache-references

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 5.357e+10 ~ 3%     -42.7%  3.069e+10 ~ 2%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 5.309e+10 ~ 3%     -38.0%  3.292e+10 ~ 2%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.067e+11          -40.4%  6.361e+10       TOTAL perf-stat.node-loads

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.414e+12 ~ 1%     -37.9%  8.779e+11 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.371e+12 ~ 1%     -42.2%  7.921e+11 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.388e+12 ~ 0%     -42.1%  8.041e+11 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.401e+12 ~ 1%     -33.5%  9.319e+11 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.363e+12 ~ 0%     -41.6%  7.952e+11 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 1.387e+12 ~ 0%     -41.9%  8.056e+11 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 8.323e+12          -39.8%  5.007e+12       TOTAL perf-stat.dTLB-stores

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.413e+12 ~ 1%     -37.6%  8.815e+11 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.371e+12 ~ 1%     -41.8%  7.977e+11 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.389e+12 ~ 0%     -41.9%  8.067e+11 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.398e+12 ~ 1%     -33.3%  9.329e+11 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.361e+12 ~ 0%     -41.5%  7.962e+11 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 1.385e+12 ~ 0%     -41.4%  8.112e+11 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 8.318e+12          -39.6%  5.026e+12       TOTAL perf-stat.L1-dcache-stores

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.812e+10 ~ 2%     -39.2%  1.102e+10 ~ 2%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.882e+10 ~ 2%     -37.7%  1.173e+10 ~ 2%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 2.022e+10 ~ 0%     -42.3%  1.167e+10 ~ 1%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.777e+10 ~ 2%     -36.3%  1.132e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 2.037e+10 ~ 4%     -42.1%   1.18e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  9.53e+10          -39.6%  5.754e+10       TOTAL perf-stat.node-store-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.049e+11 ~ 3%     -39.2%  6.379e+10 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 1.195e+11 ~ 1%     -38.8%  7.318e+10 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.157e+11 ~ 1%     -37.1%  7.278e+10 ~ 2%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.027e+11 ~ 2%     -33.3%  6.848e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 1.175e+11 ~ 2%     -37.2%  7.375e+10 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 1.146e+11 ~ 2%     -36.1%  7.317e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 6.748e+11          -37.0%  4.252e+11       TOTAL perf-stat.LLC-loads

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 3.551e+10 ~ 3%     -37.0%  2.239e+10 ~ 2%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 3.376e+10 ~ 1%     -36.2%  2.153e+10 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 3.479e+10 ~ 4%     -36.6%  2.206e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 1.041e+11          -36.6%  6.597e+10       TOTAL perf-stat.L1-dcache-prefetch-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 2.968e+12 ~ 0%     -33.9%  1.961e+12 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 2.655e+12 ~ 0%     -36.8%  1.678e+12 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 2.683e+12 ~ 0%     -36.4%  1.705e+12 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 2.947e+12 ~ 0%     -30.9%  2.036e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 2.653e+12 ~ 0%     -36.5%  1.685e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 2.681e+12 ~ 0%     -36.4%  1.705e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 1.659e+13          -35.1%  1.077e+13       TOTAL perf-stat.L1-dcache-loads

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 2.968e+12 ~ 0%     -33.7%  1.967e+12 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 2.661e+12 ~ 0%     -36.8%  1.682e+12 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 2.681e+12 ~ 0%     -36.7%  1.698e+12 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 2.952e+12 ~ 0%     -31.3%  2.028e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 2.655e+12 ~ 0%     -36.6%  1.683e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 2.681e+12 ~ 0%     -36.2%  1.711e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  1.66e+13          -35.1%  1.077e+13       TOTAL perf-stat.dTLB-loads

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.077e+13 ~ 0%     -32.7%  7.244e+12 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 9.512e+12 ~ 0%     -34.9%  6.196e+12 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 9.659e+12 ~ 0%     -35.0%   6.28e+12 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 1.073e+13 ~ 0%     -30.4%  7.467e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
  9.52e+12 ~ 0%     -34.6%  6.224e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 9.641e+12 ~ 0%     -34.7%  6.296e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 5.983e+13          -33.6%  3.971e+13       TOTAL perf-stat.instructions

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 2.434e+10 ~ 1%     -31.5%  1.667e+10 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 2.434e+10          -31.5%  1.667e+10       TOTAL perf-stat.node-load-misses

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 3.206e+12 ~ 0%     -31.4%  2.199e+12 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 2.825e+12 ~ 0%     -32.6%  1.905e+12 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 2.847e+12 ~ 0%     -32.4%  1.924e+12 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 3.198e+12 ~ 0%     -29.4%  2.258e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 2.828e+12 ~ 0%     -32.5%   1.91e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 2.857e+12 ~ 0%     -32.4%  1.931e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 1.776e+13          -31.7%  1.213e+13       TOTAL perf-stat.branch-instructions

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 3.206e+12 ~ 0%     -30.7%  2.221e+12 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
 2.831e+12 ~ 0%     -32.4%  1.914e+12 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 2.862e+12 ~ 0%     -32.4%  1.936e+12 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 3.198e+12 ~ 0%     -29.0%  2.272e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 2.838e+12 ~ 0%     -32.2%  1.923e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 2.857e+12 ~ 0%     -32.2%  1.937e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
 1.779e+13          -31.4%   1.22e+13       TOTAL perf-stat.branch-loads

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
   4094558 ~ 0%     -26.6%    3005776 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
   3766736 ~ 1%     -23.7%    2875755 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
   3741220 ~ 0%     -23.0%    2882527 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
   4234029 ~ 1%     -24.5%    3195492 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
   3827076 ~ 2%     -23.6%    2922931 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
   3804120 ~ 0%     -22.8%    2937076 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  23467741          -24.1%   17819558       TOTAL perf-stat.page-faults

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
   4094559 ~ 0%     -26.6%    3006105 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
   3767275 ~ 1%     -23.7%    2875756 ~ 1%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
   3741420 ~ 0%     -23.0%    2882528 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
   4234030 ~ 1%     -24.5%    3196091 ~ 1%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
   3827077 ~ 2%     -23.6%    2923015 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
   3804121 ~ 0%     -22.8%    2937190 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
  23468484          -24.1%   17820686       TOTAL perf-stat.minor-faults

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 4.192e+13 ~ 1%     +23.2%  5.163e+13 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 4.398e+13 ~ 0%     +17.5%  5.165e+13 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 5.066e+13 ~ 0%      +9.7%  5.559e+13 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 4.292e+13 ~ 2%     +20.5%  5.171e+13 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 1.795e+14          +17.3%  2.106e+14       TOTAL perf-stat.stalled-cycles-frontend

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     75149 ~ 1%     -14.2%      64444 ~ 1%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
     75149          -14.2%      64444       TOTAL vmstat.system.in

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 4.889e+13 ~ 1%     +15.7%  5.657e+13 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 5.098e+13 ~ 0%     +10.7%  5.645e+13 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
 5.708e+13 ~ 0%      +5.7%  6.033e+13 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
 4.975e+13 ~ 2%     +13.5%  5.645e+13 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 2.067e+14          +11.2%  2.298e+14       TOTAL perf-stat.cpu-cycles

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
       405 ~ 0%      -6.1%        381 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
       410 ~ 2%      -7.9%        378 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
       409 ~ 0%      -6.4%        383 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
      1225           -6.8%       1142       TOTAL time.elapsed_time

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
      8714 ~ 0%      +3.6%       9026 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
      8610 ~ 2%      +5.6%       9089 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
      8622 ~ 0%      +3.9%       8958 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
     25947           +4.3%      27074       TOTAL time.percent_of_cpu_this_job_got

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
     34948 ~ 0%      -2.4%      34092 ~ 0%  brickland2/debug/vm-scalability/300s-btrfs-lru-file-readtwice
     35007 ~ 0%      -2.2%      34231 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
     35077 ~ 0%      -2.4%      34241 ~ 0%  brickland2/debug/vm-scalability/300s-xfs-lru-file-readtwice
     34976 ~ 0%      -2.6%      34054 ~ 0%  brickland2/debug2/vm-scalability/300s-btrfs-lru-file-readtwice
     35054 ~ 0%      -2.4%      34222 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
     35056 ~ 0%      -2.4%      34224 ~ 0%  brickland2/debug2/vm-scalability/300s-xfs-lru-file-readtwice
     35106 ~ 0%      -2.4%      34268 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
    245227           -2.4%     239334       TOTAL time.system_time

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 3.651e+12 ~ 0%      -0.6%  3.627e+12 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 3.651e+12           -0.6%  3.627e+12       TOTAL perf-stat.bus-cycles

1d3d4437eae1bb2  9b17c62382dd2e7507984b989  
---------------  -------------------------  
 1.021e+14 ~ 0%      -0.7%  1.014e+14 ~ 0%  brickland2/debug/vm-scalability/300s-ext4-lru-file-readtwice
 1.021e+14 ~ 0%      -0.6%  1.015e+14 ~ 0%  brickland2/debug2/vm-scalability/300s-ext4-lru-file-readtwice
 2.042e+14           -0.7%  2.029e+14       TOTAL perf-stat.ref-cycles


--jI8keyz6grp/JLjh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
