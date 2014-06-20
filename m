Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1C36B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 02:47:59 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so2774439pab.16
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 23:47:59 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id hq3si8632551pad.87.2014.06.19.23.47.57
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 23:47:58 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFCv2 0/3] free reclaimed pages by paging out instantly
Date: Fri, 20 Jun 2014 15:48:29 +0900
Message-Id: <1403246912-18237-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>

Normally, I/O completed pages for reclaim would be rotated into
inactive LRU tail without freeing. The why it works is we can't free
page from atomic context(ie, end_page_writeback) due to vaious locks
isn't aware of atomic context.

So for reclaiming the I/O completed pages, we need one more iteration
of reclaim and it could make unnecessary aging as well as CPU overhead.

Long time ago, at the first trial, most concern was memcg locking
but recently, Johnannes tried amazing effort to make memcg lock simple[1]
so I coded up this again based on his patchset.(Kudos to Johannes)

[1] mm: memcontrol: naturalize charge lifetime v3
    https://lkml.org/lkml/2014/6/18/631

So, this patchset should go after [1] but not bad timing to prove
that how [1] make mm simple so that we can go further like this.

On 1G, 12 CPU kvm guest, build kernel 5 times and result.

Most of field isn't changed too much but one thing I can notice is
allocstall and pgrotated.
We could save direct reclaim 50% and page rotation 96%.
Yay!

Welcome testing, review and any feedback!

git clone -b mm/mm/asap_reclaim-v1r3 --single-branch git://git.kernel.org/pub/scm/linux/kernel/git/minchan/linux.git


TITLE                                      OLD             NEW            DIFF (RATIO)
nr_free_pages                          -79,600         -85,018          -5,418 (106.81)
nr_alloc_batch                            -532              64             596 (-12.24)
nr_inactive_anon                         1,601           1,913             312 (119.48)
nr_active_anon                         -66,021         -64,913           1,108 (98.32)
nr_inactive_file                        25,921          29,974           4,053 (115.64)
nr_active_file                         112,575         112,604              29 (100.03)
nr_unevictable                               0               0               0 (100.00)
nr_mlock                                     0               0               0 (100.00)
nr_anon_pages                          -63,698         -62,601           1,097 (98.28)
nr_mapped                              -31,818         -32,657            -839 (102.64)
nr_file_pages                          139,336         143,684           4,348 (103.12)
nr_dirty                                 9,741           9,332            -409 (95.80)
nr_writeback                                 0               0               0 (100.00)
nr_slab_reclaimable                      3,453           2,969            -484 (85.99)
nr_slab_unreclaimable                    1,348           1,503             155 (111.49)
nr_page_table_pages                        303             169            -134 (55.92)
nr_kernel_stack                              5              18              13 (316.67)
nr_unstable                                  0               0               0 (100.00)
nr_bounce                                    0               0               0 (100.00)
nr_vmscan_write                      2,347,178       2,475,802         128,624 (105.48)
nr_vmscan_immediate_reclaim             21,292          18,863          -2,429 (88.59)
nr_writeback_temp                            0               0               0 (100.00)
nr_isolated_anon                             0               0               0 (100.00)
nr_isolated_file                             0               0               0 (100.00)
nr_shmem                                  -940            -940               0 (100.00)
nr_dirtied                           9,059,820       9,055,880          -3,940 (99.96)
nr_written                          10,721,761      10,875,384         153,623 (101.43)
numa_hit                           667,598,890     667,289,491        -309,399 (99.95)
numa_miss                                    0               0               0 (100.00)
numa_foreign                                 0               0               0 (100.00)
numa_interleave                              0               0               0 (100.00)
numa_local                         667,598,890     667,289,491        -309,399 (99.95)
numa_other                                   0               0               0 (100.00)
workingset_refault                   6,843,535       6,953,675         110,140 (101.61)
workingset_activate                    500,648         462,529         -38,119 (92.39)
workingset_nodereclaim                  13,696          12,420          -1,276 (90.68)
nr_anon_transparent_hugepages                0               0               0 (100.00)
nr_free_cma                                  0               0               0 (100.00)
nr_dirty_threshold                       5,890           5,756            -134 (97.73)
nr_dirty_background_threshold            2,945           2,878             -67 (97.73)
pgpgin                              40,253,436      40,048,188        -205,248 (99.49)
pgpgout                             43,348,244      43,949,700         601,456 (101.39)
pswpin                               1,341,538       1,341,174            -364 (99.97)
pswpout                              2,238,838       2,401,758         162,920 (107.28)
pgalloc_dma                          8,107,785       8,658,979         551,194 (106.80)
pgalloc_dma32                      662,079,225     661,199,629        -879,596 (99.87)
pgalloc_normal                               0               0               0 (100.00)
pgalloc_movable                              0               0               0 (100.00)
pgfree                             670,107,583     669,774,227        -333,356 (99.95)
pgactivate                           6,644,334       6,643,232          -1,102 (99.98)
pgdeactivate                        12,717,804      12,591,803        -126,001 (99.01)
pgfault                            720,714,051     720,522,028        -192,023 (99.97)
pgmajfault                             293,791         300,790           6,999 (102.38)
pgrefill_dma                           339,536         357,065          17,529 (105.16)
pgrefill_dma32                      13,042,608      12,882,276        -160,332 (98.77)
pgrefill_normal                              0               0               0 (100.00)
pgrefill_movable                             0               0               0 (100.00)
pgsteal_kswapd_dma                     176,437         182,289           5,852 (103.32)
pgsteal_kswapd_dma32                17,820,059      15,877,438      -1,942,621 (89.10)
pgsteal_kswapd_normal                        0               0               0 (100.00)
pgsteal_kswapd_movable                       0               0               0 (100.00)
pgsteal_direct_dma                          30              63              33 (206.45)
pgsteal_direct_dma32                   388,468         208,411        -180,057 (53.65)
pgsteal_direct_normal                        0               0               0 (100.00)
pgsteal_direct_movable                       0               0               0 (100.00)
pgscan_kswapd_dma                      190,486         199,076           8,590 (104.51)
pgscan_kswapd_dma32                 22,002,203      20,034,956      -1,967,247 (91.06)
pgscan_kswapd_normal                         0               0               0 (100.00)
pgscan_kswapd_movable                        0               0               0 (100.00)
pgscan_direct_dma                           45             175             130 (382.61)
pgscan_direct_dma32                    722,765         714,866          -7,899 (98.91)
pgscan_direct_normal                         0               0               0 (100.00)
pgscan_direct_movable                        0               0               0 (100.00)
pgscan_direct_throttle                       0               0               0 (100.00)
zone_reclaim_failed                          0               0               0 (100.00)
pginodesteal                                 0               0               0 (100.00)
slabs_scanned                        3,537,255       3,580,408          43,153 (101.22)
kswapd_inodesteal                          374               0            -374 (0.27)
kswapd_low_wmark_hit_quickly             2,485           2,528              43 (101.73)
kswapd_high_wmark_hit_quickly            1,078             728            -350 (67.56)
pageoutrun                               4,652           4,346            -306 (93.42)
allocstall                               8,312           4,524          -3,788 (54.43)
pgrotated                            2,205,712          86,860      -2,118,852 (3.94)
drop_pagecache                               0               0               0 (100.00)
drop_slab                                    0               0               0 (100.00)
pgmigrate_success                            0               0               0 (100.00)
pgmigrate_fail                               0               0               0 (100.00)
compact_migrate_scanned                      0               0               0 (100.00)
compact_free_scanned                         0               0               0 (100.00)
compact_isolated                             0               0               0 (100.00)
compact_stall                                7               6              -1 (87.50)
compact_fail                                 7               6              -1 (87.50)
compact_success                              0               0               0 (100.00)
htlb_buddy_alloc_success                     0               0               0 (100.00)
htlb_buddy_alloc_fail                        0               0               0 (100.00)
unevictable_pgs_culled                       0               0               0 (100.00)
unevictable_pgs_scanned                      0               0               0 (100.00)
unevictable_pgs_rescued                      0               0               0 (100.00)
unevictable_pgs_mlocked                      0               0               0 (100.00)
unevictable_pgs_munlocked                    0               0               0 (100.00)
unevictable_pgs_cleared                      0               0               0 (100.00)
unevictable_pgs_stranded                     0               0               0 (100.00)
thp_fault_alloc                              0               0               0 (100.00)
thp_fault_fallback                           0               0               0 (100.00)
thp_collapse_alloc                           0               0               0 (100.00)
thp_collapse_alloc_failed                    0               0               0 (100.00)
thp_split                                    0               0               0 (100.00)
thp_zero_page_alloc                          0               0               0 (100.00)
thp_zero_page_alloc_failed                   0               0               0 (100.00)


Minchan Kim (3):
  mm: Don't hide spin_lock in swap_info_get internal
  mm: Introduce atomic_remove_mapping
  mm: Free reclaimed pages indepdent of next reclaim

 include/linux/swap.h |  4 ++++
 mm/filemap.c         | 17 +++++++++-----
 mm/swap.c            | 21 ++++++++++++++++++
 mm/swapfile.c        | 17 ++++++++++++--
 mm/vmscan.c          | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 114 insertions(+), 8 deletions(-)

-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
