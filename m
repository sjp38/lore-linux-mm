Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 860386B0517
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 06:33:48 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 185so1915951wmk.12
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 03:33:48 -0700 (PDT)
Received: from mail.univention.de (mail.univention.de. [82.198.197.8])
        by mx.google.com with ESMTPS id q7si969332wmg.118.2017.08.01.03.33.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 03:33:46 -0700 (PDT)
From: Philipp Hahn <hahn@univention.de>
Subject: [BUG] Slow SATA disk - waiting in balance_dirty_pages() on
 i686-pae.html
Message-ID: <2a526c85-0e27-7a5d-f606-66c74499352a@univention.de>
Date: Tue, 1 Aug 2017 12:32:40 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello,

;TL,DR: apt-get is blocked by balance_dirty_pages() with linux-{3,16
4.2, 4.9}, but fast after reboot.


We still have several systems running 4.9.0-ucs104-686-pae. They have 16
GiB RAM and two disk:
> # lsblk  -S
> NAME HCTL       TYPE VENDOR   MODEL             REV TRAN
> sdb  5:0:0:0    disk ATA      ST32000644NS     SN12 sata
> sr0  6:0:0:0    rom  Optiarc  DVD RW AD-7260S  1.03 sata
> sda  4:0:0:0    disk ATA      ST32000644NS     SN12 sata

After some time they get really slow, for example when running "apt-get
update" to update the list of available Debian packages. "vmstat" shows
a very hight "wait time":
> # vmstat 1
> procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
>  0  1      0 13545436 361480 1786148    0    0     2    21   25   35  2  1 95  2  0
>  0  2      0 13545312 361484 1786144    0    0     0   636  596  939  0  0 83 17  0
>  1  1      0 13543700 361488 1786148    0    0     4   464 3472  872  3  4 79 14  0
>  0  1      0 13545072 361488 1786148    0    0     0  2176 2504  905  3  4 79 13  0
>  0  1      0 13545188 361488 1786276    0    0     0  1832 1173  969  0  0 87 13  0
>  0  1      0 13545088 361488 1786276    0    0     0  1360  862 1036  0  0 87 12  0
>  0  2      0 13544560 361492 1786276    0    0     0  2276 1739  921  0  0 87 13  0
>  0  1      0 13545304 361500 1786276    0    0     0   468  581 1030  0  0 81 19  0
>  1  1      0 13543228 361500 1786284    0    0     0   520 1219 1078  2  3 82 13  0
>  0  2      0 13545228 361500 1786284    0    0     0   608  673 1054  3  5 75 17  0
>  0  1      0 13545436 361500 1786280    0    0     0   900 1343 1126  0  0 82 17  0
>  4  4      0 13526320 359140 1786280    0    0     0   440 2126 5782 30  6 50 14  0
>  0  2      0 13529640 359144 1786280    0    0     0  1480 2764 6362  2  3 65 30  0
>  0  2      0 13529744 359144 1786280    0    0     0   968  769 1737  0  0 74 25  0
>  0  2      0 13529884 359152 1786276    0    0     0  1036  688 1516  0  0 74 26  0
>  1  2      0 13530000 359152 1786408    0    0     0  1200  884 1402  1  1 75 23  0
>  1  2      0 13528500 359152 1786408    0    0     0  1492 1027 1340  3  4 70 23  0
>  0  3      0 13539544 359160 1786408    0    0     4  1892 1105 1204  1  1 70 28  0
>  0  2      0 13522632 359160 1786408    0    0     0  1056 3320 1838  6  4 64 26  0
>  0  1      0 13543488 359160 1786408    0    0     0  2604 1499 1200  1  0 82 17  0
>  0  1      0 13543728 359168 1786412    0    0     0  2508 1229  693  0  0 81 19  0

Loocking as 'wchan' I see it stuck in
> # ps -eo pid,tid,class,rtprio,ni,pri,psr,pcpu,stat,wchan:32,cgroup:48,comm | grep apt
> 21403 21403 TS       -   0  19   5  0.2 D+   balance_dirty_pages.isra.24      1:name=systemd:/system.slice/ssh.service         apt-get

"iostat" tell me that the system is constantly writing:
> avg-cpu:  %user   %nice %system %iowait  %steal   %idle
>            1,97    0,00    2,43   15,68    0,00   79,92
> 
> Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
> sdb               0,00     6,33    0,00  220,67     0,00     1,03     9,55     3,18   14,40    0,00   14,40   0,83  18,27
> sda               0,00     6,00    0,33  221,00     0,00     1,03     9,53     3,15   14,25   60,00   14,18   0,73  16,27
> md0               0,00     0,00    0,00    0,00     0,00     0,00     0,00     0,00    0,00    0,00    0,00   0,00   0,00
> md1               0,00     0,00    0,33  227,00     0,00     1,03     9,28     0,00    0,00    0,00    0,00   0,00   0,00
> dm-0              0,00     0,00    0,33  224,33     0,00     1,02     9,33     3,50   15,58   60,00   15,51   0,81  18,27
> dm-1              0,00     0,00    0,00    0,00     0,00     0,00     0,00     0,00    0,00    0,00    0,00   0,00   0,00
> dm-2              0,00     0,00    0,00    1,67     0,00     0,01     8,00     0,03   18,40    0,00   18,40  18,40   3,07
> dm-3              0,00     0,00    0,00    0,00     0,00     0,00     0,00     0,00    0,00    0,00    0,00   0,00   0,00
> dm-4              0,00     0,00    0,00    0,00     0,00     0,00     0,00     0,00    0,00    0,00    0,00   0,00   0,00
> dm-5              0,00     0,00    0,00    0,00     0,00     0,00     0,00     0,00    0,00    0,00    0,00   0,00   0,00

"echo 1 >/proc/sys/vm/block_dump" did now show any useful (to my
untrained eye):
> [142980.159166] apt-get(1010): dirtied inode 786560 (pkgcache.bin.Vv0g4q) on dm-0
> [142980.159183] apt-get(1010): dirtied inode 786560 (pkgcache.bin.Vv0g4q) on dm-0
> [142980.159438] kworker/u16:1(5188): WRITE block 49666728 on dm-0 (8 sectors)
> [142980.159450] kworker/u16:1(5188): WRITE block 49666968 on dm-0 (8 sectors)
> [142980.159455] kworker/u16:1(5188): WRITE block 49667384 on dm-0 (8 sectors)
> [142980.159460] kworker/u16:1(5188): WRITE block 49667568 on dm-0 (8 sectors)
> [142980.159465] kworker/u16:1(5188): WRITE block 49667584 on dm-0 (8 sectors)
> [142980.159470] kworker/u16:1(5188): WRITE block 49667616 on dm-0 (8 sectors)
> [142980.159474] kworker/u16:1(5188): WRITE block 49667664 on dm-0 (8 sectors)
> [142980.159479] kworker/u16:1(5188): WRITE block 49667704 on dm-0 (8 sectors)
> [142980.159489] kworker/u16:1(5188): WRITE block 49643520 on dm-0 (8 sectors)
> [142980.159494] kworker/u16:1(5188): WRITE block 49643680 on dm-0 (8 sectors)
> [142980.159499] kworker/u16:1(5188): WRITE block 49643920 on dm-0 (8 sectors)
> [142980.159503] kworker/u16:1(5188): WRITE block 49644240 on dm-0 (8 sectors)
> [142980.159508] kworker/u16:1(5188): WRITE block 49644408 on dm-0 (8 sectors)
> [142980.159513] kworker/u16:1(5188): WRITE block 49644872 on dm-0 (8 sectors)
> [142980.159517] kworker/u16:1(5188): WRITE block 49644888 on dm-0 (8 sectors)
> [142980.159522] kworker/u16:1(5188): WRITE block 49645048 on dm-0 (8 sectors)
> [142980.159527] kworker/u16:1(5188): WRITE block 49645072 on dm-0 (8 sectors)
> [142980.159531] kworker/u16:1(5188): WRITE block 49646088 on dm-0 (8 sectors)
> [142980.159536] kworker/u16:1(5188): WRITE block 49922424 on dm-0 (8 sectors)
> [142980.159541] kworker/u16:1(5188): WRITE block 49929072 on dm-0 (8 sectors)
> [142980.159545] kworker/u16:1(5188): WRITE block 49929296 on dm-0 (8 sectors)
> [142980.159551] kworker/u16:1(5188): WRITE block 49665288 on dm-0 (8 sectors)
> [142980.159555] kworker/u16:1(5188): WRITE block 49666272 on dm-0 (8 sectors)
> [142980.163173] rs:main Q:Reg(1284): dirtied inode 266 (debug) on dm-2
> [142980.163185] rs:main Q:Reg(1284): dirtied inode 266 (debug) on dm-2
> [142980.163251] kworker/u16:1(5188): WRITE block 14423192 on dm-2 (8 sectors)
> [142980.175161] rs:main Q:Reg(1284): dirtied inode 266 (debug) on dm-2
> [142980.175164] apt-get(1010): dirtied inode 786560 (pkgcache.bin.Vv0g4q) on dm-0
> [142980.175172] apt-get(1010): dirtied inode 786560 (pkgcache.bin.Vv0g4q) on dm-0
...
(I forgot to filter out those messages from syslog, so rsyslog is
constantly dirtying the log files with those messages)

On the other hand there doesn't seem to be much dirty data:
> # cat /proc/meminfo 
> MemTotal:       16519788 kB
> MemFree:        13524100 kB
> MemAvailable:   14599184 kB
> Buffers:          361420 kB
> Cached:          1808348 kB
> SwapCached:            0 kB
> Active:          1660840 kB
> Inactive:         973144 kB
> Active(anon):     467196 kB
> Inactive(anon):    40420 kB
> Active(file):    1193644 kB
> Inactive(file):   932724 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> HighTotal:      15778484 kB
> HighFree:       13476176 kB
> LowTotal:         741304 kB
> LowFree:           47924 kB
> SwapTotal:      25165820 kB
> SwapFree:       25165820 kB
> Dirty:                 4 kB
> Writeback:           268 kB
> AnonPages:        464272 kB
> Mapped:           514240 kB
> Shmem:             43344 kB
> Slab:             306304 kB
> SReclaimable:     282876 kB
> SUnreclaim:        23428 kB
> KernelStack:        3152 kB
> PageTables:         9620 kB
> NFS_Unstable:          0 kB
> Bounce:              536 kB
> WritebackTmp:          0 kB
> CommitLimit:    33425712 kB
> Committed_AS:    1957408 kB
> VmallocTotal:     122880 kB
> VmallocUsed:           0 kB
> VmallocChunk:          0 kB
> HardwareCorrupted:     0 kB
> AnonHugePages:         0 kB
> ShmemHugePages:        0 kB
> ShmemPmdMapped:        0 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> DirectMap4k:       10232 kB
> DirectMap2M:      899072 kB

Running "blktrace -d /dev/sda -d /dev/sdb -w 60" shows the disk to have
a very low write performance:
> Total (sda):
>  Reads Queued:           6,       24KiB  Writes Queued:        1091,     4076KiB
>  Read Dispatches:        6,       24KiB  Write Dispatches:      730,     4076KiB
>  Reads Requeued:         0               Writes Requeued:         6
>  Reads Completed:        6,       24KiB  Writes Completed:      992,     4076KiB
>  Read Merges:            0,        0KiB  Write Merges:          267,     1068KiB
>  PC Reads Queued:        0,        0KiB  PC Writes Queued:        0,        0KiB
>  PC Read Disp.:         20,        4KiB  PC Write Disp.:          0,        0KiB
>  PC Reads Req.:          7               PC Writes Req.:          0
>  PC Reads Compl.:       13               PC Writes Compl.:        0
>  IO unplugs:           508               Timer unplugs:           0
> 
> Throughput (R/W): 0KiB/s / 68KiB/s
> Events (sda): 12188 entries
> Skips: 0 forward (0 -   0.0%)
...
> Total (sdb):
>  Reads Queued:           2,        8KiB  Writes Queued:        1091,     4076KiB
>  Read Dispatches:        2,        8KiB  Write Dispatches:      727,     4076KiB
>  Reads Requeued:         0               Writes Requeued:         4
>  Reads Completed:        2,        8KiB  Writes Completed:      991,     4076KiB
>  Read Merges:            0,        0KiB  Write Merges:          268,     1072KiB
>  PC Reads Queued:        0,        0KiB  PC Writes Queued:        0,        0KiB
>  PC Read Disp.:         18,        4KiB  PC Write Disp.:          0,        0KiB
>  PC Reads Req.:          5               PC Writes Req.:          0
>  PC Reads Compl.:       13               PC Writes Compl.:        0
>  IO unplugs:           507               Timer unplugs:           0
> 
> Throughput (R/W): 0KiB/s / 68KiB/s
> Events (sdb): 12011 entries
> Skips: 0 forward (0 -   0.0%)
"sysctl" was not changes (to my knowledge):
> # sysctl -a | grep ^vm
> vm.admin_reserve_kbytes = 8192
> vm.block_dump = 0
> vm.compact_unevictable_allowed = 1
> vm.dirty_background_bytes = 0
> vm.dirty_background_ratio = 10
> vm.dirty_bytes = 0
> vm.dirty_expire_centisecs = 3000
> vm.dirty_ratio = 20
> vm.dirty_writeback_centisecs = 500
> vm.dirtytime_expire_seconds = 43200
> vm.drop_caches = 0
> vm.extfrag_threshold = 500
> vm.highmem_is_dirtyable = 0
> vm.hugepages_treat_as_movable = 0
> vm.hugetlb_shm_group = 0
> vm.laptop_mode = 0
> vm.legacy_va_layout = 0
> vm.lowmem_reserve_ratio = 256   32      32
> vm.max_map_count = 65530
> vm.memory_failure_early_kill = 0
> vm.memory_failure_recovery = 1
> vm.min_free_kbytes = 35204
> vm.mmap_min_addr = 65536
> vm.mmap_rnd_bits = 8
> vm.nr_hugepages = 0
> vm.nr_overcommit_hugepages = 0
> vm.nr_pdflush_threads = 0
> vm.oom_dump_tasks = 1
> vm.oom_kill_allocating_task = 0
> vm.overcommit_kbytes = 0
> vm.overcommit_memory = 0
> vm.overcommit_ratio = 50
> vm.page-cluster = 3
> vm.panic_on_oom = 0
> vm.percpu_pagelist_fraction = 0
> vm.stat_interval = 1
> vm.swappiness = 60
> vm.user_reserve_kbytes = 131072
> vm.vdso_enabled = 1
> vm.vfs_cache_pressure = 100
> vm.watermark_scale_factor = 10

Here's the 'SysRq-t' output (for that process):
> [148498.778772] apt-get         D    0 21403  10119 0x00000000
> [148498.778773]  00000000 e99c9480 c17756c0 e7243d0c c15afda5 f6a5f968 e7243d84 f5f07c00
> [148498.778776]  f5d90c00 10ea48c6 0000870f 10ea0f6b 0000870f e7c35e00 0000870f f7965e80
> [148498.778778]  e7243d18 e99c9480 f795fa40 f795fa40 e7243d18 c15b022e e7243d38 e7243d60
> [148498.778780] Call Trace:
> [148498.778782]  [<c15afda5>] ? __schedule+0x2b5/0x710
> [148498.778783]  [<c15b022e>] ? schedule+0x2e/0x80
> [148498.778784]  [<c15b2ff1>] ? schedule_timeout+0x131/0x2a0
> [148498.778786]  [<f85221a4>] ? jbd2_journal_stop+0xc4/0x3e0 [jbd2]
> [148498.778788]  [<c12f6457>] ? fprop_fraction_percpu+0x27/0xb0
> [148498.778790]  [<c10d5240>] ? lock_timer_base+0x80/0x80
> [148498.778791]  [<c15afa7b>] ? io_schedule_timeout+0x9b/0x110
> [148498.778793]  [<c11721d6>] ? balance_dirty_pages.isra.24+0x316/0xec0
> [148498.778794]  [<c12fa594>] ? radix_tree_tag_set+0x84/0xf0
> [148498.778796]  [<c11717d9>] ? set_page_dirty+0x49/0xb0
> [148498.778798]  [<c120e095>] ? block_page_mkwrite+0xe5/0x120
> [148498.778801]  [<c1173003>] ? balance_dirty_pages_ratelimited+0x283/0x3c0
> [148498.778804]  [<c119645c>] ? do_wp_page+0x6ac/0x7c0
> [148498.778807]  [<c105f92b>] ? kmap_atomic_prot+0xdb/0x100
> [148498.778810]  [<c1199a56>] ? handle_mm_fault+0x7e6/0x10d0
> [148498.778812]  [<c11d6f6f>] ? vfs_read+0x10f/0x140
> [148498.778815]  [<c10562f0>] ? __do_page_fault+0x1d0/0x510
> [148498.778818]  [<c1056630>] ? __do_page_fault+0x510/0x510
> [148498.778820]  [<c15b5643>] ? error_code+0x67/0x6c

There is a similar reports at
<https://askubuntu.com/questions/251781/reading-package-list-takes-forever/327444>
and we're seeing it at a regular interval.
Rebooting system fixes it (apt-get is fast again), but re-occurs after
some time.

We have used several different Linux kernel versions by now (3.16, 4.2,
4.9), but all show the same bug.
It is not limited to 'apt', we have seen it with 'slapadd' as well.
We only observed this on 686-pae, never on amd64 - may be an 32 bit
overflow bug?

Any other idea?

What other data should I collect to help diagnose this?

Philipp
-- 
Philipp Hahn
Open Source Software Engineer

Univention GmbH
be open.
Mary-Somerville-Str. 1
D-28359 Bremen
Tel.: +49 421 22232-0
Fax : +49 421 22232-99
hahn@univention.de

http://www.univention.de/
GeschA?ftsfA 1/4 hrer: Peter H. Ganten
HRB 20755 Amtsgericht Bremen
Steuer-Nr.: 71-597-02876

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
