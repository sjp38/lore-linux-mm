Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id BFDDF6B0078
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 12:56:15 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id gb23so2675668vcb.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2012 09:56:14 -0800 (PST)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 3 Dec 2012 09:55:54 -0800
Message-ID: <CALCETrX0t6YkzA5Q2rozsmbDCrrGgUopZVCMwT_vv0gVcvDDCw@mail.gmail.com>
Subject: kswapd infinite loop in 3.7-rc6?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

The stack looks like this:

[<ffffffff81192015>] put_super+0x25/0x40
[<ffffffff811920f2>] drop_super+0x22/0x30
[<ffffffff81193199>] prune_super+0x149/0x1b0
[<ffffffff8113f241>] shrink_slab+0xa1/0x2d0
[<ffffffff81142b09>] balance_pgdat+0x609/0x7d0
[<ffffffff81142e44>] kswapd+0x174/0x450
[<ffffffff81081810>] kthread+0xc0/0xd0
[<ffffffff8161e3ac>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

/proc/meminfo says:

$ cat /proc/meminfo
MemTotal:        3934452 kB
MemFree:          865764 kB
Buffers:          398132 kB
Cached:          1527112 kB
SwapCached:            0 kB
Active:          1586392 kB
Inactive:        1236996 kB
Active(anon):    1000348 kB
Inactive(anon):    40136 kB
Active(file):     586044 kB
Inactive(file):  1196860 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:               484 kB
Writeback:             0 kB
AnonPages:        898124 kB
Mapped:           111668 kB
Shmem:            142340 kB
Slab:             132552 kB
SReclaimable:      86612 kB
SUnreclaim:        45940 kB
KernelStack:        2920 kB
PageTables:        27052 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     1967224 kB
Committed_AS:    2492792 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      376628 kB
VmallocChunk:   34359339160 kB
HardwareCorrupted:     0 kB
AnonHugePages:    118784 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:       90112 kB
DirectMap2M:     3995648 kB

/proc/zoneinfo says:

Node 0, zone      DMA
  pages free     3975
        min      65
        low      81
        high     97
        scanned  0
        spanned  4080
        present  3911
    nr_free_pages 3975
    nr_inactive_anon 0
    nr_active_anon 0
    nr_inactive_file 0
    nr_active_file 0
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 0
    nr_mapped    0
    nr_file_pages 0
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 0
    nr_slab_unreclaimable 0
    nr_page_table_pages 0
    nr_kernel_stack 0
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_vmscan_immediate_reclaim 0
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     0
    nr_dirtied   0
    nr_written   0
    numa_hit     0
    numa_miss    0
    numa_foreign 0
    numa_interleave 0
    numa_local   0
    numa_other   0
    nr_anon_transparent_hugepages 0
    nr_free_cma  0
        protection: (0, 3417, 3896, 3896)
  pagesets
    cpu: 0
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 4
    cpu: 1
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 4
    cpu: 2
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 4
    cpu: 3
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 4
  all_unreclaimable: 1
  start_pfn:         16
  inactive_ratio:    1
Node 0, zone    DMA32
  pages free     208727
        min      14763
        low      18453
        high     22144
        scanned  0
        spanned  1044480
        present  874976
    nr_free_pages 208727
    nr_inactive_anon 7218
    nr_active_anon 189293
    nr_inactive_file 295611
    nr_active_file 142566
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 138923
    nr_mapped    25584
    nr_file_pages 467056
    nr_dirty     208
    nr_writeback 0
    nr_slab_reclaimable 16532
    nr_slab_unreclaimable 3813
    nr_page_table_pages 4940
    nr_kernel_stack 164
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_vmscan_immediate_reclaim 0
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     28879
    nr_dirtied   3350046
    nr_written   2639131
    numa_hit     47784160
    numa_miss    0
    numa_foreign 0
    numa_interleave 0
    numa_local   47784160
    numa_other   0
    nr_anon_transparent_hugepages 56
    nr_free_cma  0
        protection: (0, 0, 478, 478)
  pagesets
    cpu: 0
              count: 162
              high:  186
              batch: 31
  vm stats threshold: 36
    cpu: 1
              count: 77
              high:  186
              batch: 31
  vm stats threshold: 36
    cpu: 2
              count: 89
              high:  186
              batch: 31
  vm stats threshold: 36
    cpu: 3
              count: 136
              high:  186
              batch: 31
  vm stats threshold: 36
  all_unreclaimable: 0
  start_pfn:         4096
  inactive_ratio:    5
Node 0, zone   Normal
  pages free     2318
        min      2066
        low      2582
        high     3099
        scanned  0
        spanned  124416
        present  122472
    nr_free_pages 2318
    nr_inactive_anon 2842
    nr_active_anon 62181
    nr_inactive_file 3522
    nr_active_file 3943
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 57301
    nr_mapped    2333
    nr_file_pages 14163
    nr_dirty     3
    nr_writeback 0
    nr_slab_reclaimable 5121
    nr_slab_unreclaimable 7647
    nr_page_table_pages 1824
    nr_kernel_stack 201
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_vmscan_immediate_reclaim 77236
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     6698
    nr_dirtied   297229
    nr_written   234810
    numa_hit     29846177
    numa_miss    0
    numa_foreign 0
    numa_interleave 17548
    numa_local   29846177
    numa_other   0
    nr_anon_transparent_hugepages 2
    nr_free_cma  0
        protection: (0, 0, 0, 0)
  pagesets
    cpu: 0
              count: 171
              high:  186
              batch: 31
  vm stats threshold: 125
    cpu: 1
              count: 143
              high:  186
              batch: 31
  vm stats threshold: 125
    cpu: 2
              count: 169
              high:  186
              batch: 31
  vm stats threshold: 125
    cpu: 3
              count: 116
              high:  186
              batch: 31
  vm stats threshold: 125
  all_unreclaimable: 0
  start_pfn:         1048576
  inactive_ratio:    1


This is a Lenovo x220 with 4G ram, and IIRC it has an odd memory map
with a tiny high memory zone.  It's triggered bugs like this before.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
