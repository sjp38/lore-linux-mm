Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 1C84B6B004D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 05:27:36 -0400 (EDT)
Date: Mon, 23 Apr 2012 10:27:30 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Over-eager swapping
Message-ID: <20120423092730.GB20543@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Chris Webb <chris@arachsys.com>

We run a number of relatively large x86-64 hosts with twenty or so qemu-kvm
virtual machines on each of them, and I'm have some trouble with over-eager
swapping on some of the machines. This is resulting in load spikes during the
swapping and customer reports of very poor response latency from the virtual
machines which have been swapped out, despite the hosts apparently having
large amounts of free memory, and running fine if swap is turned off.


All of the hosts are currently running a 3.1.4 or 3.2.2 kernel and have ksm
enabled with 64GB of RAM and 2x eight-core AMD Opteron 6128 processors.
However, we have seen this same problem since 2010 on a 2.6.32.7 kernel and
older hardware - see http://marc.info/?l=linux-mm&m=128075337008943
(previous helpful contributors cc:ed here - thanks).

We have /proc/sys/vm/swappiness set to 0. The kernel config is here:
http://users.org.uk/config-3.1.4


The rrd graphs at http://imgur.com/a/Fklxr show a typical incident.

We estimate memory used from /proc/meminfo as:

  = MemTotal - MemFree - Buffers + SwapTotal - SwapFree

The first rrd shows memory used increasing as a VM starts, but not getting
near the 64GB of physical RAM.

The second rrd shows the heavy swapping this VM start caused.

The third rrd shows a multi-gigabyte jump in swap used = SwapTotal - SwapFree

The fourth rrd shows the large load spike (from 1 to 15) caused by this swap
storm.


It is obviously hard to capture all of the relevant data actually during an
incident. However, as of this morning, the relevant stats are as below.

Any help much appreciated! Our strong belief is that there is unnecessary
swapping going on here, and causing these load spikes. We would like to run
with swap for real out-of-memory situations, but at present it is causing
these kind of load spikes on machines which run completely happily with swap
disabled.

Thanks,

Richard.


# cat /proc/meminfo
MemTotal:       65915384 kB
MemFree:          271104 kB
Buffers:        36274368 kB
Cached:            31048 kB
SwapCached:      1830860 kB
Active:         30594144 kB
Inactive:       32295972 kB
Active(anon):   21883428 kB
Inactive(anon):  4695308 kB
Active(file):    8710716 kB
Inactive(file): 27600664 kB
Unevictable:        6740 kB
Mlocked:            6740 kB
SwapTotal:      33054708 kB
SwapFree:       30067948 kB
Dirty:              1044 kB
Writeback:             0 kB
AnonPages:      24962708 kB
Mapped:             7320 kB
Shmem:                48 kB
Slab:            2210964 kB
SReclaimable:    1013272 kB
SUnreclaim:      1197692 kB
KernelStack:        6816 kB
PageTables:       129248 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    66012400 kB
Committed_AS:   67375852 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      259380 kB
VmallocChunk:   34308695568 kB
HardwareCorrupted:     0 kB
AnonHugePages:    155648 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:         576 kB
DirectMap2M:     2095104 kB
DirectMap1G:    65011712 kB

# cat /proc/sys/vm/zone_reclaim_mode
0

# cat /proc/sys/vm/min_unmapped_ratio
1

# cat /proc/slabinfo
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
ext4_groupinfo_1k     32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
RAWv6                 34     34    960   34    8 : tunables    0    0    0 : slabdata      1      1      0
UDPLITEv6              0      0    960   34    8 : tunables    0    0    0 : slabdata      0      0      0
UDPv6                544    544    960   34    8 : tunables    0    0    0 : slabdata     16     16      0
tw_sock_TCPv6          0      0    320   25    2 : tunables    0    0    0 : slabdata      0      0      0
TCPv6                 72     72   1728   18    8 : tunables    0    0    0 : slabdata      4      4      0
nf_conntrack_expect    592    592    216   37    2 : tunables    0    0    0 : slabdata     16     16      0
nf_conntrack_ffffffff8199a280    933   1856    280   29    2 : tunables    0    0    0 : slabdata     64     64      0
dm_raid1_read_record      0      0   1064   30    8 : tunables    0    0    0 : slabdata      0      0      0
dm_snap_pending_exception      0      0    104   39    1 : tunables    0    0    0 : slabdata      0      0      0
dm_crypt_io         1811   2574    152   26    1 : tunables    0    0    0 : slabdata     99     99      0
kcopyd_job             0      0   3240   10    8 : tunables    0    0    0 : slabdata      0      0      0
dm_uevent              0      0   2608   12    8 : tunables    0    0    0 : slabdata      0      0      0
cfq_queue              0      0    232   35    2 : tunables    0    0    0 : slabdata      0      0      0
bsg_cmd                0      0    312   26    2 : tunables    0    0    0 : slabdata      0      0      0
mqueue_inode_cache     36     36    896   36    8 : tunables    0    0    0 : slabdata      1      1      0
udf_inode_cache        0      0    656   24    4 : tunables    0    0    0 : slabdata      0      0      0
fuse_request           0      0    608   26    4 : tunables    0    0    0 : slabdata      0      0      0
fuse_inode             0      0    704   46    8 : tunables    0    0    0 : slabdata      0      0      0
ntfs_big_inode_cache      0      0    832   39    8 : tunables    0    0    0 : slabdata      0      0      0
ntfs_inode_cache       0      0    280   29    2 : tunables    0    0    0 : slabdata      0      0      0
isofs_inode_cache      0      0    600   27    4 : tunables    0    0    0 : slabdata      0      0      0
fat_inode_cache        0      0    664   24    4 : tunables    0    0    0 : slabdata      0      0      0
fat_cache              0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
hugetlbfs_inode_cache     28     28    568   28    4 : tunables    0    0    0 : slabdata      1      1      0
squashfs_inode_cache      0      0    640   25    4 : tunables    0    0    0 : slabdata      0      0      0
jbd2_journal_handle   2720   2720     24  170    1 : tunables    0    0    0 : slabdata     16     16      0
jbd2_journal_head    818   1620    112   36    1 : tunables    0    0    0 : slabdata     45     45      0
jbd2_revoke_record   2048   4096     32  128    1 : tunables    0    0    0 : slabdata     32     32      0
ext4_inode_cache    2754   5328    864   37    8 : tunables    0    0    0 : slabdata    144    144      0
ext4_xattr             0      0     88   46    1 : tunables    0    0    0 : slabdata      0      0      0
ext4_free_data      1168   2628     56   73    1 : tunables    0    0    0 : slabdata     36     36      0
ext4_allocation_context    540    540    136   30    1 : tunables    0    0    0 : slabdata     18     18      0
ext4_io_end            0      0   1128   29    8 : tunables    0    0    0 : slabdata      0      0      0
ext4_io_page         256    256     16  256    1 : tunables    0    0    0 : slabdata      1      1      0
configfs_dir_cache      0      0     88   46    1 : tunables    0    0    0 : slabdata      0      0      0
kioctx                 0      0    384   42    4 : tunables    0    0    0 : slabdata      0      0      0
inotify_inode_mark     30     30    136   30    1 : tunables    0    0    0 : slabdata      1      1      0
kvm_async_pf         448    448    144   28    1 : tunables    0    0    0 : slabdata     16     16      0
kvm_vcpu              64     94  13856    2    8 : tunables    0    0    0 : slabdata     47     47      0
UDP-Lite               0      0    768   42    8 : tunables    0    0    0 : slabdata      0      0      0
xfrm_dst_cache         0      0    448   36    4 : tunables    0    0    0 : slabdata      0      0      0
ip_fib_trie          219    219     56   73    1 : tunables    0    0    0 : slabdata      3      3      0
arp_cache            417    500    320   25    2 : tunables    0    0    0 : slabdata     20     20      0
RAW                  672    672    768   42    8 : tunables    0    0    0 : slabdata     16     16      0
UDP                  672    672    768   42    8 : tunables    0    0    0 : slabdata     16     16      0
tw_sock_TCP          512   1088    256   32    2 : tunables    0    0    0 : slabdata     34     34      0
TCP                  345    357   1536   21    8 : tunables    0    0    0 : slabdata     17     17      0
blkdev_queue         414    440   1616   20    8 : tunables    0    0    0 : slabdata     22     22      0
blkdev_requests      945   2209    344   47    4 : tunables    0    0    0 : slabdata     47     47      0
sock_inode_cache     456    475    640   25    4 : tunables    0    0    0 : slabdata     19     19      0
shmem_inode_cache   2063   2375    632   25    4 : tunables    0    0    0 : slabdata     95     95      0
Acpi-ParseExt       3848   3864     72   56    1 : tunables    0    0    0 : slabdata     69     69      0
Acpi-Namespace    633667 1059270     40  102    1 : tunables    0    0    0 : slabdata  10385  10385      0
task_delay_info     1238   1584    112   36    1 : tunables    0    0    0 : slabdata     44     44      0
taskstats            384    384    328   24    2 : tunables    0    0    0 : slabdata     16     16      0
proc_inode_cache    2460   3250    616   26    4 : tunables    0    0    0 : slabdata    125    125      0
sigqueue             400    400    160   25    1 : tunables    0    0    0 : slabdata     16     16      0
bdev_cache           701    714    768   42    8 : tunables    0    0    0 : slabdata     17     17      0
sysfs_dir_cache    31662  34425     80   51    1 : tunables    0    0    0 : slabdata    675    675      0
inode_cache         2546   3886    552   29    4 : tunables    0    0    0 : slabdata    134    134      0
dentry              9452  14868    192   42    2 : tunables    0    0    0 : slabdata    354    354      0
buffer_head       8175114 8360937    104   39    1 : tunables    0    0    0 : slabdata 214383 214383      0
vm_area_struct     35344  35834    176   46    2 : tunables    0    0    0 : slabdata    782    782      0
files_cache          736    874    704   46    8 : tunables    0    0    0 : slabdata     19     19      0
signal_cache        1011   1296    896   36    8 : tunables    0    0    0 : slabdata     36     36      0
sighand_cache        682    945   2112   15    8 : tunables    0    0    0 : slabdata     63     63      0
task_struct         1057   1386   1520   21    8 : tunables    0    0    0 : slabdata     66     66      0
anon_vma            2417   2856     72   56    1 : tunables    0    0    0 : slabdata     51     51      0
shared_policy_node   4877   6800     48   85    1 : tunables    0    0    0 : slabdata     80     80      0
numa_policy        45589  48450     24  170    1 : tunables    0    0    0 : slabdata    285    285      0
radix_tree_node   227192 248388    568   28    4 : tunables    0    0    0 : slabdata   9174   9174      0
idr_layer_cache      603    660    544   30    4 : tunables    0    0    0 : slabdata     22     22      0
dma-kmalloc-8192       0      0   8192    4    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-4096       0      0   4096    8    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-2048       0      0   2048   16    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-1024       0      0   1024   32    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-512        0      0    512   32    4 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-256        0      0    256   32    2 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-128        0      0    128   32    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-64         0      0     64   64    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-32         0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-16         0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-8          0      0      8  512    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-192        0      0    192   42    2 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-96         0      0     96   42    1 : tunables    0    0    0 : slabdata      0      0      0
kmalloc-8192          88    100   8192    4    8 : tunables    0    0    0 : slabdata     25     25      0
kmalloc-4096        3567   3704   4096    8    8 : tunables    0    0    0 : slabdata    463    463      0
kmalloc-2048       55140  55936   2048   16    8 : tunables    0    0    0 : slabdata   3496   3496      0
kmalloc-1024        5960   6496   1024   32    8 : tunables    0    0    0 : slabdata    203    203      0
kmalloc-512        12185  12704    512   32    4 : tunables    0    0    0 : slabdata    397    397      0
kmalloc-256       195078 199040    256   32    2 : tunables    0    0    0 : slabdata   6220   6220      0
kmalloc-128        45645  47328    128   32    1 : tunables    0    0    0 : slabdata   1479   1479      0
kmalloc-64        14647251 14776576     64   64    1 : tunables    0    0    0 : slabdata 230884 230884      0
kmalloc-32          5573   7552     32  128    1 : tunables    0    0    0 : slabdata     59     59      0
kmalloc-16          7550  10752     16  256    1 : tunables    0    0    0 : slabdata     42     42      0
kmalloc-8          13805  14848      8  512    1 : tunables    0    0    0 : slabdata     29     29      0
kmalloc-192        47641  50883    192   42    2 : tunables    0    0    0 : slabdata   1214   1214      0
kmalloc-96          3673   6006     96   42    1 : tunables    0    0    0 : slabdata    143    143      0
kmem_cache            32     32    256   32    2 : tunables    0    0    0 : slabdata      1      1      0
kmem_cache_node      495    576     64   64    1 : tunables    0    0    0 : slabdata      9      9      0

# cat /proc/buddyinfo
Node 0, zone      DMA      0      0      1      0      2      1      1      0      1      1      3
Node 0, zone    DMA32   9148   1941    657    673    131     53     18      2      0      0      0
Node 0, zone   Normal   8080     13      0      2      0      2      1      0      1      0      0
Node 1, zone   Normal  19071   3239    675    200    413     37      4      1      2      0      0
Node 2, zone   Normal  37716   3924    154      9      3      1      2      0      1      0      0
Node 3, zone   Normal  20015   4590   1768    996    334     20      1      1      1      0      0

# grep MemFree /sys/devices/system/node/node*/meminfo
/sys/devices/system/node/node0/meminfo:Node 0 MemFree:          201460 kB
/sys/devices/system/node/node1/meminfo:Node 1 MemFree:          283224 kB
/sys/devices/system/node/node2/meminfo:Node 2 MemFree:          287060 kB
/sys/devices/system/node/node3/meminfo:Node 3 MemFree:          316928 kB

# cat /proc/vmstat
nr_free_pages 224933
nr_inactive_anon 1173838
nr_active_anon 5209232
nr_inactive_file 6998686
nr_active_file 2180311
nr_unevictable 1685
nr_mlock 1685
nr_anon_pages 5940145
nr_mapped 1836
nr_file_pages 9635092
nr_dirty 603
nr_writeback 0
nr_slab_reclaimable 253121
nr_slab_unreclaimable 299440
nr_page_table_pages 32311
nr_kernel_stack 854
nr_unstable 0
nr_bounce 0
nr_vmscan_write 50485772
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 12
nr_dirtied 5630347228
nr_written 5625041387
numa_hit 28372623283
numa_miss 4761673976
numa_foreign 4761673976
numa_interleave 30490
numa_local 28372334279
numa_other 4761962980
nr_anon_transparent_hugepages 76
nr_dirty_threshold 8192
nr_dirty_background_threshold 4096
pgpgin 9523143630
pgpgout 23124688920
pswpin 57978726
pswpout 50121412
pgalloc_dma 0
pgalloc_dma32 1132547190
pgalloc_normal 32421613044
pgalloc_movable 0
pgfree 39379011152
pgactivate 751722445
pgdeactivate 591205976
pgfault 41103638391
pgmajfault 11853858
pgrefill_dma 0
pgrefill_dma32 24124080
pgrefill_normal 540719764
pgrefill_movable 0
pgsteal_dma 0
pgsteal_dma32 297677595
pgsteal_normal 4784595717
pgsteal_movable 0
pgscan_kswapd_dma 0
pgscan_kswapd_dma32 241277864
pgscan_kswapd_normal 4004618399
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_dma32 65729843
pgscan_direct_normal 1012932822
pgscan_direct_movable 0
zone_reclaim_failed 0
pginodesteal 66
slabs_scanned 668153728
kswapd_steal 4063341017
kswapd_inodesteal 2063
kswapd_low_wmark_hit_quickly 9834
kswapd_high_wmark_hit_quickly 488468
kswapd_skip_congestion_wait 580150
pageoutrun 22006623
allocstall 926752
pgrotated 28467920
compact_blocks_moved 522323130
compact_pages_moved 5774251432
compact_pagemigrate_failed 5267247
compact_stall 121045
compact_fail 68349
compact_success 52696
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 19976952
unevictable_pgs_scanned 0
unevictable_pgs_rescued 33137561
unevictable_pgs_mlocked 35042070
unevictable_pgs_munlocked 33138335
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 1024
thp_fault_alloc 263176
thp_fault_fallback 717335
thp_collapse_alloc 21307
thp_collapse_alloc_failed 91103
thp_split 90328

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
